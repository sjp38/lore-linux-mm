Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ob0-f178.google.com (mail-ob0-f178.google.com [209.85.214.178])
	by kanga.kvack.org (Postfix) with ESMTP id D45136B0071
	for <linux-mm@kvack.org>; Tue, 12 May 2015 05:48:03 -0400 (EDT)
Received: by obblk2 with SMTP id lk2so1253863obb.0
        for <linux-mm@kvack.org>; Tue, 12 May 2015 02:48:03 -0700 (PDT)
Received: from tyo202.gate.nec.co.jp (TYO202.gate.nec.co.jp. [210.143.35.52])
        by mx.google.com with ESMTPS id n5si8547611oig.130.2015.05.12.02.48.00
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Tue, 12 May 2015 02:48:01 -0700 (PDT)
From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Subject: [PATCH 2/4] mm/memory-failure: introduce get_hwpoison_page() for
 consistent refcount handling
Date: Tue, 12 May 2015 09:46:47 +0000
Message-ID: <1431423998-1939-3-git-send-email-n-horiguchi@ah.jp.nec.com>
References: <1431423998-1939-1-git-send-email-n-horiguchi@ah.jp.nec.com>
In-Reply-To: <1431423998-1939-1-git-send-email-n-horiguchi@ah.jp.nec.com>
Content-Language: ja-JP
Content-Type: text/plain; charset="iso-2022-jp"
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Andi Kleen <andi@firstfloor.org>
Cc: Tony Luck <tony.luck@intel.com>, "Kirill A. Shutemov" <kirill@shutemov.name>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Naoya Horiguchi <nao.horiguchi@gmail.com>

memory_failrue() can run in 2 different mode (specified by MF_COUNT_INCREAS=
ED)
in page refcount perspective. When MF_COUNT_INCREASED is set, memory_failru=
e()
assumes that the caller takes a refcount of the target page. And if cleared=
,
memory_failure() takes it in it's own.

In current code, however, refcounting is done differently in each caller. F=
or
example, madvise_hwpoison() uses get_user_pages_fast() and hwpoison_inject(=
)
uses get_page_unless_zero(). So this inconsistent refcounting causes refcou=
nt
failure especially for thp tail pages. Typical user visible effects are lik=
e
memory leak or VM_BUG_ON_PAGE(!page_count(page)) in isolate_lru_page().

To fix this refcounting issue, this patch introduces get_hwpoison_page() to
handle thp tail pages in the same manner for each caller of hwpoison code.

There's a non-trivial change around unpoisoning, which now returns immediat=
ely
for thp with "MCE: Memory failure is now running on %#lx\n" message. This i=
s
not right when split_huge_page() fails. So this patch also allows
unpoison_memory() to handle thp.

Signed-off-by: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
---
 include/linux/mm.h   |  1 +
 mm/hwpoison-inject.c |  4 ++--
 mm/memory-failure.c  | 50 ++++++++++++++++++++++++++++++++----------------=
--
 mm/swap.c            |  2 --
 4 files changed, 35 insertions(+), 22 deletions(-)

diff --git v4.1-rc3.orig/include/linux/mm.h v4.1-rc3/include/linux/mm.h
index 0632deaefba0..cbcf7b9d21af 100644
--- v4.1-rc3.orig/include/linux/mm.h
+++ v4.1-rc3/include/linux/mm.h
@@ -2146,6 +2146,7 @@ enum mf_flags {
 extern int memory_failure(unsigned long pfn, int trapno, int flags);
 extern void memory_failure_queue(unsigned long pfn, int trapno, int flags)=
;
 extern int unpoison_memory(unsigned long pfn);
+extern int get_hwpoison_page(struct page *page);
 extern int sysctl_memory_failure_early_kill;
 extern int sysctl_memory_failure_recovery;
 extern void shake_page(struct page *p, int access);
diff --git v4.1-rc3.orig/mm/hwpoison-inject.c v4.1-rc3/mm/hwpoison-inject.c
index 4ca5fe0042e1..bf73ac17dad4 100644
--- v4.1-rc3.orig/mm/hwpoison-inject.c
+++ v4.1-rc3/mm/hwpoison-inject.c
@@ -28,7 +28,7 @@ static int hwpoison_inject(void *data, u64 val)
 	/*
 	 * This implies unable to support free buddy pages.
 	 */
-	if (!get_page_unless_zero(hpage))
+	if (!get_hwpoison_page(p))
 		return 0;
=20
 	if (!hwpoison_filter_enable)
@@ -58,7 +58,7 @@ static int hwpoison_inject(void *data, u64 val)
 	pr_info("Injecting memory failure at pfn %#lx\n", pfn);
 	return memory_failure(pfn, 18, MF_COUNT_INCREASED);
 put_out:
-	put_page(hpage);
+	put_page(p);
 	return 0;
 }
