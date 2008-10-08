From: Nick Piggin <nickpiggin@yahoo.com.au>
Subject: Re: [PATCH 1/1] hugetlb: pull gigantic page initialisation out of the default path
Date: Wed, 8 Oct 2008 23:31:45 +1100
References: <1223458499-12752-1-git-send-email-apw@shadowen.org>
In-Reply-To: <1223458499-12752-1-git-send-email-apw@shadowen.org>
MIME-Version: 1.0
Content-Type: text/plain;
  charset="utf-8"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Message-Id: <200810082331.45359.nickpiggin@yahoo.com.au>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andy Whitcroft <apw@shadowen.org>
Cc: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, Jon Tollefson <kniht@linux.vnet.ibm.com>, Mel Gorman <mel@csn.ul.ie>
List-ID: <linux-mm.kvack.org>

On Wednesday 08 October 2008 20:34, Andy Whitcroft wrote:
> As we can determine exactly when a gigantic page is in use we can optimise
> the common regular page cases by pulling out gigantic page initialisation
> into its own function.  As gigantic pages are never released to buddy we
> do not need a destructor.  This effectivly reverts the previous change
> to the main buddy allocator.  It also adds a paranoid check to ensure we
> never release gigantic pages from hugetlbfs to the main buddy.

Thanks for doing this. Can prep_compound_gigantic_page be #ifdef HUGETLB?


> Signed-off-by: Andy Whitcroft <apw@shadowen.org>
> Cc: Nick Piggin <nickpiggin@yahoo.com.au>
> ---
>  mm/hugetlb.c    |    4 +++-
>  mm/internal.h   |    1 +
>  mm/page_alloc.c |   26 +++++++++++++++++++-------
>  3 files changed, 23 insertions(+), 8 deletions(-)
>
> diff --git a/mm/hugetlb.c b/mm/hugetlb.c
> index bb5cf81..716b151 100644
> --- a/mm/hugetlb.c
> +++ b/mm/hugetlb.c
> @@ -460,6 +460,8 @@ static void update_and_free_page(struct hstate *h,
> struct page *page) {
>  	int i;
>
> +	BUG_ON(h->order >= MAX_ORDER);
> +
>  	h->nr_huge_pages--;
>  	h->nr_huge_pages_node[page_to_nid(page)]--;
>  	for (i = 0; i < pages_per_huge_page(h); i++) {
> @@ -984,7 +986,7 @@ static void __init gather_bootmem_prealloc(void)
>  		struct hstate *h = m->hstate;
>  		__ClearPageReserved(page);
>  		WARN_ON(page_count(page) != 1);
> -		prep_compound_page(page, h->order);
> +		prep_compound_gigantic_page(page, h->order);
>  		prep_new_huge_page(h, page, page_to_nid(page));
>  	}
>  }
> diff --git a/mm/internal.h b/mm/internal.h
> index 08b8dea..92729ea 100644
> --- a/mm/internal.h
> +++ b/mm/internal.h
> @@ -17,6 +17,7 @@ void free_pgtables(struct mmu_gather *tlb, struct
> vm_area_struct *start_vma, unsigned long floor, unsigned long ceiling);
>
>  extern void prep_compound_page(struct page *page, unsigned long order);
> +extern void prep_compound_gigantic_page(struct page *page, unsigned long
> order);
>
>  static inline void set_page_count(struct page *page, int v)
>  {
> diff --git a/mm/page_alloc.c b/mm/page_alloc.c
> index 27b8681..dbeb3f8 100644
> --- a/mm/page_alloc.c
> +++ b/mm/page_alloc.c
> @@ -268,14 +268,28 @@ void prep_compound_page(struct page *page, unsigned
> long order) {
>  	int i;
>  	int nr_pages = 1 << order;
> +
> +	set_compound_page_dtor(page, free_compound_page);
> +	set_compound_order(page, order);
> +	__SetPageHead(page);
> +	for (i = 1; i < nr_pages; i++) {
> +		struct page *p = page + i;
> +
> +		__SetPageTail(p);
> +		p->first_page = page;
> +	}
> +}
> +
> +void prep_compound_gigantic_page(struct page *page, unsigned long order)
> +{
> +	int i;
> +	int nr_pages = 1 << order;
>  	struct page *p = page + 1;
>
>  	set_compound_page_dtor(page, free_compound_page);
>  	set_compound_order(page, order);
>  	__SetPageHead(page);
> -	for (i = 1; i < nr_pages; i++, p++) {
> -		if (unlikely((i & (MAX_ORDER_NR_PAGES - 1)) == 0))
> -			p = pfn_to_page(page_to_pfn(page) + i);
> +	for (i = 1; i < nr_pages; i++, p = mem_map_next(p, page, i)) {
>  		__SetPageTail(p);
>  		p->first_page = page;
>  	}
> @@ -285,7 +299,6 @@ static void destroy_compound_page(struct page *page,
> unsigned long order) {
>  	int i;
>  	int nr_pages = 1 << order;
> -	struct page *p = page + 1;
>
>  	if (unlikely(compound_order(page) != order))
>  		bad_page(page);
> @@ -293,9 +306,8 @@ static void destroy_compound_page(struct page *page,
> unsigned long order) if (unlikely(!PageHead(page)))
>  			bad_page(page);
>  	__ClearPageHead(page);
> -	for (i = 1; i < nr_pages; i++, p++) {
> -		if (unlikely((i & (MAX_ORDER_NR_PAGES - 1)) == 0))
> -			p = pfn_to_page(page_to_pfn(page) + i);
> +	for (i = 1; i < nr_pages; i++) {
> +		struct page *p = page + i;
>
>  		if (unlikely(!PageTail(p) |
>  				(p->first_page != page)))

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
