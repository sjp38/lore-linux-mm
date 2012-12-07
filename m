Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx143.postini.com [74.125.245.143])
	by kanga.kvack.org (Postfix) with SMTP id D38F76B006C
	for <linux-mm@kvack.org>; Fri,  7 Dec 2012 10:50:38 -0500 (EST)
From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Subject: Re: [PATCH 1/3] HWPOISON, hugetlbfs: fix warning on freeing hwpoisoned hugepage
Date: Fri,  7 Dec 2012 10:49:57 -0500
Message-Id: <1354895397-21736-1-git-send-email-n-horiguchi@ah.jp.nec.com>
In-Reply-To: <878v9acn5m.fsf@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: aneesh.kumar@linux.vnet.ibm.com
Cc: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Andrew Morton <akpm@linux-foundation.org>, Andi Kleen <andi.kleen@intel.com>, Tony Luck <tony.luck@intel.com>, Wu Fengguang <fengguang.wu@intel.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Fri, Dec 07, 2012 at 01:24:45PM +0530, Aneesh Kumar K.V wrote:
> Naoya Horiguchi <n-horiguchi@ah.jp.nec.com> writes:
> 
> > On Fri, Dec 07, 2012 at 11:06:41AM +0530, Aneesh Kumar K.V wrote:
> > ...
> >> > From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
> >> > Date: Thu, 6 Dec 2012 20:54:30 -0500
> >> > Subject: [PATCH v2] HWPOISON, hugetlbfs: fix warning on freeing hwpoisoned
> >> >  hugepage
> >> >
> >> > This patch fixes the warning from __list_del_entry() which is triggered
> >> > when a process tries to do free_huge_page() for a hwpoisoned hugepage.
> >> 
> >> 
> >> Can you get a dump stack for that. I am confused because the page was
> >> already in freelist, and we deleted it from the list and set the
> >> refcount to 1. So how are we reaching free_huge_page() again ?
> >
> > free_huge_page() can be called for hwpoisoned hugepage from unpoison_memory().
> > This function gets refcount once and clears PageHWPoison, and then puts
> > refcount twice to return the hugepage back to free pool.
> > The second put_page() finally reaches free_huge_page().
> >
> 
> Can we add this also to the commit message ?. With that you can add
> 
> Reviewed-by: Aneesh Kumar K.V <aneesh.kumar@linux.vnet.ibm.com>

OK, I added it.
Thanks for the review!

Naoya
---
From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Date: Thu, 6 Dec 2012 20:54:30 -0500
Subject: [PATCH v4] HWPOISON, hugetlbfs: fix warning on freeing hwpoisoned
 hugepage

This patch fixes the warning from __list_del_entry() which is triggered
when a process tries to do free_huge_page() for a hwpoisoned hugepage.

ChangeLog v4:
 - Add comment about when the warning is triggered

ChangeLog v3:
 - Add comment

ChangeLog v2:
 - simply use list_del_init instead of introducing new hugepage list

Signed-off-by: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Reviewed-by: Aneesh Kumar K.V <aneesh.kumar@linux.vnet.ibm.com>
---
 mm/hugetlb.c | 8 +++++++-
 1 file changed, 7 insertions(+), 1 deletion(-)

diff --git a/mm/hugetlb.c b/mm/hugetlb.c
index 59a0059..2511bcb 100644
--- a/mm/hugetlb.c
+++ b/mm/hugetlb.c
@@ -3170,7 +3170,13 @@ int dequeue_hwpoisoned_huge_page(struct page *hpage)
 
 	spin_lock(&hugetlb_lock);
 	if (is_hugepage_on_freelist(hpage)) {
-		list_del(&hpage->lru);
+		/* 
+		 * Hwpoisoned hugepage isn't linked to activelist or freelist,
+		 * but dangling hpage->lru can trigger list-debug warnings
+		 * (this happens when we call unpoison_memory() on it),
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
