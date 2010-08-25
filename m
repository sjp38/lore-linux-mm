Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id ED9646B01F0
	for <linux-mm@kvack.org>; Tue, 24 Aug 2010 21:18:03 -0400 (EDT)
Date: Wed, 25 Aug 2010 09:21:31 +0800
From: Wu Fengguang <fengguang.wu@intel.com>
Subject: Re: [PATCH 3/8] hugetlb: rename hugepage allocation functions
Message-ID: <20100825012131.GC7283@localhost>
References: <1282694127-14609-1-git-send-email-n-horiguchi@ah.jp.nec.com>
 <1282694127-14609-4-git-send-email-n-horiguchi@ah.jp.nec.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1282694127-14609-4-git-send-email-n-horiguchi@ah.jp.nec.com>
Sender: owner-linux-mm@kvack.org
To: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Cc: Andi Kleen <andi@firstfloor.org>, Andrew Morton <akpm@linux-foundation.org>, Christoph Lameter <cl@linux-foundation.org>, Mel Gorman <mel@csn.ul.ie>, Jun'ichi Nomura <j-nomura@ce.jp.nec.com>, linux-mm <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

On Wed, Aug 25, 2010 at 07:55:22AM +0800, Naoya Horiguchi wrote:
> The function name alloc_huge_page_no_vma_node() has verbose suffix "_no_vma".
> This patch makes existing alloc_huge_page() and it's family have "_vma" instead,
> which makes it easier to read.
> 
> Signed-off-by: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
> ---
>  include/linux/hugetlb.h |    4 ++--
>  mm/hugetlb.c            |   20 ++++++++++----------
>  2 files changed, 12 insertions(+), 12 deletions(-)
> 
> diff --git v2.6.36-rc2/include/linux/hugetlb.h v2.6.36-rc2/include/linux/hugetlb.h
> index 142bd4f..0b73c53 100644
> --- v2.6.36-rc2/include/linux/hugetlb.h
> +++ v2.6.36-rc2/include/linux/hugetlb.h
> @@ -228,7 +228,7 @@ struct huge_bootmem_page {
>  	struct hstate *hstate;
>  };
>  
> -struct page *alloc_huge_page_no_vma_node(struct hstate *h, int nid);
> +struct page *alloc_huge_page_node(struct hstate *h, int nid);
>  
>  /* arch callback */
>  int __init alloc_bootmem_huge_page(struct hstate *h);
> @@ -305,7 +305,7 @@ static inline struct hstate *page_hstate(struct page *page)
>  
>  #else
>  struct hstate {};
> -#define alloc_huge_page_no_vma_node(h, nid) NULL
> +#define alloc_huge_page_node(h, nid) NULL
>  #define alloc_bootmem_huge_page(h) NULL
>  #define hstate_file(f) NULL
>  #define hstate_vma(v) NULL
> diff --git v2.6.36-rc2/mm/hugetlb.c v2.6.36-rc2/mm/hugetlb.c
> index 31118d2..674a25e 100644
> --- v2.6.36-rc2/mm/hugetlb.c
> +++ v2.6.36-rc2/mm/hugetlb.c
> @@ -666,7 +666,7 @@ static struct page *alloc_buddy_huge_page_node(struct hstate *h, int nid)
>   * E.g. soft-offlining uses this function because it only cares physical
>   * address of error page.
>   */
> -struct page *alloc_huge_page_no_vma_node(struct hstate *h, int nid)
> +struct page *alloc_huge_page_node(struct hstate *h, int nid)
>  {
>  	struct page *page;
>  
> @@ -818,7 +818,7 @@ static int free_pool_huge_page(struct hstate *h, nodemask_t *nodes_allowed,
>  	return ret;
>  }
>  
> -static struct page *alloc_buddy_huge_page(struct hstate *h,
> +static struct page *alloc_buddy_huge_page_vma(struct hstate *h,
>  			struct vm_area_struct *vma, unsigned long address)
>  {
>  	struct page *page;
> @@ -919,7 +919,7 @@ static int gather_surplus_pages(struct hstate *h, int delta)
>  retry:
>  	spin_unlock(&hugetlb_lock);
>  	for (i = 0; i < needed; i++) {
> -		page = alloc_buddy_huge_page(h, NULL, 0);
> +		page = alloc_buddy_huge_page_vma(h, NULL, 0);

alloc_buddy_huge_page() doesn't make use of @vma at all, so the
parameters can be removed.

It looks cleaner to fold the
alloc_huge_page_no_vma_node=>alloc_huge_page_node renames into the
previous patch, from there split out the code refactor chunks into
a standalone patch, and then include this cleanup patch.

Thanks,
Fengguang
---
hugetlb: remove unused alloc_buddy_huge_page() parameters

alloc_buddy_huge_page() doesn't make use of @vma at all, so the
parameters can be removed.

Signed-off-by: Wu Fengguang <fengguang.wu@intel.com>
---
diff --git a/mm/hugetlb.c b/mm/hugetlb.c
index cc5be78..3114b4c 100644
--- a/mm/hugetlb.c
+++ b/mm/hugetlb.c
@@ -770,8 +770,7 @@ static int free_pool_huge_page(struct hstate *h, nodemask_t *nodes_allowed,
 	return ret;
 }
 
-static struct page *alloc_buddy_huge_page(struct hstate *h,
-			struct vm_area_struct *vma, unsigned long address)
+static struct page *alloc_buddy_huge_page(struct hstate *h)
 {
 	struct page *page;
 	unsigned int nid;
@@ -871,7 +870,7 @@ static int gather_surplus_pages(struct hstate *h, int delta)
 retry:
 	spin_unlock(&hugetlb_lock);
 	for (i = 0; i < needed; i++) {
-		page = alloc_buddy_huge_page(h, NULL, 0);
+		page = alloc_buddy_huge_page(h);
 		if (!page) {
 			/*
 			 * We were not able to allocate enough pages to
@@ -1052,7 +1051,7 @@ static struct page *alloc_huge_page(struct vm_area_struct *vma,
 	spin_unlock(&hugetlb_lock);
 
 	if (!page) {
-		page = alloc_buddy_huge_page(h, vma, addr);
+		page = alloc_buddy_huge_page(h);
 		if (!page) {
 			hugetlb_put_quota(inode->i_mapping, chg);
 			return ERR_PTR(-VM_FAULT_SIGBUS);

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
