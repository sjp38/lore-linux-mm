Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id 2098A6B026E
	for <linux-mm@kvack.org>; Tue, 10 Oct 2017 10:56:10 -0400 (EDT)
Received: by mail-pf0-f197.google.com with SMTP id d28so20155711pfe.2
        for <linux-mm@kvack.org>; Tue, 10 Oct 2017 07:56:10 -0700 (PDT)
Received: from mga11.intel.com (mga11.intel.com. [192.55.52.93])
        by mx.google.com with ESMTPS id g8si8752404plt.739.2017.10.10.07.56.08
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 10 Oct 2017 07:56:08 -0700 (PDT)
Subject: [PATCH v8 08/14] fs, mapdirect: introduce ->lease_direct()
From: Dan Williams <dan.j.williams@intel.com>
Date: Tue, 10 Oct 2017 07:49:43 -0700
Message-ID: <150764698294.16882.9303626348507763643.stgit@dwillia2-desk3.amr.corp.intel.com>
In-Reply-To: <150764693502.16882.15848797003793552156.stgit@dwillia2-desk3.amr.corp.intel.com>
References: <150764693502.16882.15848797003793552156.stgit@dwillia2-desk3.amr.corp.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-nvdimm@lists.01.org
Cc: linux-xfs@vger.kernel.org, Jan Kara <jack@suse.cz>, "Darrick J. Wong" <darrick.wong@oracle.com>, linux-rdma@vger.kernel.org, linux-api@vger.kernel.org, Dave Chinner <david@fromorbit.com>, iommu@lists.linux-foundation.org, Christoph Hellwig <hch@lst.de>, "J. Bruce Fields" <bfields@fieldses.org>, linux-mm@kvack.org, Jeff Moyer <jmoyer@redhat.com>, linux-fsdevel@vger.kernel.org, Jeff Layton <jlayton@poochiereds.net>, Ross Zwisler <ross.zwisler@linux.intel.com>

Provide a vma operation that registers a lease that is broken by
break_layout(). This is motivated by a need to stop in-progress RDMA
when the block-map of a DAX-file changes. I.e. since DAX gives
direct-access to filesystem blocks we can not allow those blocks to move
or change state while they are under active RDMA. So, if the filesystem
determines it needs to move blocks it can revoke device access before
proceeding.

Cc: Jan Kara <jack@suse.cz>
Cc: Jeff Moyer <jmoyer@redhat.com>
Cc: Christoph Hellwig <hch@lst.de>
Cc: Dave Chinner <david@fromorbit.com>
Cc: "Darrick J. Wong" <darrick.wong@oracle.com>
Cc: Ross Zwisler <ross.zwisler@linux.intel.com>
Cc: Jeff Layton <jlayton@poochiereds.net>
Cc: "J. Bruce Fields" <bfields@fieldses.org>
Signed-off-by: Dan Williams <dan.j.williams@intel.com>
---
 fs/mapdirect.c            |  144 +++++++++++++++++++++++++++++++++++++++++++++
 include/linux/mapdirect.h |   14 ++++
 include/linux/mm.h        |    8 +++
 3 files changed, 166 insertions(+)

diff --git a/fs/mapdirect.c b/fs/mapdirect.c
index 9f4dd7395dcd..c6954033fc1a 100644
--- a/fs/mapdirect.c
+++ b/fs/mapdirect.c
@@ -16,6 +16,7 @@
 #include <linux/mutex.h>
 #include <linux/sched.h>
 #include <linux/slab.h>
+#include <linux/file.h>
 #include <linux/fs.h>
 #include <linux/mm.h>
 
@@ -32,12 +33,25 @@ struct map_direct_state {
 	struct vm_area_struct *mds_vma;
 };
 
+struct lease_direct_state {
+	void *lds_owner;
+	struct file *lds_file;
+	unsigned long lds_state;
+	void (*lds_break_fn)(void *lds_owner);
+	struct delayed_work lds_work;
+};
+
 bool test_map_direct_valid(struct map_direct_state *mds)
 {
 	return test_bit(MAPDIRECT_VALID, &mds->mds_state);
 }
 EXPORT_SYMBOL_GPL(test_map_direct_valid);
 
