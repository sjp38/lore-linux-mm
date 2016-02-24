Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f174.google.com (mail-pf0-f174.google.com [209.85.192.174])
	by kanga.kvack.org (Postfix) with ESMTP id 6B8516B0258
	for <linux-mm@kvack.org>; Wed, 24 Feb 2016 18:35:31 -0500 (EST)
Received: by mail-pf0-f174.google.com with SMTP id e127so21389446pfe.3
        for <linux-mm@kvack.org>; Wed, 24 Feb 2016 15:35:31 -0800 (PST)
Received: from mail-pf0-x22d.google.com (mail-pf0-x22d.google.com. [2607:f8b0:400e:c00::22d])
        by mx.google.com with ESMTPS id y29si7950298pfa.174.2016.02.24.15.35.28
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 24 Feb 2016 15:35:28 -0800 (PST)
Received: by mail-pf0-x22d.google.com with SMTP id e127so21388920pfe.3
        for <linux-mm@kvack.org>; Wed, 24 Feb 2016 15:35:28 -0800 (PST)
From: Kees Cook <keescook@chromium.org>
Subject: [RFC][PATCH v3 2/2] mm/page_poison.c: Allow for zero poisoning
Date: Wed, 24 Feb 2016 15:35:23 -0800
Message-Id: <1456356923-5164-3-git-send-email-keescook@chromium.org>
In-Reply-To: <1456356923-5164-1-git-send-email-keescook@chromium.org>
References: <1456356923-5164-1-git-send-email-keescook@chromium.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Laura Abbott <labbott@fedoraproject.org>
Cc: Kees Cook <keescook@chromium.org>, Andrew Morton <akpm@linux-foundation.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Vlastimil Babka <vbabka@suse.cz>, Michal Hocko <mhocko@suse.com>, Mathias Krause <minipli@googlemail.com>, Dave Hansen <dave.hansen@intel.com>, Jianyu Zhan <nasa4836@gmail.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

From: Laura Abbott <labbott@fedoraproject.org>

By default, page poisoning uses a poison value (0xaa) on free. If this
is changed to 0, the page is not only sanitized but zeroing on alloc
with __GFP_ZERO can be skipped as well. The tradeoff is that detecting
corruption from the poisoning is harder to detect. This feature also
cannot be used with hibernation since pages are not guaranteed to be
zeroed after hibernation.

Credit to Grsecurity/PaX team for inspiring this work

Signed-off-by: Laura Abbott <labbott@fedoraproject.org>
[rebased by Kees Cook <keescook@chromium.org>]
Tested-by: Kees Cook <keescook@chromium.org>
---
 include/linux/mm.h       |  2 ++
 include/linux/poison.h   |  4 ++++
 kernel/power/hibernate.c | 17 +++++++++++++++++
 mm/Kconfig.debug         | 14 ++++++++++++++
 mm/page_alloc.c          | 11 ++++++++++-
 mm/page_ext.c            | 10 ++++++++--
 mm/page_poison.c         |  7 +++++--
 7 files changed, 60 insertions(+), 5 deletions(-)

diff --git a/include/linux/mm.h b/include/linux/mm.h
index 6cdd8d91e5ef..c53e19fd5cfc 100644
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -2201,10 +2201,12 @@ extern int apply_to_page_range(struct mm_struct *mm, unsigned long address,
 #ifdef CONFIG_PAGE_POISONING
 extern bool page_poisoning_enabled(void);
 extern void kernel_poison_pages(struct page *page, int numpages, int enable);
+extern bool page_is_poisoned(struct page *page);
 #else
 static inline bool page_poisoning_enabled(void) { return false; }
 static inline void kernel_poison_pages(struct page *page, int numpages,
 				       int enable) { }
+static inline bool page_is_poisoned(struct page *page) { return false; }
 #endif
 
 #ifdef CONFIG_DEBUG_PAGEALLOC
diff --git a/include/linux/poison.h b/include/linux/poison.h
index 4a27153574e2..51334edec506 100644
--- a/include/linux/poison.h
+++ b/include/linux/poison.h
@@ -30,7 +30,11 @@
 #define TIMER_ENTRY_STATIC	((void *) 0x300 + POISON_POINTER_DELTA)
 
 /********** mm/debug-pagealloc.c **********/
+#ifdef CONFIG_PAGE_POISONING_ZERO
+#define PAGE_POISON 0x00
+#else
 #define PAGE_POISON 0xaa
+#endif
 
 /********** mm/page_alloc.c ************/
 
diff --git a/kernel/power/hibernate.c b/kernel/power/hibernate.c
index b7342a24f559..aa0f26b58426 100644
--- a/kernel/power/hibernate.c
+++ b/kernel/power/hibernate.c
@@ -1158,6 +1158,22 @@ static int __init kaslr_nohibernate_setup(char *str)
 	return nohibernate_setup(str);
 }
 
+static int __init page_poison_nohibernate_setup(char *str)
+{
+#ifdef CONFIG_PAGE_POISONING_ZERO
+	/*
+	 * The zeroing option for page poison skips the checks on alloc.
+	 * since hibernation doesn't save free pages there's no way to
+	 * guarantee the pages will still be zeroed.
+	 */
+	if (!strcmp(str, "on")) {
+		pr_info("Disabling hibernation due to page poisoning\n");
+		return nohibernate_setup(str);
+	}
+#endif
+	return 1;
+}
+
 __setup("noresume", noresume_setup);
 __setup("resume_offset=", resume_offset_setup);
 __setup("resume=", resume_setup);
