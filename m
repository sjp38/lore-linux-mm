Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id BA29D6B0003
	for <linux-mm@kvack.org>; Fri,  6 Apr 2018 04:03:44 -0400 (EDT)
Received: by mail-pf0-f200.google.com with SMTP id q11so214932pfd.8
        for <linux-mm@kvack.org>; Fri, 06 Apr 2018 01:03:44 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id e23sor2484389pff.89.2018.04.06.01.03.43
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 06 Apr 2018 01:03:43 -0700 (PDT)
From: Greg Thelen <gthelen@google.com>
Subject: [PATCH] writeback: safer lock nesting
Date: Fri,  6 Apr 2018 01:03:24 -0700
Message-Id: <20180406080324.160306-1-gthelen@google.com>
In-Reply-To: <2cb713cd-0b9b-594c-31db-b4582f8ba822@meituan.com>
References: <2cb713cd-0b9b-594c-31db-b4582f8ba822@meituan.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Wang Long <wanglong19@meituan.com>, Michal Hocko <mhocko@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, Tejun Heo <tj@kernel.org>
Cc: npiggin@gmail.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Greg Thelen <gthelen@google.com>

lock_page_memcg()/unlock_page_memcg() use spin_lock_irqsave/restore() if
the page's memcg is undergoing move accounting, which occurs when a
process leaves its memcg for a new one that has
memory.move_charge_at_immigrate set.

unlocked_inode_to_wb_begin,end() use spin_lock_irq/spin_unlock_irq() if the
given inode is switching writeback domains.  Swithces occur when enough
writes are issued from a new domain.

This existing pattern is thus suspicious:
    lock_page_memcg(page);
    unlocked_inode_to_wb_begin(inode, &locked);
    ...
    unlocked_inode_to_wb_end(inode, locked);
    unlock_page_memcg(page);

If both inode switch and process memcg migration are both in-flight then
unlocked_inode_to_wb_end() will unconditionally enable interrupts while
still holding the lock_page_memcg() irq spinlock.  This suggests the
possibility of deadlock if an interrupt occurs before
unlock_page_memcg().

    truncate
    __cancel_dirty_page
    lock_page_memcg
    unlocked_inode_to_wb_begin
    unlocked_inode_to_wb_end
    <interrupts mistakenly enabled>
                                    <interrupt>
                                    end_page_writeback
                                    test_clear_page_writeback
                                    lock_page_memcg
                                    <deadlock>
    unlock_page_memcg

Due to configuration limitations this deadlock is not currently possible
because we don't mix cgroup writeback (a cgroupv2 feature) and
memory.move_charge_at_immigrate (a cgroupv1 feature).

If the kernel is hacked to always claim inode switching and memcg
moving_account, then this script triggers lockup in less than a minute:
  cd /mnt/cgroup/memory
  mkdir a b
  echo 1 > a/memory.move_charge_at_immigrate
  echo 1 > b/memory.move_charge_at_immigrate
  (
    echo $BASHPID > a/cgroup.procs
    while true; do
      dd if=/dev/zero of=/mnt/big bs=1M count=256
    done
  ) &
  while true; do
    sync
  done &
  sleep 1h &
  SLEEP=$!
  while true; do
    echo $SLEEP > a/cgroup.procs
    echo $SLEEP > b/cgroup.procs
  done

Given the deadlock is not currently possible, it's debatable if there's
any reason to modify the kernel.  I suggest we should to prevent future
surprises.

Reported-by: Wang Long <wanglong19@meituan.com>
Signed-off-by: Greg Thelen <gthelen@google.com>
---
 fs/fs-writeback.c           |  5 +++--
 include/linux/backing-dev.h | 18 ++++++++++++------
 mm/page-writeback.c         | 15 +++++++++------
 3 files changed, 24 insertions(+), 14 deletions(-)

diff --git a/fs/fs-writeback.c b/fs/fs-writeback.c
index d4d04fee568a..d51bae5a53e2 100644
--- a/fs/fs-writeback.c
+++ b/fs/fs-writeback.c
@@ -746,10 +746,11 @@ int inode_congested(struct inode *inode, int cong_bits)
 	if (inode && inode_to_wb_is_valid(inode)) {
 		struct bdi_writeback *wb;
 		bool locked, congested;
+		unsigned long flags;
 
-		wb = unlocked_inode_to_wb_begin(inode, &locked);
+		wb = unlocked_inode_to_wb_begin(inode, &locked, &flags);
 		congested = wb_congested(wb, cong_bits);
-		unlocked_inode_to_wb_end(inode, locked);
+		unlocked_inode_to_wb_end(inode, locked, flags);
 		return congested;
 	}
 
diff --git a/include/linux/backing-dev.h b/include/linux/backing-dev.h
index 3e4ce54d84ab..6c74b64d6f56 100644
--- a/include/linux/backing-dev.h
+++ b/include/linux/backing-dev.h
@@ -347,6 +347,7 @@ static inline struct bdi_writeback *inode_to_wb(const struct inode *inode)
  * unlocked_inode_to_wb_begin - begin unlocked inode wb access transaction
  * @inode: target inode
  * @lockedp: temp bool output param, to be passed to the end function
+ * @flags: saved irq flags, to be passed to the end function
  *
  * The caller wants to access the wb associated with @inode but isn't
  * holding inode->i_lock, mapping->tree_lock or wb->list_lock.  This
