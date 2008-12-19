Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id 617D36B0044
	for <linux-mm@kvack.org>; Fri, 19 Dec 2008 01:17:35 -0500 (EST)
Date: Fri, 19 Dec 2008 07:19:38 +0100
From: Nick Piggin <npiggin@suse.de>
Subject: [rfc][patch 1/2] mnt_want_write speedup 1
Message-ID: <20081219061937.GA16268@wotan.suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
To: Dave Hansen <haveblue@us.ibm.com>, Linux Memory Management List <linux-mm@kvack.org>, linux-fsdevel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

Hi. Fun, chasing down performance regressions.... I wonder what people think
about these patches? Is it OK to bloat struct vfsmount? Any races? This could
be made even faster if mnt_make_readonly could tolerate a really high latency
synchronize_rcu()... can it?)

--
This patch speeds up lmbench lat_mmap test by about 8%. lat_mmap is set up
basically to mmap a 64MB file on tmpfs, fault in its pages, then unmap it.
A microbenchmark yes, but it exercises some important paths in the mm.

Before:
 avg = 501.9
 std = 14.7773

After:
 avg = 462.286
 std = 5.46106

(50 runs of each, stddev gives a reasonable confidence, but there is quite
a bit of variation there still)

It does this by removing the complex per-cpu locking and counter-cache and
replaces it with a percpu counter in struct vfsmount. This makes the code
much simpler, and avoids spinlocks (although the msync is still pretty
costly, unfortunately). It results in about 900 bytes smaller code too. It
does increase the size of a vfsmount, however.

It should also give a speedup on large systems if CPUs are frequently operating
on different mounts (because the existing scheme has to operate on an atomic in
the struct vfsmount when switching between mounts). But I'm most interested in
the single threaded path performance for the moment.

---
 fs/namespace.c        |  251 +++++++++++++++-----------------------------------
 include/linux/mount.h |   21 +++-
 2 files changed, 94 insertions(+), 178 deletions(-)

Index: linux-2.6/fs/namespace.c
===================================================================
--- linux-2.6.orig/fs/namespace.c
+++ linux-2.6/fs/namespace.c
@@ -130,10 +130,20 @@ struct vfsmount *alloc_vfsmnt(const char
 		INIT_LIST_HEAD(&mnt->mnt_share);
 		INIT_LIST_HEAD(&mnt->mnt_slave_list);
 		INIT_LIST_HEAD(&mnt->mnt_slave);
-		atomic_set(&mnt->__mnt_writers, 0);
+#ifdef CONFIG_SMP
+		mnt->mnt_writers = alloc_percpu(int);
+		if (!mnt->mnt_writers)
+			goto out_free_devname;
+#else
+		mnt->mnt_writers = 0;
+#endif
 	}
 	return mnt;
 
+#ifdef CONFIG_SMP
+out_free_devname:
+	kfree(mnt->mnt_devname);
+#endif
 out_free_id:
 	mnt_free_id(mnt);
 out_free_cache:
@@ -170,65 +180,38 @@ int __mnt_is_readonly(struct vfsmount *m
 }
 EXPORT_SYMBOL_GPL(__mnt_is_readonly);
 
-struct mnt_writer {
-	/*
-	 * If holding multiple instances of this lock, they
-	 * must be ordered by cpu number.
-	 */
-	spinlock_t lock;
-	struct lock_class_key lock_class; /* compiles out with !lockdep */
-	unsigned long count;
-	struct vfsmount *mnt;
-} ____cacheline_aligned_in_smp;
-static DEFINE_PER_CPU(struct mnt_writer, mnt_writers);
+static inline void inc_mnt_writers(struct vfsmount *mnt)
+{
+#ifdef CONFIG_SMP
+	(*per_cpu_ptr(mnt->mnt_writers, smp_processor_id()))++;
+#else
+	mnt->mnt_writers++;
+#endif
+}
 
