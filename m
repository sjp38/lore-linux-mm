Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ob0-f179.google.com (mail-ob0-f179.google.com [209.85.214.179])
	by kanga.kvack.org (Postfix) with ESMTP id 8F84682F64
	for <linux-mm@kvack.org>; Fri,  6 Nov 2015 01:13:30 -0500 (EST)
Received: by obbww6 with SMTP id ww6so58844746obb.0
        for <linux-mm@kvack.org>; Thu, 05 Nov 2015 22:13:30 -0800 (PST)
Received: from tyo201.gate.nec.co.jp (TYO201.gate.nec.co.jp. [210.143.35.51])
        by mx.google.com with ESMTPS id q185si5316892oib.56.2015.11.05.22.13.29
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Thu, 05 Nov 2015 22:13:29 -0800 (PST)
From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Subject: [PATCH v1] mm: hwpoison: adjust for new thp refcounting
Date: Fri, 6 Nov 2015 06:11:54 +0000
Message-ID: <1446790309-15683-1-git-send-email-n-horiguchi@ah.jp.nec.com>
Content-Language: ja-JP
Content-Type: text/plain; charset="iso-2022-jp"
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Cc: Wanpeng Li <wanpeng.li@hotmail.com>, Andi Kleen <andi@firstfloor.org>, Andrea Arcangeli <aarcange@redhat.com>, Hugh Dickins <hughd@google.com>, Sasha Levin <sasha.levin@oracle.com>, Minchan Kim <minchan@kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Naoya Horiguchi <nao.horiguchi@gmail.com>

Some mm-related BUG_ON()s could trigger from hwpoison code due to recent
changes in thp refcounting rule. This patch fixes them up.

In the new refcounting, we no longer use tail->_mapcount to keep tail's
refcount, and thereby we can simplify get_hwpoison_page() and remove
put_hwpoison_page() (by replacing with put_page()).

And another change is that tail's refcount is not transferred to the raw
page during thp split (more precisely, in new rule we don't take refcount
on tail page any more.) So when we need thp split, we have to transfer the
refcount properly to the 4kB soft-offlined page before migration.

thp split code goes into core code only when precheck (total_mapcount(head)
=3D=3D page_count(head) - 1) passes to avoid useless split, where we assume=
 that
one refcount is held by the caller of thp split and the others are taken
via mapping. To meet this assumption, this patch moves thp split part in
soft_offline_page() after get_any_page().

Signed-off-by: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
---
- based on mmotm-2015-10-21-14-41 + Kirill's "[PATCH 0/4] Bugfixes for THP
  refcounting" series.
---
 include/linux/mm.h   |   1 -
 mm/hwpoison-inject.c |   2 +-
 mm/memory-failure.c  | 103 ++++++++++++++++++-----------------------------=
----
 3 files changed, 37 insertions(+), 69 deletions(-)

diff --git mmotm-2015-10-21-14-41/include/linux/mm.h mmotm-2015-10-21-14-41=
_patched/include/linux/mm.h
index a36f9fa4e4cd..ac3a9db4f3cf 100644
--- mmotm-2015-10-21-14-41/include/linux/mm.h
+++ mmotm-2015-10-21-14-41_patched/include/linux/mm.h
@@ -2173,7 +2173,6 @@ extern int memory_failure(unsigned long pfn, int trap=
no, int flags);
 extern void memory_failure_queue(unsigned long pfn, int trapno, int flags)=
;
 extern int unpoison_memory(unsigned long pfn);
 extern int get_hwpoison_page(struct page *page);
-extern void put_hwpoison_page(struct page *page);
 extern int sysctl_memory_failure_early_kill;
 extern int sysctl_memory_failure_recovery;
 extern void shake_page(struct page *p, int access);
diff --git mmotm-2015-10-21-14-41/mm/hwpoison-inject.c mmotm-2015-10-21-14-=
41_patched/mm/hwpoison-inject.c
index 9d26fd9fefe4..5015679014c1 100644
--- mmotm-2015-10-21-14-41/mm/hwpoison-inject.c
+++ mmotm-2015-10-21-14-41_patched/mm/hwpoison-inject.c
@@ -55,7 +55,7 @@ static int hwpoison_inject(void *data, u64 val)
 	pr_info("Injecting memory failure at pfn %#lx\n", pfn);
 	return memory_failure(pfn, 18, MF_COUNT_INCREASED);
 put_out:
-	put_hwpoison_page(p);
+	put_page(p);
 	return 0;
 }
