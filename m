Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ob0-f182.google.com (mail-ob0-f182.google.com [209.85.214.182])
	by kanga.kvack.org (Postfix) with ESMTP id 8E052900016
	for <linux-mm@kvack.org>; Tue,  2 Jun 2015 18:09:02 -0400 (EDT)
Received: by obcnx10 with SMTP id nx10so133546819obc.2
        for <linux-mm@kvack.org>; Tue, 02 Jun 2015 15:09:02 -0700 (PDT)
Received: from mail-oi0-x231.google.com (mail-oi0-x231.google.com. [2607:f8b0:4003:c06::231])
        by mx.google.com with ESMTPS id os7si2295974obc.73.2015.06.02.15.09.01
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 02 Jun 2015 15:09:01 -0700 (PDT)
Received: by oifu123 with SMTP id u123so136823362oif.1
        for <linux-mm@kvack.org>; Tue, 02 Jun 2015 15:09:01 -0700 (PDT)
From: Dan Streetman <ddstreet@ieee.org>
Subject: [PATCHv3] frontswap: allow multiple backends
Date: Tue,  2 Jun 2015 18:08:46 -0400
Message-Id: <1433282926-15100-1-git-send-email-ddstreet@ieee.org>
In-Reply-To: <1433168544-26301-1-git-send-email-ddstreet@ieee.org>
References: <1433168544-26301-1-git-send-email-ddstreet@ieee.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, Boris Ostrovsky <boris.ostrovsky@oracle.com>, David Vrabel <david.vrabel@citrix.com>, xen-devel@lists.xenproject.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Dan Streetman <ddstreet@ieee.org>

Change frontswap single pointer to a singly linked list of frontswap
implementations.  Update Xen tmem implementation as register no longer
returns anything.

Frontswap only keeps track of a single implementation; any implementation
that registers second (or later) will replace the previously registered
implementation, and gets a pointer to the previous implementation that
the new implementation is expected to pass all frontswap functions to
if it can't handle the function itself.  However that method doesn't
really make much sense, as passing that work on to every implementation
adds unnecessary work to implementations; instead, frontswap should
simply keep a list of all registered implementations and try each
implementation for any function.  Most importantly, neither of the
two currently existing frontswap implementations in the kernel actually
do anything with any previous frontswap implementation that they
replace when registering.

This allows frontswap to successfully manage multiple implementations
by keeping a list of them all.

Signed-off-by: Dan Streetman <ddstreet@ieee.org>
---
Changes since v2: 
  -initialize bitmaps in frontswap_register_ops
  -fix comment capitalization

 drivers/xen/tmem.c        |   8 +-
 include/linux/frontswap.h |  14 +--
 mm/frontswap.c            | 215 ++++++++++++++++++++++++++++------------------
 3 files changed, 139 insertions(+), 98 deletions(-)

diff --git a/drivers/xen/tmem.c b/drivers/xen/tmem.c
index c4211a3..d88f367 100644
--- a/drivers/xen/tmem.c
+++ b/drivers/xen/tmem.c
@@ -381,15 +381,9 @@ static int __init xen_tmem_init(void)
 #ifdef CONFIG_FRONTSWAP
 	if (tmem_enabled && frontswap) {
 		char *s = "";
-		struct frontswap_ops *old_ops;
 
 		tmem_frontswap_poolid = -1;
-		old_ops = frontswap_register_ops(&tmem_frontswap_ops);
-		if (IS_ERR(old_ops) || old_ops) {
-			if (IS_ERR(old_ops))
-				return PTR_ERR(old_ops);
-			s = " (WARNING: frontswap_ops overridden)";
-		}
+		frontswap_register_ops(&tmem_frontswap_ops);
 		pr_info("frontswap enabled, RAM provided by Xen Transcendent Memory%s\n",
 			s);
 	}
diff --git a/include/linux/frontswap.h b/include/linux/frontswap.h
index 8293262..e65ef95 100644
--- a/include/linux/frontswap.h
+++ b/include/linux/frontswap.h
@@ -6,16 +6,16 @@
 #include <linux/bitops.h>
 
 struct frontswap_ops {
-	void (*init)(unsigned);
-	int (*store)(unsigned, pgoff_t, struct page *);
-	int (*load)(unsigned, pgoff_t, struct page *);
-	void (*invalidate_page)(unsigned, pgoff_t);
-	void (*invalidate_area)(unsigned);
+	void (*init)(unsigned); /* this swap type was just swapon'ed */
+	int (*store)(unsigned, pgoff_t, struct page *); /* store a page */
+	int (*load)(unsigned, pgoff_t, struct page *); /* load a page */
+	void (*invalidate_page)(unsigned, pgoff_t); /* page no longer needed */
+	void (*invalidate_area)(unsigned); /* swap type just swapoff'ed */
+	struct frontswap_ops *next; /* private pointer to next ops */
 };
 
 extern bool frontswap_enabled;
