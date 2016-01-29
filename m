Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qg0-f45.google.com (mail-qg0-f45.google.com [209.85.192.45])
	by kanga.kvack.org (Postfix) with ESMTP id A24866B0259
	for <linux-mm@kvack.org>; Thu, 28 Jan 2016 21:38:26 -0500 (EST)
Received: by mail-qg0-f45.google.com with SMTP id o11so55593696qge.2
        for <linux-mm@kvack.org>; Thu, 28 Jan 2016 18:38:26 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id a78si15379183qgf.66.2016.01.28.18.38.25
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 28 Jan 2016 18:38:25 -0800 (PST)
From: Laura Abbott <labbott@fedoraproject.org>
Subject: [PATCHv2 1/2] mm/page_poison.c: Enable PAGE_POISONING as a separate option
Date: Thu, 28 Jan 2016 18:38:18 -0800
Message-Id: <1454035099-31583-2-git-send-email-labbott@fedoraproject.org>
In-Reply-To: <1454035099-31583-1-git-send-email-labbott@fedoraproject.org>
References: <1454035099-31583-1-git-send-email-labbott@fedoraproject.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Vlastimil Babka <vbabka@suse.cz>, Michal Hocko <mhocko@suse.com>
Cc: Laura Abbott <labbott@fedoraproject.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, kernel-hardening@lists.openwall.com, Kees Cook <keescook@chromium.org>

Page poisoning is currently setup as a feature if architectures don't
have architecture debug page_alloc to allow unmapping of pages. It has
uses apart from that though. Clearing of the pages on free provides
an increase in security as it helps to limit the risk of information
leaks. Allow page poisoning to be enabled as a separate option
independent of any other debug feature. Because of how hiberanation
is implemented, the checks on alloc cannot occur if hibernation is
enabled. This option can also be set on !HIBERNATION as well.

Credit to Grsecurity/PaX team for inspiring this work

Signed-off-by: Laura Abbott <labbott@fedoraproject.org>
---
 Documentation/kernel-parameters.txt |   5 ++
 include/linux/mm.h                  |   9 ++
 mm/Kconfig.debug                    |  22 ++++-
 mm/Makefile                         |   2 +-
 mm/debug-pagealloc.c                | 137 ----------------------------
 mm/page_alloc.c                     |   2 +
 mm/page_poison.c                    | 173 ++++++++++++++++++++++++++++++++++++
 7 files changed, 211 insertions(+), 139 deletions(-)
 delete mode 100644 mm/debug-pagealloc.c
 create mode 100644 mm/page_poison.c

diff --git a/Documentation/kernel-parameters.txt b/Documentation/kernel-parameters.txt
index 87d40a7..fdade3d 100644
--- a/Documentation/kernel-parameters.txt
+++ b/Documentation/kernel-parameters.txt
@@ -2716,6 +2716,11 @@ bytes respectively. Such letter suffixes can also be entirely omitted.
 			we can turn it on.
 			on: enable the feature
 
+	page_poison=	[KNL] Boot-time parameter changing the state of
+			poisoning on the buddy allocator.
+			off: turn off poisoning
+			on: turn on poisoning
+
 	panic=		[KNL] Kernel behaviour on panic: delay <timeout>
 			timeout > 0: seconds before rebooting
 			timeout = 0: wait forever
diff --git a/include/linux/mm.h b/include/linux/mm.h
index f1cd22f..966bf0e 100644
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -2174,6 +2174,15 @@ extern int apply_to_page_range(struct mm_struct *mm, unsigned long address,
 			       unsigned long size, pte_fn_t fn, void *data);
 
 
+#ifdef CONFIG_PAGE_POISONING
+extern bool page_poisoning_enabled(void);
+extern void kernel_poison_pages(struct page *page, int numpages, int enable);
+#else
+static inline bool page_poisoning_enabled(void) { return false; }
+static inline void kernel_poison_pages(struct page *page, int numpages,
+					int enable) { }
+#endif
+
 #ifdef CONFIG_DEBUG_PAGEALLOC
 extern bool _debug_pagealloc_enabled;
 extern void __kernel_map_pages(struct page *page, int numpages, int enable);
