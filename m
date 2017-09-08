Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id 60A796B04CA
	for <linux-mm@kvack.org>; Fri,  8 Sep 2017 17:56:25 -0400 (EDT)
Received: by mail-pf0-f200.google.com with SMTP id q75so6621211pfl.1
        for <linux-mm@kvack.org>; Fri, 08 Sep 2017 14:56:25 -0700 (PDT)
Received: from mga02.intel.com (mga02.intel.com. [134.134.136.20])
        by mx.google.com with ESMTPS id h63si2074838pgc.833.2017.09.08.14.56.23
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 08 Sep 2017 14:56:24 -0700 (PDT)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: [PATCH 2/2] mm, x86: Fix performance regression in get_user_pages_fast()
Date: Sat,  9 Sep 2017 00:56:03 +0300
Message-Id: <20170908215603.9189-3-kirill.shutemov@linux.intel.com>
In-Reply-To: <20170908215603.9189-1-kirill.shutemov@linux.intel.com>
References: <20170908215603.9189-1-kirill.shutemov@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, Ingo Molnar <mingo@kernel.org>
Cc: x86@kernel.org, Thorsten Leemhuis <regressions@leemhuis.info>, Jonathan Corbet <corbet@lwn.net>, Huang Ying <ying.huang@intel.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

0-day found[1] performance regression that was tracked down to switching
x86 to generic get_user_pages_fast().

The regression was caused by the fact that we now use local_irq_save() +
local_irq_restore() in get_user_pages_fast() to disable interrupts.
In x86 implementation local_irq_disable() + local_irq_enable() was used.

The fix is to make get_user_pages_fast() use local_irq_disable(),
leaving local_irq_save() for __get_user_pages_fast() that can be called
with interrupts disabled.

Numbers for pinning a gigabyte of memory, one page a time, 20 repeats:

Before
	Average: 14911.15 us, Standard Deviation: 449.26 us
After
	Average: 10761.6 us, Standard Deviation: 181.67 us

[1] http://lkml.kernel.org/r/20170710024020.GA26389@yexl-desktop

Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
Fixes: e585513b76f7 ("x86/mm/gup: Switch GUP to the generic get_user_page_fast() implementation")
---
 mm/gup.c | 97 ++++++++++++++++++++++++++++++++++++++--------------------------
 1 file changed, 58 insertions(+), 39 deletions(-)

diff --git a/mm/gup.c b/mm/gup.c
index 33d651deeae2..c6bf94bc814c 100644
--- a/mm/gup.c
+++ b/mm/gup.c
@@ -1618,6 +1618,47 @@ static int gup_p4d_range(pgd_t pgd, unsigned long addr, unsigned long end,
 	return 1;
 }
 
+static void gup_pgd_range(unsigned long addr, unsigned long end,
+		int write, struct page **pages, int *nr)
+{
+	unsigned long next;
+	pgd_t *pgdp;
+
+	pgdp = pgd_offset(current->mm, addr);
+	do {
+		pgd_t pgd = READ_ONCE(*pgdp);
+
+		next = pgd_addr_end(addr, end);
+		if (pgd_none(pgd))
+			return;
+		if (unlikely(pgd_huge(pgd))) {
+			if (!gup_huge_pgd(pgd, pgdp, addr, next, write,
+					  pages, nr))
+				return;
+		} else if (unlikely(is_hugepd(__hugepd(pgd_val(pgd))))) {
+			if (!gup_huge_pd(__hugepd(pgd_val(pgd)), addr,
+					 PGDIR_SHIFT, next, write, pages, nr))
+				return;
+		} else if (!gup_p4d_range(pgd, addr, next, write, pages, nr))
+			return;
+	} while (pgdp++, addr = next, addr != end);
+}
+
+#ifndef gup_fast_permitted
+/*
+ * Check if it's allowed to use __get_user_pages_fast() for the range, or
+ * we need to fall back to the slow version:
+ */
+bool gup_fast_permitted(unsigned long start, int nr_pages, int write)
+{
+	unsigned long len, end;
+
+	len = (unsigned long) nr_pages << PAGE_SHIFT;
+	end = start + len;
+	return end >= start;
+}
+#endif
+
 /*
  * Like get_user_pages_fast() except it's IRQ-safe in that it won't fall back to
  * the regular GUP. It will only return non-negative values.
@@ -1625,10 +1666,8 @@ static int gup_p4d_range(pgd_t pgd, unsigned long addr, unsigned long end,
 int __get_user_pages_fast(unsigned long start, int nr_pages, int write,
 			  struct page **pages)
 {
-	struct mm_struct *mm = current->mm;
 	unsigned long addr, len, end;
-	unsigned long next, flags;
-	pgd_t *pgdp;
+	unsigned long flags;
 	int nr = 0;
 
 	start &= PAGE_MASK;
@@ -1652,45 +1691,15 @@ int __get_user_pages_fast(unsigned long start, int nr_pages, int write,
 	 * block IPIs that come from THPs splitting.
 	 */
 
-	local_irq_save(flags);
-	pgdp = pgd_offset(mm, addr);
-	do {
-		pgd_t pgd = READ_ONCE(*pgdp);
-
-		next = pgd_addr_end(addr, end);
-		if (pgd_none(pgd))
-			break;
-		if (unlikely(pgd_huge(pgd))) {
-			if (!gup_huge_pgd(pgd, pgdp, addr, next, write,
-					  pages, &nr))
-				break;
-		} else if (unlikely(is_hugepd(__hugepd(pgd_val(pgd))))) {
-			if (!gup_huge_pd(__hugepd(pgd_val(pgd)), addr,
-					 PGDIR_SHIFT, next, write, pages, &nr))
-				break;
-		} else if (!gup_p4d_range(pgd, addr, next, write, pages, &nr))
-			break;
-	} while (pgdp++, addr = next, addr != end);
-	local_irq_restore(flags);
+	if (gup_fast_permitted(start, nr_pages, write)) {
+		local_irq_save(flags);
+		gup_pgd_range(addr, end, write, pages, &nr);
+		local_irq_restore(flags);
+	}
 
 	return nr;
 }
 
-#ifndef gup_fast_permitted
-/*
- * Check if it's allowed to use __get_user_pages_fast() for the range, or
- * we need to fall back to the slow version:
- */
-bool gup_fast_permitted(unsigned long start, int nr_pages, int write)
-{
-	unsigned long len, end;
-
-	len = (unsigned long) nr_pages << PAGE_SHIFT;
-	end = start + len;
-	return end >= start;
-}
-#endif
-
 /**
  * get_user_pages_fast() - pin user pages in memory
  * @start:	starting user address
@@ -1710,12 +1719,22 @@ bool gup_fast_permitted(unsigned long start, int nr_pages, int write)
 int get_user_pages_fast(unsigned long start, int nr_pages, int write,
 			struct page **pages)
 {
+	unsigned long addr, len, end;
 	int nr = 0, ret = 0;
 
 	start &= PAGE_MASK;
+	addr = start;
+	len = (unsigned long) nr_pages << PAGE_SHIFT;
+	end = start + len;
+
+	if (unlikely(!access_ok(write ? VERIFY_WRITE : VERIFY_READ,
+					(void __user *)start, len)))
+		return 0;
 
 	if (gup_fast_permitted(start, nr_pages, write)) {
-		nr = __get_user_pages_fast(start, nr_pages, write, pages);
+		local_irq_disable();
+		gup_pgd_range(addr, end, write, pages, &nr);
+		local_irq_enable();
 		ret = nr;
 	}
 
-- 
2.14.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
