Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lb0-f197.google.com (mail-lb0-f197.google.com [209.85.217.197])
	by kanga.kvack.org (Postfix) with ESMTP id 0C9B66B0005
	for <linux-mm@kvack.org>; Fri, 13 May 2016 11:10:50 -0400 (EDT)
Received: by mail-lb0-f197.google.com with SMTP id ne4so30312636lbc.1
        for <linux-mm@kvack.org>; Fri, 13 May 2016 08:10:49 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id bb7si22645172wjc.82.2016.05.13.08.10.48
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Fri, 13 May 2016 08:10:48 -0700 (PDT)
From: Vlastimil Babka <vbabka@suse.cz>
Subject: [PATCH] mm, frontswap: convert frontswap_enabled to static key
Date: Fri, 13 May 2016 17:10:35 +0200
Message-Id: <1463152235-9717-1-git-send-email-vbabka@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, Andrew Morton <akpm@linux-foundation.org>
Cc: Boris Ostrovsky <boris.ostrovsky@oracle.com>, David Vrabel <david.vrabel@citrix.com>, Juergen Gross <jgross@suse.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, xen-devel@lists.xenproject.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Vlastimil Babka <vbabka@suse.cz>

I have noticed that frontswap.h first declares "frontswap_enabled" as extern
bool variable, and then overrides it with "#define frontswap_enabled (1)" for
CONFIG_FRONTSWAP=Y or (0) when disabled. The bool variable isn't actually
instantiated anywhere.

This all looks like an unfinished attempt to make frontswap_enabled reflect
whether a backend is instantiated. But in the current state, all frontswap
hooks call unconditionally into frontswap.c just to check if frontswap_ops is
non-NULL. This should at least be checked inline, but we can further eliminate
the overhead when CONFIG_FRONTSWAP is enabled and no backend registered, using
a static key that is initially disabled, and gets enabled only upon first
backend registration.

Thus, checks for "frontswap_enabled" are replaced with "frontswap_enabled()"
wrapping the static key check. There are two exceptions:

- xen's selfballoon_process() was testing frontswap_enabled in code guarded
  by #ifdef CONFIG_FRONTSWAP, which was effectively always true when reachable.
  The patch just removes this check. Using frontswap_enabled() does not sound
  correct here, as this can be true even without xen's own backend being
  registered.

- in SYSCALL_DEFINE2(swapon), change the check to IS_ENABLED(CONFIG_FRONTSWAP)
  as it seems the bitmap allocation cannot currently be postponed until a
  backend is registered. This means that frontswap will still have some
  memory overhead by being configured, but without a backend.

After the patch, we can expect that some functions in frontswap.c are called
only when frontswap_ops is non-NULL. Change the checks there to VM_BUG_ONs.
While at it, convert other BUG_ONs to VM_BUG_ONs as frontswap has been stable
for some time.

Signed-off-by: Vlastimil Babka <vbabka@suse.cz>
---
 drivers/xen/xen-selfballoon.c |  4 ++--
 include/linux/frontswap.h     | 34 ++++++++++++++++++++--------------
 mm/frontswap.c                | 35 +++++++++++++++--------------------
 mm/swapfile.c                 |  2 +-
 4 files changed, 38 insertions(+), 37 deletions(-)

diff --git a/drivers/xen/xen-selfballoon.c b/drivers/xen/xen-selfballoon.c
index 53a085fca00c..66620713242a 100644
--- a/drivers/xen/xen-selfballoon.c
+++ b/drivers/xen/xen-selfballoon.c
@@ -195,7 +195,7 @@ static void selfballoon_process(struct work_struct *work)
 				MB2PAGES(selfballoon_reserved_mb);
 #ifdef CONFIG_FRONTSWAP
 		/* allow space for frontswap pages to be repatriated */
-		if (frontswap_selfshrinking && frontswap_enabled)
+		if (frontswap_selfshrinking)
 			goal_pages += frontswap_curr_pages();
 #endif
 		if (cur_pages > goal_pages)
