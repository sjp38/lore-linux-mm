Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qg0-f51.google.com (mail-qg0-f51.google.com [209.85.192.51])
	by kanga.kvack.org (Postfix) with ESMTP id 8EE4A6B02B9
	for <linux-mm@kvack.org>; Fri, 22 May 2015 18:36:37 -0400 (EDT)
Received: by qget53 with SMTP id t53so17183603qge.3
        for <linux-mm@kvack.org>; Fri, 22 May 2015 15:36:37 -0700 (PDT)
Received: from mail-qg0-x233.google.com (mail-qg0-x233.google.com. [2607:f8b0:400d:c04::233])
        by mx.google.com with ESMTPS id f75si3909647qge.68.2015.05.22.15.36.36
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 22 May 2015 15:36:36 -0700 (PDT)
Received: by qgew3 with SMTP id w3so17204412qge.2
        for <linux-mm@kvack.org>; Fri, 22 May 2015 15:36:36 -0700 (PDT)
From: Tejun Heo <tj@kernel.org>
Subject: [PATCH 5/9] writeback: implement unlocked_inode_to_wb transaction and use it for stat updates
Date: Fri, 22 May 2015 18:36:19 -0400
Message-Id: <1432334183-6324-6-git-send-email-tj@kernel.org>
In-Reply-To: <1432334183-6324-1-git-send-email-tj@kernel.org>
References: <1432334183-6324-1-git-send-email-tj@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: axboe@kernel.dk
Cc: linux-kernel@vger.kernel.org, jack@suse.cz, hch@infradead.org, hannes@cmpxchg.org, linux-fsdevel@vger.kernel.org, vgoyal@redhat.com, lizefan@huawei.com, cgroups@vger.kernel.org, linux-mm@kvack.org, mhocko@suse.cz, clm@fb.com, fengguang.wu@intel.com, david@fromorbit.com, gthelen@google.com, khlebnikov@yandex-team.ru, Tejun Heo <tj@kernel.org>

The mechanism for detecting whether an inode should switch its wb
(bdi_writeback) association is now in place.  This patch build the
framework for the actual switching.

This patch adds a new inode flag I_WB_SWITCHING, which has two
functions.  First, the easy one, it ensures that there's only one
switching in progress for a give inode.  Second, it's used as a
mechanism to synchronize wb stat updates.

The two stats, WB_RECLAIMABLE and WB_WRITEBACK, aren't event counters
but track the current number of dirty pages and pages under writeback
respectively.  As such, when an inode is moved from one wb to another,
the inode's portion of those stats have to be transferred together;
unfortunately, this is a bit tricky as those stat updates are percpu
operations which are performed without holding any lock in some
places.

This patch solves the problem in a similar way as memcg.  Each such
lockless stat updates are wrapped in transaction surrounded by
unlocked_inode_to_wb_begin/end().  During normal operation, they map
to rcu_read_lock/unlock(); however, if I_WB_SWITCHING is asserted,
mapping->tree_lock is grabbed across the transaction.

In turn, the switching path sets I_WB_SWITCHING and waits for a RCU
grace period to pass before actually starting to switch, which
guarantees that all stat update paths are synchronizing against
mapping->tree_lock.

This patch still doesn't implement the actual switching.

v3: Updated on top of the recent cancel_dirty_page() updates.
    unlocked_inode_to_wb_begin() now nests inside
    mem_cgroup_begin_page_stat() to match the locking order.

v2: The i_wb access transaction will be used for !stat accesses too.
    Function names and comments updated accordingly.

    s/inode_wb_stat_unlocked_{begin|end}/unlocked_inode_to_wb_{begin|end}/
    s/switch_wb/switch_wbs/

