Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ee0-f52.google.com (mail-ee0-f52.google.com [74.125.83.52])
	by kanga.kvack.org (Postfix) with ESMTP id E49D86B0035
	for <linux-mm@kvack.org>; Wed, 16 Apr 2014 00:17:55 -0400 (EDT)
Received: by mail-ee0-f52.google.com with SMTP id e49so8330229eek.11
        for <linux-mm@kvack.org>; Tue, 15 Apr 2014 21:17:55 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id q2si28154665eep.102.2014.04.15.21.17.54
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Tue, 15 Apr 2014 21:17:54 -0700 (PDT)
From: NeilBrown <neilb@suse.de>
Date: Wed, 16 Apr 2014 14:03:36 +1000
Subject: [PATCH 01/19] Promote current_{set,
 restore}_flags_nested from xfs to global.
Message-ID: <20140416040335.10604.80681.stgit@notabene.brown>
In-Reply-To: <20140416033623.10604.69237.stgit@notabene.brown>
References: <20140416033623.10604.69237.stgit@notabene.brown>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org
Cc: xfs@oss.sgi.com, Ming Lei <ming.lei@canonical.com>

These are useful macros from xfs for modifying current->flags.
Other places in the kernel perform the same task in various different
ways.
This patch moves the macros from xfs to include/linux/sched.h and
changes all code which temporarily sets a current->flags flag to
use these macros.

This does not change functionality in any important, but does fix a
few sites which assume that PF_FSTRANS is not already set and so
arbitrarily set and then clear it.  The new code is more careful and
will only clear it if it was previously clear.

Signed-off-by: NeilBrown <neilb@suse.de>
---
 drivers/base/power/runtime.c    |    6 +++---
 drivers/block/nbd.c             |    6 +++---
 drivers/md/dm-bufio.c           |    6 +++---
 drivers/md/dm-ioctl.c           |    6 +++---
 drivers/mtd/nand/nandsim.c      |   28 ++++++++--------------------
 drivers/scsi/iscsi_tcp.c        |    6 +++---
 drivers/usb/core/hub.c          |    6 +++---
 fs/fs-writeback.c               |    5 +++--
 fs/xfs/xfs_linux.h              |    7 -------
 include/linux/sched.h           |   27 ++++++++-------------------
 kernel/softirq.c                |    6 +++---
 mm/migrate.c                    |    9 ++++-----
 mm/page_alloc.c                 |   10 ++++++----
 mm/vmscan.c                     |   10 ++++++----
 net/core/dev.c                  |    6 +++---
 net/core/sock.c                 |    6 +++---
 net/sunrpc/sched.c              |    5 +++--
 net/sunrpc/xprtrdma/transport.c |    5 +++--
 net/sunrpc/xprtsock.c           |   17 ++++++++++-------
 19 files changed, 78 insertions(+), 99 deletions(-)

diff --git a/drivers/base/power/runtime.c b/drivers/base/power/runtime.c
index 72e00e66ecc5..02448f11c879 100644
--- a/drivers/base/power/runtime.c
+++ b/drivers/base/power/runtime.c
@@ -348,7 +348,7 @@ static int rpm_callback(int (*cb)(struct device *), struct device *dev)
 		return -ENOSYS;
 
 	if (dev->power.memalloc_noio) {
-		unsigned int noio_flag;
+		unsigned int pflags;
 
 		/*
 		 * Deadlock might be caused if memory allocation with
@@ -359,9 +359,9 @@ static int rpm_callback(int (*cb)(struct device *), struct device *dev)
 		 * device, so network device and its ancestor should
 		 * be marked as memalloc_noio too.
 		 */
-		noio_flag = memalloc_noio_save();
+		current_set_flags_nested(&pflags, PF_MEMALLOC_NOIO);
 		retval = __rpm_callback(cb, dev);
-		memalloc_noio_restore(noio_flag);
+		current_restore_flags_nested(&pflags, PF_MEMALLOC_NOIO);
 	} else {
 		retval = __rpm_callback(cb, dev);
 	}
