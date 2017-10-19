Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id 853AA6B0261
	for <linux-mm@kvack.org>; Thu, 19 Oct 2017 03:03:32 -0400 (EDT)
Received: by mail-pf0-f197.google.com with SMTP id u27so5091406pfg.12
        for <linux-mm@kvack.org>; Thu, 19 Oct 2017 00:03:32 -0700 (PDT)
Received: from lgeamrelo12.lge.com (LGEAMRELO12.lge.com. [156.147.23.52])
        by mx.google.com with ESMTP id l7si3782883pgs.418.2017.10.19.00.03.30
        for <linux-mm@kvack.org>;
        Thu, 19 Oct 2017 00:03:31 -0700 (PDT)
From: Byungchul Park <byungchul.park@lge.com>
Subject: [PATCH v2 4/4] lockdep: Assign a lock_class per gendisk used for wait_for_completion()
Date: Thu, 19 Oct 2017 16:03:27 +0900
Message-Id: <1508396607-25362-5-git-send-email-byungchul.park@lge.com>
In-Reply-To: <1508396607-25362-1-git-send-email-byungchul.park@lge.com>
References: <1508392531-11284-1-git-send-email-byungchul.park@lge.com>
 <1508396607-25362-1-git-send-email-byungchul.park@lge.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: peterz@infradead.org, mingo@kernel.org
Cc: tglx@linutronix.de, linux-kernel@vger.kernel.org, linux-mm@kvack.org, tj@kernel.org, johannes.berg@intel.com, oleg@redhat.com, amir73il@gmail.com, david@fromorbit.com, darrick.wong@oracle.com, linux-xfs@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-block@vger.kernel.org, hch@infradead.org, idryomov@gmail.com, kernel-team@lge.com

Darrick and Dave Chinner posted the following warning:

> ======================================================
> WARNING: possible circular locking dependency detected
> 4.14.0-rc1-fixes #1 Tainted: G        W
> ------------------------------------------------------
> loop0/31693 is trying to acquire lock:
>  (&(&ip->i_mmaplock)->mr_lock){++++}, at: [<ffffffffa00f1b0c>] xfs_ilock+0x23c/0x330 [xfs]
>
> but now in release context of a crosslock acquired at the following:
>  ((complete)&ret.event){+.+.}, at: [<ffffffff81326c1f>] submit_bio_wait+0x7f/0xb0
>
> which lock already depends on the new lock.
>
> the existing dependency chain (in reverse order) is:
>
> -> #2 ((complete)&ret.event){+.+.}:
>        lock_acquire+0xab/0x200
>        wait_for_completion_io+0x4e/0x1a0
>        submit_bio_wait+0x7f/0xb0
>        blkdev_issue_zeroout+0x71/0xa0
>        xfs_bmapi_convert_unwritten+0x11f/0x1d0 [xfs]
>        xfs_bmapi_write+0x374/0x11f0 [xfs]
>        xfs_iomap_write_direct+0x2ac/0x430 [xfs]
>        xfs_file_iomap_begin+0x20d/0xd50 [xfs]
>        iomap_apply+0x43/0xe0
>        dax_iomap_rw+0x89/0xf0
>        xfs_file_dax_write+0xcc/0x220 [xfs]
>        xfs_file_write_iter+0xf0/0x130 [xfs]
>        __vfs_write+0xd9/0x150
>        vfs_write+0xc8/0x1c0
>        SyS_write+0x45/0xa0
>        entry_SYSCALL_64_fastpath+0x1f/0xbe
>
> -> #1 (&xfs_nondir_ilock_class){++++}:
>        lock_acquire+0xab/0x200
>        down_write_nested+0x4a/0xb0
>        xfs_ilock+0x263/0x330 [xfs]
>        xfs_setattr_size+0x152/0x370 [xfs]
>        xfs_vn_setattr+0x6b/0x90 [xfs]
>        notify_change+0x27d/0x3f0
>        do_truncate+0x5b/0x90
>        path_openat+0x237/0xa90
>        do_filp_open+0x8a/0xf0
>        do_sys_open+0x11c/0x1f0
>        entry_SYSCALL_64_fastpath+0x1f/0xbe
>
> -> #0 (&(&ip->i_mmaplock)->mr_lock){++++}:
>        up_write+0x1c/0x40
>        xfs_iunlock+0x1d0/0x310 [xfs]
>        xfs_file_fallocate+0x8a/0x310 [xfs]
>        loop_queue_work+0xb7/0x8d0
>        kthread_worker_fn+0xb9/0x1f0
>
> Chain exists of:
>   &(&ip->i_mmaplock)->mr_lock --> &xfs_nondir_ilock_class --> (complete)&ret.event
>
>  Possible unsafe locking scenario by crosslock:
>
>        CPU0                    CPU1
>        ----                    ----
>   lock(&xfs_nondir_ilock_class);
>   lock((complete)&ret.event);
>                                lock(&(&ip->i_mmaplock)->mr_lock);
>                                unlock((complete)&ret.event);
>
>                *** DEADLOCK ***

