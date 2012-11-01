Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx117.postini.com [74.125.245.117])
	by kanga.kvack.org (Postfix) with SMTP id 8C4616B0068
	for <linux-mm@kvack.org>; Thu,  1 Nov 2012 03:58:34 -0400 (EDT)
Subject: [PATCH 1/3] bdi: Track users that require stable page writes
From: "Darrick J. Wong" <darrick.wong@oracle.com>
Date: Thu, 01 Nov 2012 00:58:13 -0700
Message-ID: <20121101075813.16153.94581.stgit@blackbox.djwong.org>
In-Reply-To: <20121101075805.16153.64714.stgit@blackbox.djwong.org>
References: <20121101075805.16153.64714.stgit@blackbox.djwong.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: axboe@kernel.dk, lucho@ionkov.net, tytso@mit.edu, sage@inktank.com, darrick.wong@oracle.com, ericvh@gmail.com, mfasheh@suse.com, dedekind1@gmail.com, adrian.hunter@intel.com, dhowells@redhat.com, sfrench@samba.org, jlbec@evilplan.org, rminnich@sandia.gov
Cc: linux-cifs@vger.kernel.org, jack@suse.cz, martin.petersen@oracle.com, neilb@suse.de, david@fromorbit.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-mtd@lists.infradead.org, bharrosh@panasas.com, linux-fsdevel@vger.kernel.org, v9fs-developer@lists.sourceforge.net, ceph-devel@vger.kernel.org, linux-ext4@vger.kernel.org, linux-afs@lists.infradead.org, ocfs2-devel@oss.oracle.com

This creates a per-backing-device counter that tracks the number of users which
require pages to be held immutable during writeout.  Eventually it will be used
to waive wait_for_page_writeback() if nobody requires stable pages.

Signed-off-by: Darrick J. Wong <darrick.wong@oracle.com>
---
 Documentation/ABI/testing/sysfs-class-bdi |    7 +++++
 block/blk-integrity.c                     |    4 +++
 include/linux/backing-dev.h               |   16 ++++++++++++
 include/linux/blkdev.h                    |   10 ++++++++
 mm/backing-dev.c                          |   38 +++++++++++++++++++++++++++++
 5 files changed, 75 insertions(+)


diff --git a/Documentation/ABI/testing/sysfs-class-bdi b/Documentation/ABI/testing/sysfs-class-bdi
index 5f50097..218a618 100644
--- a/Documentation/ABI/testing/sysfs-class-bdi
+++ b/Documentation/ABI/testing/sysfs-class-bdi
@@ -48,3 +48,10 @@ max_ratio (read-write)
 	most of the write-back cache.  For example in case of an NFS
 	mount that is prone to get stuck, or a FUSE mount which cannot
 	be trusted to play fair.
+
+stable_pages_required (read-write)
+
+	If set, the backing device requires that all pages comprising a write
+	request must not be changed until writeout is complete.  The system
+	administrator can turn this on if the hardware does not do so already.
+	However, once enabled, this flag cannot be disabled.
diff --git a/block/blk-integrity.c b/block/blk-integrity.c
index da2a818..cf2dd95 100644
--- a/block/blk-integrity.c
+++ b/block/blk-integrity.c
@@ -420,6 +420,8 @@ int blk_integrity_register(struct gendisk *disk, struct blk_integrity *template)
 	} else
 		bi->name = bi_unsupported_name;
 
+	queue_require_stable_pages(disk->queue);
+
 	return 0;
 }
 EXPORT_SYMBOL(blk_integrity_register);
@@ -438,6 +440,8 @@ void blk_integrity_unregister(struct gendisk *disk)
 	if (!disk || !disk->integrity)
 		return;
 
+	queue_unrequire_stable_pages(disk->queue);
+
 	bi = disk->integrity;
 
 	kobject_uevent(&bi->kobj, KOBJ_REMOVE);
diff --git a/include/linux/backing-dev.h b/include/linux/backing-dev.h
index 2a9a9ab..0554f5d 100644
--- a/include/linux/backing-dev.h
+++ b/include/linux/backing-dev.h
@@ -109,6 +109,7 @@ struct backing_dev_info {
 	struct dentry *debug_dir;
 	struct dentry *debug_stats;
 #endif
+	atomic_t stable_page_users;
 };
 
 int bdi_init(struct backing_dev_info *bdi);
