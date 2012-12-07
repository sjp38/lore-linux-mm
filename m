Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx196.postini.com [74.125.245.196])
	by kanga.kvack.org (Postfix) with SMTP id 61BE76B0068
	for <linux-mm@kvack.org>; Fri,  7 Dec 2012 00:49:07 -0500 (EST)
From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Subject: Re: [PATCH 1/3] HWPOISON, hugetlbfs: fix warning on freeing hwpoisoned hugepage
Date: Fri,  7 Dec 2012 00:48:57 -0500
Message-Id: <1354859337-11612-1-git-send-email-n-horiguchi@ah.jp.nec.com>
In-Reply-To: <20121206182024.5f3b47be.akpm@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Andi Kleen <andi.kleen@intel.com>, Tony Luck <tony.luck@intel.com>, Wu Fengguang <fengguang.wu@intel.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Thu, Dec 06, 2012 at 06:20:24PM -0800, Andrew Morton wrote:
> On Thu,  6 Dec 2012 21:03:44 -0500 Naoya Horiguchi <n-horiguchi@ah.jp.nec.com> wrote:
> 
> > This patch fixes the warning from __list_del_entry() which is triggered
> > when a process tries to do free_huge_page() for a hwpoisoned hugepage.
> > 
> > ChangeLog v2:
> >  - simply use list_del_init instead of introducing new hugepage list
> > 
> > Signed-off-by: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
> > ---
> >  mm/hugetlb.c | 2 +-
> >  1 file changed, 1 insertion(+), 1 deletion(-)
> > 
> > diff --git a/mm/hugetlb.c b/mm/hugetlb.c
> > index 59a0059..9308752 100644
> > --- a/mm/hugetlb.c
> > +++ b/mm/hugetlb.c
> > @@ -3170,7 +3170,7 @@ int dequeue_hwpoisoned_huge_page(struct page *hpage)
> >  
> >  	spin_lock(&hugetlb_lock);
> >  	if (is_hugepage_on_freelist(hpage)) {
> > -		list_del(&hpage->lru);
> > +		list_del_init(&hpage->lru);
> 
> Can we please have a code comment in here explaining why
> list_del_init() is used?

OK, I added it.
---
From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Date: Thu, 6 Dec 2012 20:54:30 -0500
Subject: [PATCH v3] HWPOISON, hugetlbfs: fix warning on freeing hwpoisoned
 hugepage

This patch fixes the warning from __list_del_entry() which is triggered
when a process tries to do free_huge_page() for a hwpoisoned hugepage.

ChangeLog v3:
 - add comment

ChangeLog v2:
 - simply use list_del_init instead of introducing new hugepage list

Signed-off-by: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
---
 mm/hugetlb.c | 7 ++++++-
 1 file changed, 6 insertions(+), 1 deletion(-)

diff --git a/mm/hugetlb.c b/mm/hugetlb.c
index 59a0059..df03345 100644
--- a/mm/hugetlb.c
+++ b/mm/hugetlb.c
@@ -3170,7 +3170,12 @@ int dequeue_hwpoisoned_huge_page(struct page *hpage)
 
 	spin_lock(&hugetlb_lock);
 	if (is_hugepage_on_freelist(hpage)) {
-		list_del(&hpage->lru);
+		/* 
+		 * Hwpoisoned hugepage isn't linked to activelist or freelist,
+		 * but dangling hpage->lru can trigger list-debug warnings,
+		 * so let it point to itself with list_del_init().
+		 */
+		list_del_init(&hpage->lru);
 		set_page_refcounted(hpage);
 		h->free_huge_pages--;
 		h->free_huge_pages_node[nid]--;
-- 
1.7.11.7

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
