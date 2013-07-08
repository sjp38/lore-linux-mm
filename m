Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx188.postini.com [74.125.245.188])
	by kanga.kvack.org (Postfix) with SMTP id 005FE6B0070
	for <linux-mm@kvack.org>; Mon,  8 Jul 2013 05:59:32 -0400 (EDT)
Received: by mail-la0-f46.google.com with SMTP id eg20so3643677lab.33
        for <linux-mm@kvack.org>; Mon, 08 Jul 2013 02:59:31 -0700 (PDT)
Subject: [PATCH RFC] fsio: filesystem io accounting cgroup
From: Konstantin Khlebnikov <khlebnikov@openvz.org>
Date: Mon, 08 Jul 2013 13:59:28 +0400
Message-ID: <20130708095928.14058.26736.stgit@zurg>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org

This is proof of concept, just basic functionality for IO controller.
This cgroup will control filesystem usage on vfs layer, it's main goal is
bandwidth control. It's supposed to be much more lightweight than memcg/blkio.

This patch shows easy way for accounting pages in dirty/writeback state in
per-inode manner. This is easier that doing this in memcg in per-page manner.
Main idea is in keeping on each inode pointer (->i_fsio) to cgroup which owns
dirty data in that inode. It's settled by fsio_account_page_dirtied() when
first dirty tag appears in the inode. Relying to mapping tags gives us locking
for free, this patch doesn't add any new locks to hot paths.

Unlike to blkio this method works for all of filesystems, not just disk-backed.
Also it's able to handle writeback, because each inode has context which can be
used in writeback thread to account io operations.

This is early prototype, I have some plans about extra functionality because
this accounting itself is mostly useless, but it can be used as basis for more
usefull features.

Planned impovements:
* Split bdi into several tiers and account them separately. For example:
  hdd/ssd/usb/nfs. In complicated containerized environments that might be
  different kinds of storages with different limits and billing. This is more
  usefull that independent per-disk accounting and much easier to implement
  because all per-tier structures are allocated before disk appearance.
* Add some hooks for accounting actualy issued IO requests (iops).
* Implement bandwidth throttlers for each tier individually (bps and iops).
  This will be the most tasty feature. I already have very effective prototype.
* Add hook into balance_dirty_pages to limit amount of dirty page for each
  cgroup in each tier individually. This is required for accurate throttling,
  because if we want to limit speed of writeback we also must limit amount
  of dirty pages otherwise we have to inject enourmous delay after each sync().
* Implement filtered writeback requests for writing only data which belongs to
  particular fsio cgroup (or cgroups tree) to keep dirty balance in background.
* Implement filtered 'sync', special mode for sync() which syncs only
  filesystems which 'belong' to current fsio cgroup. Each container should sync
  only it's own filesystems. This also can be made in terms of 'visibility' in
  vfsmount namespaces.

This patch lays on top of this:
b26008c page_writeback: put account_page_redirty() after set_page_dirty()
80979bd page_writeback: get rid of account_size argument in cancel_dirty_page()
c575ef6 hugetlbfs: remove cancel_dirty_page() from truncate_huge_page()
b720923 nfs: remove redundant cancel_dirty_page() from nfs_wb_page_cancel()
4c21e52 mm: remove redundant dirty pages check from __delete_from_page_cache()

Signed-off-by: Konstantin Khlebnikov <khlebnikov@openvz.org>
Cc: cgroups@vger.kernel.org
Cc: devel@openvz.org
Cc: Michal Hocko <mhocko@suse.cz>
Cc: Sha Zhengju <handai.szj@gmail.com>
---
 block/blk-core.c              |    2 +
 fs/Makefile                   |    2 +
 fs/direct-io.c                |    2 +
 fs/fsio_cgroup.c              |  137 +++++++++++++++++++++++++++++++++++++++++
 fs/nfs/direct.c               |    2 +
 include/linux/cgroup_subsys.h |    6 ++
 include/linux/fs.h            |    3 +
 include/linux/fsio_cgroup.h   |  136 +++++++++++++++++++++++++++++++++++++++++
 init/Kconfig                  |    3 +
 mm/page-writeback.c           |    8 ++
 mm/readahead.c                |    2 +
 mm/truncate.c                 |    2 +
 12 files changed, 304 insertions(+), 1 deletion(-)
 create mode 100644 fs/fsio_cgroup.c
 create mode 100644 include/linux/fsio_cgroup.h