@@ -307,6 +308,21 @@ long wait_iff_congested(struct zone *zone, int sync, long timeout);
 int pdflush_proc_obsolete(struct ctl_table *table, int write,
 		void __user *buffer, size_t *lenp, loff_t *ppos);
 
+static inline void bdi_require_stable_pages(struct backing_dev_info *bdi)
+{
+	atomic_inc(&bdi->stable_page_users);
+}
+
+static inline void bdi_unrequire_stable_pages(struct backing_dev_info *bdi)
+{
+	atomic_dec(&bdi->stable_page_users);
+}
+
+static inline bool bdi_cap_stable_pages_required(struct backing_dev_info *bdi)
+{
+	return atomic_read(&bdi->stable_page_users) > 0;
+}
+
 static inline bool bdi_cap_writeback_dirty(struct backing_dev_info *bdi)
 {
 	return !(bdi->capabilities & BDI_CAP_NO_WRITEBACK);
diff --git a/include/linux/blkdev.h b/include/linux/blkdev.h
index 1756001..bf927c0 100644
--- a/include/linux/blkdev.h
+++ b/include/linux/blkdev.h
@@ -458,6 +458,16 @@ struct request_queue {
 				 (1 << QUEUE_FLAG_SAME_COMP)	|	\
 				 (1 << QUEUE_FLAG_ADD_RANDOM))
 
+static inline void queue_require_stable_pages(struct request_queue *q)
+{
+	bdi_require_stable_pages(&q->backing_dev_info);
+}
+
+static inline void queue_unrequire_stable_pages(struct request_queue *q)
+{
+	bdi_unrequire_stable_pages(&q->backing_dev_info);
+}
+
 static inline void queue_lockdep_assert_held(struct request_queue *q)
 {
 	if (q->queue_lock)
diff --git a/mm/backing-dev.c b/mm/backing-dev.c
index d3ca2b3..dd9f5ed 100644
--- a/mm/backing-dev.c
+++ b/mm/backing-dev.c
@@ -221,12 +221,48 @@ static ssize_t max_ratio_store(struct device *dev,
 }
 BDI_SHOW(max_ratio, bdi->max_ratio)
 
+static ssize_t stable_pages_required_store(struct device *dev,
+					   struct device_attribute *attr,
+					   const char *buf, size_t count)
+{
+	struct backing_dev_info *bdi = dev_get_drvdata(dev);
+	unsigned int spw;
+	ssize_t ret;
+
+	ret = kstrtouint(buf, 10, &spw);
+	if (ret < 0)
+		return ret;
+
+	/*
+	 * SPW could be enabled due to hw requirement, so don't
+	 * let users disable it.
+	 */
+	if (bdi_cap_stable_pages_required(bdi) && spw == 0)
+		return -EINVAL;
+
+	if (spw != 0)
+		atomic_inc(&bdi->stable_page_users);
+
+	return count;
+}
+
+static ssize_t stable_pages_required_show(struct device *dev,
+					  struct device_attribute *attr,
+					  char *page)
+{
+	struct backing_dev_info *bdi = dev_get_drvdata(dev);
+
+	return snprintf(page, PAGE_SIZE-1, "%d\n",
+			bdi_cap_stable_pages_required(bdi) ? 1 : 0);
+}
+
 #define __ATTR_RW(attr) __ATTR(attr, 0644, attr##_show, attr##_store)
 
 static struct device_attribute bdi_dev_attrs[] = {
 	__ATTR_RW(read_ahead_kb),
 	__ATTR_RW(min_ratio),
 	__ATTR_RW(max_ratio),
+	__ATTR_RW(stable_pages_required),
 	__ATTR_NULL,
 };
 
@@ -650,6 +686,8 @@ int bdi_init(struct backing_dev_info *bdi)
 	bdi->write_bandwidth = INIT_BW;
 	bdi->avg_write_bandwidth = INIT_BW;
 
+	atomic_set(&bdi->stable_page_users, 0);
+
 	err = fprop_local_init_percpu(&bdi->completions);
 
 	if (err) {

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
