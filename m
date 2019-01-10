Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg1-f200.google.com (mail-pg1-f200.google.com [209.85.215.200])
	by kanga.kvack.org (Postfix) with ESMTP id 18E8B8E0008
	for <linux-mm@kvack.org>; Thu, 10 Jan 2019 16:11:09 -0500 (EST)
Received: by mail-pg1-f200.google.com with SMTP id t26so7044006pgu.18
        for <linux-mm@kvack.org>; Thu, 10 Jan 2019 13:11:09 -0800 (PST)
Received: from userp2130.oracle.com (userp2130.oracle.com. [156.151.31.86])
        by mx.google.com with ESMTPS id e13si15463741pfi.271.2019.01.10.13.11.07
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 10 Jan 2019 13:11:07 -0800 (PST)
From: Khalid Aziz <khalid.aziz@oracle.com>
Subject: [RFC PATCH v7 12/16] xpfo, mm: remove dependency on CONFIG_PAGE_EXTENSION
Date: Thu, 10 Jan 2019 14:09:44 -0700
Message-Id: <a9436d3bc7943123bdbaac3f3e2b6bec3153ee05.1547153058.git.khalid.aziz@oracle.com>
In-Reply-To: <cover.1547153058.git.khalid.aziz@oracle.com>
References: <cover.1547153058.git.khalid.aziz@oracle.com>
In-Reply-To: <cover.1547153058.git.khalid.aziz@oracle.com>
References: <cover.1547153058.git.khalid.aziz@oracle.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: juergh@gmail.com, tycho@tycho.ws, jsteckli@amazon.de, ak@linux.intel.com, torvalds@linux-foundation.org, liran.alon@oracle.com, keescook@google.com, konrad.wilk@oracle.com
Cc: deepa.srinivasan@oracle.com, chris.hyser@oracle.com, tyhicks@canonical.com, dwmw@amazon.co.uk, andrew.cooper3@citrix.com, jcm@redhat.com, boris.ostrovsky@oracle.com, kanth.ghatraju@oracle.com, joao.m.martins@oracle.com, jmattson@google.com, pradeep.vincent@oracle.com, john.haxby@oracle.com, tglx@linutronix.de, kirill.shutemov@linux.intel.com, hch@lst.de, steven.sistare@oracle.com, kernel-hardening@lists.openwall.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, x86@kernel.org, "Vasileios P . Kemerlis" <vpk@cs.columbia.edu>, Juerg Haefliger <juerg.haefliger@canonical.com>, Tycho Andersen <tycho@docker.com>, Marco Benatto <marco.antonio.780@gmail.com>, David Woodhouse <dwmw2@infradead.org>, Khalid Aziz <khalid.aziz@oracle.com>

From: Julian Stecklina <jsteckli@amazon.de>

Instead of using the page extension debug feature, encode all
information, we need for XPFO in struct page. This allows to get rid of
some checks in the hot paths and there are also no pages anymore that
are allocated before XPFO is enabled.

Also make debugging aids configurable for maximum performance.

Signed-off-by: Julian Stecklina <jsteckli@amazon.de>
Cc: x86@kernel.org
Cc: kernel-hardening@lists.openwall.com
Cc: Vasileios P. Kemerlis <vpk@cs.columbia.edu>
Cc: Juerg Haefliger <juerg.haefliger@canonical.com>
Cc: Tycho Andersen <tycho@docker.com>
Cc: Marco Benatto <marco.antonio.780@gmail.com>
Cc: David Woodhouse <dwmw2@infradead.org>
Signed-off-by: Khalid Aziz <khalid.aziz@oracle.com>
---
 include/linux/mm_types.h       |   8 ++
 include/linux/page-flags.h     |  13 +++
 include/linux/xpfo.h           |   3 +-
 include/trace/events/mmflags.h |  10 +-
 mm/page_alloc.c                |   3 +-
 mm/page_ext.c                  |   4 -
 mm/xpfo.c                      | 162 ++++++++-------------------------
 security/Kconfig               |  12 ++-
 8 files changed, 81 insertions(+), 134 deletions(-)