=20
diff --git mmotm-2015-10-21-14-41/mm/memory-failure.c mmotm-2015-10-21-14-4=
1_patched/mm/memory-failure.c
index a2c987df80eb..3be8884d032a 100644
--- mmotm-2015-10-21-14-41/mm/memory-failure.c
+++ mmotm-2015-10-21-14-41_patched/mm/memory-failure.c
@@ -882,15 +882,7 @@ int get_hwpoison_page(struct page *page)
 {
 	struct page *head =3D compound_head(page);
=20
-	if (PageHuge(head))
-		return get_page_unless_zero(head);
-
-	/*
-	 * Thp tail page has special refcounting rule (refcount of tail pages
-	 * is stored in ->_mapcount,) so we can't call get_page_unless_zero()
-	 * directly for tail pages.
-	 */
-	if (PageTransHuge(head)) {
+	if (!PageHuge(head) && PageTransHuge(head)) {
 		/*
 		 * Non anonymous thp exists only in allocation/free time. We
 		 * can't handle such a case correctly, so let's give it up.
@@ -902,41 +894,12 @@ int get_hwpoison_page(struct page *page)
 				page_to_pfn(page));
 			return 0;
 		}
-
-		if (get_page_unless_zero(head)) {
-			if (PageTail(page))
-				get_page(page);
-			return 1;
-		} else {
-			return 0;
-		}
 	}
=20
-	return get_page_unless_zero(page);
+	return get_page_unless_zero(head);
 }
 EXPORT_SYMBOL_GPL(get_hwpoison_page);
=20
-/**
- * put_hwpoison_page() - Put refcount for memory error handling:
- * @page:	raw error page (hit by memory error)
- */
-void put_hwpoison_page(struct page *page)
-{
-	struct page *head =3D compound_head(page);
-
-	if (PageHuge(head)) {
-		put_page(head);
-		return;
-	}
-
-	if (PageTransHuge(head))
-		if (page !=3D head)
-			put_page(head);
-
-	put_page(page);
-}
-EXPORT_SYMBOL_GPL(put_hwpoison_page);
-
 /*
  * Do all that is necessary to remove user space mappings. Unmap
  * the pages and send SIGBUS to the processes if the data was dirty.
@@ -1158,10 +1121,12 @@ int memory_failure(unsigned long pfn, int trapno, i=
nt flags)
 				pr_err("MCE: %#lx: thp split failed\n", pfn);
 			if (TestClearPageHWPoison(p))
 				num_poisoned_pages_sub(nr_pages);
-			put_hwpoison_page(p);
+			put_page(p);
 			return -EBUSY;
 		}
 		unlock_page(hpage);
+		get_hwpoison_page(p);
+		put_page(hpage);
 		VM_BUG_ON_PAGE(!page_count(p), p);
 		hpage =3D compound_head(p);
 	}
@@ -1220,14 +1185,14 @@ int memory_failure(unsigned long pfn, int trapno, i=
nt flags)
 		printk(KERN_ERR "MCE %#lx: just unpoisoned\n", pfn);
 		num_poisoned_pages_sub(nr_pages);
 		unlock_page(hpage);
-		put_hwpoison_page(hpage);
+		put_page(hpage);
 		return 0;
 	}
 	if (hwpoison_filter(p)) {
 		if (TestClearPageHWPoison(p))
 			num_poisoned_pages_sub(nr_pages);
 		unlock_page(hpage);
-		put_hwpoison_page(hpage);
+		put_page(hpage);
 		return 0;
 	}
=20
@@ -1241,7 +1206,7 @@ int memory_failure(unsigned long pfn, int trapno, int=
 flags)
 	if (PageHuge(p) && PageTail(p) && TestSetPageHWPoison(hpage)) {
 		action_result(pfn, MF_MSG_POISONED_HUGE, MF_IGNORED);
 		unlock_page(hpage);
-		put_hwpoison_page(hpage);
+		put_page(hpage);
 		return 0;
 	}
 	/*
@@ -1506,9 +1471,9 @@ int unpoison_memory(unsigned long pfn)
 	}
 	unlock_page(page);
=20
-	put_hwpoison_page(page);
+	put_page(page);
 	if (freeit && !(pfn =3D=3D my_zero_pfn(0) && page_count(p) =3D=3D 1))
-		put_hwpoison_page(page);
+		put_page(page);
=20
 	return 0;
 }
@@ -1568,16 +1533,16 @@ static int get_any_page(struct page *page, unsigned=
 long pfn, int flags)
 		/*
 		 * Try to free it.
 		 */
-		put_hwpoison_page(page);
+		put_page(page);
 		shake_page(page, 1);
=20
 		/*
 		 * Did it turn free?
 		 */
 		ret =3D __get_any_page(page, pfn, 0);
-		if (!PageLRU(page)) {
+		if (ret =3D=3D 1 && !PageLRU(page)) {
 			/* Drop page reference which is from __get_any_page() */
-			put_hwpoison_page(page);
+			put_page(page);
 			pr_info("soft_offline: %#lx: unknown non LRU page type %lx\n",
 				pfn, page->flags);
 			return -EIO;
@@ -1600,7 +1565,7 @@ static int soft_offline_huge_page(struct page *page, =
int flags)
 	lock_page(hpage);
 	if (PageHWPoison(hpage)) {
 		unlock_page(hpage);
-		put_hwpoison_page(hpage);
+		put_page(hpage);
 		pr_info("soft offline: %#lx hugepage already poisoned\n", pfn);
 		return -EBUSY;
 	}
@@ -1611,7 +1576,7 @@ static int soft_offline_huge_page(struct page *page, =
int flags)
 	 * get_any_page() and isolate_huge_page() takes a refcount each,
 	 * so need to drop one here.
 	 */
-	put_hwpoison_page(hpage);
+	put_page(hpage);
 	if (!ret) {
 		pr_info("soft offline: %#lx hugepage failed to isolate\n", pfn);
 		return -EBUSY;
@@ -1659,7 +1624,7 @@ static int __soft_offline_page(struct page *page, int=
 flags)
 	wait_on_page_writeback(page);
 	if (PageHWPoison(page)) {
 		unlock_page(page);
-		put_hwpoison_page(page);
+		put_page(page);
 		pr_info("soft offline: %#lx page already poisoned\n", pfn);
 		return -EBUSY;
 	}
@@ -1674,7 +1639,7 @@ static int __soft_offline_page(struct page *page, int=
 flags)
 	 * would need to fix isolation locking first.
 	 */
 	if (ret =3D=3D 1) {
-		put_hwpoison_page(page);
+		put_page(page);
 		pr_info("soft_offline: %#lx: invalidated\n", pfn);
 		SetPageHWPoison(page);
 		num_poisoned_pages_inc();
@@ -1691,7 +1656,7 @@ static int __soft_offline_page(struct page *page, int=
 flags)
 	 * Drop page reference which is came from get_any_page()
 	 * successful isolate_lru_page() already took another one.
 	 */
-	put_hwpoison_page(page);
+	put_page(page);
 	if (!ret) {
 		LIST_HEAD(pagelist);
 		inc_zone_page_state(page, NR_ISOLATED_ANON +
@@ -1750,27 +1715,31 @@ int soft_offline_page(struct page *page, int flags)
 	if (PageHWPoison(page)) {
 		pr_info("soft offline: %#lx page already poisoned\n", pfn);
 		if (flags & MF_COUNT_INCREASED)
-			put_hwpoison_page(page);
+			put_page(page);
 		return -EBUSY;
 	}
-	if (!PageHuge(page) && PageTransHuge(hpage)) {
-		lock_page(page);
-		ret =3D split_huge_page(hpage);
-		unlock_page(page);
-		if (unlikely(ret)) {
-			pr_info("soft offline: %#lx: failed to split THP\n",
-				pfn);
-			if (flags & MF_COUNT_INCREASED)
-				put_hwpoison_page(page);
-			return -EBUSY;
-		}
-	}
=20
 	get_online_mems();
-
 	ret =3D get_any_page(page, pfn, flags);
 	put_online_mems();
+
 	if (ret > 0) { /* for in-use pages */
+		if (!PageHuge(page) && PageTransHuge(hpage)) {
+			lock_page(hpage);
+			ret =3D split_huge_page(hpage);
+			unlock_page(hpage);
+			if (unlikely(ret || PageTransCompound(page) ||
+					!PageAnon(page))) {
+				pr_info("soft offline: %#lx: failed to split THP\n",
+					pfn);
+				if (flags & MF_COUNT_INCREASED)
+					put_page(hpage);
+				return -EBUSY;
+			}
+			get_hwpoison_page(page);
+			put_page(hpage);
+		}
+
 		if (PageHuge(page))
 			ret =3D soft_offline_huge_page(page, flags);
 		else
--=20
2.4.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