Signed-off-by: Tejun Heo <tj@kernel.org>
Cc: Jens Axboe <axboe@kernel.dk>
Cc: Jan Kara <jack@suse.cz>
Cc: Wu Fengguang <fengguang.wu@intel.com>
Cc: Greg Thelen <gthelen@google.com>
---
 fs/fs-writeback.c           | 117 +++++++++++++++++++++++++++++++++++++++++---
 include/linux/backing-dev.h |  54 ++++++++++++++++++++
 include/linux/fs.h          |   6 +++
 include/linux/mm.h          |   3 +-
 mm/filemap.c                |   3 +-
 mm/page-writeback.c         |  27 +++++++---
 6 files changed, 196 insertions(+), 14 deletions(-)

diff --git a/fs/fs-writeback.c b/fs/fs-writeback.c
index f5565db..118e9c4 100644
--- a/fs/fs-writeback.c
+++ b/fs/fs-writeback.c
@@ -308,6 +308,115 @@ static struct bdi_writeback *inode_to_wb_and_lock_list(struct inode *inode)
 	return locked_inode_to_wb_and_lock_list(inode);
 }
 
+struct inode_switch_wbs_context {
+	struct inode		*inode;
+	struct bdi_writeback	*new_wb;
+
+	struct rcu_head		rcu_head;
+	struct work_struct	work;
+};
+
+static void inode_switch_wbs_work_fn(struct work_struct *work)
+{
+	struct inode_switch_wbs_context *isw =
+		container_of(work, struct inode_switch_wbs_context, work);
+	struct inode *inode = isw->inode;
+	struct bdi_writeback *new_wb = isw->new_wb;
+
+	/*
+	 * By the time control reaches here, RCU grace period has passed
+	 * since I_WB_SWITCH assertion and all wb stat update transactions
+	 * between unlocked_inode_to_wb_begin/end() are guaranteed to be
+	 * synchronizing against mapping->tree_lock.
+	 */
+	spin_lock(&inode->i_lock);
+
+	inode->i_wb_frn_winner = 0;
+	inode->i_wb_frn_avg_time = 0;
+	inode->i_wb_frn_history = 0;
+
+	/*
+	 * Paired with load_acquire in unlocked_inode_to_wb_begin() and
+	 * ensures that the new wb is visible if they see !I_WB_SWITCH.
+	 */
+	smp_store_release(&inode->i_state, inode->i_state & ~I_WB_SWITCH);
+
+	spin_unlock(&inode->i_lock);
+
+	iput(inode);
+	wb_put(new_wb);
+	kfree(isw);
+}
+
+static void inode_switch_wbs_rcu_fn(struct rcu_head *rcu_head)
+{
+	struct inode_switch_wbs_context *isw = container_of(rcu_head,
+				struct inode_switch_wbs_context, rcu_head);
+
+	/* needs to grab bh-unsafe locks, bounce to work item */
+	INIT_WORK(&isw->work, inode_switch_wbs_work_fn);
+	schedule_work(&isw->work);
+}
+
+/**
+ * inode_switch_wbs - change the wb association of an inode
+ * @inode: target inode
+ * @new_wb_id: ID of the new wb
+ *
+ * Switch @inode's wb association to the wb identified by @new_wb_id.  The
+ * switching is performed asynchronously and may fail silently.
+ */
+static void inode_switch_wbs(struct inode *inode, int new_wb_id)
+{
+	struct backing_dev_info *bdi = inode_to_bdi(inode);
+	struct cgroup_subsys_state *memcg_css;
+	struct inode_switch_wbs_context *isw;
+
+	/* noop if seems to be already in progress */
+	if (inode->i_state & I_WB_SWITCH)
+		return;
+
+	isw = kzalloc(sizeof(*isw), GFP_ATOMIC);
+	if (!isw)
+		return;
+
+	/* find and pin the new wb */
+	rcu_read_lock();
+	memcg_css = css_from_id(new_wb_id, &memory_cgrp_subsys);
+	if (memcg_css)
+		isw->new_wb = wb_get_create(bdi, memcg_css, GFP_ATOMIC);
+	rcu_read_unlock();
+	if (!isw->new_wb)
+		goto out_free;
+
+	/* while holding I_WB_SWITCH, no one else can update the association */
+	spin_lock(&inode->i_lock);
+	if (inode->i_state & (I_WB_SWITCH | I_FREEING) ||
+	    inode_to_wb(inode) == isw->new_wb) {
+		spin_unlock(&inode->i_lock);
+		goto out_free;
+	}
+	inode->i_state |= I_WB_SWITCH;
+	spin_unlock(&inode->i_lock);
+
+	ihold(inode);
+	isw->inode = inode;
+
+	/*
+	 * In addition to synchronizing among switchers, I_WB_SWITCH tells
+	 * the RCU protected stat update paths to grab the mapping's
+	 * tree_lock so that stat transfer can synchronize against them.
+	 * Let's continue after I_WB_SWITCH is guaranteed to be visible.
+	 */
+	call_rcu(&isw->rcu_head, inode_switch_wbs_rcu_fn);
+	return;
+
+out_free:
+	if (isw->new_wb)
+		wb_put(isw->new_wb);
+	kfree(isw);
+}
+
 /**
  * wbc_attach_and_unlock_inode - associate wbc with target inode and unlock it
  * @wbc: writeback_control of interest
@@ -433,12 +542,8 @@ void wbc_detach_inode(struct writeback_control *wbc)
 		 * is okay.  The main goal is avoiding keeping an inode on
 		 * the wrong wb for an extended period of time.
 		 */
