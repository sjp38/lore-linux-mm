Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl1-f197.google.com (mail-pl1-f197.google.com [209.85.214.197])
	by kanga.kvack.org (Postfix) with ESMTP id 6440B8E000B
	for <linux-mm@kvack.org>; Wed, 16 Jan 2019 19:33:41 -0500 (EST)
Received: by mail-pl1-f197.google.com with SMTP id 12so4923704plb.18
        for <linux-mm@kvack.org>; Wed, 16 Jan 2019 16:33:41 -0800 (PST)
Received: from mga04.intel.com (mga04.intel.com. [192.55.52.120])
        by mx.google.com with ESMTPS id q20si7678846pll.255.2019.01.16.16.33.39
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 16 Jan 2019 16:33:39 -0800 (PST)
From: Rick Edgecombe <rick.p.edgecombe@intel.com>
Subject: [PATCH 14/17] mm: Make hibernate handle unmapped pages
Date: Wed, 16 Jan 2019 16:32:56 -0800
Message-Id: <20190117003259.23141-15-rick.p.edgecombe@intel.com>
In-Reply-To: <20190117003259.23141-1-rick.p.edgecombe@intel.com>
References: <20190117003259.23141-1-rick.p.edgecombe@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andy Lutomirski <luto@kernel.org>, Ingo Molnar <mingo@redhat.com>
Cc: linux-kernel@vger.kernel.org, x86@kernel.org, hpa@zytor.com, Thomas Gleixner <tglx@linutronix.de>, Borislav Petkov <bp@alien8.de>, Nadav Amit <nadav.amit@gmail.com>, Dave Hansen <dave.hansen@linux.intel.com>, Peter Zijlstra <peterz@infradead.org>, linux_dti@icloud.com, linux-integrity@vger.kernel.org, linux-security-module@vger.kernel.org, akpm@linux-foundation.org, kernel-hardening@lists.openwall.com, linux-mm@kvack.org, will.deacon@arm.com, ard.biesheuvel@linaro.org, kristen@linux.intel.com, deneen.t.dock@intel.com, Rick Edgecombe <rick.p.edgecombe@intel.com>, "Rafael J. Wysocki" <rjw@rjwysocki.net>, Pavel Machek <pavel@ucw.cz>

For architectures with CONFIG_ARCH_HAS_SET_ALIAS, pages can be unmapped
briefly on the directmap, even when CONFIG_DEBUG_PAGEALLOC is not configured.
So this changes kernel_map_pages and kernel_page_present to be defined when
CONFIG_ARCH_HAS_SET_ALIAS is defined as well. It also changes places
(page_alloc.c) where those functions are assumed to only be implemented when
CONFIG_DEBUG_PAGEALLOC is defined.

So now when CONFIG_ARCH_HAS_SET_ALIAS=y, hibernate will handle not present
page when saving. Previously this was already done when CONFIG_DEBUG_PAGEALLOC
was configured. It does not appear to have a big hibernating performance
impact.

Before:
[    4.670938] PM: Wrote 171996 kbytes in 0.21 seconds (819.02 MB/s)

After:
[    4.504714] PM: Wrote 178932 kbytes in 0.22 seconds (813.32 MB/s)

Cc: Dave Hansen <dave.hansen@linux.intel.com>
Cc: Andy Lutomirski <luto@kernel.org>
Cc: Peter Zijlstra <peterz@infradead.org>
Cc: "Rafael J. Wysocki" <rjw@rjwysocki.net>
Cc: Pavel Machek <pavel@ucw.cz>
Signed-off-by: Rick Edgecombe <rick.p.edgecombe@intel.com>
---
 arch/x86/mm/pageattr.c |  4 ----
 include/linux/mm.h     | 18 ++++++------------
 mm/page_alloc.c        |  6 ++++--
 3 files changed, 10 insertions(+), 18 deletions(-)

diff --git a/arch/x86/mm/pageattr.c b/arch/x86/mm/pageattr.c
index 3a51915a1410..717bdc188aab 100644
--- a/arch/x86/mm/pageattr.c
+++ b/arch/x86/mm/pageattr.c
@@ -2257,7 +2257,6 @@ int set_alias_default_noflush(struct page *page)
 	return __set_pages_p(page, 1);
 }
 
