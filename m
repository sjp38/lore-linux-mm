Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f49.google.com (mail-oi0-f49.google.com [209.85.218.49])
	by kanga.kvack.org (Postfix) with ESMTP id 5F3976B0075
	for <linux-mm@kvack.org>; Mon,  1 Jun 2015 15:56:32 -0400 (EDT)
Received: by oihb142 with SMTP id b142so109765582oih.3
        for <linux-mm@kvack.org>; Mon, 01 Jun 2015 12:56:32 -0700 (PDT)
Received: from g4t3427.houston.hp.com (g4t3427.houston.hp.com. [15.201.208.55])
        by mx.google.com with ESMTPS id w186si47960oia.91.2015.06.01.12.56.30
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 01 Jun 2015 12:56:30 -0700 (PDT)
From: Toshi Kani <toshi.kani@hp.com>
Subject: [PATCH v12 08/10] x86, mm, asm: Add WT support to set_page_memtype()
Date: Mon,  1 Jun 2015 13:36:31 -0600
Message-Id: <1433187393-22688-9-git-send-email-toshi.kani@hp.com>
In-Reply-To: <1433187393-22688-1-git-send-email-toshi.kani@hp.com>
References: <1433187393-22688-1-git-send-email-toshi.kani@hp.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: bp@alien8.de, hpa@zytor.com, tglx@linutronix.de, mingo@redhat.com, akpm@linux-foundation.org, arnd@arndb.de
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, x86@kernel.org, linux-nvdimm@lists.01.org, jgross@suse.com, stefan.bader@canonical.com, luto@amacapital.net, hmh@hmh.eng.br, yigal@plexistor.com, konrad.wilk@oracle.com, Elliott@hp.com, mcgrof@suse.com, hch@lst.de, Toshi Kani <toshi.kani@hp.com>

As set_memory_wb() calls free_ram_pages_type(), which then calls
set_page_memtype() with -1, _PGMT_DEFAULT is used for tracking
the WB type.  _PGMT_WB is defined but unused.  Hence, this patch
renames _PGMT_DEFAULT to _PGMT_WB to clarify the usage, and
releases the slot used by _PGMT_WB before.  free_ram_pages_type()
is changed to call set_page_memtype() with _PGMT_WB, and
get_page_memtype() returns _PAGE_CACHE_MODE_WB for _PGMT_WB.

This patch then defines _PGMT_WT to the released slot.  This enables
set_page_memtype() to track the WT type.

Signed-off-by: Toshi Kani <toshi.kani@hp.com>
---
 arch/x86/mm/pat.c |   60 +++++++++++++++++++++++++++--------------------------
 1 file changed, 30 insertions(+), 30 deletions(-)

diff --git a/arch/x86/mm/pat.c b/arch/x86/mm/pat.c
index a89bcde..2bb73ce 100644
--- a/arch/x86/mm/pat.c
+++ b/arch/x86/mm/pat.c
@@ -70,18 +70,22 @@ __setup("debugpat", pat_debug_setup);
 
 #ifdef CONFIG_X86_PAT
 /*
- * X86 PAT uses page flags WC and Uncached together to keep track of
- * memory type of pages that have backing page struct. X86 PAT supports 3
- * different memory types, _PAGE_CACHE_MODE_WB, _PAGE_CACHE_MODE_WC and
- * _PAGE_CACHE_MODE_UC_MINUS and fourth state where page's memory type has not
- * been changed from its default (value of -1 used to denote this).
- * Note we do not support _PAGE_CACHE_MODE_UC here.
+ * X86 PAT uses page flags arch_1 and uncached together to keep track of
+ * memory type of pages that have backing page struct.
+ *
+ * X86 PAT supports 4 different memory types:
+ *  - _PAGE_CACHE_MODE_WB
+ *  - _PAGE_CACHE_MODE_WC
+ *  - _PAGE_CACHE_MODE_UC_MINUS
+ *  - _PAGE_CACHE_MODE_WT
+ *
+ * _PAGE_CACHE_MODE_WB is the default type.
  */
 
-#define _PGMT_DEFAULT		0
+#define _PGMT_WB		0
 #define _PGMT_WC		(1UL << PG_arch_1)
 #define _PGMT_UC_MINUS		(1UL << PG_uncached)
