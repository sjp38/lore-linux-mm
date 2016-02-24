Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f47.google.com (mail-pa0-f47.google.com [209.85.220.47])
	by kanga.kvack.org (Postfix) with ESMTP id 5EE2D6B0257
	for <linux-mm@kvack.org>; Wed, 24 Feb 2016 18:35:29 -0500 (EST)
Received: by mail-pa0-f47.google.com with SMTP id yy13so20873686pab.3
        for <linux-mm@kvack.org>; Wed, 24 Feb 2016 15:35:29 -0800 (PST)
Received: from mail-pf0-x234.google.com (mail-pf0-x234.google.com. [2607:f8b0:400e:c00::234])
        by mx.google.com with ESMTPS id rk6si7890149pab.242.2016.02.24.15.35.28
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 24 Feb 2016 15:35:28 -0800 (PST)
Received: by mail-pf0-x234.google.com with SMTP id x65so21408215pfb.1
        for <linux-mm@kvack.org>; Wed, 24 Feb 2016 15:35:28 -0800 (PST)
From: Kees Cook <keescook@chromium.org>
Subject: [RFC][PATCH v3 1/2] mm/page_poison.c: Enable PAGE_POISONING as a separate option
Date: Wed, 24 Feb 2016 15:35:22 -0800
Message-Id: <1456356923-5164-2-git-send-email-keescook@chromium.org>
In-Reply-To: <1456356923-5164-1-git-send-email-keescook@chromium.org>
References: <1456356923-5164-1-git-send-email-keescook@chromium.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Laura Abbott <labbott@fedoraproject.org>
Cc: Kees Cook <keescook@chromium.org>, Andrew Morton <akpm@linux-foundation.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Vlastimil Babka <vbabka@suse.cz>, Michal Hocko <mhocko@suse.com>, Mathias Krause <minipli@googlemail.com>, Dave Hansen <dave.hansen@intel.com>, Jianyu Zhan <nasa4836@gmail.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

From: Laura Abbott <labbott@fedoraproject.org>

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
[rebased by Kees Cook <keescook@chromium.org>]
Tested-by: Kees Cook <keescook@chromium.org>
---
 include/linux/mm.h |  7 +++----
 mm/Kconfig.debug   | 22 +++++++++++++++++++++-
 mm/Makefile        |  4 ----
 mm/page_alloc.c    |  2 ++
 mm/page_poison.c   | 29 +++++++++++++++++++++++++----
 5 files changed, 51 insertions(+), 13 deletions(-)