diff --git a/mm/Kconfig.debug b/mm/Kconfig.debug
index 957d3da..25c98ae 100644
--- a/mm/Kconfig.debug
+++ b/mm/Kconfig.debug
@@ -27,4 +27,24 @@ config DEBUG_PAGEALLOC
 	  a resume because free pages are not saved to the suspend image.
 
 config PAGE_POISONING
-	bool
+	bool "Poison pages after freeing"
+	select PAGE_EXTENSION
+	select PAGE_POISONING_NO_SANITY if HIBERNATION
+	---help---
+	  Fill the pages with poison patterns after free_pages() and verify
+	  the patterns before alloc_pages. The filling of the memory helps
+	  reduce the risk of information leaks from freed data. This does
+	  have a potential performance impact.
+
+	  If unsure, say N
+
+config PAGE_POISONING_NO_SANITY
+	depends on PAGE_POISONING
+	bool "Only poison, don't sanity check"
+	---help---
+	   Skip the sanity checking on alloc, only fill the pages with
+	   poison on free. This reduces some of the overhead of the
+	   poisoning feature.
+
+	   If you are only interested in sanitization, say Y. Otherwise
+	   say N.
diff --git a/mm/Makefile b/mm/Makefile
index 2ed4319..cfdd481d 100644
--- a/mm/Makefile
+++ b/mm/Makefile
@@ -48,7 +48,7 @@ obj-$(CONFIG_SPARSEMEM_VMEMMAP) += sparse-vmemmap.o
 obj-$(CONFIG_SLOB) += slob.o
 obj-$(CONFIG_MMU_NOTIFIER) += mmu_notifier.o
 obj-$(CONFIG_KSM) += ksm.o
-obj-$(CONFIG_PAGE_POISONING) += debug-pagealloc.o
+obj-$(CONFIG_PAGE_POISONING) += page_poison.o
 obj-$(CONFIG_SLAB) += slab.o
 obj-$(CONFIG_SLUB) += slub.o
 obj-$(CONFIG_KMEMCHECK) += kmemcheck.o