The warning is a false positive, caused by the fact that all
wait_for_completion()s in submit_bio_wait() are waiting with the same
lock class.

However, some bios have nothing to do with others, for example, the case
might happen while using loop devices, between bios of an upper device
and a lower device(=loop device).

The safest way to assign different lock classes to different devices is
to do it for each gendisk. In other words, this patch assigns a
lockdep_map per gendisk and uses it when initializing completion in
submit_bio_wait().

Of course, it might be too conservative. But, making it safest for now
and extended by block layer experts later is good, atm.

Signed-off-by: Byungchul Park <byungchul.park@lge.com>
---
 block/bio.c           |  2 +-
 block/genhd.c         | 13 +++++--------
 include/linux/genhd.h | 22 ++++++++++++++++++++--
 3 files changed, 26 insertions(+), 11 deletions(-)

diff --git a/block/bio.c b/block/bio.c
index 101c2a9..6dd640d 100644
--- a/block/bio.c
+++ b/block/bio.c
@@ -945,7 +945,7 @@ int submit_bio_wait(struct bio *bio)
 {
 	struct submit_bio_ret ret;
 
-	init_completion(&ret.event);
+	init_completion_with_map(&ret.event, &bio->bi_disk->lockdep_map);
 	bio->bi_private = &ret;
 	bio->bi_end_io = submit_bio_wait_endio;
 	bio->bi_opf |= REQ_SYNC;
diff --git a/block/genhd.c b/block/genhd.c
index dd305c6..f195d22 100644
--- a/block/genhd.c
+++ b/block/genhd.c
@@ -1354,13 +1354,7 @@ dev_t blk_lookup_devt(const char *name, int partno)
 }
 EXPORT_SYMBOL(blk_lookup_devt);
 
-struct gendisk *alloc_disk(int minors)
-{
-	return alloc_disk_node(minors, NUMA_NO_NODE);
-}
-EXPORT_SYMBOL(alloc_disk);
-
-struct gendisk *alloc_disk_node(int minors, int node_id)
+struct gendisk *__alloc_disk_node(int minors, int node_id, struct lock_class_key *key, const char *lock_name)
 {
 	struct gendisk *disk;
 	struct disk_part_tbl *ptbl;
@@ -1409,9 +1403,12 @@ struct gendisk *alloc_disk_node(int minors, int node_id)
 		disk_to_dev(disk)->type = &disk_type;
 		device_initialize(disk_to_dev(disk));
 	}
+
+	lockdep_init_map(&disk->lockdep_map, lock_name, key, 0);
+
 	return disk;
 }
-EXPORT_SYMBOL(alloc_disk_node);
+EXPORT_SYMBOL(__alloc_disk_node);
 
 struct kobject *get_disk(struct gendisk *disk)
 {
diff --git a/include/linux/genhd.h b/include/linux/genhd.h
index 6d85a75..9832e3c 100644
--- a/include/linux/genhd.h
+++ b/include/linux/genhd.h
@@ -206,6 +206,9 @@ struct gendisk {
 #endif	/* CONFIG_BLK_DEV_INTEGRITY */
 	int node_id;
 	struct badblocks *bb;
+#ifdef CONFIG_LOCKDEP_COMPLETIONS
+	struct lockdep_map lockdep_map;
+#endif
 };
 
 static inline struct gendisk *part_to_disk(struct hd_struct *part)
@@ -590,8 +593,7 @@ extern struct hd_struct * __must_check add_partition(struct gendisk *disk,
 extern void delete_partition(struct gendisk *, int);
 extern void printk_all_partitions(void);
 
-extern struct gendisk *alloc_disk_node(int minors, int node_id);
-extern struct gendisk *alloc_disk(int minors);
+extern struct gendisk *__alloc_disk_node(int minors, int node_id, struct lock_class_key *key, const char *lock_name);
 extern struct kobject *get_disk(struct gendisk *disk);
 extern void put_disk(struct gendisk *disk);
 extern void blk_register_region(dev_t devt, unsigned long range,
@@ -615,6 +617,22 @@ extern ssize_t part_fail_store(struct device *dev,
 			       const char *buf, size_t count);
 #endif /* CONFIG_FAIL_MAKE_REQUEST */
 
+#ifdef CONFIG_LOCKDEP_COMPLETIONS
+#define alloc_disk_node(m, id) \
+({									\
+	static struct lock_class_key __key;				\
+	const char *__lock_name;					\
+									\
+	__lock_name = "(complete)"#m"("#id")";				\
+									\
+	__alloc_disk_node(m, id, &__key, __lock_name);			\
+})
+#else
+#define alloc_disk_node(m, id)	__alloc_disk_node(m, id, NULL, NULL)
+#endif
+
+#define alloc_disk(m)		alloc_disk_node(m, NUMA_NO_NODE)
+
 static inline int hd_ref_init(struct hd_struct *part)
 {
 	if (percpu_ref_init(&part->ref, __delete_partition, 0,
-- 
1.9.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