diff --git a/block/blk-core.c b/block/blk-core.c
index 93a18d1..5f4e6c9 100644
--- a/block/blk-core.c
+++ b/block/blk-core.c
@@ -26,6 +26,7 @@
 #include <linux/swap.h>
 #include <linux/writeback.h>
 #include <linux/task_io_accounting_ops.h>
+#include <linux/fsio_cgroup.h>
 #include <linux/fault-inject.h>
 #include <linux/list_sort.h>
 #include <linux/delay.h>
@@ -1866,6 +1867,7 @@ void submit_bio(int rw, struct bio *bio)
 			count_vm_events(PGPGOUT, count);
 		} else {
 			task_io_account_read(bio->bi_size);
+			fsio_account_read(bio->bi_size);
 			count_vm_events(PGPGIN, count);
 		}
 
diff --git a/fs/Makefile b/fs/Makefile
index 4fe6df3..d4432e7 100644
--- a/fs/Makefile
+++ b/fs/Makefile
@@ -52,6 +52,8 @@ obj-$(CONFIG_FHANDLE)		+= fhandle.o
 
 obj-y				+= quota/
 
+obj-$(CONFIG_FSIO_CGROUP)	+= fsio_cgroup.o
+
 obj-$(CONFIG_PROC_FS)		+= proc/
 obj-$(CONFIG_SYSFS)		+= sysfs/
 obj-$(CONFIG_CONFIGFS_FS)	+= configfs/
diff --git a/fs/direct-io.c b/fs/direct-io.c
index 7ab90f5..0fe99af 100644
--- a/fs/direct-io.c
+++ b/fs/direct-io.c
@@ -28,6 +28,7 @@
 #include <linux/highmem.h>
 #include <linux/pagemap.h>
 #include <linux/task_io_accounting_ops.h>
+#include <linux/fsio_cgroup.h>
 #include <linux/bio.h>
 #include <linux/wait.h>
 #include <linux/err.h>
