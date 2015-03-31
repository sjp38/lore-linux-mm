Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f181.google.com (mail-pd0-f181.google.com [209.85.192.181])
	by kanga.kvack.org (Postfix) with ESMTP id 5D5396B0038
	for <linux-mm@kvack.org>; Tue, 31 Mar 2015 17:06:13 -0400 (EDT)
Received: by pdrw1 with SMTP id w1so24154610pdr.0
        for <linux-mm@kvack.org>; Tue, 31 Mar 2015 14:06:13 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id hm17si20993187pad.46.2015.03.31.14.06.11
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 31 Mar 2015 14:06:12 -0700 (PDT)
Date: Tue, 31 Mar 2015 14:06:10 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH v3 2/3] mm: hugetlb: introduce PageHugeActive flag
Message-Id: <20150331140610.a146030d6a2e3abc6e4c9ba4@linux-foundation.org>
In-Reply-To: <1427791840-11247-3-git-send-email-n-horiguchi@ah.jp.nec.com>
References: <1427791840-11247-1-git-send-email-n-horiguchi@ah.jp.nec.com>
	<1427791840-11247-3-git-send-email-n-horiguchi@ah.jp.nec.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Cc: Hugh Dickins <hughd@google.com>, Michal Hocko <mhocko@suse.cz>, Mel Gorman <mgorman@suse.de>, Johannes Weiner <hannes@cmpxchg.org>, David Rientjes <rientjes@google.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Naoya Horiguchi <nao.horiguchi@gmail.com>

On Tue, 31 Mar 2015 08:50:46 +0000 Naoya Horiguchi <n-horiguchi@ah.jp.nec.com> wrote:

> We are not safe from calling isolate_huge_page() on a hugepage concurrently,
> which can make the victim hugepage in invalid state and results in BUG_ON().
> 
> The root problem of this is that we don't have any information on struct page
> (so easily accessible) about hugepages' activeness. Note that hugepages'
> activeness means just being linked to hstate->hugepage_activelist, which is
> not the same as normal pages' activeness represented by PageActive flag.
> 
> Normal pages are isolated by isolate_lru_page() which prechecks PageLRU before
> isolation, so let's do similarly for hugetlb with a new PageHugeActive flag.
> 
> Set/ClearPageHugeActive should be called within hugetlb_lock. But hugetlb_cow()
> and hugetlb_no_page() don't do this, being justified because in these function
> SetPageHugeActive is called right after the hugepage is allocated and no other
> thread tries to isolate it.
> 
> ...
>
> +/*
> + * Page flag to show that the hugepage is "active/in-use" (i.e. being linked to
> + * hstate->hugepage_activelist.)
> + *
> + * This function can be called for tail pages, but never returns true for them.
> + */
> +int PageHugeActive(struct page *page)
> +{
> +	VM_BUG_ON_PAGE(!PageHuge(page), page);
> +	return PageHead(page) && PagePrivate(&page[1]);
> +}

This is not a "page flag".  It is a regular old C function which tests
for a certain page state.  Yes, it kind of pretends to act like a
separate page flag but its use of the peculiar naming convention is
rather misleading.

I mean, if you see

	SetPageHugeActive(page);

then you expect that to be doing set_bit(PG_hugeactive, &page->flags)
but that isn't what it does, so the name is misleading.

Agree?

From: Andrew Morton <akpm@linux-foundation.org>
Subject: mm-hugetlb-introduce-pagehugeactive-flag-fix

s/PageHugeActive/page_huge_active/, make it return bool

Cc: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Cc: Hugh Dickins <hughd@google.com>
Cc: Michal Hocko <mhocko@suse.cz>
Cc: Mel Gorman <mgorman@suse.de>
Cc: Johannes Weiner <hannes@cmpxchg.org>
Cc: David Rientjes <rientjes@google.com>
Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
---

 mm/hugetlb.c |   22 +++++++++++-----------
 1 file changed, 11 insertions(+), 11 deletions(-)

diff -puN mm/hugetlb.c~mm-hugetlb-introduce-pagehugeactive-flag-fix mm/hugetlb.c
--- a/mm/hugetlb.c~mm-hugetlb-introduce-pagehugeactive-flag-fix
+++ a/mm/hugetlb.c
@@ -925,25 +925,25 @@ struct hstate *size_to_hstate(unsigned l
 }
 
 /*
- * Page flag to show that the hugepage is "active/in-use" (i.e. being linked to
- * hstate->hugepage_activelist.)
+ * Test to determine whether the hugepage is "active/in-use" (i.e. being linked
+ * to hstate->hugepage_activelist.)
  *
  * This function can be called for tail pages, but never returns true for them.
  */
-int PageHugeActive(struct page *page)
+bool page_huge_active(struct page *page)
 {
 	VM_BUG_ON_PAGE(!PageHuge(page), page);
 	return PageHead(page) && PagePrivate(&page[1]);
 }
 
 /* never called for tail page */
-void SetPageHugeActive(struct page *page)
+void set_page_huge_active(struct page *page)
 {
 	VM_BUG_ON_PAGE(!PageHeadHuge(page), page);
 	SetPagePrivate(&page[1]);
 }
 
-void ClearPageHugeActive(struct page *page)
+void clear_page_huge_active(struct page *page)
 {
 	VM_BUG_ON_PAGE(!PageHeadHuge(page), page);
 	ClearPagePrivate(&page[1]);
@@ -977,7 +977,7 @@ void free_huge_page(struct page *page)
 		restore_reserve = true;
 
 	spin_lock(&hugetlb_lock);
-	ClearPageHugeActive(page);
+	clear_page_huge_active(page);
 	hugetlb_cgroup_uncharge_page(hstate_index(h),
 				     pages_per_huge_page(h), page);
 	if (restore_reserve)
@@ -2998,7 +2998,7 @@ retry_avoidcopy:
 	copy_user_huge_page(new_page, old_page, address, vma,
 			    pages_per_huge_page(h));
 	__SetPageUptodate(new_page);
-	SetPageHugeActive(new_page);
+	set_page_huge_active(new_page);
 
 	mmun_start = address & huge_page_mask(h);
 	mmun_end = mmun_start + huge_page_size(h);
@@ -3111,7 +3111,7 @@ retry:
 		}
 		clear_huge_page(page, address, pages_per_huge_page(h));
 		__SetPageUptodate(page);
-		SetPageHugeActive(page);
+		set_page_huge_active(page);
 
 		if (vma->vm_flags & VM_MAYSHARE) {
 			int err;
@@ -3946,11 +3946,11 @@ bool isolate_huge_page(struct page *page
 
 	VM_BUG_ON_PAGE(!PageHead(page), page);
 	spin_lock(&hugetlb_lock);
-	if (!PageHugeActive(page) || !get_page_unless_zero(page)) {
+	if (!page_huge_active(page) || !get_page_unless_zero(page)) {
 		ret = false;
 		goto unlock;
 	}
-	ClearPageHugeActive(page);
+	clear_page_huge_active(page);
 	list_move_tail(&page->lru, list);
 unlock:
 	spin_unlock(&hugetlb_lock);
@@ -3961,7 +3961,7 @@ void putback_active_hugepage(struct page
 {
 	VM_BUG_ON_PAGE(!PageHead(page), page);
 	spin_lock(&hugetlb_lock);
-	SetPageHugeActive(page);
+	set_page_huge_active(page);
 	list_move_tail(&page->lru, &(page_hstate(page))->hugepage_activelist);
 	spin_unlock(&hugetlb_lock);
 	put_page(page);

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
