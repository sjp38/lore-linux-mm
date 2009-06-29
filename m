Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id 79F736B004D
	for <linux-mm@kvack.org>; Mon, 29 Jun 2009 05:56:47 -0400 (EDT)
Date: Mon, 29 Jun 2009 10:58:32 +0100
From: Mel Gorman <mel@csn.ul.ie>
Subject: Re: [PATCH] Hugepages should be accounted as unevictable pages.
Message-ID: <20090629095832.GF28597@csn.ul.ie>
References: <1245705941.26649.19.camel@alok-dev1>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <1245705941.26649.19.camel@alok-dev1>
Sender: owner-linux-mm@kvack.org
To: Alok Kataria <akataria@vmware.com>
Cc: LKML <linux-kernel@vger.kernel.org>, Lee Schermerhorn <Lee.Schermerhorn@hp.com>, Dave Hansen <dave@linux.vnet.ibm.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, Jun 22, 2009 at 02:25:41PM -0700, Alok Kataria wrote:
> Looking at the output of /proc/meminfo, a user might get confused in thinking
> that there are zero unevictable pages, though, in reality their can be
> hugepages which are inherently unevictable. 
> 

I think the problem may be with what meaning different people are
getting from "Unevictable"

For those of us that saw the Unevitable patches going by it means the number
of pages that could potentially be on the LRU lists but are not because
they are unevitable due to some action taken by the program - mlock() for
example. This does not include hugepages because we know they cannot be
reclaimed by any action other than directly freeing them.

The meaning you want is that Unevitable represents a count of the pages
that are unpagable such as pagetable pages, mlocked pages, hugepages,
etc.

> Though hugepages are not handled by the unevictable lru framework, they are
> infact unevictable in nature and global statistics counter should reflect that. 
> 

I somewhat disagree as the full count of unreclaimable pages can be
aggregated by looking at various statistics such as page table counts,
slab pages, locked, etc.

> For instance, I have allocated 20 huge pages on my system, meminfo shows this 
> 
> Unevictable:           0 kB
> Mlocked:               0 kB
> HugePages_Total:      20
> HugePages_Free:       20
> HugePages_Rsvd:        0
> HugePages_Surp:        0
> 

Note that the hugepages_total here is for the default hugepage size. If
there are other hugepages, you need to go to sysfs for them. If you are in
the kernel, you need to walk through the hstates and aggregate the counters.

> After the patch:
> 
> Unevictable:       81920 kB
> Mlocked:               0 kB
> HugePages_Total:      20
> HugePages_Free:       20
> HugePages_Rsvd:        0
> HugePages_Surp:        0
> 

I'm not keen on this to be honest but that's because I know Unevitable to
mean pages that potentially could be on the LRU but are not. I think that
people will want to consider that separetly from hugepage usage.

What I would be ok with is changing the output of meminfo slightly.
Output "Pinned" which is a total count of pages that cannot be reclaimed at
the moment. Give subheadings for that such as Unevitable LRU (potentially
broken further down to what makes up the unevictable LRU count), pagetables,
hugepages, etc.

At minimum, your changelog needs to state why you need this information and
how it's going to be used. It's not clear why you cannot just add Unevitable
+ pagetables + slab + HugePages_Total to get an approximation of the amount
of pinned memory for example.

> Signed-off-by: Alok N Kataria <akataria@vmware.com>
> Cc: Lee Schermerhorn <Lee.Schermerhorn@hp.com>
> Cc: Dave Hansen <dave@linux.vnet.ibm.com>
> Cc: Mel Gorman <mel@csn.ul.ie>
> 
> Index: linux-2.6/Documentation/vm/unevictable-lru.txt
> ===================================================================
> --- linux-2.6.orig/Documentation/vm/unevictable-lru.txt	2009-06-22 11:49:27.000000000 -0700
> +++ linux-2.6/Documentation/vm/unevictable-lru.txt	2009-06-22 13:57:32.000000000 -0700
> @@ -71,6 +71,12 @@ The unevictable list addresses the follo
>  
>   (*) Those mapped into VM_LOCKED [mlock()ed] VMAs.
>  
> + (*) Hugetlb pages are also unevictable. Hugepages are already implemented in
> +     a way that these pages don't reside on the LRU and hence are not iterated
> +     over during the vmscan. So there is no need to move around these pages
> +     across different LRU's. We just account these pages as unevictable for
> +     correct statistics.
> +
>  The infrastructure may also be able to handle other conditions that make pages
>  unevictable, either by definition or by circumstance, in the future.
>  
> Index: linux-2.6/mm/hugetlb.c
> ===================================================================
> --- linux-2.6.orig/mm/hugetlb.c	2009-06-22 11:49:57.000000000 -0700
> +++ linux-2.6/mm/hugetlb.c	2009-06-22 14:04:05.000000000 -0700
> @@ -533,6 +533,8 @@ static void update_and_free_page(struct 
>  				1 << PG_dirty | 1 << PG_active | 1 << PG_reserved |
>  				1 << PG_private | 1<< PG_writeback);
>  	}
> +	mod_zone_page_state(page_zone(page), NR_LRU_BASE + LRU_UNEVICTABLE,
> +				-(pages_per_huge_page(h)));
>  	set_compound_page_dtor(page, NULL);
>  	set_page_refcounted(page);
>  	arch_release_hugepage(page);
> @@ -584,6 +586,8 @@ static void prep_new_huge_page(struct hs
>  	spin_lock(&hugetlb_lock);
>  	h->nr_huge_pages++;
>  	h->nr_huge_pages_node[nid]++;
> +	mod_zone_page_state(page_zone(page), NR_LRU_BASE + LRU_UNEVICTABLE,
> +				pages_per_huge_page(h));
>  	spin_unlock(&hugetlb_lock);
>  	put_page(page); /* free it into the hugepage allocator */
>  }
> @@ -749,6 +753,9 @@ static struct page *alloc_buddy_huge_pag
>  		 */
>  		h->nr_huge_pages_node[nid]++;
>  		h->surplus_huge_pages_node[nid]++;
> +		mod_zone_page_state(page_zone(page),
> +					NR_LRU_BASE + LRU_UNEVICTABLE,
> +					pages_per_huge_page(h));
>  		__count_vm_event(HTLB_BUDDY_PGALLOC);
>  	} else {
>  		h->nr_huge_pages--;
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