-static int __init init_mnt_writers(void)
+static inline void dec_mnt_writers(struct vfsmount *mnt)
 {
-	int cpu;
-	for_each_possible_cpu(cpu) {
-		struct mnt_writer *writer = &per_cpu(mnt_writers, cpu);
-		spin_lock_init(&writer->lock);
-		lockdep_set_class(&writer->lock, &writer->lock_class);
-		writer->count = 0;
-	}
-	return 0;
+#ifdef CONFIG_SMP
+	(*per_cpu_ptr(mnt->mnt_writers, smp_processor_id()))--;
+#else
+	mnt->mnt_writers--;
+#endif
 }
-fs_initcall(init_mnt_writers);
 
-static void unlock_mnt_writers(void)
+static unsigned int count_mnt_writers(struct vfsmount *mnt)
 {
+#ifdef CONFIG_SMP
+	unsigned int count = 0;
 	int cpu;
-	struct mnt_writer *cpu_writer;
 
 	for_each_possible_cpu(cpu) {
-		cpu_writer = &per_cpu(mnt_writers, cpu);
-		spin_unlock(&cpu_writer->lock);
+		count += *per_cpu_ptr(mnt->mnt_writers, cpu);
 	}
-}
 
-static inline void __clear_mnt_count(struct mnt_writer *cpu_writer)
-{
-	if (!cpu_writer->mnt)
-		return;
-	/*
-	 * This is in case anyone ever leaves an invalid,
-	 * old ->mnt and a count of 0.
-	 */
-	if (!cpu_writer->count)
-		return;
-	atomic_add(cpu_writer->count, &cpu_writer->mnt->__mnt_writers);
-	cpu_writer->count = 0;
-}
- /*
- * must hold cpu_writer->lock
- */
-static inline void use_cpu_writer_for_mount(struct mnt_writer *cpu_writer,
-					  struct vfsmount *mnt)
-{
-	if (cpu_writer->mnt == mnt)
-		return;
-	__clear_mnt_count(cpu_writer);
-	cpu_writer->mnt = mnt;
+	return count;
+#else
+	return mnt->mnt_writers;
+#endif
 }
 
 /*
@@ -252,75 +235,34 @@ static inline void use_cpu_writer_for_mo
 int mnt_want_write(struct vfsmount *mnt)
 {
 	int ret = 0;
-	struct mnt_writer *cpu_writer;
 
-	cpu_writer = &get_cpu_var(mnt_writers);
-	spin_lock(&cpu_writer->lock);
+	preempt_disable();
+	inc_mnt_writers(mnt);
+	/*
+	 * The store to inc_mnt_writers must be visible before we pass
+	 * MNT_WRITE_HOLD loop below, so that the slowpath can see our
+	 * incremented count after it has set MNT_WRITE_HOLD.
+	 */
+	smp_mb();
+	while (mnt->mnt_flags & MNT_WRITE_HOLD)
+		cpu_relax();
+	/*
+	 * After the slowpath clears MNT_WRITE_HOLD, mnt_is_readonly will
+	 * be set to match its requirements. So we must not load that until
+	 * MNT_WRITE_HOLD is cleared.
+	 */
+	smp_rmb();
 	if (__mnt_is_readonly(mnt)) {
+		dec_mnt_writers(mnt);
 		ret = -EROFS;
 		goto out;
 	}
-	use_cpu_writer_for_mount(cpu_writer, mnt);
-	cpu_writer->count++;
 out:
-	spin_unlock(&cpu_writer->lock);
-	put_cpu_var(mnt_writers);
+	preempt_enable();
 	return ret;
 }
 EXPORT_SYMBOL_GPL(mnt_want_write);
 