@@ -722,6 +723,7 @@ submit_page_section(struct dio *dio, struct dio_submit *sdio, struct page *page,
 		 * Read accounting is performed in submit_bio()
 		 */
 		task_io_account_write(len);
+		fsio_account_write(len);
 	}
 
 	/*
diff --git a/fs/fsio_cgroup.c b/fs/fsio_cgroup.c
new file mode 100644
index 0000000..5d5158f
--- /dev/null
+++ b/fs/fsio_cgroup.c
@@ -0,0 +1,137 @@
+#include <linux/fsio_cgroup.h>
+#include "internal.h"
+
+static inline struct fsio_cgroup *cgroup_fsio(struct cgroup *cgroup)
+{
+	return container_of(cgroup_subsys_state(cgroup, fsio_subsys_id),
+			    struct fsio_cgroup, css);
+}
+
+static void fsio_free(struct fsio_cgroup *fsio)
+{
+	percpu_counter_destroy(&fsio->read_bytes);
+	percpu_counter_destroy(&fsio->write_bytes);
+	percpu_counter_destroy(&fsio->nr_dirty);
+	percpu_counter_destroy(&fsio->nr_writeback);
+	kfree(fsio);
+}
+
+static struct cgroup_subsys_state *fsio_css_alloc(struct cgroup *cgroup)
+{
+	struct fsio_cgroup *fsio;
+
+	fsio = kzalloc(sizeof(struct fsio_cgroup), GFP_KERNEL);
+	if (!fsio)
+		return ERR_PTR(-ENOMEM);
+
+	if (percpu_counter_init(&fsio->read_bytes, 0) ||
+	    percpu_counter_init(&fsio->write_bytes, 0) ||
+	    percpu_counter_init(&fsio->nr_dirty, 0) ||
+	    percpu_counter_init(&fsio->nr_writeback, 0)) {
+		fsio_free(fsio);
+		return ERR_PTR(-ENOMEM);
+	}
+
+	return &fsio->css;
+}
+
+/* switch all ->i_fsio references to the parent cgroup */
+static void fsio_switch_sb(struct super_block *sb, void *_fsio)
+{
+	struct fsio_cgroup *fsio = _fsio;
+	struct fsio_cgroup *parent = cgroup_fsio(fsio->css.cgroup->parent);
+	struct address_space *mapping;
+	struct inode *inode;
+
+	spin_lock(&inode_sb_list_lock);
+	list_for_each_entry(inode, &sb->s_inodes, i_sb_list) {
+		mapping = inode->i_mapping;
+		if (mapping->i_fsio == fsio &&
+		    (mapping_tagged(mapping, PAGECACHE_TAG_DIRTY) ||
+		     mapping_tagged(mapping, PAGECACHE_TAG_WRITEBACK))) {
+			spin_lock_irq(&mapping->tree_lock);
+			if (mapping->i_fsio == fsio)
+				mapping->i_fsio = parent;
+			spin_unlock_irq(&mapping->tree_lock);
+		}
+	}
+	spin_unlock(&inode_sb_list_lock);
+}
+
+static void fsio_css_free(struct cgroup *cgroup)
+{
+	struct fsio_cgroup *fsio = cgroup_fsio(cgroup);
+	struct fsio_cgroup *parent = cgroup_fsio(fsio->css.cgroup->parent);
+	u64 nr_dirty, nr_writeback, tmp;
+
+	nr_dirty = percpu_counter_sum_positive(&fsio->nr_dirty);
+	percpu_counter_add(&parent->nr_dirty, nr_dirty);
+
+	nr_writeback = percpu_counter_sum_positive(&fsio->nr_writeback);
+	percpu_counter_add(&parent->nr_writeback, nr_writeback);
+
+	iterate_supers(fsio_switch_sb, fsio);
+
+	tmp = percpu_counter_sum(&fsio->nr_dirty);
+	percpu_counter_add(&parent->nr_dirty, tmp - nr_dirty);
+
+	tmp = percpu_counter_sum(&fsio->nr_writeback);
+	percpu_counter_add(&parent->nr_writeback, tmp - nr_writeback);
+}
+
+static u64 fsio_get_read_bytes(struct cgroup *cgroup, struct cftype *cft)
+{
+	struct fsio_cgroup *fsio = cgroup_fsio(cgroup);
+
+	return percpu_counter_sum(&fsio->read_bytes);
+}
+
+static u64 fsio_get_write_bytes(struct cgroup *cgroup, struct cftype *cft)
+{
+	struct fsio_cgroup *fsio = cgroup_fsio(cgroup);
+
+	return percpu_counter_sum(&fsio->write_bytes);
+}
+
+static u64 fsio_get_dirty_bytes(struct cgroup *cgroup, struct cftype *cft)
+{
+	struct fsio_cgroup *fsio = cgroup_fsio(cgroup);
+
+	return percpu_counter_sum_positive(&fsio->nr_dirty) * PAGE_CACHE_SIZE;
+}
+
+static u64 fsio_get_writeback_bytes(struct cgroup *cgroup, struct cftype *cft)
+{
+	struct fsio_cgroup *fsio = cgroup_fsio(cgroup);
+
+	return percpu_counter_sum_positive(&fsio->nr_writeback) *
+		PAGE_CACHE_SIZE;
+}
+
+static struct cftype fsio_files[] = {
+	{
+		.name = "read_bytes",
+		.read_u64 = fsio_get_read_bytes,
+	},
+	{
+		.name = "write_bytes",
+		.read_u64 = fsio_get_write_bytes,
+	},
+	{
+		.name = "dirty_bytes",
+		.read_u64 = fsio_get_dirty_bytes,
+	},
+	{
+		.name = "writeback_bytes",
+		.read_u64 = fsio_get_writeback_bytes,
+	},
+	{ }	/* terminate */
+};
+
+struct cgroup_subsys fsio_subsys = {
+	.name = "fsio",
+	.subsys_id = fsio_subsys_id,
+	.css_alloc = fsio_css_alloc,
+	.css_free = fsio_css_free,
+	.base_cftypes = fsio_files,
+};
diff --git a/fs/nfs/direct.c b/fs/nfs/direct.c
index 0bd7a55..b8e61ee 100644
--- a/fs/nfs/direct.c
+++ b/fs/nfs/direct.c
@@ -46,6 +46,7 @@
 #include <linux/kref.h>
 #include <linux/slab.h>
 #include <linux/task_io_accounting_ops.h>