@@ -359,7 +360,8 @@ static inline struct bdi_writeback *inode_to_wb(const struct inode *inode)
  * disabled on return.
  */
 static inline struct bdi_writeback *
-unlocked_inode_to_wb_begin(struct inode *inode, bool *lockedp)
+unlocked_inode_to_wb_begin(struct inode *inode, bool *lockedp,
+			   unsigned long *flags)
 {
 	rcu_read_lock();
 
@@ -370,7 +372,7 @@ unlocked_inode_to_wb_begin(struct inode *inode, bool *lockedp)
 	*lockedp = smp_load_acquire(&inode->i_state) & I_WB_SWITCH;
 
 	if (unlikely(*lockedp))
-		spin_lock_irq(&inode->i_mapping->tree_lock);
+		spin_lock_irqsave(&inode->i_mapping->tree_lock, *flags);
 
 	/*
 	 * Protected by either !I_WB_SWITCH + rcu_read_lock() or tree_lock.
@@ -383,11 +385,13 @@ unlocked_inode_to_wb_begin(struct inode *inode, bool *lockedp)
  * unlocked_inode_to_wb_end - end inode wb access transaction
  * @inode: target inode
  * @locked: *@lockedp from unlocked_inode_to_wb_begin()
+ * @flags: *@flags from unlocked_inode_to_wb_begin()
  */
-static inline void unlocked_inode_to_wb_end(struct inode *inode, bool locked)
+static inline void unlocked_inode_to_wb_end(struct inode *inode, bool locked,
+					    unsigned long flags)
 {
 	if (unlikely(locked))
-		spin_unlock_irq(&inode->i_mapping->tree_lock);
+		spin_unlock_irqrestore(&inode->i_mapping->tree_lock, flags);
 
 	rcu_read_unlock();
 }
@@ -434,12 +438,14 @@ static inline struct bdi_writeback *inode_to_wb(struct inode *inode)
 }
 
 static inline struct bdi_writeback *
-unlocked_inode_to_wb_begin(struct inode *inode, bool *lockedp)
+unlocked_inode_to_wb_begin(struct inode *inode, bool *lockedp,
+			   unsigned long *flags)
 {
 	return inode_to_wb(inode);
 }
 
-static inline void unlocked_inode_to_wb_end(struct inode *inode, bool locked)
+static inline void unlocked_inode_to_wb_end(struct inode *inode, bool locked,
+					    unsigned long flags)
 {
 }
 
diff --git a/mm/page-writeback.c b/mm/page-writeback.c
index 586f31261c83..ca786528c74d 100644
--- a/mm/page-writeback.c
+++ b/mm/page-writeback.c
@@ -2501,13 +2501,14 @@ void account_page_redirty(struct page *page)
 	if (mapping && mapping_cap_account_dirty(mapping)) {
 		struct inode *inode = mapping->host;
 		struct bdi_writeback *wb;
+		unsigned long flags;
 		bool locked;
 
-		wb = unlocked_inode_to_wb_begin(inode, &locked);
+		wb = unlocked_inode_to_wb_begin(inode, &locked, &flags);
 		current->nr_dirtied--;
 		dec_node_page_state(page, NR_DIRTIED);
 		dec_wb_stat(wb, WB_DIRTIED);
-		unlocked_inode_to_wb_end(inode, locked);
+		unlocked_inode_to_wb_end(inode, locked, flags);
 	}
 }
 EXPORT_SYMBOL(account_page_redirty);
@@ -2613,15 +2614,16 @@ void __cancel_dirty_page(struct page *page)
 	if (mapping_cap_account_dirty(mapping)) {
 		struct inode *inode = mapping->host;
 		struct bdi_writeback *wb;
+		unsigned long flags;
 		bool locked;
 
 		lock_page_memcg(page);
-		wb = unlocked_inode_to_wb_begin(inode, &locked);
+		wb = unlocked_inode_to_wb_begin(inode, &locked, &flags);
 
 		if (TestClearPageDirty(page))
 			account_page_cleaned(page, mapping, wb);
 
-		unlocked_inode_to_wb_end(inode, locked);
+		unlocked_inode_to_wb_end(inode, locked, flags);
 		unlock_page_memcg(page);
 	} else {
 		ClearPageDirty(page);
@@ -2653,6 +2655,7 @@ int clear_page_dirty_for_io(struct page *page)
 	if (mapping && mapping_cap_account_dirty(mapping)) {
 		struct inode *inode = mapping->host;
 		struct bdi_writeback *wb;
+		unsigned long flags;
 		bool locked;
 
 		/*
@@ -2690,14 +2693,14 @@ int clear_page_dirty_for_io(struct page *page)
 		 * always locked coming in here, so we get the desired
 		 * exclusion.
 		 */
-		wb = unlocked_inode_to_wb_begin(inode, &locked);
+		wb = unlocked_inode_to_wb_begin(inode, &locked, &flags);
 		if (TestClearPageDirty(page)) {
 			dec_lruvec_page_state(page, NR_FILE_DIRTY);
 			dec_zone_page_state(page, NR_ZONE_WRITE_PENDING);
 			dec_wb_stat(wb, WB_RECLAIMABLE);
 			ret = 1;
 		}
-		unlocked_inode_to_wb_end(inode, locked);
+		unlocked_inode_to_wb_end(inode, locked, flags);
 		return ret;
 	}
 	return TestClearPageDirty(page);
-- 
2.17.0.484.g0c8726318c-goog