-#define _PGMT_WB		(1UL << PG_uncached | 1UL << PG_arch_1)
+#define _PGMT_WT		(1UL << PG_uncached | 1UL << PG_arch_1)
 #define _PGMT_MASK		(1UL << PG_uncached | 1UL << PG_arch_1)
 #define _PGMT_CLEAR_MASK	(~_PGMT_MASK)
 
@@ -89,14 +93,14 @@ static inline enum page_cache_mode get_page_memtype(struct page *pg)
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
@@ -113,11 +117,12 @@ static inline void set_page_memtype(struct page *pg,
 	case _PAGE_CACHE_MODE_UC_MINUS:
 		memtype_flags = _PGMT_UC_MINUS;
 		break;
-	case _PAGE_CACHE_MODE_WB:
-		memtype_flags = _PGMT_WB;
+	case _PAGE_CACHE_MODE_WT:
+		memtype_flags = _PGMT_WT;
 		break;
+	case _PAGE_CACHE_MODE_WB:
 	default:
-		memtype_flags = _PGMT_DEFAULT;
+		memtype_flags = _PGMT_WB;
 		break;
 	}
 
@@ -401,8 +406,11 @@ static int pat_pagerange_is_ram(resource_size_t start, resource_size_t end)
 
 /*
  * For RAM pages, we use page flags to mark the pages with appropriate type.
- * The page flags are limited to three types, WB, WC and UC-.
- * WT and WP requests fail with -EINVAL, and UC gets redirected to UC-.
+ * The page flags are limited to four types, WB (default), WC, WT and UC-.
+ * WP request fails with -EINVAL, and UC gets redirected to UC-.  Setting
+ * a new memory type is only allowed to a page mapped with the default WB
+ * type.
+ *
  * Here we do two pass:
  * - Find the memtype of all the pages in the range, look for any conflicts
  * - In case of no conflicts, set the new memtype for pages in the range
@@ -414,8 +422,7 @@ static int reserve_ram_pages_type(u64 start, u64 end,
 	struct page *page;
 	u64 pfn;
 
-	if ((req_type == _PAGE_CACHE_MODE_WT) ||
-	    (req_type == _PAGE_CACHE_MODE_WP)) {
+	if (req_type == _PAGE_CACHE_MODE_WP) {
 		if (new_type)
 			*new_type = _PAGE_CACHE_MODE_UC_MINUS;
 		return -EINVAL;
@@ -432,7 +439,7 @@ static int reserve_ram_pages_type(u64 start, u64 end,
 
 		page = pfn_to_page(pfn);
 		type = get_page_memtype(page);
-		if (type != -1) {
+		if (type != _PAGE_CACHE_MODE_WB) {
 			pr_info("x86/PAT: reserve_ram_pages_type failed [mem %#010Lx-%#010Lx], track 0x%x, req 0x%x\n",
 				start, end - 1, type, req_type);
 			if (new_type)
@@ -459,7 +466,7 @@ static int free_ram_pages_type(u64 start, u64 end)
 
 	for (pfn = (start >> PAGE_SHIFT); pfn < (end >> PAGE_SHIFT); ++pfn) {
 		page = pfn_to_page(pfn);
-		set_page_memtype(page, -1);
+		set_page_memtype(page, _PAGE_CACHE_MODE_WB);
 	}
 	return 0;
 }
@@ -600,7 +607,7 @@ int free_memtype(u64 start, u64 end)
  * Only to be called when PAT is enabled
  *
  * Returns _PAGE_CACHE_MODE_WB, _PAGE_CACHE_MODE_WC, _PAGE_CACHE_MODE_UC_MINUS
- * or _PAGE_CACHE_MODE_UC
+ * or _PAGE_CACHE_MODE_WT.
  */
 static enum page_cache_mode lookup_memtype(u64 paddr)
 {
@@ -612,16 +619,9 @@ static enum page_cache_mode lookup_memtype(u64 paddr)
 
 	if (pat_pagerange_is_ram(paddr, paddr + PAGE_SIZE)) {
 		struct page *page;
-		page = pfn_to_page(paddr >> PAGE_SHIFT);
-		rettype = get_page_memtype(page);
-		/*
-		 * -1 from get_page_memtype() implies RAM page is in its
-		 * default state and not reserved, and hence of type WB
-		 */
-		if (rettype == -1)
-			rettype = _PAGE_CACHE_MODE_WB;
 
-		return rettype;
+		page = pfn_to_page(paddr >> PAGE_SHIFT);
+		return get_page_memtype(page);
 	}
 
 	spin_lock(&memtype_lock);

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
