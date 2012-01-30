Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx160.postini.com [74.125.245.160])
	by kanga.kvack.org (Postfix) with SMTP id A257C6B0070
	for <linux-mm@kvack.org>; Mon, 30 Jan 2012 17:39:24 -0500 (EST)
From: Dan Magenheimer <dan.magenheimer@oracle.com>
Subject: [PATCH 1/6] staging: ramster: cluster/messaging foundation
Date: Mon, 30 Jan 2012 14:39:18 -0800
Message-Id: <1327963158-15971-1-git-send-email-dan.magenheimer@oracle.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: devel@driverdev.osuosl.org, linux-kernel@vger.kernel.org, gregkh@suse.de, linux-mm@kvack.org, ngupta@vflare.org, konrad.wilk@oracle.com, kurt.hackel@oracle.com, sjenning@linux.vnet.ibm.com, chris.mason@oracle.com, dan.magenheimer@oracle.com

Copy cluster subdirectory from ocfs2.  These files implement
the basic cluster discovery, mapping, heartbeat / keepalive, and
messaging ("o2net") that ramster requires for internode communication.
Note: there are NO ramster-specific changes yet; this commit
does NOT pass checkpatch since the copied source files do not.

(Why copy?  This particular part of ocfs2 has never been broken out
for non-ocfs2 use before, some (small) changes are required for ramster
to use that code, and ramster is currently incompatible with real
ocfs2 anyway (requires !CONFIG_OCFS2_FS).  Before ramster can be promoted
out of staging, we will need to work with the ocfs2 maintainers to
see if the code interdependencies can be merged, but for now, for
staging, this seemed to be an expedient way to make use of the ocfs2
core cluster code while still incorporating necessary changes for ramster.)

Signed-off-by: Dan Magenheimer <dan.magenheimer@oracle.com>
---
 drivers/staging/ramster/cluster/Makefile           |    4 +
 drivers/staging/ramster/cluster/heartbeat.c        | 2678 ++++++++++++++++++++
 drivers/staging/ramster/cluster/heartbeat.h        |   89 +
 drivers/staging/ramster/cluster/masklog.c          |  155 ++
 drivers/staging/ramster/cluster/masklog.h          |  219 ++
 drivers/staging/ramster/cluster/netdebug.c         |  579 +++++
 drivers/staging/ramster/cluster/nodemanager.c      |  989 ++++++++
 drivers/staging/ramster/cluster/nodemanager.h      |   88 +
 drivers/staging/ramster/cluster/ocfs2_heartbeat.h  |   38 +
 .../staging/ramster/cluster/ocfs2_nodemanager.h    |   45 +
 drivers/staging/ramster/cluster/quorum.c           |  331 +++
 drivers/staging/ramster/cluster/quorum.h           |   36 +
 drivers/staging/ramster/cluster/sys.c              |   82 +
 drivers/staging/ramster/cluster/sys.h              |   33 +
 drivers/staging/ramster/cluster/tcp.c              | 2150 ++++++++++++++++
 drivers/staging/ramster/cluster/tcp.h              |  154 ++
 drivers/staging/ramster/cluster/tcp_internal.h     |  242 ++
 drivers/staging/ramster/cluster/ver.c              |   42 +
 drivers/staging/ramster/cluster/ver.h              |   31 +
 19 files changed, 7985 insertions(+), 0 deletions(-)
 create mode 100644 drivers/staging/ramster/cluster/Makefile
 create mode 100644 drivers/staging/ramster/cluster/heartbeat.c
 create mode 100644 drivers/staging/ramster/cluster/heartbeat.h
 create mode 100644 drivers/staging/ramster/cluster/masklog.c
 create mode 100644 drivers/staging/ramster/cluster/masklog.h
 create mode 100644 drivers/staging/ramster/cluster/netdebug.c
 create mode 100644 drivers/staging/ramster/cluster/nodemanager.c
 create mode 100644 drivers/staging/ramster/cluster/nodemanager.h
 create mode 100644 drivers/staging/ramster/cluster/ocfs2_heartbeat.h
 create mode 100644 drivers/staging/ramster/cluster/ocfs2_nodemanager.h
 create mode 100644 drivers/staging/ramster/cluster/quorum.c
 create mode 100644 drivers/staging/ramster/cluster/quorum.h
 create mode 100644 drivers/staging/ramster/cluster/sys.c
 create mode 100644 drivers/staging/ramster/cluster/sys.h
 create mode 100644 drivers/staging/ramster/cluster/tcp.c
 create mode 100644 drivers/staging/ramster/cluster/tcp.h
 create mode 100644 drivers/staging/ramster/cluster/tcp_internal.h
 create mode 100644 drivers/staging/ramster/cluster/ver.c
 create mode 100644 drivers/staging/ramster/cluster/ver.h

