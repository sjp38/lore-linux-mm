Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f69.google.com (mail-it0-f69.google.com [209.85.214.69])
	by kanga.kvack.org (Postfix) with ESMTP id 724766B007E
	for <linux-mm@kvack.org>; Wed,  1 Jun 2016 14:16:29 -0400 (EDT)
Received: by mail-it0-f69.google.com with SMTP id i127so53362593ita.2
        for <linux-mm@kvack.org>; Wed, 01 Jun 2016 11:16:29 -0700 (PDT)
Received: from merlin.infradead.org (merlin.infradead.org. [2001:4978:20e::2])
        by mx.google.com with ESMTPS id c79si40394457itd.63.2016.06.01.11.16.22
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 01 Jun 2016 11:16:23 -0700 (PDT)
Date: Wed, 1 Jun 2016 20:16:17 +0200
From: Peter Zijlstra <peterz@infradead.org>
Subject: Re: Xfs lockdep warning with for-dave-for-4.6 branch
Message-ID: <20160601181617.GV3190@twins.programming.kicks-ass.net>
References: <20160513160341.GW20141@dhcp22.suse.cz>
 <20160516104130.GK3193@twins.programming.kicks-ass.net>
 <20160516130519.GJ23146@dhcp22.suse.cz>
 <20160516132541.GP3193@twins.programming.kicks-ass.net>
 <20160516231056.GE18496@dastard>
 <20160517144912.GZ3193@twins.programming.kicks-ass.net>
 <20160517223549.GV26977@dastard>
 <20160519081146.GS3193@twins.programming.kicks-ass.net>
 <20160520001714.GC26977@dastard>
 <20160601131758.GO26601@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20160601131758.GO26601@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Dave Chinner <david@fromorbit.com>, "Darrick J. Wong" <darrick.wong@oracle.com>, Qu Wenruo <quwenruo@cn.fujitsu.com>, xfs@oss.sgi.com, linux-mm@kvack.org, Ingo Molnar <mingo@kernel.org>

On Wed, Jun 01, 2016 at 03:17:58PM +0200, Michal Hocko wrote:
> Thanks Dave for your detailed explanation again! Peter do you have any
> other idea how to deal with these situations other than opt out from
> lockdep reclaim machinery?
> 
> If not I would rather go with an annotation than a gfp flag to be honest
> but if you absolutely hate that approach then I will try to check wheter
> a CONFIG_LOCKDEP GFP_FOO doesn't break something else. Otherwise I would
> steal the description from Dave's email and repost my patch.
> 
> I plan to repost my scope gfp patches in few days and it would be good
> to have some mechanism to drop those GFP_NOFS to paper over lockdep
> false positives for that.

Right; sorry I got side-tracked in other things again.

So my favourite is the dedicated GFP flag, but if that's unpalatable for
the mm folks then something like the below might work. It should be
similar in effect to your proposal, except its more limited in scope.

---
 include/linux/gfp.h      |  5 ++++-
 include/linux/lockdep.h  |  2 ++
 kernel/locking/lockdep.c | 36 ++++++++++++++++++++++++++++++++++++
 3 files changed, 42 insertions(+), 1 deletion(-)

diff --git a/include/linux/gfp.h b/include/linux/gfp.h
index 570383a41853..d6be35643ee7 100644
--- a/include/linux/gfp.h
+++ b/include/linux/gfp.h
@@ -187,7 +187,10 @@ struct vm_area_struct;
 #define __GFP_NOTRACK_FALSE_POSITIVE (__GFP_NOTRACK)
 #define __GFP_OTHER_NODE ((__force gfp_t)___GFP_OTHER_NODE)
 
-/* Room for N __GFP_FOO bits */
+/*
+ * Room for N __GFP_FOO bits.
+ * Fix lockdep's __GFP_SKIP_ALLOC if this ever hits 32.
+ */
 #define __GFP_BITS_SHIFT 26
 #define __GFP_BITS_MASK ((__force gfp_t)((1 << __GFP_BITS_SHIFT) - 1))
 
diff --git a/include/linux/lockdep.h b/include/linux/lockdep.h
index eabe0138eb06..08a021b1e275 100644
--- a/include/linux/lockdep.h
+++ b/include/linux/lockdep.h
@@ -354,6 +354,7 @@ static inline void lock_set_subclass(struct lockdep_map *lock,
 
 extern void lockdep_set_current_reclaim_state(gfp_t gfp_mask);
 extern void lockdep_clear_current_reclaim_state(void);
+extern void lockdep_skip_alloc(void);
 extern void lockdep_trace_alloc(gfp_t mask);
 
 struct pin_cookie { unsigned int val; };
@@ -398,6 +399,7 @@ static inline void lockdep_on(void)
 # define lock_set_subclass(l, s, i)		do { } while (0)
 # define lockdep_set_current_reclaim_state(g)	do { } while (0)
 # define lockdep_clear_current_reclaim_state()	do { } while (0)
+# define lockdep_skip_alloc()			do { } while (0)
 # define lockdep_trace_alloc(g)			do { } while (0)
 # define lockdep_info()				do { } while (0)
 # define lockdep_init_map(lock, name, key, sub) \
diff --git a/kernel/locking/lockdep.c b/kernel/locking/lockdep.c
index 589d763a49b3..aa3ccbadc74e 100644
--- a/kernel/locking/lockdep.c
+++ b/kernel/locking/lockdep.c
@@ -2851,6 +2851,13 @@ void trace_softirqs_off(unsigned long ip)
 		debug_atomic_inc(redundant_softirqs_off);
 }
 
+#define __GFP_SKIP_ALLOC (1UL << __GFP_BITS_SHIFT)
+
+static void __lockdep_skip_alloc(void)
+{
+	current->lockdep_reclaim_gfp |= __GFP_SKIP_ALLOC;
+}
+
 static void __lockdep_trace_alloc(gfp_t gfp_mask, unsigned long flags)
 {
 	struct task_struct *curr = current;
@@ -2876,11 +2883,36 @@ static void __lockdep_trace_alloc(gfp_t gfp_mask, unsigned long flags)
 	if (DEBUG_LOCKS_WARN_ON(irqs_disabled_flags(flags)))
 		return;
 
+	/*
+	 * Skip _one_ allocation as per the lockdep_skip_alloc() request.
+	 * Must be done last so that we don't loose the annotation for
+	 * GFP_ATOMIC like things from IRQ or other nesting contexts.
+	 */
+	if (current->lockdep_reclaim_gfp & __GFP_SKIP_ALLOC) {
+		current->lockdep_reclaim_gfp &= ~__GFP_SKIP_ALLOC;
+		return;
+	}
+
 	mark_held_locks(curr, RECLAIM_FS);
 }
 
 static void check_flags(unsigned long flags);
 
+void lockdep_skip_alloc(void)
+{
+	unsigned long flags;
+
+	if (unlikely(current->lockdep_recursion))
+		return;
+
+	raw_local_irq_save(flags);
+	check_flags(flags);
+	current->lockdep_recursion = 1;
+	__lockdep_skip_alloc();
+	current->lockdep_recursion = 0;
+	raw_local_irq_restore(flags);
+}
+
 void lockdep_trace_alloc(gfp_t gfp_mask)
 {
 	unsigned long flags;
@@ -3015,6 +3047,10 @@ static inline int separate_irq_context(struct task_struct *curr,
 	return 0;
 }
 
+void lockdep_skip_alloc(void)
+{
+}
+
 void lockdep_trace_alloc(gfp_t gfp_mask)
 {
 }

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
