Message-ID: <43961949.8070900@yahoo.com.au>
Date: Wed, 07 Dec 2005 10:05:45 +1100
From: Nick Piggin <nickpiggin@yahoo.com.au>
MIME-Version: 1.0
Subject: Re: [RFC 2/3] Make nr_mapped a per node counter
References: <20051206182843.19188.82045.sendpatchset@schroedinger.engr.sgi.com> <20051206182848.19188.12787.sendpatchset@schroedinger.engr.sgi.com>
In-Reply-To: <20051206182848.19188.12787.sendpatchset@schroedinger.engr.sgi.com>
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: linux-kernel@vger.kernel.org, Hugh Dickins <hugh@veritas.com>, linux-mm@kvack.org, Andi Kleen <ak@suse.de>, Marcelo Tosatti <marcelo.tosatti@cyclades.com>
List-ID: <linux-mm.kvack.org>

Christoph Lameter wrote:
> Make nr_mapped a per node counter
> 
> The per cpu nr_mapped counter is important because it allows a determination
> how many pages of a node are not mapped, which would allow a more effiecient
> means of determining when a node should reclaim memory.
> 
> Signed-off-by: Christoph Lameter <clameter@sgi.com>
> 
> Index: linux-2.6.15-rc3/include/linux/page-flags.h
> ===================================================================
> --- linux-2.6.15-rc3.orig/include/linux/page-flags.h	2005-12-01 00:35:38.000000000 -0800
> +++ linux-2.6.15-rc3/include/linux/page-flags.h	2005-12-01 00:35:49.000000000 -0800
> @@ -85,7 +85,6 @@ struct page_state {
>  	unsigned long nr_writeback;	/* Pages under writeback */
>  	unsigned long nr_unstable;	/* NFS unstable pages */
>  	unsigned long nr_page_table_pages;/* Pages used for pagetables */
> -	unsigned long nr_mapped;	/* mapped into pagetables */
>  	unsigned long nr_slab;		/* In slab */
>  #define GET_PAGE_STATE_LAST nr_slab
>  
> @@ -165,8 +164,8 @@ extern void __mod_page_state(unsigned lo
>  /*
>   * Node based accounting with per cpu differentials.
>   */
> -enum node_stat_item { };
> -#define NR_STAT_ITEMS 0
> +enum node_stat_item { NR_MAPPED };
> +#define NR_STAT_ITEMS 1
>  
>  extern unsigned long vm_stat_global[NR_STAT_ITEMS];
>  extern unsigned long vm_stat_node[MAX_NUMNODES][NR_STAT_ITEMS];
> Index: linux-2.6.15-rc3/drivers/base/node.c
> ===================================================================
> --- linux-2.6.15-rc3.orig/drivers/base/node.c	2005-11-28 19:51:27.000000000 -0800
> +++ linux-2.6.15-rc3/drivers/base/node.c	2005-12-01 00:35:49.000000000 -0800
> @@ -53,8 +53,6 @@ static ssize_t node_read_meminfo(struct 
>  		ps.nr_dirty = 0;
>  	if ((long)ps.nr_writeback < 0)
>  		ps.nr_writeback = 0;
> -	if ((long)ps.nr_mapped < 0)
> -		ps.nr_mapped = 0;
>  	if ((long)ps.nr_slab < 0)
>  		ps.nr_slab = 0;
>  
> @@ -83,7 +81,7 @@ static ssize_t node_read_meminfo(struct 
>  		       nid, K(i.freeram - i.freehigh),
>  		       nid, K(ps.nr_dirty),
>  		       nid, K(ps.nr_writeback),
> -		       nid, K(ps.nr_mapped),
> +		       nid, K(vm_stat_node[nid][NR_MAPPED]),
>  		       nid, K(ps.nr_slab));
>  	n += hugetlb_report_node_meminfo(nid, buf + n);
>  	return n;
> Index: linux-2.6.15-rc3/fs/proc/proc_misc.c
> ===================================================================
> --- linux-2.6.15-rc3.orig/fs/proc/proc_misc.c	2005-11-28 19:51:27.000000000 -0800
> +++ linux-2.6.15-rc3/fs/proc/proc_misc.c	2005-12-01 00:35:49.000000000 -0800
> @@ -190,7 +190,7 @@ static int meminfo_read_proc(char *page,
>  		K(i.freeswap),
>  		K(ps.nr_dirty),
>  		K(ps.nr_writeback),
> -		K(ps.nr_mapped),
> +		K(vm_stat_global[NR_MAPPED]),
>  		K(ps.nr_slab),
>  		K(allowed),
>  		K(committed),
> Index: linux-2.6.15-rc3/mm/vmscan.c
> ===================================================================
> --- linux-2.6.15-rc3.orig/mm/vmscan.c	2005-11-28 19:51:27.000000000 -0800
> +++ linux-2.6.15-rc3/mm/vmscan.c	2005-12-01 00:35:49.000000000 -0800
> @@ -967,7 +967,7 @@ int try_to_free_pages(struct zone **zone
>  	}
>  
>  	for (priority = DEF_PRIORITY; priority >= 0; priority--) {
> -		sc.nr_mapped = read_page_state(nr_mapped);
> +		sc.nr_mapped = vm_stat_global[NR_MAPPED];
>  		sc.nr_scanned = 0;
>  		sc.nr_reclaimed = 0;
>  		sc.priority = priority;
> @@ -1056,7 +1056,7 @@ loop_again:
>  	sc.gfp_mask = GFP_KERNEL;
>  	sc.may_writepage = 0;
>  	sc.may_swap = 1;
> -	sc.nr_mapped = read_page_state(nr_mapped);
> +	sc.nr_mapped = vm_stat_global[NR_MAPPED];
>  

Any chance you can wrap these in macros? (something like read_page_node_state())

I gather Andrew did this so that they can easily be defined out for things
that don't want them (maybe, embedded systems).

-- 
SUSE Labs, Novell Inc.

Send instant messages to your online friends http://au.messenger.yahoo.com 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