-static void lock_mnt_writers(void)
-{
-	int cpu;
-	struct mnt_writer *cpu_writer;
-
-	for_each_possible_cpu(cpu) {
-		cpu_writer = &per_cpu(mnt_writers, cpu);
-		spin_lock(&cpu_writer->lock);
-		__clear_mnt_count(cpu_writer);
-		cpu_writer->mnt = NULL;
-	}
-}
-
-/*
- * These per-cpu write counts are not guaranteed to have
- * matched increments and decrements on any given cpu.
- * A file open()ed for write on one cpu and close()d on
- * another cpu will imbalance this count.  Make sure it
- * does not get too far out of whack.
- */
-static void handle_write_count_underflow(struct vfsmount *mnt)
-{
-	if (atomic_read(&mnt->__mnt_writers) >=
-	    MNT_WRITER_UNDERFLOW_LIMIT)
-		return;
-	/*
-	 * It isn't necessary to hold all of the locks
-	 * at the same time, but doing it this way makes
-	 * us share a lot more code.
-	 */
-	lock_mnt_writers();
-	/*
-	 * vfsmount_lock is for mnt_flags.
-	 */
-	spin_lock(&vfsmount_lock);
-	/*
-	 * If coalescing the per-cpu writer counts did not
-	 * get us back to a positive writer count, we have
-	 * a bug.
-	 */
-	if ((atomic_read(&mnt->__mnt_writers) < 0) &&
-	    !(mnt->mnt_flags & MNT_IMBALANCED_WRITE_COUNT)) {
-		WARN(1, KERN_DEBUG "leak detected on mount(%p) writers "
-				"count: %d\n",
-			mnt, atomic_read(&mnt->__mnt_writers));
-		/* use the flag to keep the dmesg spam down */
-		mnt->mnt_flags |= MNT_IMBALANCED_WRITE_COUNT;
-	}
-	spin_unlock(&vfsmount_lock);
-	unlock_mnt_writers();
-}
-
 /**
  * mnt_drop_write - give up write access to a mount
  * @mnt: the mount on which to give up write access
@@ -331,37 +273,9 @@ static void handle_write_count_underflow
  */
 void mnt_drop_write(struct vfsmount *mnt)
 {
-	int must_check_underflow = 0;
-	struct mnt_writer *cpu_writer;
-
-	cpu_writer = &get_cpu_var(mnt_writers);
-	spin_lock(&cpu_writer->lock);
-
-	use_cpu_writer_for_mount(cpu_writer, mnt);
-	if (cpu_writer->count > 0) {
-		cpu_writer->count--;
-	} else {
-		must_check_underflow = 1;
-		atomic_dec(&mnt->__mnt_writers);
-	}
-
-	spin_unlock(&cpu_writer->lock);
-	/*
-	 * Logically, we could call this each time,
-	 * but the __mnt_writers cacheline tends to
-	 * be cold, and makes this expensive.
-	 */
-	if (must_check_underflow)
-		handle_write_count_underflow(mnt);
-	/*
-	 * This could be done right after the spinlock
-	 * is taken because the spinlock keeps us on
-	 * the cpu, and disables preemption.  However,
-	 * putting it here bounds the amount that
-	 * __mnt_writers can underflow.  Without it,
-	 * we could theoretically wrap __mnt_writers.
-	 */
-	put_cpu_var(mnt_writers);
+	preempt_disable();
+	dec_mnt_writers(mnt);
+	preempt_enable();
 }
 EXPORT_SYMBOL_GPL(mnt_drop_write);
 
