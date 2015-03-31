Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f42.google.com (mail-pa0-f42.google.com [209.85.220.42])
	by kanga.kvack.org (Postfix) with ESMTP id 59A57900015
	for <linux-mm@kvack.org>; Tue, 31 Mar 2015 05:03:10 -0400 (EDT)
Received: by patj18 with SMTP id j18so13703907pat.2
        for <linux-mm@kvack.org>; Tue, 31 Mar 2015 02:03:10 -0700 (PDT)
Received: from tyo200.gate.nec.co.jp (TYO200.gate.nec.co.jp. [210.143.35.50])
        by mx.google.com with ESMTPS id at5si18495389pbc.170.2015.03.31.02.03.03
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Tue, 31 Mar 2015 02:03:04 -0700 (PDT)
Received: from tyo201.gate.nec.co.jp ([10.7.69.201])
	by tyo200.gate.nec.co.jp (8.13.8/8.13.4) with ESMTP id t2V930Vk016992
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=NO)
	for <linux-mm@kvack.org>; Tue, 31 Mar 2015 18:03:01 +0900 (JST)
From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Subject: [PATCH v3 2/3] mm: hugetlb: introduce PageHugeActive flag
Date: Tue, 31 Mar 2015 08:50:46 +0000
Message-ID: <1427791840-11247-3-git-send-email-n-horiguchi@ah.jp.nec.com>
References: <1427791840-11247-1-git-send-email-n-horiguchi@ah.jp.nec.com>
In-Reply-To: <1427791840-11247-1-git-send-email-n-horiguchi@ah.jp.nec.com>
Content-Language: ja-JP
Content-Type: text/plain; charset="iso-2022-jp"
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Hugh Dickins <hughd@google.com>, Michal Hocko <mhocko@suse.cz>, Mel Gorman <mgorman@suse.de>, Johannes Weiner <hannes@cmpxchg.org>, David Rientjes <rientjes@google.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Naoya Horiguchi <nao.horiguchi@gmail.com>

We are not safe from calling isolate_huge_page() on a hugepage concurrently=
,
which can make the victim hugepage in invalid state and results in BUG_ON()=
.

The root problem of this is that we don't have any information on struct pa=
ge
(so easily accessible) about hugepages' activeness. Note that hugepages'
activeness means just being linked to hstate->hugepage_activelist, which is
not the same as normal pages' activeness represented by PageActive flag.

Normal pages are isolated by isolate_lru_page() which prechecks PageLRU bef=
ore
isolation, so let's do similarly for hugetlb with a new PageHugeActive flag=
.

Set/ClearPageHugeActive should be called within hugetlb_lock. But hugetlb_c=
ow()
and hugetlb_no_page() don't do this, being justified because in these funct=
ion
SetPageHugeActive is called right after the hugepage is allocated and no ot=
her
thread tries to isolate it.

Signed-off-by: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
---
ChangeLog v2->v3:
- Use PagePrivate of the first tail page to show hugepage's activeness inst=
ead
  of PageLRU
- drop ClearPageLRU in dequeue_hwpoisoned_huge_page() (which was wrong)
- fix return value of isolate_huge_page() (using ret)
- move __put_compound_page() part to a separate patch
- drop "Cc: stable" tag because this is not a simple fix

ChangeLog v1->v2:
- call isolate_huge_page() in soft_offline_huge_page() instead of list_move=
()
---
 mm/hugetlb.c        | 41 ++++++++++++++++++++++++++++++++++++++---
 mm/memory-failure.c | 14 ++++++++++++--
 2 files changed, 50 insertions(+), 5 deletions(-)

diff --git v4.0-rc6.orig/mm/hugetlb.c v4.0-rc6/mm/hugetlb.c
index c41b2a0ee273..05e0233d30d7 100644
--- v4.0-rc6.orig/mm/hugetlb.c
+++ v4.0-rc6/mm/hugetlb.c
@@ -855,6 +855,31 @@ struct hstate *size_to_hstate(unsigned long size)
 	return NULL;
 }