-extern struct frontswap_ops *
-	frontswap_register_ops(struct frontswap_ops *ops);
+extern void frontswap_register_ops(struct frontswap_ops *ops);
 extern void frontswap_shrink(unsigned long);
 extern unsigned long frontswap_curr_pages(void);
 extern void frontswap_writethrough(bool);
diff --git a/mm/frontswap.c b/mm/frontswap.c
index 8d82809..27a9924 100644
--- a/mm/frontswap.c
+++ b/mm/frontswap.c
@@ -21,11 +21,16 @@
 #include <linux/swapfile.h>
 
 /*
- * frontswap_ops is set by frontswap_register_ops to contain the pointers
- * to the frontswap "backend" implementation functions.
+ * frontswap_ops are added by frontswap_register_ops, and provide the
+ * frontswap "backend" implementation functions.  Multiple implementations
+ * may be registered, but implementations can never deregister.  This
+ * is a simple singly-linked list of all registered implementations.
  */
 static struct frontswap_ops *frontswap_ops __read_mostly;
 
+#define for_each_frontswap_ops(ops)		\
+	for ((ops) = frontswap_ops; (ops); (ops) = (ops)->next)
+
 /*
  * If enabled, frontswap_store will return failure even on success.  As
  * a result, the swap subsystem will always write the page to swap, in
@@ -79,15 +84,6 @@ static inline void inc_frontswap_invalidates(void) { }
  * on all frontswap functions to not call the backend until the backend
  * has registered.
  *
- * Specifically when no backend is registered (nobody called
- * frontswap_register_ops) all calls to frontswap_init (which is done via
- * swapon -> enable_swap_info -> frontswap_init) are registered and remembered
- * (via the setting of need_init bitmap) but fail to create tmem_pools. When a
- * backend registers with frontswap at some later point the previous
- * calls to frontswap_init are executed (by iterating over the need_init
- * bitmap) to create tmem_pools and set the respective poolids. All of that is
- * guarded by us using atomic bit operations on the 'need_init' bitmap.
- *
  * This would not guards us against the user deciding to call swapoff right as
  * we are calling the backend to initialize (so swapon is in action).
  * Fortunatly for us, the swapon_mutex has been taked by the callee so we are
@@ -106,37 +102,64 @@ static inline void inc_frontswap_invalidates(void) { }
  *
  * Obviously the opposite (unloading the backend) must be done after all
  * the frontswap_[store|load|invalidate_area|invalidate_page] start
- * ignorning or failing the requests - at which point frontswap_ops
- * would have to be made in some fashion atomic.
+ * ignoring or failing the requests.  However, there is currently no way
+ * to unload a backend once it is registered.
  */
-static DECLARE_BITMAP(need_init, MAX_SWAPFILES);
 
 /*
- * Register operations for frontswap, returning previous thus allowing
- * detection of multiple backends and possible nesting.
+ * Register operations for frontswap
  */
