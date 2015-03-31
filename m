Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f178.google.com (mail-pd0-f178.google.com [209.85.192.178])
	by kanga.kvack.org (Postfix) with ESMTP id 249AD6B006C
	for <linux-mm@kvack.org>; Tue, 31 Mar 2015 05:03:06 -0400 (EDT)
Received: by pdbni2 with SMTP id ni2so14421054pdb.1
        for <linux-mm@kvack.org>; Tue, 31 Mar 2015 02:03:05 -0700 (PDT)
Received: from tyo200.gate.nec.co.jp (TYO200.gate.nec.co.jp. [210.143.35.50])
        by mx.google.com with ESMTPS id v1si18558719pdr.114.2015.03.31.02.03.03
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Tue, 31 Mar 2015 02:03:04 -0700 (PDT)
Received: from tyo201.gate.nec.co.jp ([10.7.69.201])
	by tyo200.gate.nec.co.jp (8.13.8/8.13.4) with ESMTP id t2V930Vi016992
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=NO)
	for <linux-mm@kvack.org>; Tue, 31 Mar 2015 18:03:01 +0900 (JST)
From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Subject: [PATCH v3 3/3] mm: hugetlb: cleanup using PageHugeActive flag
Date: Tue, 31 Mar 2015 08:50:46 +0000
Message-ID: <1427791840-11247-4-git-send-email-n-horiguchi@ah.jp.nec.com>
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

Now we have an easy access to hugepages' activeness, so existing helpers to
get the information can be cleaned up.

Signed-off-by: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
---
 include/linux/hugetlb.h |  8 ++++++--
 mm/hugetlb.c            | 42 +++++-------------------------------------
 mm/memory_hotplug.c     |  2 +-
 3 files changed, 12 insertions(+), 40 deletions(-)

diff --git v4.0-rc6.orig/include/linux/hugetlb.h v4.0-rc6/include/linux/hug=
etlb.h
index 7b5785032049..8494abed02a5 100644
--- v4.0-rc6.orig/include/linux/hugetlb.h
+++ v4.0-rc6/include/linux/hugetlb.h
@@ -42,6 +42,7 @@ struct hugepage_subpool *hugepage_new_subpool(long nr_blo=
cks);
 void hugepage_put_subpool(struct hugepage_subpool *spool);
=20
 int PageHuge(struct page *page);
+int PageHugeActive(struct page *page);
=20
 void reset_vma_resv_huge_pages(struct vm_area_struct *vma);
 int hugetlb_sysctl_handler(struct ctl_table *, int, void __user *, size_t =
*, loff_t *);
@@ -79,7 +80,6 @@ void hugetlb_unreserve_pages(struct inode *inode, long of=
fset, long freed);
 int dequeue_hwpoisoned_huge_page(struct page *page);
 bool isolate_huge_page(struct page *page, struct list_head *list);
 void putback_active_hugepage(struct page *page);
-bool is_hugepage_active(struct page *page);
 void free_huge_page(struct page *page);
=20
 #ifdef CONFIG_ARCH_WANT_HUGE_PMD_SHARE
@@ -114,6 +114,11 @@ static inline int PageHuge(struct page *page)
 	return 0;
 }
=20
+static inline int PageHugeActive(struct page *page)
+{
+	return 0;
+}
+
 static inline void reset_vma_resv_huge_pages(struct vm_area_struct *vma)
 {
 }
@@ -152,7 +157,6 @@ static inline bool isolate_huge_page(struct page *page,=
 struct list_head *list)
 	return false;
 }
 #define putback_active_hugepage(p)	do {} while (0)
-#define is_hugepage_active(x)	false
=20
 static inline unsigned long hugetlb_change_protection(struct vm_area_struc=
t *vma,
 		unsigned long address, unsigned long end, pgprot_t newprot)
diff --git v4.0-rc6.orig/mm/hugetlb.c v4.0-rc6/mm/hugetlb.c
index 05e0233d30d7..8e1c46affc59 100644
--- v4.0-rc6.orig/mm/hugetlb.c
+++ v4.0-rc6/mm/hugetlb.c
@@ -3795,20 +3795,6 @@ follow_huge_pud(struct mm_struct *mm, unsigned long =
address,
=20
 #ifdef CONFIG_MEMORY_FAILURE
=20
-/* Should be called in hugetlb_lock */
-static int is_hugepage_on_freelist(struct page *hpage)
-{
-	struct page *page;
-	struct page *tmp;
-	struct hstate *h =3D page_hstate(hpage);
-	int nid =3D page_to_nid(hpage);
-
-	list_for_each_entry_safe(page, tmp, &h->hugepage_freelists[nid], lru)
-		if (page =3D=3D hpage)
-			return 1;
-	return 0;
-}
-
 /*
  * This function is called from memory failure code.
  * Assume the caller holds page lock of the head page.
@@ -3820,7 +3806,11 @@ int dequeue_hwpoisoned_huge_page(struct page *hpage)
 	int ret =3D -EBUSY;
=20
 	spin_lock(&hugetlb_lock);
-	if (is_hugepage_on_freelist(hpage)) {
+	/*
+	 * Just checking !PageHugeActive is not enough, because that could be
+	 * an isolated/hwpoisoned hugepage (which have >0 refcount).
+	 */
+	if (!PageHugeActive(hpage) && !page_count(hpage)) {
 		/*
 		 * Hwpoisoned hugepage isn't linked to activelist or freelist,
 		 * but dangling hpage->lru can trigger list-debug warnings
@@ -3864,25 +3854,3 @@ void putback_active_hugepage(struct page *page)
 	spin_unlock(&hugetlb_lock);
 	put_page(page);
 }
-
-bool is_hugepage_active(struct page *page)
-{
-	VM_BUG_ON_PAGE(!PageHuge(page), page);
-	/*
-	 * This function can be called for a tail page because the caller,
-	 * scan_movable_pages, scans through a given pfn-range which typically
-	 * covers one memory block. In systems using gigantic hugepage (1GB
-	 * for x86_64,) a hugepage is larger than a memory block, and we don't
-	 * support migrating such large hugepages for now, so return false
-	 * when called for tail pages.
-	 */
-	if (PageTail(page))
-		return false;
-	/*
-	 * Refcount of a hwpoisoned hugepages is 1, but they are not active,
-	 * so we should return false for them.
-	 */
-	if (unlikely(PageHWPoison(page)))
-		return false;
-	return page_count(page) > 0;
-}
diff --git v4.0-rc6.orig/mm/memory_hotplug.c v4.0-rc6/mm/memory_hotplug.c
index 65842d688b7c..2d53388c0715 100644
--- v4.0-rc6.orig/mm/memory_hotplug.c
+++ v4.0-rc6/mm/memory_hotplug.c
@@ -1376,7 +1376,7 @@ static unsigned long scan_movable_pages(unsigned long=
 start, unsigned long end)
 			if (PageLRU(page))
 				return pfn;
 			if (PageHuge(page)) {
-				if (is_hugepage_active(page))
+				if (PageHugeActive(page))
 					return pfn;
 				else
 					pfn =3D round_up(pfn + 1,
--=20
1.9.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