+static bool test_map_direct_broken(struct map_direct_state *mds)
+{
+	return test_bit(MAPDIRECT_BREAK, &mds->mds_state);
+}
+
 static void put_map_direct(struct map_direct_state *mds)
 {
 	if (!atomic_dec_and_test(&mds->mds_ref))
@@ -168,6 +182,136 @@ static const struct lock_manager_operations map_direct_lm_ops = {
 	.lm_setup = map_direct_lm_setup,
 };
 
+static void lease_direct_invalidate(struct work_struct *work)
+{
+	struct lease_direct_state *lds;
+	void *owner;
+
+	lds = container_of(work, typeof(*lds), lds_work.work);
+	owner = lds;
+	lds->lds_break_fn(lds->lds_owner);
+	vfs_setlease(lds->lds_file, F_UNLCK, NULL, &owner);
+}
+
+static bool lease_direct_lm_break(struct file_lock *fl)
+{
+	struct lease_direct_state *lds = fl->fl_owner;
+
+	if (!test_and_set_bit(MAPDIRECT_BREAK, &lds->lds_state))
+		schedule_delayed_work(&lds->lds_work, lease_break_time * HZ);
+
+	/* Tell the core lease code to wait for delayed work completion */
+	fl->fl_break_time = 0;
+
+	return false;
+}
+
+static int lease_direct_lm_change(struct file_lock *fl, int arg,
+		struct list_head *dispose)
+{
+	WARN_ON(!(arg & F_UNLCK));
+	return lease_modify(fl, arg, dispose);
+}
+
+static const struct lock_manager_operations lease_direct_lm_ops = {
+	.lm_break = lease_direct_lm_break,
+	.lm_change = lease_direct_lm_change,
+};
+
+static struct lease_direct *map_direct_lease(struct vm_area_struct *vma,
+		void (*lds_break_fn)(void *), void *lds_owner)
+{
+	struct file *file = vma->vm_file;
+	struct lease_direct_state *lds;
+	struct lease_direct *ld;
+	struct file_lock *fl;
+	int rc = -ENOMEM;
+	void *owner;
+
+	ld = kzalloc(sizeof(*ld) + sizeof(*lds), GFP_KERNEL);
+	if (!ld)
+		return ERR_PTR(-ENOMEM);
+	INIT_LIST_HEAD(&ld->list);
+	lds = (struct lease_direct_state *)(ld + 1);
+	owner = lds;
+	ld->lds = lds;
+	lds->lds_break_fn = lds_break_fn;
+	lds->lds_owner = lds_owner;
+	INIT_DELAYED_WORK(&lds->lds_work, lease_direct_invalidate);
+	lds->lds_file = get_file(file);
+
+	fl = locks_alloc_lock();
+	if (!fl)
+		goto err_lock_alloc;
+
+	locks_init_lock(fl);
+	fl->fl_lmops = &lease_direct_lm_ops;
+	fl->fl_flags = FL_LAYOUT;
+	fl->fl_type = F_RDLCK;
+	fl->fl_end = OFFSET_MAX;
+	fl->fl_owner = lds;
+	fl->fl_pid = current->tgid;
+	fl->fl_file = file;
+
+	rc = vfs_setlease(file, fl->fl_type, &fl, &owner);
+	if (rc)
+		goto err_setlease;
+	if (fl) {
+		WARN_ON(1);
+		owner = lds;
+		vfs_setlease(file, F_UNLCK, NULL, &owner);
+		owner = NULL;
+		rc = -ENXIO;
+		goto err_setlease;
+	}
+
+	return ld;
+err_setlease:
+	locks_free_lock(fl);
+err_lock_alloc:
+	kfree(lds);
+	return ERR_PTR(rc);
+}
+
+struct lease_direct *generic_map_direct_lease(struct vm_area_struct *vma,
+		void (*break_fn)(void *), void *owner)
+{
+	struct lease_direct *ld;
+
+	ld = map_direct_lease(vma, break_fn, owner);
+
+	if (IS_ERR(ld))
+		return ld;
+
+	/*
+	 * We now have an established lease while the base MAP_DIRECT
+	 * lease was not broken. So, we know that the "lease holder" will
+	 * receive a SIGIO notification when the lease is broken and
+	 * take any necessary cleanup actions.
+	 */
+	if (!test_map_direct_broken(vma->vm_private_data))
+		return ld;
+
+	map_direct_lease_destroy(ld);
+
+	return ERR_PTR(-ENXIO);
+}
+EXPORT_SYMBOL_GPL(generic_map_direct_lease);
+
+void map_direct_lease_destroy(struct lease_direct *ld)
+{
+	struct lease_direct_state *lds = ld->lds;
+	struct file *file = lds->lds_file;
+	void *owner = lds;
+
+	vfs_setlease(file, F_UNLCK, NULL, &owner);
+	flush_delayed_work(&lds->lds_work);
+	fput(file);
+	WARN_ON(!list_empty(&ld->list));
+	kfree(ld);
+}
+EXPORT_SYMBOL_GPL(map_direct_lease_destroy);
+
 struct map_direct_state *map_direct_register(int fd, struct vm_area_struct *vma)
 {
 	struct map_direct_state *mds = kzalloc(sizeof(*mds), GFP_KERNEL);
diff --git a/include/linux/mapdirect.h b/include/linux/mapdirect.h
index 5491aa550e55..e0df6ac5795a 100644
--- a/include/linux/mapdirect.h
+++ b/include/linux/mapdirect.h
@@ -13,17 +13,27 @@
 #ifndef __MAPDIRECT_H__
 #define __MAPDIRECT_H__
 #include <linux/err.h>
+#include <linux/list.h>
 
 struct inode;
 struct work_struct;
 struct vm_area_struct;
 struct map_direct_state;
+struct list_direct_state;
+
+struct lease_direct {
+	struct list_head list;
+	struct lease_direct_state *lds;
+};
 
 #if IS_ENABLED(CONFIG_FS_DAX)
 struct map_direct_state *map_direct_register(int fd, struct vm_area_struct *vma);
 bool test_map_direct_valid(struct map_direct_state *mds);
 void generic_map_direct_open(struct vm_area_struct *vma);
 void generic_map_direct_close(struct vm_area_struct *vma);
+struct lease_direct *generic_map_direct_lease(struct vm_area_struct *vma,
+		void (*ld_break_fn)(void *), void *ld_owner);
+void map_direct_lease_destroy(struct lease_direct *ld);
 #else
 static inline struct map_direct_state *map_direct_register(int fd,
 		struct vm_area_struct *vma)
@@ -36,5 +46,9 @@ static inline bool test_map_direct_valid(struct map_direct_state *mds)
 }
 #define generic_map_direct_open NULL
 #define generic_map_direct_close NULL
+#define generic_map_direct_lease NULL
+static inline void map_direct_lease_destroy(struct lease_direct *ld)
+{
+}
 #endif
 #endif /* __MAPDIRECT_H__ */
diff --git a/include/linux/mm.h b/include/linux/mm.h
index 0afa19feb755..00d54e120257 100644
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -420,6 +420,14 @@ struct vm_operations_struct {
 	 */
 	struct page *(*find_special_page)(struct vm_area_struct *vma,
 					  unsigned long addr);
+	/*
+	 * Called by rdma or similar memory registration agent to
+	 * subscribe for "break" events that require any ongoing
+	 * accesses, that will not be stopped by a unmap_mapping_range,
+	 * to quiesce.
+	 */
+	struct lease_direct *(*lease_direct)(struct vm_area_struct *vma,
+			void (*break_fn)(void *), void *owner);
 };
 
 struct mmu_gather;

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
