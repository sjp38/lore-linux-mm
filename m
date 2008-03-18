Date: Tue, 18 Mar 2008 16:37:15 +0000
From: Mel Gorman <mel@csn.ul.ie>
Subject: Re: [PATCH] [14/18] Clean up hugetlb boot time printk
Message-ID: <20080318163715.GN23866@csn.ul.ie>
References: <20080317258.659191058@firstfloor.org> <20080317015828.1AB091B41E0@basil.firstfloor.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20080317015828.1AB091B41E0@basil.firstfloor.org>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andi Kleen <andi@firstfloor.org>
Cc: linux-kernel@vger.kernel.org, pj@sgi.com, linux-mm@kvack.org, nickpiggin@yahoo.com.au
List-ID: <linux-mm.kvack.org>

On (17/03/08 02:58), Andi Kleen didst pronounce:
> - Reword sentence to clarify meaning with multiple options
> - Add support for using GB prefixes for the page size
> - Add extra printk to delayed > MAX_ORDER allocation code
> 

Scratch earlier comments about this printk. If the printk fix
was broken out, it could be moved to the start of the set so it can be
tested/merged separetly. The remainder of this patch could then be
folded into the patch allowing 1GB pages to be reserved at boot-time.

> Signed-off-by: Andi Kleen <ak@suse.de>
> 
> ---
>  mm/hugetlb.c |   33 ++++++++++++++++++++++++++++++---
>  1 file changed, 30 insertions(+), 3 deletions(-)
> 
> Index: linux/mm/hugetlb.c
> ===================================================================
> --- linux.orig/mm/hugetlb.c
> +++ linux/mm/hugetlb.c
> @@ -510,6 +510,15 @@ static struct page *alloc_huge_page(stru
>  	return page;
>  }
>  
> +static __init char *memfmt(char *buf, unsigned long n)
> +{
> +	if (n >= (1UL << 30))
> +		sprintf(buf, "%lu GB", n >> 30);
> +	else
> +		sprintf(buf, "%lu MB", n >> 20);
> +	return buf;
> +}
> +
>  static __initdata LIST_HEAD(huge_boot_pages);
>  
>  struct huge_bm_page {
> @@ -536,14 +545,28 @@ static int __init alloc_bm_huge_page(str
>  /* Put bootmem huge pages into the standard lists after mem_map is up */
>  static int __init huge_init_bm(void)
>  {
> +	unsigned long pages = 0;
>  	struct huge_bm_page *m;
> +	struct hstate *h = NULL;
> +	char buf[32];
> +
>  	list_for_each_entry (m, &huge_boot_pages, list) {
>  		struct page *page = virt_to_page(m);
> -		struct hstate *h = m->hstate;
> +		h = m->hstate;
>  		__ClearPageReserved(page);
>  		prep_compound_page(page, h->order);
>  		huge_new_page(h, page);
> +		pages++;
>  	}
> +
> +	/*
> +	 * This only prints for a single hstate. This works for x86-64,
> +	 * but if you do multiple > MAX_ORDER hstates you'll need to fix it.
> +	 */
> +	if (pages > 0)
> +		printk(KERN_INFO "HugeTLB pre-allocated %ld %s pages\n",
> +				h->free_huge_pages,
> +				memfmt(buf, huge_page_size(h)));
>  	return 0;
>  }
>  __initcall(huge_init_bm);
> @@ -551,6 +574,8 @@ __initcall(huge_init_bm);
>  static int __init hugetlb_init_hstate(struct hstate *h)
>  {
>  	unsigned long i;
> +	char buf[32];
> +	unsigned long pages = 0;
>  
>  	/* Don't reinitialize lists if they have been already init'ed */
>  	if (!h->hugepage_freelists[0].next) {
> @@ -567,12 +592,14 @@ static int __init hugetlb_init_hstate(st
>  		} else if (!alloc_fresh_huge_page(h))
>  			break;
>  		h->parsed_hugepages++;
> +		pages++;
>  	}
>  	max_huge_pages[h - hstates] = h->parsed_hugepages;
>  
> -	printk(KERN_INFO "Total HugeTLB memory allocated, %ld %dMB pages\n",
> +	if (pages > 0)
> +		printk(KERN_INFO "HugeTLB pre-allocated %ld %s pages\n",
>  			h->free_huge_pages,
> -			1 << (h->order + PAGE_SHIFT - 20));
> +			memfmt(buf, huge_page_size(h)));
>  	return 0;
>  }
>  
> 

-- 
Mel Gorman
Part-time Phd Student                          Linux Technology Center
University of Limerick                         IBM Dublin Software Lab

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