diff --git a/include/linux/mm_types.h b/include/linux/mm_types.h
index 2c471a2c43fa..d17d33f36a01 100644
--- a/include/linux/mm_types.h
+++ b/include/linux/mm_types.h
@@ -204,6 +204,14 @@ struct page {
 #ifdef LAST_CPUPID_NOT_IN_PAGE_FLAGS
 	int _last_cpupid;
 #endif
+
+#ifdef CONFIG_XPFO
+	/* Counts the number of times this page has been kmapped. */
+	atomic_t xpfo_mapcount;
+
+	/* Serialize kmap/kunmap of this page */
+	spinlock_t xpfo_lock;
+#endif
 } _struct_page_alignment;
 
 /*
diff --git a/include/linux/page-flags.h b/include/linux/page-flags.h
index 50ce1bddaf56..a532063f27b5 100644
--- a/include/linux/page-flags.h
+++ b/include/linux/page-flags.h
@@ -101,6 +101,10 @@ enum pageflags {
 #if defined(CONFIG_IDLE_PAGE_TRACKING) && defined(CONFIG_64BIT)
 	PG_young,
 	PG_idle,
+#endif
+#ifdef CONFIG_XPFO
+	PG_xpfo_user,		/* Page is allocated to user-space */
+	PG_xpfo_unmapped,	/* Page is unmapped from the linear map */
 #endif
 	__NR_PAGEFLAGS,
 
@@ -398,6 +402,15 @@ TESTCLEARFLAG(Young, young, PF_ANY)
 PAGEFLAG(Idle, idle, PF_ANY)
 #endif
 
+#ifdef CONFIG_XPFO
+PAGEFLAG(XpfoUser, xpfo_user, PF_ANY)
+TESTCLEARFLAG(XpfoUser, xpfo_user, PF_ANY)
+TESTSETFLAG(XpfoUser, xpfo_user, PF_ANY)
+PAGEFLAG(XpfoUnmapped, xpfo_unmapped, PF_ANY)
+TESTCLEARFLAG(XpfoUnmapped, xpfo_unmapped, PF_ANY)
+TESTSETFLAG(XpfoUnmapped, xpfo_unmapped, PF_ANY)
+#endif
+
 /*
  * On an anonymous page mapped into a user virtual memory area,
  * page->mapping points to its anon_vma, not to a struct address_space;
diff --git a/include/linux/xpfo.h b/include/linux/xpfo.h
index d4b38ab8a633..ea5188882f49 100644
--- a/include/linux/xpfo.h
+++ b/include/linux/xpfo.h
@@ -27,7 +27,7 @@ struct page;
 
 #include <linux/types.h>
 
-extern struct page_ext_operations page_xpfo_ops;
+void xpfo_init_single_page(struct page *page);
 
 void set_kpte(void *kaddr, struct page *page, pgprot_t prot);
 void xpfo_dma_map_unmap_area(bool map, const void *addr, size_t size,
@@ -56,6 +56,7 @@ phys_addr_t user_virt_to_phys(unsigned long addr);
 
 #else /* !CONFIG_XPFO */
 
+static inline void xpfo_init_single_page(struct page *page) { }
 static inline void xpfo_kmap(void *kaddr, struct page *page) { }
 static inline void xpfo_kunmap(void *kaddr, struct page *page) { }
 static inline void xpfo_alloc_pages(struct page *page, int order, gfp_t gfp) { }
diff --git a/include/trace/events/mmflags.h b/include/trace/events/mmflags.h
index a1675d43777e..6bb000bb366f 100644
--- a/include/trace/events/mmflags.h
+++ b/include/trace/events/mmflags.h
@@ -79,6 +79,12 @@
 #define IF_HAVE_PG_IDLE(flag,string)
 #endif
 
+#ifdef CONFIG_XPFO
+#define IF_HAVE_PG_XPFO(flag,string) ,{1UL << flag, string}
+#else
+#define IF_HAVE_PG_XPFO(flag,string)
+#endif
+
 #define __def_pageflag_names						\
 	{1UL << PG_locked,		"locked"	},		\
 	{1UL << PG_waiters,		"waiters"	},		\
@@ -105,7 +111,9 @@ IF_HAVE_PG_MLOCK(PG_mlocked,		"mlocked"	)		\
 IF_HAVE_PG_UNCACHED(PG_uncached,	"uncached"	)		\
 IF_HAVE_PG_HWPOISON(PG_hwpoison,	"hwpoison"	)		\
 IF_HAVE_PG_IDLE(PG_young,		"young"		)		\