diff --git a/mm/debug-pagealloc.c b/mm/debug-pagealloc.c
deleted file mode 100644
index 5bf5906..0000000
--- a/mm/debug-pagealloc.c
+++ /dev/null
@@ -1,137 +0,0 @@
-#include <linux/kernel.h>
-#include <linux/string.h>
-#include <linux/mm.h>
-#include <linux/highmem.h>
-#include <linux/page_ext.h>
-#include <linux/poison.h>
-#include <linux/ratelimit.h>
-
-static bool page_poisoning_enabled __read_mostly;
-
-static bool need_page_poisoning(void)
-{
-	if (!debug_pagealloc_enabled())
-		return false;
-
-	return true;
-}
-
-static void init_page_poisoning(void)
-{
-	if (!debug_pagealloc_enabled())
-		return;
-
-	page_poisoning_enabled = true;
-}
-
-struct page_ext_operations page_poisoning_ops = {
-	.need = need_page_poisoning,
-	.init = init_page_poisoning,
-};
-
-static inline void set_page_poison(struct page *page)
-{
-	struct page_ext *page_ext;
-
-	page_ext = lookup_page_ext(page);
-	__set_bit(PAGE_EXT_DEBUG_POISON, &page_ext->flags);
-}
-
-static inline void clear_page_poison(struct page *page)
-{
-	struct page_ext *page_ext;
-
-	page_ext = lookup_page_ext(page);
-	__clear_bit(PAGE_EXT_DEBUG_POISON, &page_ext->flags);
-}
-
-static inline bool page_poison(struct page *page)
-{
-	struct page_ext *page_ext;
-
-	page_ext = lookup_page_ext(page);
-	return test_bit(PAGE_EXT_DEBUG_POISON, &page_ext->flags);
-}
-
-static void poison_page(struct page *page)
-{
-	void *addr = kmap_atomic(page);
-
-	set_page_poison(page);
-	memset(addr, PAGE_POISON, PAGE_SIZE);
-	kunmap_atomic(addr);
-}
-
-static void poison_pages(struct page *page, int n)
-{
-	int i;
-
-	for (i = 0; i < n; i++)
-		poison_page(page + i);
-}
-
-static bool single_bit_flip(unsigned char a, unsigned char b)
-{
-	unsigned char error = a ^ b;
-
-	return error && !(error & (error - 1));
-}
-
-static void check_poison_mem(unsigned char *mem, size_t bytes)
-{
-	static DEFINE_RATELIMIT_STATE(ratelimit, 5 * HZ, 10);
-	unsigned char *start;
-	unsigned char *end;
-
-	start = memchr_inv(mem, PAGE_POISON, bytes);
-	if (!start)
-		return;
-
-	for (end = mem + bytes - 1; end > start; end--) {
-		if (*end != PAGE_POISON)
-			break;
-	}
-
-	if (!__ratelimit(&ratelimit))
-		return;
-	else if (start == end && single_bit_flip(*start, PAGE_POISON))
-		printk(KERN_ERR "pagealloc: single bit error\n");
-	else
-		printk(KERN_ERR "pagealloc: memory corruption\n");
-
-	print_hex_dump(KERN_ERR, "", DUMP_PREFIX_ADDRESS, 16, 1, start,
-			end - start + 1, 1);
-	dump_stack();
-}
-
-static void unpoison_page(struct page *page)
-{
-	void *addr;
-
-	if (!page_poison(page))
-		return;
-
-	addr = kmap_atomic(page);
-	check_poison_mem(addr, PAGE_SIZE);
-	clear_page_poison(page);
-	kunmap_atomic(addr);
-}
-
-static void unpoison_pages(struct page *page, int n)
-{
-	int i;
-
-	for (i = 0; i < n; i++)
-		unpoison_page(page + i);
-}
-
-void __kernel_map_pages(struct page *page, int numpages, int enable)
-{
-	if (!page_poisoning_enabled)
-		return;
-
-	if (enable)
-		unpoison_pages(page, numpages);
-	else
-		poison_pages(page, numpages);
-}
diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 63358d9..cc4762a 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -1002,6 +1002,7 @@ static bool free_pages_prepare(struct page *page, unsigned int order)
 					   PAGE_SIZE << order);
 	}
 	arch_free_page(page, order);
+	kernel_poison_pages(page, 1 << order, 0);
 	kernel_map_pages(page, 1 << order, 0);
 
 	return true;