=20
diff --git v4.1-rc3.orig/mm/memory-failure.c v4.1-rc3/mm/memory-failure.c
index 331c75b23ba2..6d4cc5442b1a 100644
--- v4.1-rc3.orig/mm/memory-failure.c
+++ v4.1-rc3/mm/memory-failure.c
@@ -885,6 +885,28 @@ static int page_action(struct page_state *ps, struct p=
age *p,
 }
=20
 /*
+ * Get refcount for memory error handling:
+ * - @page: raw page
+ */
+inline int get_hwpoison_page(struct page *page)
+{
+	struct page *head =3D compound_head(page);
+
+	if (PageHuge(head))
+		return get_page_unless_zero(head);
+	else if (PageTransHuge(head))
+		if (get_page_unless_zero(head)) {
+			if (PageTail(page))
+				get_page(page);
+			return 1;
+		} else {
+			return 0;
+		}
+	else
+		return get_page_unless_zero(page);
+}
+
+/*
  * Do all that is necessary to remove user space mappings. Unmap
  * the pages and send SIGBUS to the processes if the data was dirty.
  */
@@ -1066,8 +1088,7 @@ int memory_failure(unsigned long pfn, int trapno, int=
 flags)
 	 * In fact it's dangerous to directly bump up page count from 0,
 	 * that may make page_freeze_refs()/page_unfreeze_refs() mismatch.
 	 */
-	if (!(flags & MF_COUNT_INCREASED) &&
-		!get_page_unless_zero(hpage)) {
+	if (!(flags & MF_COUNT_INCREASED) && !get_hwpoison_page(p)) {
 		if (is_free_buddy_page(p)) {
 			action_result(pfn, MF_MSG_BUDDY, MF_DELAYED);
 			return 0;
@@ -1375,19 +1396,12 @@ int unpoison_memory(unsigned long pfn)
 		return 0;
 	}
=20
-	/*
-	 * unpoison_memory() can encounter thp only when the thp is being
-	 * worked by memory_failure() and the page lock is not held yet.
-	 * In such case, we yield to memory_failure() and make unpoison fail.
-	 */
-	if (!PageHuge(page) && PageTransHuge(page)) {
-		pr_info("MCE: Memory failure is now running on %#lx\n", pfn);
-			return 0;
-	}
-
-	nr_pages =3D 1 << compound_order(page);
+	if (PageHuge(page))
+		nr_pages =3D 1 << compound_order(page);
+	else
+		nr_pages =3D 1;
=20
-	if (!get_page_unless_zero(page)) {
+	if (!get_hwpoison_page(p)) {
 		/*
 		 * Since HWPoisoned hugepage should have non-zero refcount,
 		 * race between memory failure and unpoison seems to happen.
@@ -1411,7 +1425,7 @@ int unpoison_memory(unsigned long pfn)
 	 * the PG_hwpoison page will be caught and isolated on the entrance to
 	 * the free buddy page pool.
 	 */
-	if (TestClearPageHWPoison(page)) {
+	if (TestClearPageHWPoison(p)) {
 		pr_info("MCE: Software-unpoisoned page %#lx\n", pfn);
 		atomic_long_sub(nr_pages, &num_poisoned_pages);
 		freeit =3D 1;
@@ -1420,9 +1434,9 @@ int unpoison_memory(unsigned long pfn)
 	}
 	unlock_page(page);
=20
-	put_page(page);
+	put_page(p);
 	if (freeit && !(pfn =3D=3D my_zero_pfn(0) && page_count(p) =3D=3D 1))
-		put_page(page);
+		put_page(p);
=20
 	return 0;
 }
@@ -1455,7 +1469,7 @@ static int __get_any_page(struct page *p, unsigned lo=
ng pfn, int flags)
 	 * When the target page is a free hugepage, just remove it
 	 * from free hugepage list.
 	 */
-	if (!get_page_unless_zero(compound_head(p))) {
+	if (!get_hwpoison_page(p)) {
 		if (PageHuge(p)) {
 			pr_info("%s: %#lx free huge page\n", __func__, pfn);
 			ret =3D 0;
diff --git v4.1-rc3.orig/mm/swap.c v4.1-rc3/mm/swap.c
index a7251a8ed532..c303c1c0e4f3 100644
--- v4.1-rc3.orig/mm/swap.c
+++ v4.1-rc3/mm/swap.c
@@ -210,8 +210,6 @@ void put_refcounted_compound_page(struct page *page_hea=
d, struct page *page)
 		 */
 		if (put_page_testzero(page_head))
 			VM_BUG_ON_PAGE(1, page_head);
-		/* __split_huge_page_refcount will wait now */
-		VM_BUG_ON_PAGE(page_mapcount(page) <=3D 0, page);
 		atomic_dec(&page->_mapcount);
 		VM_BUG_ON_PAGE(atomic_read(&page_head->_count) <=3D 0, page_head);
 		VM_BUG_ON_PAGE(atomic_read(&page->_count) !=3D 0, page);
--=20
2.1.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
