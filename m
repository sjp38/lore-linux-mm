Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f41.google.com (mail-oi0-f41.google.com [209.85.218.41])
	by kanga.kvack.org (Postfix) with ESMTP id A26426B0070
	for <linux-mm@kvack.org>; Thu, 14 May 2015 06:41:29 -0400 (EDT)
Received: by oign205 with SMTP id n205so52294921oig.2
        for <linux-mm@kvack.org>; Thu, 14 May 2015 03:41:29 -0700 (PDT)
Received: from tyo201.gate.nec.co.jp (TYO201.gate.nec.co.jp. [210.143.35.51])
        by mx.google.com with ESMTPS id a9si1687815oek.34.2015.05.14.03.41.24
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Thu, 14 May 2015 03:41:24 -0700 (PDT)
From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Subject: [PATCH v2 1/4] mm/memory-failure: split thp earlier in memory error
 handling
Date: Thu, 14 May 2015 10:39:12 +0000
Message-ID: <1431599951-32545-2-git-send-email-n-horiguchi@ah.jp.nec.com>
References: <1431599951-32545-1-git-send-email-n-horiguchi@ah.jp.nec.com>
In-Reply-To: <1431599951-32545-1-git-send-email-n-horiguchi@ah.jp.nec.com>
Content-Language: ja-JP
Content-Type: text/plain; charset="iso-2022-jp"
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Andi Kleen <andi@firstfloor.org>
Cc: Dean Nelson <dnelson@redhat.com>, Tony Luck <tony.luck@intel.com>, "Kirill A. Shutemov" <kirill@shutemov.name>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Naoya Horiguchi <nao.horiguchi@gmail.com>

memory_failure() doesn't handle thp itself at this time and need to split
it before doing isolation. Currently thp is split in the middle of
hwpoison_user_mappings(), but there're corner cases where memory_failure()
wrongly tries to handle thp without splitting.
  1) "non anonymous" thp, which is not a normal operating mode of thp, but
a memory error could hit a thp before anon_vma is initialized. In such case=
,
split_huge_page() fails and me_huge_page() (intended for hugetlb) is called
for thp, which triggers BUG_ON in page_hstate().
  2) !PageLRU case, where hwpoison_user_mappings() returns with SWAP_SUCCES=
S
and the result is the same as case 1.

memory_failure() can't avoid splitting, so let's split it more earlier, whi=
ch
also reduces code which are prepared for both of normal page and thp.

Signed-off-by: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
---
ChangeLog v1->v2:
- s/pr_info/pr_err/ and add "\n"
---
 mm/memory-failure.c | 88 +++++++++++++++----------------------------------=
----
 1 file changed, 25 insertions(+), 63 deletions(-)

diff --git v4.1-rc3.orig/mm/memory-failure.c v4.1-rc3/mm/memory-failure.c
index 9e9d04843d52..bec5e9b11909 100644
--- v4.1-rc3.orig/mm/memory-failure.c
+++ v4.1-rc3/mm/memory-failure.c
@@ -897,7 +897,6 @@ static int hwpoison_user_mappings(struct page *p, unsig=
ned long pfn,
 	int ret;
 	int kill =3D 1, forcekill;
 	struct page *hpage =3D *hpagep;
-	struct page *ppage;
=20
 	/*
 	 * Here we are interested only in user-mapped pages, so skip any
@@ -947,59 +946,6 @@ static int hwpoison_user_mappings(struct page *p, unsi=
gned long pfn,
 	}
=20
 	/*
-	 * ppage: poisoned page
-	 *   if p is regular page(4k page)
-	 *        ppage =3D=3D real poisoned page;
-	 *   else p is hugetlb or THP, ppage =3D=3D head page.
-	 */
-	ppage =3D hpage;
-
-	if (PageTransHuge(hpage)) {
-		/*
-		 * Verify that this isn't a hugetlbfs head page, the check for
-		 * PageAnon is just for avoid tripping a split_huge_page
-		 * internal debug check, as split_huge_page refuses to deal with
-		 * anything that isn't an anon page. PageAnon can't go away fro
-		 * under us because we hold a refcount on the hpage, without a
-		 * refcount on the hpage. split_huge_page can't be safely called
-		 * in the first place, having a refcount on the tail isn't
-		 * enough * to be safe.
-		 */
-		if (!PageHuge(hpage) && PageAnon(hpage)) {
-			if (unlikely(split_huge_page(hpage))) {
-				/*
-				 * FIXME: if splitting THP is failed, it is
-				 * better to stop the following operation rather
-				 * than causing panic by unmapping. System might
-				 * survive if the page is freed later.
-				 */
-				printk(KERN_INFO
-					"MCE %#lx: failed to split THP\n", pfn);
-
-				BUG_ON(!PageHWPoison(p));
-				return SWAP_FAIL;
-			}
-			/*
-			 * We pinned the head page for hwpoison handling,
-			 * now we split the thp and we are interested in
-			 * the hwpoisoned raw page, so move the refcount
-			 * to it. Similarly, page lock is shifted.
-			 */
-			if (hpage !=3D p) {
-				if (!(flags & MF_COUNT_INCREASED)) {
-					put_page(hpage);
-					get_page(p);
-				}
-				lock_page(p);
-				unlock_page(hpage);
-				*hpagep =3D p;
-			}
-			/* THP is split, so ppage should be the real poisoned page. */
-			ppage =3D p;
-		}
-	}
-
-	/*
 	 * First collect all the processes that have the page
 	 * mapped in dirty form.  This has to be done before try_to_unmap,
 	 * because ttu takes the rmap data structures down.
@@ -1008,12 +954,12 @@ static int hwpoison_user_mappings(struct page *p, un=
signed long pfn,
 	 * there's nothing that can be done.
 	 */
 	if (kill)
-		collect_procs(ppage, &tokill, flags & MF_ACTION_REQUIRED);
+		collect_procs(hpage, &tokill, flags & MF_ACTION_REQUIRED);
=20
-	ret =3D try_to_unmap(ppage, ttu);
+	ret =3D try_to_unmap(hpage, ttu);
 	if (ret !=3D SWAP_SUCCESS)
 		printk(KERN_ERR "MCE %#lx: failed to unmap page (mapcount=3D%d)\n",
-				pfn, page_mapcount(ppage));
+				pfn, page_mapcount(hpage));
=20
 	/*
 	 * Now that the dirty bit has been propagated to the
@@ -1025,7 +971,7 @@ static int hwpoison_user_mappings(struct page *p, unsi=
gned long pfn,
 	 * use a more force-full uncatchable kill to prevent
 	 * any accesses to the poisoned memory.
 	 */
