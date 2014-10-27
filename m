Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yh0-f48.google.com (mail-yh0-f48.google.com [209.85.213.48])
	by kanga.kvack.org (Postfix) with ESMTP id 1E331900021
	for <linux-mm@kvack.org>; Mon, 27 Oct 2014 19:09:54 -0400 (EDT)
Received: by mail-yh0-f48.google.com with SMTP id v1so5117378yhn.21
        for <linux-mm@kvack.org>; Mon, 27 Oct 2014 16:09:53 -0700 (PDT)
Received: from g6t1525.atlanta.hp.com (g6t1525.atlanta.hp.com. [15.193.200.68])
        by mx.google.com with ESMTPS id m66si13496675ykm.154.2014.10.27.16.09.53
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Mon, 27 Oct 2014 16:09:53 -0700 (PDT)
From: Toshi Kani <toshi.kani@hp.com>
Subject: [PATCH v4 6/7] x86, mm, asm: Add WT support to set_page_memtype()
Date: Mon, 27 Oct 2014 16:55:44 -0600
Message-Id: <1414450545-14028-7-git-send-email-toshi.kani@hp.com>
In-Reply-To: <1414450545-14028-1-git-send-email-toshi.kani@hp.com>
References: <1414450545-14028-1-git-send-email-toshi.kani@hp.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: hpa@zytor.com, tglx@linutronix.de, mingo@redhat.com, akpm@linux-foundation.org, arnd@arndb.de
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, jgross@suse.com, stefan.bader@canonical.com, luto@amacapital.net, hmh@hmh.eng.br, yigal@plexistor.com, konrad.wilk@oracle.com, Toshi Kani <toshi.kani@hp.com>

As set_memory_wb() calls set_page_memtype() with -1, _PGMT_DEFAULT is
solely used for tracking the WB type.  _PGMT_WB is defined but unused.
Hence, this patch renames _PGMT_DEFAULT to _PGMT_WB to clarify its
usage, and releases the slot used by _PGMT_WB before.  As a result,
set_memory_wb() is changed to call set_page_memtype() with _PGMT_WB,
and set_page_memtype() handles any undefined type as a bug.

This patch then defines _PGMT_WT to the released slot.  This enables
set_page_memtype() to track the WT type.

Signed-off-by: Toshi Kani <toshi.kani@hp.com>
---
 arch/x86/include/asm/cacheflush.h |   28 ++++++++++++++--------------
 arch/x86/mm/pat.c                 |   20 ++++++--------------
 2 files changed, 20 insertions(+), 28 deletions(-)

diff --git a/arch/x86/include/asm/cacheflush.h b/arch/x86/include/asm/cacheflush.h
index c912680..a561171 100644
--- a/arch/x86/include/asm/cacheflush.h
+++ b/arch/x86/include/asm/cacheflush.h
@@ -7,18 +7,18 @@
 
 #ifdef CONFIG_X86_PAT
 /*
- * X86 PAT uses page flags WC and Uncached together to keep track of
- * memory type of pages that have backing page struct. X86 PAT supports 3
- * different memory types, _PAGE_CACHE_MODE_WB, _PAGE_CACHE_MODE_WC and
- * _PAGE_CACHE_MODE_UC_MINUS and fourth state where page's memory type has not
- * been changed from its default (value of -1 used to denote this).
+ * X86 PAT uses page flags arch_1 and uncached together to keep track of
+ * memory type of pages that have backing page struct. X86 PAT supports 4
+ * different memory types, _PAGE_CACHE_MODE_WT, _PAGE_CACHE_MODE_WC,
+ * _PAGE_CACHE_MODE_UC_MINUS and _PAGE_CACHE_MODE_WB where page's memory
+ * type has not been changed from its default.
  * Note we do not support _PAGE_CACHE_MODE_UC here.
  */
 
-#define _PGMT_DEFAULT		0
+#define _PGMT_WB		0	/* default */
 #define _PGMT_WC		(1UL << PG_arch_1)
 #define _PGMT_UC_MINUS		(1UL << PG_uncached)
-#define _PGMT_WB		(1UL << PG_uncached | 1UL << PG_arch_1)
+#define _PGMT_WT		(1UL << PG_uncached | 1UL << PG_arch_1)
 #define _PGMT_MASK		(1UL << PG_uncached | 1UL << PG_arch_1)
 #define _PGMT_CLEAR_MASK	(~_PGMT_MASK)
 