@@ -1397,6 +1398,7 @@ static int prep_new_page(struct page *page, unsigned int order, gfp_t gfp_flags,
 
 	arch_alloc_page(page, order);
 	kernel_map_pages(page, 1 << order, 1);
+	kernel_poison_pages(page, 1 << order, 1);
 	kasan_alloc_pages(page, order);
 
 	if (gfp_flags & __GFP_ZERO)
diff --git a/mm/page_poison.c b/mm/page_poison.c
new file mode 100644
index 0000000..89d3bc7
--- /dev/null
+++ b/mm/page_poison.c
@@ -0,0 +1,173 @@
+#include <linux/kernel.h>
+#include <linux/string.h>
+#include <linux/mm.h>
+#include <linux/highmem.h>
+#include <linux/page_ext.h>
+#include <linux/poison.h>
+#include <linux/ratelimit.h>
+
+static bool __page_poisoning_enabled __read_mostly;
+static bool want_page_poisoning __read_mostly;
+
+static int early_page_poison_param(char *buf)
+{
+	if (!buf)
+		return -EINVAL;
+
+	if (strcmp(buf, "on") == 0)
+		want_page_poisoning = true;
+	else if (strcmp(buf, "off") == 0)
+		want_page_poisoning = false;
+
+	return 0;
+}
+early_param("page_poison", early_page_poison_param);
+
+bool page_poisoning_enabled(void)
+{
+	return __page_poisoning_enabled;
+}
+
+static bool need_page_poisoning(void)
+{
+	return want_page_poisoning;
+}
+
+static void init_page_poisoning(void)
+{
+	/*
+	 * page poisoning is debug page alloc for some arches. If either
+	 * of those options are enabled, enable poisoning
+	 */
+	if (!IS_ENABLED(CONFIG_ARCH_SUPPORTS_DEBUG_PAGEALLOC)) {
+		if (!want_page_poisoning && !debug_pagealloc_enabled())
+			return;
+	} else {
+		if (!want_page_poisoning)
+			return;
+	}
+
+	__page_poisoning_enabled = true;
+}
+
+struct page_ext_operations page_poisoning_ops = {
+	.need = need_page_poisoning,
+	.init = init_page_poisoning,
+};
+
+static inline void set_page_poison(struct page *page)
+{
+	struct page_ext *page_ext;
+
+	page_ext = lookup_page_ext(page);
+	__set_bit(PAGE_EXT_DEBUG_POISON, &page_ext->flags);
+}
+
+static inline void clear_page_poison(struct page *page)
+{
+	struct page_ext *page_ext;
+
+	page_ext = lookup_page_ext(page);
+	__clear_bit(PAGE_EXT_DEBUG_POISON, &page_ext->flags);
+}
+
+static inline bool page_poison(struct page *page)
+{
+	struct page_ext *page_ext;
+
+	page_ext = lookup_page_ext(page);
+	return test_bit(PAGE_EXT_DEBUG_POISON, &page_ext->flags);
+}
+
+static void poison_page(struct page *page)
+{
+	void *addr = kmap_atomic(page);
+
+	set_page_poison(page);
+	memset(addr, PAGE_POISON, PAGE_SIZE);
+	kunmap_atomic(addr);
+}
+
+static void poison_pages(struct page *page, int n)
+{
+	int i;
+
+	for (i = 0; i < n; i++)
+		poison_page(page + i);
+}
+
+static bool single_bit_flip(unsigned char a, unsigned char b)
+{
+	unsigned char error = a ^ b;
+
+	return error && !(error & (error - 1));
+}
+
+static void check_poison_mem(unsigned char *mem, size_t bytes)
+{
+	static DEFINE_RATELIMIT_STATE(ratelimit, 5 * HZ, 10);
+	unsigned char *start;
+	unsigned char *end;
+
+	if (IS_ENABLED(CONFIG_PAGE_POISONING_NO_SANITY))
+		return;
+
+	start = memchr_inv(mem, PAGE_POISON, bytes);
+	if (!start)
+		return;
+
+	for (end = mem + bytes - 1; end > start; end--) {
+		if (*end != PAGE_POISON)
+			break;
+	}
+
+	if (!__ratelimit(&ratelimit))
+		return;
+	else if (start == end && single_bit_flip(*start, PAGE_POISON))
+		pr_err("pagealloc: single bit error\n");
+	else
+		pr_err("pagealloc: memory corruption\n");
+
+	print_hex_dump(KERN_ERR, "", DUMP_PREFIX_ADDRESS, 16, 1, start,
+			end - start + 1, 1);
+	dump_stack();
+}
+
+static void unpoison_page(struct page *page)
+{
+	void *addr;
+
+	if (!page_poison(page))
+		return;
+
+	addr = kmap_atomic(page);
+	check_poison_mem(addr, PAGE_SIZE);
+	clear_page_poison(page);
+	kunmap_atomic(addr);
+}
+
+static void unpoison_pages(struct page *page, int n)
+{
+	int i;
+
+	for (i = 0; i < n; i++)
+		unpoison_page(page + i);
+}
+
+void kernel_poison_pages(struct page *page, int numpages, int enable)
+{
+	if (!page_poisoning_enabled())
+		return;
+
+	if (enable)
+		unpoison_pages(page, numpages);
+	else
+		poison_pages(page, numpages);
+}
+
+#ifndef CONFIG_ARCH_SUPPORTS_DEBUG_PAGEALLOC
+void __kernel_map_pages(struct page *page, int numpages, int enable)
+{
+	/* This function does nothing, all work is done via poison pages */
+}
+#endif
-- 
2.5.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