diff --git a/include/linux/mm.h b/include/linux/mm.h
index ea5de9d3e00b..6cdd8d91e5ef 100644
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -2199,13 +2199,12 @@ extern int apply_to_page_range(struct mm_struct *mm, unsigned long address,
 
 
 #ifdef CONFIG_PAGE_POISONING
-extern void poison_pages(struct page *page, int n);
-extern void unpoison_pages(struct page *page, int n);
 extern bool page_poisoning_enabled(void);
+extern void kernel_poison_pages(struct page *page, int numpages, int enable);
 #else
-static inline void poison_pages(struct page *page, int n) { }
-static inline void unpoison_pages(struct page *page, int n) { }
 static inline bool page_poisoning_enabled(void) { return false; }
+static inline void kernel_poison_pages(struct page *page, int numpages,
+				       int enable) { }
 #endif
 
 #ifdef CONFIG_DEBUG_PAGEALLOC
diff --git a/mm/Kconfig.debug b/mm/Kconfig.debug
index a0c136af9c91..ddf71d7cb6ba 100644
--- a/mm/Kconfig.debug
+++ b/mm/Kconfig.debug
@@ -41,4 +41,24 @@ config DEBUG_PAGEALLOC_ENABLE_DEFAULT
 	  can be overridden by debug_pagealloc=off|on.
 
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
index fb1a7948c107..ec59c071b4f9 100644
--- a/mm/Makefile
+++ b/mm/Makefile
@@ -13,7 +13,6 @@ KCOV_INSTRUMENT_slob.o := n
 KCOV_INSTRUMENT_slab.o := n
 KCOV_INSTRUMENT_slub.o := n
 KCOV_INSTRUMENT_page_alloc.o := n
-KCOV_INSTRUMENT_debug-pagealloc.o := n
 KCOV_INSTRUMENT_kmemleak.o := n
 KCOV_INSTRUMENT_kmemcheck.o := n
 KCOV_INSTRUMENT_memcontrol.o := n
@@ -63,9 +62,6 @@ obj-$(CONFIG_SPARSEMEM_VMEMMAP) += sparse-vmemmap.o
 obj-$(CONFIG_SLOB) += slob.o
 obj-$(CONFIG_MMU_NOTIFIER) += mmu_notifier.o
 obj-$(CONFIG_KSM) += ksm.o
-ifndef CONFIG_ARCH_SUPPORTS_DEBUG_PAGEALLOC
-	obj-$(CONFIG_DEBUG_PAGEALLOC) += debug-pagealloc.o
-endif
 obj-$(CONFIG_PAGE_POISONING) += page_poison.o
 obj-$(CONFIG_SLAB) += slab.o
 obj-$(CONFIG_SLUB) += slub.o
diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index a34c359d8e81..0bdb3cfd83b5 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -1026,6 +1026,7 @@ static bool free_pages_prepare(struct page *page, unsigned int order)
 					   PAGE_SIZE << order);
 	}
 	arch_free_page(page, order);
+	kernel_poison_pages(page, 1 << order, 0);
 	kernel_map_pages(page, 1 << order, 0);
 
 	return true;
@@ -1497,6 +1498,7 @@ static int prep_new_page(struct page *page, unsigned int order, gfp_t gfp_flags,
 
 	arch_alloc_page(page, order);
 	kernel_map_pages(page, 1 << order, 1);
+	kernel_poison_pages(page, 1 << order, 1);
 	kasan_alloc_pages(page, order);
 
 	if (gfp_flags & __GFP_ZERO)
diff --git a/mm/page_poison.c b/mm/page_poison.c
index 92ead727b8f0..884a6f854432 100644
--- a/mm/page_poison.c
+++ b/mm/page_poison.c
@@ -80,7 +80,7 @@ static void poison_page(struct page *page)
 	kunmap_atomic(addr);
 }
 
-void poison_pages(struct page *page, int n)
+static void poison_pages(struct page *page, int n)
 {
 	int i;
 
@@ -101,6 +101,9 @@ static void check_poison_mem(unsigned char *mem, size_t bytes)
 	unsigned char *start;
 	unsigned char *end;
 
+	if (IS_ENABLED(CONFIG_PAGE_POISONING_NO_SANITY))
+		return;
+
 	start = memchr_inv(mem, PAGE_POISON, bytes);
 	if (!start)
 		return;
@@ -113,9 +116,9 @@ static void check_poison_mem(unsigned char *mem, size_t bytes)
 	if (!__ratelimit(&ratelimit))
 		return;
 	else if (start == end && single_bit_flip(*start, PAGE_POISON))
-		printk(KERN_ERR "pagealloc: single bit error\n");
+		pr_err("pagealloc: single bit error\n");
 	else
-		printk(KERN_ERR "pagealloc: memory corruption\n");
+		pr_err("pagealloc: memory corruption\n");
 
 	print_hex_dump(KERN_ERR, "", DUMP_PREFIX_ADDRESS, 16, 1, start,
 			end - start + 1, 1);
@@ -135,10 +138,28 @@ static void unpoison_page(struct page *page)
 	kunmap_atomic(addr);
 }
 
-void unpoison_pages(struct page *page, int n)
+static void unpoison_pages(struct page *page, int n)
 {
 	int i;
 
 	for (i = 0; i < n; i++)
 		unpoison_page(page + i);
 }
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
2.6.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