-		if (hweight32(history) > WB_FRN_HIST_THR_SLOTS) {
-			/* switch */
-			max_id = 0;
-			avg_time = 0;
-			history = 0;
-		}
+		if (hweight32(history) > WB_FRN_HIST_THR_SLOTS)
+			inode_switch_wbs(inode, max_id);
 	}
 
 	/*
diff --git a/include/linux/backing-dev.h b/include/linux/backing-dev.h
index b1d2489..73ffa32 100644
--- a/include/linux/backing-dev.h
+++ b/include/linux/backing-dev.h
@@ -332,6 +332,50 @@ static inline struct bdi_writeback *inode_to_wb(struct inode *inode)
 	return inode->i_wb;
 }
 
+/**
+ * unlocked_inode_to_wb_begin - begin unlocked inode wb access transaction
+ * @inode: target inode
+ * @lockedp: temp bool output param, to be passed to the end function
+ *
+ * The caller wants to access the wb associated with @inode but isn't
+ * holding inode->i_lock, mapping->tree_lock or wb->list_lock.  This
+ * function determines the wb associated with @inode and ensures that the
+ * association doesn't change until the transaction is finished with
+ * unlocked_inode_to_wb_end().
+ *
+ * The caller must call unlocked_inode_to_wb_end() with *@lockdep
+ * afterwards and can't sleep during transaction.  IRQ may or may not be
+ * disabled on return.
+ */
+static inline struct bdi_writeback *
+unlocked_inode_to_wb_begin(struct inode *inode, bool *lockedp)
+{
+	rcu_read_lock();
+
+	/*
+	 * Paired with store_release in inode_switch_wb_work_fn() and
+	 * ensures that we see the new wb if we see cleared I_WB_SWITCH.
+	 */
+	*lockedp = smp_load_acquire(&inode->i_state) & I_WB_SWITCH;
+
+	if (unlikely(*lockedp))
+		spin_lock_irq(&inode->i_mapping->tree_lock);
+	return inode_to_wb(inode);
+}
+
+/**
+ * unlocked_inode_to_wb_end - end inode wb access transaction
+ * @inode: target inode
+ * @locked: *@lockedp from unlocked_inode_to_wb_begin()
+ */
+static inline void unlocked_inode_to_wb_end(struct inode *inode, bool locked)
+{
+	if (unlikely(locked))
+		spin_unlock_irq(&inode->i_mapping->tree_lock);
+
+	rcu_read_unlock();
+}
+
 struct wb_iter {
 	int			start_blkcg_id;
 	struct radix_tree_iter	tree_iter;
@@ -420,6 +464,16 @@ static inline struct bdi_writeback *inode_to_wb(struct inode *inode)
 	return &inode_to_bdi(inode)->wb;
 }
 