@@ -230,7 +230,7 @@ static void selfballoon_process(struct work_struct *work)
 		reset_timer = true;
 	}
 #ifdef CONFIG_FRONTSWAP
-	if (frontswap_selfshrinking && frontswap_enabled) {
+	if (frontswap_selfshrinking) {
 		frontswap_selfshrink();
 		reset_timer = true;
 	}
diff --git a/include/linux/frontswap.h b/include/linux/frontswap.h
index e65ef959546c..c46d2aa16d81 100644
--- a/include/linux/frontswap.h
+++ b/include/linux/frontswap.h
@@ -4,6 +4,7 @@
 #include <linux/swap.h>
 #include <linux/mm.h>
 #include <linux/bitops.h>
+#include <linux/jump_label.h>
 
 struct frontswap_ops {
 	void (*init)(unsigned); /* this swap type was just swapon'ed */
@@ -14,7 +15,6 @@ struct frontswap_ops {
 	struct frontswap_ops *next; /* private pointer to next ops */
 };
 
-extern bool frontswap_enabled;
 extern void frontswap_register_ops(struct frontswap_ops *ops);
 extern void frontswap_shrink(unsigned long);
 extern unsigned long frontswap_curr_pages(void);
@@ -30,7 +30,12 @@ extern void __frontswap_invalidate_page(unsigned, pgoff_t);
 extern void __frontswap_invalidate_area(unsigned);
 
 #ifdef CONFIG_FRONTSWAP
-#define frontswap_enabled (1)
+extern struct static_key_false frontswap_enabled_key;
+
+static inline bool frontswap_enabled(void)
+{
+	return static_branch_unlikely(&frontswap_enabled_key);
+}
 
 static inline bool frontswap_test(struct swap_info_struct *sis, pgoff_t offset)
 {
@@ -50,7 +55,10 @@ static inline unsigned long *frontswap_map_get(struct swap_info_struct *p)
 #else
 /* all inline routines become no-ops and all externs are ignored */
 
-#define frontswap_enabled (0)
+static inline bool frontswap_enabled(void)
+{
+	return false;
+}
 
 static inline bool frontswap_test(struct swap_info_struct *sis, pgoff_t offset)
 {
@@ -70,37 +78,35 @@ static inline unsigned long *frontswap_map_get(struct swap_info_struct *p)
 
 static inline int frontswap_store(struct page *page)
 {
-	int ret = -1;
+	if (frontswap_enabled())
+		return __frontswap_store(page);
 
-	if (frontswap_enabled)
-		ret = __frontswap_store(page);
-	return ret;
+	return -1;
 }
 
 static inline int frontswap_load(struct page *page)
 {
-	int ret = -1;
+	if (frontswap_enabled())
+		return __frontswap_load(page);
 
-	if (frontswap_enabled)
-		ret = __frontswap_load(page);
-	return ret;
+	return -1;
 }
 
 static inline void frontswap_invalidate_page(unsigned type, pgoff_t offset)
 {
-	if (frontswap_enabled)
+	if (frontswap_enabled())
 		__frontswap_invalidate_page(type, offset);
 }
 
 static inline void frontswap_invalidate_area(unsigned type)
 {
-	if (frontswap_enabled)
+	if (frontswap_enabled())
 		__frontswap_invalidate_area(type);
 }
 
 static inline void frontswap_init(unsigned type, unsigned long *map)
 {
-	if (frontswap_enabled)
+	if (frontswap_enabled())
 		__frontswap_init(type, map);
 }
 
diff --git a/mm/frontswap.c b/mm/frontswap.c
index 27a9924caf61..f3294d7ba682 100644
--- a/mm/frontswap.c
+++ b/mm/frontswap.c
@@ -20,6 +20,8 @@
 #include <linux/frontswap.h>
 #include <linux/swapfile.h>
 
+DEFINE_STATIC_KEY_FALSE(frontswap_enabled_key);
+
 /*
  * frontswap_ops are added by frontswap_register_ops, and provide the
  * frontswap "backend" implementation functions.  Multiple implementations
@@ -139,6 +141,8 @@ void frontswap_register_ops(struct frontswap_ops *ops)
 		ops->next = frontswap_ops;
 	} while (cmpxchg(&frontswap_ops, ops->next, ops) != ops->next);
 
+	static_branch_inc(&frontswap_enabled_key);
+
 	spin_lock(&swap_lock);
 	plist_for_each_entry(si, &swap_active_head, list) {
 		if (si->frontswap_map)
@@ -189,7 +193,7 @@ void __frontswap_init(unsigned type, unsigned long *map)
 	struct swap_info_struct *sis = swap_info[type];
 	struct frontswap_ops *ops;
 
-	BUG_ON(sis == NULL);
+	VM_BUG_ON(sis == NULL);
 
 	/*
 	 * p->frontswap is a bitmap that we MUST have to figure out which page
@@ -248,15 +252,9 @@ int __frontswap_store(struct page *page)
 	pgoff_t offset = swp_offset(entry);
 	struct frontswap_ops *ops;
 
-	/*
-	 * Return if no backend registed.
-	 * Don't need to inc frontswap_failed_stores here.
-	 */
-	if (!frontswap_ops)
-		return -1;
-
-	BUG_ON(!PageLocked(page));
-	BUG_ON(sis == NULL);
+	VM_BUG_ON (!frontswap_ops);
+	VM_BUG_ON(!PageLocked(page));
+	VM_BUG_ON(sis == NULL);
 
 	/*
 	 * If a dup, we must remove the old page first; we can't leave the
@@ -303,11 +301,10 @@ int __frontswap_load(struct page *page)
 	pgoff_t offset = swp_offset(entry);
 	struct frontswap_ops *ops;
 
-	if (!frontswap_ops)
-		return -1;
+	VM_BUG_ON(!frontswap_ops);
+	VM_BUG_ON(!PageLocked(page));
+	VM_BUG_ON(sis == NULL);
 
-	BUG_ON(!PageLocked(page));
-	BUG_ON(sis == NULL);
 	if (!__frontswap_test(sis, offset))
 		return -1;
 
@@ -337,10 +334,9 @@ void __frontswap_invalidate_page(unsigned type, pgoff_t offset)
 	struct swap_info_struct *sis = swap_info[type];
 	struct frontswap_ops *ops;
 
-	if (!frontswap_ops)
-		return;
+	VM_BUG_ON(!frontswap_ops);
+	VM_BUG_ON(sis == NULL);
 
-	BUG_ON(sis == NULL);
 	if (!__frontswap_test(sis, offset))
 		return;
 
@@ -360,10 +356,9 @@ void __frontswap_invalidate_area(unsigned type)
 	struct swap_info_struct *sis = swap_info[type];
 	struct frontswap_ops *ops;
 
-	if (!frontswap_ops)
-		return;
+	VM_BUG_ON(!frontswap_ops);
+	VM_BUG_ON(sis == NULL);
 
-	BUG_ON(sis == NULL);
 	if (sis->frontswap_map == NULL)
 		return;
 
diff --git a/mm/swapfile.c b/mm/swapfile.c
index 031713ab40ce..78cfa292a29a 100644
--- a/mm/swapfile.c
+++ b/mm/swapfile.c
@@ -2493,7 +2493,7 @@ SYSCALL_DEFINE2(swapon, const char __user *, specialfile, int, swap_flags)
 		goto bad_swap;
 	}
 	/* frontswap enabled? set up bit-per-page map for frontswap */
-	if (frontswap_enabled)
+	if (IS_ENABLED(CONFIG_FRONTSWAP))
 		frontswap_map = vzalloc(BITS_TO_LONGS(maxpages) * sizeof(long));
 
 	if (p->bdev &&(swap_flags & SWAP_FLAG_DISCARD) && swap_discardable(p)) {
-- 
2.8.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
