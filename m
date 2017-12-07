Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f69.google.com (mail-wm0-f69.google.com [74.125.82.69])
	by kanga.kvack.org (Postfix) with ESMTP id E81626B0253
	for <linux-mm@kvack.org>; Thu,  7 Dec 2017 08:12:33 -0500 (EST)
Received: by mail-wm0-f69.google.com with SMTP id b82so3385015wmd.5
        for <linux-mm@kvack.org>; Thu, 07 Dec 2017 05:12:33 -0800 (PST)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id p14si4002674wrd.35.2017.12.07.05.12.31
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 07 Dec 2017 05:12:32 -0800 (PST)
From: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Subject: [PATCH 4.14 61/75] mm, x86/mm: Fix performance regression in get_user_pages_fast()
Date: Thu,  7 Dec 2017 14:08:23 +0100
Message-Id: <20171207130821.277841888@linuxfoundation.org>
In-Reply-To: <20171207130818.742746317@linuxfoundation.org>
References: <20171207130818.742746317@linuxfoundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, stable@vger.kernel.org, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Andrew Morton <akpm@linux-foundation.org>, Huang Ying <ying.huang@intel.com>, Jonathan Corbet <corbet@lwn.net>, Linus Torvalds <torvalds@linux-foundation.org>, Peter Zijlstra <peterz@infradead.org>, Thomas Gleixner <tglx@linutronix.de>, Thorsten Leemhuis <regressions@leemhuis.info>, linux-mm@kvack.org, Ingo Molnar <mingo@kernel.org>, Sasha Levin <alexander.levin@verizon.com>

4.14-stable review patch.  If anyone has any objections, please let me know.

------------------

From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>


[ Upstream commit 5b65c4677a57a1d4414212f9995aa0e46a21ff80 ]

The 0-day test bot found a performance regression that was tracked down to
switching x86 to the generic get_user_pages_fast() implementation:

  http://lkml.kernel.org/r/20170710024020.GA26389@yexl-desktop

The regression was caused by the fact that we now use local_irq_save() +
local_irq_restore() in get_user_pages_fast() to disable interrupts.
In x86 implementation local_irq_disable() + local_irq_enable() was used.

The fix is to make get_user_pages_fast() use local_irq_disable(),
leaving local_irq_save() for __get_user_pages_fast() that can be called
with interrupts disabled.

Numbers for pinning a gigabyte of memory, one page a time, 20 repeats:

  Before:  Average: 14.91 ms, stddev: 0.45 ms
  After:   Average: 10.76 ms, stddev: 0.18 ms

Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
Cc: Andrew Morton <akpm@linux-foundation.org>
Cc: Huang Ying <ying.huang@intel.com>
Cc: Jonathan Corbet <corbet@lwn.net>
Cc: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Peter Zijlstra <peterz@infradead.org>
Cc: Thomas Gleixner <tglx@linutronix.de>
Cc: Thorsten Leemhuis <regressions@leemhuis.info>
Cc: linux-mm@kvack.org
Fixes: e585513b76f7 ("x86/mm/gup: Switch GUP to the generic get_user_page_fast() implementation")
Link: http://lkml.kernel.org/r/20170908215603.9189-3-kirill.shutemov@linux.intel.com
Signed-off-by: Ingo Molnar <mingo@kernel.org>
Signed-off-by: Sasha Levin <alexander.levin@verizon.com>
Signed-off-by: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
---
 mm/gup.c |   97 +++++++++++++++++++++++++++++++++++++--------------------------
 1 file changed, 58 insertions(+), 39 deletions(-)

--- a/mm/gup.c
+++ b/mm/gup.c
@@ -1707,6 +1707,47 @@ static int gup_p4d_range(pgd_t pgd, unsi
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
@@ -1714,10 +1755,8 @@ static int gup_p4d_range(pgd_t pgd, unsi
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
@@ -1741,45 +1780,15 @@ int __get_user_pages_fast(unsigned long
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
@@ -1799,12 +1808,22 @@ bool gup_fast_permitted(unsigned long st
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
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
