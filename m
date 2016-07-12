Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f70.google.com (mail-pa0-f70.google.com [209.85.220.70])
	by kanga.kvack.org (Postfix) with ESMTP id 2DC456B025E
	for <linux-mm@kvack.org>; Tue, 12 Jul 2016 09:12:38 -0400 (EDT)
Received: by mail-pa0-f70.google.com with SMTP id hh10so27211879pac.3
        for <linux-mm@kvack.org>; Tue, 12 Jul 2016 06:12:38 -0700 (PDT)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2001:1868:205::9])
        by mx.google.com with ESMTPS id e8si4519944pfg.248.2016.07.12.06.12.37
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 12 Jul 2016 06:12:37 -0700 (PDT)
Date: Tue, 12 Jul 2016 15:12:35 +0200
From: Peter Zijlstra <peterz@infradead.org>
Subject: Re: divide error: 0000 [#1] SMP in task_numa_migrate -
 handle_mm_fault vanilla 4.4.6
Message-ID: <20160712131235.GO30154@twins.programming.kicks-ass.net>
References: <20160320214130.GB23920@kroah.com>
 <56EFD267.9070609@profihost.ag>
 <20160321133815.GA14188@kroah.com>
 <573AB3BF.3030604@profihost.ag>
 <CAPerZE_OCJGp2v8dXM=dY8oP1ydX_oB29UbzaXMHKZcrsL_iJg@mail.gmail.com>
 <CAPerZE_WLYzrALa3YOzC2+NWr--1GL9na8WLssFBNbRsXcYMiA@mail.gmail.com>
 <20160622061356.GW30154@twins.programming.kicks-ass.net>
 <CAPerZE99rBx6YCZrudJPTh7L-LCWitk7n7g41pt7JLej_2KR1g@mail.gmail.com>
 <20160707074232.GS30921@twins.programming.kicks-ass.net>
 <20160711223353.GA8959@kroah.com>
MIME-Version: 1.0
Content-Type: multipart/mixed; boundary="vtzGhvizbBRQ85DL"
Content-Disposition: inline
In-Reply-To: <20160711223353.GA8959@kroah.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Greg KH <greg@kroah.com>
Cc: Campbell Steven <casteven@gmail.com>, Stefan Priebe - Profihost AG <s.priebe@profihost.ag>, Vlastimil Babka <vbabka@suse.cz>, LKML <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, linux-mm@vger.kernel.org, Ingo Molnar <mingo@redhat.com>, Rik van Riel <riel@redhat.com>


--vtzGhvizbBRQ85DL
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

On Mon, Jul 11, 2016 at 03:33:53PM -0700, Greg KH wrote:

> Oops, this commit does not apply cleanly to 4.6 or 4.4-stable trees.
> Can someone send me the backported verision that they have tested to
> work properly so I can queue it up?

I've never actually been able to reproduce, but the attached patches
apply, the reject was trivial.

They seem to compile and boot on my main test rig, but nothing else was
done but build the next kernel with it.



--vtzGhvizbBRQ85DL
Content-Type: text/x-diff; charset=us-ascii
Content-Disposition: attachment; filename="sched-stable-4.4.patch"

commit 8974189222159154c55f24ddad33e3613960521a
Author: Peter Zijlstra <peterz@infradead.org>
Date:   Thu Jun 16 10:50:40 2016 +0200

    sched/fair: Fix cfs_rq avg tracking underflow
    
    As per commit:
    
      b7fa30c9cc48 ("sched/fair: Fix post_init_entity_util_avg() serialization")
    
    > the code generated from update_cfs_rq_load_avg():
    >
    > 	if (atomic_long_read(&cfs_rq->removed_load_avg)) {
    > 		s64 r = atomic_long_xchg(&cfs_rq->removed_load_avg, 0);
    > 		sa->load_avg = max_t(long, sa->load_avg - r, 0);
    > 		sa->load_sum = max_t(s64, sa->load_sum - r * LOAD_AVG_MAX, 0);
    > 		removed_load = 1;
    > 	}
    >
    > turns into:
    >
    > ffffffff81087064:       49 8b 85 98 00 00 00    mov    0x98(%r13),%rax
    > ffffffff8108706b:       48 85 c0                test   %rax,%rax
    > ffffffff8108706e:       74 40                   je     ffffffff810870b0 <update_blocked_averages+0xc0>
    > ffffffff81087070:       4c 89 f8                mov    %r15,%rax
    > ffffffff81087073:       49 87 85 98 00 00 00    xchg   %rax,0x98(%r13)
    > ffffffff8108707a:       49 29 45 70             sub    %rax,0x70(%r13)
    > ffffffff8108707e:       4c 89 f9                mov    %r15,%rcx
    > ffffffff81087081:       bb 01 00 00 00          mov    $0x1,%ebx
    > ffffffff81087086:       49 83 7d 70 00          cmpq   $0x0,0x70(%r13)
    > ffffffff8108708b:       49 0f 49 4d 70          cmovns 0x70(%r13),%rcx
    >
    > Which you'll note ends up with sa->load_avg -= r in memory at
    > ffffffff8108707a.
    
    So I _should_ have looked at other unserialized users of ->load_avg,
    but alas. Luckily nikbor reported a similar /0 from task_h_load() which
    instantly triggered recollection of this here problem.
    
    Aside from the intermediate value hitting memory and causing problems,
    there's another problem: the underflow detection relies on the signed
    bit. This reduces the effective width of the variables, IOW its
    effectively the same as having these variables be of signed type.
    
    This patch changes to a different means of unsigned underflow
    detection to not rely on the signed bit. This allows the variables to
    use the 'full' unsigned range. And it does so with explicit LOAD -
    STORE to ensure any intermediate value will never be visible in
    memory, allowing these unserialized loads.
    
    Note: GCC generates crap code for this, might warrant a look later.
    
    Note2: I say 'full' above, if we end up at U*_MAX we'll still explode;
           maybe we should do clamping on add too.
    
    Signed-off-by: Peter Zijlstra (Intel) <peterz@infradead.org>
    Cc: Andrey Ryabinin <aryabinin@virtuozzo.com>
    Cc: Chris Wilson <chris@chris-wilson.co.uk>
    Cc: Linus Torvalds <torvalds@linux-foundation.org>
    Cc: Mike Galbraith <efault@gmx.de>
    Cc: Peter Zijlstra <peterz@infradead.org>
    Cc: Thomas Gleixner <tglx@linutronix.de>
    Cc: Yuyang Du <yuyang.du@intel.com>
    Cc: bsegall@google.com
    Cc: kernel@kyup.com
    Cc: morten.rasmussen@arm.com
    Cc: pjt@google.com
    Cc: steve.muckle@linaro.org
    Fixes: 9d89c257dfb9 ("sched/fair: Rewrite runnable load and utilization average tracking")
    Link: http://lkml.kernel.org/r/20160617091948.GJ30927@twins.programming.kicks-ass.net
    Signed-off-by: Ingo Molnar <mingo@kernel.org>

---
 kernel/sched/fair.c |   33 +++++++++++++++++++++++++--------
 1 file changed, 25 insertions(+), 8 deletions(-)

--- a/kernel/sched/fair.c
+++ b/kernel/sched/fair.c
@@ -2682,6 +2682,23 @@ static inline void update_tg_load_avg(st
 
 static inline u64 cfs_rq_clock_task(struct cfs_rq *cfs_rq);
 
+/*
+ * Unsigned subtract and clamp on underflow.
+ *
+ * Explicitly do a load-store to ensure the intermediate value never hits
+ * memory. This allows lockless observations without ever seeing the negative
+ * values.
+ */
+#define sub_positive(_ptr, _val) do {				\
+	typeof(_ptr) ptr = (_ptr);				\
+	typeof(*ptr) val = (_val);				\
+	typeof(*ptr) res, var = READ_ONCE(*ptr);		\
+	res = var - val;					\
+	if (res > var)						\
+		res = 0;					\
+	WRITE_ONCE(*ptr, res);					\
+} while (0)
+
 /* Group cfs_rq's load_avg is used for task_h_load and update_cfs_share */
 static inline int update_cfs_rq_load_avg(u64 now, struct cfs_rq *cfs_rq)
 {
@@ -2690,15 +2707,15 @@ static inline int update_cfs_rq_load_avg
 
 	if (atomic_long_read(&cfs_rq->removed_load_avg)) {
 		s64 r = atomic_long_xchg(&cfs_rq->removed_load_avg, 0);
-		sa->load_avg = max_t(long, sa->load_avg - r, 0);
-		sa->load_sum = max_t(s64, sa->load_sum - r * LOAD_AVG_MAX, 0);
+		sub_positive(&sa->load_avg, r);
+		sub_positive(&sa->load_sum, r * LOAD_AVG_MAX);
 		removed = 1;
 	}
 
 	if (atomic_long_read(&cfs_rq->removed_util_avg)) {
 		long r = atomic_long_xchg(&cfs_rq->removed_util_avg, 0);
-		sa->util_avg = max_t(long, sa->util_avg - r, 0);
-		sa->util_sum = max_t(s32, sa->util_sum - r * LOAD_AVG_MAX, 0);
+		sub_positive(&sa->util_avg, r);
+		sub_positive(&sa->util_sum, r * LOAD_AVG_MAX);
 	}
 
 	decayed = __update_load_avg(now, cpu_of(rq_of(cfs_rq)), sa,
@@ -2764,10 +2781,10 @@ static void detach_entity_load_avg(struc
 			  &se->avg, se->on_rq * scale_load_down(se->load.weight),
 			  cfs_rq->curr == se, NULL);
 
-	cfs_rq->avg.load_avg = max_t(long, cfs_rq->avg.load_avg - se->avg.load_avg, 0);
-	cfs_rq->avg.load_sum = max_t(s64,  cfs_rq->avg.load_sum - se->avg.load_sum, 0);
-	cfs_rq->avg.util_avg = max_t(long, cfs_rq->avg.util_avg - se->avg.util_avg, 0);
-	cfs_rq->avg.util_sum = max_t(s32,  cfs_rq->avg.util_sum - se->avg.util_sum, 0);
+	sub_positive(&cfs_rq->avg.load_avg, se->avg.load_avg);
+	sub_positive(&cfs_rq->avg.load_sum, se->avg.load_sum);
+	sub_positive(&cfs_rq->avg.util_avg, se->avg.util_avg);
+	sub_positive(&cfs_rq->avg.util_sum, se->avg.util_sum);
 }
 
 /* Add the load generated by se into cfs_rq's load average */

--vtzGhvizbBRQ85DL
Content-Type: text/x-diff; charset=us-ascii
Content-Disposition: attachment; filename="sched-stable-4.6.patch"

commit 8974189222159154c55f24ddad33e3613960521a
Author: Peter Zijlstra <peterz@infradead.org>
Date:   Thu Jun 16 10:50:40 2016 +0200

    sched/fair: Fix cfs_rq avg tracking underflow

    As per commit:

      b7fa30c9cc48 ("sched/fair: Fix post_init_entity_util_avg() serialization")

    > the code generated from update_cfs_rq_load_avg():
    >
    > 	if (atomic_long_read(&cfs_rq->removed_load_avg)) {
    > 		s64 r = atomic_long_xchg(&cfs_rq->removed_load_avg, 0);
    > 		sa->load_avg = max_t(long, sa->load_avg - r, 0);
    > 		sa->load_sum = max_t(s64, sa->load_sum - r * LOAD_AVG_MAX, 0);
    > 		removed_load = 1;
    > 	}
    >
    > turns into:
    >
    > ffffffff81087064:       49 8b 85 98 00 00 00    mov    0x98(%r13),%rax
    > ffffffff8108706b:       48 85 c0                test   %rax,%rax
    > ffffffff8108706e:       74 40                   je     ffffffff810870b0 <update_blocked_averages+0xc0>
    > ffffffff81087070:       4c 89 f8                mov    %r15,%rax
    > ffffffff81087073:       49 87 85 98 00 00 00    xchg   %rax,0x98(%r13)
    > ffffffff8108707a:       49 29 45 70             sub    %rax,0x70(%r13)
    > ffffffff8108707e:       4c 89 f9                mov    %r15,%rcx
    > ffffffff81087081:       bb 01 00 00 00          mov    $0x1,%ebx
    > ffffffff81087086:       49 83 7d 70 00          cmpq   $0x0,0x70(%r13)
    > ffffffff8108708b:       49 0f 49 4d 70          cmovns 0x70(%r13),%rcx
    >
    > Which you'll note ends up with sa->load_avg -= r in memory at
    > ffffffff8108707a.

    So I _should_ have looked at other unserialized users of ->load_avg,
    but alas. Luckily nikbor reported a similar /0 from task_h_load() which
    instantly triggered recollection of this here problem.

    Aside from the intermediate value hitting memory and causing problems,
    there's another problem: the underflow detection relies on the signed
    bit. This reduces the effective width of the variables, IOW its
    effectively the same as having these variables be of signed type.

    This patch changes to a different means of unsigned underflow
    detection to not rely on the signed bit. This allows the variables to
    use the 'full' unsigned range. And it does so with explicit LOAD -
    STORE to ensure any intermediate value will never be visible in
    memory, allowing these unserialized loads.

    Note: GCC generates crap code for this, might warrant a look later.

    Note2: I say 'full' above, if we end up at U*_MAX we'll still explode;
           maybe we should do clamping on add too.

    Signed-off-by: Peter Zijlstra (Intel) <peterz@infradead.org>
    Cc: Andrey Ryabinin <aryabinin@virtuozzo.com>
    Cc: Chris Wilson <chris@chris-wilson.co.uk>
    Cc: Linus Torvalds <torvalds@linux-foundation.org>
    Cc: Mike Galbraith <efault@gmx.de>
    Cc: Peter Zijlstra <peterz@infradead.org>
    Cc: Thomas Gleixner <tglx@linutronix.de>
    Cc: Yuyang Du <yuyang.du@intel.com>
    Cc: bsegall@google.com
    Cc: kernel@kyup.com
    Cc: morten.rasmussen@arm.com
    Cc: pjt@google.com
    Cc: steve.muckle@linaro.org
    Fixes: 9d89c257dfb9 ("sched/fair: Rewrite runnable load and utilization average tracking")
    Link: http://lkml.kernel.org/r/20160617091948.GJ30927@twins.programming.kicks-ass.net
    Signed-off-by: Ingo Molnar <mingo@kernel.org>

--- a/kernel/sched/fair.c
+++ b/kernel/sched/fair.c
@@ -2821,6 +2821,23 @@ static inline void update_tg_load_avg(st
 
 static inline u64 cfs_rq_clock_task(struct cfs_rq *cfs_rq);
 
+/*
+ * Unsigned subtract and clamp on underflow.
+ *
+ * Explicitly do a load-store to ensure the intermediate value never hits
+ * memory. This allows lockless observations without ever seeing the negative
+ * values.
+ */
+#define sub_positive(_ptr, _val) do {				\
+	typeof(_ptr) ptr = (_ptr);				\
+	typeof(*ptr) val = (_val);				\
+	typeof(*ptr) res, var = READ_ONCE(*ptr);		\
+	res = var - val;					\
+	if (res > var)						\
+		res = 0;					\
+	WRITE_ONCE(*ptr, res);					\
+} while (0)
+
 /* Group cfs_rq's load_avg is used for task_h_load and update_cfs_share */
 static inline int update_cfs_rq_load_avg(u64 now, struct cfs_rq *cfs_rq)
 {
@@ -2829,15 +2846,15 @@ static inline int update_cfs_rq_load_avg
 
 	if (atomic_long_read(&cfs_rq->removed_load_avg)) {
 		s64 r = atomic_long_xchg(&cfs_rq->removed_load_avg, 0);
-		sa->load_avg = max_t(long, sa->load_avg - r, 0);
-		sa->load_sum = max_t(s64, sa->load_sum - r * LOAD_AVG_MAX, 0);
+		sub_positive(&sa->load_avg, r);
+		sub_positive(&sa->load_sum, r * LOAD_AVG_MAX);
 		removed = 1;
 	}
 
 	if (atomic_long_read(&cfs_rq->removed_util_avg)) {
 		long r = atomic_long_xchg(&cfs_rq->removed_util_avg, 0);
-		sa->util_avg = max_t(long, sa->util_avg - r, 0);
-		sa->util_sum = max_t(s32, sa->util_sum - r * LOAD_AVG_MAX, 0);
+		sub_positive(&sa->util_avg, r);
+		sub_positive(&sa->util_sum, r * LOAD_AVG_MAX);
 	}
 
 	decayed = __update_load_avg(now, cpu_of(rq_of(cfs_rq)), sa,
@@ -2927,10 +2944,10 @@ static void detach_entity_load_avg(struc
 			  &se->avg, se->on_rq * scale_load_down(se->load.weight),
 			  cfs_rq->curr == se, NULL);
 
-	cfs_rq->avg.load_avg = max_t(long, cfs_rq->avg.load_avg - se->avg.load_avg, 0);
-	cfs_rq->avg.load_sum = max_t(s64,  cfs_rq->avg.load_sum - se->avg.load_sum, 0);
-	cfs_rq->avg.util_avg = max_t(long, cfs_rq->avg.util_avg - se->avg.util_avg, 0);
-	cfs_rq->avg.util_sum = max_t(s32,  cfs_rq->avg.util_sum - se->avg.util_sum, 0);
+	sub_positive(&cfs_rq->avg.load_avg, se->avg.load_avg);
+	sub_positive(&cfs_rq->avg.load_sum, se->avg.load_sum);
+	sub_positive(&cfs_rq->avg.util_avg, se->avg.util_avg);
+	sub_positive(&cfs_rq->avg.util_sum, se->avg.util_sum);
 }
 
 /* Add the load generated by se into cfs_rq's load average */

--vtzGhvizbBRQ85DL--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
