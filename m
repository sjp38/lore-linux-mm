Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f50.google.com (mail-pa0-f50.google.com [209.85.220.50])
	by kanga.kvack.org (Postfix) with ESMTP id 1F3C76B0032
	for <linux-mm@kvack.org>; Mon, 16 Feb 2015 22:28:05 -0500 (EST)
Received: by padhz1 with SMTP id hz1so3002708pad.9
        for <linux-mm@kvack.org>; Mon, 16 Feb 2015 19:28:04 -0800 (PST)
Received: from tyo200.gate.nec.co.jp (TYO200.gate.nec.co.jp. [210.143.35.50])
        by mx.google.com with ESMTPS id oe8si5290212pbc.207.2015.02.16.19.28.03
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Mon, 16 Feb 2015 19:28:04 -0800 (PST)
Received: from tyo202.gate.nec.co.jp ([10.7.69.202])
	by tyo200.gate.nec.co.jp (8.13.8/8.13.4) with ESMTP id t1H3S04O020396
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=NO)
	for <linux-mm@kvack.org>; Tue, 17 Feb 2015 12:28:01 +0900 (JST)
From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Subject: [PATCH] mm, hugetlb: set PageLRU for in-use/active hugepages
Date: Tue, 17 Feb 2015 03:22:45 +0000
Message-ID: <1424143299-7557-1-git-send-email-n-horiguchi@ah.jp.nec.com>
Content-Language: ja-JP
Content-Type: text/plain; charset="iso-2022-jp"
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Hugh Dickins <hughd@google.com>, Michal Hocko <mhocko@suse.cz>, Mel Gorman <mgorman@suse.de>, Johannes Weiner <hannes@cmpxchg.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Naoya Horiguchi <nao.horiguchi@gmail.com>

Currently we are not safe from concurrent calls of isolate_huge_page(),
which can make the victim hugepage in invalid state and results in BUG_ON()=
.

The root problem of this is that we don't have any information on struct pa=
ge
(so easily accessible) about the hugepage's activeness. Note that hugepages=
'
activeness means just being linked to hstate->hugepage_activelist, which is
not the same as normal pages' activeness represented by PageActive flag.

Normal pages are isolated by isolate_lru_page() which prechecks PageLRU bef=
ore
isolation, so let's do similarly for hugetlb. PageLRU is unused on hugetlb,
so this change is mostly straightforward. One non-straightforward point is =
that
__put_compound_page() calls __page_cache_release() to do some LRU works,
but this is obviously for thps and assumes that hugetlb has always !PageLRU=
.
This assumption is no more true, so this patch simply adds if (!PageHuge) t=
o
avoid calling __page_cache_release() for hugetlb.

Set/ClearPageLRU should be called within hugetlb_lock, but hugetlb_cow() an=
d
hugetlb_no_page() don't do this. This is justified because in these functio=
n
SetPageLRU is called right after the hugepage is allocated and no other thr=
ead
tries to isolate it.

Fixes: commit 31caf665e666 ("mm: migrate: make core migration code aware of=
 hugepage")
Signed-off-by: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Cc: <stable@vger.kernel.org>        [3.12+]
---
 mm/hugetlb.c | 17 ++++++++++++++---
 mm/swap.c    |  4 +++-
 2 files changed, 17 insertions(+), 4 deletions(-)

diff --git v3.19_with_hugemigration_fixes.orig/mm/hugetlb.c v3.19_with_huge=
migration_fixes/mm/hugetlb.c
index a2bfd02e289f..e28489270d9a 100644
--- v3.19_with_hugemigration_fixes.orig/mm/hugetlb.c
+++ v3.19_with_hugemigration_fixes/mm/hugetlb.c
@@ -830,7 +830,7 @@ static void update_and_free_page(struct hstate *h, stru=
ct page *page)
 		page[i].flags &=3D ~(1 << PG_locked | 1 << PG_error |
 				1 << PG_referenced | 1 << PG_dirty |
 				1 << PG_active | 1 << PG_private |
-				1 << PG_writeback);
+				1 << PG_writeback | 1 << PG_lru);
 	}
 	VM_BUG_ON_PAGE(hugetlb_cgroup_from_page(page), page);
 	set_compound_page_dtor(page, NULL);