=20
+/*
+ * Page flag to show that the hugepage is "active/in-use" (i.e. being link=
ed to
+ * hstate->hugepage_activelist.)
+ *
+ * This function can be called for tail pages, but never returns true for =
them.
+ */
+int PageHugeActive(struct page *page)
+{
+	VM_BUG_ON_PAGE(!PageHuge(page), page);
+	return PageHead(page) && PagePrivate(&page[1]);
+}
+
+/* never called for tail page */
+void SetPageHugeActive(struct page *page)
+{
+	VM_BUG_ON_PAGE(!PageHeadHuge(page), page);
+	SetPagePrivate(&page[1]);
+}
+
+void ClearPageHugeActive(struct page *page)
+{
+	VM_BUG_ON_PAGE(!PageHeadHuge(page), page);
+	ClearPagePrivate(&page[1]);
+}
+
 void free_huge_page(struct page *page)
 {
 	/*
@@ -875,6 +900,7 @@ void free_huge_page(struct page *page)
 	ClearPagePrivate(page);
=20
 	spin_lock(&hugetlb_lock);
+	ClearPageHugeActive(page);
 	hugetlb_cgroup_uncharge_page(hstate_index(h),
 				     pages_per_huge_page(h), page);
 	if (restore_reserve)
@@ -2891,6 +2917,7 @@ static int hugetlb_cow(struct mm_struct *mm, struct v=
m_area_struct *vma,
 	copy_user_huge_page(new_page, old_page, address, vma,
 			    pages_per_huge_page(h));
 	__SetPageUptodate(new_page);
+	SetPageHugeActive(new_page);
=20
 	mmun_start =3D address & huge_page_mask(h);
 	mmun_end =3D mmun_start + huge_page_size(h);
@@ -3003,6 +3030,7 @@ static int hugetlb_no_page(struct mm_struct *mm, stru=
ct vm_area_struct *vma,
 		}
 		clear_huge_page(page, address, pages_per_huge_page(h));
 		__SetPageUptodate(page);
+		SetPageHugeActive(page);
=20
 		if (vma->vm_flags & VM_MAYSHARE) {
 			int err;
@@ -3812,19 +3840,26 @@ int dequeue_hwpoisoned_huge_page(struct page *hpage=
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
+	if (!PageHugeActive(page) || !get_page_unless_zero(page)) {
+		ret =3D false;
+		goto unlock;
+	}
+	ClearPageHugeActive(page);
 	list_move_tail(&page->lru, list);
+unlock:
 	spin_unlock(&hugetlb_lock);
-	return true;
+	return ret;
 }
=20
 void putback_active_hugepage(struct page *page)
 {
 	VM_BUG_ON_PAGE(!PageHead(page), page);
 	spin_lock(&hugetlb_lock);
+	SetPageHugeActive(page);
 	list_move_tail(&page->lru, &(page_hstate(page))->hugepage_activelist);
 	spin_unlock(&hugetlb_lock);
 	put_page(page);
diff --git v4.0-rc6.orig/mm/memory-failure.c v4.0-rc6/mm/memory-failure.c
index d487f8dc6d39..1d86cca8de26 100644
--- v4.0-rc6.orig/mm/memory-failure.c
+++ v4.0-rc6/mm/memory-failure.c
@@ -1540,8 +1540,18 @@ static int soft_offline_huge_page(struct page *page,=
 int flags)
 	}
 	unlock_page(hpage);
=20
-	/* Keep page count to indicate a given hugepage is isolated. */
-	list_move(&hpage->lru, &pagelist);
+	ret =3D isolate_huge_page(hpage, &pagelist);
+	if (ret) {
+		/*
+		 * get_any_page() and isolate_huge_page() takes a refcount each,
+		 * so need to drop one here.
+		 */
+		put_page(hpage);
+	} else {
+		pr_info("soft offline: %#lx hugepage failed to isolate\n", pfn);
+		return -EBUSY;
+	}
+
 	ret =3D migrate_pages(&pagelist, new_page, NULL, MPOL_MF_MOVE_ALL,
 				MIGRATE_SYNC, MR_MEMORY_FAILURE);
 	if (ret) {
--=20
1.9.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