@@ -369,24 +283,34 @@ static int mnt_make_readonly(struct vfsm
 {
 	int ret = 0;
 
-	lock_mnt_writers();
+	spin_lock(&vfsmount_lock);
+	mnt->mnt_flags |= MNT_WRITE_HOLD;
 	/*
-	 * With all the locks held, this value is stable
+	 * After storing MNT_WRITE_HOLD, we'll read the counters. This store
+	 * should be visible before we do.
 	 */
-	if (atomic_read(&mnt->__mnt_writers) > 0) {
+	smp_mb();
+
+	/*
+	 * With writers on hold, if this value is zero, then there are definitely
+	 * no active writers (although held writers may subsequently increment
+	 * the count, they'll have to wait, and decrement it after seeing
+	 * MNT_READONLY).
+	 */
+	if (count_mnt_writers(mnt) > 0) {
 		ret = -EBUSY;
 		goto out;
 	}
-	/*
-	 * nobody can do a successful mnt_want_write() with all
-	 * of the counts in MNT_DENIED_WRITE and the locks held.
-	 */
-	spin_lock(&vfsmount_lock);
 	if (!ret)
 		mnt->mnt_flags |= MNT_READONLY;
-	spin_unlock(&vfsmount_lock);
 out:
-	unlock_mnt_writers();
+	/*
+	 * MNT_READONLY must become visible before ~MNT_WRITE_HOLD, so writers
+	 * that become unheld will see MNT_READONLY.
+	 */
+	smp_wmb();
+	mnt->mnt_flags &= ~MNT_WRITE_HOLD;
+	spin_unlock(&vfsmount_lock);
 	return ret;
 }
 
@@ -410,6 +334,9 @@ void free_vfsmnt(struct vfsmount *mnt)
 {
 	kfree(mnt->mnt_devname);
 	mnt_free_id(mnt);
+#ifdef CONFIG_SMP
+	free_percpu(mnt->mnt_writers);
+#endif
 	kmem_cache_free(mnt_cache, mnt);
 }
 
@@ -604,36 +531,14 @@ static struct vfsmount *clone_mnt(struct
 
 static inline void __mntput(struct vfsmount *mnt)
 {
-	int cpu;
 	struct super_block *sb = mnt->mnt_sb;
 	/*
-	 * We don't have to hold all of the locks at the
-	 * same time here because we know that we're the
-	 * last reference to mnt and that no new writers
-	 * can come in.
-	 */
-	for_each_possible_cpu(cpu) {
-		struct mnt_writer *cpu_writer = &per_cpu(mnt_writers, cpu);
-		if (cpu_writer->mnt != mnt)
-			continue;
-		spin_lock(&cpu_writer->lock);
-		atomic_add(cpu_writer->count, &mnt->__mnt_writers);
-		cpu_writer->count = 0;
-		/*
-		 * Might as well do this so that no one
-		 * ever sees the pointer and expects
-		 * it to be valid.
-		 */
-		cpu_writer->mnt = NULL;
-		spin_unlock(&cpu_writer->lock);
-	}
-	/*
 	 * This probably indicates that somebody messed
 	 * up a mnt_want/drop_write() pair.  If this
 	 * happens, the filesystem was probably unable
 	 * to make r/w->r/o transitions.
 	 */
-	WARN_ON(atomic_read(&mnt->__mnt_writers));
+	WARN_ON(count_mnt_writers(mnt));
 	dput(mnt->mnt_root);
 	free_vfsmnt(mnt);
 	deactivate_super(sb);
Index: linux-2.6/include/linux/mount.h
===================================================================
--- linux-2.6.orig/include/linux/mount.h
+++ linux-2.6/include/linux/mount.h
@@ -30,6 +30,7 @@ struct mnt_namespace;
 
 #define MNT_SHRINKABLE	0x100
 #define MNT_IMBALANCED_WRITE_COUNT	0x200 /* just for debugging */
+#define MNT_WRITE_HOLD	0x400
 
 #define MNT_SHARED	0x1000	/* if the vfsmount is a shared mount */
 #define MNT_UNBINDABLE	0x2000	/* if the vfsmount is a unbindable mount */
@@ -64,13 +65,23 @@ struct vfsmount {
 	int mnt_expiry_mark;		/* true if marked for expiry */
 	int mnt_pinned;
 	int mnt_ghosts;
-	/*
-	 * This value is not stable unless all of the mnt_writers[] spinlocks
-	 * are held, and all mnt_writer[]s on this mount have 0 as their ->count
-	 */
-	atomic_t __mnt_writers;
+
+#ifdef CONFIG_SMP
+	int *mnt_writers;
+#else
+	int mnt_writers;
+#endif
 };
 
+static inline int *get_mnt_writers_ptr(struct vfsmount *mnt)
+{
+#ifdef CONFIG_SMP
+	return mnt->mnt_writers;
+#else
+	return &mnt->mnt_writers;
+#endif
+}
+
 static inline struct vfsmount *mntget(struct vfsmount *mnt)
 {
 	if (mnt)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