-	forcekill =3D PageDirty(ppage) || (flags & MF_MUST_KILL);
+	forcekill =3D PageDirty(hpage) || (flags & MF_MUST_KILL);
 	kill_procs(&tokill, forcekill, trapno,
 		      ret !=3D SWAP_SUCCESS, p, pfn, flags);
=20
@@ -1071,6 +1017,7 @@ int memory_failure(unsigned long pfn, int trapno, int=
 flags)
 	struct page_state *ps;
 	struct page *p;
 	struct page *hpage;
+	struct page *orig_head;
 	int res;
 	unsigned int nr_pages;
 	unsigned long page_flags;
@@ -1086,7 +1033,7 @@ int memory_failure(unsigned long pfn, int trapno, int=
 flags)
 	}
=20
 	p =3D pfn_to_page(pfn);
-	hpage =3D compound_head(p);
+	orig_head =3D hpage =3D compound_head(p);
 	if (TestSetPageHWPoison(p)) {
 		printk(KERN_ERR "MCE %#lx: already hardware poisoned\n", pfn);
 		return 0;
@@ -1149,6 +1096,21 @@ int memory_failure(unsigned long pfn, int trapno, in=
t flags)
 		}
 	}
=20
+	if (!PageHuge(p) && PageTransHuge(hpage)) {
+		if (!PageAnon(hpage)) {
+			pr_err("MCE: %#lx: non anonymous thp\n", pfn);
+			put_page(p);
+			return -EBUSY;
+		}
+		if (unlikely(split_huge_page(hpage))) {
+			pr_err("MCE: %#lx: thp split failed\n", pfn);
+			put_page(p);
+			return -EBUSY;
+		}
+		VM_BUG_ON_PAGE(!page_count(p), p);
+		hpage =3D compound_head(p);
+	}
+
 	/*
 	 * We ignore non-LRU pages for good reasons.
 	 * - PG_locked is only well defined for LRU pages and a few others
@@ -1158,9 +1120,9 @@ int memory_failure(unsigned long pfn, int trapno, int=
 flags)
 	 * walked by the page reclaim code, however that's not a big loss.
 	 */
 	if (!PageHuge(p)) {
-		if (!PageLRU(hpage))
-			shake_page(hpage, 0);
-		if (!PageLRU(hpage)) {
+		if (!PageLRU(p))
+			shake_page(p, 0);
+		if (!PageLRU(p)) {
 			/*
 			 * shake_page could have turned it free.
 			 */
@@ -1181,7 +1143,7 @@ int memory_failure(unsigned long pfn, int trapno, int=
 flags)
 	 * The page could have changed compound pages during the locking.
 	 * If this happens just bail out.
 	 */
-	if (compound_head(p) !=3D hpage) {
+	if (PageCompound(p) && compound_head(p) !=3D orig_head) {
 		action_result(pfn, MF_MSG_DIFFERENT_COMPOUND, MF_IGNORED);
 		res =3D -EBUSY;
 		goto out;
--=20
2.1.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