@@ -1166,3 +1182,4 @@ __setup("resumewait", resumewait_setup);
 __setup("resumedelay=", resumedelay_setup);
 __setup("nohibernate", nohibernate_setup);
 __setup("kaslr", kaslr_nohibernate_setup);
+__setup("page_poison=", page_poison_nohibernate_setup);
diff --git a/mm/Kconfig.debug b/mm/Kconfig.debug
index ddf71d7cb6ba..802c0eb589ab 100644
--- a/mm/Kconfig.debug
+++ b/mm/Kconfig.debug
@@ -62,3 +62,17 @@ config PAGE_POISONING_NO_SANITY
 
 	   If you are only interested in sanitization, say Y. Otherwise
 	   say N.
+
+config PAGE_POISONING_ZERO
+	bool "Use zero for poisoning instead of alternating bits"
+	depends on PAGE_POISONING
+	---help---
+	   Instead of using the existing poison value (0xAA), fill the pages
+	   with zeros. This makes it harder to detect when errors are
+	   occurring due to sanitization but the zeroing at free means that
+	   it is no longer necessary to write zeros when GFP_ZERO is used on
+	   allocation.
+
+	   Enabling page poisoning with this option will disable hibernation
+
+	   If unsure, say N
diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 0bdb3cfd83b5..83de29d16b74 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -1482,15 +1482,24 @@ static inline int check_new_page(struct page *page)
 	return 0;
 }
 
+static inline bool free_pages_prezeroed(bool poisoned)
+{
+	return IS_ENABLED(CONFIG_PAGE_POISONING_ZERO) &&
+		page_poisoning_enabled() && poisoned;
+}
+
 static int prep_new_page(struct page *page, unsigned int order, gfp_t gfp_flags,
 								int alloc_flags)
 {
 	int i;
+	bool poisoned = true;
 
 	for (i = 0; i < (1 << order); i++) {
 		struct page *p = page + i;
 		if (unlikely(check_new_page(p)))
 			return 1;
+		if (poisoned)
+			poisoned &= page_is_poisoned(p);
 	}
 
 	set_page_private(page, 0);
@@ -1501,7 +1510,7 @@ static int prep_new_page(struct page *page, unsigned int order, gfp_t gfp_flags,
 	kernel_poison_pages(page, 1 << order, 1);
 	kasan_alloc_pages(page, order);
 
-	if (gfp_flags & __GFP_ZERO)
+	if (!free_pages_prezeroed(poisoned) && (gfp_flags & __GFP_ZERO))
 		for (i = 0; i < (1 << order); i++)
 			clear_highpage(page + i);
 
diff --git a/mm/page_ext.c b/mm/page_ext.c
index 292ca7b8debd..2d864e64f7fe 100644
--- a/mm/page_ext.c
+++ b/mm/page_ext.c
@@ -106,12 +106,15 @@ struct page_ext *lookup_page_ext(struct page *page)
 	struct page_ext *base;
 
 	base = NODE_DATA(page_to_nid(page))->node_page_ext;
-#ifdef CONFIG_DEBUG_VM
+#if defined(CONFIG_DEBUG_VM) || defined(CONFIG_PAGE_POISONING)
 	/*
 	 * The sanity checks the page allocator does upon freeing a
 	 * page can reach here before the page_ext arrays are
 	 * allocated when feeding a range of pages to the allocator
 	 * for the first time during bootup or memory hotplug.
+	 *
+	 * This check is also necessary for ensuring page poisoning
+	 * works as expected when enabled
 	 */
 	if (unlikely(!base))
 		return NULL;
@@ -180,12 +183,15 @@ struct page_ext *lookup_page_ext(struct page *page)
 {
 	unsigned long pfn = page_to_pfn(page);
 	struct mem_section *section = __pfn_to_section(pfn);
-#ifdef CONFIG_DEBUG_VM
+#if defined(CONFIG_DEBUG_VM) || defined(CONFIG_PAGE_POISONING)
 	/*
 	 * The sanity checks the page allocator does upon freeing a
 	 * page can reach here before the page_ext arrays are
 	 * allocated when feeding a range of pages to the allocator
 	 * for the first time during bootup or memory hotplug.
+	 *
+	 * This check is also necessary for ensuring page poisoning
+	 * works as expected when enabled
 	 */
 	if (!section->page_ext)
 		return NULL;
diff --git a/mm/page_poison.c b/mm/page_poison.c
index 884a6f854432..f52701fe7b6d 100644
--- a/mm/page_poison.c
+++ b/mm/page_poison.c
@@ -63,11 +63,14 @@ static inline void clear_page_poison(struct page *page)
 	__clear_bit(PAGE_EXT_DEBUG_POISON, &page_ext->flags);
 }
 
-static inline bool page_poison(struct page *page)
+bool page_is_poisoned(struct page *page)
 {
 	struct page_ext *page_ext;
 
 	page_ext = lookup_page_ext(page);
+	if (!page_ext)
+		return false;
+
 	return test_bit(PAGE_EXT_DEBUG_POISON, &page_ext->flags);
 }
 
@@ -129,7 +132,7 @@ static void unpoison_page(struct page *page)
 {
 	void *addr;
 
-	if (!page_poison(page))
+	if (!page_is_poisoned(page))
 		return;
 
 	addr = kmap_atomic(page);
-- 
2.6.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