-struct frontswap_ops *frontswap_register_ops(struct frontswap_ops *ops)
+void frontswap_register_ops(struct frontswap_ops *ops)
 {
-	struct frontswap_ops *old = frontswap_ops;
-	int i;
-
-	for (i = 0; i < MAX_SWAPFILES; i++) {
-		if (test_and_clear_bit(i, need_init)) {
-			struct swap_info_struct *sis = swap_info[i];
-			/* __frontswap_init _should_ have set it! */
-			if (!sis->frontswap_map)
-				return ERR_PTR(-EINVAL);
-			ops->init(i);
-		}
+	DECLARE_BITMAP(a, MAX_SWAPFILES);
+	DECLARE_BITMAP(b, MAX_SWAPFILES);
+	struct swap_info_struct *si;
+	unsigned int i;
+
+	bitmap_zero(a, MAX_SWAPFILES);
+	bitmap_zero(b, MAX_SWAPFILES);
+
+	spin_lock(&swap_lock);
+	plist_for_each_entry(si, &swap_active_head, list) {
+		if (!WARN_ON(!si->frontswap_map))
+			set_bit(si->type, a);
 	}
+	spin_unlock(&swap_lock);
+
+	/* the new ops needs to know the currently active swap devices */
+	for_each_set_bit(i, a, MAX_SWAPFILES)
+		ops->init(i);
+
 	/*
-	 * We MUST have frontswap_ops set _after_ the frontswap_init's
-	 * have been called. Otherwise __frontswap_store might fail. Hence
-	 * the barrier to make sure compiler does not re-order us.
+	 * Setting frontswap_ops must happen after the ops->init() calls
+	 * above; cmpxchg implies smp_mb() which will ensure the init is
+	 * complete at this point.
 	 */
-	barrier();
-	frontswap_ops = ops;
-	return old;
+	do {
+		ops->next = frontswap_ops;
+	} while (cmpxchg(&frontswap_ops, ops->next, ops) != ops->next);
+
+	spin_lock(&swap_lock);
+	plist_for_each_entry(si, &swap_active_head, list) {
+		if (si->frontswap_map)
+			set_bit(si->type, b);
+	}
+	spin_unlock(&swap_lock);
+
+	/*
+	 * On the very unlikely chance that a swap device was added or
+	 * removed between setting the "a" list bits and the ops init
+	 * calls, we re-check and do init or invalidate for any changed
+	 * bits.
+	 */
+	if (unlikely(!bitmap_equal(a, b, MAX_SWAPFILES))) {
+		for (i = 0; i < MAX_SWAPFILES; i++) {
+			if (!test_bit(i, a) && test_bit(i, b))
+				ops->init(i);
+			else if (test_bit(i, a) && !test_bit(i, b))
+				ops->invalidate_area(i);
+		}
+	}
 }
 EXPORT_SYMBOL(frontswap_register_ops);
 
@@ -164,6 +187,7 @@ EXPORT_SYMBOL(frontswap_tmem_exclusive_gets);
 void __frontswap_init(unsigned type, unsigned long *map)
 {
 	struct swap_info_struct *sis = swap_info[type];
+	struct frontswap_ops *ops;
 
 	BUG_ON(sis == NULL);
 
@@ -179,28 +203,30 @@ void __frontswap_init(unsigned type, unsigned long *map)
 	 * p->frontswap set to something valid to work properly.
 	 */
 	frontswap_map_set(sis, map);
-	if (frontswap_ops)
-		frontswap_ops->init(type);
-	else {
-		BUG_ON(type >= MAX_SWAPFILES);
-		set_bit(type, need_init);
-	}
+
+	for_each_frontswap_ops(ops)
+		ops->init(type);
 }
 EXPORT_SYMBOL(__frontswap_init);
 
 bool __frontswap_test(struct swap_info_struct *sis,
 				pgoff_t offset)
 {
-	bool ret = false;
-
-	if (frontswap_ops && sis->frontswap_map)
-		ret = test_bit(offset, sis->frontswap_map);
-	return ret;
+	if (sis->frontswap_map)
+		return test_bit(offset, sis->frontswap_map);
+	return false;
 }
 EXPORT_SYMBOL(__frontswap_test);
 
+static inline void __frontswap_set(struct swap_info_struct *sis,
+				   pgoff_t offset)
+{
+	set_bit(offset, sis->frontswap_map);
+	atomic_inc(&sis->frontswap_pages);
+}
+
 static inline void __frontswap_clear(struct swap_info_struct *sis,
-				pgoff_t offset)
+				     pgoff_t offset)
 {
 	clear_bit(offset, sis->frontswap_map);
 	atomic_dec(&sis->frontswap_pages);
@@ -215,39 +241,46 @@ static inline void __frontswap_clear(struct swap_info_struct *sis,
  */
 int __frontswap_store(struct page *page)
 {
-	int ret = -1, dup = 0;
+	int ret = -1;
 	swp_entry_t entry = { .val = page_private(page), };
 	int type = swp_type(entry);
 	struct swap_info_struct *sis = swap_info[type];
 	pgoff_t offset = swp_offset(entry);
+	struct frontswap_ops *ops;
 
 	/*
 	 * Return if no backend registed.
 	 * Don't need to inc frontswap_failed_stores here.
 	 */
 	if (!frontswap_ops)
-		return ret;
+		return -1;
 
 	BUG_ON(!PageLocked(page));
 	BUG_ON(sis == NULL);
-	if (__frontswap_test(sis, offset))
-		dup = 1;
-	ret = frontswap_ops->store(type, offset, page);
+
+	/*
+	 * If a dup, we must remove the old page first; we can't leave the
+	 * old page no matter if the store of the new page succeeds or fails,
+	 * and we can't rely on the new page replacing the old page as we may
+	 * not store to the same implementation that contains the old page.
+	 */
+	if (__frontswap_test(sis, offset)) {
+		__frontswap_clear(sis, offset);
+		for_each_frontswap_ops(ops)
+			ops->invalidate_page(type, offset);
+	}
+
+	/* Try to store in each implementation, until one succeeds. */
+	for_each_frontswap_ops(ops) {
+		ret = ops->store(type, offset, page);
+		if (!ret) /* successful store */
+			break;
+	}
 	if (ret == 0) {
-		set_bit(offset, sis->frontswap_map);
+		__frontswap_set(sis, offset);
 		inc_frontswap_succ_stores();
-		if (!dup)
-			atomic_inc(&sis->frontswap_pages);
 	} else {
-		/*
-		  failed dup always results in automatic invalidate of
-		  the (older) page from frontswap
-		 */
 		inc_frontswap_failed_stores();
-		if (dup) {
-			__frontswap_clear(sis, offset);
-			frontswap_ops->invalidate_page(type, offset);
-		}
 	}
 	if (frontswap_writethrough_enabled)
 		/* report failure so swap also writes to swap device */
@@ -268,14 +301,22 @@ int __frontswap_load(struct page *page)
 	int type = swp_type(entry);
 	struct swap_info_struct *sis = swap_info[type];
 	pgoff_t offset = swp_offset(entry);
+	struct frontswap_ops *ops;
+
+	if (!frontswap_ops)
+		return -1;
 
 	BUG_ON(!PageLocked(page));
 	BUG_ON(sis == NULL);
-	/*
-	 * __frontswap_test() will check whether there is backend registered
-	 */
-	if (__frontswap_test(sis, offset))
-		ret = frontswap_ops->load(type, offset, page);
+	if (!__frontswap_test(sis, offset))
+		return -1;
+
+	/* Try loading from each implementation, until one succeeds. */
+	for_each_frontswap_ops(ops) {
+		ret = ops->load(type, offset, page);
+		if (!ret) /* successful load */
+			break;
+	}
 	if (ret == 0) {
 		inc_frontswap_loads();
 		if (frontswap_tmem_exclusive_gets_enabled) {
@@ -294,16 +335,19 @@ EXPORT_SYMBOL(__frontswap_load);
 void __frontswap_invalidate_page(unsigned type, pgoff_t offset)
 {
 	struct swap_info_struct *sis = swap_info[type];
+	struct frontswap_ops *ops;
+
+	if (!frontswap_ops)
+		return;
 
 	BUG_ON(sis == NULL);
-	/*
-	 * __frontswap_test() will check whether there is backend registered
-	 */
-	if (__frontswap_test(sis, offset)) {
-		frontswap_ops->invalidate_page(type, offset);
-		__frontswap_clear(sis, offset);
-		inc_frontswap_invalidates();
-	}
+	if (!__frontswap_test(sis, offset))
+		return;
+
+	for_each_frontswap_ops(ops)
+		ops->invalidate_page(type, offset);
+	__frontswap_clear(sis, offset);
+	inc_frontswap_invalidates();
 }
 EXPORT_SYMBOL(__frontswap_invalidate_page);
 
@@ -314,16 +358,19 @@ EXPORT_SYMBOL(__frontswap_invalidate_page);
 void __frontswap_invalidate_area(unsigned type)
 {
 	struct swap_info_struct *sis = swap_info[type];
+	struct frontswap_ops *ops;
 
-	if (frontswap_ops) {
-		BUG_ON(sis == NULL);
-		if (sis->frontswap_map == NULL)
-			return;
-		frontswap_ops->invalidate_area(type);
-		atomic_set(&sis->frontswap_pages, 0);
-		bitmap_zero(sis->frontswap_map, sis->max);
-	}
-	clear_bit(type, need_init);
+	if (!frontswap_ops)
+		return;
+
+	BUG_ON(sis == NULL);
+	if (sis->frontswap_map == NULL)
+		return;
+
+	for_each_frontswap_ops(ops)
+		ops->invalidate_area(type);
+	atomic_set(&sis->frontswap_pages, 0);
+	bitmap_zero(sis->frontswap_map, sis->max);
 }
 EXPORT_SYMBOL(__frontswap_invalidate_area);
 
-- 
2.1.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