diff --git a/drivers/staging/ramster/cluster/Makefile b/drivers/staging/ramster/cluster/Makefile
new file mode 100644
index 0000000..bc8c5e7
--- /dev/null
+++ b/drivers/staging/ramster/cluster/Makefile
@@ -0,0 +1,4 @@
+obj-$(CONFIG_OCFS2_FS) += ocfs2_nodemanager.o
+
+ocfs2_nodemanager-objs := heartbeat.o masklog.o sys.o nodemanager.o \
+	quorum.o tcp.o netdebug.o ver.o
diff --git a/drivers/staging/ramster/cluster/heartbeat.c b/drivers/staging/ramster/cluster/heartbeat.c
new file mode 100644
index 0000000..a4e855e
--- /dev/null
+++ b/drivers/staging/ramster/cluster/heartbeat.c
@@ -0,0 +1,2678 @@
+/* -*- mode: c; c-basic-offset: 8; -*-
+ * vim: noexpandtab sw=8 ts=8 sts=0:
+ *
+ * Copyright (C) 2004, 2005 Oracle.  All rights reserved.
+ *
+ * This program is free software; you can redistribute it and/or
+ * modify it under the terms of the GNU General Public
+ * License as published by the Free Software Foundation; either
+ * version 2 of the License, or (at your option) any later version.
+ *
+ * This program is distributed in the hope that it will be useful,
+ * but WITHOUT ANY WARRANTY; without even the implied warranty of
+ * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
+ * General Public License for more details.
+ *
+ * You should have received a copy of the GNU General Public
+ * License along with this program; if not, write to the
+ * Free Software Foundation, Inc., 59 Temple Place - Suite 330,
+ * Boston, MA 021110-1307, USA.
+ */
+
+#include <linux/kernel.h>
+#include <linux/sched.h>
+#include <linux/jiffies.h>
+#include <linux/module.h>
+#include <linux/fs.h>
+#include <linux/bio.h>
+#include <linux/blkdev.h>
+#include <linux/delay.h>
+#include <linux/file.h>
+#include <linux/kthread.h>
+#include <linux/configfs.h>
+#include <linux/random.h>
+#include <linux/crc32.h>
+#include <linux/time.h>
+#include <linux/debugfs.h>
+#include <linux/slab.h>
+
+#include "heartbeat.h"
+#include "tcp.h"
+#include "nodemanager.h"
+#include "quorum.h"
+
+#include "masklog.h"
+
+
+/*
+ * The first heartbeat pass had one global thread that would serialize all hb
+ * callback calls.  This global serializing sem should only be removed once
+ * we've made sure that all callees can deal with being called concurrently
+ * from multiple hb region threads.
+ */
+static DECLARE_RWSEM(o2hb_callback_sem);
+
+/*
+ * multiple hb threads are watching multiple regions.  A node is live
+ * whenever any of the threads sees activity from the node in its region.
+ */
+static DEFINE_SPINLOCK(o2hb_live_lock);
+static struct list_head o2hb_live_slots[O2NM_MAX_NODES];
+static unsigned long o2hb_live_node_bitmap[BITS_TO_LONGS(O2NM_MAX_NODES)];
+static LIST_HEAD(o2hb_node_events);
+static DECLARE_WAIT_QUEUE_HEAD(o2hb_steady_queue);
+
+/*
+ * In global heartbeat, we maintain a series of region bitmaps.
+ * 	- o2hb_region_bitmap allows us to limit the region number to max region.
+ * 	- o2hb_live_region_bitmap tracks live regions (seen steady iterations).
+ * 	- o2hb_quorum_region_bitmap tracks live regions that have seen all nodes
+ * 		heartbeat on it.
+ * 	- o2hb_failed_region_bitmap tracks the regions that have seen io timeouts.
+ */
+static unsigned long o2hb_region_bitmap[BITS_TO_LONGS(O2NM_MAX_REGIONS)];
+static unsigned long o2hb_live_region_bitmap[BITS_TO_LONGS(O2NM_MAX_REGIONS)];
+static unsigned long o2hb_quorum_region_bitmap[BITS_TO_LONGS(O2NM_MAX_REGIONS)];
+static unsigned long o2hb_failed_region_bitmap[BITS_TO_LONGS(O2NM_MAX_REGIONS)];
+
+#define O2HB_DB_TYPE_LIVENODES		0
+#define O2HB_DB_TYPE_LIVEREGIONS	1
+#define O2HB_DB_TYPE_QUORUMREGIONS	2
+#define O2HB_DB_TYPE_FAILEDREGIONS	3
+#define O2HB_DB_TYPE_REGION_LIVENODES	4
+#define O2HB_DB_TYPE_REGION_NUMBER	5
+#define O2HB_DB_TYPE_REGION_ELAPSED_TIME	6
+#define O2HB_DB_TYPE_REGION_PINNED	7
+struct o2hb_debug_buf {
+	int db_type;
+	int db_size;
+	int db_len;
+	void *db_data;
+};
+
+static struct o2hb_debug_buf *o2hb_db_livenodes;
+static struct o2hb_debug_buf *o2hb_db_liveregions;
+static struct o2hb_debug_buf *o2hb_db_quorumregions;
+static struct o2hb_debug_buf *o2hb_db_failedregions;
+
+#define O2HB_DEBUG_DIR			"o2hb"
+#define O2HB_DEBUG_LIVENODES		"livenodes"
+#define O2HB_DEBUG_LIVEREGIONS		"live_regions"
+#define O2HB_DEBUG_QUORUMREGIONS	"quorum_regions"
+#define O2HB_DEBUG_FAILEDREGIONS	"failed_regions"
+#define O2HB_DEBUG_REGION_NUMBER	"num"
+#define O2HB_DEBUG_REGION_ELAPSED_TIME	"elapsed_time_in_ms"
+#define O2HB_DEBUG_REGION_PINNED	"pinned"
+
+static struct dentry *o2hb_debug_dir;
+static struct dentry *o2hb_debug_livenodes;
+static struct dentry *o2hb_debug_liveregions;
+static struct dentry *o2hb_debug_quorumregions;
+static struct dentry *o2hb_debug_failedregions;
+
+static LIST_HEAD(o2hb_all_regions);
+
+static struct o2hb_callback {
+	struct list_head list;
+} o2hb_callbacks[O2HB_NUM_CB];
+
+static struct o2hb_callback *hbcall_from_type(enum o2hb_callback_type type);
+
+#define O2HB_DEFAULT_BLOCK_BITS       9
+
+enum o2hb_heartbeat_modes {
+	O2HB_HEARTBEAT_LOCAL		= 0,
+	O2HB_HEARTBEAT_GLOBAL,
+	O2HB_HEARTBEAT_NUM_MODES,
+};
+
+char *o2hb_heartbeat_mode_desc[O2HB_HEARTBEAT_NUM_MODES] = {
+		"local",	/* O2HB_HEARTBEAT_LOCAL */
+		"global",	/* O2HB_HEARTBEAT_GLOBAL */
+};
+
+unsigned int o2hb_dead_threshold = O2HB_DEFAULT_DEAD_THRESHOLD;
+unsigned int o2hb_heartbeat_mode = O2HB_HEARTBEAT_LOCAL;
+
+/*
+ * o2hb_dependent_users tracks the number of registered callbacks that depend
+ * on heartbeat. o2net and o2dlm are two entities that register this callback.
+ * However only o2dlm depends on the heartbeat. It does not want the heartbeat
+ * to stop while a dlm domain is still active.
+ */
+unsigned int o2hb_dependent_users;
+
+/*
+ * In global heartbeat mode, all regions are pinned if there are one or more
+ * dependent users and the quorum region count is <= O2HB_PIN_CUT_OFF. All
+ * regions are unpinned if the region count exceeds the cut off or the number
+ * of dependent users falls to zero.
+ */
+#define O2HB_PIN_CUT_OFF		3
+
+/*
+ * In local heartbeat mode, we assume the dlm domain name to be the same as
+ * region uuid. This is true for domains created for the file system but not
+ * necessarily true for userdlm domains. This is a known limitation.
+ *
+ * In global heartbeat mode, we pin/unpin all o2hb regions. This solution
+ * works for both file system and userdlm domains.
+ */
+static int o2hb_region_pin(const char *region_uuid);
+static void o2hb_region_unpin(const char *region_uuid);
+
+/* Only sets a new threshold if there are no active regions.
+ *
+ * No locking or otherwise interesting code is required for reading
+ * o2hb_dead_threshold as it can't change once regions are active and
+ * it's not interesting to anyone until then anyway. */
+static void o2hb_dead_threshold_set(unsigned int threshold)
+{
+	if (threshold > O2HB_MIN_DEAD_THRESHOLD) {
+		spin_lock(&o2hb_live_lock);
+		if (list_empty(&o2hb_all_regions))
+			o2hb_dead_threshold = threshold;
+		spin_unlock(&o2hb_live_lock);
+	}
+}
+
+static int o2hb_global_hearbeat_mode_set(unsigned int hb_mode)
+{
+	int ret = -1;
+
+	if (hb_mode < O2HB_HEARTBEAT_NUM_MODES) {
+		spin_lock(&o2hb_live_lock);
+		if (list_empty(&o2hb_all_regions)) {
+			o2hb_heartbeat_mode = hb_mode;
+			ret = 0;
+		}
+		spin_unlock(&o2hb_live_lock);
+	}
+
+	return ret;
+}
+
+struct o2hb_node_event {
+	struct list_head        hn_item;
+	enum o2hb_callback_type hn_event_type;
+	struct o2nm_node        *hn_node;
+	int                     hn_node_num;
+};
+
+struct o2hb_disk_slot {
+	struct o2hb_disk_heartbeat_block *ds_raw_block;
+	u8			ds_node_num;
+	u64			ds_last_time;
+	u64			ds_last_generation;
+	u16			ds_equal_samples;
+	u16			ds_changed_samples;
+	struct list_head	ds_live_item;
+};
+
+/* each thread owns a region.. when we're asked to tear down the region
+ * we ask the thread to stop, who cleans up the region */
+struct o2hb_region {
+	struct config_item	hr_item;
+
+	struct list_head	hr_all_item;
+	unsigned		hr_unclean_stop:1,
+				hr_aborted_start:1,
+				hr_item_pinned:1,
+				hr_item_dropped:1;
+
+	/* protected by the hr_callback_sem */
+	struct task_struct 	*hr_task;
+
+	unsigned int		hr_blocks;
+	unsigned long long	hr_start_block;
+
+	unsigned int		hr_block_bits;
+	unsigned int		hr_block_bytes;
+
+	unsigned int		hr_slots_per_page;
+	unsigned int		hr_num_pages;
+
+	struct page             **hr_slot_data;
+	struct block_device	*hr_bdev;
+	struct o2hb_disk_slot	*hr_slots;
+
+	/* live node map of this region */
+	unsigned long		hr_live_node_bitmap[BITS_TO_LONGS(O2NM_MAX_NODES)];
+	unsigned int		hr_region_num;
+
+	struct dentry		*hr_debug_dir;
+	struct dentry		*hr_debug_livenodes;
+	struct dentry		*hr_debug_regnum;
+	struct dentry		*hr_debug_elapsed_time;
+	struct dentry		*hr_debug_pinned;
+	struct o2hb_debug_buf	*hr_db_livenodes;
+	struct o2hb_debug_buf	*hr_db_regnum;
+	struct o2hb_debug_buf	*hr_db_elapsed_time;
+	struct o2hb_debug_buf	*hr_db_pinned;
+
+	/* let the person setting up hb wait for it to return until it
+	 * has reached a 'steady' state.  This will be fixed when we have
+	 * a more complete api that doesn't lead to this sort of fragility. */
+	atomic_t		hr_steady_iterations;
+
+	/* terminate o2hb thread if it does not reach steady state
+	 * (hr_steady_iterations == 0) within hr_unsteady_iterations */
+	atomic_t		hr_unsteady_iterations;
+
+	char			hr_dev_name[BDEVNAME_SIZE];
+
+	unsigned int		hr_timeout_ms;
+
+	/* randomized as the region goes up and down so that a node
+	 * recognizes a node going up and down in one iteration */
+	u64			hr_generation;
+
+	struct delayed_work	hr_write_timeout_work;
+	unsigned long		hr_last_timeout_start;
+
+	/* Used during o2hb_check_slot to hold a copy of the block
+	 * being checked because we temporarily have to zero out the
+	 * crc field. */
+	struct o2hb_disk_heartbeat_block *hr_tmp_block;
+};
+
+struct o2hb_bio_wait_ctxt {
+	atomic_t          wc_num_reqs;
+	struct completion wc_io_complete;
+	int               wc_error;
+};
+
+static int o2hb_pop_count(void *map, int count)
+{
+	int i = -1, pop = 0;
+
+	while ((i = find_next_bit(map, count, i + 1)) < count)
+		pop++;
+	return pop;
+}
+
+static void o2hb_write_timeout(struct work_struct *work)
+{
+	int failed, quorum;
+	unsigned long flags;
+	struct o2hb_region *reg =
+		container_of(work, struct o2hb_region,
+			     hr_write_timeout_work.work);
+
+	mlog(ML_ERROR, "Heartbeat write timeout to device %s after %u "
+	     "milliseconds\n", reg->hr_dev_name,
+	     jiffies_to_msecs(jiffies - reg->hr_last_timeout_start));
+
+	if (o2hb_global_heartbeat_active()) {
+		spin_lock_irqsave(&o2hb_live_lock, flags);
+		if (test_bit(reg->hr_region_num, o2hb_quorum_region_bitmap))
+			set_bit(reg->hr_region_num, o2hb_failed_region_bitmap);
+		failed = o2hb_pop_count(&o2hb_failed_region_bitmap,
+					O2NM_MAX_REGIONS);
+		quorum = o2hb_pop_count(&o2hb_quorum_region_bitmap,
+					O2NM_MAX_REGIONS);
+		spin_unlock_irqrestore(&o2hb_live_lock, flags);
+
+		mlog(ML_HEARTBEAT, "Number of regions %d, failed regions %d\n",
+		     quorum, failed);
+
+		/*
+		 * Fence if the number of failed regions >= half the number
+		 * of  quorum regions
+		 */
+		if ((failed << 1) < quorum)
+			return;
+	}
+
+	o2quo_disk_timeout();
+}
+
+static void o2hb_arm_write_timeout(struct o2hb_region *reg)
+{
+	/* Arm writeout only after thread reaches steady state */
+	if (atomic_read(&reg->hr_steady_iterations) != 0)
+		return;
+
+	mlog(ML_HEARTBEAT, "Queue write timeout for %u ms\n",
+	     O2HB_MAX_WRITE_TIMEOUT_MS);
+
+	if (o2hb_global_heartbeat_active()) {
+		spin_lock(&o2hb_live_lock);
+		clear_bit(reg->hr_region_num, o2hb_failed_region_bitmap);
+		spin_unlock(&o2hb_live_lock);
+	}
+	cancel_delayed_work(&reg->hr_write_timeout_work);
+	reg->hr_last_timeout_start = jiffies;
+	schedule_delayed_work(&reg->hr_write_timeout_work,
+			      msecs_to_jiffies(O2HB_MAX_WRITE_TIMEOUT_MS));
+}
+
+static void o2hb_disarm_write_timeout(struct o2hb_region *reg)
+{
+	cancel_delayed_work_sync(&reg->hr_write_timeout_work);
+}
+
+static inline void o2hb_bio_wait_init(struct o2hb_bio_wait_ctxt *wc)
+{
+	atomic_set(&wc->wc_num_reqs, 1);
+	init_completion(&wc->wc_io_complete);
+	wc->wc_error = 0;
+}
+
+/* Used in error paths too */
+static inline void o2hb_bio_wait_dec(struct o2hb_bio_wait_ctxt *wc,
+				     unsigned int num)
+{
+	/* sadly atomic_sub_and_test() isn't available on all platforms.  The
+	 * good news is that the fast path only completes one at a time */
+	while(num--) {
+		if (atomic_dec_and_test(&wc->wc_num_reqs)) {
+			BUG_ON(num > 0);
+			complete(&wc->wc_io_complete);
+		}
+	}
+}
+
+static void o2hb_wait_on_io(struct o2hb_region *reg,
+			    struct o2hb_bio_wait_ctxt *wc)
+{
+	o2hb_bio_wait_dec(wc, 1);
+	wait_for_completion(&wc->wc_io_complete);
+}
+
+static void o2hb_bio_end_io(struct bio *bio,
+			   int error)
+{
+	struct o2hb_bio_wait_ctxt *wc = bio->bi_private;
+
+	if (error) {
+		mlog(ML_ERROR, "IO Error %d\n", error);
+		wc->wc_error = error;
+	}
+
+	o2hb_bio_wait_dec(wc, 1);
+	bio_put(bio);
+}
+
+/* Setup a Bio to cover I/O against num_slots slots starting at
+ * start_slot. */
+static struct bio *o2hb_setup_one_bio(struct o2hb_region *reg,
+				      struct o2hb_bio_wait_ctxt *wc,
+				      unsigned int *current_slot,
+				      unsigned int max_slots)
+{
+	int len, current_page;
+	unsigned int vec_len, vec_start;
+	unsigned int bits = reg->hr_block_bits;
+	unsigned int spp = reg->hr_slots_per_page;
+	unsigned int cs = *current_slot;
+	struct bio *bio;
+	struct page *page;
+
+	/* Testing has shown this allocation to take long enough under
+	 * GFP_KERNEL that the local node can get fenced. It would be
+	 * nicest if we could pre-allocate these bios and avoid this
+	 * all together. */
+	bio = bio_alloc(GFP_ATOMIC, 16);
+	if (!bio) {
+		mlog(ML_ERROR, "Could not alloc slots BIO!\n");
+		bio = ERR_PTR(-ENOMEM);
+		goto bail;
+	}
+
+	/* Must put everything in 512 byte sectors for the bio... */
+	bio->bi_sector = (reg->hr_start_block + cs) << (bits - 9);
+	bio->bi_bdev = reg->hr_bdev;
+	bio->bi_private = wc;
+	bio->bi_end_io = o2hb_bio_end_io;
+
+	vec_start = (cs << bits) % PAGE_CACHE_SIZE;
+	while(cs < max_slots) {
+		current_page = cs / spp;
+		page = reg->hr_slot_data[current_page];
+
+		vec_len = min(PAGE_CACHE_SIZE - vec_start,
+			      (max_slots-cs) * (PAGE_CACHE_SIZE/spp) );
+
+		mlog(ML_HB_BIO, "page %d, vec_len = %u, vec_start = %u\n",
+		     current_page, vec_len, vec_start);
+
+		len = bio_add_page(bio, page, vec_len, vec_start);
+		if (len != vec_len) break;
+
+		cs += vec_len / (PAGE_CACHE_SIZE/spp);
+		vec_start = 0;
+	}
+
+bail:
+	*current_slot = cs;
+	return bio;
+}
+
+static int o2hb_read_slots(struct o2hb_region *reg,
+			   unsigned int max_slots)
+{
+	unsigned int current_slot=0;
+	int status;
+	struct o2hb_bio_wait_ctxt wc;
+	struct bio *bio;
+
+	o2hb_bio_wait_init(&wc);
+
+	while(current_slot < max_slots) {
+		bio = o2hb_setup_one_bio(reg, &wc, &current_slot, max_slots);
+		if (IS_ERR(bio)) {
+			status = PTR_ERR(bio);
+			mlog_errno(status);
+			goto bail_and_wait;
+		}
+
+		atomic_inc(&wc.wc_num_reqs);
+		submit_bio(READ, bio);
+	}
+
+	status = 0;
+
+bail_and_wait:
+	o2hb_wait_on_io(reg, &wc);
+	if (wc.wc_error && !status)
+		status = wc.wc_error;
+
+	return status;
+}
+
+static int o2hb_issue_node_write(struct o2hb_region *reg,
+				 struct o2hb_bio_wait_ctxt *write_wc)
+{
+	int status;
+	unsigned int slot;
+	struct bio *bio;
+
+	o2hb_bio_wait_init(write_wc);
+
+	slot = o2nm_this_node();
+
+	bio = o2hb_setup_one_bio(reg, write_wc, &slot, slot+1);
+	if (IS_ERR(bio)) {
+		status = PTR_ERR(bio);
+		mlog_errno(status);
+		goto bail;
+	}
+
+	atomic_inc(&write_wc->wc_num_reqs);
+	submit_bio(WRITE, bio);
+
+	status = 0;
+bail:
+	return status;
+}
+
+static u32 o2hb_compute_block_crc_le(struct o2hb_region *reg,
+				     struct o2hb_disk_heartbeat_block *hb_block)
+{
+	__le32 old_cksum;
+	u32 ret;
+
+	/* We want to compute the block crc with a 0 value in the
+	 * hb_cksum field. Save it off here and replace after the
+	 * crc. */
+	old_cksum = hb_block->hb_cksum;
+	hb_block->hb_cksum = 0;
+
+	ret = crc32_le(0, (unsigned char *) hb_block, reg->hr_block_bytes);
+
+	hb_block->hb_cksum = old_cksum;
+
+	return ret;
+}
+
+static void o2hb_dump_slot(struct o2hb_disk_heartbeat_block *hb_block)
+{
+	mlog(ML_ERROR, "Dump slot information: seq = 0x%llx, node = %u, "
+	     "cksum = 0x%x, generation 0x%llx\n",
+	     (long long)le64_to_cpu(hb_block->hb_seq),
+	     hb_block->hb_node, le32_to_cpu(hb_block->hb_cksum),
+	     (long long)le64_to_cpu(hb_block->hb_generation));
+}
+
+static int o2hb_verify_crc(struct o2hb_region *reg,
+			   struct o2hb_disk_heartbeat_block *hb_block)
+{
+	u32 read, computed;
+
+	read = le32_to_cpu(hb_block->hb_cksum);
+	computed = o2hb_compute_block_crc_le(reg, hb_block);
+
+	return read == computed;
+}
+
+/*
+ * Compare the slot data with what we wrote in the last iteration.
+ * If the match fails, print an appropriate error message. This is to
+ * detect errors like... another node hearting on the same slot,
+ * flaky device that is losing writes, etc.
+ * Returns 1 if check succeeds, 0 otherwise.
+ */
+static int o2hb_check_own_slot(struct o2hb_region *reg)
+{
+	struct o2hb_disk_slot *slot;
+	struct o2hb_disk_heartbeat_block *hb_block;
+	char *errstr;
+
+	slot = &reg->hr_slots[o2nm_this_node()];
+	/* Don't check on our 1st timestamp */
+	if (!slot->ds_last_time)
+		return 0;
+
+	hb_block = slot->ds_raw_block;
+	if (le64_to_cpu(hb_block->hb_seq) == slot->ds_last_time &&
+	    le64_to_cpu(hb_block->hb_generation) == slot->ds_last_generation &&
+	    hb_block->hb_node == slot->ds_node_num)
+		return 1;
+
+#define ERRSTR1		"Another node is heartbeating on device"
+#define ERRSTR2		"Heartbeat generation mismatch on device"
+#define ERRSTR3		"Heartbeat sequence mismatch on device"
+
+	if (hb_block->hb_node != slot->ds_node_num)
+		errstr = ERRSTR1;
+	else if (le64_to_cpu(hb_block->hb_generation) !=
+		 slot->ds_last_generation)
+		errstr = ERRSTR2;
+	else
+		errstr = ERRSTR3;
+
+	mlog(ML_ERROR, "%s (%s): expected(%u:0x%llx, 0x%llx), "
+	     "ondisk(%u:0x%llx, 0x%llx)\n", errstr, reg->hr_dev_name,
+	     slot->ds_node_num, (unsigned long long)slot->ds_last_generation,
+	     (unsigned long long)slot->ds_last_time, hb_block->hb_node,
+	     (unsigned long long)le64_to_cpu(hb_block->hb_generation),
+	     (unsigned long long)le64_to_cpu(hb_block->hb_seq));
+
+	return 0;
+}
+
+static inline void o2hb_prepare_block(struct o2hb_region *reg,
+				      u64 generation)
+{
+	int node_num;
+	u64 cputime;
+	struct o2hb_disk_slot *slot;
+	struct o2hb_disk_heartbeat_block *hb_block;
+
+	node_num = o2nm_this_node();
+	slot = &reg->hr_slots[node_num];
+
+	hb_block = (struct o2hb_disk_heartbeat_block *)slot->ds_raw_block;
+	memset(hb_block, 0, reg->hr_block_bytes);
+	/* TODO: time stuff */
+	cputime = CURRENT_TIME.tv_sec;
+	if (!cputime)
+		cputime = 1;
+
+	hb_block->hb_seq = cpu_to_le64(cputime);
+	hb_block->hb_node = node_num;
+	hb_block->hb_generation = cpu_to_le64(generation);
+	hb_block->hb_dead_ms = cpu_to_le32(o2hb_dead_threshold * O2HB_REGION_TIMEOUT_MS);
+
+	/* This step must always happen last! */
+	hb_block->hb_cksum = cpu_to_le32(o2hb_compute_block_crc_le(reg,
+								   hb_block));
+
+	mlog(ML_HB_BIO, "our node generation = 0x%llx, cksum = 0x%x\n",
+	     (long long)generation,
+	     le32_to_cpu(hb_block->hb_cksum));
+}
+
+static void o2hb_fire_callbacks(struct o2hb_callback *hbcall,
+				struct o2nm_node *node,
+				int idx)
+{
+	struct list_head *iter;
+	struct o2hb_callback_func *f;
+
+	list_for_each(iter, &hbcall->list) {
+		f = list_entry(iter, struct o2hb_callback_func, hc_item);
+		mlog(ML_HEARTBEAT, "calling funcs %p\n", f);
+		(f->hc_func)(node, idx, f->hc_data);
+	}
+}
+
+/* Will run the list in order until we process the passed event */
+static void o2hb_run_event_list(struct o2hb_node_event *queued_event)
+{
+	int empty;
+	struct o2hb_callback *hbcall;
+	struct o2hb_node_event *event;
+
+	spin_lock(&o2hb_live_lock);
+	empty = list_empty(&queued_event->hn_item);
+	spin_unlock(&o2hb_live_lock);
+	if (empty)
+		return;
+
+	/* Holding callback sem assures we don't alter the callback
+	 * lists when doing this, and serializes ourselves with other
+	 * processes wanting callbacks. */
+	down_write(&o2hb_callback_sem);
+
+	spin_lock(&o2hb_live_lock);
+	while (!list_empty(&o2hb_node_events)
+	       && !list_empty(&queued_event->hn_item)) {
+		event = list_entry(o2hb_node_events.next,
+				   struct o2hb_node_event,
+				   hn_item);
+		list_del_init(&event->hn_item);
+		spin_unlock(&o2hb_live_lock);
+
+		mlog(ML_HEARTBEAT, "Node %s event for %d\n",
+		     event->hn_event_type == O2HB_NODE_UP_CB ? "UP" : "DOWN",
+		     event->hn_node_num);
+
+		hbcall = hbcall_from_type(event->hn_event_type);
+
+		/* We should *never* have gotten on to the list with a
+		 * bad type... This isn't something that we should try
+		 * to recover from. */
+		BUG_ON(IS_ERR(hbcall));
+
+		o2hb_fire_callbacks(hbcall, event->hn_node, event->hn_node_num);
+
+		spin_lock(&o2hb_live_lock);
+	}
+	spin_unlock(&o2hb_live_lock);
+
+	up_write(&o2hb_callback_sem);
+}
+
+static void o2hb_queue_node_event(struct o2hb_node_event *event,
+				  enum o2hb_callback_type type,
+				  struct o2nm_node *node,
+				  int node_num)
+{
+	assert_spin_locked(&o2hb_live_lock);
+
+	BUG_ON((!node) && (type != O2HB_NODE_DOWN_CB));
+
+	event->hn_event_type = type;
+	event->hn_node = node;
+	event->hn_node_num = node_num;
+
+	mlog(ML_HEARTBEAT, "Queue node %s event for node %d\n",
+	     type == O2HB_NODE_UP_CB ? "UP" : "DOWN", node_num);
+
+	list_add_tail(&event->hn_item, &o2hb_node_events);
+}
+
+static void o2hb_shutdown_slot(struct o2hb_disk_slot *slot)
+{
+	struct o2hb_node_event event =
+		{ .hn_item = LIST_HEAD_INIT(event.hn_item), };
+	struct o2nm_node *node;
+
+	node = o2nm_get_node_by_num(slot->ds_node_num);
+	if (!node)
+		return;
+
+	spin_lock(&o2hb_live_lock);
+	if (!list_empty(&slot->ds_live_item)) {
+		mlog(ML_HEARTBEAT, "Shutdown, node %d leaves region\n",
+		     slot->ds_node_num);
+
+		list_del_init(&slot->ds_live_item);
+
+		if (list_empty(&o2hb_live_slots[slot->ds_node_num])) {
+			clear_bit(slot->ds_node_num, o2hb_live_node_bitmap);
+
+			o2hb_queue_node_event(&event, O2HB_NODE_DOWN_CB, node,
+					      slot->ds_node_num);
+		}
+	}
+	spin_unlock(&o2hb_live_lock);
+
+	o2hb_run_event_list(&event);
+
+	o2nm_node_put(node);
+}
+
+static void o2hb_set_quorum_device(struct o2hb_region *reg)
+{
+	if (!o2hb_global_heartbeat_active())
+		return;
+
+	/* Prevent race with o2hb_heartbeat_group_drop_item() */
+	if (kthread_should_stop())
+		return;
+
+	/* Tag region as quorum only after thread reaches steady state */
+	if (atomic_read(&reg->hr_steady_iterations) != 0)
+		return;
+
+	spin_lock(&o2hb_live_lock);
+
+	if (test_bit(reg->hr_region_num, o2hb_quorum_region_bitmap))
+		goto unlock;
+
+	/*
+	 * A region can be added to the quorum only when it sees all
+	 * live nodes heartbeat on it. In other words, the region has been
+	 * added to all nodes.
+	 */
+	if (memcmp(reg->hr_live_node_bitmap, o2hb_live_node_bitmap,
+		   sizeof(o2hb_live_node_bitmap)))
+		goto unlock;
+
+	printk(KERN_NOTICE "o2hb: Region %s (%s) is now a quorum device\n",
+	       config_item_name(&reg->hr_item), reg->hr_dev_name);
+
+	set_bit(reg->hr_region_num, o2hb_quorum_region_bitmap);
+
+	/*
+	 * If global heartbeat active, unpin all regions if the
+	 * region count > CUT_OFF
+	 */
+	if (o2hb_pop_count(&o2hb_quorum_region_bitmap,
+			   O2NM_MAX_REGIONS) > O2HB_PIN_CUT_OFF)
+		o2hb_region_unpin(NULL);
+unlock:
+	spin_unlock(&o2hb_live_lock);
+}
+
+static int o2hb_check_slot(struct o2hb_region *reg,
+			   struct o2hb_disk_slot *slot)
+{
+	int changed = 0, gen_changed = 0;
+	struct o2hb_node_event event =
+		{ .hn_item = LIST_HEAD_INIT(event.hn_item), };
+	struct o2nm_node *node;
+	struct o2hb_disk_heartbeat_block *hb_block = reg->hr_tmp_block;
+	u64 cputime;
+	unsigned int dead_ms = o2hb_dead_threshold * O2HB_REGION_TIMEOUT_MS;
+	unsigned int slot_dead_ms;
+	int tmp;
+
+	memcpy(hb_block, slot->ds_raw_block, reg->hr_block_bytes);
+
+	/*
+	 * If a node is no longer configured but is still in the livemap, we
+	 * may need to clear that bit from the livemap.
+	 */
+	node = o2nm_get_node_by_num(slot->ds_node_num);
+	if (!node) {
+		spin_lock(&o2hb_live_lock);
+		tmp = test_bit(slot->ds_node_num, o2hb_live_node_bitmap);
+		spin_unlock(&o2hb_live_lock);
+		if (!tmp)
+			return 0;
+	}
+
+	if (!o2hb_verify_crc(reg, hb_block)) {
+		/* all paths from here will drop o2hb_live_lock for
+		 * us. */
+		spin_lock(&o2hb_live_lock);
+
+		/* Don't print an error on the console in this case -
+		 * a freshly formatted heartbeat area will not have a
+		 * crc set on it. */
+		if (list_empty(&slot->ds_live_item))
+			goto out;
+
+		/* The node is live but pushed out a bad crc. We
+		 * consider it a transient miss but don't populate any
+		 * other values as they may be junk. */
+		mlog(ML_ERROR, "Node %d has written a bad crc to %s\n",
+		     slot->ds_node_num, reg->hr_dev_name);
+		o2hb_dump_slot(hb_block);
+
+		slot->ds_equal_samples++;
+		goto fire_callbacks;
+	}
+
+	/* we don't care if these wrap.. the state transitions below
+	 * clear at the right places */
+	cputime = le64_to_cpu(hb_block->hb_seq);
+	if (slot->ds_last_time != cputime)
+		slot->ds_changed_samples++;
+	else
+		slot->ds_equal_samples++;
+	slot->ds_last_time = cputime;
+
+	/* The node changed heartbeat generations. We assume this to
+	 * mean it dropped off but came back before we timed out. We
+	 * want to consider it down for the time being but don't want
+	 * to lose any changed_samples state we might build up to
+	 * considering it live again. */
+	if (slot->ds_last_generation != le64_to_cpu(hb_block->hb_generation)) {
+		gen_changed = 1;
+		slot->ds_equal_samples = 0;
+		mlog(ML_HEARTBEAT, "Node %d changed generation (0x%llx "
+		     "to 0x%llx)\n", slot->ds_node_num,
+		     (long long)slot->ds_last_generation,
+		     (long long)le64_to_cpu(hb_block->hb_generation));
+	}
+
+	slot->ds_last_generation = le64_to_cpu(hb_block->hb_generation);
+
+	mlog(ML_HEARTBEAT, "Slot %d gen 0x%llx cksum 0x%x "
+	     "seq %llu last %llu changed %u equal %u\n",
+	     slot->ds_node_num, (long long)slot->ds_last_generation,
+	     le32_to_cpu(hb_block->hb_cksum),
+	     (unsigned long long)le64_to_cpu(hb_block->hb_seq),
+	     (unsigned long long)slot->ds_last_time, slot->ds_changed_samples,
+	     slot->ds_equal_samples);
+
+	spin_lock(&o2hb_live_lock);
+
+fire_callbacks:
+	/* dead nodes only come to life after some number of
+	 * changes at any time during their dead time */
+	if (list_empty(&slot->ds_live_item) &&
+	    slot->ds_changed_samples >= O2HB_LIVE_THRESHOLD) {
+		mlog(ML_HEARTBEAT, "Node %d (id 0x%llx) joined my region\n",
+		     slot->ds_node_num, (long long)slot->ds_last_generation);
+
+		set_bit(slot->ds_node_num, reg->hr_live_node_bitmap);
+
+		/* first on the list generates a callback */
+		if (list_empty(&o2hb_live_slots[slot->ds_node_num])) {
+			mlog(ML_HEARTBEAT, "o2hb: Add node %d to live nodes "
+			     "bitmap\n", slot->ds_node_num);
+			set_bit(slot->ds_node_num, o2hb_live_node_bitmap);
+
+			o2hb_queue_node_event(&event, O2HB_NODE_UP_CB, node,
+					      slot->ds_node_num);
+
+			changed = 1;
+		}
+
+		list_add_tail(&slot->ds_live_item,
+			      &o2hb_live_slots[slot->ds_node_num]);
+
+		slot->ds_equal_samples = 0;
+
+		/* We want to be sure that all nodes agree on the
+		 * number of milliseconds before a node will be
+		 * considered dead. The self-fencing timeout is
+		 * computed from this value, and a discrepancy might
+		 * result in heartbeat calling a node dead when it
+		 * hasn't self-fenced yet. */
+		slot_dead_ms = le32_to_cpu(hb_block->hb_dead_ms);
+		if (slot_dead_ms && slot_dead_ms != dead_ms) {
+			/* TODO: Perhaps we can fail the region here. */
+			mlog(ML_ERROR, "Node %d on device %s has a dead count "
+			     "of %u ms, but our count is %u ms.\n"
+			     "Please double check your configuration values "
+			     "for 'O2CB_HEARTBEAT_THRESHOLD'\n",
+			     slot->ds_node_num, reg->hr_dev_name, slot_dead_ms,
+			     dead_ms);
+		}
+		goto out;
+	}
+
+	/* if the list is dead, we're done.. */
+	if (list_empty(&slot->ds_live_item))
+		goto out;
+
+	/* live nodes only go dead after enough consequtive missed
+	 * samples..  reset the missed counter whenever we see
+	 * activity */
+	if (slot->ds_equal_samples >= o2hb_dead_threshold || gen_changed) {
+		mlog(ML_HEARTBEAT, "Node %d left my region\n",
+		     slot->ds_node_num);
+
+		clear_bit(slot->ds_node_num, reg->hr_live_node_bitmap);
+
+		/* last off the live_slot generates a callback */
+		list_del_init(&slot->ds_live_item);
+		if (list_empty(&o2hb_live_slots[slot->ds_node_num])) {
+			mlog(ML_HEARTBEAT, "o2hb: Remove node %d from live "
+			     "nodes bitmap\n", slot->ds_node_num);
+			clear_bit(slot->ds_node_num, o2hb_live_node_bitmap);
+
+			/* node can be null */
+			o2hb_queue_node_event(&event, O2HB_NODE_DOWN_CB,
+					      node, slot->ds_node_num);
+
+			changed = 1;
+		}
+
+		/* We don't clear this because the node is still
+		 * actually writing new blocks. */
+		if (!gen_changed)
+			slot->ds_changed_samples = 0;
+		goto out;
+	}
+	if (slot->ds_changed_samples) {
+		slot->ds_changed_samples = 0;
+		slot->ds_equal_samples = 0;
+	}
+out:
+	spin_unlock(&o2hb_live_lock);
+
+	o2hb_run_event_list(&event);
+
+	if (node)
+		o2nm_node_put(node);
+	return changed;
+}
+
+/* This could be faster if we just implmented a find_last_bit, but I
+ * don't think the circumstances warrant it. */
+static int o2hb_highest_node(unsigned long *nodes,
+			     int numbits)
+{
+	int highest, node;
+
+	highest = numbits;
+	node = -1;
+	while ((node = find_next_bit(nodes, numbits, node + 1)) != -1) {
+		if (node >= numbits)
+			break;
+
+		highest = node;
+	}
+
+	return highest;
+}
+
+static int o2hb_do_disk_heartbeat(struct o2hb_region *reg)
+{
+	int i, ret, highest_node;
+	int membership_change = 0, own_slot_ok = 0;
+	unsigned long configured_nodes[BITS_TO_LONGS(O2NM_MAX_NODES)];
+	unsigned long live_node_bitmap[BITS_TO_LONGS(O2NM_MAX_NODES)];
+	struct o2hb_bio_wait_ctxt write_wc;
+
+	ret = o2nm_configured_node_map(configured_nodes,
+				       sizeof(configured_nodes));
+	if (ret) {
+		mlog_errno(ret);
+		goto bail;
+	}
+
+	/*
+	 * If a node is not configured but is in the livemap, we still need
+	 * to read the slot so as to be able to remove it from the livemap.
+	 */
+	o2hb_fill_node_map(live_node_bitmap, sizeof(live_node_bitmap));
+	i = -1;
+	while ((i = find_next_bit(live_node_bitmap,
+				  O2NM_MAX_NODES, i + 1)) < O2NM_MAX_NODES) {
+		set_bit(i, configured_nodes);
+	}
+
+	highest_node = o2hb_highest_node(configured_nodes, O2NM_MAX_NODES);
+	if (highest_node >= O2NM_MAX_NODES) {
+		mlog(ML_NOTICE, "o2hb: No configured nodes found!\n");
+		ret = -EINVAL;
+		goto bail;
+	}
+
+	/* No sense in reading the slots of nodes that don't exist
+	 * yet. Of course, if the node definitions have holes in them
+	 * then we're reading an empty slot anyway... Consider this
+	 * best-effort. */
+	ret = o2hb_read_slots(reg, highest_node + 1);
+	if (ret < 0) {
+		mlog_errno(ret);
+		goto bail;
+	}
+
+	/* With an up to date view of the slots, we can check that no
+	 * other node has been improperly configured to heartbeat in
+	 * our slot. */
+	own_slot_ok = o2hb_check_own_slot(reg);
+
+	/* fill in the proper info for our next heartbeat */
+	o2hb_prepare_block(reg, reg->hr_generation);
+
+	ret = o2hb_issue_node_write(reg, &write_wc);
+	if (ret < 0) {
+		mlog_errno(ret);
+		goto bail;
+	}
+
+	i = -1;
+	while((i = find_next_bit(configured_nodes,
+				 O2NM_MAX_NODES, i + 1)) < O2NM_MAX_NODES) {
+		membership_change |= o2hb_check_slot(reg, &reg->hr_slots[i]);
+	}
+
+	/*
+	 * We have to be sure we've advertised ourselves on disk
+	 * before we can go to steady state.  This ensures that
+	 * people we find in our steady state have seen us.
+	 */
+	o2hb_wait_on_io(reg, &write_wc);
+	if (write_wc.wc_error) {
+		/* Do not re-arm the write timeout on I/O error - we
+		 * can't be sure that the new block ever made it to
+		 * disk */
+		mlog(ML_ERROR, "Write error %d on device \"%s\"\n",
+		     write_wc.wc_error, reg->hr_dev_name);
+		ret = write_wc.wc_error;
+		goto bail;
+	}
+
+	/* Skip disarming the timeout if own slot has stale/bad data */
+	if (own_slot_ok) {
+		o2hb_set_quorum_device(reg);
+		o2hb_arm_write_timeout(reg);
+	}
+
+bail:
+	/* let the person who launched us know when things are steady */
+	if (atomic_read(&reg->hr_steady_iterations) != 0) {
+		if (!ret && own_slot_ok && !membership_change) {
+			if (atomic_dec_and_test(&reg->hr_steady_iterations))
+				wake_up(&o2hb_steady_queue);
+		}
+	}
+
+	if (atomic_read(&reg->hr_steady_iterations) != 0) {
+		if (atomic_dec_and_test(&reg->hr_unsteady_iterations)) {
+			printk(KERN_NOTICE "o2hb: Unable to stabilize "
+			       "heartbeart on region %s (%s)\n",
+			       config_item_name(&reg->hr_item),
+			       reg->hr_dev_name);
+			atomic_set(&reg->hr_steady_iterations, 0);
+			reg->hr_aborted_start = 1;
+			wake_up(&o2hb_steady_queue);
+			ret = -EIO;
+		}
+	}
+
+	return ret;
+}
+
+/* Subtract b from a, storing the result in a. a *must* have a larger
+ * value than b. */
+static void o2hb_tv_subtract(struct timeval *a,
+			     struct timeval *b)
+{
+	/* just return 0 when a is after b */
+	if (a->tv_sec < b->tv_sec ||
+	    (a->tv_sec == b->tv_sec && a->tv_usec < b->tv_usec)) {
+		a->tv_sec = 0;
+		a->tv_usec = 0;
+		return;
+	}
+
+	a->tv_sec -= b->tv_sec;
+	a->tv_usec -= b->tv_usec;
+	while ( a->tv_usec < 0 ) {
+		a->tv_sec--;
+		a->tv_usec += 1000000;
+	}
+}
+
+static unsigned int o2hb_elapsed_msecs(struct timeval *start,
+				       struct timeval *end)
+{
+	struct timeval res = *end;
+
+	o2hb_tv_subtract(&res, start);
+
+	return res.tv_sec * 1000 + res.tv_usec / 1000;
+}
+
+/*
+ * we ride the region ref that the region dir holds.  before the region
+ * dir is removed and drops it ref it will wait to tear down this
+ * thread.
+ */
+static int o2hb_thread(void *data)
+{
+	int i, ret;
+	struct o2hb_region *reg = data;
+	struct o2hb_bio_wait_ctxt write_wc;
+	struct timeval before_hb, after_hb;
+	unsigned int elapsed_msec;
+
+	mlog(ML_HEARTBEAT|ML_KTHREAD, "hb thread running\n");
+
+	set_user_nice(current, -20);
+
+	/* Pin node */
+	o2nm_depend_this_node();
+
+	while (!kthread_should_stop() &&
+	       !reg->hr_unclean_stop && !reg->hr_aborted_start) {
+		/* We track the time spent inside
+		 * o2hb_do_disk_heartbeat so that we avoid more than
+		 * hr_timeout_ms between disk writes. On busy systems
+		 * this should result in a heartbeat which is less
+		 * likely to time itself out. */
+		do_gettimeofday(&before_hb);
+
+		ret = o2hb_do_disk_heartbeat(reg);
+
+		do_gettimeofday(&after_hb);
+		elapsed_msec = o2hb_elapsed_msecs(&before_hb, &after_hb);
+
+		mlog(ML_HEARTBEAT,
+		     "start = %lu.%lu, end = %lu.%lu, msec = %u\n",
+		     before_hb.tv_sec, (unsigned long) before_hb.tv_usec,
+		     after_hb.tv_sec, (unsigned long) after_hb.tv_usec,
+		     elapsed_msec);
+
+		if (!kthread_should_stop() &&
+		    elapsed_msec < reg->hr_timeout_ms) {
+			/* the kthread api has blocked signals for us so no
+			 * need to record the return value. */
+			msleep_interruptible(reg->hr_timeout_ms - elapsed_msec);
+		}
+	}
+
+	o2hb_disarm_write_timeout(reg);
+
+	/* unclean stop is only used in very bad situation */
+	for(i = 0; !reg->hr_unclean_stop && i < reg->hr_blocks; i++)
+		o2hb_shutdown_slot(&reg->hr_slots[i]);
+
+	/* Explicit down notification - avoid forcing the other nodes
+	 * to timeout on this region when we could just as easily
+	 * write a clear generation - thus indicating to them that
+	 * this node has left this region.
+	 */
+	if (!reg->hr_unclean_stop && !reg->hr_aborted_start) {
+		o2hb_prepare_block(reg, 0);
+		ret = o2hb_issue_node_write(reg, &write_wc);
+		if (ret == 0)
+			o2hb_wait_on_io(reg, &write_wc);
+		else
+			mlog_errno(ret);
+	}
+
+	/* Unpin node */
+	o2nm_undepend_this_node();
+
+	mlog(ML_HEARTBEAT|ML_KTHREAD, "o2hb thread exiting\n");
+
+	return 0;
+}
+
+#ifdef CONFIG_DEBUG_FS
+static int o2hb_debug_open(struct inode *inode, struct file *file)
+{
+	struct o2hb_debug_buf *db = inode->i_private;
+	struct o2hb_region *reg;
+	unsigned long map[BITS_TO_LONGS(O2NM_MAX_NODES)];
+	unsigned long lts;
+	char *buf = NULL;
+	int i = -1;
+	int out = 0;
+
+	/* max_nodes should be the largest bitmap we pass here */
+	BUG_ON(sizeof(map) < db->db_size);
+
+	buf = kmalloc(PAGE_SIZE, GFP_KERNEL);
+	if (!buf)
+		goto bail;
+
+	switch (db->db_type) {
+	case O2HB_DB_TYPE_LIVENODES:
+	case O2HB_DB_TYPE_LIVEREGIONS:
+	case O2HB_DB_TYPE_QUORUMREGIONS:
+	case O2HB_DB_TYPE_FAILEDREGIONS:
+		spin_lock(&o2hb_live_lock);
+		memcpy(map, db->db_data, db->db_size);
+		spin_unlock(&o2hb_live_lock);
+		break;
+
+	case O2HB_DB_TYPE_REGION_LIVENODES:
+		spin_lock(&o2hb_live_lock);
+		reg = (struct o2hb_region *)db->db_data;
+		memcpy(map, reg->hr_live_node_bitmap, db->db_size);
+		spin_unlock(&o2hb_live_lock);
+		break;
+
+	case O2HB_DB_TYPE_REGION_NUMBER:
+		reg = (struct o2hb_region *)db->db_data;
+		out += snprintf(buf + out, PAGE_SIZE - out, "%d\n",
+				reg->hr_region_num);
+		goto done;
+
+	case O2HB_DB_TYPE_REGION_ELAPSED_TIME:
+		reg = (struct o2hb_region *)db->db_data;
+		lts = reg->hr_last_timeout_start;
+		/* If 0, it has never been set before */
+		if (lts)
+			lts = jiffies_to_msecs(jiffies - lts);
+		out += snprintf(buf + out, PAGE_SIZE - out, "%lu\n", lts);
+		goto done;
+
+	case O2HB_DB_TYPE_REGION_PINNED:
+		reg = (struct o2hb_region *)db->db_data;
+		out += snprintf(buf + out, PAGE_SIZE - out, "%u\n",
+				!!reg->hr_item_pinned);
+		goto done;
+
+	default:
+		goto done;
+	}
+
+	while ((i = find_next_bit(map, db->db_len, i + 1)) < db->db_len)
+		out += snprintf(buf + out, PAGE_SIZE - out, "%d ", i);
+	out += snprintf(buf + out, PAGE_SIZE - out, "\n");
+
+done:
+	i_size_write(inode, out);
+
+	file->private_data = buf;
+
+	return 0;
+bail:
+	return -ENOMEM;
+}
+
+static int o2hb_debug_release(struct inode *inode, struct file *file)
+{
+	kfree(file->private_data);
+	return 0;
+}
+
+static ssize_t o2hb_debug_read(struct file *file, char __user *buf,
+				 size_t nbytes, loff_t *ppos)
+{
+	return simple_read_from_buffer(buf, nbytes, ppos, file->private_data,
+				       i_size_read(file->f_mapping->host));
+}
+#else
+static int o2hb_debug_open(struct inode *inode, struct file *file)
+{
+	return 0;
+}
+static int o2hb_debug_release(struct inode *inode, struct file *file)
+{
+	return 0;
+}
+static ssize_t o2hb_debug_read(struct file *file, char __user *buf,
+			       size_t nbytes, loff_t *ppos)
+{
+	return 0;
+}
+#endif  /* CONFIG_DEBUG_FS */
+
+static const struct file_operations o2hb_debug_fops = {
+	.open =		o2hb_debug_open,
+	.release =	o2hb_debug_release,
+	.read =		o2hb_debug_read,
+	.llseek =	generic_file_llseek,
+};
+
+void o2hb_exit(void)
+{
+	kfree(o2hb_db_livenodes);
+	kfree(o2hb_db_liveregions);
+	kfree(o2hb_db_quorumregions);
+	kfree(o2hb_db_failedregions);
+	debugfs_remove(o2hb_debug_failedregions);
+	debugfs_remove(o2hb_debug_quorumregions);
+	debugfs_remove(o2hb_debug_liveregions);
+	debugfs_remove(o2hb_debug_livenodes);
+	debugfs_remove(o2hb_debug_dir);
+}
+
+static struct dentry *o2hb_debug_create(const char *name, struct dentry *dir,
+					struct o2hb_debug_buf **db, int db_len,
+					int type, int size, int len, void *data)
+{
+	*db = kmalloc(db_len, GFP_KERNEL);
+	if (!*db)
+		return NULL;
+
+	(*db)->db_type = type;
+	(*db)->db_size = size;
+	(*db)->db_len = len;
+	(*db)->db_data = data;
+
+	return debugfs_create_file(name, S_IFREG|S_IRUSR, dir, *db,
+				   &o2hb_debug_fops);
+}
+
+static int o2hb_debug_init(void)
+{
+	int ret = -ENOMEM;
+
+	o2hb_debug_dir = debugfs_create_dir(O2HB_DEBUG_DIR, NULL);
+	if (!o2hb_debug_dir) {
+		mlog_errno(ret);
+		goto bail;
+	}
+
+	o2hb_debug_livenodes = o2hb_debug_create(O2HB_DEBUG_LIVENODES,
+						 o2hb_debug_dir,
+						 &o2hb_db_livenodes,
+						 sizeof(*o2hb_db_livenodes),
+						 O2HB_DB_TYPE_LIVENODES,
+						 sizeof(o2hb_live_node_bitmap),
+						 O2NM_MAX_NODES,
+						 o2hb_live_node_bitmap);
+	if (!o2hb_debug_livenodes) {
+		mlog_errno(ret);
+		goto bail;
+	}
+
+	o2hb_debug_liveregions = o2hb_debug_create(O2HB_DEBUG_LIVEREGIONS,
+						   o2hb_debug_dir,
+						   &o2hb_db_liveregions,
+						   sizeof(*o2hb_db_liveregions),
+						   O2HB_DB_TYPE_LIVEREGIONS,
+						   sizeof(o2hb_live_region_bitmap),
+						   O2NM_MAX_REGIONS,
+						   o2hb_live_region_bitmap);
+	if (!o2hb_debug_liveregions) {
+		mlog_errno(ret);
+		goto bail;
+	}
+
+	o2hb_debug_quorumregions =
+			o2hb_debug_create(O2HB_DEBUG_QUORUMREGIONS,
+					  o2hb_debug_dir,
+					  &o2hb_db_quorumregions,
+					  sizeof(*o2hb_db_quorumregions),
+					  O2HB_DB_TYPE_QUORUMREGIONS,
+					  sizeof(o2hb_quorum_region_bitmap),
+					  O2NM_MAX_REGIONS,
+					  o2hb_quorum_region_bitmap);
+	if (!o2hb_debug_quorumregions) {
+		mlog_errno(ret);
+		goto bail;
+	}
+
+	o2hb_debug_failedregions =
+			o2hb_debug_create(O2HB_DEBUG_FAILEDREGIONS,
+					  o2hb_debug_dir,
+					  &o2hb_db_failedregions,
+					  sizeof(*o2hb_db_failedregions),
+					  O2HB_DB_TYPE_FAILEDREGIONS,
+					  sizeof(o2hb_failed_region_bitmap),
+					  O2NM_MAX_REGIONS,
+					  o2hb_failed_region_bitmap);
+	if (!o2hb_debug_failedregions) {
+		mlog_errno(ret);
+		goto bail;
+	}
+
+	ret = 0;
+bail:
+	if (ret)
+		o2hb_exit();
+
+	return ret;
+}
+
+int o2hb_init(void)
+{
+	int i;
+
+	for (i = 0; i < ARRAY_SIZE(o2hb_callbacks); i++)
+		INIT_LIST_HEAD(&o2hb_callbacks[i].list);
+
+	for (i = 0; i < ARRAY_SIZE(o2hb_live_slots); i++)
+		INIT_LIST_HEAD(&o2hb_live_slots[i]);
+
+	INIT_LIST_HEAD(&o2hb_node_events);
+
+	memset(o2hb_live_node_bitmap, 0, sizeof(o2hb_live_node_bitmap));
+	memset(o2hb_region_bitmap, 0, sizeof(o2hb_region_bitmap));
+	memset(o2hb_live_region_bitmap, 0, sizeof(o2hb_live_region_bitmap));
+	memset(o2hb_quorum_region_bitmap, 0, sizeof(o2hb_quorum_region_bitmap));
+	memset(o2hb_failed_region_bitmap, 0, sizeof(o2hb_failed_region_bitmap));
+
+	o2hb_dependent_users = 0;
+
+	return o2hb_debug_init();
+}
+
+/* if we're already in a callback then we're already serialized by the sem */
+static void o2hb_fill_node_map_from_callback(unsigned long *map,
+					     unsigned bytes)
+{
+	BUG_ON(bytes < (BITS_TO_LONGS(O2NM_MAX_NODES) * sizeof(unsigned long)));
+
+	memcpy(map, &o2hb_live_node_bitmap, bytes);
+}
+
+/*
+ * get a map of all nodes that are heartbeating in any regions
+ */
+void o2hb_fill_node_map(unsigned long *map, unsigned bytes)
+{
+	/* callers want to serialize this map and callbacks so that they
+	 * can trust that they don't miss nodes coming to the party */
+	down_read(&o2hb_callback_sem);
+	spin_lock(&o2hb_live_lock);
+	o2hb_fill_node_map_from_callback(map, bytes);
+	spin_unlock(&o2hb_live_lock);
+	up_read(&o2hb_callback_sem);
+}
+EXPORT_SYMBOL_GPL(o2hb_fill_node_map);
+
+/*
+ * heartbeat configfs bits.  The heartbeat set is a default set under
+ * the cluster set in nodemanager.c.
+ */
+
+static struct o2hb_region *to_o2hb_region(struct config_item *item)
+{
+	return item ? container_of(item, struct o2hb_region, hr_item) : NULL;
+}
+
+/* drop_item only drops its ref after killing the thread, nothing should
+ * be using the region anymore.  this has to clean up any state that
+ * attributes might have built up. */
+static void o2hb_region_release(struct config_item *item)
+{
+	int i;
+	struct page *page;
+	struct o2hb_region *reg = to_o2hb_region(item);
+
+	mlog(ML_HEARTBEAT, "hb region release (%s)\n", reg->hr_dev_name);
+
+	if (reg->hr_tmp_block)
+		kfree(reg->hr_tmp_block);
+
+	if (reg->hr_slot_data) {
+		for (i = 0; i < reg->hr_num_pages; i++) {
+			page = reg->hr_slot_data[i];
+			if (page)
+				__free_page(page);
+		}
+		kfree(reg->hr_slot_data);
+	}
+
+	if (reg->hr_bdev)
+		blkdev_put(reg->hr_bdev, FMODE_READ|FMODE_WRITE);
+
+	if (reg->hr_slots)
+		kfree(reg->hr_slots);
+
+	kfree(reg->hr_db_regnum);
+	kfree(reg->hr_db_livenodes);
+	debugfs_remove(reg->hr_debug_livenodes);
+	debugfs_remove(reg->hr_debug_regnum);
+	debugfs_remove(reg->hr_debug_elapsed_time);
+	debugfs_remove(reg->hr_debug_pinned);
+	debugfs_remove(reg->hr_debug_dir);
+
+	spin_lock(&o2hb_live_lock);
+	list_del(&reg->hr_all_item);
+	spin_unlock(&o2hb_live_lock);
+
+	kfree(reg);
+}
+
+static int o2hb_read_block_input(struct o2hb_region *reg,
+				 const char *page,
+				 size_t count,
+				 unsigned long *ret_bytes,
+				 unsigned int *ret_bits)
+{
+	unsigned long bytes;
+	char *p = (char *)page;
+
+	bytes = simple_strtoul(p, &p, 0);
+	if (!p || (*p && (*p != '\n')))
+		return -EINVAL;
+
+	/* Heartbeat and fs min / max block sizes are the same. */
+	if (bytes > 4096 || bytes < 512)
+		return -ERANGE;
+	if (hweight16(bytes) != 1)
+		return -EINVAL;
+
+	if (ret_bytes)
+		*ret_bytes = bytes;
+	if (ret_bits)
+		*ret_bits = ffs(bytes) - 1;
+
+	return 0;
+}
+
+static ssize_t o2hb_region_block_bytes_read(struct o2hb_region *reg,
+					    char *page)
+{
+	return sprintf(page, "%u\n", reg->hr_block_bytes);
+}
+
+static ssize_t o2hb_region_block_bytes_write(struct o2hb_region *reg,
+					     const char *page,
+					     size_t count)
+{
+	int status;
+	unsigned long block_bytes;
+	unsigned int block_bits;
+
+	if (reg->hr_bdev)
+		return -EINVAL;
+
+	status = o2hb_read_block_input(reg, page, count,
+				       &block_bytes, &block_bits);
+	if (status)
+		return status;
+
+	reg->hr_block_bytes = (unsigned int)block_bytes;
+	reg->hr_block_bits = block_bits;
+
+	return count;
+}
+
+static ssize_t o2hb_region_start_block_read(struct o2hb_region *reg,
+					    char *page)
+{
+	return sprintf(page, "%llu\n", reg->hr_start_block);
+}
+
+static ssize_t o2hb_region_start_block_write(struct o2hb_region *reg,
+					     const char *page,
+					     size_t count)
+{
+	unsigned long long tmp;
+	char *p = (char *)page;
+
+	if (reg->hr_bdev)
+		return -EINVAL;
+
+	tmp = simple_strtoull(p, &p, 0);
+	if (!p || (*p && (*p != '\n')))
+		return -EINVAL;
+
+	reg->hr_start_block = tmp;
+
+	return count;
+}
+
+static ssize_t o2hb_region_blocks_read(struct o2hb_region *reg,
+				       char *page)
+{
+	return sprintf(page, "%d\n", reg->hr_blocks);
+}
+
+static ssize_t o2hb_region_blocks_write(struct o2hb_region *reg,
+					const char *page,
+					size_t count)
+{
+	unsigned long tmp;
+	char *p = (char *)page;
+
+	if (reg->hr_bdev)
+		return -EINVAL;
+
+	tmp = simple_strtoul(p, &p, 0);
+	if (!p || (*p && (*p != '\n')))
+		return -EINVAL;
+
+	if (tmp > O2NM_MAX_NODES || tmp == 0)
+		return -ERANGE;
+
+	reg->hr_blocks = (unsigned int)tmp;
+
+	return count;
+}
+
+static ssize_t o2hb_region_dev_read(struct o2hb_region *reg,
+				    char *page)
+{
+	unsigned int ret = 0;
+
+	if (reg->hr_bdev)
+		ret = sprintf(page, "%s\n", reg->hr_dev_name);
+
+	return ret;
+}
+
+static void o2hb_init_region_params(struct o2hb_region *reg)
+{
+	reg->hr_slots_per_page = PAGE_CACHE_SIZE >> reg->hr_block_bits;
+	reg->hr_timeout_ms = O2HB_REGION_TIMEOUT_MS;
+
+	mlog(ML_HEARTBEAT, "hr_start_block = %llu, hr_blocks = %u\n",
+	     reg->hr_start_block, reg->hr_blocks);
+	mlog(ML_HEARTBEAT, "hr_block_bytes = %u, hr_block_bits = %u\n",
+	     reg->hr_block_bytes, reg->hr_block_bits);
+	mlog(ML_HEARTBEAT, "hr_timeout_ms = %u\n", reg->hr_timeout_ms);
+	mlog(ML_HEARTBEAT, "dead threshold = %u\n", o2hb_dead_threshold);
+}
+
+static int o2hb_map_slot_data(struct o2hb_region *reg)
+{
+	int i, j;
+	unsigned int last_slot;
+	unsigned int spp = reg->hr_slots_per_page;
+	struct page *page;
+	char *raw;
+	struct o2hb_disk_slot *slot;
+
+	reg->hr_tmp_block = kmalloc(reg->hr_block_bytes, GFP_KERNEL);
+	if (reg->hr_tmp_block == NULL) {
+		mlog_errno(-ENOMEM);
+		return -ENOMEM;
+	}
+
+	reg->hr_slots = kcalloc(reg->hr_blocks,
+				sizeof(struct o2hb_disk_slot), GFP_KERNEL);
+	if (reg->hr_slots == NULL) {
+		mlog_errno(-ENOMEM);
+		return -ENOMEM;
+	}
+
+	for(i = 0; i < reg->hr_blocks; i++) {
+		slot = &reg->hr_slots[i];
+		slot->ds_node_num = i;
+		INIT_LIST_HEAD(&slot->ds_live_item);
+		slot->ds_raw_block = NULL;
+	}
+
+	reg->hr_num_pages = (reg->hr_blocks + spp - 1) / spp;
+	mlog(ML_HEARTBEAT, "Going to require %u pages to cover %u blocks "
+			   "at %u blocks per page\n",
+	     reg->hr_num_pages, reg->hr_blocks, spp);
+
+	reg->hr_slot_data = kcalloc(reg->hr_num_pages, sizeof(struct page *),
+				    GFP_KERNEL);
+	if (!reg->hr_slot_data) {
+		mlog_errno(-ENOMEM);
+		return -ENOMEM;
+	}
+
+	for(i = 0; i < reg->hr_num_pages; i++) {
+		page = alloc_page(GFP_KERNEL);
+		if (!page) {
+			mlog_errno(-ENOMEM);
+			return -ENOMEM;
+		}
+
+		reg->hr_slot_data[i] = page;
+
+		last_slot = i * spp;
+		raw = page_address(page);
+		for (j = 0;
+		     (j < spp) && ((j + last_slot) < reg->hr_blocks);
+		     j++) {
+			BUG_ON((j + last_slot) >= reg->hr_blocks);
+
+			slot = &reg->hr_slots[j + last_slot];
+			slot->ds_raw_block =
+				(struct o2hb_disk_heartbeat_block *) raw;
+
+			raw += reg->hr_block_bytes;
+		}
+	}
+
+	return 0;
+}
+
+/* Read in all the slots available and populate the tracking
+ * structures so that we can start with a baseline idea of what's
+ * there. */
+static int o2hb_populate_slot_data(struct o2hb_region *reg)
+{
+	int ret, i;
+	struct o2hb_disk_slot *slot;
+	struct o2hb_disk_heartbeat_block *hb_block;
+
+	ret = o2hb_read_slots(reg, reg->hr_blocks);
+	if (ret) {
+		mlog_errno(ret);
+		goto out;
+	}
+
+	/* We only want to get an idea of the values initially in each
+	 * slot, so we do no verification - o2hb_check_slot will
+	 * actually determine if each configured slot is valid and
+	 * whether any values have changed. */
+	for(i = 0; i < reg->hr_blocks; i++) {
+		slot = &reg->hr_slots[i];
+		hb_block = (struct o2hb_disk_heartbeat_block *) slot->ds_raw_block;
+
+		/* Only fill the values that o2hb_check_slot uses to
+		 * determine changing slots */
+		slot->ds_last_time = le64_to_cpu(hb_block->hb_seq);
+		slot->ds_last_generation = le64_to_cpu(hb_block->hb_generation);
+	}
+
+out:
+	return ret;
+}
+
+/* this is acting as commit; we set up all of hr_bdev and hr_task or nothing */
+static ssize_t o2hb_region_dev_write(struct o2hb_region *reg,
+				     const char *page,
+				     size_t count)
+{
+	struct task_struct *hb_task;
+	long fd;
+	int sectsize;
+	char *p = (char *)page;
+	struct file *filp = NULL;
+	struct inode *inode = NULL;
+	ssize_t ret = -EINVAL;
+	int live_threshold;
+
+	if (reg->hr_bdev)
+		goto out;
+
+	/* We can't heartbeat without having had our node number
+	 * configured yet. */
+	if (o2nm_this_node() == O2NM_MAX_NODES)
+		goto out;
+
+	fd = simple_strtol(p, &p, 0);
+	if (!p || (*p && (*p != '\n')))
+		goto out;
+
+	if (fd < 0 || fd >= INT_MAX)
+		goto out;
+
+	filp = fget(fd);
+	if (filp == NULL)
+		goto out;
+
+	if (reg->hr_blocks == 0 || reg->hr_start_block == 0 ||
+	    reg->hr_block_bytes == 0)
+		goto out;
+
+	inode = igrab(filp->f_mapping->host);
+	if (inode == NULL)
+		goto out;
+
+	if (!S_ISBLK(inode->i_mode))
+		goto out;
+
+	reg->hr_bdev = I_BDEV(filp->f_mapping->host);
+	ret = blkdev_get(reg->hr_bdev, FMODE_WRITE | FMODE_READ, NULL);
+	if (ret) {
+		reg->hr_bdev = NULL;
+		goto out;
+	}
+	inode = NULL;
+
+	bdevname(reg->hr_bdev, reg->hr_dev_name);
+
+	sectsize = bdev_logical_block_size(reg->hr_bdev);
+	if (sectsize != reg->hr_block_bytes) {
+		mlog(ML_ERROR,
+		     "blocksize %u incorrect for device, expected %d",
+		     reg->hr_block_bytes, sectsize);
+		ret = -EINVAL;
+		goto out;
+	}
+
+	o2hb_init_region_params(reg);
+
+	/* Generation of zero is invalid */
+	do {
+		get_random_bytes(&reg->hr_generation,
+				 sizeof(reg->hr_generation));
+	} while (reg->hr_generation == 0);
+
+	ret = o2hb_map_slot_data(reg);
+	if (ret) {
+		mlog_errno(ret);
+		goto out;
+	}
+
+	ret = o2hb_populate_slot_data(reg);
+	if (ret) {
+		mlog_errno(ret);
+		goto out;
+	}
+
+	INIT_DELAYED_WORK(&reg->hr_write_timeout_work, o2hb_write_timeout);
+
+	/*
+	 * A node is considered live after it has beat LIVE_THRESHOLD
+	 * times.  We're not steady until we've given them a chance
+	 * _after_ our first read.
+	 * The default threshold is bare minimum so as to limit the delay
+	 * during mounts. For global heartbeat, the threshold doubled for the
+	 * first region.
+	 */
+	live_threshold = O2HB_LIVE_THRESHOLD;
+	if (o2hb_global_heartbeat_active()) {
+		spin_lock(&o2hb_live_lock);
+		if (o2hb_pop_count(&o2hb_region_bitmap, O2NM_MAX_REGIONS) == 1)
+			live_threshold <<= 1;
+		spin_unlock(&o2hb_live_lock);
+	}
+	++live_threshold;
+	atomic_set(&reg->hr_steady_iterations, live_threshold);
+	/* unsteady_iterations is double the steady_iterations */
+	atomic_set(&reg->hr_unsteady_iterations, (live_threshold << 1));
+
+	hb_task = kthread_run(o2hb_thread, reg, "o2hb-%s",
+			      reg->hr_item.ci_name);
+	if (IS_ERR(hb_task)) {
+		ret = PTR_ERR(hb_task);
+		mlog_errno(ret);
+		goto out;
+	}
+
+	spin_lock(&o2hb_live_lock);
+	reg->hr_task = hb_task;
+	spin_unlock(&o2hb_live_lock);
+
+	ret = wait_event_interruptible(o2hb_steady_queue,
+				atomic_read(&reg->hr_steady_iterations) == 0);
+	if (ret) {
+		atomic_set(&reg->hr_steady_iterations, 0);
+		reg->hr_aborted_start = 1;
+	}
+
+	if (reg->hr_aborted_start) {
+		ret = -EIO;
+		goto out;
+	}
+
+	/* Ok, we were woken.  Make sure it wasn't by drop_item() */
+	spin_lock(&o2hb_live_lock);
+	hb_task = reg->hr_task;
+	if (o2hb_global_heartbeat_active())
+		set_bit(reg->hr_region_num, o2hb_live_region_bitmap);
+	spin_unlock(&o2hb_live_lock);
+
+	if (hb_task)
+		ret = count;
+	else
+		ret = -EIO;
+
+	if (hb_task && o2hb_global_heartbeat_active())
+		printk(KERN_NOTICE "o2hb: Heartbeat started on region %s (%s)\n",
+		       config_item_name(&reg->hr_item), reg->hr_dev_name);
+
+out:
+	if (filp)
+		fput(filp);
+	if (inode)
+		iput(inode);
+	if (ret < 0) {
+		if (reg->hr_bdev) {
+			blkdev_put(reg->hr_bdev, FMODE_READ|FMODE_WRITE);
+			reg->hr_bdev = NULL;
+		}
+	}
+	return ret;
+}
+
+static ssize_t o2hb_region_pid_read(struct o2hb_region *reg,
+                                      char *page)
+{
+	pid_t pid = 0;
+
+	spin_lock(&o2hb_live_lock);
+	if (reg->hr_task)
+		pid = task_pid_nr(reg->hr_task);
+	spin_unlock(&o2hb_live_lock);
+
+	if (!pid)
+		return 0;
+
+	return sprintf(page, "%u\n", pid);
+}
+
+struct o2hb_region_attribute {
+	struct configfs_attribute attr;
+	ssize_t (*show)(struct o2hb_region *, char *);
+	ssize_t (*store)(struct o2hb_region *, const char *, size_t);
+};
+
+static struct o2hb_region_attribute o2hb_region_attr_block_bytes = {
+	.attr	= { .ca_owner = THIS_MODULE,
+		    .ca_name = "block_bytes",
+		    .ca_mode = S_IRUGO | S_IWUSR },
+	.show	= o2hb_region_block_bytes_read,
+	.store	= o2hb_region_block_bytes_write,
+};
+
+static struct o2hb_region_attribute o2hb_region_attr_start_block = {
+	.attr	= { .ca_owner = THIS_MODULE,
+		    .ca_name = "start_block",
+		    .ca_mode = S_IRUGO | S_IWUSR },
+	.show	= o2hb_region_start_block_read,
+	.store	= o2hb_region_start_block_write,
+};
+
+static struct o2hb_region_attribute o2hb_region_attr_blocks = {
+	.attr	= { .ca_owner = THIS_MODULE,
+		    .ca_name = "blocks",
+		    .ca_mode = S_IRUGO | S_IWUSR },
+	.show	= o2hb_region_blocks_read,
+	.store	= o2hb_region_blocks_write,
+};
+
+static struct o2hb_region_attribute o2hb_region_attr_dev = {
+	.attr	= { .ca_owner = THIS_MODULE,
+		    .ca_name = "dev",
+		    .ca_mode = S_IRUGO | S_IWUSR },
+	.show	= o2hb_region_dev_read,
+	.store	= o2hb_region_dev_write,
+};
+
+static struct o2hb_region_attribute o2hb_region_attr_pid = {
+       .attr   = { .ca_owner = THIS_MODULE,
+                   .ca_name = "pid",
+                   .ca_mode = S_IRUGO | S_IRUSR },
+       .show   = o2hb_region_pid_read,
+};
+
+static struct configfs_attribute *o2hb_region_attrs[] = {
+	&o2hb_region_attr_block_bytes.attr,
+	&o2hb_region_attr_start_block.attr,
+	&o2hb_region_attr_blocks.attr,
+	&o2hb_region_attr_dev.attr,
+	&o2hb_region_attr_pid.attr,
+	NULL,
+};
+
+static ssize_t o2hb_region_show(struct config_item *item,
+				struct configfs_attribute *attr,
+				char *page)
+{
+	struct o2hb_region *reg = to_o2hb_region(item);
+	struct o2hb_region_attribute *o2hb_region_attr =
+		container_of(attr, struct o2hb_region_attribute, attr);
+	ssize_t ret = 0;
+
+	if (o2hb_region_attr->show)
+		ret = o2hb_region_attr->show(reg, page);
+	return ret;
+}
+
+static ssize_t o2hb_region_store(struct config_item *item,
+				 struct configfs_attribute *attr,
+				 const char *page, size_t count)
+{
+	struct o2hb_region *reg = to_o2hb_region(item);
+	struct o2hb_region_attribute *o2hb_region_attr =
+		container_of(attr, struct o2hb_region_attribute, attr);
+	ssize_t ret = -EINVAL;
+
+	if (o2hb_region_attr->store)
+		ret = o2hb_region_attr->store(reg, page, count);
+	return ret;
+}
+
+static struct configfs_item_operations o2hb_region_item_ops = {
+	.release		= o2hb_region_release,
+	.show_attribute		= o2hb_region_show,
+	.store_attribute	= o2hb_region_store,
+};
+
+static struct config_item_type o2hb_region_type = {
+	.ct_item_ops	= &o2hb_region_item_ops,
+	.ct_attrs	= o2hb_region_attrs,
+	.ct_owner	= THIS_MODULE,
+};
+
+/* heartbeat set */
+
+struct o2hb_heartbeat_group {
+	struct config_group hs_group;
+	/* some stuff? */
+};
+
+static struct o2hb_heartbeat_group *to_o2hb_heartbeat_group(struct config_group *group)
+{
+	return group ?
+		container_of(group, struct o2hb_heartbeat_group, hs_group)
+		: NULL;
+}
+
+static int o2hb_debug_region_init(struct o2hb_region *reg, struct dentry *dir)
+{
+	int ret = -ENOMEM;
+
+	reg->hr_debug_dir =
+		debugfs_create_dir(config_item_name(&reg->hr_item), dir);
+	if (!reg->hr_debug_dir) {
+		mlog_errno(ret);
+		goto bail;
+	}
+
+	reg->hr_debug_livenodes =
+			o2hb_debug_create(O2HB_DEBUG_LIVENODES,
+					  reg->hr_debug_dir,
+					  &(reg->hr_db_livenodes),
+					  sizeof(*(reg->hr_db_livenodes)),
+					  O2HB_DB_TYPE_REGION_LIVENODES,
+					  sizeof(reg->hr_live_node_bitmap),
+					  O2NM_MAX_NODES, reg);
+	if (!reg->hr_debug_livenodes) {
+		mlog_errno(ret);
+		goto bail;
+	}
+
+	reg->hr_debug_regnum =
+			o2hb_debug_create(O2HB_DEBUG_REGION_NUMBER,
+					  reg->hr_debug_dir,
+					  &(reg->hr_db_regnum),
+					  sizeof(*(reg->hr_db_regnum)),
+					  O2HB_DB_TYPE_REGION_NUMBER,
+					  0, O2NM_MAX_NODES, reg);
+	if (!reg->hr_debug_regnum) {
+		mlog_errno(ret);
+		goto bail;
+	}
+
+	reg->hr_debug_elapsed_time =
+			o2hb_debug_create(O2HB_DEBUG_REGION_ELAPSED_TIME,
+					  reg->hr_debug_dir,
+					  &(reg->hr_db_elapsed_time),
+					  sizeof(*(reg->hr_db_elapsed_time)),
+					  O2HB_DB_TYPE_REGION_ELAPSED_TIME,
+					  0, 0, reg);
+	if (!reg->hr_debug_elapsed_time) {
+		mlog_errno(ret);
+		goto bail;
+	}
+
+	reg->hr_debug_pinned =
+			o2hb_debug_create(O2HB_DEBUG_REGION_PINNED,
+					  reg->hr_debug_dir,
+					  &(reg->hr_db_pinned),
+					  sizeof(*(reg->hr_db_pinned)),
+					  O2HB_DB_TYPE_REGION_PINNED,
+					  0, 0, reg);
+	if (!reg->hr_debug_pinned) {
+		mlog_errno(ret);
+		goto bail;
+	}
+
+	ret = 0;
+bail:
+	return ret;
+}
+
+static struct config_item *o2hb_heartbeat_group_make_item(struct config_group *group,
+							  const char *name)
+{
+	struct o2hb_region *reg = NULL;
+	int ret;
+
+	reg = kzalloc(sizeof(struct o2hb_region), GFP_KERNEL);
+	if (reg == NULL)
+		return ERR_PTR(-ENOMEM);
+
+	if (strlen(name) > O2HB_MAX_REGION_NAME_LEN) {
+		ret = -ENAMETOOLONG;
+		goto free;
+	}
+
+	spin_lock(&o2hb_live_lock);
+	reg->hr_region_num = 0;
+	if (o2hb_global_heartbeat_active()) {
+		reg->hr_region_num = find_first_zero_bit(o2hb_region_bitmap,
+							 O2NM_MAX_REGIONS);
+		if (reg->hr_region_num >= O2NM_MAX_REGIONS) {
+			spin_unlock(&o2hb_live_lock);
+			ret = -EFBIG;
+			goto free;
+		}
+		set_bit(reg->hr_region_num, o2hb_region_bitmap);
+	}
+	list_add_tail(&reg->hr_all_item, &o2hb_all_regions);
+	spin_unlock(&o2hb_live_lock);
+
+	config_item_init_type_name(&reg->hr_item, name, &o2hb_region_type);
+
+	ret = o2hb_debug_region_init(reg, o2hb_debug_dir);
+	if (ret) {
+		config_item_put(&reg->hr_item);
+		goto free;
+	}
+
+	return &reg->hr_item;
+free:
+	kfree(reg);
+	return ERR_PTR(ret);
+}
+
+static void o2hb_heartbeat_group_drop_item(struct config_group *group,
+					   struct config_item *item)
+{
+	struct task_struct *hb_task;
+	struct o2hb_region *reg = to_o2hb_region(item);
+	int quorum_region = 0;
+
+	/* stop the thread when the user removes the region dir */
+	spin_lock(&o2hb_live_lock);
+	hb_task = reg->hr_task;
+	reg->hr_task = NULL;
+	reg->hr_item_dropped = 1;
+	spin_unlock(&o2hb_live_lock);
+
+	if (hb_task)
+		kthread_stop(hb_task);
+
+	if (o2hb_global_heartbeat_active()) {
+		spin_lock(&o2hb_live_lock);
+		clear_bit(reg->hr_region_num, o2hb_region_bitmap);
+		clear_bit(reg->hr_region_num, o2hb_live_region_bitmap);
+		if (test_bit(reg->hr_region_num, o2hb_quorum_region_bitmap))
+			quorum_region = 1;
+		clear_bit(reg->hr_region_num, o2hb_quorum_region_bitmap);
+		spin_unlock(&o2hb_live_lock);
+		printk(KERN_NOTICE "o2hb: Heartbeat %s on region %s (%s)\n",
+		       ((atomic_read(&reg->hr_steady_iterations) == 0) ?
+			"stopped" : "start aborted"), config_item_name(item),
+		       reg->hr_dev_name);
+	}
+
+	/*
+	 * If we're racing a dev_write(), we need to wake them.  They will
+	 * check reg->hr_task
+	 */
+	if (atomic_read(&reg->hr_steady_iterations) != 0) {
+		reg->hr_aborted_start = 1;
+		atomic_set(&reg->hr_steady_iterations, 0);
+		wake_up(&o2hb_steady_queue);
+	}
+
+	config_item_put(item);
+
+	if (!o2hb_global_heartbeat_active() || !quorum_region)
+		return;
+
+	/*
+	 * If global heartbeat active and there are dependent users,
+	 * pin all regions if quorum region count <= CUT_OFF
+	 */
+	spin_lock(&o2hb_live_lock);
+
+	if (!o2hb_dependent_users)
+		goto unlock;
+
+	if (o2hb_pop_count(&o2hb_quorum_region_bitmap,
+			   O2NM_MAX_REGIONS) <= O2HB_PIN_CUT_OFF)
+		o2hb_region_pin(NULL);
+
+unlock:
+	spin_unlock(&o2hb_live_lock);
+}
+
+struct o2hb_heartbeat_group_attribute {
+	struct configfs_attribute attr;
+	ssize_t (*show)(struct o2hb_heartbeat_group *, char *);
+	ssize_t (*store)(struct o2hb_heartbeat_group *, const char *, size_t);
+};
+
+static ssize_t o2hb_heartbeat_group_show(struct config_item *item,
+					 struct configfs_attribute *attr,
+					 char *page)
+{
+	struct o2hb_heartbeat_group *reg = to_o2hb_heartbeat_group(to_config_group(item));
+	struct o2hb_heartbeat_group_attribute *o2hb_heartbeat_group_attr =
+		container_of(attr, struct o2hb_heartbeat_group_attribute, attr);
+	ssize_t ret = 0;
+
+	if (o2hb_heartbeat_group_attr->show)
+		ret = o2hb_heartbeat_group_attr->show(reg, page);
+	return ret;
+}
+
+static ssize_t o2hb_heartbeat_group_store(struct config_item *item,
+					  struct configfs_attribute *attr,
+					  const char *page, size_t count)
+{
+	struct o2hb_heartbeat_group *reg = to_o2hb_heartbeat_group(to_config_group(item));
+	struct o2hb_heartbeat_group_attribute *o2hb_heartbeat_group_attr =
+		container_of(attr, struct o2hb_heartbeat_group_attribute, attr);
+	ssize_t ret = -EINVAL;
+
+	if (o2hb_heartbeat_group_attr->store)
+		ret = o2hb_heartbeat_group_attr->store(reg, page, count);
+	return ret;
+}
+
+static ssize_t o2hb_heartbeat_group_threshold_show(struct o2hb_heartbeat_group *group,
+						     char *page)
+{
+	return sprintf(page, "%u\n", o2hb_dead_threshold);
+}
+
+static ssize_t o2hb_heartbeat_group_threshold_store(struct o2hb_heartbeat_group *group,
+						    const char *page,
+						    size_t count)
+{
+	unsigned long tmp;
+	char *p = (char *)page;
+
+	tmp = simple_strtoul(p, &p, 10);
+	if (!p || (*p && (*p != '\n')))
+                return -EINVAL;
+
+	/* this will validate ranges for us. */
+	o2hb_dead_threshold_set((unsigned int) tmp);
+
+	return count;
+}
+
+static
+ssize_t o2hb_heartbeat_group_mode_show(struct o2hb_heartbeat_group *group,
+				       char *page)
+{
+	return sprintf(page, "%s\n",
+		       o2hb_heartbeat_mode_desc[o2hb_heartbeat_mode]);
+}
+
+static
+ssize_t o2hb_heartbeat_group_mode_store(struct o2hb_heartbeat_group *group,
+					const char *page, size_t count)
+{
+	unsigned int i;
+	int ret;
+	size_t len;
+
+	len = (page[count - 1] == '\n') ? count - 1 : count;
+	if (!len)
+		return -EINVAL;
+
+	for (i = 0; i < O2HB_HEARTBEAT_NUM_MODES; ++i) {
+		if (strnicmp(page, o2hb_heartbeat_mode_desc[i], len))
+			continue;
+
+		ret = o2hb_global_hearbeat_mode_set(i);
+		if (!ret)
+			printk(KERN_NOTICE "o2hb: Heartbeat mode set to %s\n",
+			       o2hb_heartbeat_mode_desc[i]);
+		return count;
+	}
+
+	return -EINVAL;
+
+}
+
+static struct o2hb_heartbeat_group_attribute o2hb_heartbeat_group_attr_threshold = {
+	.attr	= { .ca_owner = THIS_MODULE,
+		    .ca_name = "dead_threshold",
+		    .ca_mode = S_IRUGO | S_IWUSR },
+	.show	= o2hb_heartbeat_group_threshold_show,
+	.store	= o2hb_heartbeat_group_threshold_store,
+};
+
+static struct o2hb_heartbeat_group_attribute o2hb_heartbeat_group_attr_mode = {
+	.attr   = { .ca_owner = THIS_MODULE,
+		.ca_name = "mode",
+		.ca_mode = S_IRUGO | S_IWUSR },
+	.show   = o2hb_heartbeat_group_mode_show,
+	.store  = o2hb_heartbeat_group_mode_store,
+};
+
+static struct configfs_attribute *o2hb_heartbeat_group_attrs[] = {
+	&o2hb_heartbeat_group_attr_threshold.attr,
+	&o2hb_heartbeat_group_attr_mode.attr,
+	NULL,
+};
+
+static struct configfs_item_operations o2hb_hearbeat_group_item_ops = {
+	.show_attribute		= o2hb_heartbeat_group_show,
+	.store_attribute	= o2hb_heartbeat_group_store,
+};
+
+static struct configfs_group_operations o2hb_heartbeat_group_group_ops = {
+	.make_item	= o2hb_heartbeat_group_make_item,
+	.drop_item	= o2hb_heartbeat_group_drop_item,
+};
+
+static struct config_item_type o2hb_heartbeat_group_type = {
+	.ct_group_ops	= &o2hb_heartbeat_group_group_ops,
+	.ct_item_ops	= &o2hb_hearbeat_group_item_ops,
+	.ct_attrs	= o2hb_heartbeat_group_attrs,
+	.ct_owner	= THIS_MODULE,
+};
+
+/* this is just here to avoid touching group in heartbeat.h which the
+ * entire damn world #includes */
+struct config_group *o2hb_alloc_hb_set(void)
+{
+	struct o2hb_heartbeat_group *hs = NULL;
+	struct config_group *ret = NULL;
+
+	hs = kzalloc(sizeof(struct o2hb_heartbeat_group), GFP_KERNEL);
+	if (hs == NULL)
+		goto out;
+
+	config_group_init_type_name(&hs->hs_group, "heartbeat",
+				    &o2hb_heartbeat_group_type);
+
+	ret = &hs->hs_group;
+out:
+	if (ret == NULL)
+		kfree(hs);
+	return ret;
+}
+
+void o2hb_free_hb_set(struct config_group *group)
+{
+	struct o2hb_heartbeat_group *hs = to_o2hb_heartbeat_group(group);
+	kfree(hs);
+}
+
+/* hb callback registration and issuing */
+
+static struct o2hb_callback *hbcall_from_type(enum o2hb_callback_type type)
+{
+	if (type == O2HB_NUM_CB)
+		return ERR_PTR(-EINVAL);
+
+	return &o2hb_callbacks[type];
+}
+
+void o2hb_setup_callback(struct o2hb_callback_func *hc,
+			 enum o2hb_callback_type type,
+			 o2hb_cb_func *func,
+			 void *data,
+			 int priority)
+{
+	INIT_LIST_HEAD(&hc->hc_item);
+	hc->hc_func = func;
+	hc->hc_data = data;
+	hc->hc_priority = priority;
+	hc->hc_type = type;
+	hc->hc_magic = O2HB_CB_MAGIC;
+}
+EXPORT_SYMBOL_GPL(o2hb_setup_callback);
+
+/*
+ * In local heartbeat mode, region_uuid passed matches the dlm domain name.
+ * In global heartbeat mode, region_uuid passed is NULL.
+ *
+ * In local, we only pin the matching region. In global we pin all the active
+ * regions.
+ */
+static int o2hb_region_pin(const char *region_uuid)
+{
+	int ret = 0, found = 0;
+	struct o2hb_region *reg;
+	char *uuid;
+
+	assert_spin_locked(&o2hb_live_lock);
+
+	list_for_each_entry(reg, &o2hb_all_regions, hr_all_item) {
+		uuid = config_item_name(&reg->hr_item);
+
+		/* local heartbeat */
+		if (region_uuid) {
+			if (strcmp(region_uuid, uuid))
+				continue;
+			found = 1;
+		}
+
+		if (reg->hr_item_pinned || reg->hr_item_dropped)
+			goto skip_pin;
+
+		/* Ignore ENOENT only for local hb (userdlm domain) */
+		ret = o2nm_depend_item(&reg->hr_item);
+		if (!ret) {
+			mlog(ML_CLUSTER, "Pin region %s\n", uuid);
+			reg->hr_item_pinned = 1;
+		} else {
+			if (ret == -ENOENT && found)
+				ret = 0;
+			else {
+				mlog(ML_ERROR, "Pin region %s fails with %d\n",
+				     uuid, ret);
+				break;
+			}
+		}
+skip_pin:
+		if (found)
+			break;
+	}
+
+	return ret;
+}
+
+/*
+ * In local heartbeat mode, region_uuid passed matches the dlm domain name.
+ * In global heartbeat mode, region_uuid passed is NULL.
+ *
+ * In local, we only unpin the matching region. In global we unpin all the
+ * active regions.
+ */
+static void o2hb_region_unpin(const char *region_uuid)
+{
+	struct o2hb_region *reg;
+	char *uuid;
+	int found = 0;
+
+	assert_spin_locked(&o2hb_live_lock);
+
+	list_for_each_entry(reg, &o2hb_all_regions, hr_all_item) {
+		uuid = config_item_name(&reg->hr_item);
+		if (region_uuid) {
+			if (strcmp(region_uuid, uuid))
+				continue;
+			found = 1;
+		}
+
+		if (reg->hr_item_pinned) {
+			mlog(ML_CLUSTER, "Unpin region %s\n", uuid);
+			o2nm_undepend_item(&reg->hr_item);
+			reg->hr_item_pinned = 0;
+		}
+		if (found)
+			break;
+	}
+}
+
+static int o2hb_region_inc_user(const char *region_uuid)
+{
+	int ret = 0;
+
+	spin_lock(&o2hb_live_lock);
+
+	/* local heartbeat */
+	if (!o2hb_global_heartbeat_active()) {
+	    ret = o2hb_region_pin(region_uuid);
+	    goto unlock;
+	}
+
+	/*
+	 * if global heartbeat active and this is the first dependent user,
+	 * pin all regions if quorum region count <= CUT_OFF
+	 */
+	o2hb_dependent_users++;
+	if (o2hb_dependent_users > 1)
+		goto unlock;
+
+	if (o2hb_pop_count(&o2hb_quorum_region_bitmap,
+			   O2NM_MAX_REGIONS) <= O2HB_PIN_CUT_OFF)
+		ret = o2hb_region_pin(NULL);
+
+unlock:
+	spin_unlock(&o2hb_live_lock);
+	return ret;
+}
+
+void o2hb_region_dec_user(const char *region_uuid)
+{
+	spin_lock(&o2hb_live_lock);
+
+	/* local heartbeat */
+	if (!o2hb_global_heartbeat_active()) {
+	    o2hb_region_unpin(region_uuid);
+	    goto unlock;
+	}
+
+	/*
+	 * if global heartbeat active and there are no dependent users,
+	 * unpin all quorum regions
+	 */
+	o2hb_dependent_users--;
+	if (!o2hb_dependent_users)
+		o2hb_region_unpin(NULL);
+
+unlock:
+	spin_unlock(&o2hb_live_lock);
+}
+
+int o2hb_register_callback(const char *region_uuid,
+			   struct o2hb_callback_func *hc)
+{
+	struct o2hb_callback_func *tmp;
+	struct list_head *iter;
+	struct o2hb_callback *hbcall;
+	int ret;
+
+	BUG_ON(hc->hc_magic != O2HB_CB_MAGIC);
+	BUG_ON(!list_empty(&hc->hc_item));
+
+	hbcall = hbcall_from_type(hc->hc_type);
+	if (IS_ERR(hbcall)) {
+		ret = PTR_ERR(hbcall);
+		goto out;
+	}
+
+	if (region_uuid) {
+		ret = o2hb_region_inc_user(region_uuid);
+		if (ret) {
+			mlog_errno(ret);
+			goto out;
+		}
+	}
+
+	down_write(&o2hb_callback_sem);
+
+	list_for_each(iter, &hbcall->list) {
+		tmp = list_entry(iter, struct o2hb_callback_func, hc_item);
+		if (hc->hc_priority < tmp->hc_priority) {
+			list_add_tail(&hc->hc_item, iter);
+			break;
+		}
+	}
+	if (list_empty(&hc->hc_item))
+		list_add_tail(&hc->hc_item, &hbcall->list);
+
+	up_write(&o2hb_callback_sem);
+	ret = 0;
+out:
+	mlog(ML_CLUSTER, "returning %d on behalf of %p for funcs %p\n",
+	     ret, __builtin_return_address(0), hc);
+	return ret;
+}
+EXPORT_SYMBOL_GPL(o2hb_register_callback);
+
+void o2hb_unregister_callback(const char *region_uuid,
+			      struct o2hb_callback_func *hc)
+{
+	BUG_ON(hc->hc_magic != O2HB_CB_MAGIC);
+
+	mlog(ML_CLUSTER, "on behalf of %p for funcs %p\n",
+	     __builtin_return_address(0), hc);
+
+	/* XXX Can this happen _with_ a region reference? */
+	if (list_empty(&hc->hc_item))
+		return;
+
+	if (region_uuid)
+		o2hb_region_dec_user(region_uuid);
+
+	down_write(&o2hb_callback_sem);
+
+	list_del_init(&hc->hc_item);
+
+	up_write(&o2hb_callback_sem);
+}
+EXPORT_SYMBOL_GPL(o2hb_unregister_callback);
+
+int o2hb_check_node_heartbeating(u8 node_num)
+{
+	unsigned long testing_map[BITS_TO_LONGS(O2NM_MAX_NODES)];
+
+	o2hb_fill_node_map(testing_map, sizeof(testing_map));
+	if (!test_bit(node_num, testing_map)) {
+		mlog(ML_HEARTBEAT,
+		     "node (%u) does not have heartbeating enabled.\n",
+		     node_num);
+		return 0;
+	}
+
+	return 1;
+}
+EXPORT_SYMBOL_GPL(o2hb_check_node_heartbeating);
+
+int o2hb_check_node_heartbeating_from_callback(u8 node_num)
+{
+	unsigned long testing_map[BITS_TO_LONGS(O2NM_MAX_NODES)];
+
+	o2hb_fill_node_map_from_callback(testing_map, sizeof(testing_map));
+	if (!test_bit(node_num, testing_map)) {
+		mlog(ML_HEARTBEAT,
+		     "node (%u) does not have heartbeating enabled.\n",
+		     node_num);
+		return 0;
+	}
+
+	return 1;
+}
+EXPORT_SYMBOL_GPL(o2hb_check_node_heartbeating_from_callback);
+
+/* Makes sure our local node is configured with a node number, and is
+ * heartbeating. */
+int o2hb_check_local_node_heartbeating(void)
+{
+	u8 node_num;
+
+	/* if this node was set then we have networking */
+	node_num = o2nm_this_node();
+	if (node_num == O2NM_MAX_NODES) {
+		mlog(ML_HEARTBEAT, "this node has not been configured.\n");
+		return 0;
+	}
+
+	return o2hb_check_node_heartbeating(node_num);
+}
+EXPORT_SYMBOL_GPL(o2hb_check_local_node_heartbeating);
+
+/*
+ * this is just a hack until we get the plumbing which flips file systems
+ * read only and drops the hb ref instead of killing the node dead.
+ */
+void o2hb_stop_all_regions(void)
+{
+	struct o2hb_region *reg;
+
+	mlog(ML_ERROR, "stopping heartbeat on all active regions.\n");
+
+	spin_lock(&o2hb_live_lock);
+
+	list_for_each_entry(reg, &o2hb_all_regions, hr_all_item)
+		reg->hr_unclean_stop = 1;
+
+	spin_unlock(&o2hb_live_lock);
+}
+EXPORT_SYMBOL_GPL(o2hb_stop_all_regions);
+
+int o2hb_get_all_regions(char *region_uuids, u8 max_regions)
+{
+	struct o2hb_region *reg;
+	int numregs = 0;
+	char *p;
+
+	spin_lock(&o2hb_live_lock);
+
+	p = region_uuids;
+	list_for_each_entry(reg, &o2hb_all_regions, hr_all_item) {
+		mlog(0, "Region: %s\n", config_item_name(&reg->hr_item));
+		if (numregs < max_regions) {
+			memcpy(p, config_item_name(&reg->hr_item),
+			       O2HB_MAX_REGION_NAME_LEN);
+			p += O2HB_MAX_REGION_NAME_LEN;
+		}
+		numregs++;
+	}
+
+	spin_unlock(&o2hb_live_lock);
+
+	return numregs;
+}
+EXPORT_SYMBOL_GPL(o2hb_get_all_regions);
+
+int o2hb_global_heartbeat_active(void)
+{
+	return (o2hb_heartbeat_mode == O2HB_HEARTBEAT_GLOBAL);
+}
+EXPORT_SYMBOL(o2hb_global_heartbeat_active);
diff --git a/drivers/staging/ramster/cluster/heartbeat.h b/drivers/staging/ramster/cluster/heartbeat.h
new file mode 100644
index 0000000..00ad8e8
--- /dev/null
+++ b/drivers/staging/ramster/cluster/heartbeat.h
@@ -0,0 +1,89 @@
+/* -*- mode: c; c-basic-offset: 8; -*-
+ * vim: noexpandtab sw=8 ts=8 sts=0:
+ *
+ * heartbeat.h
+ *
+ * Function prototypes
+ *
+ * Copyright (C) 2004 Oracle.  All rights reserved.
+ *
+ * This program is free software; you can redistribute it and/or
+ * modify it under the terms of the GNU General Public
+ * License as published by the Free Software Foundation; either
+ * version 2 of the License, or (at your option) any later version.
+ *
+ * This program is distributed in the hope that it will be useful,
+ * but WITHOUT ANY WARRANTY; without even the implied warranty of
+ * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
+ * General Public License for more details.
+ *
+ * You should have received a copy of the GNU General Public
+ * License along with this program; if not, write to the
+ * Free Software Foundation, Inc., 59 Temple Place - Suite 330,
+ * Boston, MA 021110-1307, USA.
+ *
+ */
+
+#ifndef O2CLUSTER_HEARTBEAT_H
+#define O2CLUSTER_HEARTBEAT_H
+
+#include "ocfs2_heartbeat.h"
+
+#define O2HB_REGION_TIMEOUT_MS		2000
+
+#define O2HB_MAX_REGION_NAME_LEN	32
+
+/* number of changes to be seen as live */
+#define O2HB_LIVE_THRESHOLD	   2
+/* number of equal samples to be seen as dead */
+extern unsigned int o2hb_dead_threshold;
+#define O2HB_DEFAULT_DEAD_THRESHOLD	   31
+/* Otherwise MAX_WRITE_TIMEOUT will be zero... */
+#define O2HB_MIN_DEAD_THRESHOLD	  2
+#define O2HB_MAX_WRITE_TIMEOUT_MS (O2HB_REGION_TIMEOUT_MS * (o2hb_dead_threshold - 1))
+
+#define O2HB_CB_MAGIC		0x51d1e4ec
+
+/* callback stuff */
+enum o2hb_callback_type {
+	O2HB_NODE_DOWN_CB = 0,
+	O2HB_NODE_UP_CB,
+	O2HB_NUM_CB
+};
+
+struct o2nm_node;
+typedef void (o2hb_cb_func)(struct o2nm_node *, int, void *);
+
+struct o2hb_callback_func {
+	u32			hc_magic;
+	struct list_head	hc_item;
+	o2hb_cb_func		*hc_func;
+	void			*hc_data;
+	int			hc_priority;
+	enum o2hb_callback_type hc_type;
+};
+
+struct config_group *o2hb_alloc_hb_set(void);
+void o2hb_free_hb_set(struct config_group *group);
+
+void o2hb_setup_callback(struct o2hb_callback_func *hc,
+			 enum o2hb_callback_type type,
+			 o2hb_cb_func *func,
+			 void *data,
+			 int priority);
+int o2hb_register_callback(const char *region_uuid,
+			   struct o2hb_callback_func *hc);
+void o2hb_unregister_callback(const char *region_uuid,
+			      struct o2hb_callback_func *hc);
+void o2hb_fill_node_map(unsigned long *map,
+			unsigned bytes);
+void o2hb_exit(void);
+int o2hb_init(void);
+int o2hb_check_node_heartbeating(u8 node_num);
+int o2hb_check_node_heartbeating_from_callback(u8 node_num);
+int o2hb_check_local_node_heartbeating(void);
+void o2hb_stop_all_regions(void);
+int o2hb_get_all_regions(char *region_uuids, u8 numregions);
+int o2hb_global_heartbeat_active(void);
+
+#endif /* O2CLUSTER_HEARTBEAT_H */
diff --git a/drivers/staging/ramster/cluster/masklog.c b/drivers/staging/ramster/cluster/masklog.c
new file mode 100644
index 0000000..07ac24f
--- /dev/null
+++ b/drivers/staging/ramster/cluster/masklog.c
@@ -0,0 +1,155 @@
+/* -*- mode: c; c-basic-offset: 8; -*-
+ * vim: noexpandtab sw=8 ts=8 sts=0:
+ *
+ * Copyright (C) 2004, 2005 Oracle.  All rights reserved.
+ *
+ * This program is free software; you can redistribute it and/or
+ * modify it under the terms of the GNU General Public
+ * License as published by the Free Software Foundation; either
+ * version 2 of the License, or (at your option) any later version.
+ *
+ * This program is distributed in the hope that it will be useful,
+ * but WITHOUT ANY WARRANTY; without even the implied warranty of
+ * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
+ * General Public License for more details.
+ *
+ * You should have received a copy of the GNU General Public
+ * License along with this program; if not, write to the
+ * Free Software Foundation, Inc., 59 Temple Place - Suite 330,
+ * Boston, MA 021110-1307, USA.
+ */
+
+#include <linux/module.h>
+#include <linux/kernel.h>
+#include <linux/proc_fs.h>
+#include <linux/seq_file.h>
+#include <linux/string.h>
+#include <asm/uaccess.h>
+
+#include "masklog.h"
+
+struct mlog_bits mlog_and_bits = MLOG_BITS_RHS(MLOG_INITIAL_AND_MASK);
+EXPORT_SYMBOL_GPL(mlog_and_bits);
+struct mlog_bits mlog_not_bits = MLOG_BITS_RHS(0);
+EXPORT_SYMBOL_GPL(mlog_not_bits);
+
+static ssize_t mlog_mask_show(u64 mask, char *buf)
+{
+	char *state;
+
+	if (__mlog_test_u64(mask, mlog_and_bits))
+		state = "allow";
+	else if (__mlog_test_u64(mask, mlog_not_bits))
+		state = "deny";
+	else
+		state = "off";
+
+	return snprintf(buf, PAGE_SIZE, "%s\n", state);
+}
+
+static ssize_t mlog_mask_store(u64 mask, const char *buf, size_t count)
+{
+	if (!strnicmp(buf, "allow", 5)) {
+		__mlog_set_u64(mask, mlog_and_bits);
+		__mlog_clear_u64(mask, mlog_not_bits);
+	} else if (!strnicmp(buf, "deny", 4)) {
+		__mlog_set_u64(mask, mlog_not_bits);
+		__mlog_clear_u64(mask, mlog_and_bits);
+	} else if (!strnicmp(buf, "off", 3)) {
+		__mlog_clear_u64(mask, mlog_not_bits);
+		__mlog_clear_u64(mask, mlog_and_bits);
+	} else
+		return -EINVAL;
+
+	return count;
+}
+
+struct mlog_attribute {
+	struct attribute attr;
+	u64 mask;
+};
+
+#define to_mlog_attr(_attr) container_of(_attr, struct mlog_attribute, attr)
+
+#define define_mask(_name) {			\
+	.attr = {				\
+		.name = #_name,			\
+		.mode = S_IRUGO | S_IWUSR,	\
+	},					\
+	.mask = ML_##_name,			\
+}
+
+static struct mlog_attribute mlog_attrs[MLOG_MAX_BITS] = {
+	define_mask(TCP),
+	define_mask(MSG),
+	define_mask(SOCKET),
+	define_mask(HEARTBEAT),
+	define_mask(HB_BIO),
+	define_mask(DLMFS),
+	define_mask(DLM),
+	define_mask(DLM_DOMAIN),
+	define_mask(DLM_THREAD),
+	define_mask(DLM_MASTER),
+	define_mask(DLM_RECOVERY),
+	define_mask(DLM_GLUE),
+	define_mask(VOTE),
+	define_mask(CONN),
+	define_mask(QUORUM),
+	define_mask(BASTS),
+	define_mask(CLUSTER),
+	define_mask(ERROR),
+	define_mask(NOTICE),
+	define_mask(KTHREAD),
+};
+
+static struct attribute *mlog_attr_ptrs[MLOG_MAX_BITS] = {NULL, };
+
+static ssize_t mlog_show(struct kobject *obj, struct attribute *attr,
+			 char *buf)
+{
+	struct mlog_attribute *mlog_attr = to_mlog_attr(attr);
+
+	return mlog_mask_show(mlog_attr->mask, buf);
+}
+
+static ssize_t mlog_store(struct kobject *obj, struct attribute *attr,
+			  const char *buf, size_t count)
+{
+	struct mlog_attribute *mlog_attr = to_mlog_attr(attr);
+
+	return mlog_mask_store(mlog_attr->mask, buf, count);
+}
+
+static const struct sysfs_ops mlog_attr_ops = {
+	.show  = mlog_show,
+	.store = mlog_store,
+};
+
+static struct kobj_type mlog_ktype = {
+	.default_attrs = mlog_attr_ptrs,
+	.sysfs_ops     = &mlog_attr_ops,
+};
+
+static struct kset mlog_kset = {
+	.kobj   = {.ktype = &mlog_ktype},
+};
+
+int mlog_sys_init(struct kset *o2cb_kset)
+{
+	int i = 0;
+
+	while (mlog_attrs[i].attr.mode) {
+		mlog_attr_ptrs[i] = &mlog_attrs[i].attr;
+		i++;
+	}
+	mlog_attr_ptrs[i] = NULL;
+
+	kobject_set_name(&mlog_kset.kobj, "logmask");
+	mlog_kset.kobj.kset = o2cb_kset;
+	return kset_register(&mlog_kset);
+}
+
+void mlog_sys_shutdown(void)
+{
+	kset_unregister(&mlog_kset);
+}
diff --git a/drivers/staging/ramster/cluster/masklog.h b/drivers/staging/ramster/cluster/masklog.h
new file mode 100644
index 0000000..baa2b9e
--- /dev/null
+++ b/drivers/staging/ramster/cluster/masklog.h
@@ -0,0 +1,219 @@
+/* -*- mode: c; c-basic-offset: 8; -*-
+ * vim: noexpandtab sw=8 ts=8 sts=0:
+ *
+ * Copyright (C) 2005 Oracle.  All rights reserved.
+ *
+ * This program is free software; you can redistribute it and/or
+ * modify it under the terms of the GNU General Public
+ * License as published by the Free Software Foundation; either
+ * version 2 of the License, or (at your option) any later version.
+ *
+ * This program is distributed in the hope that it will be useful,
+ * but WITHOUT ANY WARRANTY; without even the implied warranty of
+ * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
+ * General Public License for more details.
+ *
+ * You should have received a copy of the GNU General Public
+ * License along with this program; if not, write to the
+ * Free Software Foundation, Inc., 59 Temple Place - Suite 330,
+ * Boston, MA 021110-1307, USA.
+ */
+
+#ifndef O2CLUSTER_MASKLOG_H
+#define O2CLUSTER_MASKLOG_H
+
+/*
+ * For now this is a trivial wrapper around printk() that gives the critical
+ * ability to enable sets of debugging output at run-time.  In the future this
+ * will almost certainly be redirected to relayfs so that it can pay a
+ * substantially lower heisenberg tax.
+ *
+ * Callers associate the message with a bitmask and a global bitmask is
+ * maintained with help from /proc.  If any of the bits match the message is
+ * output.
+ *
+ * We must have efficient bit tests on i386 and it seems gcc still emits crazy
+ * code for the 64bit compare.  It emits very good code for the dual unsigned
+ * long tests, though, completely avoiding tests that can never pass if the
+ * caller gives a constant bitmask that fills one of the longs with all 0s.  So
+ * the desire is to have almost all of the calls decided on by comparing just
+ * one of the longs.  This leads to having infrequently given bits that are
+ * frequently matched in the high bits.
+ *
+ * _ERROR and _NOTICE are used for messages that always go to the console and
+ * have appropriate KERN_ prefixes.  We wrap these in our function instead of
+ * just calling printk() so that this can eventually make its way through
+ * relayfs along with the debugging messages.  Everything else gets KERN_DEBUG.
+ * The inline tests and macro dance give GCC the opportunity to quite cleverly
+ * only emit the appropriage printk() when the caller passes in a constant
+ * mask, as is almost always the case.
+ *
+ * All this bitmask nonsense is managed from the files under
+ * /sys/fs/o2cb/logmask/.  Reading the files gives a straightforward
+ * indication of which bits are allowed (allow) or denied (off/deny).
+ * 	ENTRY deny
+ * 	EXIT deny
+ * 	TCP off
+ * 	MSG off
+ * 	SOCKET off
+ * 	ERROR allow
+ * 	NOTICE allow
+ *
+ * Writing changes the state of a given bit and requires a strictly formatted
+ * single write() call:
+ *
+ * 	write(fd, "allow", 5);
+ *
+ * Echoing allow/deny/off string into the logmask files can flip the bits
+ * on or off as expected; here is the bash script for example:
+ *
+ * log_mask="/sys/fs/o2cb/log_mask"
+ * for node in ENTRY EXIT TCP MSG SOCKET ERROR NOTICE; do
+ *	echo allow >"$log_mask"/"$node"
+ * done
+ *
+ * The debugfs.ocfs2 tool can also flip the bits with the -l option:
+ *
+ * debugfs.ocfs2 -l TCP allow
+ */
+
+/* for task_struct */
+#include <linux/sched.h>
+
+/* bits that are frequently given and infrequently matched in the low word */
+/* NOTE: If you add a flag, you need to also update masklog.c! */
+#define ML_TCP		0x0000000000000001ULL /* net cluster/tcp.c */
+#define ML_MSG		0x0000000000000002ULL /* net network messages */
+#define ML_SOCKET	0x0000000000000004ULL /* net socket lifetime */
+#define ML_HEARTBEAT	0x0000000000000008ULL /* hb all heartbeat tracking */
+#define ML_HB_BIO	0x0000000000000010ULL /* hb io tracing */
+#define ML_DLMFS	0x0000000000000020ULL /* dlm user dlmfs */
+#define ML_DLM		0x0000000000000040ULL /* dlm general debugging */
+#define ML_DLM_DOMAIN	0x0000000000000080ULL /* dlm domain debugging */
+#define ML_DLM_THREAD	0x0000000000000100ULL /* dlm domain thread */
+#define ML_DLM_MASTER	0x0000000000000200ULL /* dlm master functions */
+#define ML_DLM_RECOVERY	0x0000000000000400ULL /* dlm master functions */
+#define ML_DLM_GLUE	0x0000000000000800ULL /* ocfs2 dlm glue layer */
+#define ML_VOTE		0x0000000000001000ULL /* ocfs2 node messaging  */
+#define ML_CONN		0x0000000000002000ULL /* net connection management */
+#define ML_QUORUM	0x0000000000004000ULL /* net connection quorum */
+#define ML_BASTS	0x0000000000008000ULL /* dlmglue asts and basts */
+#define ML_CLUSTER	0x0000000000010000ULL /* cluster stack */
+
+/* bits that are infrequently given and frequently matched in the high word */
+#define ML_ERROR	0x1000000000000000ULL /* sent to KERN_ERR */
+#define ML_NOTICE	0x2000000000000000ULL /* setn to KERN_NOTICE */
+#define ML_KTHREAD	0x4000000000000000ULL /* kernel thread activity */
+
+#define MLOG_INITIAL_AND_MASK (ML_ERROR|ML_NOTICE)
+#ifndef MLOG_MASK_PREFIX
+#define MLOG_MASK_PREFIX 0
+#endif
+
+/*
+ * When logging is disabled, force the bit test to 0 for anything other
+ * than errors and notices, allowing gcc to remove the code completely.
+ * When enabled, allow all masks.
+ */
+#if defined(CONFIG_OCFS2_DEBUG_MASKLOG)
+#define ML_ALLOWED_BITS ~0
+#else
+#define ML_ALLOWED_BITS (ML_ERROR|ML_NOTICE)
+#endif
+
+#define MLOG_MAX_BITS 64
+
+struct mlog_bits {
+	unsigned long words[MLOG_MAX_BITS / BITS_PER_LONG];
+};
+
+extern struct mlog_bits mlog_and_bits, mlog_not_bits;
+
+#if BITS_PER_LONG == 32
+
+#define __mlog_test_u64(mask, bits)			\
+	( (u32)(mask & 0xffffffff) & bits.words[0] || 	\
+	  ((u64)(mask) >> 32) & bits.words[1] )
+#define __mlog_set_u64(mask, bits) do {			\
+	bits.words[0] |= (u32)(mask & 0xffffffff);	\
+       	bits.words[1] |= (u64)(mask) >> 32;		\
+} while (0)
+#define __mlog_clear_u64(mask, bits) do {		\
+	bits.words[0] &= ~((u32)(mask & 0xffffffff));	\
+       	bits.words[1] &= ~((u64)(mask) >> 32);		\
+} while (0)
+#define MLOG_BITS_RHS(mask) {				\
+	{						\
+		[0] = (u32)(mask & 0xffffffff),		\
+		[1] = (u64)(mask) >> 32,		\
+	}						\
+}
+
+#else /* 32bit long above, 64bit long below */
+
+#define __mlog_test_u64(mask, bits)	((mask) & bits.words[0])
+#define __mlog_set_u64(mask, bits) do {		\
+	bits.words[0] |= (mask);		\
+} while (0)
+#define __mlog_clear_u64(mask, bits) do {	\
+	bits.words[0] &= ~(mask);		\
+} while (0)
+#define MLOG_BITS_RHS(mask) { { (mask) } }
+
+#endif
+
+/*
+ * smp_processor_id() "helpfully" screams when called outside preemptible
+ * regions in current kernels.  sles doesn't have the variants that don't
+ * scream.  just do this instead of trying to guess which we're building
+ * against.. *sigh*.
+ */
+#define __mlog_cpu_guess ({		\
+	unsigned long _cpu = get_cpu();	\
+	put_cpu();			\
+	_cpu;				\
+})
+
+/* In the following two macros, the whitespace after the ',' just
+ * before ##args is intentional. Otherwise, gcc 2.95 will eat the
+ * previous token if args expands to nothing.
+ */
+#define __mlog_printk(level, fmt, args...)				\
+	printk(level "(%s,%u,%lu):%s:%d " fmt, current->comm,		\
+	       task_pid_nr(current), __mlog_cpu_guess,			\
+	       __PRETTY_FUNCTION__, __LINE__ , ##args)
+
+#define mlog(mask, fmt, args...) do {					\
+	u64 __m = MLOG_MASK_PREFIX | (mask);				\
+	if ((__m & ML_ALLOWED_BITS) &&					\
+	    __mlog_test_u64(__m, mlog_and_bits) &&			\
+	    !__mlog_test_u64(__m, mlog_not_bits)) {			\
+		if (__m & ML_ERROR)					\
+			__mlog_printk(KERN_ERR, "ERROR: "fmt , ##args);	\
+		else if (__m & ML_NOTICE)				\
+			__mlog_printk(KERN_NOTICE, fmt , ##args);	\
+		else __mlog_printk(KERN_INFO, fmt , ##args);		\
+	}								\
+} while (0)
+
+#define mlog_errno(st) do {						\
+	int _st = (st);							\
+	if (_st != -ERESTARTSYS && _st != -EINTR &&			\
+	    _st != AOP_TRUNCATED_PAGE && _st != -ENOSPC)		\
+		mlog(ML_ERROR, "status = %lld\n", (long long)_st);	\
+} while (0)
+
+#define mlog_bug_on_msg(cond, fmt, args...) do {			\
+	if (cond) {							\
+		mlog(ML_ERROR, "bug expression: " #cond "\n");		\
+		mlog(ML_ERROR, fmt, ##args);				\
+		BUG();							\
+	}								\
+} while (0)
+
+#include <linux/kobject.h>
+#include <linux/sysfs.h>
+int mlog_sys_init(struct kset *o2cb_subsys);
+void mlog_sys_shutdown(void);
+
+#endif /* O2CLUSTER_MASKLOG_H */
diff --git a/drivers/staging/ramster/cluster/netdebug.c b/drivers/staging/ramster/cluster/netdebug.c
new file mode 100644
index 0000000..dc45deb
--- /dev/null
+++ b/drivers/staging/ramster/cluster/netdebug.c
@@ -0,0 +1,579 @@
+/* -*- mode: c; c-basic-offset: 8; -*-
+ * vim: noexpandtab sw=8 ts=8 sts=0:
+ *
+ * netdebug.c
+ *
+ * debug functionality for o2net
+ *
+ * Copyright (C) 2005, 2008 Oracle.  All rights reserved.
+ *
+ * This program is free software; you can redistribute it and/or
+ * modify it under the terms of the GNU General Public
+ * License as published by the Free Software Foundation; either
+ * version 2 of the License, or (at your option) any later version.
+ *
+ * This program is distributed in the hope that it will be useful,
+ * but WITHOUT ANY WARRANTY; without even the implied warranty of
+ * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
+ * General Public License for more details.
+ *
+ * You should have received a copy of the GNU General Public
+ * License along with this program; if not, write to the
+ * Free Software Foundation, Inc., 59 Temple Place - Suite 330,
+ * Boston, MA 021110-1307, USA.
+ *
+ */
+
+#ifdef CONFIG_DEBUG_FS
+
+#include <linux/module.h>
+#include <linux/types.h>
+#include <linux/slab.h>
+#include <linux/idr.h>
+#include <linux/kref.h>
+#include <linux/seq_file.h>
+#include <linux/debugfs.h>
+
+#include <linux/uaccess.h>
+
+#include "tcp.h"
+#include "nodemanager.h"
+#define MLOG_MASK_PREFIX ML_TCP
+#include "masklog.h"
+
+#include "tcp_internal.h"
+
+#define O2NET_DEBUG_DIR		"o2net"
+#define SC_DEBUG_NAME		"sock_containers"
+#define NST_DEBUG_NAME		"send_tracking"
+#define STATS_DEBUG_NAME	"stats"
+#define NODES_DEBUG_NAME	"connected_nodes"
+
+#define SHOW_SOCK_CONTAINERS	0
+#define SHOW_SOCK_STATS		1
+
+static struct dentry *o2net_dentry;
+static struct dentry *sc_dentry;
+static struct dentry *nst_dentry;
+static struct dentry *stats_dentry;
+static struct dentry *nodes_dentry;
+
+static DEFINE_SPINLOCK(o2net_debug_lock);
+
+static LIST_HEAD(sock_containers);
+static LIST_HEAD(send_tracking);
+
+void o2net_debug_add_nst(struct o2net_send_tracking *nst)
+{
+	spin_lock(&o2net_debug_lock);
+	list_add(&nst->st_net_debug_item, &send_tracking);
+	spin_unlock(&o2net_debug_lock);
+}
+
+void o2net_debug_del_nst(struct o2net_send_tracking *nst)
+{
+	spin_lock(&o2net_debug_lock);
+	if (!list_empty(&nst->st_net_debug_item))
+		list_del_init(&nst->st_net_debug_item);
+	spin_unlock(&o2net_debug_lock);
+}
+
+static struct o2net_send_tracking
+			*next_nst(struct o2net_send_tracking *nst_start)
+{
+	struct o2net_send_tracking *nst, *ret = NULL;
+
+	assert_spin_locked(&o2net_debug_lock);
+
+	list_for_each_entry(nst, &nst_start->st_net_debug_item,
+			    st_net_debug_item) {
+		/* discover the head of the list */
+		if (&nst->st_net_debug_item == &send_tracking)
+			break;
+
+		/* use st_task to detect real nsts in the list */
+		if (nst->st_task != NULL) {
+			ret = nst;
+			break;
+		}
+	}
+
+	return ret;
+}
+
+static void *nst_seq_start(struct seq_file *seq, loff_t *pos)
+{
+	struct o2net_send_tracking *nst, *dummy_nst = seq->private;
+
+	spin_lock(&o2net_debug_lock);
+	nst = next_nst(dummy_nst);
+	spin_unlock(&o2net_debug_lock);
+
+	return nst;
+}
+
+static void *nst_seq_next(struct seq_file *seq, void *v, loff_t *pos)
+{
+	struct o2net_send_tracking *nst, *dummy_nst = seq->private;
+
+	spin_lock(&o2net_debug_lock);
+	nst = next_nst(dummy_nst);
+	list_del_init(&dummy_nst->st_net_debug_item);
+	if (nst)
+		list_add(&dummy_nst->st_net_debug_item,
+			 &nst->st_net_debug_item);
+	spin_unlock(&o2net_debug_lock);
+
+	return nst; /* unused, just needs to be null when done */
+}
+
+static int nst_seq_show(struct seq_file *seq, void *v)
+{
+	struct o2net_send_tracking *nst, *dummy_nst = seq->private;
+	ktime_t now;
+	s64 sock, send, status;
+
+	spin_lock(&o2net_debug_lock);
+	nst = next_nst(dummy_nst);
+	if (!nst)
+		goto out;
+
+	now = ktime_get();
+	sock = ktime_to_us(ktime_sub(now, nst->st_sock_time));
+	send = ktime_to_us(ktime_sub(now, nst->st_send_time));
+	status = ktime_to_us(ktime_sub(now, nst->st_status_time));
+
+	/* get_task_comm isn't exported.  oh well. */
+	seq_printf(seq, "%p:\n"
+		   "  pid:          %lu\n"
+		   "  tgid:         %lu\n"
+		   "  process name: %s\n"
+		   "  node:         %u\n"
+		   "  sc:           %p\n"
+		   "  message id:   %d\n"
+		   "  message type: %u\n"
+		   "  message key:  0x%08x\n"
+		   "  sock acquiry: %lld usecs ago\n"
+		   "  send start:   %lld usecs ago\n"
+		   "  wait start:   %lld usecs ago\n",
+		   nst, (unsigned long)task_pid_nr(nst->st_task),
+		   (unsigned long)nst->st_task->tgid,
+		   nst->st_task->comm, nst->st_node,
+		   nst->st_sc, nst->st_id, nst->st_msg_type,
+		   nst->st_msg_key,
+		   (long long)sock,
+		   (long long)send,
+		   (long long)status);
+
+out:
+	spin_unlock(&o2net_debug_lock);
+
+	return 0;
+}
+
+static void nst_seq_stop(struct seq_file *seq, void *v)
+{
+}
+
+static const struct seq_operations nst_seq_ops = {
+	.start = nst_seq_start,
+	.next = nst_seq_next,
+	.stop = nst_seq_stop,
+	.show = nst_seq_show,
+};
+
+static int nst_fop_open(struct inode *inode, struct file *file)
+{
+	struct o2net_send_tracking *dummy_nst;
+	struct seq_file *seq;
+	int ret;
+
+	dummy_nst = kmalloc(sizeof(struct o2net_send_tracking), GFP_KERNEL);
+	if (dummy_nst == NULL) {
+		ret = -ENOMEM;
+		goto out;
+	}
+	dummy_nst->st_task = NULL;
+
+	ret = seq_open(file, &nst_seq_ops);
+	if (ret)
+		goto out;
+
+	seq = file->private_data;
+	seq->private = dummy_nst;
+	o2net_debug_add_nst(dummy_nst);
+
+	dummy_nst = NULL;
+
+out:
+	kfree(dummy_nst);
+	return ret;
+}
+
+static int nst_fop_release(struct inode *inode, struct file *file)
+{
+	struct seq_file *seq = file->private_data;
+	struct o2net_send_tracking *dummy_nst = seq->private;
+
+	o2net_debug_del_nst(dummy_nst);
+	return seq_release_private(inode, file);
+}
+
+static const struct file_operations nst_seq_fops = {
+	.open = nst_fop_open,
+	.read = seq_read,
+	.llseek = seq_lseek,
+	.release = nst_fop_release,
+};
+
+void o2net_debug_add_sc(struct o2net_sock_container *sc)
+{
+	spin_lock(&o2net_debug_lock);
+	list_add(&sc->sc_net_debug_item, &sock_containers);
+	spin_unlock(&o2net_debug_lock);
+}
+
+void o2net_debug_del_sc(struct o2net_sock_container *sc)
+{
+	spin_lock(&o2net_debug_lock);
+	list_del_init(&sc->sc_net_debug_item);
+	spin_unlock(&o2net_debug_lock);
+}
+
+struct o2net_sock_debug {
+	int dbg_ctxt;
+	struct o2net_sock_container *dbg_sock;
+};
+
+static struct o2net_sock_container
+			*next_sc(struct o2net_sock_container *sc_start)
+{
+	struct o2net_sock_container *sc, *ret = NULL;
+
+	assert_spin_locked(&o2net_debug_lock);
+
+	list_for_each_entry(sc, &sc_start->sc_net_debug_item,
+			    sc_net_debug_item) {
+		/* discover the head of the list miscast as a sc */
+		if (&sc->sc_net_debug_item == &sock_containers)
+			break;
+
+		/* use sc_page to detect real scs in the list */
+		if (sc->sc_page != NULL) {
+			ret = sc;
+			break;
+		}
+	}
+
+	return ret;
+}
+
+static void *sc_seq_start(struct seq_file *seq, loff_t *pos)
+{
+	struct o2net_sock_debug *sd = seq->private;
+	struct o2net_sock_container *sc, *dummy_sc = sd->dbg_sock;
+
+	spin_lock(&o2net_debug_lock);
+	sc = next_sc(dummy_sc);
+	spin_unlock(&o2net_debug_lock);
+
+	return sc;
+}
+
+static void *sc_seq_next(struct seq_file *seq, void *v, loff_t *pos)
+{
+	struct o2net_sock_debug *sd = seq->private;
+	struct o2net_sock_container *sc, *dummy_sc = sd->dbg_sock;
+
+	spin_lock(&o2net_debug_lock);
+	sc = next_sc(dummy_sc);
+	list_del_init(&dummy_sc->sc_net_debug_item);
+	if (sc)
+		list_add(&dummy_sc->sc_net_debug_item, &sc->sc_net_debug_item);
+	spin_unlock(&o2net_debug_lock);
+
+	return sc; /* unused, just needs to be null when done */
+}
+
+#ifdef CONFIG_OCFS2_FS_STATS
+# define sc_send_count(_s)		((_s)->sc_send_count)
+# define sc_recv_count(_s)		((_s)->sc_recv_count)
+# define sc_tv_acquiry_total_ns(_s)	(ktime_to_ns((_s)->sc_tv_acquiry_total))
+# define sc_tv_send_total_ns(_s)	(ktime_to_ns((_s)->sc_tv_send_total))
+# define sc_tv_status_total_ns(_s)	(ktime_to_ns((_s)->sc_tv_status_total))
+# define sc_tv_process_total_ns(_s)	(ktime_to_ns((_s)->sc_tv_process_total))
+#else
+# define sc_send_count(_s)		(0U)
+# define sc_recv_count(_s)		(0U)
+# define sc_tv_acquiry_total_ns(_s)	(0LL)
+# define sc_tv_send_total_ns(_s)	(0LL)
+# define sc_tv_status_total_ns(_s)	(0LL)
+# define sc_tv_process_total_ns(_s)	(0LL)
+#endif
+
+/* So that debugfs.ocfs2 can determine which format is being used */
+#define O2NET_STATS_STR_VERSION		1
+static void sc_show_sock_stats(struct seq_file *seq,
+			       struct o2net_sock_container *sc)
+{
+	if (!sc)
+		return;
+
+	seq_printf(seq, "%d,%u,%lu,%lld,%lld,%lld,%lu,%lld\n", O2NET_STATS_STR_VERSION,
+		   sc->sc_node->nd_num, (unsigned long)sc_send_count(sc),
+		   (long long)sc_tv_acquiry_total_ns(sc),
+		   (long long)sc_tv_send_total_ns(sc),
+		   (long long)sc_tv_status_total_ns(sc),
+		   (unsigned long)sc_recv_count(sc),
+		   (long long)sc_tv_process_total_ns(sc));
+}
+
+static void sc_show_sock_container(struct seq_file *seq,
+				   struct o2net_sock_container *sc)
+{
+	struct inet_sock *inet = NULL;
+	__be32 saddr = 0, daddr = 0;
+	__be16 sport = 0, dport = 0;
+
+	if (!sc)
+		return;
+
+	if (sc->sc_sock) {
+		inet = inet_sk(sc->sc_sock->sk);
+		/* the stack's structs aren't sparse endian clean */
+		saddr = (__force __be32)inet->inet_saddr;
+		daddr = (__force __be32)inet->inet_daddr;
+		sport = (__force __be16)inet->inet_sport;
+		dport = (__force __be16)inet->inet_dport;
+	}
+
+	/* XXX sigh, inet-> doesn't have sparse annotation so any
+	 * use of it here generates a warning with -Wbitwise */
+	seq_printf(seq, "%p:\n"
+		   "  krefs:           %d\n"
+		   "  sock:            %pI4:%u -> "
+				      "%pI4:%u\n"
+		   "  remote node:     %s\n"
+		   "  page off:        %zu\n"
+		   "  handshake ok:    %u\n"
+		   "  timer:           %lld usecs\n"
+		   "  data ready:      %lld usecs\n"
+		   "  advance start:   %lld usecs\n"
+		   "  advance stop:    %lld usecs\n"
+		   "  func start:      %lld usecs\n"
+		   "  func stop:       %lld usecs\n"
+		   "  func key:        0x%08x\n"
+		   "  func type:       %u\n",
+		   sc,
+		   atomic_read(&sc->sc_kref.refcount),
+		   &saddr, inet ? ntohs(sport) : 0,
+		   &daddr, inet ? ntohs(dport) : 0,
+		   sc->sc_node->nd_name,
+		   sc->sc_page_off,
+		   sc->sc_handshake_ok,
+		   (long long)ktime_to_us(sc->sc_tv_timer),
+		   (long long)ktime_to_us(sc->sc_tv_data_ready),
+		   (long long)ktime_to_us(sc->sc_tv_advance_start),
+		   (long long)ktime_to_us(sc->sc_tv_advance_stop),
+		   (long long)ktime_to_us(sc->sc_tv_func_start),
+		   (long long)ktime_to_us(sc->sc_tv_func_stop),
+		   sc->sc_msg_key,
+		   sc->sc_msg_type);
+}
+
+static int sc_seq_show(struct seq_file *seq, void *v)
+{
+	struct o2net_sock_debug *sd = seq->private;
+	struct o2net_sock_container *sc, *dummy_sc = sd->dbg_sock;
+
+	spin_lock(&o2net_debug_lock);
+	sc = next_sc(dummy_sc);
+
+	if (sc) {
+		if (sd->dbg_ctxt == SHOW_SOCK_CONTAINERS)
+			sc_show_sock_container(seq, sc);
+		else
+			sc_show_sock_stats(seq, sc);
+	}
+
+	spin_unlock(&o2net_debug_lock);
+
+	return 0;
+}
+
+static void sc_seq_stop(struct seq_file *seq, void *v)
+{
+}
+
+static const struct seq_operations sc_seq_ops = {
+	.start = sc_seq_start,
+	.next = sc_seq_next,
+	.stop = sc_seq_stop,
+	.show = sc_seq_show,
+};
+
+static int sc_common_open(struct file *file, struct o2net_sock_debug *sd)
+{
+	struct o2net_sock_container *dummy_sc;
+	struct seq_file *seq;
+	int ret;
+
+	dummy_sc = kmalloc(sizeof(struct o2net_sock_container), GFP_KERNEL);
+	if (dummy_sc == NULL) {
+		ret = -ENOMEM;
+		goto out;
+	}
+	dummy_sc->sc_page = NULL;
+
+	ret = seq_open(file, &sc_seq_ops);
+	if (ret)
+		goto out;
+
+	seq = file->private_data;
+	seq->private = sd;
+	sd->dbg_sock = dummy_sc;
+	o2net_debug_add_sc(dummy_sc);
+
+	dummy_sc = NULL;
+
+out:
+	kfree(dummy_sc);
+	return ret;
+}
+
+static int sc_fop_release(struct inode *inode, struct file *file)
+{
+	struct seq_file *seq = file->private_data;
+	struct o2net_sock_debug *sd = seq->private;
+	struct o2net_sock_container *dummy_sc = sd->dbg_sock;
+
+	o2net_debug_del_sc(dummy_sc);
+	return seq_release_private(inode, file);
+}
+
+static int stats_fop_open(struct inode *inode, struct file *file)
+{
+	struct o2net_sock_debug *sd;
+
+	sd = kmalloc(sizeof(struct o2net_sock_debug), GFP_KERNEL);
+	if (sd == NULL)
+		return -ENOMEM;
+
+	sd->dbg_ctxt = SHOW_SOCK_STATS;
+	sd->dbg_sock = NULL;
+
+	return sc_common_open(file, sd);
+}
+
+static const struct file_operations stats_seq_fops = {
+	.open = stats_fop_open,
+	.read = seq_read,
+	.llseek = seq_lseek,
+	.release = sc_fop_release,
+};
+
+static int sc_fop_open(struct inode *inode, struct file *file)
+{
+	struct o2net_sock_debug *sd;
+
+	sd = kmalloc(sizeof(struct o2net_sock_debug), GFP_KERNEL);
+	if (sd == NULL)
+		return -ENOMEM;
+
+	sd->dbg_ctxt = SHOW_SOCK_CONTAINERS;
+	sd->dbg_sock = NULL;
+
+	return sc_common_open(file, sd);
+}
+
+static const struct file_operations sc_seq_fops = {
+	.open = sc_fop_open,
+	.read = seq_read,
+	.llseek = seq_lseek,
+	.release = sc_fop_release,
+};
+
+static int o2net_fill_bitmap(char *buf, int len)
+{
+	unsigned long map[BITS_TO_LONGS(O2NM_MAX_NODES)];
+	int i = -1, out = 0;
+
+	o2net_fill_node_map(map, sizeof(map));
+
+	while ((i = find_next_bit(map, O2NM_MAX_NODES, i + 1)) < O2NM_MAX_NODES)
+		out += snprintf(buf + out, PAGE_SIZE - out, "%d ", i);
+	out += snprintf(buf + out, PAGE_SIZE - out, "\n");
+
+	return out;
+}
+
+static int nodes_fop_open(struct inode *inode, struct file *file)
+{
+	char *buf;
+
+	buf = kmalloc(PAGE_SIZE, GFP_KERNEL);
+	if (!buf)
+		return -ENOMEM;
+
+	i_size_write(inode, o2net_fill_bitmap(buf, PAGE_SIZE));
+
+	file->private_data = buf;
+
+	return 0;
+}
+
+static int o2net_debug_release(struct inode *inode, struct file *file)
+{
+	kfree(file->private_data);
+	return 0;
+}
+
+static ssize_t o2net_debug_read(struct file *file, char __user *buf,
+				size_t nbytes, loff_t *ppos)
+{
+	return simple_read_from_buffer(buf, nbytes, ppos, file->private_data,
+				       i_size_read(file->f_mapping->host));
+}
+
+static const struct file_operations nodes_fops = {
+	.open		= nodes_fop_open,
+	.release	= o2net_debug_release,
+	.read		= o2net_debug_read,
+	.llseek		= generic_file_llseek,
+};
+
+void o2net_debugfs_exit(void)
+{
+	debugfs_remove(nodes_dentry);
+	debugfs_remove(stats_dentry);
+	debugfs_remove(sc_dentry);
+	debugfs_remove(nst_dentry);
+	debugfs_remove(o2net_dentry);
+}
+
+int o2net_debugfs_init(void)
+{
+	mode_t mode = S_IFREG|S_IRUSR;
+
+	o2net_dentry = debugfs_create_dir(O2NET_DEBUG_DIR, NULL);
+	if (o2net_dentry)
+		nst_dentry = debugfs_create_file(NST_DEBUG_NAME, mode,
+					o2net_dentry, NULL, &nst_seq_fops);
+	if (nst_dentry)
+		sc_dentry = debugfs_create_file(SC_DEBUG_NAME, mode,
+					o2net_dentry, NULL, &sc_seq_fops);
+	if (sc_dentry)
+		stats_dentry = debugfs_create_file(STATS_DEBUG_NAME, mode,
+					o2net_dentry, NULL, &stats_seq_fops);
+	if (stats_dentry)
+		nodes_dentry = debugfs_create_file(NODES_DEBUG_NAME, mode,
+					o2net_dentry, NULL, &nodes_fops);
+	if (nodes_dentry)
+		return 0;
+
+	o2net_debugfs_exit();
+	mlog_errno(-ENOMEM);
+	return -ENOMEM;
+}
+
+#endif	/* CONFIG_DEBUG_FS */
diff --git a/drivers/staging/ramster/cluster/nodemanager.c b/drivers/staging/ramster/cluster/nodemanager.c
new file mode 100644
index 0000000..bb24064
--- /dev/null
+++ b/drivers/staging/ramster/cluster/nodemanager.c
@@ -0,0 +1,989 @@
+/* -*- mode: c; c-basic-offset: 8; -*-
+ * vim: noexpandtab sw=8 ts=8 sts=0:
+ *
+ * Copyright (C) 2004, 2005 Oracle.  All rights reserved.
+ *
+ * This program is free software; you can redistribute it and/or
+ * modify it under the terms of the GNU General Public
+ * License as published by the Free Software Foundation; either
+ * version 2 of the License, or (at your option) any later version.
+ *
+ * This program is distributed in the hope that it will be useful,
+ * but WITHOUT ANY WARRANTY; without even the implied warranty of
+ * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
+ * General Public License for more details.
+ *
+ * You should have received a copy of the GNU General Public
+ * License along with this program; if not, write to the
+ * Free Software Foundation, Inc., 59 Temple Place - Suite 330,
+ * Boston, MA 021110-1307, USA.
+ */
+
+#include <linux/slab.h>
+#include <linux/kernel.h>
+#include <linux/module.h>
+#include <linux/configfs.h>
+
+#include "tcp.h"
+#include "nodemanager.h"
+#include "heartbeat.h"
+#include "masklog.h"
+#include "sys.h"
+#include "ver.h"
+
+/* for now we operate under the assertion that there can be only one
+ * cluster active at a time.  Changing this will require trickling
+ * cluster references throughout where nodes are looked up */
+struct o2nm_cluster *o2nm_single_cluster = NULL;
+
+char *o2nm_fence_method_desc[O2NM_FENCE_METHODS] = {
+		"reset",	/* O2NM_FENCE_RESET */
+		"panic",	/* O2NM_FENCE_PANIC */
+};
+
+struct o2nm_node *o2nm_get_node_by_num(u8 node_num)
+{
+	struct o2nm_node *node = NULL;
+
+	if (node_num >= O2NM_MAX_NODES || o2nm_single_cluster == NULL)
+		goto out;
+
+	read_lock(&o2nm_single_cluster->cl_nodes_lock);
+	node = o2nm_single_cluster->cl_nodes[node_num];
+	if (node)
+		config_item_get(&node->nd_item);
+	read_unlock(&o2nm_single_cluster->cl_nodes_lock);
+out:
+	return node;
+}
+EXPORT_SYMBOL_GPL(o2nm_get_node_by_num);
+
+int o2nm_configured_node_map(unsigned long *map, unsigned bytes)
+{
+	struct o2nm_cluster *cluster = o2nm_single_cluster;
+
+	BUG_ON(bytes < (sizeof(cluster->cl_nodes_bitmap)));
+
+	if (cluster == NULL)
+		return -EINVAL;
+
+	read_lock(&cluster->cl_nodes_lock);
+	memcpy(map, cluster->cl_nodes_bitmap, sizeof(cluster->cl_nodes_bitmap));
+	read_unlock(&cluster->cl_nodes_lock);
+
+	return 0;
+}
+EXPORT_SYMBOL_GPL(o2nm_configured_node_map);
+
+static struct o2nm_node *o2nm_node_ip_tree_lookup(struct o2nm_cluster *cluster,
+						  __be32 ip_needle,
+						  struct rb_node ***ret_p,
+						  struct rb_node **ret_parent)
+{
+	struct rb_node **p = &cluster->cl_node_ip_tree.rb_node;
+	struct rb_node *parent = NULL;
+	struct o2nm_node *node, *ret = NULL;
+
+	while (*p) {
+		int cmp;
+
+		parent = *p;
+		node = rb_entry(parent, struct o2nm_node, nd_ip_node);
+
+		cmp = memcmp(&ip_needle, &node->nd_ipv4_address,
+				sizeof(ip_needle));
+		if (cmp < 0)
+			p = &(*p)->rb_left;
+		else if (cmp > 0)
+			p = &(*p)->rb_right;
+		else {
+			ret = node;
+			break;
+		}
+	}
+
+	if (ret_p != NULL)
+		*ret_p = p;
+	if (ret_parent != NULL)
+		*ret_parent = parent;
+
+	return ret;
+}
+
+struct o2nm_node *o2nm_get_node_by_ip(__be32 addr)
+{
+	struct o2nm_node *node = NULL;
+	struct o2nm_cluster *cluster = o2nm_single_cluster;
+
+	if (cluster == NULL)
+		goto out;
+
+	read_lock(&cluster->cl_nodes_lock);
+	node = o2nm_node_ip_tree_lookup(cluster, addr, NULL, NULL);
+	if (node)
+		config_item_get(&node->nd_item);
+	read_unlock(&cluster->cl_nodes_lock);
+
+out:
+	return node;
+}
+EXPORT_SYMBOL_GPL(o2nm_get_node_by_ip);
+
+void o2nm_node_put(struct o2nm_node *node)
+{
+	config_item_put(&node->nd_item);
+}
+EXPORT_SYMBOL_GPL(o2nm_node_put);
+
+void o2nm_node_get(struct o2nm_node *node)
+{
+	config_item_get(&node->nd_item);
+}
+EXPORT_SYMBOL_GPL(o2nm_node_get);
+
+u8 o2nm_this_node(void)
+{
+	u8 node_num = O2NM_MAX_NODES;
+
+	if (o2nm_single_cluster && o2nm_single_cluster->cl_has_local)
+		node_num = o2nm_single_cluster->cl_local_node;
+
+	return node_num;
+}
+EXPORT_SYMBOL_GPL(o2nm_this_node);
+
+/* node configfs bits */
+
+static struct o2nm_cluster *to_o2nm_cluster(struct config_item *item)
+{
+	return item ?
+		container_of(to_config_group(item), struct o2nm_cluster,
+			     cl_group)
+		: NULL;
+}
+
+static struct o2nm_node *to_o2nm_node(struct config_item *item)
+{
+	return item ? container_of(item, struct o2nm_node, nd_item) : NULL;
+}
+
+static void o2nm_node_release(struct config_item *item)
+{
+	struct o2nm_node *node = to_o2nm_node(item);
+	kfree(node);
+}
+
+static ssize_t o2nm_node_num_read(struct o2nm_node *node, char *page)
+{
+	return sprintf(page, "%d\n", node->nd_num);
+}
+
+static struct o2nm_cluster *to_o2nm_cluster_from_node(struct o2nm_node *node)
+{
+	/* through the first node_set .parent
+	 * mycluster/nodes/mynode == o2nm_cluster->o2nm_node_group->o2nm_node */
+	return to_o2nm_cluster(node->nd_item.ci_parent->ci_parent);
+}
+
+enum {
+	O2NM_NODE_ATTR_NUM = 0,
+	O2NM_NODE_ATTR_PORT,
+	O2NM_NODE_ATTR_ADDRESS,
+	O2NM_NODE_ATTR_LOCAL,
+};
+
+static ssize_t o2nm_node_num_write(struct o2nm_node *node, const char *page,
+				   size_t count)
+{
+	struct o2nm_cluster *cluster = to_o2nm_cluster_from_node(node);
+	unsigned long tmp;
+	char *p = (char *)page;
+
+	tmp = simple_strtoul(p, &p, 0);
+	if (!p || (*p && (*p != '\n')))
+		return -EINVAL;
+
+	if (tmp >= O2NM_MAX_NODES)
+		return -ERANGE;
+
+	/* once we're in the cl_nodes tree networking can look us up by
+	 * node number and try to use our address and port attributes
+	 * to connect to this node.. make sure that they've been set
+	 * before writing the node attribute? */
+	if (!test_bit(O2NM_NODE_ATTR_ADDRESS, &node->nd_set_attributes) ||
+	    !test_bit(O2NM_NODE_ATTR_PORT, &node->nd_set_attributes))
+		return -EINVAL; /* XXX */
+
+	write_lock(&cluster->cl_nodes_lock);
+	if (cluster->cl_nodes[tmp])
+		p = NULL;
+	else  {
+		cluster->cl_nodes[tmp] = node;
+		node->nd_num = tmp;
+		set_bit(tmp, cluster->cl_nodes_bitmap);
+	}
+	write_unlock(&cluster->cl_nodes_lock);
+	if (p == NULL)
+		return -EEXIST;
+
+	return count;
+}
+static ssize_t o2nm_node_ipv4_port_read(struct o2nm_node *node, char *page)
+{
+	return sprintf(page, "%u\n", ntohs(node->nd_ipv4_port));
+}
+
+static ssize_t o2nm_node_ipv4_port_write(struct o2nm_node *node,
+					 const char *page, size_t count)
+{
+	unsigned long tmp;
+	char *p = (char *)page;
+
+	tmp = simple_strtoul(p, &p, 0);
+	if (!p || (*p && (*p != '\n')))
+		return -EINVAL;
+
+	if (tmp == 0)
+		return -EINVAL;
+	if (tmp >= (u16)-1)
+		return -ERANGE;
+
+	node->nd_ipv4_port = htons(tmp);
+
+	return count;
+}
+
+static ssize_t o2nm_node_ipv4_address_read(struct o2nm_node *node, char *page)
+{
+	return sprintf(page, "%pI4\n", &node->nd_ipv4_address);
+}
+
+static ssize_t o2nm_node_ipv4_address_write(struct o2nm_node *node,
+					    const char *page,
+					    size_t count)
+{
+	struct o2nm_cluster *cluster = to_o2nm_cluster_from_node(node);
+	int ret, i;
+	struct rb_node **p, *parent;
+	unsigned int octets[4];
+	__be32 ipv4_addr = 0;
+
+	ret = sscanf(page, "%3u.%3u.%3u.%3u", &octets[3], &octets[2],
+		     &octets[1], &octets[0]);
+	if (ret != 4)
+		return -EINVAL;
+
+	for (i = 0; i < ARRAY_SIZE(octets); i++) {
+		if (octets[i] > 255)
+			return -ERANGE;
+		be32_add_cpu(&ipv4_addr, octets[i] << (i * 8));
+	}
+
+	ret = 0;
+	write_lock(&cluster->cl_nodes_lock);
+	if (o2nm_node_ip_tree_lookup(cluster, ipv4_addr, &p, &parent))
+		ret = -EEXIST;
+	else {
+		rb_link_node(&node->nd_ip_node, parent, p);
+		rb_insert_color(&node->nd_ip_node, &cluster->cl_node_ip_tree);
+	}
+	write_unlock(&cluster->cl_nodes_lock);
+	if (ret)
+		return ret;
+
+	memcpy(&node->nd_ipv4_address, &ipv4_addr, sizeof(ipv4_addr));
+
+	return count;
+}
+
+static ssize_t o2nm_node_local_read(struct o2nm_node *node, char *page)
+{
+	return sprintf(page, "%d\n", node->nd_local);
+}
+
+static ssize_t o2nm_node_local_write(struct o2nm_node *node, const char *page,
+				     size_t count)
+{
+	struct o2nm_cluster *cluster = to_o2nm_cluster_from_node(node);
+	unsigned long tmp;
+	char *p = (char *)page;
+	ssize_t ret;
+
+	tmp = simple_strtoul(p, &p, 0);
+	if (!p || (*p && (*p != '\n')))
+		return -EINVAL;
+
+	tmp = !!tmp; /* boolean of whether this node wants to be local */
+
+	/* setting local turns on networking rx for now so we require having
+	 * set everything else first */
+	if (!test_bit(O2NM_NODE_ATTR_ADDRESS, &node->nd_set_attributes) ||
+	    !test_bit(O2NM_NODE_ATTR_NUM, &node->nd_set_attributes) ||
+	    !test_bit(O2NM_NODE_ATTR_PORT, &node->nd_set_attributes))
+		return -EINVAL; /* XXX */
+
+	/* the only failure case is trying to set a new local node
+	 * when a different one is already set */
+	if (tmp && tmp == cluster->cl_has_local &&
+	    cluster->cl_local_node != node->nd_num)
+		return -EBUSY;
+
+	/* bring up the rx thread if we're setting the new local node. */
+	if (tmp && !cluster->cl_has_local) {
+		ret = o2net_start_listening(node);
+		if (ret)
+			return ret;
+	}
+
+	if (!tmp && cluster->cl_has_local &&
+	    cluster->cl_local_node == node->nd_num) {
+		o2net_stop_listening(node);
+		cluster->cl_local_node = O2NM_INVALID_NODE_NUM;
+	}
+
+	node->nd_local = tmp;
+	if (node->nd_local) {
+		cluster->cl_has_local = tmp;
+		cluster->cl_local_node = node->nd_num;
+	}
+
+	return count;
+}
+
+struct o2nm_node_attribute {
+	struct configfs_attribute attr;
+	ssize_t (*show)(struct o2nm_node *, char *);
+	ssize_t (*store)(struct o2nm_node *, const char *, size_t);
+};
+
+static struct o2nm_node_attribute o2nm_node_attr_num = {
+	.attr	= { .ca_owner = THIS_MODULE,
+		    .ca_name = "num",
+		    .ca_mode = S_IRUGO | S_IWUSR },
+	.show	= o2nm_node_num_read,
+	.store	= o2nm_node_num_write,
+};
+
+static struct o2nm_node_attribute o2nm_node_attr_ipv4_port = {
+	.attr	= { .ca_owner = THIS_MODULE,
+		    .ca_name = "ipv4_port",
+		    .ca_mode = S_IRUGO | S_IWUSR },
+	.show	= o2nm_node_ipv4_port_read,
+	.store	= o2nm_node_ipv4_port_write,
+};
+
+static struct o2nm_node_attribute o2nm_node_attr_ipv4_address = {
+	.attr	= { .ca_owner = THIS_MODULE,
+		    .ca_name = "ipv4_address",
+		    .ca_mode = S_IRUGO | S_IWUSR },
+	.show	= o2nm_node_ipv4_address_read,
+	.store	= o2nm_node_ipv4_address_write,
+};
+
+static struct o2nm_node_attribute o2nm_node_attr_local = {
+	.attr	= { .ca_owner = THIS_MODULE,
+		    .ca_name = "local",
+		    .ca_mode = S_IRUGO | S_IWUSR },
+	.show	= o2nm_node_local_read,
+	.store	= o2nm_node_local_write,
+};
+
+static struct configfs_attribute *o2nm_node_attrs[] = {
+	[O2NM_NODE_ATTR_NUM] = &o2nm_node_attr_num.attr,
+	[O2NM_NODE_ATTR_PORT] = &o2nm_node_attr_ipv4_port.attr,
+	[O2NM_NODE_ATTR_ADDRESS] = &o2nm_node_attr_ipv4_address.attr,
+	[O2NM_NODE_ATTR_LOCAL] = &o2nm_node_attr_local.attr,
+	NULL,
+};
+
+static int o2nm_attr_index(struct configfs_attribute *attr)
+{
+	int i;
+	for (i = 0; i < ARRAY_SIZE(o2nm_node_attrs); i++) {
+		if (attr == o2nm_node_attrs[i])
+			return i;
+	}
+	BUG();
+	return 0;
+}
+
+static ssize_t o2nm_node_show(struct config_item *item,
+			      struct configfs_attribute *attr,
+			      char *page)
+{
+	struct o2nm_node *node = to_o2nm_node(item);
+	struct o2nm_node_attribute *o2nm_node_attr =
+		container_of(attr, struct o2nm_node_attribute, attr);
+	ssize_t ret = 0;
+
+	if (o2nm_node_attr->show)
+		ret = o2nm_node_attr->show(node, page);
+	return ret;
+}
+
+static ssize_t o2nm_node_store(struct config_item *item,
+			       struct configfs_attribute *attr,
+			       const char *page, size_t count)
+{
+	struct o2nm_node *node = to_o2nm_node(item);
+	struct o2nm_node_attribute *o2nm_node_attr =
+		container_of(attr, struct o2nm_node_attribute, attr);
+	ssize_t ret;
+	int attr_index = o2nm_attr_index(attr);
+
+	if (o2nm_node_attr->store == NULL) {
+		ret = -EINVAL;
+		goto out;
+	}
+
+	if (test_bit(attr_index, &node->nd_set_attributes))
+		return -EBUSY;
+
+	ret = o2nm_node_attr->store(node, page, count);
+	if (ret < count)
+		goto out;
+
+	set_bit(attr_index, &node->nd_set_attributes);
+out:
+	return ret;
+}
+
+static struct configfs_item_operations o2nm_node_item_ops = {
+	.release		= o2nm_node_release,
+	.show_attribute		= o2nm_node_show,
+	.store_attribute	= o2nm_node_store,
+};
+
+static struct config_item_type o2nm_node_type = {
+	.ct_item_ops	= &o2nm_node_item_ops,
+	.ct_attrs	= o2nm_node_attrs,
+	.ct_owner	= THIS_MODULE,
+};
+
+/* node set */
+
+struct o2nm_node_group {
+	struct config_group ns_group;
+	/* some stuff? */
+};
+
+#if 0
+static struct o2nm_node_group *to_o2nm_node_group(struct config_group *group)
+{
+	return group ?
+		container_of(group, struct o2nm_node_group, ns_group)
+		: NULL;
+}
+#endif
+
+struct o2nm_cluster_attribute {
+	struct configfs_attribute attr;
+	ssize_t (*show)(struct o2nm_cluster *, char *);
+	ssize_t (*store)(struct o2nm_cluster *, const char *, size_t);
+};
+
+static ssize_t o2nm_cluster_attr_write(const char *page, ssize_t count,
+                                       unsigned int *val)
+{
+	unsigned long tmp;
+	char *p = (char *)page;
+
+	tmp = simple_strtoul(p, &p, 0);
+	if (!p || (*p && (*p != '\n')))
+		return -EINVAL;
+
+	if (tmp == 0)
+		return -EINVAL;
+	if (tmp >= (u32)-1)
+		return -ERANGE;
+
+	*val = tmp;
+
+	return count;
+}
+
+static ssize_t o2nm_cluster_attr_idle_timeout_ms_read(
+	struct o2nm_cluster *cluster, char *page)
+{
+	return sprintf(page, "%u\n", cluster->cl_idle_timeout_ms);
+}
+
+static ssize_t o2nm_cluster_attr_idle_timeout_ms_write(
+	struct o2nm_cluster *cluster, const char *page, size_t count)
+{
+	ssize_t ret;
+	unsigned int val;
+
+	ret =  o2nm_cluster_attr_write(page, count, &val);
+
+	if (ret > 0) {
+		if (cluster->cl_idle_timeout_ms != val
+			&& o2net_num_connected_peers()) {
+			mlog(ML_NOTICE,
+			     "o2net: cannot change idle timeout after "
+			     "the first peer has agreed to it."
+			     "  %d connected peers\n",
+			     o2net_num_connected_peers());
+			ret = -EINVAL;
+		} else if (val <= cluster->cl_keepalive_delay_ms) {
+			mlog(ML_NOTICE, "o2net: idle timeout must be larger "
+			     "than keepalive delay\n");
+			ret = -EINVAL;
+		} else {
+			cluster->cl_idle_timeout_ms = val;
+		}
+	}
+
+	return ret;
+}
+
+static ssize_t o2nm_cluster_attr_keepalive_delay_ms_read(
+	struct o2nm_cluster *cluster, char *page)
+{
+	return sprintf(page, "%u\n", cluster->cl_keepalive_delay_ms);
+}
+
+static ssize_t o2nm_cluster_attr_keepalive_delay_ms_write(
+	struct o2nm_cluster *cluster, const char *page, size_t count)
+{
+	ssize_t ret;
+	unsigned int val;
+
+	ret =  o2nm_cluster_attr_write(page, count, &val);
+
+	if (ret > 0) {
+		if (cluster->cl_keepalive_delay_ms != val
+		    && o2net_num_connected_peers()) {
+			mlog(ML_NOTICE,
+			     "o2net: cannot change keepalive delay after"
+			     " the first peer has agreed to it."
+			     "  %d connected peers\n",
+			     o2net_num_connected_peers());
+			ret = -EINVAL;
+		} else if (val >= cluster->cl_idle_timeout_ms) {
+			mlog(ML_NOTICE, "o2net: keepalive delay must be "
+			     "smaller than idle timeout\n");
+			ret = -EINVAL;
+		} else {
+			cluster->cl_keepalive_delay_ms = val;
+		}
+	}
+
+	return ret;
+}
+
+static ssize_t o2nm_cluster_attr_reconnect_delay_ms_read(
+	struct o2nm_cluster *cluster, char *page)
+{
+	return sprintf(page, "%u\n", cluster->cl_reconnect_delay_ms);
+}
+
+static ssize_t o2nm_cluster_attr_reconnect_delay_ms_write(
+	struct o2nm_cluster *cluster, const char *page, size_t count)
+{
+	return o2nm_cluster_attr_write(page, count,
+	                               &cluster->cl_reconnect_delay_ms);
+}
+
+static ssize_t o2nm_cluster_attr_fence_method_read(
+	struct o2nm_cluster *cluster, char *page)
+{
+	ssize_t ret = 0;
+
+	if (cluster)
+		ret = sprintf(page, "%s\n",
+			      o2nm_fence_method_desc[cluster->cl_fence_method]);
+	return ret;
+}
+
+static ssize_t o2nm_cluster_attr_fence_method_write(
+	struct o2nm_cluster *cluster, const char *page, size_t count)
+{
+	unsigned int i;
+
+	if (page[count - 1] != '\n')
+		goto bail;
+
+	for (i = 0; i < O2NM_FENCE_METHODS; ++i) {
+		if (count != strlen(o2nm_fence_method_desc[i]) + 1)
+			continue;
+		if (strncasecmp(page, o2nm_fence_method_desc[i], count - 1))
+			continue;
+		if (cluster->cl_fence_method != i) {
+			printk(KERN_INFO "ocfs2: Changing fence method to %s\n",
+			       o2nm_fence_method_desc[i]);
+			cluster->cl_fence_method = i;
+		}
+		return count;
+	}
+
+bail:
+	return -EINVAL;
+}
+
+static struct o2nm_cluster_attribute o2nm_cluster_attr_idle_timeout_ms = {
+	.attr	= { .ca_owner = THIS_MODULE,
+		    .ca_name = "idle_timeout_ms",
+		    .ca_mode = S_IRUGO | S_IWUSR },
+	.show	= o2nm_cluster_attr_idle_timeout_ms_read,
+	.store	= o2nm_cluster_attr_idle_timeout_ms_write,
+};
+
+static struct o2nm_cluster_attribute o2nm_cluster_attr_keepalive_delay_ms = {
+	.attr	= { .ca_owner = THIS_MODULE,
+		    .ca_name = "keepalive_delay_ms",
+		    .ca_mode = S_IRUGO | S_IWUSR },
+	.show	= o2nm_cluster_attr_keepalive_delay_ms_read,
+	.store	= o2nm_cluster_attr_keepalive_delay_ms_write,
+};
+
+static struct o2nm_cluster_attribute o2nm_cluster_attr_reconnect_delay_ms = {
+	.attr	= { .ca_owner = THIS_MODULE,
+		    .ca_name = "reconnect_delay_ms",
+		    .ca_mode = S_IRUGO | S_IWUSR },
+	.show	= o2nm_cluster_attr_reconnect_delay_ms_read,
+	.store	= o2nm_cluster_attr_reconnect_delay_ms_write,
+};
+
+static struct o2nm_cluster_attribute o2nm_cluster_attr_fence_method = {
+	.attr	= { .ca_owner = THIS_MODULE,
+		    .ca_name = "fence_method",
+		    .ca_mode = S_IRUGO | S_IWUSR },
+	.show	= o2nm_cluster_attr_fence_method_read,
+	.store	= o2nm_cluster_attr_fence_method_write,
+};
+
+static struct configfs_attribute *o2nm_cluster_attrs[] = {
+	&o2nm_cluster_attr_idle_timeout_ms.attr,
+	&o2nm_cluster_attr_keepalive_delay_ms.attr,
+	&o2nm_cluster_attr_reconnect_delay_ms.attr,
+	&o2nm_cluster_attr_fence_method.attr,
+	NULL,
+};
+static ssize_t o2nm_cluster_show(struct config_item *item,
+                                 struct configfs_attribute *attr,
+                                 char *page)
+{
+	struct o2nm_cluster *cluster = to_o2nm_cluster(item);
+	struct o2nm_cluster_attribute *o2nm_cluster_attr =
+		container_of(attr, struct o2nm_cluster_attribute, attr);
+	ssize_t ret = 0;
+
+	if (o2nm_cluster_attr->show)
+		ret = o2nm_cluster_attr->show(cluster, page);
+	return ret;
+}
+
+static ssize_t o2nm_cluster_store(struct config_item *item,
+                                  struct configfs_attribute *attr,
+                                  const char *page, size_t count)
+{
+	struct o2nm_cluster *cluster = to_o2nm_cluster(item);
+	struct o2nm_cluster_attribute *o2nm_cluster_attr =
+		container_of(attr, struct o2nm_cluster_attribute, attr);
+	ssize_t ret;
+
+	if (o2nm_cluster_attr->store == NULL) {
+		ret = -EINVAL;
+		goto out;
+	}
+
+	ret = o2nm_cluster_attr->store(cluster, page, count);
+	if (ret < count)
+		goto out;
+out:
+	return ret;
+}
+
+static struct config_item *o2nm_node_group_make_item(struct config_group *group,
+						     const char *name)
+{
+	struct o2nm_node *node = NULL;
+
+	if (strlen(name) > O2NM_MAX_NAME_LEN)
+		return ERR_PTR(-ENAMETOOLONG);
+
+	node = kzalloc(sizeof(struct o2nm_node), GFP_KERNEL);
+	if (node == NULL)
+		return ERR_PTR(-ENOMEM);
+
+	strcpy(node->nd_name, name); /* use item.ci_namebuf instead? */
+	config_item_init_type_name(&node->nd_item, name, &o2nm_node_type);
+	spin_lock_init(&node->nd_lock);
+
+	mlog(ML_CLUSTER, "o2nm: Registering node %s\n", name);
+
+	return &node->nd_item;
+}
+
+static void o2nm_node_group_drop_item(struct config_group *group,
+				      struct config_item *item)
+{
+	struct o2nm_node *node = to_o2nm_node(item);
+	struct o2nm_cluster *cluster = to_o2nm_cluster(group->cg_item.ci_parent);
+
+	o2net_disconnect_node(node);
+
+	if (cluster->cl_has_local &&
+	    (cluster->cl_local_node == node->nd_num)) {
+		cluster->cl_has_local = 0;
+		cluster->cl_local_node = O2NM_INVALID_NODE_NUM;
+		o2net_stop_listening(node);
+	}
+
+	/* XXX call into net to stop this node from trading messages */
+
+	write_lock(&cluster->cl_nodes_lock);
+
+	/* XXX sloppy */
+	if (node->nd_ipv4_address)
+		rb_erase(&node->nd_ip_node, &cluster->cl_node_ip_tree);
+
+	/* nd_num might be 0 if the node number hasn't been set.. */
+	if (cluster->cl_nodes[node->nd_num] == node) {
+		cluster->cl_nodes[node->nd_num] = NULL;
+		clear_bit(node->nd_num, cluster->cl_nodes_bitmap);
+	}
+	write_unlock(&cluster->cl_nodes_lock);
+
+	mlog(ML_CLUSTER, "o2nm: Unregistered node %s\n",
+	     config_item_name(&node->nd_item));
+
+	config_item_put(item);
+}
+
+static struct configfs_group_operations o2nm_node_group_group_ops = {
+	.make_item	= o2nm_node_group_make_item,
+	.drop_item	= o2nm_node_group_drop_item,
+};
+
+static struct config_item_type o2nm_node_group_type = {
+	.ct_group_ops	= &o2nm_node_group_group_ops,
+	.ct_owner	= THIS_MODULE,
+};
+
+/* cluster */
+
+static void o2nm_cluster_release(struct config_item *item)
+{
+	struct o2nm_cluster *cluster = to_o2nm_cluster(item);
+
+	kfree(cluster->cl_group.default_groups);
+	kfree(cluster);
+}
+
+static struct configfs_item_operations o2nm_cluster_item_ops = {
+	.release	= o2nm_cluster_release,
+	.show_attribute		= o2nm_cluster_show,
+	.store_attribute	= o2nm_cluster_store,
+};
+
+static struct config_item_type o2nm_cluster_type = {
+	.ct_item_ops	= &o2nm_cluster_item_ops,
+	.ct_attrs	= o2nm_cluster_attrs,
+	.ct_owner	= THIS_MODULE,
+};
+
+/* cluster set */
+
+struct o2nm_cluster_group {
+	struct configfs_subsystem cs_subsys;
+	/* some stuff? */
+};
+
+#if 0
+static struct o2nm_cluster_group *to_o2nm_cluster_group(struct config_group *group)
+{
+	return group ?
+		container_of(to_configfs_subsystem(group), struct o2nm_cluster_group, cs_subsys)
+	       : NULL;
+}
+#endif
+
+static struct config_group *o2nm_cluster_group_make_group(struct config_group *group,
+							  const char *name)
+{
+	struct o2nm_cluster *cluster = NULL;
+	struct o2nm_node_group *ns = NULL;
+	struct config_group *o2hb_group = NULL, *ret = NULL;
+	void *defs = NULL;
+
+	/* this runs under the parent dir's i_mutex; there can be only
+	 * one caller in here at a time */
+	if (o2nm_single_cluster)
+		return ERR_PTR(-ENOSPC);
+
+	cluster = kzalloc(sizeof(struct o2nm_cluster), GFP_KERNEL);
+	ns = kzalloc(sizeof(struct o2nm_node_group), GFP_KERNEL);
+	defs = kcalloc(3, sizeof(struct config_group *), GFP_KERNEL);
+	o2hb_group = o2hb_alloc_hb_set();
+	if (cluster == NULL || ns == NULL || o2hb_group == NULL || defs == NULL)
+		goto out;
+
+	config_group_init_type_name(&cluster->cl_group, name,
+				    &o2nm_cluster_type);
+	config_group_init_type_name(&ns->ns_group, "node",
+				    &o2nm_node_group_type);
+
+	cluster->cl_group.default_groups = defs;
+	cluster->cl_group.default_groups[0] = &ns->ns_group;
+	cluster->cl_group.default_groups[1] = o2hb_group;
+	cluster->cl_group.default_groups[2] = NULL;
+	rwlock_init(&cluster->cl_nodes_lock);
+	cluster->cl_node_ip_tree = RB_ROOT;
+	cluster->cl_reconnect_delay_ms = O2NET_RECONNECT_DELAY_MS_DEFAULT;
+	cluster->cl_idle_timeout_ms    = O2NET_IDLE_TIMEOUT_MS_DEFAULT;
+	cluster->cl_keepalive_delay_ms = O2NET_KEEPALIVE_DELAY_MS_DEFAULT;
+	cluster->cl_fence_method       = O2NM_FENCE_RESET;
+
+	ret = &cluster->cl_group;
+	o2nm_single_cluster = cluster;
+
+out:
+	if (ret == NULL) {
+		kfree(cluster);
+		kfree(ns);
+		o2hb_free_hb_set(o2hb_group);
+		kfree(defs);
+		ret = ERR_PTR(-ENOMEM);
+	}
+
+	return ret;
+}
+
+static void o2nm_cluster_group_drop_item(struct config_group *group, struct config_item *item)
+{
+	struct o2nm_cluster *cluster = to_o2nm_cluster(item);
+	int i;
+	struct config_item *killme;
+
+	BUG_ON(o2nm_single_cluster != cluster);
+	o2nm_single_cluster = NULL;
+
+	for (i = 0; cluster->cl_group.default_groups[i]; i++) {
+		killme = &cluster->cl_group.default_groups[i]->cg_item;
+		cluster->cl_group.default_groups[i] = NULL;
+		config_item_put(killme);
+	}
+
+	config_item_put(item);
+}
+
+static struct configfs_group_operations o2nm_cluster_group_group_ops = {
+	.make_group	= o2nm_cluster_group_make_group,
+	.drop_item	= o2nm_cluster_group_drop_item,
+};
+
+static struct config_item_type o2nm_cluster_group_type = {
+	.ct_group_ops	= &o2nm_cluster_group_group_ops,
+	.ct_owner	= THIS_MODULE,
+};
+
+static struct o2nm_cluster_group o2nm_cluster_group = {
+	.cs_subsys = {
+		.su_group = {
+			.cg_item = {
+				.ci_namebuf = "cluster",
+				.ci_type = &o2nm_cluster_group_type,
+			},
+		},
+	},
+};
+
+int o2nm_depend_item(struct config_item *item)
+{
+	return configfs_depend_item(&o2nm_cluster_group.cs_subsys, item);
+}
+
+void o2nm_undepend_item(struct config_item *item)
+{
+	configfs_undepend_item(&o2nm_cluster_group.cs_subsys, item);
+}
+
+int o2nm_depend_this_node(void)
+{
+	int ret = 0;
+	struct o2nm_node *local_node;
+
+	local_node = o2nm_get_node_by_num(o2nm_this_node());
+	if (!local_node) {
+		ret = -EINVAL;
+		goto out;
+	}
+
+	ret = o2nm_depend_item(&local_node->nd_item);
+	o2nm_node_put(local_node);
+
+out:
+	return ret;
+}
+
+void o2nm_undepend_this_node(void)
+{
+	struct o2nm_node *local_node;
+
+	local_node = o2nm_get_node_by_num(o2nm_this_node());
+	BUG_ON(!local_node);
+
+	o2nm_undepend_item(&local_node->nd_item);
+	o2nm_node_put(local_node);
+}
+
+
+static void __exit exit_o2nm(void)
+{
+	/* XXX sync with hb callbacks and shut down hb? */
+	o2net_unregister_hb_callbacks();
+	configfs_unregister_subsystem(&o2nm_cluster_group.cs_subsys);
+	o2cb_sys_shutdown();
+
+	o2net_exit();
+	o2hb_exit();
+}
+
+static int __init init_o2nm(void)
+{
+	int ret = -1;
+
+	cluster_print_version();
+
+	ret = o2hb_init();
+	if (ret)
+		goto out;
+
+	ret = o2net_init();
+	if (ret)
+		goto out_o2hb;
+
+	ret = o2net_register_hb_callbacks();
+	if (ret)
+		goto out_o2net;
+
+	config_group_init(&o2nm_cluster_group.cs_subsys.su_group);
+	mutex_init(&o2nm_cluster_group.cs_subsys.su_mutex);
+	ret = configfs_register_subsystem(&o2nm_cluster_group.cs_subsys);
+	if (ret) {
+		printk(KERN_ERR "nodemanager: Registration returned %d\n", ret);
+		goto out_callbacks;
+	}
+
+	ret = o2cb_sys_init();
+	if (!ret)
+		goto out;
+
+	configfs_unregister_subsystem(&o2nm_cluster_group.cs_subsys);
+out_callbacks:
+	o2net_unregister_hb_callbacks();
+out_o2net:
+	o2net_exit();
+out_o2hb:
+	o2hb_exit();
+out:
+	return ret;
+}
+
+MODULE_AUTHOR("Oracle");
+MODULE_LICENSE("GPL");
+
+module_init(init_o2nm)
+module_exit(exit_o2nm)
diff --git a/drivers/staging/ramster/cluster/nodemanager.h b/drivers/staging/ramster/cluster/nodemanager.h
new file mode 100644
index 0000000..09ea2d3
--- /dev/null
+++ b/drivers/staging/ramster/cluster/nodemanager.h
@@ -0,0 +1,88 @@
+/* -*- mode: c; c-basic-offset: 8; -*-
+ * vim: noexpandtab sw=8 ts=8 sts=0:
+ *
+ * nodemanager.h
+ *
+ * Function prototypes
+ *
+ * Copyright (C) 2004 Oracle.  All rights reserved.
+ *
+ * This program is free software; you can redistribute it and/or
+ * modify it under the terms of the GNU General Public
+ * License as published by the Free Software Foundation; either
+ * version 2 of the License, or (at your option) any later version.
+ *
+ * This program is distributed in the hope that it will be useful,
+ * but WITHOUT ANY WARRANTY; without even the implied warranty of
+ * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
+ * General Public License for more details.
+ *
+ * You should have received a copy of the GNU General Public
+ * License along with this program; if not, write to the
+ * Free Software Foundation, Inc., 59 Temple Place - Suite 330,
+ * Boston, MA 021110-1307, USA.
+ *
+ */
+
+#ifndef O2CLUSTER_NODEMANAGER_H
+#define O2CLUSTER_NODEMANAGER_H
+
+#include "ocfs2_nodemanager.h"
+
+/* This totally doesn't belong here. */
+#include <linux/configfs.h>
+#include <linux/rbtree.h>
+
+enum o2nm_fence_method {
+	O2NM_FENCE_RESET	= 0,
+	O2NM_FENCE_PANIC,
+	O2NM_FENCE_METHODS,	/* Number of fence methods */
+};
+
+struct o2nm_node {
+	spinlock_t		nd_lock;
+	struct config_item	nd_item;
+	char			nd_name[O2NM_MAX_NAME_LEN+1]; /* replace? */
+	__u8			nd_num;
+	/* only one address per node, as attributes, for now. */
+	__be32			nd_ipv4_address;
+	__be16			nd_ipv4_port;
+	struct rb_node		nd_ip_node;
+	/* there can be only one local node for now */
+	int			nd_local;
+
+	unsigned long		nd_set_attributes;
+};
+
+struct o2nm_cluster {
+	struct config_group	cl_group;
+	unsigned		cl_has_local:1;
+	u8			cl_local_node;
+	rwlock_t		cl_nodes_lock;
+	struct o2nm_node  	*cl_nodes[O2NM_MAX_NODES];
+	struct rb_root		cl_node_ip_tree;
+	unsigned int		cl_idle_timeout_ms;
+	unsigned int		cl_keepalive_delay_ms;
+	unsigned int		cl_reconnect_delay_ms;
+	enum o2nm_fence_method	cl_fence_method;
+
+	/* this bitmap is part of a hack for disk bitmap.. will go eventually. - zab */
+	unsigned long	cl_nodes_bitmap[BITS_TO_LONGS(O2NM_MAX_NODES)];
+};
+
+extern struct o2nm_cluster *o2nm_single_cluster;
+
+u8 o2nm_this_node(void);
+
+int o2nm_configured_node_map(unsigned long *map, unsigned bytes);
+struct o2nm_node *o2nm_get_node_by_num(u8 node_num);
+struct o2nm_node *o2nm_get_node_by_ip(__be32 addr);
+void o2nm_node_get(struct o2nm_node *node);
+void o2nm_node_put(struct o2nm_node *node);
+
+int o2nm_depend_item(struct config_item *item);
+void o2nm_undepend_item(struct config_item *item);
+int o2nm_depend_this_node(void);
+void o2nm_undepend_this_node(void);
+
+#endif /* O2CLUSTER_NODEMANAGER_H */
diff --git a/drivers/staging/ramster/cluster/ocfs2_heartbeat.h b/drivers/staging/ramster/cluster/ocfs2_heartbeat.h
new file mode 100644
index 0000000..3f4151d
--- /dev/null
+++ b/drivers/staging/ramster/cluster/ocfs2_heartbeat.h
@@ -0,0 +1,38 @@
+/* -*- mode: c; c-basic-offset: 8; -*-
+ * vim: noexpandtab sw=8 ts=8 sts=0:
+ *
+ * ocfs2_heartbeat.h
+ *
+ * On-disk structures for ocfs2_heartbeat
+ *
+ * Copyright (C) 2002, 2004 Oracle.  All rights reserved.
+ *
+ * This program is free software; you can redistribute it and/or
+ * modify it under the terms of the GNU General Public
+ * License as published by the Free Software Foundation; either
+ * version 2 of the License, or (at your option) any later version.
+ *
+ * This program is distributed in the hope that it will be useful,
+ * but WITHOUT ANY WARRANTY; without even the implied warranty of
+ * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
+ * General Public License for more details.
+ *
+ * You should have received a copy of the GNU General Public
+ * License along with this program; if not, write to the
+ * Free Software Foundation, Inc., 59 Temple Place - Suite 330,
+ * Boston, MA 021110-1307, USA.
+ */
+
+#ifndef _OCFS2_HEARTBEAT_H
+#define _OCFS2_HEARTBEAT_H
+
+struct o2hb_disk_heartbeat_block {
+	__le64 hb_seq;
+	__u8  hb_node;
+	__u8  hb_pad1[3];
+	__le32 hb_cksum;
+	__le64 hb_generation;
+	__le32 hb_dead_ms;
+};
+
+#endif /* _OCFS2_HEARTBEAT_H */
diff --git a/drivers/staging/ramster/cluster/ocfs2_nodemanager.h b/drivers/staging/ramster/cluster/ocfs2_nodemanager.h
new file mode 100644
index 0000000..49b5943
--- /dev/null
+++ b/drivers/staging/ramster/cluster/ocfs2_nodemanager.h
@@ -0,0 +1,45 @@
+/* -*- mode: c; c-basic-offset: 8; -*-
+ * vim: noexpandtab sw=8 ts=8 sts=0:
+ *
+ * ocfs2_nodemanager.h
+ *
+ * Header describing the interface between userspace and the kernel
+ * for the ocfs2_nodemanager module.
+ *
+ * Copyright (C) 2002, 2004 Oracle.  All rights reserved.
+ *
+ * This program is free software; you can redistribute it and/or
+ * modify it under the terms of the GNU General Public
+ * License as published by the Free Software Foundation; either
+ * version 2 of the License, or (at your option) any later version.
+ *
+ * This program is distributed in the hope that it will be useful,
+ * but WITHOUT ANY WARRANTY; without even the implied warranty of
+ * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
+ * General Public License for more details.
+ *
+ * You should have received a copy of the GNU General Public
+ * License along with this program; if not, write to the
+ * Free Software Foundation, Inc., 59 Temple Place - Suite 330,
+ * Boston, MA 021110-1307, USA.
+ *
+ */
+
+#ifndef _OCFS2_NODEMANAGER_H
+#define _OCFS2_NODEMANAGER_H
+
+#define O2NM_API_VERSION	5
+
+#define O2NM_MAX_NODES		255
+#define O2NM_INVALID_NODE_NUM	255
+
+/* host name, group name, cluster name all 64 bytes */
+#define O2NM_MAX_NAME_LEN        64    // __NEW_UTS_LEN
+
+/*
+ * Maximum number of global heartbeat regions allowed.
+ * **CAUTION**  Changing this number will break dlm compatibility.
+ */
+#define O2NM_MAX_REGIONS	32
+
+#endif /* _OCFS2_NODEMANAGER_H */
diff --git a/drivers/staging/ramster/cluster/quorum.c b/drivers/staging/ramster/cluster/quorum.c
new file mode 100644
index 0000000..8f9cea1
--- /dev/null
+++ b/drivers/staging/ramster/cluster/quorum.c
@@ -0,0 +1,331 @@
+/* -*- mode: c; c-basic-offset: 8; -*-
+ *
+ * vim: noexpandtab sw=8 ts=8 sts=0:
+ *
+ * Copyright (C) 2005 Oracle.  All rights reserved.
+ *
+ * This program is free software; you can redistribute it and/or
+ * modify it under the terms of the GNU General Public
+ * License as published by the Free Software Foundation; either
+ * version 2 of the License, or (at your option) any later version.
+ *
+ * This program is distributed in the hope that it will be useful,
+ * but WITHOUT ANY WARRANTY; without even the implied warranty of
+ * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
+ * General Public License for more details.
+ *
+ * You should have received a copy of the GNU General Public
+ * License along with this program; if not, write to the
+ * Free Software Foundation, Inc., 59 Temple Place - Suite 330,
+ * Boston, MA 021110-1307, USA.
+ */
+
+/* This quorum hack is only here until we transition to some more rational
+ * approach that is driven from userspace.  Honest.  No foolin'.
+ *
+ * Imagine two nodes lose network connectivity to each other but they're still
+ * up and operating in every other way.  Presumably a network timeout indicates
+ * that a node is broken and should be recovered.  They can't both recover each
+ * other and both carry on without serialising their access to the file system.
+ * They need to decide who is authoritative.  Now extend that problem to
+ * arbitrary groups of nodes losing connectivity between each other.
+ *
+ * So we declare that a node which has given up on connecting to a majority
+ * of nodes who are still heartbeating will fence itself.
+ *
+ * There are huge opportunities for races here.  After we give up on a node's
+ * connection we need to wait long enough to give heartbeat an opportunity
+ * to declare the node as truly dead.  We also need to be careful with the
+ * race between when we see a node start heartbeating and when we connect
+ * to it.
+ *
+ * So nodes that are in this transtion put a hold on the quorum decision
+ * with a counter.  As they fall out of this transition they drop the count
+ * and if they're the last, they fire off the decision.
+ */
+#include <linux/kernel.h>
+#include <linux/workqueue.h>
+#include <linux/reboot.h>
+
+#include "heartbeat.h"
+#include "nodemanager.h"
+#define MLOG_MASK_PREFIX ML_QUORUM
+#include "masklog.h"
+#include "quorum.h"
+
+static struct o2quo_state {
+	spinlock_t		qs_lock;
+	struct work_struct	qs_work;
+	int			qs_pending;
+	int			qs_heartbeating;
+	unsigned long		qs_hb_bm[BITS_TO_LONGS(O2NM_MAX_NODES)];
+	int			qs_connected;
+	unsigned long		qs_conn_bm[BITS_TO_LONGS(O2NM_MAX_NODES)];
+	int			qs_holds;
+	unsigned long		qs_hold_bm[BITS_TO_LONGS(O2NM_MAX_NODES)];
+} o2quo_state;
+
+/* this is horribly heavy-handed.  It should instead flip the file
+ * system RO and call some userspace script. */
+static void o2quo_fence_self(void)
+{
+	/* panic spins with interrupts enabled.  with preempt
+	 * threads can still schedule, etc, etc */
+	o2hb_stop_all_regions();
+
+	switch (o2nm_single_cluster->cl_fence_method) {
+	case O2NM_FENCE_PANIC:
+		panic("*** ocfs2 is very sorry to be fencing this system by "
+		      "panicing ***\n");
+		break;
+	default:
+		WARN_ON(o2nm_single_cluster->cl_fence_method >=
+			O2NM_FENCE_METHODS);
+	case O2NM_FENCE_RESET:
+		printk(KERN_ERR "*** ocfs2 is very sorry to be fencing this "
+		       "system by restarting ***\n");
+		emergency_restart();
+		break;
+	};
+}
+
+/* Indicate that a timeout occurred on a hearbeat region write. The
+ * other nodes in the cluster may consider us dead at that time so we
+ * want to "fence" ourselves so that we don't scribble on the disk
+ * after they think they've recovered us. This can't solve all
+ * problems related to writeout after recovery but this hack can at
+ * least close some of those gaps. When we have real fencing, this can
+ * go away as our node would be fenced externally before other nodes
+ * begin recovery. */
+void o2quo_disk_timeout(void)
+{
+	o2quo_fence_self();
+}
+
+static void o2quo_make_decision(struct work_struct *work)
+{
+	int quorum;
+	int lowest_hb, lowest_reachable = 0, fence = 0;
+	struct o2quo_state *qs = &o2quo_state;
+
+	spin_lock(&qs->qs_lock);
+
+	lowest_hb = find_first_bit(qs->qs_hb_bm, O2NM_MAX_NODES);
+	if (lowest_hb != O2NM_MAX_NODES)
+		lowest_reachable = test_bit(lowest_hb, qs->qs_conn_bm);
+
+	mlog(0, "heartbeating: %d, connected: %d, "
+	     "lowest: %d (%sreachable)\n", qs->qs_heartbeating,
+	     qs->qs_connected, lowest_hb, lowest_reachable ? "" : "un");
+
+	if (!test_bit(o2nm_this_node(), qs->qs_hb_bm) ||
+	    qs->qs_heartbeating == 1)
+		goto out;
+
+	if (qs->qs_heartbeating & 1) {
+		/* the odd numbered cluster case is straight forward --
+		 * if we can't talk to the majority we're hosed */
+		quorum = (qs->qs_heartbeating + 1)/2;
+		if (qs->qs_connected < quorum) {
+			mlog(ML_ERROR, "fencing this node because it is "
+			     "only connected to %u nodes and %u is needed "
+			     "to make a quorum out of %u heartbeating nodes\n",
+			     qs->qs_connected, quorum,
+			     qs->qs_heartbeating);
+			fence = 1;
+		}
+	} else {
+		/* the even numbered cluster adds the possibility of each half
+		 * of the cluster being able to talk amongst themselves.. in
+		 * that case we're hosed if we can't talk to the group that has
+		 * the lowest numbered node */
+		quorum = qs->qs_heartbeating / 2;
+		if (qs->qs_connected < quorum) {
+			mlog(ML_ERROR, "fencing this node because it is "
+			     "only connected to %u nodes and %u is needed "
+			     "to make a quorum out of %u heartbeating nodes\n",
+			     qs->qs_connected, quorum,
+			     qs->qs_heartbeating);
+			fence = 1;
+		}
+		else if ((qs->qs_connected == quorum) &&
+			 !lowest_reachable) {
+			mlog(ML_ERROR, "fencing this node because it is "
+			     "connected to a half-quorum of %u out of %u "
+			     "nodes which doesn't include the lowest active "
+			     "node %u\n", quorum, qs->qs_heartbeating,
+			     lowest_hb);
+			fence = 1;
+		}
+	}
+
+out:
+	spin_unlock(&qs->qs_lock);
+	if (fence)
+		o2quo_fence_self();
+}
+
+static void o2quo_set_hold(struct o2quo_state *qs, u8 node)
+{
+	assert_spin_locked(&qs->qs_lock);
+
+	if (!test_and_set_bit(node, qs->qs_hold_bm)) {
+		qs->qs_holds++;
+		mlog_bug_on_msg(qs->qs_holds == O2NM_MAX_NODES,
+			        "node %u\n", node);
+		mlog(0, "node %u, %d total\n", node, qs->qs_holds);
+	}
+}
+
+static void o2quo_clear_hold(struct o2quo_state *qs, u8 node)
+{
+	assert_spin_locked(&qs->qs_lock);
+
+	if (test_and_clear_bit(node, qs->qs_hold_bm)) {
+		mlog(0, "node %u, %d total\n", node, qs->qs_holds - 1);
+		if (--qs->qs_holds == 0) {
+			if (qs->qs_pending) {
+				qs->qs_pending = 0;
+				schedule_work(&qs->qs_work);
+			}
+		}
+		mlog_bug_on_msg(qs->qs_holds < 0, "node %u, holds %d\n",
+				node, qs->qs_holds);
+	}
+}
+
+/* as a node comes up we delay the quorum decision until we know the fate of
+ * the connection.  the hold will be droped in conn_up or hb_down.  it might be
+ * perpetuated by con_err until hb_down.  if we already have a conn, we might
+ * be dropping a hold that conn_up got. */
+void o2quo_hb_up(u8 node)
+{
+	struct o2quo_state *qs = &o2quo_state;
+
+	spin_lock(&qs->qs_lock);
+
+	qs->qs_heartbeating++;
+	mlog_bug_on_msg(qs->qs_heartbeating == O2NM_MAX_NODES,
+		        "node %u\n", node);
+	mlog_bug_on_msg(test_bit(node, qs->qs_hb_bm), "node %u\n", node);
+	set_bit(node, qs->qs_hb_bm);
+
+	mlog(0, "node %u, %d total\n", node, qs->qs_heartbeating);
+
+	if (!test_bit(node, qs->qs_conn_bm))
+		o2quo_set_hold(qs, node);
+	else
+		o2quo_clear_hold(qs, node);
+
+	spin_unlock(&qs->qs_lock);
+}
+
+/* hb going down releases any holds we might have had due to this node from
+ * conn_up, conn_err, or hb_up */
+void o2quo_hb_down(u8 node)
+{
+	struct o2quo_state *qs = &o2quo_state;
+
+	spin_lock(&qs->qs_lock);
+
+	qs->qs_heartbeating--;
+	mlog_bug_on_msg(qs->qs_heartbeating < 0,
+			"node %u, %d heartbeating\n",
+			node, qs->qs_heartbeating);
+	mlog_bug_on_msg(!test_bit(node, qs->qs_hb_bm), "node %u\n", node);
+	clear_bit(node, qs->qs_hb_bm);
+
+	mlog(0, "node %u, %d total\n", node, qs->qs_heartbeating);
+
+	o2quo_clear_hold(qs, node);
+
+	spin_unlock(&qs->qs_lock);
+}
+
+/* this tells us that we've decided that the node is still heartbeating
+ * even though we've lost it's conn.  it must only be called after conn_err
+ * and indicates that we must now make a quorum decision in the future,
+ * though we might be doing so after waiting for holds to drain.  Here
+ * we'll be dropping the hold from conn_err. */
+void o2quo_hb_still_up(u8 node)
+{
+	struct o2quo_state *qs = &o2quo_state;
+
+	spin_lock(&qs->qs_lock);
+
+	mlog(0, "node %u\n", node);
+
+	qs->qs_pending = 1;
+	o2quo_clear_hold(qs, node);
+
+	spin_unlock(&qs->qs_lock);
+}
+
+/* This is analogous to hb_up.  as a node's connection comes up we delay the
+ * quorum decision until we see it heartbeating.  the hold will be droped in
+ * hb_up or hb_down.  it might be perpetuated by con_err until hb_down.  if
+ * it's already heartbeating we we might be dropping a hold that conn_up got.
+ * */
+void o2quo_conn_up(u8 node)
+{
+	struct o2quo_state *qs = &o2quo_state;
+
+	spin_lock(&qs->qs_lock);
+
+	qs->qs_connected++;
+	mlog_bug_on_msg(qs->qs_connected == O2NM_MAX_NODES,
+		        "node %u\n", node);
+	mlog_bug_on_msg(test_bit(node, qs->qs_conn_bm), "node %u\n", node);
+	set_bit(node, qs->qs_conn_bm);
+
+	mlog(0, "node %u, %d total\n", node, qs->qs_connected);
+
+	if (!test_bit(node, qs->qs_hb_bm))
+		o2quo_set_hold(qs, node);
+	else
+		o2quo_clear_hold(qs, node);
+
+	spin_unlock(&qs->qs_lock);
+}
+
+/* we've decided that we won't ever be connecting to the node again.  if it's
+ * still heartbeating we grab a hold that will delay decisions until either the
+ * node stops heartbeating from hb_down or the caller decides that the node is
+ * still up and calls still_up */
+void o2quo_conn_err(u8 node)
+{
+	struct o2quo_state *qs = &o2quo_state;
+
+	spin_lock(&qs->qs_lock);
+
+	if (test_bit(node, qs->qs_conn_bm)) {
+		qs->qs_connected--;
+		mlog_bug_on_msg(qs->qs_connected < 0,
+				"node %u, connected %d\n",
+				node, qs->qs_connected);
+
+		clear_bit(node, qs->qs_conn_bm);
+	}
+
+	mlog(0, "node %u, %d total\n", node, qs->qs_connected);
+
+	if (test_bit(node, qs->qs_hb_bm))
+		o2quo_set_hold(qs, node);
+
+	spin_unlock(&qs->qs_lock);
+}
+
+void o2quo_init(void)
+{
+	struct o2quo_state *qs = &o2quo_state;
+
+	spin_lock_init(&qs->qs_lock);
+	INIT_WORK(&qs->qs_work, o2quo_make_decision);
+}
+
+void o2quo_exit(void)
+{
+	struct o2quo_state *qs = &o2quo_state;
+
+	flush_work_sync(&qs->qs_work);
+}
diff --git a/drivers/staging/ramster/cluster/quorum.h b/drivers/staging/ramster/cluster/quorum.h
new file mode 100644
index 0000000..6649cc6
--- /dev/null
+++ b/drivers/staging/ramster/cluster/quorum.h
@@ -0,0 +1,36 @@
+/* -*- mode: c; c-basic-offset: 8; -*-
+ * vim: noexpandtab sw=8 ts=8 sts=0:
+ *
+ * Copyright (C) 2005 Oracle.  All rights reserved.
+ *
+ * This program is free software; you can redistribute it and/or
+ * modify it under the terms of the GNU General Public
+ * License as published by the Free Software Foundation; either
+ * version 2 of the License, or (at your option) any later version.
+ *
+ * This program is distributed in the hope that it will be useful,
+ * but WITHOUT ANY WARRANTY; without even the implied warranty of
+ * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
+ * General Public License for more details.
+ *
+ * You should have received a copy of the GNU General Public
+ * License along with this program; if not, write to the
+ * Free Software Foundation, Inc., 59 Temple Place - Suite 330,
+ * Boston, MA 021110-1307, USA.
+ *
+ */
+
+#ifndef O2CLUSTER_QUORUM_H
+#define O2CLUSTER_QUORUM_H
+
+void o2quo_init(void);
+void o2quo_exit(void);
+
+void o2quo_hb_up(u8 node);
+void o2quo_hb_down(u8 node);
+void o2quo_hb_still_up(u8 node);
+void o2quo_conn_up(u8 node);
+void o2quo_conn_err(u8 node);
+void o2quo_disk_timeout(void);
+
+#endif /* O2CLUSTER_QUORUM_H */
diff --git a/drivers/staging/ramster/cluster/sys.c b/drivers/staging/ramster/cluster/sys.c
new file mode 100644
index 0000000..a4b0773
--- /dev/null
+++ b/drivers/staging/ramster/cluster/sys.c
@@ -0,0 +1,82 @@
+/* -*- mode: c; c-basic-offset: 8; -*-
+ * vim: noexpandtab sw=8 ts=8 sts=0:
+ *
+ * sys.c
+ *
+ * OCFS2 cluster sysfs interface
+ *
+ * Copyright (C) 2005 Oracle.  All rights reserved.
+ *
+ * This program is free software; you can redistribute it and/or
+ * modify it under the terms of the GNU General Public
+ * License as published by the Free Software Foundation,
+ * version 2 of the License.
+ *
+ * This program is distributed in the hope that it will be useful,
+ * but WITHOUT ANY WARRANTY; without even the implied warranty of
+ * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
+ * General Public License for more details.
+ *
+ * You should have received a copy of the GNU General Public
+ * License along with this program; if not, write to the
+ * Free Software Foundation, Inc., 59 Temple Place - Suite 330,
+ * Boston, MA 021110-1307, USA.
+ *
+ */
+
+#include <linux/kernel.h>
+#include <linux/module.h>
+#include <linux/kobject.h>
+#include <linux/sysfs.h>
+#include <linux/fs.h>
+
+#include "ocfs2_nodemanager.h"
+#include "masklog.h"
+#include "sys.h"
+
+
+static ssize_t version_show(struct kobject *kobj, struct kobj_attribute *attr,
+			    char *buf)
+{
+	return snprintf(buf, PAGE_SIZE, "%u\n", O2NM_API_VERSION);
+}
+static struct kobj_attribute attr_version =
+	__ATTR(interface_revision, S_IFREG | S_IRUGO, version_show, NULL);
+
+static struct attribute *o2cb_attrs[] = {
+	&attr_version.attr,
+	NULL,
+};
+
+static struct attribute_group o2cb_attr_group = {
+	.attrs = o2cb_attrs,
+};
+
+static struct kset *o2cb_kset;
+
+void o2cb_sys_shutdown(void)
+{
+	mlog_sys_shutdown();
+	kset_unregister(o2cb_kset);
+}
+
+int o2cb_sys_init(void)
+{
+	int ret;
+
+	o2cb_kset = kset_create_and_add("o2cb", NULL, fs_kobj);
+	if (!o2cb_kset)
+		return -ENOMEM;
+
+	ret = sysfs_create_group(&o2cb_kset->kobj, &o2cb_attr_group);
+	if (ret)
+		goto error;
+
+	ret = mlog_sys_init(o2cb_kset);
+	if (ret)
+		goto error;
+	return 0;
+error:
+	kset_unregister(o2cb_kset);
+	return ret;
+}
diff --git a/drivers/staging/ramster/cluster/sys.h b/drivers/staging/ramster/cluster/sys.h
new file mode 100644
index 0000000..d66b8ab
--- /dev/null
+++ b/drivers/staging/ramster/cluster/sys.h
@@ -0,0 +1,33 @@
+/* -*- mode: c; c-basic-offset: 8; -*-
+ * vim: noexpandtab sw=8 ts=8 sts=0:
+ *
+ * sys.h
+ *
+ * Function prototypes for o2cb sysfs interface
+ *
+ * Copyright (C) 2005 Oracle.  All rights reserved.
+ *
+ * This program is free software; you can redistribute it and/or
+ * modify it under the terms of the GNU General Public
+ * License as published by the Free Software Foundation,
+ * version 2 of the License.
+ *
+ * This program is distributed in the hope that it will be useful,
+ * but WITHOUT ANY WARRANTY; without even the implied warranty of
+ * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
+ * General Public License for more details.
+ *
+ * You should have received a copy of the GNU General Public
+ * License along with this program; if not, write to the
+ * Free Software Foundation, Inc., 59 Temple Place - Suite 330,
+ * Boston, MA 021110-1307, USA.
+ *
+ */
+
+#ifndef O2CLUSTER_SYS_H
+#define O2CLUSTER_SYS_H
+
+void o2cb_sys_shutdown(void);
+int o2cb_sys_init(void);
+
+#endif /* O2CLUSTER_SYS_H */
diff --git a/drivers/staging/ramster/cluster/tcp.c b/drivers/staging/ramster/cluster/tcp.c
new file mode 100644
index 0000000..044e7b5
--- /dev/null
+++ b/drivers/staging/ramster/cluster/tcp.c
@@ -0,0 +1,2150 @@
+/* -*- mode: c; c-basic-offset: 8; -*-
+ *
+ * vim: noexpandtab sw=8 ts=8 sts=0:
+ *
+ * Copyright (C) 2004 Oracle.  All rights reserved.
+ *
+ * This program is free software; you can redistribute it and/or
+ * modify it under the terms of the GNU General Public
+ * License as published by the Free Software Foundation; either
+ * version 2 of the License, or (at your option) any later version.
+ *
+ * This program is distributed in the hope that it will be useful,
+ * but WITHOUT ANY WARRANTY; without even the implied warranty of
+ * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
+ * General Public License for more details.
+ *
+ * You should have received a copy of the GNU General Public
+ * License along with this program; if not, write to the
+ * Free Software Foundation, Inc., 59 Temple Place - Suite 330,
+ * Boston, MA 021110-1307, USA.
+ *
+ * ----
+ *
+ * Callers for this were originally written against a very simple synchronus
+ * API.  This implementation reflects those simple callers.  Some day I'm sure
+ * we'll need to move to a more robust posting/callback mechanism.
+ *
+ * Transmit calls pass in kernel virtual addresses and block copying this into
+ * the socket's tx buffers via a usual blocking sendmsg.  They'll block waiting
+ * for a failed socket to timeout.  TX callers can also pass in a poniter to an
+ * 'int' which gets filled with an errno off the wire in response to the
+ * message they send.
+ *
+ * Handlers for unsolicited messages are registered.  Each socket has a page
+ * that incoming data is copied into.  First the header, then the data.
+ * Handlers are called from only one thread with a reference to this per-socket
+ * page.  This page is destroyed after the handler call, so it can't be
+ * referenced beyond the call.  Handlers may block but are discouraged from
+ * doing so.
+ *
+ * Any framing errors (bad magic, large payload lengths) close a connection.
+ *
+ * Our sock_container holds the state we associate with a socket.  It's current
+ * framing state is held there as well as the refcounting we do around when it
+ * is safe to tear down the socket.  The socket is only finally torn down from
+ * the container when the container loses all of its references -- so as long
+ * as you hold a ref on the container you can trust that the socket is valid
+ * for use with kernel socket APIs.
+ *
+ * Connections are initiated between a pair of nodes when the node with the
+ * higher node number gets a heartbeat callback which indicates that the lower
+ * numbered node has started heartbeating.  The lower numbered node is passive
+ * and only accepts the connection if the higher numbered node is heartbeating.
+ */
+
+#include <linux/kernel.h>
+#include <linux/jiffies.h>
+#include <linux/slab.h>
+#include <linux/idr.h>
+#include <linux/kref.h>
+#include <linux/net.h>
+#include <linux/export.h>
+#include <net/tcp.h>
+
+#include <asm/uaccess.h>
+
+#include "heartbeat.h"
+#include "tcp.h"
+#include "nodemanager.h"
+#define MLOG_MASK_PREFIX ML_TCP
+#include "masklog.h"
+#include "quorum.h"
+
+#include "tcp_internal.h"
+
+#define SC_NODEF_FMT "node %s (num %u) at %pI4:%u"
+#define SC_NODEF_ARGS(sc) sc->sc_node->nd_name, sc->sc_node->nd_num,	\
+			  &sc->sc_node->nd_ipv4_address,		\
+			  ntohs(sc->sc_node->nd_ipv4_port)
+
+/*
+ * In the following two log macros, the whitespace after the ',' just
+ * before ##args is intentional. Otherwise, gcc 2.95 will eat the
+ * previous token if args expands to nothing.
+ */
+#define msglog(hdr, fmt, args...) do {					\
+	typeof(hdr) __hdr = (hdr);					\
+	mlog(ML_MSG, "[mag %u len %u typ %u stat %d sys_stat %d "	\
+	     "key %08x num %u] " fmt,					\
+	     be16_to_cpu(__hdr->magic), be16_to_cpu(__hdr->data_len), 	\
+	     be16_to_cpu(__hdr->msg_type), be32_to_cpu(__hdr->status),	\
+	     be32_to_cpu(__hdr->sys_status), be32_to_cpu(__hdr->key),	\
+	     be32_to_cpu(__hdr->msg_num) ,  ##args);			\
+} while (0)
+
+#define sclog(sc, fmt, args...) do {					\
+	typeof(sc) __sc = (sc);						\
+	mlog(ML_SOCKET, "[sc %p refs %d sock %p node %u page %p "	\
+	     "pg_off %zu] " fmt, __sc,					\
+	     atomic_read(&__sc->sc_kref.refcount), __sc->sc_sock,	\
+	    __sc->sc_node->nd_num, __sc->sc_page, __sc->sc_page_off ,	\
+	    ##args);							\
+} while (0)
+
+static DEFINE_RWLOCK(o2net_handler_lock);
+static struct rb_root o2net_handler_tree = RB_ROOT;
+
+static struct o2net_node o2net_nodes[O2NM_MAX_NODES];
+
+/* XXX someday we'll need better accounting */
+static struct socket *o2net_listen_sock = NULL;
+
+/*
+ * listen work is only queued by the listening socket callbacks on the
+ * o2net_wq.  teardown detaches the callbacks before destroying the workqueue.
+ * quorum work is queued as sock containers are shutdown.. stop_listening
+ * tears down all the node's sock containers, preventing future shutdowns
+ * and queued quroum work, before canceling delayed quorum work and
+ * destroying the work queue.
+ */
+static struct workqueue_struct *o2net_wq;
+static struct work_struct o2net_listen_work;
+
+static struct o2hb_callback_func o2net_hb_up, o2net_hb_down;
+#define O2NET_HB_PRI 0x1
+
+static struct o2net_handshake *o2net_hand;
+static struct o2net_msg *o2net_keep_req, *o2net_keep_resp;
+
+static int o2net_sys_err_translations[O2NET_ERR_MAX] =
+		{[O2NET_ERR_NONE]	= 0,
+		 [O2NET_ERR_NO_HNDLR]	= -ENOPROTOOPT,
+		 [O2NET_ERR_OVERFLOW]	= -EOVERFLOW,
+		 [O2NET_ERR_DIED]	= -EHOSTDOWN,};
+
+/* can't quite avoid *all* internal declarations :/ */
+static void o2net_sc_connect_completed(struct work_struct *work);
+static void o2net_rx_until_empty(struct work_struct *work);
+static void o2net_shutdown_sc(struct work_struct *work);
+static void o2net_listen_data_ready(struct sock *sk, int bytes);
+static void o2net_sc_send_keep_req(struct work_struct *work);
+static void o2net_idle_timer(unsigned long data);
+static void o2net_sc_postpone_idle(struct o2net_sock_container *sc);
+static void o2net_sc_reset_idle_timer(struct o2net_sock_container *sc);
+
+#ifdef CONFIG_DEBUG_FS
+static void o2net_init_nst(struct o2net_send_tracking *nst, u32 msgtype,
+			   u32 msgkey, struct task_struct *task, u8 node)
+{
+	INIT_LIST_HEAD(&nst->st_net_debug_item);
+	nst->st_task = task;
+	nst->st_msg_type = msgtype;
+	nst->st_msg_key = msgkey;
+	nst->st_node = node;
+}
+
+static inline void o2net_set_nst_sock_time(struct o2net_send_tracking *nst)
+{
+	nst->st_sock_time = ktime_get();
+}
+
+static inline void o2net_set_nst_send_time(struct o2net_send_tracking *nst)
+{
+	nst->st_send_time = ktime_get();
+}
+
+static inline void o2net_set_nst_status_time(struct o2net_send_tracking *nst)
+{
+	nst->st_status_time = ktime_get();
+}
+
+static inline void o2net_set_nst_sock_container(struct o2net_send_tracking *nst,
+						struct o2net_sock_container *sc)
+{
+	nst->st_sc = sc;
+}
+
+static inline void o2net_set_nst_msg_id(struct o2net_send_tracking *nst,
+					u32 msg_id)
+{
+	nst->st_id = msg_id;
+}
+
+static inline void o2net_set_sock_timer(struct o2net_sock_container *sc)
+{
+	sc->sc_tv_timer = ktime_get();
+}
+
+static inline void o2net_set_data_ready_time(struct o2net_sock_container *sc)
+{
+	sc->sc_tv_data_ready = ktime_get();
+}
+
+static inline void o2net_set_advance_start_time(struct o2net_sock_container *sc)
+{
+	sc->sc_tv_advance_start = ktime_get();
+}
+
+static inline void o2net_set_advance_stop_time(struct o2net_sock_container *sc)
+{
+	sc->sc_tv_advance_stop = ktime_get();
+}
+
+static inline void o2net_set_func_start_time(struct o2net_sock_container *sc)
+{
+	sc->sc_tv_func_start = ktime_get();
+}
+
+static inline void o2net_set_func_stop_time(struct o2net_sock_container *sc)
+{
+	sc->sc_tv_func_stop = ktime_get();
+}
+
+#else  /* CONFIG_DEBUG_FS */
+# define o2net_init_nst(a, b, c, d, e)
+# define o2net_set_nst_sock_time(a)
+# define o2net_set_nst_send_time(a)
+# define o2net_set_nst_status_time(a)
+# define o2net_set_nst_sock_container(a, b)
+# define o2net_set_nst_msg_id(a, b)
+# define o2net_set_sock_timer(a)
+# define o2net_set_data_ready_time(a)
+# define o2net_set_advance_start_time(a)
+# define o2net_set_advance_stop_time(a)
+# define o2net_set_func_start_time(a)
+# define o2net_set_func_stop_time(a)
+#endif /* CONFIG_DEBUG_FS */
+
+#ifdef CONFIG_OCFS2_FS_STATS
+static ktime_t o2net_get_func_run_time(struct o2net_sock_container *sc)
+{
+	return ktime_sub(sc->sc_tv_func_stop, sc->sc_tv_func_start);
+}
+
+static void o2net_update_send_stats(struct o2net_send_tracking *nst,
+				    struct o2net_sock_container *sc)
+{
+	sc->sc_tv_status_total = ktime_add(sc->sc_tv_status_total,
+					   ktime_sub(ktime_get(),
+						     nst->st_status_time));
+	sc->sc_tv_send_total = ktime_add(sc->sc_tv_send_total,
+					 ktime_sub(nst->st_status_time,
+						   nst->st_send_time));
+	sc->sc_tv_acquiry_total = ktime_add(sc->sc_tv_acquiry_total,
+					    ktime_sub(nst->st_send_time,
+						      nst->st_sock_time));
+	sc->sc_send_count++;
+}
+
+static void o2net_update_recv_stats(struct o2net_sock_container *sc)
+{
+	sc->sc_tv_process_total = ktime_add(sc->sc_tv_process_total,
+					    o2net_get_func_run_time(sc));
+	sc->sc_recv_count++;
+}
+
+#else
+
+# define o2net_update_send_stats(a, b)
+
+# define o2net_update_recv_stats(sc)
+
+#endif /* CONFIG_OCFS2_FS_STATS */
+
+static inline int o2net_reconnect_delay(void)
+{
+	return o2nm_single_cluster->cl_reconnect_delay_ms;
+}
+
+static inline int o2net_keepalive_delay(void)
+{
+	return o2nm_single_cluster->cl_keepalive_delay_ms;
+}
+
+static inline int o2net_idle_timeout(void)
+{
+	return o2nm_single_cluster->cl_idle_timeout_ms;
+}
+
+static inline int o2net_sys_err_to_errno(enum o2net_system_error err)
+{
+	int trans;
+	BUG_ON(err >= O2NET_ERR_MAX);
+	trans = o2net_sys_err_translations[err];
+
+	/* Just in case we mess up the translation table above */
+	BUG_ON(err != O2NET_ERR_NONE && trans == 0);
+	return trans;
+}
+
+static struct o2net_node * o2net_nn_from_num(u8 node_num)
+{
+	BUG_ON(node_num >= ARRAY_SIZE(o2net_nodes));
+	return &o2net_nodes[node_num];
+}
+
+static u8 o2net_num_from_nn(struct o2net_node *nn)
+{
+	BUG_ON(nn == NULL);
+	return nn - o2net_nodes;
+}
+
+/* ------------------------------------------------------------ */
+
+static int o2net_prep_nsw(struct o2net_node *nn, struct o2net_status_wait *nsw)
+{
+	int ret = 0;
+
+	do {
+		if (!idr_pre_get(&nn->nn_status_idr, GFP_ATOMIC)) {
+			ret = -EAGAIN;
+			break;
+		}
+		spin_lock(&nn->nn_lock);
+		ret = idr_get_new(&nn->nn_status_idr, nsw, &nsw->ns_id);
+		if (ret == 0)
+			list_add_tail(&nsw->ns_node_item,
+				      &nn->nn_status_list);
+		spin_unlock(&nn->nn_lock);
+	} while (ret == -EAGAIN);
+
+	if (ret == 0)  {
+		init_waitqueue_head(&nsw->ns_wq);
+		nsw->ns_sys_status = O2NET_ERR_NONE;
+		nsw->ns_status = 0;
+	}
+
+	return ret;
+}
+
+static void o2net_complete_nsw_locked(struct o2net_node *nn,
+				      struct o2net_status_wait *nsw,
+				      enum o2net_system_error sys_status,
+				      s32 status)
+{
+	assert_spin_locked(&nn->nn_lock);
+
+	if (!list_empty(&nsw->ns_node_item)) {
+		list_del_init(&nsw->ns_node_item);
+		nsw->ns_sys_status = sys_status;
+		nsw->ns_status = status;
+		idr_remove(&nn->nn_status_idr, nsw->ns_id);
+		wake_up(&nsw->ns_wq);
+	}
+}
+
+static void o2net_complete_nsw(struct o2net_node *nn,
+			       struct o2net_status_wait *nsw,
+			       u64 id, enum o2net_system_error sys_status,
+			       s32 status)
+{
+	spin_lock(&nn->nn_lock);
+	if (nsw == NULL) {
+		if (id > INT_MAX)
+			goto out;
+
+		nsw = idr_find(&nn->nn_status_idr, id);
+		if (nsw == NULL)
+			goto out;
+	}
+
+	o2net_complete_nsw_locked(nn, nsw, sys_status, status);
+
+out:
+	spin_unlock(&nn->nn_lock);
+	return;
+}
+
+static void o2net_complete_nodes_nsw(struct o2net_node *nn)
+{
+	struct o2net_status_wait *nsw, *tmp;
+	unsigned int num_kills = 0;
+
+	assert_spin_locked(&nn->nn_lock);
+
+	list_for_each_entry_safe(nsw, tmp, &nn->nn_status_list, ns_node_item) {
+		o2net_complete_nsw_locked(nn, nsw, O2NET_ERR_DIED, 0);
+		num_kills++;
+	}
+
+	mlog(0, "completed %d messages for node %u\n", num_kills,
+	     o2net_num_from_nn(nn));
+}
+
+static int o2net_nsw_completed(struct o2net_node *nn,
+			       struct o2net_status_wait *nsw)
+{
+	int completed;
+	spin_lock(&nn->nn_lock);
+	completed = list_empty(&nsw->ns_node_item);
+	spin_unlock(&nn->nn_lock);
+	return completed;
+}
+
+/* ------------------------------------------------------------ */
+
+static void sc_kref_release(struct kref *kref)
+{
+	struct o2net_sock_container *sc = container_of(kref,
+					struct o2net_sock_container, sc_kref);
+	BUG_ON(timer_pending(&sc->sc_idle_timeout));
+
+	sclog(sc, "releasing\n");
+
+	if (sc->sc_sock) {
+		sock_release(sc->sc_sock);
+		sc->sc_sock = NULL;
+	}
+
+	o2nm_undepend_item(&sc->sc_node->nd_item);
+	o2nm_node_put(sc->sc_node);
+	sc->sc_node = NULL;
+
+	o2net_debug_del_sc(sc);
+	kfree(sc);
+}
+
+static void sc_put(struct o2net_sock_container *sc)
+{
+	sclog(sc, "put\n");
+	kref_put(&sc->sc_kref, sc_kref_release);
+}
+static void sc_get(struct o2net_sock_container *sc)
+{
+	sclog(sc, "get\n");
+	kref_get(&sc->sc_kref);
+}
+static struct o2net_sock_container *sc_alloc(struct o2nm_node *node)
+{
+	struct o2net_sock_container *sc, *ret = NULL;
+	struct page *page = NULL;
+	int status = 0;
+
+	page = alloc_page(GFP_NOFS);
+	sc = kzalloc(sizeof(*sc), GFP_NOFS);
+	if (sc == NULL || page == NULL)
+		goto out;
+
+	kref_init(&sc->sc_kref);
+	o2nm_node_get(node);
+	sc->sc_node = node;
+
+	/* pin the node item of the remote node */
+	status = o2nm_depend_item(&node->nd_item);
+	if (status) {
+		mlog_errno(status);
+		o2nm_node_put(node);
+		goto out;
+	}
+	INIT_WORK(&sc->sc_connect_work, o2net_sc_connect_completed);
+	INIT_WORK(&sc->sc_rx_work, o2net_rx_until_empty);
+	INIT_WORK(&sc->sc_shutdown_work, o2net_shutdown_sc);
+	INIT_DELAYED_WORK(&sc->sc_keepalive_work, o2net_sc_send_keep_req);
+
+	init_timer(&sc->sc_idle_timeout);
+	sc->sc_idle_timeout.function = o2net_idle_timer;
+	sc->sc_idle_timeout.data = (unsigned long)sc;
+
+	sclog(sc, "alloced\n");
+
+	ret = sc;
+	sc->sc_page = page;
+	o2net_debug_add_sc(sc);
+	sc = NULL;
+	page = NULL;
+
+out:
+	if (page)
+		__free_page(page);
+	kfree(sc);
+
+	return ret;
+}
+
+/* ------------------------------------------------------------ */
+
+static void o2net_sc_queue_work(struct o2net_sock_container *sc,
+				struct work_struct *work)
+{
+	sc_get(sc);
+	if (!queue_work(o2net_wq, work))
+		sc_put(sc);
+}
+static void o2net_sc_queue_delayed_work(struct o2net_sock_container *sc,
+					struct delayed_work *work,
+					int delay)
+{
+	sc_get(sc);
+	if (!queue_delayed_work(o2net_wq, work, delay))
+		sc_put(sc);
+}
+static void o2net_sc_cancel_delayed_work(struct o2net_sock_container *sc,
+					 struct delayed_work *work)
+{
+	if (cancel_delayed_work(work))
+		sc_put(sc);
+}
+
+static atomic_t o2net_connected_peers = ATOMIC_INIT(0);
+
+int o2net_num_connected_peers(void)
+{
+	return atomic_read(&o2net_connected_peers);
+}
+
+static void o2net_set_nn_state(struct o2net_node *nn,
+			       struct o2net_sock_container *sc,
+			       unsigned valid, int err)
+{
+	int was_valid = nn->nn_sc_valid;
+	int was_err = nn->nn_persistent_error;
+	struct o2net_sock_container *old_sc = nn->nn_sc;
+
+	assert_spin_locked(&nn->nn_lock);
+
+	if (old_sc && !sc)
+		atomic_dec(&o2net_connected_peers);
+	else if (!old_sc && sc)
+		atomic_inc(&o2net_connected_peers);
+
+	/* the node num comparison and single connect/accept path should stop
+	 * an non-null sc from being overwritten with another */
+	BUG_ON(sc && nn->nn_sc && nn->nn_sc != sc);
+	mlog_bug_on_msg(err && valid, "err %d valid %u\n", err, valid);
+	mlog_bug_on_msg(valid && !sc, "valid %u sc %p\n", valid, sc);
+
+	if (was_valid && !valid && err == 0)
+		err = -ENOTCONN;
+
+	mlog(ML_CONN, "node %u sc: %p -> %p, valid %u -> %u, err %d -> %d\n",
+	     o2net_num_from_nn(nn), nn->nn_sc, sc, nn->nn_sc_valid, valid,
+	     nn->nn_persistent_error, err);
+
+	nn->nn_sc = sc;
+	nn->nn_sc_valid = valid ? 1 : 0;
+	nn->nn_persistent_error = err;
+
+	/* mirrors o2net_tx_can_proceed() */
+	if (nn->nn_persistent_error || nn->nn_sc_valid)
+		wake_up(&nn->nn_sc_wq);
+
+	if (!was_err && nn->nn_persistent_error) {
+		o2quo_conn_err(o2net_num_from_nn(nn));
+		queue_delayed_work(o2net_wq, &nn->nn_still_up,
+				   msecs_to_jiffies(O2NET_QUORUM_DELAY_MS));
+	}
+
+	if (was_valid && !valid) {
+		printk(KERN_NOTICE "o2net: No longer connected to "
+		       SC_NODEF_FMT "\n", SC_NODEF_ARGS(old_sc));
+		o2net_complete_nodes_nsw(nn);
+	}
+
+	if (!was_valid && valid) {
+		o2quo_conn_up(o2net_num_from_nn(nn));
+		cancel_delayed_work(&nn->nn_connect_expired);
+		printk(KERN_NOTICE "o2net: %s " SC_NODEF_FMT "\n",
+		       o2nm_this_node() > sc->sc_node->nd_num ?
+		       "Connected to" : "Accepted connection from",
+		       SC_NODEF_ARGS(sc));
+	}
+
+	/* trigger the connecting worker func as long as we're not valid,
+	 * it will back off if it shouldn't connect.  This can be called
+	 * from node config teardown and so needs to be careful about
+	 * the work queue actually being up. */
+	if (!valid && o2net_wq) {
+		unsigned long delay;
+		/* delay if we're within a RECONNECT_DELAY of the
+		 * last attempt */
+		delay = (nn->nn_last_connect_attempt +
+			 msecs_to_jiffies(o2net_reconnect_delay()))
+			- jiffies;
+		if (delay > msecs_to_jiffies(o2net_reconnect_delay()))
+			delay = 0;
+		mlog(ML_CONN, "queueing conn attempt in %lu jiffies\n", delay);
+		queue_delayed_work(o2net_wq, &nn->nn_connect_work, delay);
+
+		/*
+		 * Delay the expired work after idle timeout.
+		 *
+		 * We might have lots of failed connection attempts that run
+		 * through here but we only cancel the connect_expired work when
+		 * a connection attempt succeeds.  So only the first enqueue of
+		 * the connect_expired work will do anything.  The rest will see
+		 * that it's already queued and do nothing.
+		 */
+		delay += msecs_to_jiffies(o2net_idle_timeout());
+		queue_delayed_work(o2net_wq, &nn->nn_connect_expired, delay);
+	}
+
+	/* keep track of the nn's sc ref for the caller */
+	if ((old_sc == NULL) && sc)
+		sc_get(sc);
+	if (old_sc && (old_sc != sc)) {
+		o2net_sc_queue_work(old_sc, &old_sc->sc_shutdown_work);
+		sc_put(old_sc);
+	}
+}
+
+/* see o2net_register_callbacks() */
+static void o2net_data_ready(struct sock *sk, int bytes)
+{
+	void (*ready)(struct sock *sk, int bytes);
+
+	read_lock(&sk->sk_callback_lock);
+	if (sk->sk_user_data) {
+		struct o2net_sock_container *sc = sk->sk_user_data;
+		sclog(sc, "data_ready hit\n");
+		o2net_set_data_ready_time(sc);
+		o2net_sc_queue_work(sc, &sc->sc_rx_work);
+		ready = sc->sc_data_ready;
+	} else {
+		ready = sk->sk_data_ready;
+	}
+	read_unlock(&sk->sk_callback_lock);
+
+	ready(sk, bytes);
+}
+
+/* see o2net_register_callbacks() */
+static void o2net_state_change(struct sock *sk)
+{
+	void (*state_change)(struct sock *sk);
+	struct o2net_sock_container *sc;
+
+	read_lock(&sk->sk_callback_lock);
+	sc = sk->sk_user_data;
+	if (sc == NULL) {
+		state_change = sk->sk_state_change;
+		goto out;
+	}
+
+	sclog(sc, "state_change to %d\n", sk->sk_state);
+
+	state_change = sc->sc_state_change;
+
+	switch(sk->sk_state) {
+		/* ignore connecting sockets as they make progress */
+		case TCP_SYN_SENT:
+		case TCP_SYN_RECV:
+			break;
+		case TCP_ESTABLISHED:
+			o2net_sc_queue_work(sc, &sc->sc_connect_work);
+			break;
+		default:
+			printk(KERN_INFO "o2net: Connection to " SC_NODEF_FMT
+			      " shutdown, state %d\n",
+			      SC_NODEF_ARGS(sc), sk->sk_state);
+			o2net_sc_queue_work(sc, &sc->sc_shutdown_work);
+			break;
+	}
+out:
+	read_unlock(&sk->sk_callback_lock);
+	state_change(sk);
+}
+
+/*
+ * we register callbacks so we can queue work on events before calling
+ * the original callbacks.  our callbacks our careful to test user_data
+ * to discover when they've reaced with o2net_unregister_callbacks().
+ */
+static void o2net_register_callbacks(struct sock *sk,
+				     struct o2net_sock_container *sc)
+{
+	write_lock_bh(&sk->sk_callback_lock);
+
+	/* accepted sockets inherit the old listen socket data ready */
+	if (sk->sk_data_ready == o2net_listen_data_ready) {
+		sk->sk_data_ready = sk->sk_user_data;
+		sk->sk_user_data = NULL;
+	}
+
+	BUG_ON(sk->sk_user_data != NULL);
+	sk->sk_user_data = sc;
+	sc_get(sc);
+
+	sc->sc_data_ready = sk->sk_data_ready;
+	sc->sc_state_change = sk->sk_state_change;
+	sk->sk_data_ready = o2net_data_ready;
+	sk->sk_state_change = o2net_state_change;
+
+	mutex_init(&sc->sc_send_lock);
+
+	write_unlock_bh(&sk->sk_callback_lock);
+}
+
+static int o2net_unregister_callbacks(struct sock *sk,
+			           struct o2net_sock_container *sc)
+{
+	int ret = 0;
+
+	write_lock_bh(&sk->sk_callback_lock);
+	if (sk->sk_user_data == sc) {
+		ret = 1;
+		sk->sk_user_data = NULL;
+		sk->sk_data_ready = sc->sc_data_ready;
+		sk->sk_state_change = sc->sc_state_change;
+	}
+	write_unlock_bh(&sk->sk_callback_lock);
+
+	return ret;
+}
+
+/*
+ * this is a little helper that is called by callers who have seen a problem
+ * with an sc and want to detach it from the nn if someone already hasn't beat
+ * them to it.  if an error is given then the shutdown will be persistent
+ * and pending transmits will be canceled.
+ */
+static void o2net_ensure_shutdown(struct o2net_node *nn,
+			           struct o2net_sock_container *sc,
+				   int err)
+{
+	spin_lock(&nn->nn_lock);
+	if (nn->nn_sc == sc)
+		o2net_set_nn_state(nn, NULL, 0, err);
+	spin_unlock(&nn->nn_lock);
+}
+
+/*
+ * This work queue function performs the blocking parts of socket shutdown.  A
+ * few paths lead here.  set_nn_state will trigger this callback if it sees an
+ * sc detached from the nn.  state_change will also trigger this callback
+ * directly when it sees errors.  In that case we need to call set_nn_state
+ * ourselves as state_change couldn't get the nn_lock and call set_nn_state
+ * itself.
+ */
+static void o2net_shutdown_sc(struct work_struct *work)
+{
+	struct o2net_sock_container *sc =
+		container_of(work, struct o2net_sock_container,
+			     sc_shutdown_work);
+	struct o2net_node *nn = o2net_nn_from_num(sc->sc_node->nd_num);
+
+	sclog(sc, "shutting down\n");
+
+	/* drop the callbacks ref and call shutdown only once */
+	if (o2net_unregister_callbacks(sc->sc_sock->sk, sc)) {
+		/* we shouldn't flush as we're in the thread, the
+		 * races with pending sc work structs are harmless */
+		del_timer_sync(&sc->sc_idle_timeout);
+		o2net_sc_cancel_delayed_work(sc, &sc->sc_keepalive_work);
+		sc_put(sc);
+		kernel_sock_shutdown(sc->sc_sock, SHUT_RDWR);
+	}
+
+	/* not fatal so failed connects before the other guy has our
+	 * heartbeat can be retried */
+	o2net_ensure_shutdown(nn, sc, 0);
+	sc_put(sc);
+}
+
+/* ------------------------------------------------------------ */
+
+static int o2net_handler_cmp(struct o2net_msg_handler *nmh, u32 msg_type,
+			     u32 key)
+{
+	int ret = memcmp(&nmh->nh_key, &key, sizeof(key));
+
+	if (ret == 0)
+		ret = memcmp(&nmh->nh_msg_type, &msg_type, sizeof(msg_type));
+
+	return ret;
+}
+
+static struct o2net_msg_handler *
+o2net_handler_tree_lookup(u32 msg_type, u32 key, struct rb_node ***ret_p,
+			  struct rb_node **ret_parent)
+{
+        struct rb_node **p = &o2net_handler_tree.rb_node;
+        struct rb_node *parent = NULL;
+	struct o2net_msg_handler *nmh, *ret = NULL;
+	int cmp;
+
+        while (*p) {
+                parent = *p;
+                nmh = rb_entry(parent, struct o2net_msg_handler, nh_node);
+		cmp = o2net_handler_cmp(nmh, msg_type, key);
+
+                if (cmp < 0)
+                        p = &(*p)->rb_left;
+                else if (cmp > 0)
+                        p = &(*p)->rb_right;
+                else {
+			ret = nmh;
+                        break;
+		}
+        }
+
+        if (ret_p != NULL)
+                *ret_p = p;
+        if (ret_parent != NULL)
+                *ret_parent = parent;
+
+        return ret;
+}
+
+static void o2net_handler_kref_release(struct kref *kref)
+{
+	struct o2net_msg_handler *nmh;
+	nmh = container_of(kref, struct o2net_msg_handler, nh_kref);
+
+	kfree(nmh);
+}
+
+static void o2net_handler_put(struct o2net_msg_handler *nmh)
+{
+	kref_put(&nmh->nh_kref, o2net_handler_kref_release);
+}
+
+/* max_len is protection for the handler func.  incoming messages won't
+ * be given to the handler if their payload is longer than the max. */
+int o2net_register_handler(u32 msg_type, u32 key, u32 max_len,
+			   o2net_msg_handler_func *func, void *data,
+			   o2net_post_msg_handler_func *post_func,
+			   struct list_head *unreg_list)
+{
+	struct o2net_msg_handler *nmh = NULL;
+	struct rb_node **p, *parent;
+	int ret = 0;
+
+	if (max_len > O2NET_MAX_PAYLOAD_BYTES) {
+		mlog(0, "max_len for message handler out of range: %u\n",
+			max_len);
+		ret = -EINVAL;
+		goto out;
+	}
+
+	if (!msg_type) {
+		mlog(0, "no message type provided: %u, %p\n", msg_type, func);
+		ret = -EINVAL;
+		goto out;
+
+	}
+	if (!func) {
+		mlog(0, "no message handler provided: %u, %p\n",
+		       msg_type, func);
+		ret = -EINVAL;
+		goto out;
+	}
+
+       	nmh = kzalloc(sizeof(struct o2net_msg_handler), GFP_NOFS);
+	if (nmh == NULL) {
+		ret = -ENOMEM;
+		goto out;
+	}
+
+	nmh->nh_func = func;
+	nmh->nh_func_data = data;
+	nmh->nh_post_func = post_func;
+	nmh->nh_msg_type = msg_type;
+	nmh->nh_max_len = max_len;
+	nmh->nh_key = key;
+	/* the tree and list get this ref.. they're both removed in
+	 * unregister when this ref is dropped */
+	kref_init(&nmh->nh_kref);
+	INIT_LIST_HEAD(&nmh->nh_unregister_item);
+
+	write_lock(&o2net_handler_lock);
+	if (o2net_handler_tree_lookup(msg_type, key, &p, &parent))
+		ret = -EEXIST;
+	else {
+	        rb_link_node(&nmh->nh_node, parent, p);
+		rb_insert_color(&nmh->nh_node, &o2net_handler_tree);
+		list_add_tail(&nmh->nh_unregister_item, unreg_list);
+
+		mlog(ML_TCP, "registered handler func %p type %u key %08x\n",
+		     func, msg_type, key);
+		/* we've had some trouble with handlers seemingly vanishing. */
+		mlog_bug_on_msg(o2net_handler_tree_lookup(msg_type, key, &p,
+							  &parent) == NULL,
+			        "couldn't find handler we *just* registerd "
+				"for type %u key %08x\n", msg_type, key);
+	}
+	write_unlock(&o2net_handler_lock);
+	if (ret)
+		goto out;
+
+out:
+	if (ret)
+		kfree(nmh);
+
+	return ret;
+}
+EXPORT_SYMBOL_GPL(o2net_register_handler);
+
+void o2net_unregister_handler_list(struct list_head *list)
+{
+	struct o2net_msg_handler *nmh, *n;
+
+	write_lock(&o2net_handler_lock);
+	list_for_each_entry_safe(nmh, n, list, nh_unregister_item) {
+		mlog(ML_TCP, "unregistering handler func %p type %u key %08x\n",
+		     nmh->nh_func, nmh->nh_msg_type, nmh->nh_key);
+		rb_erase(&nmh->nh_node, &o2net_handler_tree);
+		list_del_init(&nmh->nh_unregister_item);
+		kref_put(&nmh->nh_kref, o2net_handler_kref_release);
+	}
+	write_unlock(&o2net_handler_lock);
+}
+EXPORT_SYMBOL_GPL(o2net_unregister_handler_list);
+
+static struct o2net_msg_handler *o2net_handler_get(u32 msg_type, u32 key)
+{
+	struct o2net_msg_handler *nmh;
+
+	read_lock(&o2net_handler_lock);
+	nmh = o2net_handler_tree_lookup(msg_type, key, NULL, NULL);
+	if (nmh)
+		kref_get(&nmh->nh_kref);
+	read_unlock(&o2net_handler_lock);
+
+	return nmh;
+}
+
+/* ------------------------------------------------------------ */
+
+static int o2net_recv_tcp_msg(struct socket *sock, void *data, size_t len)
+{
+	int ret;
+	mm_segment_t oldfs;
+	struct kvec vec = {
+		.iov_len = len,
+		.iov_base = data,
+	};
+	struct msghdr msg = {
+		.msg_iovlen = 1,
+		.msg_iov = (struct iovec *)&vec,
+       		.msg_flags = MSG_DONTWAIT,
+	};
+
+	oldfs = get_fs();
+	set_fs(get_ds());
+	ret = sock_recvmsg(sock, &msg, len, msg.msg_flags);
+	set_fs(oldfs);
+
+	return ret;
+}
+
+static int o2net_send_tcp_msg(struct socket *sock, struct kvec *vec,
+			      size_t veclen, size_t total)
+{
+	int ret;
+	mm_segment_t oldfs;
+	struct msghdr msg = {
+		.msg_iov = (struct iovec *)vec,
+		.msg_iovlen = veclen,
+	};
+
+	if (sock == NULL) {
+		ret = -EINVAL;
+		goto out;
+	}
+
+	oldfs = get_fs();
+	set_fs(get_ds());
+	ret = sock_sendmsg(sock, &msg, total);
+	set_fs(oldfs);
+	if (ret != total) {
+		mlog(ML_ERROR, "sendmsg returned %d instead of %zu\n", ret,
+		     total);
+		if (ret >= 0)
+			ret = -EPIPE; /* should be smarter, I bet */
+		goto out;
+	}
+
+	ret = 0;
+out:
+	if (ret < 0)
+		mlog(0, "returning error: %d\n", ret);
+	return ret;
+}
+
+static void o2net_sendpage(struct o2net_sock_container *sc,
+			   void *kmalloced_virt,
+			   size_t size)
+{
+	struct o2net_node *nn = o2net_nn_from_num(sc->sc_node->nd_num);
+	ssize_t ret;
+
+	while (1) {
+		mutex_lock(&sc->sc_send_lock);
+		ret = sc->sc_sock->ops->sendpage(sc->sc_sock,
+						 virt_to_page(kmalloced_virt),
+						 (long)kmalloced_virt & ~PAGE_MASK,
+						 size, MSG_DONTWAIT);
+		mutex_unlock(&sc->sc_send_lock);
+		if (ret == size)
+			break;
+		if (ret == (ssize_t)-EAGAIN) {
+			mlog(0, "sendpage of size %zu to " SC_NODEF_FMT
+			     " returned EAGAIN\n", size, SC_NODEF_ARGS(sc));
+			cond_resched();
+			continue;
+		}
+		mlog(ML_ERROR, "sendpage of size %zu to " SC_NODEF_FMT
+		     " failed with %zd\n", size, SC_NODEF_ARGS(sc), ret);
+		o2net_ensure_shutdown(nn, sc, 0);
+		break;
+	}
+}
+
+static void o2net_init_msg(struct o2net_msg *msg, u16 data_len, u16 msg_type, u32 key)
+{
+	memset(msg, 0, sizeof(struct o2net_msg));
+	msg->magic = cpu_to_be16(O2NET_MSG_MAGIC);
+	msg->data_len = cpu_to_be16(data_len);
+	msg->msg_type = cpu_to_be16(msg_type);
+	msg->sys_status = cpu_to_be32(O2NET_ERR_NONE);
+	msg->status = 0;
+	msg->key = cpu_to_be32(key);
+}
+
+static int o2net_tx_can_proceed(struct o2net_node *nn,
+			        struct o2net_sock_container **sc_ret,
+				int *error)
+{
+	int ret = 0;
+
+	spin_lock(&nn->nn_lock);
+	if (nn->nn_persistent_error) {
+		ret = 1;
+		*sc_ret = NULL;
+		*error = nn->nn_persistent_error;
+	} else if (nn->nn_sc_valid) {
+		kref_get(&nn->nn_sc->sc_kref);
+
+		ret = 1;
+		*sc_ret = nn->nn_sc;
+		*error = 0;
+	}
+	spin_unlock(&nn->nn_lock);
+
+	return ret;
+}
+
+/* Get a map of all nodes to which this node is currently connected to */
+void o2net_fill_node_map(unsigned long *map, unsigned bytes)
+{
+	struct o2net_sock_container *sc;
+	int node, ret;
+
+	BUG_ON(bytes < (BITS_TO_LONGS(O2NM_MAX_NODES) * sizeof(unsigned long)));
+
+	memset(map, 0, bytes);
+	for (node = 0; node < O2NM_MAX_NODES; ++node) {
+		o2net_tx_can_proceed(o2net_nn_from_num(node), &sc, &ret);
+		if (!ret) {
+			set_bit(node, map);
+			sc_put(sc);
+		}
+	}
+}
+EXPORT_SYMBOL_GPL(o2net_fill_node_map);
+
+int o2net_send_message_vec(u32 msg_type, u32 key, struct kvec *caller_vec,
+			   size_t caller_veclen, u8 target_node, int *status)
+{
+	int ret = 0;
+	struct o2net_msg *msg = NULL;
+	size_t veclen, caller_bytes = 0;
+	struct kvec *vec = NULL;
+	struct o2net_sock_container *sc = NULL;
+	struct o2net_node *nn = o2net_nn_from_num(target_node);
+	struct o2net_status_wait nsw = {
+		.ns_node_item = LIST_HEAD_INIT(nsw.ns_node_item),
+	};
+	struct o2net_send_tracking nst;
+
+	o2net_init_nst(&nst, msg_type, key, current, target_node);
+
+	if (o2net_wq == NULL) {
+		mlog(0, "attempt to tx without o2netd running\n");
+		ret = -ESRCH;
+		goto out;
+	}
+
+	if (caller_veclen == 0) {
+		mlog(0, "bad kvec array length\n");
+		ret = -EINVAL;
+		goto out;
+	}
+
+	caller_bytes = iov_length((struct iovec *)caller_vec, caller_veclen);
+	if (caller_bytes > O2NET_MAX_PAYLOAD_BYTES) {
+		mlog(0, "total payload len %zu too large\n", caller_bytes);
+		ret = -EINVAL;
+		goto out;
+	}
+
+	if (target_node == o2nm_this_node()) {
+		ret = -ELOOP;
+		goto out;
+	}
+
+	o2net_debug_add_nst(&nst);
+
+	o2net_set_nst_sock_time(&nst);
+
+	wait_event(nn->nn_sc_wq, o2net_tx_can_proceed(nn, &sc, &ret));
+	if (ret)
+		goto out;
+
+	o2net_set_nst_sock_container(&nst, sc);
+
+	veclen = caller_veclen + 1;
+	vec = kmalloc(sizeof(struct kvec) * veclen, GFP_ATOMIC);
+	if (vec == NULL) {
+		mlog(0, "failed to %zu element kvec!\n", veclen);
+		ret = -ENOMEM;
+		goto out;
+	}
+
+	msg = kmalloc(sizeof(struct o2net_msg), GFP_ATOMIC);
+	if (!msg) {
+		mlog(0, "failed to allocate a o2net_msg!\n");
+		ret = -ENOMEM;
+		goto out;
+	}
+
+	o2net_init_msg(msg, caller_bytes, msg_type, key);
+
+	vec[0].iov_len = sizeof(struct o2net_msg);
+	vec[0].iov_base = msg;
+	memcpy(&vec[1], caller_vec, caller_veclen * sizeof(struct kvec));
+
+	ret = o2net_prep_nsw(nn, &nsw);
+	if (ret)
+		goto out;
+
+	msg->msg_num = cpu_to_be32(nsw.ns_id);
+	o2net_set_nst_msg_id(&nst, nsw.ns_id);
+
+	o2net_set_nst_send_time(&nst);
+
+	/* finally, convert the message header to network byte-order
+	 * and send */
+	mutex_lock(&sc->sc_send_lock);
+	ret = o2net_send_tcp_msg(sc->sc_sock, vec, veclen,
+				 sizeof(struct o2net_msg) + caller_bytes);
+	mutex_unlock(&sc->sc_send_lock);
+	msglog(msg, "sending returned %d\n", ret);
+	if (ret < 0) {
+		mlog(0, "error returned from o2net_send_tcp_msg=%d\n", ret);
+		goto out;
+	}
+
+	/* wait on other node's handler */
+	o2net_set_nst_status_time(&nst);
+	wait_event(nsw.ns_wq, o2net_nsw_completed(nn, &nsw));
+
+	o2net_update_send_stats(&nst, sc);
+
+	/* Note that we avoid overwriting the callers status return
+	 * variable if a system error was reported on the other
+	 * side. Callers beware. */
+	ret = o2net_sys_err_to_errno(nsw.ns_sys_status);
+	if (status && !ret)
+		*status = nsw.ns_status;
+
+	mlog(0, "woken, returning system status %d, user status %d\n",
+	     ret, nsw.ns_status);
+out:
+	o2net_debug_del_nst(&nst); /* must be before dropping sc and node */
+	if (sc)
+		sc_put(sc);
+	if (vec)
+		kfree(vec);
+	if (msg)
+		kfree(msg);
+	o2net_complete_nsw(nn, &nsw, 0, 0, 0);
+	return ret;
+}
+EXPORT_SYMBOL_GPL(o2net_send_message_vec);
+
+int o2net_send_message(u32 msg_type, u32 key, void *data, u32 len,
+		       u8 target_node, int *status)
+{
+	struct kvec vec = {
+		.iov_base = data,
+		.iov_len = len,
+	};
+	return o2net_send_message_vec(msg_type, key, &vec, 1,
+				      target_node, status);
+}
+EXPORT_SYMBOL_GPL(o2net_send_message);
+
+static int o2net_send_status_magic(struct socket *sock, struct o2net_msg *hdr,
+				   enum o2net_system_error syserr, int err)
+{
+	struct kvec vec = {
+		.iov_base = hdr,
+		.iov_len = sizeof(struct o2net_msg),
+	};
+
+	BUG_ON(syserr >= O2NET_ERR_MAX);
+
+	/* leave other fields intact from the incoming message, msg_num
+	 * in particular */
+	hdr->sys_status = cpu_to_be32(syserr);
+	hdr->status = cpu_to_be32(err);
+	hdr->magic = cpu_to_be16(O2NET_MSG_STATUS_MAGIC);  // twiddle the magic
+	hdr->data_len = 0;
+
+	msglog(hdr, "about to send status magic %d\n", err);
+	/* hdr has been in host byteorder this whole time */
+	return o2net_send_tcp_msg(sock, &vec, 1, sizeof(struct o2net_msg));
+}
+
+/* this returns -errno if the header was unknown or too large, etc.
+ * after this is called the buffer us reused for the next message */
+static int o2net_process_message(struct o2net_sock_container *sc,
+				 struct o2net_msg *hdr)
+{
+	struct o2net_node *nn = o2net_nn_from_num(sc->sc_node->nd_num);
+	int ret = 0, handler_status;
+	enum  o2net_system_error syserr;
+	struct o2net_msg_handler *nmh = NULL;
+	void *ret_data = NULL;
+
+	msglog(hdr, "processing message\n");
+
+	o2net_sc_postpone_idle(sc);
+
+	switch(be16_to_cpu(hdr->magic)) {
+		case O2NET_MSG_STATUS_MAGIC:
+			/* special type for returning message status */
+			o2net_complete_nsw(nn, NULL,
+					   be32_to_cpu(hdr->msg_num),
+					   be32_to_cpu(hdr->sys_status),
+					   be32_to_cpu(hdr->status));
+			goto out;
+		case O2NET_MSG_KEEP_REQ_MAGIC:
+			o2net_sendpage(sc, o2net_keep_resp,
+				       sizeof(*o2net_keep_resp));
+			goto out;
+		case O2NET_MSG_KEEP_RESP_MAGIC:
+			goto out;
+		case O2NET_MSG_MAGIC:
+			break;
+		default:
+			msglog(hdr, "bad magic\n");
+			ret = -EINVAL;
+			goto out;
+			break;
+	}
+
+	/* find a handler for it */
+	handler_status = 0;
+	nmh = o2net_handler_get(be16_to_cpu(hdr->msg_type),
+				be32_to_cpu(hdr->key));
+	if (!nmh) {
+		mlog(ML_TCP, "couldn't find handler for type %u key %08x\n",
+		     be16_to_cpu(hdr->msg_type), be32_to_cpu(hdr->key));
+		syserr = O2NET_ERR_NO_HNDLR;
+		goto out_respond;
+	}
+
+	syserr = O2NET_ERR_NONE;
+
+	if (be16_to_cpu(hdr->data_len) > nmh->nh_max_len)
+		syserr = O2NET_ERR_OVERFLOW;
+
+	if (syserr != O2NET_ERR_NONE)
+		goto out_respond;
+
+	o2net_set_func_start_time(sc);
+	sc->sc_msg_key = be32_to_cpu(hdr->key);
+	sc->sc_msg_type = be16_to_cpu(hdr->msg_type);
+	handler_status = (nmh->nh_func)(hdr, sizeof(struct o2net_msg) +
+					     be16_to_cpu(hdr->data_len),
+					nmh->nh_func_data, &ret_data);
+	o2net_set_func_stop_time(sc);
+
+	o2net_update_recv_stats(sc);
+
+out_respond:
+	/* this destroys the hdr, so don't use it after this */
+	mutex_lock(&sc->sc_send_lock);
+	ret = o2net_send_status_magic(sc->sc_sock, hdr, syserr,
+				      handler_status);
+	mutex_unlock(&sc->sc_send_lock);
+	hdr = NULL;
+	mlog(0, "sending handler status %d, syserr %d returned %d\n",
+	     handler_status, syserr, ret);
+
+	if (nmh) {
+		BUG_ON(ret_data != NULL && nmh->nh_post_func == NULL);
+		if (nmh->nh_post_func)
+			(nmh->nh_post_func)(handler_status, nmh->nh_func_data,
+					    ret_data);
+	}
+
+out:
+	if (nmh)
+		o2net_handler_put(nmh);
+	return ret;
+}
+
+static int o2net_check_handshake(struct o2net_sock_container *sc)
+{
+	struct o2net_handshake *hand = page_address(sc->sc_page);
+	struct o2net_node *nn = o2net_nn_from_num(sc->sc_node->nd_num);
+
+	if (hand->protocol_version != cpu_to_be64(O2NET_PROTOCOL_VERSION)) {
+		printk(KERN_NOTICE "o2net: " SC_NODEF_FMT " Advertised net "
+		       "protocol version %llu but %llu is required. "
+		       "Disconnecting.\n", SC_NODEF_ARGS(sc),
+		       (unsigned long long)be64_to_cpu(hand->protocol_version),
+		       O2NET_PROTOCOL_VERSION);
+
+		/* don't bother reconnecting if its the wrong version. */
+		o2net_ensure_shutdown(nn, sc, -ENOTCONN);
+		return -1;
+	}
+
+	/*
+	 * Ensure timeouts are consistent with other nodes, otherwise
+	 * we can end up with one node thinking that the other must be down,
+	 * but isn't. This can ultimately cause corruption.
+	 */
+	if (be32_to_cpu(hand->o2net_idle_timeout_ms) !=
+				o2net_idle_timeout()) {
+		printk(KERN_NOTICE "o2net: " SC_NODEF_FMT " uses a network "
+		       "idle timeout of %u ms, but we use %u ms locally. "
+		       "Disconnecting.\n", SC_NODEF_ARGS(sc),
+		       be32_to_cpu(hand->o2net_idle_timeout_ms),
+		       o2net_idle_timeout());
+		o2net_ensure_shutdown(nn, sc, -ENOTCONN);
+		return -1;
+	}
+
+	if (be32_to_cpu(hand->o2net_keepalive_delay_ms) !=
+			o2net_keepalive_delay()) {
+		printk(KERN_NOTICE "o2net: " SC_NODEF_FMT " uses a keepalive "
+		       "delay of %u ms, but we use %u ms locally. "
+		       "Disconnecting.\n", SC_NODEF_ARGS(sc),
+		       be32_to_cpu(hand->o2net_keepalive_delay_ms),
+		       o2net_keepalive_delay());
+		o2net_ensure_shutdown(nn, sc, -ENOTCONN);
+		return -1;
+	}
+
+	if (be32_to_cpu(hand->o2hb_heartbeat_timeout_ms) !=
+			O2HB_MAX_WRITE_TIMEOUT_MS) {
+		printk(KERN_NOTICE "o2net: " SC_NODEF_FMT " uses a heartbeat "
+		       "timeout of %u ms, but we use %u ms locally. "
+		       "Disconnecting.\n", SC_NODEF_ARGS(sc),
+		       be32_to_cpu(hand->o2hb_heartbeat_timeout_ms),
+		       O2HB_MAX_WRITE_TIMEOUT_MS);
+		o2net_ensure_shutdown(nn, sc, -ENOTCONN);
+		return -1;
+	}
+
+	sc->sc_handshake_ok = 1;
+
+	spin_lock(&nn->nn_lock);
+	/* set valid and queue the idle timers only if it hasn't been
+	 * shut down already */
+	if (nn->nn_sc == sc) {
+		o2net_sc_reset_idle_timer(sc);
+		atomic_set(&nn->nn_timeout, 0);
+		o2net_set_nn_state(nn, sc, 1, 0);
+	}
+	spin_unlock(&nn->nn_lock);
+
+	/* shift everything up as though it wasn't there */
+	sc->sc_page_off -= sizeof(struct o2net_handshake);
+	if (sc->sc_page_off)
+		memmove(hand, hand + 1, sc->sc_page_off);
+
+	return 0;
+}
+
+/* this demuxes the queued rx bytes into header or payload bits and calls
+ * handlers as each full message is read off the socket.  it returns -error,
+ * == 0 eof, or > 0 for progress made.*/
+static int o2net_advance_rx(struct o2net_sock_container *sc)
+{
+	struct o2net_msg *hdr;
+	int ret = 0;
+	void *data;
+	size_t datalen;
+
+	sclog(sc, "receiving\n");
+	o2net_set_advance_start_time(sc);
+
+	if (unlikely(sc->sc_handshake_ok == 0)) {
+		if(sc->sc_page_off < sizeof(struct o2net_handshake)) {
+			data = page_address(sc->sc_page) + sc->sc_page_off;
+			datalen = sizeof(struct o2net_handshake) - sc->sc_page_off;
+			ret = o2net_recv_tcp_msg(sc->sc_sock, data, datalen);
+			if (ret > 0)
+				sc->sc_page_off += ret;
+		}
+
+		if (sc->sc_page_off == sizeof(struct o2net_handshake)) {
+			o2net_check_handshake(sc);
+			if (unlikely(sc->sc_handshake_ok == 0))
+				ret = -EPROTO;
+		}
+		goto out;
+	}
+
+	/* do we need more header? */
+	if (sc->sc_page_off < sizeof(struct o2net_msg)) {
+		data = page_address(sc->sc_page) + sc->sc_page_off;
+		datalen = sizeof(struct o2net_msg) - sc->sc_page_off;
+		ret = o2net_recv_tcp_msg(sc->sc_sock, data, datalen);
+		if (ret > 0) {
+			sc->sc_page_off += ret;
+			/* only swab incoming here.. we can
+			 * only get here once as we cross from
+			 * being under to over */
+			if (sc->sc_page_off == sizeof(struct o2net_msg)) {
+				hdr = page_address(sc->sc_page);
+				if (be16_to_cpu(hdr->data_len) >
+				    O2NET_MAX_PAYLOAD_BYTES)
+					ret = -EOVERFLOW;
+			}
+		}
+		if (ret <= 0)
+			goto out;
+	}
+
+	if (sc->sc_page_off < sizeof(struct o2net_msg)) {
+		/* oof, still don't have a header */
+		goto out;
+	}
+
+	/* this was swabbed above when we first read it */
+	hdr = page_address(sc->sc_page);
+
+	msglog(hdr, "at page_off %zu\n", sc->sc_page_off);
+
+	/* do we need more payload? */
+	if (sc->sc_page_off - sizeof(struct o2net_msg) < be16_to_cpu(hdr->data_len)) {
+		/* need more payload */
+		data = page_address(sc->sc_page) + sc->sc_page_off;
+		datalen = (sizeof(struct o2net_msg) + be16_to_cpu(hdr->data_len)) -
+			  sc->sc_page_off;
+		ret = o2net_recv_tcp_msg(sc->sc_sock, data, datalen);
+		if (ret > 0)
+			sc->sc_page_off += ret;
+		if (ret <= 0)
+			goto out;
+	}
+
+	if (sc->sc_page_off - sizeof(struct o2net_msg) == be16_to_cpu(hdr->data_len)) {
+		/* we can only get here once, the first time we read
+		 * the payload.. so set ret to progress if the handler
+		 * works out. after calling this the message is toast */
+		ret = o2net_process_message(sc, hdr);
+		if (ret == 0)
+			ret = 1;
+		sc->sc_page_off = 0;
+	}
+
+out:
+	sclog(sc, "ret = %d\n", ret);
+	o2net_set_advance_stop_time(sc);
+	return ret;
+}
+
+/* this work func is triggerd by data ready.  it reads until it can read no
+ * more.  it interprets 0, eof, as fatal.  if data_ready hits while we're doing
+ * our work the work struct will be marked and we'll be called again. */
+static void o2net_rx_until_empty(struct work_struct *work)
+{
+	struct o2net_sock_container *sc =
+		container_of(work, struct o2net_sock_container, sc_rx_work);
+	int ret;
+
+	do {
+		ret = o2net_advance_rx(sc);
+	} while (ret > 0);
+
+	if (ret <= 0 && ret != -EAGAIN) {
+		struct o2net_node *nn = o2net_nn_from_num(sc->sc_node->nd_num);
+		sclog(sc, "saw error %d, closing\n", ret);
+		/* not permanent so read failed handshake can retry */
+		o2net_ensure_shutdown(nn, sc, 0);
+	}
+
+	sc_put(sc);
+}
+
+static int o2net_set_nodelay(struct socket *sock)
+{
+	int ret, val = 1;
+	mm_segment_t oldfs;
+
+	oldfs = get_fs();
+	set_fs(KERNEL_DS);
+
+	/*
+	 * Dear unsuspecting programmer,
+	 *
+	 * Don't use sock_setsockopt() for SOL_TCP.  It doesn't check its level
+	 * argument and assumes SOL_SOCKET so, say, your TCP_NODELAY will
+	 * silently turn into SO_DEBUG.
+	 *
+	 * Yours,
+	 * Keeper of hilariously fragile interfaces.
+	 */
+	ret = sock->ops->setsockopt(sock, SOL_TCP, TCP_NODELAY,
+				    (char __user *)&val, sizeof(val));
+
+	set_fs(oldfs);
+	return ret;
+}
+
+static void o2net_initialize_handshake(void)
+{
+	o2net_hand->o2hb_heartbeat_timeout_ms = cpu_to_be32(
+		O2HB_MAX_WRITE_TIMEOUT_MS);
+	o2net_hand->o2net_idle_timeout_ms = cpu_to_be32(o2net_idle_timeout());
+	o2net_hand->o2net_keepalive_delay_ms = cpu_to_be32(
+		o2net_keepalive_delay());
+	o2net_hand->o2net_reconnect_delay_ms = cpu_to_be32(
+		o2net_reconnect_delay());
+}
+
+/* ------------------------------------------------------------ */
+
+/* called when a connect completes and after a sock is accepted.  the
+ * rx path will see the response and mark the sc valid */
+static void o2net_sc_connect_completed(struct work_struct *work)
+{
+	struct o2net_sock_container *sc =
+		container_of(work, struct o2net_sock_container,
+			     sc_connect_work);
+
+	mlog(ML_MSG, "sc sending handshake with ver %llu id %llx\n",
+              (unsigned long long)O2NET_PROTOCOL_VERSION,
+	      (unsigned long long)be64_to_cpu(o2net_hand->connector_id));
+
+	o2net_initialize_handshake();
+	o2net_sendpage(sc, o2net_hand, sizeof(*o2net_hand));
+	sc_put(sc);
+}
+
+/* this is called as a work_struct func. */
+static void o2net_sc_send_keep_req(struct work_struct *work)
+{
+	struct o2net_sock_container *sc =
+		container_of(work, struct o2net_sock_container,
+			     sc_keepalive_work.work);
+
+	o2net_sendpage(sc, o2net_keep_req, sizeof(*o2net_keep_req));
+	sc_put(sc);
+}
+
+/* socket shutdown does a del_timer_sync against this as it tears down.
+ * we can't start this timer until we've got to the point in sc buildup
+ * where shutdown is going to be involved */
+static void o2net_idle_timer(unsigned long data)
+{
+	struct o2net_sock_container *sc = (struct o2net_sock_container *)data;
+	struct o2net_node *nn = o2net_nn_from_num(sc->sc_node->nd_num);
+#ifdef CONFIG_DEBUG_FS
+	unsigned long msecs = ktime_to_ms(ktime_get()) -
+		ktime_to_ms(sc->sc_tv_timer);
+#else
+	unsigned long msecs = o2net_idle_timeout();
+#endif
+
+	printk(KERN_NOTICE "o2net: Connection to " SC_NODEF_FMT " has been "
+	       "idle for %lu.%lu secs, shutting it down.\n", SC_NODEF_ARGS(sc),
+	       msecs / 1000, msecs % 1000);
+
+	/*
+	 * Initialize the nn_timeout so that the next connection attempt
+	 * will continue in o2net_start_connect.
+	 */
+	atomic_set(&nn->nn_timeout, 1);
+
+	o2net_sc_queue_work(sc, &sc->sc_shutdown_work);
+}
+
+static void o2net_sc_reset_idle_timer(struct o2net_sock_container *sc)
+{
+	o2net_sc_cancel_delayed_work(sc, &sc->sc_keepalive_work);
+	o2net_sc_queue_delayed_work(sc, &sc->sc_keepalive_work,
+		      msecs_to_jiffies(o2net_keepalive_delay()));
+	o2net_set_sock_timer(sc);
+	mod_timer(&sc->sc_idle_timeout,
+	       jiffies + msecs_to_jiffies(o2net_idle_timeout()));
+}
+
+static void o2net_sc_postpone_idle(struct o2net_sock_container *sc)
+{
+	/* Only push out an existing timer */
+	if (timer_pending(&sc->sc_idle_timeout))
+		o2net_sc_reset_idle_timer(sc);
+}
+
+/* this work func is kicked whenever a path sets the nn state which doesn't
+ * have valid set.  This includes seeing hb come up, losing a connection,
+ * having a connect attempt fail, etc. This centralizes the logic which decides
+ * if a connect attempt should be made or if we should give up and all future
+ * transmit attempts should fail */
+static void o2net_start_connect(struct work_struct *work)
+{
+	struct o2net_node *nn =
+		container_of(work, struct o2net_node, nn_connect_work.work);
+	struct o2net_sock_container *sc = NULL;
+	struct o2nm_node *node = NULL, *mynode = NULL;
+	struct socket *sock = NULL;
+	struct sockaddr_in myaddr = {0, }, remoteaddr = {0, };
+	int ret = 0, stop;
+	unsigned int timeout;
+
+	/* if we're greater we initiate tx, otherwise we accept */
+	if (o2nm_this_node() <= o2net_num_from_nn(nn))
+		goto out;
+
+	/* watch for racing with tearing a node down */
+	node = o2nm_get_node_by_num(o2net_num_from_nn(nn));
+	if (node == NULL) {
+		ret = 0;
+		goto out;
+	}
+
+	mynode = o2nm_get_node_by_num(o2nm_this_node());
+	if (mynode == NULL) {
+		ret = 0;
+		goto out;
+	}
+
+	spin_lock(&nn->nn_lock);
+	/*
+	 * see if we already have one pending or have given up.
+	 * For nn_timeout, it is set when we close the connection
+	 * because of the idle time out. So it means that we have
+	 * at least connected to that node successfully once,
+	 * now try to connect to it again.
+	 */
+	timeout = atomic_read(&nn->nn_timeout);
+	stop = (nn->nn_sc ||
+		(nn->nn_persistent_error &&
+		(nn->nn_persistent_error != -ENOTCONN || timeout == 0)));
+	spin_unlock(&nn->nn_lock);
+	if (stop)
+		goto out;
+
+	nn->nn_last_connect_attempt = jiffies;
+
+	sc = sc_alloc(node);
+	if (sc == NULL) {
+		mlog(0, "couldn't allocate sc\n");
+		ret = -ENOMEM;
+		goto out;
+	}
+
+	ret = sock_create(PF_INET, SOCK_STREAM, IPPROTO_TCP, &sock);
+	if (ret < 0) {
+		mlog(0, "can't create socket: %d\n", ret);
+		goto out;
+	}
+	sc->sc_sock = sock; /* freed by sc_kref_release */
+
+	sock->sk->sk_allocation = GFP_ATOMIC;
+
+	myaddr.sin_family = AF_INET;
+	myaddr.sin_addr.s_addr = mynode->nd_ipv4_address;
+	myaddr.sin_port = htons(0); /* any port */
+
+	ret = sock->ops->bind(sock, (struct sockaddr *)&myaddr,
+			      sizeof(myaddr));
+	if (ret) {
+		mlog(ML_ERROR, "bind failed with %d at address %pI4\n",
+		     ret, &mynode->nd_ipv4_address);
+		goto out;
+	}
+
+	ret = o2net_set_nodelay(sc->sc_sock);
+	if (ret) {
+		mlog(ML_ERROR, "setting TCP_NODELAY failed with %d\n", ret);
+		goto out;
+	}
+
+	o2net_register_callbacks(sc->sc_sock->sk, sc);
+
+	spin_lock(&nn->nn_lock);
+	/* handshake completion will set nn->nn_sc_valid */
+	o2net_set_nn_state(nn, sc, 0, 0);
+	spin_unlock(&nn->nn_lock);
+
+	remoteaddr.sin_family = AF_INET;
+	remoteaddr.sin_addr.s_addr = node->nd_ipv4_address;
+	remoteaddr.sin_port = node->nd_ipv4_port;
+
+	ret = sc->sc_sock->ops->connect(sc->sc_sock,
+					(struct sockaddr *)&remoteaddr,
+					sizeof(remoteaddr),
+					O_NONBLOCK);
+	if (ret == -EINPROGRESS)
+		ret = 0;
+
+out:
+	if (ret) {
+		printk(KERN_NOTICE "o2net: Connect attempt to " SC_NODEF_FMT
+		       " failed with errno %d\n", SC_NODEF_ARGS(sc), ret);
+		/* 0 err so that another will be queued and attempted
+		 * from set_nn_state */
+		if (sc)
+			o2net_ensure_shutdown(nn, sc, 0);
+	}
+	if (sc)
+		sc_put(sc);
+	if (node)
+		o2nm_node_put(node);
+	if (mynode)
+		o2nm_node_put(mynode);
+
+	return;
+}
+
+static void o2net_connect_expired(struct work_struct *work)
+{
+	struct o2net_node *nn =
+		container_of(work, struct o2net_node, nn_connect_expired.work);
+
+	spin_lock(&nn->nn_lock);
+	if (!nn->nn_sc_valid) {
+		printk(KERN_NOTICE "o2net: No connection established with "
+		       "node %u after %u.%u seconds, giving up.\n",
+		     o2net_num_from_nn(nn),
+		     o2net_idle_timeout() / 1000,
+		     o2net_idle_timeout() % 1000);
+
+		o2net_set_nn_state(nn, NULL, 0, -ENOTCONN);
+	}
+	spin_unlock(&nn->nn_lock);
+}
+
+static void o2net_still_up(struct work_struct *work)
+{
+	struct o2net_node *nn =
+		container_of(work, struct o2net_node, nn_still_up.work);
+
+	o2quo_hb_still_up(o2net_num_from_nn(nn));
+}
+
+/* ------------------------------------------------------------ */
+
+void o2net_disconnect_node(struct o2nm_node *node)
+{
+	struct o2net_node *nn = o2net_nn_from_num(node->nd_num);
+
+	/* don't reconnect until it's heartbeating again */
+	spin_lock(&nn->nn_lock);
+	atomic_set(&nn->nn_timeout, 0);
+	o2net_set_nn_state(nn, NULL, 0, -ENOTCONN);
+	spin_unlock(&nn->nn_lock);
+
+	if (o2net_wq) {
+		cancel_delayed_work(&nn->nn_connect_expired);
+		cancel_delayed_work(&nn->nn_connect_work);
+		cancel_delayed_work(&nn->nn_still_up);
+		flush_workqueue(o2net_wq);
+	}
+}
+
+static void o2net_hb_node_down_cb(struct o2nm_node *node, int node_num,
+				  void *data)
+{
+	o2quo_hb_down(node_num);
+
+	if (!node)
+		return;
+
+	if (node_num != o2nm_this_node())
+		o2net_disconnect_node(node);
+
+	BUG_ON(atomic_read(&o2net_connected_peers) < 0);
+}
+
+static void o2net_hb_node_up_cb(struct o2nm_node *node, int node_num,
+				void *data)
+{
+	struct o2net_node *nn = o2net_nn_from_num(node_num);
+
+	o2quo_hb_up(node_num);
+
+	BUG_ON(!node);
+
+	/* ensure an immediate connect attempt */
+	nn->nn_last_connect_attempt = jiffies -
+		(msecs_to_jiffies(o2net_reconnect_delay()) + 1);
+
+	if (node_num != o2nm_this_node()) {
+		/* believe it or not, accept and node hearbeating testing
+		 * can succeed for this node before we got here.. so
+		 * only use set_nn_state to clear the persistent error
+		 * if that hasn't already happened */
+		spin_lock(&nn->nn_lock);
+		atomic_set(&nn->nn_timeout, 0);
+		if (nn->nn_persistent_error)
+			o2net_set_nn_state(nn, NULL, 0, 0);
+		spin_unlock(&nn->nn_lock);
+	}
+}
+
+void o2net_unregister_hb_callbacks(void)
+{
+	o2hb_unregister_callback(NULL, &o2net_hb_up);
+	o2hb_unregister_callback(NULL, &o2net_hb_down);
+}
+
+int o2net_register_hb_callbacks(void)
+{
+	int ret;
+
+	o2hb_setup_callback(&o2net_hb_down, O2HB_NODE_DOWN_CB,
+			    o2net_hb_node_down_cb, NULL, O2NET_HB_PRI);
+	o2hb_setup_callback(&o2net_hb_up, O2HB_NODE_UP_CB,
+			    o2net_hb_node_up_cb, NULL, O2NET_HB_PRI);
+
+	ret = o2hb_register_callback(NULL, &o2net_hb_up);
+	if (ret == 0)
+		ret = o2hb_register_callback(NULL, &o2net_hb_down);
+
+	if (ret)
+		o2net_unregister_hb_callbacks();
+
+	return ret;
+}
+
+/* ------------------------------------------------------------ */
+
+static int o2net_accept_one(struct socket *sock)
+{
+	int ret, slen;
+	struct sockaddr_in sin;
+	struct socket *new_sock = NULL;
+	struct o2nm_node *node = NULL;
+	struct o2nm_node *local_node = NULL;
+	struct o2net_sock_container *sc = NULL;
+	struct o2net_node *nn;
+
+	BUG_ON(sock == NULL);
+	ret = sock_create_lite(sock->sk->sk_family, sock->sk->sk_type,
+			       sock->sk->sk_protocol, &new_sock);
+	if (ret)
+		goto out;
+
+	new_sock->type = sock->type;
+	new_sock->ops = sock->ops;
+	ret = sock->ops->accept(sock, new_sock, O_NONBLOCK);
+	if (ret < 0)
+		goto out;
+
+	new_sock->sk->sk_allocation = GFP_ATOMIC;
+
+	ret = o2net_set_nodelay(new_sock);
+	if (ret) {
+		mlog(ML_ERROR, "setting TCP_NODELAY failed with %d\n", ret);
+		goto out;
+	}
+
+	slen = sizeof(sin);
+	ret = new_sock->ops->getname(new_sock, (struct sockaddr *) &sin,
+				       &slen, 1);
+	if (ret < 0)
+		goto out;
+
+	node = o2nm_get_node_by_ip(sin.sin_addr.s_addr);
+	if (node == NULL) {
+		printk(KERN_NOTICE "o2net: Attempt to connect from unknown "
+		       "node at %pI4:%d\n", &sin.sin_addr.s_addr,
+		       ntohs(sin.sin_port));
+		ret = -EINVAL;
+		goto out;
+	}
+
+	if (o2nm_this_node() >= node->nd_num) {
+		local_node = o2nm_get_node_by_num(o2nm_this_node());
+		printk(KERN_NOTICE "o2net: Unexpected connect attempt seen "
+		       "at node '%s' (%u, %pI4:%d) from node '%s' (%u, "
+		       "%pI4:%d)\n", local_node->nd_name, local_node->nd_num,
+		       &(local_node->nd_ipv4_address),
+		       ntohs(local_node->nd_ipv4_port), node->nd_name,
+		       node->nd_num, &sin.sin_addr.s_addr, ntohs(sin.sin_port));
+		ret = -EINVAL;
+		goto out;
+	}
+
+	/* this happens all the time when the other node sees our heartbeat
+	 * and tries to connect before we see their heartbeat */
+	if (!o2hb_check_node_heartbeating_from_callback(node->nd_num)) {
+		mlog(ML_CONN, "attempt to connect from node '%s' at "
+		     "%pI4:%d but it isn't heartbeating\n",
+		     node->nd_name, &sin.sin_addr.s_addr,
+		     ntohs(sin.sin_port));
+		ret = -EINVAL;
+		goto out;
+	}
+
+	nn = o2net_nn_from_num(node->nd_num);
+
+	spin_lock(&nn->nn_lock);
+	if (nn->nn_sc)
+		ret = -EBUSY;
+	else
+		ret = 0;
+	spin_unlock(&nn->nn_lock);
+	if (ret) {
+		printk(KERN_NOTICE "o2net: Attempt to connect from node '%s' "
+		       "at %pI4:%d but it already has an open connection\n",
+		       node->nd_name, &sin.sin_addr.s_addr,
+		       ntohs(sin.sin_port));
+		goto out;
+	}
+
+	sc = sc_alloc(node);
+	if (sc == NULL) {
+		ret = -ENOMEM;
+		goto out;
+	}
+
+	sc->sc_sock = new_sock;
+	new_sock = NULL;
+
+	spin_lock(&nn->nn_lock);
+	atomic_set(&nn->nn_timeout, 0);
+	o2net_set_nn_state(nn, sc, 0, 0);
+	spin_unlock(&nn->nn_lock);
+
+	o2net_register_callbacks(sc->sc_sock->sk, sc);
+	o2net_sc_queue_work(sc, &sc->sc_rx_work);
+
+	o2net_initialize_handshake();
+	o2net_sendpage(sc, o2net_hand, sizeof(*o2net_hand));
+
+out:
+	if (new_sock)
+		sock_release(new_sock);
+	if (node)
+		o2nm_node_put(node);
+	if (local_node)
+		o2nm_node_put(local_node);
+	if (sc)
+		sc_put(sc);
+	return ret;
+}
+
+static void o2net_accept_many(struct work_struct *work)
+{
+	struct socket *sock = o2net_listen_sock;
+	while (o2net_accept_one(sock) == 0)
+		cond_resched();
+}
+
+static void o2net_listen_data_ready(struct sock *sk, int bytes)
+{
+	void (*ready)(struct sock *sk, int bytes);
+
+	read_lock(&sk->sk_callback_lock);
+	ready = sk->sk_user_data;
+	if (ready == NULL) { /* check for teardown race */
+		ready = sk->sk_data_ready;
+		goto out;
+	}
+
+	/* ->sk_data_ready is also called for a newly established child socket
+	 * before it has been accepted and the acceptor has set up their
+	 * data_ready.. we only want to queue listen work for our listening
+	 * socket */
+	if (sk->sk_state == TCP_LISTEN) {
+		mlog(ML_TCP, "bytes: %d\n", bytes);
+		queue_work(o2net_wq, &o2net_listen_work);
+	}
+
+out:
+	read_unlock(&sk->sk_callback_lock);
+	ready(sk, bytes);
+}
+
+static int o2net_open_listening_sock(__be32 addr, __be16 port)
+{
+	struct socket *sock = NULL;
+	int ret;
+	struct sockaddr_in sin = {
+		.sin_family = PF_INET,
+		.sin_addr = { .s_addr = addr },
+		.sin_port = port,
+	};
+
+	ret = sock_create(PF_INET, SOCK_STREAM, IPPROTO_TCP, &sock);
+	if (ret < 0) {
+		printk(KERN_ERR "o2net: Error %d while creating socket\n", ret);
+		goto out;
+	}
+
+	sock->sk->sk_allocation = GFP_ATOMIC;
+
+	write_lock_bh(&sock->sk->sk_callback_lock);
+	sock->sk->sk_user_data = sock->sk->sk_data_ready;
+	sock->sk->sk_data_ready = o2net_listen_data_ready;
+	write_unlock_bh(&sock->sk->sk_callback_lock);
+
+	o2net_listen_sock = sock;
+	INIT_WORK(&o2net_listen_work, o2net_accept_many);
+
+	sock->sk->sk_reuse = 1;
+	ret = sock->ops->bind(sock, (struct sockaddr *)&sin, sizeof(sin));
+	if (ret < 0) {
+		printk(KERN_ERR "o2net: Error %d while binding socket at "
+		       "%pI4:%u\n", ret, &addr, ntohs(port)); 
+		goto out;
+	}
+
+	ret = sock->ops->listen(sock, 64);
+	if (ret < 0)
+		printk(KERN_ERR "o2net: Error %d while listening on %pI4:%u\n",
+		       ret, &addr, ntohs(port));
+
+out:
+	if (ret) {
+		o2net_listen_sock = NULL;
+		if (sock)
+			sock_release(sock);
+	}
+	return ret;
+}
+
+/*
+ * called from node manager when we should bring up our network listening
+ * socket.  node manager handles all the serialization to only call this
+ * once and to match it with o2net_stop_listening().  note,
+ * o2nm_this_node() doesn't work yet as we're being called while it
+ * is being set up.
+ */
+int o2net_start_listening(struct o2nm_node *node)
+{
+	int ret = 0;
+
+	BUG_ON(o2net_wq != NULL);
+	BUG_ON(o2net_listen_sock != NULL);
+
+	mlog(ML_KTHREAD, "starting o2net thread...\n");
+	o2net_wq = create_singlethread_workqueue("o2net");
+	if (o2net_wq == NULL) {
+		mlog(ML_ERROR, "unable to launch o2net thread\n");
+		return -ENOMEM; /* ? */
+	}
+
+	ret = o2net_open_listening_sock(node->nd_ipv4_address,
+					node->nd_ipv4_port);
+	if (ret) {
+		destroy_workqueue(o2net_wq);
+		o2net_wq = NULL;
+	} else
+		o2quo_conn_up(node->nd_num);
+
+	return ret;
+}
+
+/* again, o2nm_this_node() doesn't work here as we're involved in
+ * tearing it down */
+void o2net_stop_listening(struct o2nm_node *node)
+{
+	struct socket *sock = o2net_listen_sock;
+	size_t i;
+
+	BUG_ON(o2net_wq == NULL);
+	BUG_ON(o2net_listen_sock == NULL);
+
+	/* stop the listening socket from generating work */
+	write_lock_bh(&sock->sk->sk_callback_lock);
+	sock->sk->sk_data_ready = sock->sk->sk_user_data;
+	sock->sk->sk_user_data = NULL;
+	write_unlock_bh(&sock->sk->sk_callback_lock);
+
+	for (i = 0; i < ARRAY_SIZE(o2net_nodes); i++) {
+		struct o2nm_node *node = o2nm_get_node_by_num(i);
+		if (node) {
+			o2net_disconnect_node(node);
+			o2nm_node_put(node);
+		}
+	}
+
+	/* finish all work and tear down the work queue */
+	mlog(ML_KTHREAD, "waiting for o2net thread to exit....\n");
+	destroy_workqueue(o2net_wq);
+	o2net_wq = NULL;
+
+	sock_release(o2net_listen_sock);
+	o2net_listen_sock = NULL;
+
+	o2quo_conn_err(node->nd_num);
+}
+
+/* ------------------------------------------------------------ */
+
+int o2net_init(void)
+{
+	unsigned long i;
+
+	o2quo_init();
+
+	if (o2net_debugfs_init())
+		return -ENOMEM;
+
+	o2net_hand = kzalloc(sizeof(struct o2net_handshake), GFP_KERNEL);
+	o2net_keep_req = kzalloc(sizeof(struct o2net_msg), GFP_KERNEL);
+	o2net_keep_resp = kzalloc(sizeof(struct o2net_msg), GFP_KERNEL);
+	if (!o2net_hand || !o2net_keep_req || !o2net_keep_resp) {
+		kfree(o2net_hand);
+		kfree(o2net_keep_req);
+		kfree(o2net_keep_resp);
+		return -ENOMEM;
+	}
+
+	o2net_hand->protocol_version = cpu_to_be64(O2NET_PROTOCOL_VERSION);
+	o2net_hand->connector_id = cpu_to_be64(1);
+
+	o2net_keep_req->magic = cpu_to_be16(O2NET_MSG_KEEP_REQ_MAGIC);
+	o2net_keep_resp->magic = cpu_to_be16(O2NET_MSG_KEEP_RESP_MAGIC);
+
+	for (i = 0; i < ARRAY_SIZE(o2net_nodes); i++) {
+		struct o2net_node *nn = o2net_nn_from_num(i);
+
+		atomic_set(&nn->nn_timeout, 0);
+		spin_lock_init(&nn->nn_lock);
+		INIT_DELAYED_WORK(&nn->nn_connect_work, o2net_start_connect);
+		INIT_DELAYED_WORK(&nn->nn_connect_expired,
+				  o2net_connect_expired);
+		INIT_DELAYED_WORK(&nn->nn_still_up, o2net_still_up);
+		/* until we see hb from a node we'll return einval */
+		nn->nn_persistent_error = -ENOTCONN;
+		init_waitqueue_head(&nn->nn_sc_wq);
+		idr_init(&nn->nn_status_idr);
+		INIT_LIST_HEAD(&nn->nn_status_list);
+	}
+
+	return 0;
+}
+
+void o2net_exit(void)
+{
+	o2quo_exit();
+	kfree(o2net_hand);
+	kfree(o2net_keep_req);
+	kfree(o2net_keep_resp);
+	o2net_debugfs_exit();
+}
diff --git a/drivers/staging/ramster/cluster/tcp.h b/drivers/staging/ramster/cluster/tcp.h
new file mode 100644
index 0000000..5bada2a
--- /dev/null
+++ b/drivers/staging/ramster/cluster/tcp.h
@@ -0,0 +1,154 @@
+/* -*- mode: c; c-basic-offset: 8; -*-
+ * vim: noexpandtab sw=8 ts=8 sts=0:
+ *
+ * tcp.h
+ *
+ * Function prototypes
+ *
+ * Copyright (C) 2004 Oracle.  All rights reserved.
+ *
+ * This program is free software; you can redistribute it and/or
+ * modify it under the terms of the GNU General Public
+ * License as published by the Free Software Foundation; either
+ * version 2 of the License, or (at your option) any later version.
+ *
+ * This program is distributed in the hope that it will be useful,
+ * but WITHOUT ANY WARRANTY; without even the implied warranty of
+ * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
+ * General Public License for more details.
+ *
+ * You should have received a copy of the GNU General Public
+ * License along with this program; if not, write to the
+ * Free Software Foundation, Inc., 59 Temple Place - Suite 330,
+ * Boston, MA 021110-1307, USA.
+ *
+ */
+
+#ifndef O2CLUSTER_TCP_H
+#define O2CLUSTER_TCP_H
+
+#include <linux/socket.h>
+#ifdef __KERNEL__
+#include <net/sock.h>
+#include <linux/tcp.h>
+#else
+#include <sys/socket.h>
+#endif
+#include <linux/inet.h>
+#include <linux/in.h>
+
+struct o2net_msg
+{
+	__be16 magic;
+	__be16 data_len;
+	__be16 msg_type;
+	__be16 pad1;
+	__be32 sys_status;
+	__be32 status;
+	__be32 key;
+	__be32 msg_num;
+	__u8  buf[0];
+};
+
+typedef int (o2net_msg_handler_func)(struct o2net_msg *msg, u32 len, void *data,
+				     void **ret_data);
+typedef void (o2net_post_msg_handler_func)(int status, void *data,
+					   void *ret_data);
+
+#define O2NET_MAX_PAYLOAD_BYTES  (4096 - sizeof(struct o2net_msg))
+
+/* same as hb delay, we're waiting for another node to recognize our hb */
+#define O2NET_RECONNECT_DELAY_MS_DEFAULT	2000
+
+#define O2NET_KEEPALIVE_DELAY_MS_DEFAULT	2000
+#define O2NET_IDLE_TIMEOUT_MS_DEFAULT		30000
+
+
+/* TODO: figure this out.... */
+static inline int o2net_link_down(int err, struct socket *sock)
+{
+	if (sock) {
+		if (sock->sk->sk_state != TCP_ESTABLISHED &&
+	    	    sock->sk->sk_state != TCP_CLOSE_WAIT)
+			return 1;
+	}
+
+	if (err >= 0)
+		return 0;
+	switch (err) {
+		/* ????????????????????????? */
+		case -ERESTARTSYS:
+		case -EBADF:
+		/* When the server has died, an ICMP port unreachable
+		 * message prompts ECONNREFUSED. */
+		case -ECONNREFUSED:
+		case -ENOTCONN:
+		case -ECONNRESET:
+		case -EPIPE:
+			return 1;
+	}
+	return 0;
+}
+
+enum {
+	O2NET_DRIVER_UNINITED,
+	O2NET_DRIVER_READY,
+};
+
+int o2net_send_message(u32 msg_type, u32 key, void *data, u32 len,
+		       u8 target_node, int *status);
+int o2net_send_message_vec(u32 msg_type, u32 key, struct kvec *vec,
+			   size_t veclen, u8 target_node, int *status);
+
+int o2net_register_handler(u32 msg_type, u32 key, u32 max_len,
+			   o2net_msg_handler_func *func, void *data,
+			   o2net_post_msg_handler_func *post_func,
+			   struct list_head *unreg_list);
+void o2net_unregister_handler_list(struct list_head *list);
+
+void o2net_fill_node_map(unsigned long *map, unsigned bytes);
+
+struct o2nm_node;
+int o2net_register_hb_callbacks(void);
+void o2net_unregister_hb_callbacks(void);
+int o2net_start_listening(struct o2nm_node *node);
+void o2net_stop_listening(struct o2nm_node *node);
+void o2net_disconnect_node(struct o2nm_node *node);
+int o2net_num_connected_peers(void);
+
+int o2net_init(void);
+void o2net_exit(void);
+
+struct o2net_send_tracking;
+struct o2net_sock_container;
+
+#ifdef CONFIG_DEBUG_FS
+int o2net_debugfs_init(void);
+void o2net_debugfs_exit(void);
+void o2net_debug_add_nst(struct o2net_send_tracking *nst);
+void o2net_debug_del_nst(struct o2net_send_tracking *nst);
+void o2net_debug_add_sc(struct o2net_sock_container *sc);
+void o2net_debug_del_sc(struct o2net_sock_container *sc);
+#else
+static inline int o2net_debugfs_init(void)
+{
+	return 0;
+}
+static inline void o2net_debugfs_exit(void)
+{
+}
+static inline void o2net_debug_add_nst(struct o2net_send_tracking *nst)
+{
+}
+static inline void o2net_debug_del_nst(struct o2net_send_tracking *nst)
+{
+}
+static inline void o2net_debug_add_sc(struct o2net_sock_container *sc)
+{
+}
+static inline void o2net_debug_del_sc(struct o2net_sock_container *sc)
+{
+}
+#endif	/* CONFIG_DEBUG_FS */
+
+#endif /* O2CLUSTER_TCP_H */
diff --git a/drivers/staging/ramster/cluster/tcp_internal.h b/drivers/staging/ramster/cluster/tcp_internal.h
new file mode 100644
index 0000000..4cbcb65
--- /dev/null
+++ b/drivers/staging/ramster/cluster/tcp_internal.h
@@ -0,0 +1,242 @@
+/* -*- mode: c; c-basic-offset: 8; -*-
+ * vim: noexpandtab sw=8 ts=8 sts=0:
+ *
+ * Copyright (C) 2005 Oracle.  All rights reserved.
+ *
+ * This program is free software; you can redistribute it and/or
+ * modify it under the terms of the GNU General Public
+ * License as published by the Free Software Foundation; either
+ * version 2 of the License, or (at your option) any later version.
+ *
+ * This program is distributed in the hope that it will be useful,
+ * but WITHOUT ANY WARRANTY; without even the implied warranty of
+ * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
+ * General Public License for more details.
+ *
+ * You should have received a copy of the GNU General Public
+ * License along with this program; if not, write to the
+ * Free Software Foundation, Inc., 59 Temple Place - Suite 330,
+ * Boston, MA 021110-1307, USA.
+ */
+
+#ifndef O2CLUSTER_TCP_INTERNAL_H
+#define O2CLUSTER_TCP_INTERNAL_H
+
+#define O2NET_MSG_MAGIC           ((u16)0xfa55)
+#define O2NET_MSG_STATUS_MAGIC    ((u16)0xfa56)
+#define O2NET_MSG_KEEP_REQ_MAGIC  ((u16)0xfa57)
+#define O2NET_MSG_KEEP_RESP_MAGIC ((u16)0xfa58)
+
+/* we're delaying our quorum decision so that heartbeat will have timed
+ * out truly dead nodes by the time we come around to making decisions
+ * on their number */
+#define O2NET_QUORUM_DELAY_MS	((o2hb_dead_threshold + 2) * O2HB_REGION_TIMEOUT_MS)
+
+/*
+ * This version number represents quite a lot, unfortunately.  It not
+ * only represents the raw network message protocol on the wire but also
+ * locking semantics of the file system using the protocol.  It should
+ * be somewhere else, I'm sure, but right now it isn't.
+ *
+ * With version 11, we separate out the filesystem locking portion.  The
+ * filesystem now has a major.minor version it negotiates.  Version 11
+ * introduces this negotiation to the o2dlm protocol, and as such the
+ * version here in tcp_internal.h should not need to be bumped for
+ * filesystem locking changes.
+ *
+ * New in version 11
+ * 	- Negotiation of filesystem locking in the dlm join.
+ *
+ * New in version 10:
+ * 	- Meta/data locks combined
+ *
+ * New in version 9:
+ * 	- All votes removed
+ *
+ * New in version 8:
+ * 	- Replace delete inode votes with a cluster lock
+ *
+ * New in version 7:
+ * 	- DLM join domain includes the live nodemap
+ *
+ * New in version 6:
+ * 	- DLM lockres remote refcount fixes.
+ *
+ * New in version 5:
+ * 	- Network timeout checking protocol
+ *
+ * New in version 4:
+ * 	- Remove i_generation from lock names for better stat performance.
+ *
+ * New in version 3:
+ * 	- Replace dentry votes with a cluster lock
+ *
+ * New in version 2:
+ * 	- full 64 bit i_size in the metadata lock lvbs
+ * 	- introduction of "rw" lock and pushing meta/data locking down
+ */
+#define O2NET_PROTOCOL_VERSION 11ULL
+struct o2net_handshake {
+	__be64	protocol_version;
+	__be64	connector_id;
+	__be32  o2hb_heartbeat_timeout_ms;
+	__be32  o2net_idle_timeout_ms;
+	__be32  o2net_keepalive_delay_ms;
+	__be32  o2net_reconnect_delay_ms;
+};
+
+struct o2net_node {
+	/* this is never called from int/bh */
+	spinlock_t			nn_lock;
+
+	/* set the moment an sc is allocated and a connect is started */
+	struct o2net_sock_container	*nn_sc;
+	/* _valid is only set after the handshake passes and tx can happen */
+	unsigned			nn_sc_valid:1;
+	/* if this is set tx just returns it */
+	int				nn_persistent_error;
+	/* It is only set to 1 after the idle time out. */
+	atomic_t			nn_timeout;
+
+	/* threads waiting for an sc to arrive wait on the wq for generation
+	 * to increase.  it is increased when a connecting socket succeeds
+	 * or fails or when an accepted socket is attached. */
+	wait_queue_head_t		nn_sc_wq;
+
+	struct idr			nn_status_idr;
+	struct list_head		nn_status_list;
+
+	/* connects are attempted from when heartbeat comes up until either hb
+	 * goes down, the node is unconfigured, no connect attempts succeed
+	 * before O2NET_CONN_IDLE_DELAY, or a connect succeeds.  connect_work
+	 * is queued from set_nn_state both from hb up and from itself if a
+	 * connect attempt fails and so can be self-arming.  shutdown is
+	 * careful to first mark the nn such that no connects will be attempted
+	 * before canceling delayed connect work and flushing the queue. */
+	struct delayed_work		nn_connect_work;
+	unsigned long			nn_last_connect_attempt;
+
+	/* this is queued as nodes come up and is canceled when a connection is
+	 * established.  this expiring gives up on the node and errors out
+	 * transmits */
+	struct delayed_work		nn_connect_expired;
+
+	/* after we give up on a socket we wait a while before deciding
+	 * that it is still heartbeating and that we should do some
+	 * quorum work */
+	struct delayed_work		nn_still_up;
+};
+
+struct o2net_sock_container {
+	struct kref		sc_kref;
+	/* the next two are valid for the life time of the sc */
+	struct socket		*sc_sock;
+	struct o2nm_node	*sc_node;
+
+	/* all of these sc work structs hold refs on the sc while they are
+	 * queued.  they should not be able to ref a freed sc.  the teardown
+	 * race is with o2net_wq destruction in o2net_stop_listening() */
+
+	/* rx and connect work are generated from socket callbacks.  sc
+	 * shutdown removes the callbacks and then flushes the work queue */
+	struct work_struct	sc_rx_work;
+	struct work_struct	sc_connect_work;
+	/* shutdown work is triggered in two ways.  the simple way is
+	 * for a code path calls ensure_shutdown which gets a lock, removes
+	 * the sc from the nn, and queues the work.  in this case the
+	 * work is single-shot.  the work is also queued from a sock
+	 * callback, though, and in this case the work will find the sc
+	 * still on the nn and will call ensure_shutdown itself.. this
+	 * ends up triggering the shutdown work again, though nothing
+	 * will be done in that second iteration.  so work queue teardown
+	 * has to be careful to remove the sc from the nn before waiting
+	 * on the work queue so that the shutdown work doesn't remove the
+	 * sc and rearm itself.
+	 */
+	struct work_struct	sc_shutdown_work;
+
+	struct timer_list	sc_idle_timeout;
+	struct delayed_work	sc_keepalive_work;
+
+	unsigned		sc_handshake_ok:1;
+
+	struct page 		*sc_page;
+	size_t			sc_page_off;
+
+	/* original handlers for the sockets */
+	void			(*sc_state_change)(struct sock *sk);
+	void			(*sc_data_ready)(struct sock *sk, int bytes);
+
+	u32			sc_msg_key;
+	u16			sc_msg_type;
+
+#ifdef CONFIG_DEBUG_FS
+	struct list_head        sc_net_debug_item;
+	ktime_t			sc_tv_timer;
+	ktime_t			sc_tv_data_ready;
+	ktime_t			sc_tv_advance_start;
+	ktime_t			sc_tv_advance_stop;
+	ktime_t			sc_tv_func_start;
+	ktime_t			sc_tv_func_stop;
+#endif
+#ifdef CONFIG_OCFS2_FS_STATS
+	ktime_t			sc_tv_acquiry_total;
+	ktime_t			sc_tv_send_total;
+	ktime_t			sc_tv_status_total;
+	u32			sc_send_count;
+	u32			sc_recv_count;
+	ktime_t			sc_tv_process_total;
+#endif
+	struct mutex		sc_send_lock;
+};
+
+struct o2net_msg_handler {
+	struct rb_node		nh_node;
+	u32			nh_max_len;
+	u32			nh_msg_type;
+	u32			nh_key;
+	o2net_msg_handler_func	*nh_func;
+	o2net_msg_handler_func	*nh_func_data;
+	o2net_post_msg_handler_func
+				*nh_post_func;
+	struct kref		nh_kref;
+	struct list_head	nh_unregister_item;
+};
+
+enum o2net_system_error {
+	O2NET_ERR_NONE = 0,
+	O2NET_ERR_NO_HNDLR,
+	O2NET_ERR_OVERFLOW,
+	O2NET_ERR_DIED,
+	O2NET_ERR_MAX
+};
+
+struct o2net_status_wait {
+	enum o2net_system_error	ns_sys_status;
+	s32			ns_status;
+	int			ns_id;
+	wait_queue_head_t	ns_wq;
+	struct list_head	ns_node_item;
+};
+
+#ifdef CONFIG_DEBUG_FS
+/* just for state dumps */
+struct o2net_send_tracking {
+	struct list_head		st_net_debug_item;
+	struct task_struct		*st_task;
+	struct o2net_sock_container	*st_sc;
+	u32				st_id;
+	u32				st_msg_type;
+	u32				st_msg_key;
+	u8				st_node;
+	ktime_t				st_sock_time;
+	ktime_t				st_send_time;
+	ktime_t				st_status_time;
+};
+#else
+struct o2net_send_tracking {
+	u32	dummy;
+};
+#endif	/* CONFIG_DEBUG_FS */
+
+#endif /* O2CLUSTER_TCP_INTERNAL_H */
diff --git a/drivers/staging/ramster/cluster/ver.c b/drivers/staging/ramster/cluster/ver.c
new file mode 100644
index 0000000..a56eee6
--- /dev/null
+++ b/drivers/staging/ramster/cluster/ver.c
@@ -0,0 +1,42 @@
+/* -*- mode: c; c-basic-offset: 8; -*-
+ * vim: noexpandtab sw=8 ts=8 sts=0:
+ *
+ * ver.c
+ *
+ * version string
+ *
+ * Copyright (C) 2002, 2005 Oracle.  All rights reserved.
+ *
+ * This program is free software; you can redistribute it and/or
+ * modify it under the terms of the GNU General Public
+ * License as published by the Free Software Foundation; either
+ * version 2 of the License, or (at your option) any later version.
+ *
+ * This program is distributed in the hope that it will be useful,
+ * but WITHOUT ANY WARRANTY; without even the implied warranty of
+ * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
+ * General Public License for more details.
+ *
+ * You should have received a copy of the GNU General Public
+ * License along with this program; if not, write to the
+ * Free Software Foundation, Inc., 59 Temple Place - Suite 330,
+ * Boston, MA 021110-1307, USA.
+ */
+
+#include <linux/module.h>
+#include <linux/kernel.h>
+
+#include "ver.h"
+
+#define CLUSTER_BUILD_VERSION "1.5.0"
+
+#define VERSION_STR "OCFS2 Node Manager " CLUSTER_BUILD_VERSION
+
+void cluster_print_version(void)
+{
+	printk(KERN_INFO "%s\n", VERSION_STR);
+}
+
+MODULE_DESCRIPTION(VERSION_STR);
+
+MODULE_VERSION(CLUSTER_BUILD_VERSION);
diff --git a/drivers/staging/ramster/cluster/ver.h b/drivers/staging/ramster/cluster/ver.h
new file mode 100644
index 0000000..32554c3
--- /dev/null
+++ b/drivers/staging/ramster/cluster/ver.h
@@ -0,0 +1,31 @@
+/* -*- mode: c; c-basic-offset: 8; -*-
+ * vim: noexpandtab sw=8 ts=8 sts=0:
+ *
+ * ver.h
+ *
+ * Function prototypes
+ *
+ * Copyright (C) 2005 Oracle.  All rights reserved.
+ *
+ * This program is free software; you can redistribute it and/or
+ * modify it under the terms of the GNU General Public
+ * License as published by the Free Software Foundation; either
+ * version 2 of the License, or (at your option) any later version.
+ *
+ * This program is distributed in the hope that it will be useful,
+ * but WITHOUT ANY WARRANTY; without even the implied warranty of
+ * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
+ * General Public License for more details.
+ *
+ * You should have received a copy of the GNU General Public
+ * License along with this program; if not, write to the
+ * Free Software Foundation, Inc., 59 Temple Place - Suite 330,
+ * Boston, MA 021110-1307, USA.
+ */
+
+#ifndef O2CLUSTER_VER_H
+#define O2CLUSTER_VER_H
+
+void cluster_print_version(void);
+
+#endif /* O2CLUSTER_VER_H */
-- 
1.7.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
