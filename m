Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f176.google.com (mail-pd0-f176.google.com [209.85.192.176])
	by kanga.kvack.org (Postfix) with ESMTP id 1AFE76B006E
	for <linux-mm@kvack.org>; Tue, 31 Mar 2015 17:08:17 -0400 (EDT)
Received: by pddn5 with SMTP id n5so32472485pdd.2
        for <linux-mm@kvack.org>; Tue, 31 Mar 2015 14:08:16 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id ep3si14258567pbd.133.2015.03.31.14.08.15
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 31 Mar 2015 14:08:16 -0700 (PDT)
Date: Tue, 31 Mar 2015 14:08:14 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH v3 3/3] mm: hugetlb: cleanup using PageHugeActive flag
Message-Id: <20150331140814.b939a57340cb1d3bf6b32c9d@linux-foundation.org>
In-Reply-To: <1427791840-11247-4-git-send-email-n-horiguchi@ah.jp.nec.com>
References: <1427791840-11247-1-git-send-email-n-horiguchi@ah.jp.nec.com>
	<1427791840-11247-4-git-send-email-n-horiguchi@ah.jp.nec.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Cc: Hugh Dickins <hughd@google.com>, Michal Hocko <mhocko@suse.cz>, Mel Gorman <mgorman@suse.de>, Johannes Weiner <hannes@cmpxchg.org>, David Rientjes <rientjes@google.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Naoya Horiguchi <nao.horiguchi@gmail.com>

On Tue, 31 Mar 2015 08:50:46 +0000 Naoya Horiguchi <n-horiguchi@ah.jp.nec.com> wrote:

> Now we have an easy access to hugepages' activeness, so existing helpers to
> get the information can be cleaned up.

Similarly.  Also I adapted the code to fit in with
http://ozlabs.org/~akpm/mmots/broken-out/mm-consolidate-all-page-flags-helpers-in-linux-page-flagsh.patch


From: Andrew Morton <akpm@linux-foundation.org>
Subject: mm-hugetlb-cleanup-using-pagehugeactive-flag-fix

s/PageHugeActive/page_huge_active/

Cc: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Cc: Hugh Dickins <hughd@google.com>
Cc: Michal Hocko <mhocko@suse.cz>
Cc: Mel Gorman <mgorman@suse.de>
Cc: Johannes Weiner <hannes@cmpxchg.org>
Cc: David Rientjes <rientjes@google.com>
Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
---

 include/linux/hugetlb.h    |    7 -------
 include/linux/page-flags.h |    7 +++++++
 mm/hugetlb.c               |    4 ++--
 mm/memory_hotplug.c        |    2 +-
 4 files changed, 10 insertions(+), 10 deletions(-)

diff -puN include/linux/hugetlb.h~mm-hugetlb-cleanup-using-pagehugeactive-flag-fix include/linux/hugetlb.h
--- a/include/linux/hugetlb.h~mm-hugetlb-cleanup-using-pagehugeactive-flag-fix
+++ a/include/linux/hugetlb.h
@@ -44,8 +44,6 @@ extern int hugetlb_max_hstate __read_mos
 #define for_each_hstate(h) \
 	for ((h) = hstates; (h) < &hstates[hugetlb_max_hstate]; (h)++)
 
-int PageHugeActive(struct page *page);
-
 struct hugepage_subpool *hugepage_new_subpool(struct hstate *h, long max_hpages,
 						long min_hpages);
 void hugepage_put_subpool(struct hugepage_subpool *spool);
@@ -115,11 +113,6 @@ unsigned long hugetlb_change_protection(
 
 #else /* !CONFIG_HUGETLB_PAGE */
 
-static inline int PageHugeActive(struct page *page)
-{
-	return 0;
-}
-
 static inline void reset_vma_resv_huge_pages(struct vm_area_struct *vma)
 {
 }
diff -puN mm/hugetlb.c~mm-hugetlb-cleanup-using-pagehugeactive-flag-fix mm/hugetlb.c
--- a/mm/hugetlb.c~mm-hugetlb-cleanup-using-pagehugeactive-flag-fix
+++ a/mm/hugetlb.c
@@ -3909,10 +3909,10 @@ int dequeue_hwpoisoned_huge_page(struct
 
 	spin_lock(&hugetlb_lock);
 	/*
-	 * Just checking !PageHugeActive is not enough, because that could be
+	 * Just checking !page_huge_active is not enough, because that could be
 	 * an isolated/hwpoisoned hugepage (which have >0 refcount).
 	 */
-	if (!PageHugeActive(hpage) && !page_count(hpage)) {
+	if (!page_huge_active(hpage) && !page_count(hpage)) {
 		/*
 		 * Hwpoisoned hugepage isn't linked to activelist or freelist,
 		 * but dangling hpage->lru can trigger list-debug warnings
diff -puN mm/memory_hotplug.c~mm-hugetlb-cleanup-using-pagehugeactive-flag-fix mm/memory_hotplug.c
--- a/mm/memory_hotplug.c~mm-hugetlb-cleanup-using-pagehugeactive-flag-fix
+++ a/mm/memory_hotplug.c
@@ -1373,7 +1373,7 @@ static unsigned long scan_movable_pages(
 			if (PageLRU(page))
 				return pfn;
 			if (PageHuge(page)) {
-				if (PageHugeActive(page))
+				if (page_huge_active(page))
 					return pfn;
 				else
 					pfn = round_up(pfn + 1,
diff -puN include/linux/page-flags.h~mm-hugetlb-cleanup-using-pagehugeactive-flag-fix include/linux/page-flags.h
--- a/include/linux/page-flags.h~mm-hugetlb-cleanup-using-pagehugeactive-flag-fix
+++ a/include/linux/page-flags.h
@@ -549,11 +549,18 @@ static inline void ClearPageCompound(str
 #ifdef CONFIG_HUGETLB_PAGE
 int PageHuge(struct page *page);
 int PageHeadHuge(struct page *page);
+bool page_huge_active(struct page *page);
 #else
 TESTPAGEFLAG_FALSE(Huge)
 TESTPAGEFLAG_FALSE(HeadHuge)
+
+static inline bool page_huge_active(struct page *page)
+{
+	return 0;
+}
 #endif
 
+
 #ifdef CONFIG_TRANSPARENT_HUGEPAGE
 /*
  * PageHuge() only returns true for hugetlbfs pages, but not for
_

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
