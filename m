Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f51.google.com (mail-pa0-f51.google.com [209.85.220.51])
	by kanga.kvack.org (Postfix) with ESMTP id 52E2C6B0078
	for <linux-mm@kvack.org>; Sun,  7 Jun 2015 13:43:12 -0400 (EDT)
Received: by padev16 with SMTP id ev16so22914038pad.0
        for <linux-mm@kvack.org>; Sun, 07 Jun 2015 10:43:12 -0700 (PDT)
Received: from terminus.zytor.com (terminus.zytor.com. [2001:1868:205::10])
        by mx.google.com with ESMTPS id 13si360739pdb.141.2015.06.07.10.43.11
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 07 Jun 2015 10:43:11 -0700 (PDT)
Date: Sun, 7 Jun 2015 10:42:38 -0700
From: tip-bot for Toshi Kani <tipbot@zytor.com>
Message-ID: <tip-35a5a10411d87e24b46a7a9dda8d08ef9961b783@git.kernel.org>
Reply-To: bp@suse.de, hpa@zytor.com, linux-mm@kvack.org, mingo@kernel.org,
        tglx@linutronix.de, linux-kernel@vger.kernel.org, peterz@infradead.org,
        mcgrof@suse.com, luto@amacapital.net, akpm@linux-foundation.org,
        toshi.kani@hp.com, torvalds@linux-foundation.org
In-Reply-To: <1433436928-31903-12-git-send-email-bp@alien8.de>
References: <1433436928-31903-12-git-send-email-bp@alien8.de>
Subject: [tip:x86/mm] x86/mm/pat: Extend set_page_memtype()
  to support Write-Through type
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
Content-Type: text/plain; charset=UTF-8
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-tip-commits@vger.kernel.org
Cc: bp@suse.de, hpa@zytor.com, linux-mm@kvack.org, mingo@kernel.org, linux-kernel@vger.kernel.org, tglx@linutronix.de, peterz@infradead.org, mcgrof@suse.com, akpm@linux-foundation.org, luto@amacapital.net, torvalds@linux-foundation.org, toshi.kani@hp.com

Commit-ID:  35a5a10411d87e24b46a7a9dda8d08ef9961b783
Gitweb:     http://git.kernel.org/tip/35a5a10411d87e24b46a7a9dda8d08ef9961b783
Author:     Toshi Kani <toshi.kani@hp.com>
AuthorDate: Thu, 4 Jun 2015 18:55:19 +0200
Committer:  Ingo Molnar <mingo@kernel.org>
CommitDate: Sun, 7 Jun 2015 15:28:59 +0200

x86/mm/pat: Extend set_page_memtype() to support Write-Through type

As set_memory_wb() calls free_ram_pages_type(), which then calls
set_page_memtype() with -1, _PGMT_DEFAULT is used for tracking
the WB type. _PGMT_WB is defined but unused. Thus, rename
_PGMT_DEFAULT to _PGMT_WB to clarify the usage, and release the
slot used by _PGMT_WB.

Furthermore, change free_ram_pages_type() to call
set_page_memtype() with _PGMT_WB, and get_page_memtype() to
return _PAGE_CACHE_MODE_WB for _PGMT_WB.

Then, define _PGMT_WT in the freed slot. This allows
set_page_memtype() to track the WT type.

Signed-off-by: Toshi Kani <toshi.kani@hp.com>
Signed-off-by: Borislav Petkov <bp@suse.de>
Cc: Andrew Morton <akpm@linux-foundation.org>
Cc: Andy Lutomirski <luto@amacapital.net>
Cc: Elliott@hp.com
Cc: H. Peter Anvin <hpa@zytor.com>
Cc: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Luis R. Rodriguez <mcgrof@suse.com>
Cc: Peter Zijlstra <peterz@infradead.org>
Cc: Thomas Gleixner <tglx@linutronix.de>
Cc: arnd@arndb.de
Cc: hch@lst.de
Cc: hmh@hmh.eng.br
Cc: jgross@suse.com
Cc: konrad.wilk@oracle.com
Cc: linux-mm <linux-mm@kvack.org>
Cc: linux-nvdimm@lists.01.org
Cc: stefan.bader@canonical.com
Cc: yigal@plexistor.com
Link: http://lkml.kernel.org/r/1433436928-31903-12-git-send-email-bp@alien8.de
Signed-off-by: Ingo Molnar <mingo@kernel.org>
---
 arch/x86/mm/pat.c | 59 +++++++++++++++++++++++++++----------------------------
 1 file changed, 29 insertions(+), 30 deletions(-)

diff --git a/arch/x86/mm/pat.c b/arch/x86/mm/pat.c
index 076187c..188e3e0 100644
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
 
@@ -401,8 +406,10 @@ static int pat_pagerange_is_ram(resource_size_t start, resource_size_t end)
 
 /*
  * For RAM pages, we use page flags to mark the pages with appropriate type.
- * The page flags are limited to three types, WB, WC and UC-. WT and WP requests
- * fail with -EINVAL, and UC gets redirected to UC-.
+ * The page flags are limited to four types, WB (default), WC, WT and UC-.
+ * WP request fails with -EINVAL, and UC gets redirected to UC-.  Setting
+ * a new memory type is only allowed for a page mapped with the default WB
+ * type.
  *
  * Here we do two passes:
  * - Find the memtype of all the pages in the range, look for any conflicts.
@@ -415,8 +422,7 @@ static int reserve_ram_pages_type(u64 start, u64 end,
 	struct page *page;
 	u64 pfn;
 
-	if ((req_type == _PAGE_CACHE_MODE_WT) ||
-	    (req_type == _PAGE_CACHE_MODE_WP)) {
+	if (req_type == _PAGE_CACHE_MODE_WP) {
 		if (new_type)
 			*new_type = _PAGE_CACHE_MODE_UC_MINUS;
 		return -EINVAL;
@@ -433,7 +439,7 @@ static int reserve_ram_pages_type(u64 start, u64 end,
 
 		page = pfn_to_page(pfn);
 		type = get_page_memtype(page);
-		if (type != -1) {
+		if (type != _PAGE_CACHE_MODE_WB) {
 			pr_info("x86/PAT: reserve_ram_pages_type failed [mem %#010Lx-%#010Lx], track 0x%x, req 0x%x\n",
 				start, end - 1, type, req_type);
 			if (new_type)
@@ -460,7 +466,7 @@ static int free_ram_pages_type(u64 start, u64 end)
 
 	for (pfn = (start >> PAGE_SHIFT); pfn < (end >> PAGE_SHIFT); ++pfn) {
 		page = pfn_to_page(pfn);
-		set_page_memtype(page, -1);
+		set_page_memtype(page, _PAGE_CACHE_MODE_WB);
 	}
 	return 0;
 }
@@ -601,7 +607,7 @@ int free_memtype(u64 start, u64 end)
  * Only to be called when PAT is enabled
  *
  * Returns _PAGE_CACHE_MODE_WB, _PAGE_CACHE_MODE_WC, _PAGE_CACHE_MODE_UC_MINUS
- * or _PAGE_CACHE_MODE_UC
+ * or _PAGE_CACHE_MODE_WT.
  */
 static enum page_cache_mode lookup_memtype(u64 paddr)
 {
@@ -613,16 +619,9 @@ static enum page_cache_mode lookup_memtype(u64 paddr)
 
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
