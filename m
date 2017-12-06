Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f72.google.com (mail-pg0-f72.google.com [74.125.83.72])
	by kanga.kvack.org (Postfix) with ESMTP id AF4D16B02C2
	for <linux-mm@kvack.org>; Tue,  5 Dec 2017 19:43:50 -0500 (EST)
Received: by mail-pg0-f72.google.com with SMTP id i14so1503388pgf.13
        for <linux-mm@kvack.org>; Tue, 05 Dec 2017 16:43:50 -0800 (PST)
Received: from bombadil.infradead.org (bombadil.infradead.org. [65.50.211.133])
        by mx.google.com with ESMTPS id p123si871838pga.747.2017.12.05.16.42.14
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 05 Dec 2017 16:42:14 -0800 (PST)
From: Matthew Wilcox <willy@infradead.org>
Subject: [PATCH v4 57/73] dax: Convert dax_unlock_mapping_entry to XArray
Date: Tue,  5 Dec 2017 16:41:43 -0800
Message-Id: <20171206004159.3755-58-willy@infradead.org>
In-Reply-To: <20171206004159.3755-1-willy@infradead.org>
References: <20171206004159.3755-1-willy@infradead.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
Cc: Matthew Wilcox <mawilcox@microsoft.com>, Ross Zwisler <ross.zwisler@linux.intel.com>, Jens Axboe <axboe@kernel.dk>, Rehas Sachdeva <aquannie@gmail.com>, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, linux-f2fs-devel@lists.sourceforge.net, linux-nilfs@vger.kernel.org, linux-btrfs@vger.kernel.org, linux-xfs@vger.kernel.org, linux-usb@vger.kernel.org, linux-kernel@vger.kernel.org

From: Matthew Wilcox <mawilcox@microsoft.com>

Replace slot_locked() with dax_locked() and inline unlock_slot() into
its only caller.

Signed-off-by: Matthew Wilcox <mawilcox@microsoft.com>
---
 fs/dax.c | 50 ++++++++++++++++----------------------------------
 1 file changed, 16 insertions(+), 34 deletions(-)

diff --git a/fs/dax.c b/fs/dax.c
index 86bacca51eed..03bfa599f75c 100644
--- a/fs/dax.c
+++ b/fs/dax.c
@@ -73,6 +73,11 @@ fs_initcall(init_dax_wait_table);
 #define DAX_ZERO_PAGE	(1UL << 2)
 #define DAX_EMPTY	(1UL << 3)
 
+static bool dax_locked(void *entry)
+{
+	return xa_to_value(entry) & DAX_ENTRY_LOCK;
+}
+
 static unsigned long dax_radix_sector(void *entry)
 {
 	return xa_to_value(entry) >> DAX_SHIFT;
@@ -182,17 +187,6 @@ static void dax_wake_mapping_entry_waiter(struct address_space *mapping,
 		__wake_up(wq, TASK_NORMAL, wake_all ? 0 : 1, &key);
 }
 
-/*
- * Check whether the given slot is locked. The function must be called with
- * mapping xa_lock held
- */
-static inline int slot_locked(struct address_space *mapping, void **slot)
-{
-	unsigned long entry = xa_to_value(
-		radix_tree_deref_slot_protected(slot, &mapping->pages.xa_lock));
-	return entry & DAX_ENTRY_LOCK;
-}
-
 /*
  * Mark the given slot is locked. The function must be called with
  * mapping xa_lock held
@@ -206,19 +200,6 @@ static inline void *lock_slot(struct address_space *mapping, void **slot)
 	return entry;
 }
 
-/*
- * Mark the given slot is unlocked. The function must be called with
- * mapping xa_lock held
- */
-static inline void *unlock_slot(struct address_space *mapping, void **slot)
-{
-	unsigned long v = xa_to_value(
-		radix_tree_deref_slot_protected(slot, &mapping->pages.xa_lock));
-	void *entry = xa_mk_value(v & ~DAX_ENTRY_LOCK);
-	radix_tree_replace_slot(&mapping->pages, slot, entry);
-	return entry;
-}
-
 /*
  * Lookup entry in radix tree, wait for it to become unlocked if it is
  * a data value entry and return it. The caller must call
@@ -242,8 +223,7 @@ static void *get_unlocked_mapping_entry(struct address_space *mapping,
 		entry = __radix_tree_lookup(&mapping->pages, index, NULL,
 					  &slot);
 		if (!entry ||
-		    WARN_ON_ONCE(!xa_is_value(entry)) ||
-		    !slot_locked(mapping, slot)) {
+		    WARN_ON_ONCE(!xa_is_value(entry)) || !dax_locked(entry)) {
 			if (slotp)
 				*slotp = slot;
 			return entry;
@@ -262,17 +242,19 @@ static void *get_unlocked_mapping_entry(struct address_space *mapping,
 static void dax_unlock_mapping_entry(struct address_space *mapping,
 				     pgoff_t index)
 {
-	void *entry, **slot;
+	XA_STATE(xas, &mapping->pages, index);
+	void *entry;
 
-	xa_lock_irq(&mapping->pages);
-	entry = __radix_tree_lookup(&mapping->pages, index, NULL, &slot);
-	if (WARN_ON_ONCE(!entry || !xa_is_value(entry) ||
-			 !slot_locked(mapping, slot))) {
-		xa_unlock_irq(&mapping->pages);
+	xas_lock_irq(&xas);
+	entry = xas_load(&xas);
+	if (WARN_ON_ONCE(!entry || !xa_is_value(entry) || !dax_locked(entry))) {
+		xas_unlock_irq(&xas);
 		return;
 	}
-	unlock_slot(mapping, slot);
-	xa_unlock_irq(&mapping->pages);
+	entry = xa_mk_value(xa_to_value(entry) & ~DAX_ENTRY_LOCK);
+	xas_store(&xas, entry);
+	/* Safe to not call xas_pause here -- we don't touch the array after */
+	xas_unlock_irq(&xas);
 	dax_wake_mapping_entry_waiter(mapping, index, entry, false);
 }
 
-- 
2.15.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