+#include <linux/fsio_cgroup.h>
 #include <linux/module.h>
 
 #include <linux/nfs_fs.h>
@@ -987,6 +988,7 @@ ssize_t nfs_file_direct_write(struct kiocb *iocb, const struct iovec *iov,
 		goto out;
 
 	task_io_account_write(count);
+	fsio_account_write(count);
 
 	retval = nfs_direct_write(iocb, iov, nr_segs, pos, count, uio);
 	if (retval > 0) {
diff --git a/include/linux/cgroup_subsys.h b/include/linux/cgroup_subsys.h
index 6e7ec64..d16df6e 100644
--- a/include/linux/cgroup_subsys.h
+++ b/include/linux/cgroup_subsys.h
@@ -84,3 +84,9 @@ SUBSYS(bcache)
 #endif
 
 /* */
+
+#if IS_SUBSYS_ENABLED(CONFIG_FSIO_CGROUP)
+SUBSYS(fsio)
+#endif
+
+/* */
diff --git a/include/linux/fs.h b/include/linux/fs.h
index 99be011..8156d99 100644
--- a/include/linux/fs.h
+++ b/include/linux/fs.h
@@ -421,6 +421,9 @@ struct address_space {
 	spinlock_t		private_lock;	/* for use by the address_space */
 	struct list_head	private_list;	/* ditto */
 	void			*private_data;	/* ditto */
+#ifdef CONFIG_FSIO_CGROUP
+	struct fsio_cgroup	*i_fsio;	/* protected with tree_lock */
+#endif
 } __attribute__((aligned(sizeof(long))));
 	/*
 	 * On most architectures that alignment is already the case; but
diff --git a/include/linux/fsio_cgroup.h b/include/linux/fsio_cgroup.h
new file mode 100644
index 0000000..78aa53b
--- /dev/null
+++ b/include/linux/fsio_cgroup.h
@@ -0,0 +1,136 @@
+#ifndef _LINUX_FSIO_CGGROUP_H
+#define _LINUX_FSIO_CGGROUP_H
+
+#include <linux/fs.h>
+#include <linux/pagemap.h>
+#include <linux/cgroup.h>
+#include <linux/workqueue.h>
+#include <linux/percpu_counter.h>
+
+struct fsio_cgroup {
+	struct cgroup_subsys_state css;
+	struct percpu_counter read_bytes;
+	struct percpu_counter write_bytes;
+	struct percpu_counter nr_dirty;
+	struct percpu_counter nr_writeback;
+};
+
+#ifdef CONFIG_FSIO_CGROUP
+
+static inline struct fsio_cgroup *task_fsio_cgroup(struct task_struct *task)
+{
+	return container_of(task_subsys_state(task, fsio_subsys_id),
+			    struct fsio_cgroup, css);
+}
+
+/*
+ * This accounts all reads, both cached and direct-io.
+ */
+static inline void fsio_account_read(unsigned long bytes)
+{
+	struct task_struct *task = current;
+	struct fsio_cgroup *fsio;
+
+	rcu_read_lock();
+	fsio = task_fsio_cgroup(task);
+	__percpu_counter_add(&fsio->read_bytes, bytes,
+			PAGE_CACHE_SIZE * percpu_counter_batch);
+	rcu_read_unlock();
+}
+
+/*
+ * This is used for accounting  direct-io writes.
+ */
+static inline void fsio_account_write(unsigned long bytes)
+{
+	struct task_struct *task = current;
+	struct fsio_cgroup *fsio;
+
+	rcu_read_lock();
+	fsio = task_fsio_cgroup(task);
+	__percpu_counter_add(&fsio->write_bytes, bytes,
+			PAGE_CACHE_SIZE * percpu_counter_batch);
+	rcu_read_unlock();
+}
+
+/*
+ * This called under mapping->tree_lock before setting radix-tree tag,
+ * page which caused this call either locked (write) or mapped (unmap).
+ *
+ * If this is first dirty page in inode and there is no writeback then current
+ * fsio cgroup becomes owner of this inode. Following radix_tree_tag_set()
+ * will pin this pointer till the end of writeback or truncate. Otherwise
+ * mapping->i_fsio already valid and points to cgroup who owns this inode.
+ */
+static inline void fsio_account_page_dirtied(struct address_space *mapping)
+{
+	struct fsio_cgroup *fsio = mapping->i_fsio;
+
+	if (!mapping_tagged(mapping, PAGECACHE_TAG_DIRTY) &&
+	    !mapping_tagged(mapping, PAGECACHE_TAG_WRITEBACK)) {
+		rcu_read_lock();
+		fsio = task_fsio_cgroup(current);
+		mapping->i_fsio = fsio;
+		rcu_read_unlock();
+	}
+
+	percpu_counter_inc(&fsio->nr_dirty);
+}
+
+/*
+ * This called after clearing dirty bit. Page here locked and unmapped,
+ * thus dirtying process is complete and mapping->i_fsio is valid.
+ * This state is stable because at this point page still in mapping and tagged.
+ * We cannot reset mapping->i_mapping here even that was last dirty page, becase
+ * this hook is called without tree_lock before removing page from page cache.
+ */
+static inline void fsio_cancel_dirty_page(struct address_space *mapping)
+{
+	percpu_counter_dec(&mapping->i_fsio->nr_dirty);
+}
+
+/*
+ * This called after redirtying page, thus nr_dirty will not fall to zero.
+ * No tree_lock, page is locked and still tagged in mapping.
+ */
+static inline void fsio_account_page_redirty(struct address_space *mapping)
+{
+	percpu_counter_dec(&mapping->i_fsio->nr_dirty);
+}
+
+/*
+ * This switches page accounging from dirty to writeback.
+ */
+static inline void fsio_set_page_writeback(struct address_space *mapping)
+{
+	struct fsio_cgroup *fsio = mapping->i_fsio;
+
+	percpu_counter_inc(&fsio->nr_writeback);
+	percpu_counter_dec(&fsio->nr_dirty);
+}
+
+/*
+ * Writeback is done, mapping->i_fsio pointer becomes invalid after that.
+ */
+static inline void fsio_clear_page_writeback(struct address_space *mapping)
+{
+	struct fsio_cgroup *fsio = mapping->i_fsio;
+
+	__percpu_counter_add(&fsio->write_bytes, PAGE_CACHE_SIZE,
+			PAGE_CACHE_SIZE * percpu_counter_batch);
+	percpu_counter_dec(&fsio->nr_writeback);
+}
+
+#else /* CONFIG_FSIO_CGROUP */
+
+static inline void fsio_account_read(unsigned long bytes) {}
+static inline void fsio_account_write(unsigned long bytes) {}
+static inline void fsio_account_page_dirtied(struct address_space *mapping) {}
+static inline void fsio_cancel_dirty_page(struct address_space *mapping) {}
+static inline void fsio_account_page_redirty(struct address_space *mapping) {}
+static inline void fsio_set_page_writeback(struct address_space *mapping) {}
+static inline void fsio_clear_page_writeback(struct address_space *mapping) {}
+
+#endif /* CONFIG_FSIO_CGROUP */
+
+#endif /* _LINUX_FSIO_CGGROUP_H */
diff --git a/init/Kconfig b/init/Kconfig
index ea1be00..689b29a 100644
--- a/init/Kconfig
+++ b/init/Kconfig
@@ -1050,6 +1050,9 @@ config DEBUG_BLK_CGROUP
 	Enable some debugging help. Currently it exports additional stat
 	files in a cgroup which can be useful for debugging.
 
+config FSIO_CGROUP
+	bool "Filesystem IO controller"
+
 endif # CGROUPS
 
 config CHECKPOINT_RESTORE
diff --git a/mm/page-writeback.c b/mm/page-writeback.c
index a599f38..bc39a36 100644
--- a/mm/page-writeback.c
+++ b/mm/page-writeback.c
@@ -23,6 +23,7 @@
 #include <linux/init.h>
 #include <linux/backing-dev.h>
 #include <linux/task_io_accounting_ops.h>
+#include <linux/fsio_cgroup.h>
 #include <linux/blkdev.h>
 #include <linux/mpage.h>
 #include <linux/rmap.h>
@@ -1994,6 +1995,7 @@ void account_page_dirtied(struct page *page, struct address_space *mapping)
 		__inc_bdi_stat(mapping->backing_dev_info, BDI_RECLAIMABLE);
 		__inc_bdi_stat(mapping->backing_dev_info, BDI_DIRTIED);
 		task_io_account_write(PAGE_CACHE_SIZE);
+		fsio_account_page_dirtied(mapping);
 		current->nr_dirtied++;
 		this_cpu_inc(bdp_ratelimits);
 	}
@@ -2071,6 +2073,7 @@ void account_page_redirty(struct page *page)
 		current->nr_dirtied--;
 		dec_zone_page_state(page, NR_DIRTIED);
 		dec_bdi_stat(mapping->backing_dev_info, BDI_DIRTIED);
+		fsio_account_page_redirty(mapping);
 	}
 }
 EXPORT_SYMBOL(account_page_redirty);
