Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f197.google.com (mail-qt0-f197.google.com [209.85.216.197])
	by kanga.kvack.org (Postfix) with ESMTP id 3F5636B026D
	for <linux-mm@kvack.org>; Wed, 22 Nov 2017 17:28:06 -0500 (EST)
Received: by mail-qt0-f197.google.com with SMTP id k23so8886827qtc.14
        for <linux-mm@kvack.org>; Wed, 22 Nov 2017 14:28:06 -0800 (PST)
Received: from omzsmtpe03.verizonbusiness.com (omzsmtpe03.verizonbusiness.com. [199.249.25.208])
        by mx.google.com with ESMTPS id j4si4633406qte.331.2017.11.22.14.28.05
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 22 Nov 2017 14:28:05 -0800 (PST)
From: alexander.levin@verizon.com
Subject: [PATCH AUTOSEL for 4.14 49/51] mm, x86/mm: Fix performance regression
 in get_user_pages_fast()
Date: Wed, 22 Nov 2017 22:25:48 +0000
Message-ID: <20171122222526.20021-49-alexander.levin@verizon.com>
References: <20171122222526.20021-1-alexander.levin@verizon.com>
In-Reply-To: <20171122222526.20021-1-alexander.levin@verizon.com>
Content-Language: en-US
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "stable@vger.kernel.org" <stable@vger.kernel.org>
Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Andrew Morton <akpm@linux-foundation.org>, Huang Ying <ying.huang@intel.com>, Jonathan
 Corbet <corbet@lwn.net>, Linus Torvalds <torvalds@linux-foundation.org>, Peter Zijlstra <peterz@infradead.org>, Thomas Gleixner <tglx@linutronix.de>, Thorsten Leemhuis <regressions@leemhuis.info>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Ingo Molnar <mingo@kernel.org>, alexander.levin@verizon.com

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
Fixes: e585513b76f7 ("x86/mm/gup: Switch GUP to the generic get_user_page_f=
ast() implementation")
Link: http://lkml.kernel.org/r/20170908215603.9189-3-kirill.shutemov@linux.=
intel.com
Signed-off-by: Ingo Molnar <mingo@kernel.org>
Signed-off-by: Sasha Levin <alexander.levin@verizon.com>
---
 mm/gup.c | 97 ++++++++++++++++++++++++++++++++++++++----------------------=
----
 1 file changed, 58 insertions(+), 39 deletions(-)

diff --git a/mm/gup.c b/mm/gup.c
index b2b4d4263768..dfcde13f289a 100644
--- a/mm/gup.c
+++ b/mm/gup.c
@@ -1643,6 +1643,47 @@ static int gup_p4d_range(pgd_t pgd, unsigned long ad=
dr, unsigned long end,
 	return 1;
 }
=20
+static void gup_pgd_range(unsigned long addr, unsigned long end,
+		int write, struct page **pages, int *nr)
+{
+	unsigned long next;
+	pgd_t *pgdp;
+
+	pgdp =3D pgd_offset(current->mm, addr);
+	do {
+		pgd_t pgd =3D READ_ONCE(*pgdp);
+
+		next =3D pgd_addr_end(addr, end);
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
+	} while (pgdp++, addr =3D next, addr !=3D end);
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
+	len =3D (unsigned long) nr_pages << PAGE_SHIFT;
+	end =3D start + len;
+	return end >=3D start;
+}
+#endif
+
 /*
  * Like get_user_pages_fast() except it's IRQ-safe in that it won't fall b=
ack to
  * the regular GUP. It will only return non-negative values.
@@ -1650,10 +1691,8 @@ static int gup_p4d_range(pgd_t pgd, unsigned long ad=
dr, unsigned long end,
 int __get_user_pages_fast(unsigned long start, int nr_pages, int write,
 			  struct page **pages)
 {
-	struct mm_struct *mm =3D current->mm;
 	unsigned long addr, len, end;
-	unsigned long next, flags;
-	pgd_t *pgdp;
+	unsigned long flags;
 	int nr =3D 0;
=20
 	start &=3D PAGE_MASK;
@@ -1677,45 +1716,15 @@ int __get_user_pages_fast(unsigned long start, int =
nr_pages, int write,
 	 * block IPIs that come from THPs splitting.
 	 */
=20
-	local_irq_save(flags);
-	pgdp =3D pgd_offset(mm, addr);
-	do {
-		pgd_t pgd =3D READ_ONCE(*pgdp);
-
-		next =3D pgd_addr_end(addr, end);
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
-	} while (pgdp++, addr =3D next, addr !=3D end);
-	local_irq_restore(flags);
+	if (gup_fast_permitted(start, nr_pages, write)) {
+		local_irq_save(flags);
+		gup_pgd_range(addr, end, write, pages, &nr);
+		local_irq_restore(flags);
+	}
=20
 	return nr;
 }
=20
-#ifndef gup_fast_permitted
-/*
- * Check if it's allowed to use __get_user_pages_fast() for the range, or
- * we need to fall back to the slow version:
- */
-bool gup_fast_permitted(unsigned long start, int nr_pages, int write)
-{
-	unsigned long len, end;
-
-	len =3D (unsigned long) nr_pages << PAGE_SHIFT;
-	end =3D start + len;
-	return end >=3D start;
-}
-#endif
-
 /**
  * get_user_pages_fast() - pin user pages in memory
  * @start:	starting user address
@@ -1735,12 +1744,22 @@ bool gup_fast_permitted(unsigned long start, int nr=
_pages, int write)
 int get_user_pages_fast(unsigned long start, int nr_pages, int write,
 			struct page **pages)
 {
+	unsigned long addr, len, end;
 	int nr =3D 0, ret =3D 0;
=20
 	start &=3D PAGE_MASK;
+	addr =3D start;
+	len =3D (unsigned long) nr_pages << PAGE_SHIFT;
+	end =3D start + len;
+
+	if (unlikely(!access_ok(write ? VERIFY_WRITE : VERIFY_READ,
+					(void __user *)start, len)))
+		return 0;
=20
 	if (gup_fast_permitted(start, nr_pages, write)) {
-		nr =3D __get_user_pages_fast(start, nr_pages, write, pages);
+		local_irq_disable();
+		gup_pgd_range(addr, end, write, pages, &nr);
+		local_irq_enable();
 		ret =3D nr;
 	}
=20
--=20
2.11.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