@@ -26,14 +26,14 @@ static inline enum page_cache_mode get_page_memtype(struct page *pg)
 {
 	unsigned long pg_flags = pg->flags & _PGMT_MASK;
 
-	if (pg_flags == _PGMT_DEFAULT)
-		return -1;
+	if (pg_flags == _PGMT_WB)
+		return _PAGE_CACHE_MODE_WB;
 	else if (pg_flags == _PGMT_WC)
 		return _PAGE_CACHE_MODE_WC;
 	else if (pg_flags == _PGMT_UC_MINUS)
 		return _PAGE_CACHE_MODE_UC_MINUS;
 	else
-		return _PAGE_CACHE_MODE_WB;
+		return _PAGE_CACHE_MODE_WT;
 }
 
 static inline void set_page_memtype(struct page *pg,
@@ -50,16 +50,16 @@ static inline void set_page_memtype(struct page *pg,
 	case _PAGE_CACHE_MODE_UC_MINUS:
 		memtype_flags = _PGMT_UC_MINUS;
 		break;
+	case _PAGE_CACHE_MODE_WT:
+		memtype_flags = _PGMT_WT;
+		break;
 	case _PAGE_CACHE_MODE_WB:
 		memtype_flags = _PGMT_WB;
 		break;
-	case _PAGE_CACHE_MODE_WT:
 	case _PAGE_CACHE_MODE_WP:
+	default:
 		pr_err("set_page_memtype: unsupported cachemode %d\n", memtype);
 		BUG();
-	default:
-		memtype_flags = _PGMT_DEFAULT;
-		break;
 	}
 
 	do {
diff --git a/arch/x86/mm/pat.c b/arch/x86/mm/pat.c
index 648b885..4f61483 100644
--- a/arch/x86/mm/pat.c
+++ b/arch/x86/mm/pat.c
@@ -311,8 +311,8 @@ static int pat_pagerange_is_ram(resource_size_t start, resource_size_t end)
 
 /*
  * For RAM pages, we use page flags to mark the pages with appropriate type.
- * The page flags are currently limited to three types, WB, WC and UC. Hence,
- * any request to WT or WP will fail with -EINVAL.
+ * The page flags are limited to four memtypes, WB (default), WC, WT and UC.
+ * A new memtype can only be set to the default memtype WB.
  * Here we do two pass:
  * - Find the memtype of all the pages in the range, look for any conflicts
  * - In case of no conflicts, set the new memtype for pages in the range
@@ -324,8 +324,7 @@ static int reserve_ram_pages_type(u64 start, u64 end,
 	struct page *page;
 	u64 pfn;
 
-	if ((req_type == _PAGE_CACHE_MODE_WT) ||
-	    (req_type == _PAGE_CACHE_MODE_WP)) {
+	if (req_type == _PAGE_CACHE_MODE_WP) {
 		if (new_type)
 			*new_type = _PAGE_CACHE_MODE_UC_MINUS;
 		return -EINVAL;
@@ -342,7 +341,7 @@ static int reserve_ram_pages_type(u64 start, u64 end,
 
 		page = pfn_to_page(pfn);
 		type = get_page_memtype(page);
-		if (type != -1) {
+		if (type != _PAGE_CACHE_MODE_WB) {
 			pr_info("reserve_ram_pages_type failed [mem %#010Lx-%#010Lx], track 0x%x, req 0x%x\n",
 				start, end - 1, type, req_type);
 			if (new_type)
@@ -369,7 +368,7 @@ static int free_ram_pages_type(u64 start, u64 end)
 
 	for (pfn = (start >> PAGE_SHIFT); pfn < (end >> PAGE_SHIFT); ++pfn) {
 		page = pfn_to_page(pfn);
-		set_page_memtype(page, -1);
+		set_page_memtype(page, _PAGE_CACHE_MODE_WB);
 	}
 	return 0;
 }
@@ -498,7 +497,7 @@ int free_memtype(u64 start, u64 end)
  * @paddr: physical address of which memory type needs to be looked up
  *
  * Returns _PAGE_CACHE_MODE_WB, _PAGE_CACHE_MODE_WC, _PAGE_CACHE_MODE_UC_MINUS
- * or _PAGE_CACHE_MODE_UC
+ * or _PAGE_CACHE_MODE_WT.
  */
 static enum page_cache_mode lookup_memtype(u64 paddr)
 {
@@ -512,13 +511,6 @@ static enum page_cache_mode lookup_memtype(u64 paddr)
 		struct page *page;
 		page = pfn_to_page(paddr >> PAGE_SHIFT);
 		rettype = get_page_memtype(page);
-		/*
-		 * -1 from get_page_memtype() implies RAM page is in its
-		 * default state and not reserved, and hence of type WB
-		 */
-		if (rettype == -1)
-			rettype = _PAGE_CACHE_MODE_WB;
-
 		return rettype;
 	}
 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