diff --git a/drivers/block/nbd.c b/drivers/block/nbd.c
index 55298db36b2d..d3ddfa8a4da4 100644
--- a/drivers/block/nbd.c
+++ b/drivers/block/nbd.c
@@ -158,7 +158,7 @@ static int sock_xmit(struct nbd_device *nbd, int send, void *buf, int size,
 	struct msghdr msg;
 	struct kvec iov;
 	sigset_t blocked, oldset;
-	unsigned long pflags = current->flags;
+	unsigned int pflags;
 
 	if (unlikely(!sock)) {
 		dev_err(disk_to_dev(nbd->disk),
@@ -172,7 +172,7 @@ static int sock_xmit(struct nbd_device *nbd, int send, void *buf, int size,
 	siginitsetinv(&blocked, sigmask(SIGKILL));
 	sigprocmask(SIG_SETMASK, &blocked, &oldset);
 
-	current->flags |= PF_MEMALLOC;
+	current_set_flags_nested(&pflags, PF_MEMALLOC);
 	do {
 		sock->sk->sk_allocation = GFP_NOIO | __GFP_MEMALLOC;
 		iov.iov_base = buf;
@@ -220,7 +220,7 @@ static int sock_xmit(struct nbd_device *nbd, int send, void *buf, int size,
 	} while (size > 0);
 
 	sigprocmask(SIG_SETMASK, &oldset, NULL);
-	tsk_restore_flags(current, pflags, PF_MEMALLOC);
+	current_restore_flags_nested(&pflags, PF_MEMALLOC);
 
 	return result;
 }
diff --git a/drivers/md/dm-bufio.c b/drivers/md/dm-bufio.c
index 66c5d130c8c2..f5fa93ea3a59 100644
--- a/drivers/md/dm-bufio.c
+++ b/drivers/md/dm-bufio.c
@@ -322,7 +322,7 @@ static void __cache_size_refresh(void)
 static void *alloc_buffer_data(struct dm_bufio_client *c, gfp_t gfp_mask,
 			       enum data_mode *data_mode)
 {
-	unsigned noio_flag;
+	unsigned int pflags;
 	void *ptr;
 
 	if (c->block_size <= DM_BUFIO_BLOCK_SIZE_SLAB_LIMIT) {
@@ -350,12 +350,12 @@ static void *alloc_buffer_data(struct dm_bufio_client *c, gfp_t gfp_mask,
 	 */
 
 	if (gfp_mask & __GFP_NORETRY)
-		noio_flag = memalloc_noio_save();
+		current_set_flags_nested(&pflags, PF_MEMALLOC_NOIO);
 
 	ptr = __vmalloc(c->block_size, gfp_mask | __GFP_HIGHMEM, PAGE_KERNEL);
 
 	if (gfp_mask & __GFP_NORETRY)
-		memalloc_noio_restore(noio_flag);
+		current_restore_flags_nested(&pflags, PF_MEMALLOC_NOIO);
 
 	return ptr;
 }
diff --git a/drivers/md/dm-ioctl.c b/drivers/md/dm-ioctl.c
index 51521429fb59..5409533f22b5 100644
--- a/drivers/md/dm-ioctl.c
+++ b/drivers/md/dm-ioctl.c
@@ -1716,10 +1716,10 @@ static int copy_params(struct dm_ioctl __user *user, struct dm_ioctl *param_kern
 	}
 
 	if (!dmi) {
-		unsigned noio_flag;
-		noio_flag = memalloc_noio_save();
+		unsigned int pflags;
+		current_set_flags_nested(&pflags, PF_MEMALLOC_NOIO);
 		dmi = __vmalloc(param_kernel->data_size, GFP_NOIO | __GFP_REPEAT | __GFP_HIGH | __GFP_HIGHMEM, PAGE_KERNEL);
-		memalloc_noio_restore(noio_flag);
+		current_restore_flags_nested(&pflags, PF_MEMALLOC_NOIO);
 		if (dmi)
 			*param_flags |= DM_PARAMS_VMALLOC;
 	}
diff --git a/drivers/mtd/nand/nandsim.c b/drivers/mtd/nand/nandsim.c
index 42e8a770e631..8c995f9bb020 100644
--- a/drivers/mtd/nand/nandsim.c
+++ b/drivers/mtd/nand/nandsim.c
@@ -1373,31 +1373,18 @@ static int get_pages(struct nandsim *ns, struct file *file, size_t count, loff_t
 	return 0;
 }
 
-static int set_memalloc(void)
-{
-	if (current->flags & PF_MEMALLOC)
-		return 0;
-	current->flags |= PF_MEMALLOC;
-	return 1;
-}
-
-static void clear_memalloc(int memalloc)
-{
-	if (memalloc)
-		current->flags &= ~PF_MEMALLOC;
-}
-
 static ssize_t read_file(struct nandsim *ns, struct file *file, void *buf, size_t count, loff_t pos)
 {
 	ssize_t tx;
-	int err, memalloc;
+	int err;
+	unsigned int pflags;
 
 	err = get_pages(ns, file, count, pos);
 	if (err)
 		return err;
-	memalloc = set_memalloc();
+	current_set_flags_nested(&pflags, PF_MEMALLOC);
 	tx = kernel_read(file, pos, buf, count);
-	clear_memalloc(memalloc);
+	current_restore_flags_nested(&pflags, PF_MEMALLOC);
 	put_pages(ns);
 	return tx;
 }
@@ -1405,14 +1392,15 @@ static ssize_t read_file(struct nandsim *ns, struct file *file, void *buf, size_
 static ssize_t write_file(struct nandsim *ns, struct file *file, void *buf, size_t count, loff_t pos)
 {
 	ssize_t tx;
-	int err, memalloc;
+	int err;
+	unsigned int pflags;
 
 	err = get_pages(ns, file, count, pos);
 	if (err)
 		return err;
-	memalloc = set_memalloc();
+	current_set_flags_nested(&pflags, PF_MEMALLOC);
 	tx = kernel_write(file, buf, count, pos);
-	clear_memalloc(memalloc);
+	current_restore_flags_nested(&pflags, PF_MEMALLOC);
 	put_pages(ns);
 	return tx;
 }
diff --git a/drivers/scsi/iscsi_tcp.c b/drivers/scsi/iscsi_tcp.c
index add6d1566ec8..834cc3afaadf 100644
--- a/drivers/scsi/iscsi_tcp.c
+++ b/drivers/scsi/iscsi_tcp.c
@@ -371,10 +371,10 @@ static inline int iscsi_sw_tcp_xmit_qlen(struct iscsi_conn *conn)
 static int iscsi_sw_tcp_pdu_xmit(struct iscsi_task *task)
 {
 	struct iscsi_conn *conn = task->conn;
-	unsigned long pflags = current->flags;
+	unsigned int pflags;
 	int rc = 0;
 
-	current->flags |= PF_MEMALLOC;
+	current_set_flags_nested(&pflags, PF_MEMALLOC);
 
 	while (iscsi_sw_tcp_xmit_qlen(conn)) {
 		rc = iscsi_sw_tcp_xmit(conn);
@@ -387,7 +387,7 @@ static int iscsi_sw_tcp_pdu_xmit(struct iscsi_task *task)
 		rc = 0;
 	}
 
-	tsk_restore_flags(current, pflags, PF_MEMALLOC);
+	current_restore_flags_nested(&pflags, PF_MEMALLOC);
 	return rc;
 }
 
diff --git a/drivers/usb/core/hub.c b/drivers/usb/core/hub.c
index 64ea21971be2..7622b8b09163 100644
--- a/drivers/usb/core/hub.c
+++ b/drivers/usb/core/hub.c
@@ -5282,7 +5282,7 @@ int usb_reset_device(struct usb_device *udev)
 {
 	int ret;
 	int i;
-	unsigned int noio_flag;
+	unsigned int pflags;
 	struct usb_host_config *config = udev->actconfig;
 
 	if (udev->state == USB_STATE_NOTATTACHED ||
@@ -5301,7 +5301,7 @@ int usb_reset_device(struct usb_device *udev)
 	 * because the device 'memalloc_noio' flag may have
 	 * not been set before reseting the usb device.
 	 */
-	noio_flag = memalloc_noio_save();
+	current_set_flags_nested(&pflags, PF_MEMALLOC_NOIO);
 
 	/* Prevent autosuspend during the reset */
 	usb_autoresume_device(udev);
@@ -5347,7 +5347,7 @@ int usb_reset_device(struct usb_device *udev)
 	}
 
 	usb_autosuspend_device(udev);
-	memalloc_noio_restore(noio_flag);
+	current_restore_flags_nested(&pflags, PF_MEMALLOC_NOIO);
 	return ret;
 }
 EXPORT_SYMBOL_GPL(usb_reset_device);
diff --git a/fs/fs-writeback.c b/fs/fs-writeback.c
index d754e3cf99a8..73beb4d86ab1 100644
--- a/fs/fs-writeback.c
+++ b/fs/fs-writeback.c
@@ -1012,9 +1012,10 @@ void bdi_writeback_workfn(struct work_struct *work)
 						struct bdi_writeback, dwork);
 	struct backing_dev_info *bdi = wb->bdi;
 	long pages_written;
+	unsigned int pflags;
 
 	set_worker_desc("flush-%s", dev_name(bdi->dev));
-	current->flags |= PF_SWAPWRITE;
+	current_set_flags_nested(&pflags, PF_SWAPWRITE);
 
 	if (likely(!current_is_workqueue_rescuer() ||
 		   list_empty(&bdi->bdi_list))) {
@@ -1044,7 +1045,7 @@ void bdi_writeback_workfn(struct work_struct *work)
 		queue_delayed_work(bdi_wq, &wb->dwork,
 			msecs_to_jiffies(dirty_writeback_interval * 10));
 
-	current->flags &= ~PF_SWAPWRITE;
+	current_restore_flags_nested(&pflags, PF_SWAPWRITE);
 }
 
 /*
diff --git a/fs/xfs/xfs_linux.h b/fs/xfs/xfs_linux.h
index f9bb590acc0e..7c5b9eaebd0d 100644
--- a/fs/xfs/xfs_linux.h
+++ b/fs/xfs/xfs_linux.h
@@ -154,13 +154,6 @@ typedef __uint64_t __psunsigned_t;
 
 #define current_cpu()		(raw_smp_processor_id())
 #define current_pid()		(current->pid)
-#define current_test_flags(f)	(current->flags & (f))
-#define current_set_flags_nested(sp, f)		\
-		(*(sp) = current->flags, current->flags |= (f))
-#define current_clear_flags_nested(sp, f)	\
-		(*(sp) = current->flags, current->flags &= ~(f))
-#define current_restore_flags_nested(sp, f)	\
-		(current->flags = ((current->flags & ~(f)) | (*(sp) & (f))))
 
 #define spinlock_destroy(lock)
 
diff --git a/include/linux/sched.h b/include/linux/sched.h
index a781dec1cd0b..56fa52a0654c 100644
--- a/include/linux/sched.h
+++ b/include/linux/sched.h
@@ -1826,6 +1826,14 @@ extern void thread_group_cputime_adjusted(struct task_struct *p, cputime_t *ut,
 #define PF_FREEZER_SKIP	0x40000000	/* Freezer should not count it as freezable */
 #define PF_SUSPEND_TASK 0x80000000      /* this thread called freeze_processes and should not be frozen */
 
+#define current_test_flags(f)	(current->flags & (f))
+#define current_set_flags_nested(sp, f)		\
+		(*(sp) = current->flags, current->flags |= (f))
+#define current_clear_flags_nested(sp, f)	\
+		(*(sp) = current->flags, current->flags &= ~(f))
+#define current_restore_flags_nested(sp, f)	\
+		(current->flags = ((current->flags & ~(f)) | (*(sp) & (f))))
+
 /*
  * Only the _current_ task can read/write to tsk->flags, but other
  * tasks can access tsk->flags in readonly mode for example
@@ -1859,18 +1867,6 @@ static inline gfp_t memalloc_noio_flags(gfp_t flags)
 	return flags;
 }
 
-static inline unsigned int memalloc_noio_save(void)
-{
-	unsigned int flags = current->flags & PF_MEMALLOC_NOIO;
-	current->flags |= PF_MEMALLOC_NOIO;
-	return flags;
-}
-
-static inline void memalloc_noio_restore(unsigned int flags)
-{
-	current->flags = (current->flags & ~PF_MEMALLOC_NOIO) | flags;
-}
-
 /*
  * task->jobctl flags
  */
@@ -1927,13 +1923,6 @@ static inline void rcu_copy_process(struct task_struct *p)
 
 #endif
 
-static inline void tsk_restore_flags(struct task_struct *task,
-				unsigned long orig_flags, unsigned long flags)
-{
-	task->flags &= ~flags;
-	task->flags |= orig_flags & flags;
-}
-
 #ifdef CONFIG_SMP
 extern void do_set_cpus_allowed(struct task_struct *p,
 			       const struct cpumask *new_mask);
diff --git a/kernel/softirq.c b/kernel/softirq.c
index 490fcbb1dc5b..dff051dae277 100644
--- a/kernel/softirq.c
+++ b/kernel/softirq.c
@@ -225,7 +225,7 @@ static inline void lockdep_softirq_end(bool in_hardirq) { }
 asmlinkage void __do_softirq(void)
 {
 	unsigned long end = jiffies + MAX_SOFTIRQ_TIME;
-	unsigned long old_flags = current->flags;
+	unsigned int pflags;
 	int max_restart = MAX_SOFTIRQ_RESTART;
 	struct softirq_action *h;
 	bool in_hardirq;
@@ -238,7 +238,7 @@ asmlinkage void __do_softirq(void)
 	 * softirq. A softirq handled such as network RX might set PF_MEMALLOC
 	 * again if the socket is related to swap
 	 */
-	current->flags &= ~PF_MEMALLOC;
+	current_set_flags_nested(&pflags, PF_MEMALLOC);
 
 	pending = local_softirq_pending();
 	account_irq_enter_time(current);
@@ -295,7 +295,7 @@ restart:
 	account_irq_exit_time(current);
 	__local_bh_enable(SOFTIRQ_OFFSET);
 	WARN_ON_ONCE(in_interrupt());
-	tsk_restore_flags(current, old_flags, PF_MEMALLOC);
+	current_restore_flags_nested(&pflags, PF_MEMALLOC);
 }
 
 asmlinkage void do_softirq(void)
diff --git a/mm/migrate.c b/mm/migrate.c
index bed48809e5d0..2b7574860b2b 100644
--- a/mm/migrate.c
+++ b/mm/migrate.c
@@ -1107,11 +1107,11 @@ int migrate_pages(struct list_head *from, new_page_t get_new_page,
 	int pass = 0;
 	struct page *page;
 	struct page *page2;
-	int swapwrite = current->flags & PF_SWAPWRITE;
+	unsigned int pflags;
 	int rc;
 
-	if (!swapwrite)
-		current->flags |= PF_SWAPWRITE;
+
+	current_set_flags_nested(&pflags, PF_SWAPWRITE);
 
 	for(pass = 0; pass < 10 && retry; pass++) {
 		retry = 0;
@@ -1155,8 +1155,7 @@ out:
 		count_vm_events(PGMIGRATE_FAIL, nr_failed);
 	trace_mm_migrate_pages(nr_succeeded, nr_failed, mode, reason);
 
-	if (!swapwrite)
-		current->flags &= ~PF_SWAPWRITE;
+	current_restore_flags_nested(&pflags, PF_SWAPWRITE);
 
 	return rc;
 }
diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 3bac76ae4b30..a3d1f5da2f21 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -2254,6 +2254,7 @@ __alloc_pages_direct_compact(gfp_t gfp_mask, unsigned int order,
 	bool *contended_compaction, bool *deferred_compaction,
 	unsigned long *did_some_progress)
 {
+	unsigned int pflags;
 	if (!order)
 		return NULL;
 
@@ -2262,11 +2263,11 @@ __alloc_pages_direct_compact(gfp_t gfp_mask, unsigned int order,
 		return NULL;
 	}
 
-	current->flags |= PF_MEMALLOC;
+	current_set_flags_nested(&pflags, PF_MEMALLOC);
 	*did_some_progress = try_to_compact_pages(zonelist, order, gfp_mask,
 						nodemask, sync_migration,
 						contended_compaction);
-	current->flags &= ~PF_MEMALLOC;
+	current_restore_flags_nested(&pflags, PF_MEMALLOC);
 
 	if (*did_some_progress != COMPACT_SKIPPED) {
 		struct page *page;
@@ -2325,12 +2326,13 @@ __perform_reclaim(gfp_t gfp_mask, unsigned int order, struct zonelist *zonelist,
 {
 	struct reclaim_state reclaim_state;
 	int progress;
+	unsigned int pflags;
 
 	cond_resched();
 
 	/* We now go into synchronous reclaim */
 	cpuset_memory_pressure_bump();
-	current->flags |= PF_MEMALLOC;
+	current_set_flags_nested(&pflags, PF_MEMALLOC);
 	lockdep_set_current_reclaim_state(gfp_mask);
 	reclaim_state.reclaimed_slab = 0;
 	current->reclaim_state = &reclaim_state;
@@ -2339,7 +2341,7 @@ __perform_reclaim(gfp_t gfp_mask, unsigned int order, struct zonelist *zonelist,
 
 	current->reclaim_state = NULL;
 	lockdep_clear_current_reclaim_state();
-	current->flags &= ~PF_MEMALLOC;
+	current_restore_flags_nested(&pflags, PF_MEMALLOC);
 
 	cond_resched();
 
diff --git a/mm/vmscan.c b/mm/vmscan.c
index a9c74b409681..94acf53d9abf 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -3343,8 +3343,9 @@ unsigned long shrink_all_memory(unsigned long nr_to_reclaim)
 	struct zonelist *zonelist = node_zonelist(numa_node_id(), sc.gfp_mask);
 	struct task_struct *p = current;
 	unsigned long nr_reclaimed;
+	unsigned int pflags;
 
-	p->flags |= PF_MEMALLOC;
+	current_set_flags_nested(&pflags, PF_MEMALLOC);
 	lockdep_set_current_reclaim_state(sc.gfp_mask);
 	reclaim_state.reclaimed_slab = 0;
 	p->reclaim_state = &reclaim_state;
@@ -3353,7 +3354,7 @@ unsigned long shrink_all_memory(unsigned long nr_to_reclaim)
 
 	p->reclaim_state = NULL;
 	lockdep_clear_current_reclaim_state();
-	p->flags &= ~PF_MEMALLOC;
+	current_restore_flags_nested(&pflags, PF_MEMALLOC);
 
 	return nr_reclaimed;
 }
@@ -3530,6 +3531,7 @@ static int __zone_reclaim(struct zone *zone, gfp_t gfp_mask, unsigned int order)
 		.gfp_mask = sc.gfp_mask,
 	};
 	unsigned long nr_slab_pages0, nr_slab_pages1;
+	unsigned int pflags;
 
 	cond_resched();
 	/*
@@ -3537,7 +3539,7 @@ static int __zone_reclaim(struct zone *zone, gfp_t gfp_mask, unsigned int order)
 	 * and we also need to be able to write out pages for RECLAIM_WRITE
 	 * and RECLAIM_SWAP.
 	 */
-	p->flags |= PF_MEMALLOC | PF_SWAPWRITE;
+	current_set_flags_nested(&pflags, PF_MEMALLOC | PF_SWAPWRITE);
 	lockdep_set_current_reclaim_state(gfp_mask);
 	reclaim_state.reclaimed_slab = 0;
 	p->reclaim_state = &reclaim_state;
@@ -3587,7 +3589,7 @@ static int __zone_reclaim(struct zone *zone, gfp_t gfp_mask, unsigned int order)
 	}
 
 	p->reclaim_state = NULL;
-	current->flags &= ~(PF_MEMALLOC | PF_SWAPWRITE);
+	current_restore_flags_nested(&pflags, PF_MEMALLOC | PF_SWAPWRITE);
 	lockdep_clear_current_reclaim_state();
 	return sc.nr_reclaimed >= nr_pages;
 }
diff --git a/net/core/dev.c b/net/core/dev.c
index 45fa2f11f84d..b4eaac7c0d63 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -3664,7 +3664,7 @@ static int __netif_receive_skb(struct sk_buff *skb)
 	int ret;
 
 	if (sk_memalloc_socks() && skb_pfmemalloc(skb)) {
-		unsigned long pflags = current->flags;
+		unsigned int pflags;
 
 		/*
 		 * PFMEMALLOC skbs are special, they should
@@ -3675,9 +3675,9 @@ static int __netif_receive_skb(struct sk_buff *skb)
 		 * Use PF_MEMALLOC as this saves us from propagating the allocation
 		 * context down to all allocation sites.
 		 */
-		current->flags |= PF_MEMALLOC;
+		current_set_flags_nested(&pflags, PF_MEMALLOC);
 		ret = __netif_receive_skb_core(skb, true);
-		tsk_restore_flags(current, pflags, PF_MEMALLOC);
+		current_restore_flags_nested(&pflags, PF_MEMALLOC);
 	} else
 		ret = __netif_receive_skb_core(skb, false);
 
diff --git a/net/core/sock.c b/net/core/sock.c
index c0fc6bdad1e3..cf9bd24e4099 100644
--- a/net/core/sock.c
+++ b/net/core/sock.c
@@ -318,14 +318,14 @@ EXPORT_SYMBOL_GPL(sk_clear_memalloc);
 int __sk_backlog_rcv(struct sock *sk, struct sk_buff *skb)
 {
 	int ret;
-	unsigned long pflags = current->flags;
+	unsigned int pflags;
 
 	/* these should have been dropped before queueing */
 	BUG_ON(!sock_flag(sk, SOCK_MEMALLOC));
 
-	current->flags |= PF_MEMALLOC;
+	current_set_flags_nested(&pflags, PF_MEMALLOC);
 	ret = sk->sk_backlog_rcv(sk, skb);
-	tsk_restore_flags(current, pflags, PF_MEMALLOC);
+	current_restore_flags_nested(&pflags, PF_MEMALLOC);
 
 	return ret;
 }
diff --git a/net/sunrpc/sched.c b/net/sunrpc/sched.c
index ff3cc4bf4b24..c110dec833cd 100644
--- a/net/sunrpc/sched.c
+++ b/net/sunrpc/sched.c
@@ -820,9 +820,10 @@ void rpc_execute(struct rpc_task *task)
 
 static void rpc_async_schedule(struct work_struct *work)
 {
-	current->flags |= PF_FSTRANS;
+	unsigned int pflags;
+	current_set_flags_nested(&pflags, PF_FSTRANS);
 	__rpc_execute(container_of(work, struct rpc_task, u.tk_work));
-	current->flags &= ~PF_FSTRANS;
+	current_restore_flags_nested(&pflags, PF_FSTRANS);
 }
 
 /**
diff --git a/net/sunrpc/xprtrdma/transport.c b/net/sunrpc/xprtrdma/transport.c
index 285dc0884115..ac339b5ccf22 100644
--- a/net/sunrpc/xprtrdma/transport.c
+++ b/net/sunrpc/xprtrdma/transport.c
@@ -199,8 +199,9 @@ xprt_rdma_connect_worker(struct work_struct *work)
 		container_of(work, struct rpcrdma_xprt, rdma_connect.work);
 	struct rpc_xprt *xprt = &r_xprt->xprt;
 	int rc = 0;
+	unsigned int pflags;
 
-	current->flags |= PF_FSTRANS;
+	current_set_flags_nested(&pflags, PF_FSTRANS);
 	xprt_clear_connected(xprt);
 
 	dprintk("RPC:       %s: %sconnect\n", __func__,
@@ -211,7 +212,7 @@ xprt_rdma_connect_worker(struct work_struct *work)
 
 	dprintk("RPC:       %s: exit\n", __func__);
 	xprt_clear_connecting(xprt);
-	current->flags &= ~PF_FSTRANS;
+	current_restore_flags_nested(&pflags, PF_FSTRANS);
 }
 
 /*
diff --git a/net/sunrpc/xprtsock.c b/net/sunrpc/xprtsock.c
index 0addefca8e77..8015e7b7d87c 100644
--- a/net/sunrpc/xprtsock.c
+++ b/net/sunrpc/xprtsock.c
@@ -1932,8 +1932,9 @@ static int xs_local_setup_socket(struct sock_xprt *transport)
 	struct rpc_xprt *xprt = &transport->xprt;
 	struct socket *sock;
 	int status = -EIO;
+	unsigned int pflags;
 
-	current->flags |= PF_FSTRANS;
+	current_set_flags_nested(&pflags, PF_FSTRANS);
 
 	clear_bit(XPRT_CONNECTION_ABORT, &xprt->state);
 	status = __sock_create(xprt->xprt_net, AF_LOCAL,
@@ -1973,7 +1974,7 @@ static int xs_local_setup_socket(struct sock_xprt *transport)
 out:
 	xprt_clear_connecting(xprt);
 	xprt_wake_pending_tasks(xprt, status);
-	current->flags &= ~PF_FSTRANS;
+	current_restore_flags_nested(&pflags, PF_FSTRANS);
 	return status;
 }
 
@@ -2076,8 +2077,9 @@ static void xs_udp_setup_socket(struct work_struct *work)
 	struct rpc_xprt *xprt = &transport->xprt;
 	struct socket *sock = transport->sock;
 	int status = -EIO;
+	unsigned int pflags;
 
-	current->flags |= PF_FSTRANS;
+	current_set_flags_nested(&pflags, PF_FSTRANS);
 
 	/* Start by resetting any existing state */
 	xs_reset_transport(transport);
@@ -2098,7 +2100,7 @@ static void xs_udp_setup_socket(struct work_struct *work)
 out:
 	xprt_clear_connecting(xprt);
 	xprt_wake_pending_tasks(xprt, status);
-	current->flags &= ~PF_FSTRANS;
+	current_restore_flags_nested(&pflags, PF_FSTRANS);
 }
 
 /*
@@ -2234,8 +2236,9 @@ static void xs_tcp_setup_socket(struct work_struct *work)
 	struct socket *sock = transport->sock;
 	struct rpc_xprt *xprt = &transport->xprt;
 	int status = -EIO;
+	unsigned int pflags;
 
-	current->flags |= PF_FSTRANS;
+	current_set_flags_nested(&pflags, PF_FSTRANS);
 
 	if (!sock) {
 		clear_bit(XPRT_CONNECTION_ABORT, &xprt->state);
@@ -2282,7 +2285,7 @@ static void xs_tcp_setup_socket(struct work_struct *work)
 	case -EINPROGRESS:
 	case -EALREADY:
 		xprt_clear_connecting(xprt);
-		current->flags &= ~PF_FSTRANS;
+		current_restore_flags_nested(&pflags, PF_FSTRANS);
 		return;
 	case -EINVAL:
 		/* Happens, for instance, if the user specified a link
@@ -2299,7 +2302,7 @@ out_eagain:
 out:
 	xprt_clear_connecting(xprt);
 	xprt_wake_pending_tasks(xprt, status);
-	current->flags &= ~PF_FSTRANS;
+	current_restore_flags_nested(&pflags, PF_FSTRANS);
 }
 
 /**


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