-#ifdef CONFIG_DEBUG_PAGEALLOC
 void __kernel_map_pages(struct page *page, int numpages, int enable)
 {
 	if (PageHighMem(page))
@@ -2302,11 +2301,8 @@ bool kernel_page_present(struct page *page)
 	pte = lookup_address((unsigned long)page_address(page), &level);
 	return (pte_val(*pte) & _PAGE_PRESENT);
 }
-
 #endif /* CONFIG_HIBERNATION */
 
-#endif /* CONFIG_DEBUG_PAGEALLOC */
-
 int __init kernel_map_pages_in_pgd(pgd_t *pgd, u64 pfn, unsigned long address,
 				   unsigned numpages, unsigned long page_flags)
 {
diff --git a/include/linux/mm.h b/include/linux/mm.h
index 80bb6408fe73..b362a280a919 100644
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -2642,37 +2642,31 @@ static inline void kernel_poison_pages(struct page *page, int numpages,
 					int enable) { }
 #endif
 
-#ifdef CONFIG_DEBUG_PAGEALLOC
 extern bool _debug_pagealloc_enabled;
-extern void __kernel_map_pages(struct page *page, int numpages, int enable);
 
 static inline bool debug_pagealloc_enabled(void)
 {
-	return _debug_pagealloc_enabled;
+	return IS_ENABLED(CONFIG_DEBUG_PAGEALLOC) && _debug_pagealloc_enabled;
 }
 
+#if defined(CONFIG_DEBUG_PAGEALLOC) || defined(CONFIG_ARCH_HAS_SET_ALIAS)
+extern void __kernel_map_pages(struct page *page, int numpages, int enable);
+
 static inline void
 kernel_map_pages(struct page *page, int numpages, int enable)
 {
-	if (!debug_pagealloc_enabled())
-		return;
-
 	__kernel_map_pages(page, numpages, enable);
 }
 #ifdef CONFIG_HIBERNATION
 extern bool kernel_page_present(struct page *page);
 #endif	/* CONFIG_HIBERNATION */
-#else	/* CONFIG_DEBUG_PAGEALLOC */
+#else	/* CONFIG_DEBUG_PAGEALLOC || CONFIG_ARCH_HAS_SET_ALIAS */
 static inline void
 kernel_map_pages(struct page *page, int numpages, int enable) {}
 #ifdef CONFIG_HIBERNATION
 static inline bool kernel_page_present(struct page *page) { return true; }
 #endif	/* CONFIG_HIBERNATION */
-static inline bool debug_pagealloc_enabled(void)
-{
-	return false;
-}
-#endif	/* CONFIG_DEBUG_PAGEALLOC */
+#endif	/* CONFIG_DEBUG_PAGEALLOC || CONFIG_ARCH_HAS_SET_ALIAS */
 
 #ifdef __HAVE_ARCH_GATE_AREA
 extern struct vm_area_struct *get_gate_vma(struct mm_struct *mm);
diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index d295c9bc01a8..c10a0d484aa6 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -1074,7 +1074,8 @@ static __always_inline bool free_pages_prepare(struct page *page,
 	}
 	arch_free_page(page, order);
 	kernel_poison_pages(page, 1 << order, 0);
-	kernel_map_pages(page, 1 << order, 0);
+	if (debug_pagealloc_enabled())
+		kernel_map_pages(page, 1 << order, 0);
 	kasan_free_nondeferred_pages(page, order);
 
 	return true;
@@ -1944,7 +1945,8 @@ inline void post_alloc_hook(struct page *page, unsigned int order,
 	set_page_refcounted(page);
 
 	arch_alloc_page(page, order);
-	kernel_map_pages(page, 1 << order, 1);
+	if (debug_pagealloc_enabled())
+		kernel_map_pages(page, 1 << order, 1);
 	kernel_poison_pages(page, 1 << order, 1);
 	kasan_alloc_pages(page, order);
 	set_page_owner(page, order, gfp_flags);
-- 
2.17.1