-IF_HAVE_PG_IDLE(PG_idle,		"idle"		)
+IF_HAVE_PG_IDLE(PG_idle,		"idle"		)		\
+IF_HAVE_PG_XPFO(PG_xpfo_user,		"xpfo_user"	)		\
+IF_HAVE_PG_XPFO(PG_xpfo_unmapped,	"xpfo_unmapped" ) 		\
 
 #define show_page_flags(flags)						\
 	(flags) ? __print_flags(flags, "|",				\
diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 08e277790b5f..d00382b20001 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -1024,6 +1024,7 @@ static __always_inline bool free_pages_prepare(struct page *page,
 	if (bad)
 		return false;
 
+	xpfo_free_pages(page, order);
 	page_cpupid_reset_last(page);
 	page->flags &= ~PAGE_FLAGS_CHECK_AT_PREP;
 	reset_page_owner(page, order);
@@ -1038,7 +1039,6 @@ static __always_inline bool free_pages_prepare(struct page *page,
 	kernel_poison_pages(page, 1 << order, 0);
 	kernel_map_pages(page, 1 << order, 0);
 	kasan_free_pages(page, order);
-	xpfo_free_pages(page, order);
 
 	return true;
 }
@@ -1191,6 +1191,7 @@ static void __meminit __init_single_page(struct page *page, unsigned long pfn,
 	if (!is_highmem_idx(zone))
 		set_page_address(page, __va(pfn << PAGE_SHIFT));
 #endif
+	xpfo_init_single_page(page);
 }
 
 #ifdef CONFIG_DEFERRED_STRUCT_PAGE_INIT
diff --git a/mm/page_ext.c b/mm/page_ext.c
index 38e5013dcb9a..ae44f7adbe07 100644
--- a/mm/page_ext.c
+++ b/mm/page_ext.c
@@ -8,7 +8,6 @@
 #include <linux/kmemleak.h>
 #include <linux/page_owner.h>
 #include <linux/page_idle.h>
-#include <linux/xpfo.h>
 
 /*
  * struct page extension
@@ -69,9 +68,6 @@ static struct page_ext_operations *page_ext_ops[] = {
 #if defined(CONFIG_IDLE_PAGE_TRACKING) && !defined(CONFIG_64BIT)
 	&page_idle_ops,
 #endif
-#ifdef CONFIG_XPFO
-	&page_xpfo_ops,
-#endif
 };
 
 static unsigned long total_usage;
diff --git a/mm/xpfo.c b/mm/xpfo.c
index e80374b0c78e..cbfeafc2f10f 100644
--- a/mm/xpfo.c
+++ b/mm/xpfo.c
@@ -16,33 +16,16 @@
 #include <linux/highmem.h>
 #include <linux/mm.h>
 #include <linux/module.h>
-#include <linux/page_ext.h>
 #include <linux/xpfo.h>
 
 #include <asm/tlbflush.h>
 
-/* XPFO page state flags */
-enum xpfo_flags {
-	XPFO_PAGE_USER,		/* Page is allocated to user-space */
-	XPFO_PAGE_UNMAPPED,	/* Page is unmapped from the linear map */
-};
-
-/* Per-page XPFO house-keeping data */
-struct xpfo {
-	unsigned long flags;	/* Page state */
-	bool inited;		/* Map counter and lock initialized */
-	atomic_t mapcount;	/* Counter for balancing map/unmap requests */
-	spinlock_t maplock;	/* Lock to serialize map/unmap requests */
-};
-
-DEFINE_STATIC_KEY_FALSE(xpfo_inited);
+DEFINE_STATIC_KEY_TRUE(xpfo_inited);
 DEFINE_STATIC_KEY_FALSE(xpfo_do_tlb_flush);
 
-static bool xpfo_disabled __initdata;
-
 static int __init noxpfo_param(char *str)
 {
-	xpfo_disabled = true;
+	static_branch_disable(&xpfo_inited);
 
 	return 0;
 }
@@ -57,34 +40,13 @@ static int __init xpfotlbflush_param(char *str)
 early_param("noxpfo", noxpfo_param);
 early_param("xpfotlbflush", xpfotlbflush_param);
 
-static bool __init need_xpfo(void)
-{
-	if (xpfo_disabled) {
-		printk(KERN_INFO "XPFO disabled\n");
-		return false;
-	}
-
-	return true;
-}
-
-static void init_xpfo(void)
-{
-	printk(KERN_INFO "XPFO enabled\n");
-	static_branch_enable(&xpfo_inited);
-}
-
-struct page_ext_operations page_xpfo_ops = {
-	.size = sizeof(struct xpfo),
-	.need = need_xpfo,
-	.init = init_xpfo,
-};
-
 bool __init xpfo_enabled(void)
 {
-	return !xpfo_disabled;
+	if (!static_branch_unlikely(&xpfo_inited))
+		return false;
+	else
+		return true;
 }
-EXPORT_SYMBOL(xpfo_enabled);
-
 
 static void xpfo_cond_flush_kernel_tlb(struct page *page, int order)
 {
@@ -92,58 +54,40 @@ static void xpfo_cond_flush_kernel_tlb(struct page *page, int order)
 		xpfo_flush_kernel_tlb(page, order);
 }
 
-static inline struct xpfo *lookup_xpfo(struct page *page)
+void __meminit xpfo_init_single_page(struct page *page)
 {
-	struct page_ext *page_ext = lookup_page_ext(page);
-
-	if (unlikely(!page_ext)) {
-		WARN(1, "xpfo: failed to get page ext");
-		return NULL;
-	}
-
-	return (void *)page_ext + page_xpfo_ops.offset;
+	spin_lock_init(&page->xpfo_lock);
 }
 
 void xpfo_alloc_pages(struct page *page, int order, gfp_t gfp)
 {
 	int i, flush_tlb = 0;
-	struct xpfo *xpfo;
 
 	if (!static_branch_unlikely(&xpfo_inited))
 		return;
 
 	for (i = 0; i < (1 << order); i++)  {
-		xpfo = lookup_xpfo(page + i);
-		if (!xpfo)
-			continue;
-
-		WARN(test_bit(XPFO_PAGE_UNMAPPED, &xpfo->flags),
-		     "xpfo: unmapped page being allocated\n");
-
-		/* Initialize the map lock and map counter */
-		if (unlikely(!xpfo->inited)) {
-			spin_lock_init(&xpfo->maplock);
-			atomic_set(&xpfo->mapcount, 0);
-			xpfo->inited = true;
-		}
-		WARN(atomic_read(&xpfo->mapcount),
-		     "xpfo: already mapped page being allocated\n");
-
+#ifdef CONFIG_XPFO_DEBUG
+		BUG_ON(PageXpfoUser(page + i));
+		BUG_ON(PageXpfoUnmapped(page + i));
+		BUG_ON(spin_is_locked(&(page + i)->xpfo_lock));
+		BUG_ON(atomic_read(&(page + i)->xpfo_mapcount));
+#endif
 		if ((gfp & GFP_HIGHUSER) == GFP_HIGHUSER) {
 			if (static_branch_unlikely(&xpfo_do_tlb_flush)) {
 				/*
 				 * Tag the page as a user page and flush the TLB if it
 				 * was previously allocated to the kernel.
 				 */
-				if (!test_and_set_bit(XPFO_PAGE_USER, &xpfo->flags))
+				if (!TestSetPageXpfoUser(page + i))
 					flush_tlb = 1;
 			} else {
-				set_bit(XPFO_PAGE_USER, &xpfo->flags);
+				SetPageXpfoUser(page + i);
 			}
 
 		} else {
 			/* Tag the page as a non-user (kernel) page */
-			clear_bit(XPFO_PAGE_USER, &xpfo->flags);
+			ClearPageXpfoUser(page + i);
 		}
 	}
 
@@ -154,27 +98,21 @@ void xpfo_alloc_pages(struct page *page, int order, gfp_t gfp)
 void xpfo_free_pages(struct page *page, int order)
 {
 	int i;
-	struct xpfo *xpfo;
 
 	if (!static_branch_unlikely(&xpfo_inited))
 		return;
 
 	for (i = 0; i < (1 << order); i++) {
-		xpfo = lookup_xpfo(page + i);
-		if (!xpfo || unlikely(!xpfo->inited)) {
-			/*
-			 * The page was allocated before page_ext was
-			 * initialized, so it is a kernel page.
-			 */
-			continue;
-		}
+#ifdef CONFIG_XPFO_DEBUG
+		BUG_ON(atomic_read(&(page + i)->xpfo_mapcount));
+#endif
 
 		/*
 		 * Map the page back into the kernel if it was previously
 		 * allocated to user space.
 		 */
-		if (test_and_clear_bit(XPFO_PAGE_USER, &xpfo->flags)) {
-			clear_bit(XPFO_PAGE_UNMAPPED, &xpfo->flags);
+		if (TestClearPageXpfoUser(page + i)) {
+			ClearPageXpfoUnmapped(page + i);
 			set_kpte(page_address(page + i), page + i,
 				 PAGE_KERNEL);
 		}
@@ -183,84 +121,56 @@ void xpfo_free_pages(struct page *page, int order)
 
 void xpfo_kmap(void *kaddr, struct page *page)
 {
-	struct xpfo *xpfo;
-
 	if (!static_branch_unlikely(&xpfo_inited))
 		return;
 
-	xpfo = lookup_xpfo(page);
-
-	/*
-	 * The page was allocated before page_ext was initialized (which means
-	 * it's a kernel page) or it's allocated to the kernel, so nothing to
-	 * do.
-	 */
-	if (!xpfo || unlikely(!xpfo->inited) ||
-	    !test_bit(XPFO_PAGE_USER, &xpfo->flags))
+	if (!PageXpfoUser(page))
 		return;
 
-	spin_lock(&xpfo->maplock);
+	spin_lock(&page->xpfo_lock);
 
 	/*
 	 * The page was previously allocated to user space, so map it back
 	 * into the kernel. No TLB flush required.
 	 */
-	if ((atomic_inc_return(&xpfo->mapcount) == 1) &&
-	    test_and_clear_bit(XPFO_PAGE_UNMAPPED, &xpfo->flags))
+	if ((atomic_inc_return(&page->xpfo_mapcount) == 1) &&
+	    TestClearPageXpfoUnmapped(page))
 		set_kpte(kaddr, page, PAGE_KERNEL);
 
-	spin_unlock(&xpfo->maplock);
+	spin_unlock(&page->xpfo_lock);
 }
 EXPORT_SYMBOL(xpfo_kmap);
 
 void xpfo_kunmap(void *kaddr, struct page *page)
 {
-	struct xpfo *xpfo;
-
 	if (!static_branch_unlikely(&xpfo_inited))
 		return;
 
-	xpfo = lookup_xpfo(page);
-
-	/*
-	 * The page was allocated before page_ext was initialized (which means
-	 * it's a kernel page) or it's allocated to the kernel, so nothing to
-	 * do.
-	 */
-	if (!xpfo || unlikely(!xpfo->inited) ||
-	    !test_bit(XPFO_PAGE_USER, &xpfo->flags))
+	if (!PageXpfoUser(page))
 		return;
 
-	spin_lock(&xpfo->maplock);
+	spin_lock(&page->xpfo_lock);
 
 	/*
 	 * The page is to be allocated back to user space, so unmap it from the
 	 * kernel, flush the TLB and tag it as a user page.
 	 */
-	if (atomic_dec_return(&xpfo->mapcount) == 0) {
-		WARN(test_bit(XPFO_PAGE_UNMAPPED, &xpfo->flags),
-		     "xpfo: unmapping already unmapped page\n");
-		set_bit(XPFO_PAGE_UNMAPPED, &xpfo->flags);
+	if (atomic_dec_return(&page->xpfo_mapcount) == 0) {
+#ifdef CONFIG_XPFO_DEBUG
+		BUG_ON(PageXpfoUnmapped(page));
+#endif
+		SetPageXpfoUnmapped(page);
 		set_kpte(kaddr, page, __pgprot(0));
 		xpfo_cond_flush_kernel_tlb(page, 0);
 	}
 
-	spin_unlock(&xpfo->maplock);
+	spin_unlock(&page->xpfo_lock);
 }
 EXPORT_SYMBOL(xpfo_kunmap);
 
 bool xpfo_page_is_unmapped(struct page *page)
 {
-	struct xpfo *xpfo;
-
-	if (!static_branch_unlikely(&xpfo_inited))
-		return false;
-
-	xpfo = lookup_xpfo(page);
-	if (unlikely(!xpfo) && !xpfo->inited)
-		return false;
-
-	return test_bit(XPFO_PAGE_UNMAPPED, &xpfo->flags);
+	return PageXpfoUnmapped(page);
 }
 EXPORT_SYMBOL(xpfo_page_is_unmapped);
 
diff --git a/security/Kconfig b/security/Kconfig
index 8d0e4e303551..c7c581bac963 100644
--- a/security/Kconfig
+++ b/security/Kconfig
@@ -13,7 +13,6 @@ config XPFO
 	bool "Enable eXclusive Page Frame Ownership (XPFO)"
 	default n
 	depends on ARCH_SUPPORTS_XPFO
-	select PAGE_EXTENSION
 	help
 	  This option offers protection against 'ret2dir' kernel attacks.
 	  When enabled, every time a page frame is allocated to user space, it
@@ -25,6 +24,17 @@ config XPFO
 
 	  If in doubt, say "N".
 
+config XPFO_DEBUG
+       bool "Enable debugging of XPFO"
+       default n
+       depends on XPFO
+       help
+         Enables additional checking of XPFO data structures that help find
+	 bugs in the XPFO implementation. This option comes with a slight
+	 performance cost.
+
+	 If in doubt, say "N".
+
 config SECURITY_DMESG_RESTRICT
 	bool "Restrict unprivileged access to the kernel syslog"
 	default n
-- 
2.17.1