+static inline struct bdi_writeback *
+unlocked_inode_to_wb_begin(struct inode *inode, bool *lockedp)
+{
+	return inode_to_wb(inode);
+}
+
+static inline void unlocked_inode_to_wb_end(struct inode *inode, bool locked)
+{
+}
+
 static inline void wb_memcg_offline(struct mem_cgroup *memcg)
 {
 }
diff --git a/include/linux/fs.h b/include/linux/fs.h
index 740126d..b5e1dcf 100644
--- a/include/linux/fs.h
+++ b/include/linux/fs.h
@@ -1815,6 +1815,11 @@ struct super_operations {
  *
  * I_DIO_WAKEUP		Never set.  Only used as a key for wait_on_bit().
  *
+ * I_WB_SWITCH		Cgroup bdi_writeback switching in progress.  Used to
+ *			synchronize competing switching instances and to tell
+ *			wb stat updates to grab mapping->tree_lock.  See
+ *			inode_switch_wb_work_fn() for details.
+ *
  * Q: What is the difference between I_WILL_FREE and I_FREEING?
  */
 #define I_DIRTY_SYNC		(1 << 0)
@@ -1834,6 +1839,7 @@ struct super_operations {
 #define I_DIRTY_TIME		(1 << 11)
 #define __I_DIRTY_TIME_EXPIRED	12
 #define I_DIRTY_TIME_EXPIRED	(1 << __I_DIRTY_TIME_EXPIRED)
+#define I_WB_SWITCH		(1 << 13)
 
 #define I_DIRTY (I_DIRTY_SYNC | I_DIRTY_DATASYNC | I_DIRTY_PAGES)
 #define I_DIRTY_ALL (I_DIRTY | I_DIRTY_TIME)
diff --git a/include/linux/mm.h b/include/linux/mm.h
index f48d979..4024543 100644
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -27,6 +27,7 @@ struct anon_vma_chain;
 struct file_ra_state;
 struct user_struct;
 struct writeback_control;
+struct bdi_writeback;
 
 #ifndef CONFIG_NEED_MULTIPLE_NODES	/* Don't use mapnrs, do it properly */
 extern unsigned long max_mapnr;
@@ -1214,7 +1215,7 @@ int redirty_page_for_writepage(struct writeback_control *wbc,
 void account_page_dirtied(struct page *page, struct address_space *mapping,
 			  struct mem_cgroup *memcg);
 void account_page_cleaned(struct page *page, struct address_space *mapping,
-			  struct mem_cgroup *memcg);
+			  struct mem_cgroup *memcg, struct bdi_writeback *wb);
 int set_page_dirty(struct page *page);
 int set_page_dirty_lock(struct page *page);
 void cancel_dirty_page(struct page *page);
diff --git a/mm/filemap.c b/mm/filemap.c
index 2f065b1..bfc1ab0 100644
--- a/mm/filemap.c
+++ b/mm/filemap.c
@@ -213,7 +213,8 @@ void __delete_from_page_cache(struct page *page, void *shadow,
 	 * anyway will be cleared before returning page into buddy allocator.
 	 */
 	if (WARN_ON_ONCE(PageDirty(page)))
-		account_page_cleaned(page, mapping, memcg);
+		account_page_cleaned(page, mapping, memcg,
+				     inode_to_wb(mapping->host));
 }
 
 /**
diff --git a/mm/page-writeback.c b/mm/page-writeback.c
index e890335..e1514d5 100644
--- a/mm/page-writeback.c
+++ b/mm/page-writeback.c
@@ -2422,12 +2422,12 @@ EXPORT_SYMBOL(account_page_dirtied);
  * Caller must hold mem_cgroup_begin_page_stat().
  */
 void account_page_cleaned(struct page *page, struct address_space *mapping,
-			  struct mem_cgroup *memcg)
+			  struct mem_cgroup *memcg, struct bdi_writeback *wb)
 {
 	if (mapping_cap_account_dirty(mapping)) {
 		mem_cgroup_dec_page_stat(memcg, MEM_CGROUP_STAT_DIRTY);
 		dec_zone_page_state(page, NR_FILE_DIRTY);
-		dec_wb_stat(inode_to_wb(mapping->host), WB_RECLAIMABLE);
+		dec_wb_stat(wb, WB_RECLAIMABLE);
 		task_io_account_cancelled_write(PAGE_CACHE_SIZE);
 	}
 }
@@ -2490,11 +2490,15 @@ void account_page_redirty(struct page *page)
 	struct address_space *mapping = page->mapping;
 
 	if (mapping && mapping_cap_account_dirty(mapping)) {
-		struct bdi_writeback *wb = inode_to_wb(mapping->host);
+		struct inode *inode = mapping->host;
+		struct bdi_writeback *wb;
+		bool locked;
 
+		wb = unlocked_inode_to_wb_begin(inode, &locked);
 		current->nr_dirtied--;
 		dec_zone_page_state(page, NR_DIRTIED);
 		dec_wb_stat(wb, WB_DIRTIED);
+		unlocked_inode_to_wb_end(inode, locked);
 	}
 }
 EXPORT_SYMBOL(account_page_redirty);