@@ -875,6 +875,7 @@ void free_huge_page(struct page *page)
 	ClearPagePrivate(page);
=20
 	spin_lock(&hugetlb_lock);
+	ClearPageLRU(page);
 	hugetlb_cgroup_uncharge_page(hstate_index(h),
 				     pages_per_huge_page(h), page);
 	if (restore_reserve)
@@ -2889,6 +2890,7 @@ static int hugetlb_cow(struct mm_struct *mm, struct v=
m_area_struct *vma,
 	copy_user_huge_page(new_page, old_page, address, vma,
 			    pages_per_huge_page(h));
 	__SetPageUptodate(new_page);
+	SetPageLRU(new_page);
=20
 	mmun_start =3D address & huge_page_mask(h);
 	mmun_end =3D mmun_start + huge_page_size(h);
@@ -3001,6 +3003,7 @@ static int hugetlb_no_page(struct mm_struct *mm, stru=
ct vm_area_struct *vma,
 		}
 		clear_huge_page(page, address, pages_per_huge_page(h));
 		__SetPageUptodate(page);
+		SetPageLRU(page);
=20
 		if (vma->vm_flags & VM_MAYSHARE) {
 			int err;
@@ -3794,6 +3797,7 @@ int dequeue_hwpoisoned_huge_page(struct page *hpage)
 		 * so let it point to itself with list_del_init().
 		 */
 		list_del_init(&hpage->lru);
+		ClearPageLRU(hpage);
 		set_page_refcounted(hpage);
 		h->free_huge_pages--;
 		h->free_huge_pages_node[nid]--;
@@ -3806,11 +3810,17 @@ int dequeue_hwpoisoned_huge_page(struct page *hpage=
)
=20
 bool isolate_huge_page(struct page *page, struct list_head *list)
 {
+	bool ret =3D true;
+
 	VM_BUG_ON_PAGE(!PageHead(page), page);
-	if (!get_page_unless_zero(page))
-		return false;
 	spin_lock(&hugetlb_lock);
+	if (!PageLRU(page) || !get_page_unless_zero(page)) {
+		ret =3D false;
+		goto unlock;
+	}
+	ClearPageLRU(page);
 	list_move_tail(&page->lru, list);
+unlock:
 	spin_unlock(&hugetlb_lock);
 	return true;
 }
@@ -3819,6 +3829,7 @@ void putback_active_hugepage(struct page *page)
 {
 	VM_BUG_ON_PAGE(!PageHead(page), page);
 	spin_lock(&hugetlb_lock);
+	SetPageLRU(page);
 	list_move_tail(&page->lru, &(page_hstate(page))->hugepage_activelist);
 	spin_unlock(&hugetlb_lock);
 	put_page(page);
diff --git v3.19_with_hugemigration_fixes.orig/mm/swap.c v3.19_with_hugemig=
ration_fixes/mm/swap.c
index 8a12b33936b4..ea8fe72999a8 100644
--- v3.19_with_hugemigration_fixes.orig/mm/swap.c
+++ v3.19_with_hugemigration_fixes/mm/swap.c
@@ -31,6 +31,7 @@
 #include <linux/memcontrol.h>
 #include <linux/gfp.h>
 #include <linux/uio.h>
+#include <linux/hugetlb.h>
=20
 #include "internal.h"
=20
@@ -75,7 +76,8 @@ static void __put_compound_page(struct page *page)
 {
 	compound_page_dtor *dtor;
=20
-	__page_cache_release(page);
+	if (!PageHuge(page))
+		__page_cache_release(page);
 	dtor =3D get_compound_page_dtor(page);
 	(*dtor)(page);
 }
--=20
1.9.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
