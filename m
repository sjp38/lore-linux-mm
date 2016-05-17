Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f200.google.com (mail-ig0-f200.google.com [209.85.213.200])
	by kanga.kvack.org (Postfix) with ESMTP id 1DD136B0005
	for <linux-mm@kvack.org>; Tue, 17 May 2016 10:49:20 -0400 (EDT)
Received: by mail-ig0-f200.google.com with SMTP id i5so39566940ige.1
        for <linux-mm@kvack.org>; Tue, 17 May 2016 07:49:20 -0700 (PDT)
Received: from merlin.infradead.org (merlin.infradead.org. [2001:4978:20e::2])
        by mx.google.com with ESMTPS id p6si15376063ige.39.2016.05.17.07.49.18
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 17 May 2016 07:49:18 -0700 (PDT)
Date: Tue, 17 May 2016 16:49:12 +0200
From: Peter Zijlstra <peterz@infradead.org>
Subject: Re: Xfs lockdep warning with for-dave-for-4.6 branch
Message-ID: <20160517144912.GZ3193@twins.programming.kicks-ass.net>
References: <94cea603-2782-1c5a-e2df-42db4459a8ce@cn.fujitsu.com>
 <20160512055756.GE6648@birch.djwong.org>
 <20160512080321.GA18496@dastard>
 <20160513160341.GW20141@dhcp22.suse.cz>
 <20160516104130.GK3193@twins.programming.kicks-ass.net>
 <20160516130519.GJ23146@dhcp22.suse.cz>
 <20160516132541.GP3193@twins.programming.kicks-ass.net>
 <20160516231056.GE18496@dastard>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20160516231056.GE18496@dastard>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Chinner <david@fromorbit.com>
Cc: Michal Hocko <mhocko@kernel.org>, "Darrick J. Wong" <darrick.wong@oracle.com>, Qu Wenruo <quwenruo@cn.fujitsu.com>, xfs@oss.sgi.com, linux-mm@kvack.org, Ingo Molnar <mingo@kernel.org>


Thanks for writing all that down Dave!

On Tue, May 17, 2016 at 09:10:56AM +1000, Dave Chinner wrote:

> The reason we don't have lock clases for the ilock is that we aren't
> supposed to call memory reclaim with that lock held in exclusive
> mode. This is because reclaim can run transactions, and that may
> need to flush dirty inodes to make progress. Flushing dirty inode
> requires taking the ilock in shared mode.
> 
> In the code path that was reported, we hold the ilock in /shared/
> mode with no transaction context (we are doing a read-only
> operation). This means we can run transactions in memory reclaim
> because a) we can't deadlock on the inode we hold locks on, and b)
> transaction reservations will be able to make progress as we don't
> hold any locks it can block on.

Just to clarify; I read the above as that we cannot block on recursive
shared locks, is this correct?

Because we can in fact block on down_read()+down_read() just fine, so if
you're assuming that, then something's busted.

Otherwise, I'm not quite reading it right, which is, given the
complexity of that stuff, entirely possible.

The other possible reading is that we cannot deadlock on the inode we
hold locks on because we hold a reference on it; and the reference
avoids the inode from being reclaimed. But then the whole
shared/exclusive thing doesn't seem to make sense.

> For the ilock, the number of places where the ilock is held over
> GFP_KERNEL allocations is pretty small. Hence we've simply added
> GFP_NOFS to those allocations to - effectively - annotate those
> allocations as "lockdep causes problems here". There are probably
> 30-35 allocations in XFS that explicitly use KM_NOFS - some of these
> are masking lockdep false positive reports.


> In the end, like pretty much all the complex lockdep false positives
> we've had to deal in XFS, we've ended up changing the locking or
> allocation contexts because that's been far easier than trying to
> make annotations cover everything or convince other people that
> lockdep annotations are insufficient.

Well, I don't mind creating lockdep annotations; but explanations of the
exact details always go a long way towards helping me come up with
something.

While going over the code; I see there's complaining about
MAX_SUBCLASSES being too small. Would it help if we doubled it? We
cannot grow the thing without limits, but doubling it should be possible
I think.


In any case; would something like this work for you? Its entirely
untested, but the idea is to mark an entire class to skip reclaim
validation, instead of marking individual sites.

We have to do the subclass loop because; as per the comment with
XFS_ILOCK_* we use all 8 subclasses.

---
 fs/xfs/xfs_super.c       | 13 +++++++++++++
 include/linux/lockdep.h  |  8 +++++++-
 kernel/locking/lockdep.c | 47 +++++++++++++++++++++++++++++++++++++++++++----
 3 files changed, 63 insertions(+), 5 deletions(-)

diff --git a/fs/xfs/xfs_super.c b/fs/xfs/xfs_super.c
index 187e14b696c2..ea55f87edad8 100644
--- a/fs/xfs/xfs_super.c
+++ b/fs/xfs/xfs_super.c
@@ -985,6 +985,19 @@ xfs_fs_inode_init_once(
 		     "xfsino", ip->i_ino);
 	mrlock_init(&ip->i_lock, MRLOCK_ALLOW_EQUAL_PRI|MRLOCK_BARRIER,
 		     "xfsino", ip->i_ino);