@@ -2597,13 +2601,18 @@ void cancel_dirty_page(struct page *page)
 	struct address_space *mapping = page_mapping(page);
 
 	if (mapping_cap_account_dirty(mapping)) {
+		struct inode *inode = mapping->host;
+		struct bdi_writeback *wb;
 		struct mem_cgroup *memcg;
+		bool locked;
 
 		memcg = mem_cgroup_begin_page_stat(page);
+		wb = unlocked_inode_to_wb_begin(inode, &locked);
 
 		if (TestClearPageDirty(page))
-			account_page_cleaned(page, mapping, memcg);
+			account_page_cleaned(page, mapping, memcg, wb);
 
+		unlocked_inode_to_wb_end(inode, locked);
 		mem_cgroup_end_page_stat(memcg);
 	} else {
 		ClearPageDirty(page);
@@ -2628,12 +2637,16 @@ EXPORT_SYMBOL(cancel_dirty_page);
 int clear_page_dirty_for_io(struct page *page)
 {
 	struct address_space *mapping = page_mapping(page);
-	struct mem_cgroup *memcg;
 	int ret = 0;
 
 	BUG_ON(!PageLocked(page));
 
 	if (mapping && mapping_cap_account_dirty(mapping)) {
+		struct inode *inode = mapping->host;
+		struct bdi_writeback *wb;
+		struct mem_cgroup *memcg;
+		bool locked;
+
 		/*
 		 * Yes, Virginia, this is indeed insane.
 		 *
@@ -2670,12 +2683,14 @@ int clear_page_dirty_for_io(struct page *page)
 		 * exclusion.
 		 */
 		memcg = mem_cgroup_begin_page_stat(page);
+		wb = unlocked_inode_to_wb_begin(inode, &locked);
 		if (TestClearPageDirty(page)) {
 			mem_cgroup_dec_page_stat(memcg, MEM_CGROUP_STAT_DIRTY);
 			dec_zone_page_state(page, NR_FILE_DIRTY);
-			dec_wb_stat(inode_to_wb(mapping->host), WB_RECLAIMABLE);
+			dec_wb_stat(wb, WB_RECLAIMABLE);
 			ret = 1;
 		}
+		unlocked_inode_to_wb_end(inode, locked);
 		mem_cgroup_end_page_stat(memcg);
 		return ret;
 	}
-- 
2.4.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