@@ -2242,6 +2245,7 @@ int test_clear_page_writeback(struct page *page)
 			if (bdi_cap_account_writeback(bdi)) {
 				__dec_bdi_stat(bdi, BDI_WRITEBACK);
 				__bdi_writeout_inc(bdi);
+				fsio_clear_page_writeback(mapping);
 			}
 		}
 		spin_unlock_irqrestore(&mapping->tree_lock, flags);
@@ -2270,8 +2274,10 @@ int test_set_page_writeback(struct page *page)
 			radix_tree_tag_set(&mapping->page_tree,
 						page_index(page),
 						PAGECACHE_TAG_WRITEBACK);
-			if (bdi_cap_account_writeback(bdi))
+			if (bdi_cap_account_writeback(bdi)) {
 				__inc_bdi_stat(bdi, BDI_WRITEBACK);
+				fsio_set_page_writeback(mapping);
+			}
 		}
 		if (!PageDirty(page))
 			radix_tree_tag_clear(&mapping->page_tree,
diff --git a/mm/readahead.c b/mm/readahead.c
index 829a77c..530599c 100644
--- a/mm/readahead.c
+++ b/mm/readahead.c
@@ -15,6 +15,7 @@
 #include <linux/blkdev.h>
 #include <linux/backing-dev.h>
 #include <linux/task_io_accounting_ops.h>
+#include <linux/fsio_cgroup.h>
 #include <linux/pagevec.h>
 #include <linux/pagemap.h>
 #include <linux/syscalls.h>
@@ -102,6 +103,7 @@ int read_cache_pages(struct address_space *mapping, struct list_head *pages,
 			break;
 		}
 		task_io_account_read(PAGE_CACHE_SIZE);
+		fsio_account_read(PAGE_CACHE_SIZE);
 	}
 	return ret;
 }
diff --git a/mm/truncate.c b/mm/truncate.c
index e212252..e84668e 100644
--- a/mm/truncate.c
+++ b/mm/truncate.c
@@ -17,6 +17,7 @@
 #include <linux/highmem.h>
 #include <linux/pagevec.h>
 #include <linux/task_io_accounting_ops.h>
+#include <linux/fsio_cgroup.h>
 #include <linux/buffer_head.h>	/* grr. try_to_release_page,
 				   do_invalidatepage */
 #include <linux/cleancache.h>
@@ -75,6 +76,7 @@ void cancel_dirty_page(struct page *page)
 			dec_bdi_stat(mapping->backing_dev_info,
 					BDI_RECLAIMABLE);
 			task_io_account_cancelled_write(PAGE_CACHE_SIZE);
+			fsio_cancel_dirty_page(mapping);
 		}
 	}
 }

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