+
+#ifdef CONFIG_LOCKDEP
+	/*
+	 * Disable reclaim tests for the i_lock; reclaim is guarded
+	 * by a reference count... XXX write coherent comment.
+	 */
+	do {
+		int i;
+
+		for (i = 0; i < MAX_LOCKDEP_SUBCLASSES; i++)
+			lockdep_skip_reclaim(&ip->i_lock.mr_lock, i);
+	} while (0);
+#endif
 }
 
 STATIC void
diff --git a/include/linux/lockdep.h b/include/linux/lockdep.h
index eabe0138eb06..fbaa6c8bcff6 100644
--- a/include/linux/lockdep.h
+++ b/include/linux/lockdep.h
@@ -80,7 +80,8 @@ struct lock_class {
 	/*
 	 * IRQ/softirq usage tracking bits:
 	 */
-	unsigned long			usage_mask;
+	unsigned int			usage_mask;
+	unsigned int			skip_mask;
 	struct stack_trace		usage_traces[XXX_LOCK_USAGE_STATES];
 
 	/*
@@ -281,6 +282,8 @@ extern void lockdep_on(void);
 extern void lockdep_init_map(struct lockdep_map *lock, const char *name,
 			     struct lock_class_key *key, int subclass);
 
+extern void lock_skip_reclaim(struct lockdep_map *lock, int subclass);
+
 /*
  * To initialize a lockdep_map statically use this macro.
  * Note that _name must not be NULL.
@@ -304,6 +307,9 @@ extern void lockdep_init_map(struct lockdep_map *lock, const char *name,
 		lockdep_init_map(&(lock)->dep_map, #lock, \
 				 (lock)->dep_map.key, sub)
 
+#define lockdep_skip_reclaim(lock, sub) \
+		lock_skip_reclaim(&(lock)->dep_map, sub)
+
 #define lockdep_set_novalidate_class(lock) \
 	lockdep_set_class_and_name(lock, &__lockdep_no_validate__, #lock)
 /*
diff --git a/kernel/locking/lockdep.c b/kernel/locking/lockdep.c
index 81f1a7107c0e..f3b3b3e7938a 100644
--- a/kernel/locking/lockdep.c
+++ b/kernel/locking/lockdep.c
@@ -3022,13 +3022,17 @@ void lockdep_trace_alloc(gfp_t gfp_mask)
 static int mark_lock(struct task_struct *curr, struct held_lock *this,
 			     enum lock_usage_bit new_bit)
 {
+	struct lock_class *class = hlock_class(this);
 	unsigned int new_mask = 1 << new_bit, ret = 1;
 
 	/*
 	 * If already set then do not dirty the cacheline,
 	 * nor do any checks:
 	 */
-	if (likely(hlock_class(this)->usage_mask & new_mask))
+	if (likely(class->usage_mask & new_mask))
+		return 1;
+
+	if (class->skip_mask & (new_mask >> 2))
 		return 1;
 
 	if (!graph_lock())
@@ -3036,14 +3040,14 @@ static int mark_lock(struct task_struct *curr, struct held_lock *this,
 	/*
 	 * Make sure we didn't race:
 	 */
-	if (unlikely(hlock_class(this)->usage_mask & new_mask)) {
+	if (unlikely(class->usage_mask & new_mask)) {
 		graph_unlock();
 		return 1;
 	}
 
-	hlock_class(this)->usage_mask |= new_mask;
+	class->usage_mask |= new_mask;
 
-	if (!save_trace(hlock_class(this)->usage_traces + new_bit))
+	if (!save_trace(class->usage_traces + new_bit))
 		return 0;
 
 	switch (new_bit) {
@@ -3586,6 +3590,24 @@ static int __lock_is_held(struct lockdep_map *lock)
 	return 0;
 }
 
+static void __lock_skip_reclaim(struct lockdep_map *lock, int subclass)
+{
+	struct lock_class *class = register_lock_class(lock, subclass, 0);
+
+	if (!class)
+		return;
+
+	if (class->skip_mask & (1 << RECLAIM_FS))
+		return;
+
+	if (!graph_lock())
+		return;
+
+	class->skip_mask |= 1 << RECLAIM_FS;
+
+	graph_unlock();
+}
+
 static struct pin_cookie __lock_pin_lock(struct lockdep_map *lock)
 {
 	struct pin_cookie cookie = NIL_COOKIE;
@@ -3784,6 +3806,23 @@ int lock_is_held(struct lockdep_map *lock)
 }
 EXPORT_SYMBOL_GPL(lock_is_held);
 
+void lock_skip_reclaim(struct lockdep_map *lock, int subclass)
+{
+	unsigned long flags;
+
+	if (unlikely(current->lockdep_recursion))
+		return;
+
+	raw_local_irq_save(flags);
+	check_flags(flags);
+
+	current->lockdep_recursion = 1;
+	__lock_skip_reclaim(lock, subclass);
+	current->lockdep_recursion = 0;
+	raw_local_irq_restore(flags);
+}
+EXPORT_SYMBOL_GPL(lock_skip_reclaim);
+
 struct pin_cookie lock_pin_lock(struct lockdep_map *lock)
 {
 	struct pin_cookie cookie = NIL_COOKIE;

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
