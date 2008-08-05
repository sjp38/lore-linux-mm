From: Nick Piggin <nickpiggin@yahoo.com.au>
Subject: Re: [PATCH] hugetlb: call arch_prepare_hugepage() for surplus pages
Date: Wed, 6 Aug 2008 01:36:16 +1000
References: <1217950147.5032.15.camel@localhost.localdomain>
In-Reply-To: <1217950147.5032.15.camel@localhost.localdomain>
MIME-Version: 1.0
Content-Type: text/plain;
  charset="utf-8"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Message-Id: <200808060136.17277.nickpiggin@yahoo.com.au>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Gerald Schaefer <gerald.schaefer@de.ibm.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-s390@vger.kernel.org, schwidefsky@de.ibm.com, heiko.carstens@de.ibm.com, Nishanth Aravamudan <nacc@us.ibm.com>, Adam Litke <agl@us.ibm.com>
List-ID: <linux-mm.kvack.org>

On Wednesday 06 August 2008 01:29, Gerald Schaefer wrote:
> From: Gerald Schaefer <gerald.schaefer@de.ibm.com>
>
> The s390 software large page emulation implements shared page tables
> by using page->index of the first tail page from a compound large page
> to store page table information. This is set up in arch_prepare_hugepage(),
> which is called from alloc_fresh_huge_page_node().
>
> A similar call to arch_prepare_hugepage() is missing for surplus large
> pages that are allocated in alloc_buddy_huge_page(), which breaks the
> software emulation mode for (surplus) large pages on s390. This patch
> adds the missing call to arch_prepare_hugepage(). It will have no effect
> on other architectures where arch_prepare_hugepage() is a nop.
>
> Acked-by: Martin Schwidefsky <schwidefsky@de.ibm.com>
> Signed-off-by: Gerald Schaefer <gerald.schaefer@de.ibm.com>
> ---
>
>  mm/hugetlb.c |    7 ++++++-
>  1 file changed, 6 insertions(+), 1 deletion(-)
>
> Index: linux/mm/hugetlb.c
> ===================================================================
> --- linux.orig/mm/hugetlb.c
> +++ linux/mm/hugetlb.c
> @@ -565,7 +565,7 @@ static struct page *alloc_fresh_huge_pag
>  		huge_page_order(h));
>  	if (page) {
>  		if (arch_prepare_hugepage(page)) {
> -			__free_pages(page, HUGETLB_PAGE_ORDER);
> +			__free_pages(page, huge_page_order(h));
>  			return NULL;
>  		}
>  		prep_new_huge_page(h, page, nid);

This looks like a seperate bugfix?


> @@ -665,6 +665,11 @@ static struct page *alloc_buddy_huge_pag
>  					__GFP_REPEAT|__GFP_NOWARN,
>  					huge_page_order(h));
>
> +	if (page && arch_prepare_hugepage(page)) {
> +		__free_pages(page, huge_page_order(h));
> +		return NULL;
> +	}
> +
>  	spin_lock(&hugetlb_lock);
>  	if (page) {
>  		/*

Acked-by: Nick Piggin <npiggin@suse.de>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
