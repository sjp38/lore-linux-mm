Date: Tue, 21 Oct 2008 09:34:54 +0100
Subject: Re: [memcg BUG] unable to handle kernel NULL pointer derefence at 00000000
Message-ID: <20081021083454.GA2427@csn.ul.ie>
References: <6599ad830810201253u3bca41d4rabe48eb1ec1d529f@mail.gmail.com> <20081021101430.d2629a81.kamezawa.hiroyu@jp.fujitsu.com> <48FD6901.6050301@linux.vnet.ibm.com> <20081021143955.eeb86d49.kamezawa.hiroyu@jp.fujitsu.com> <48FD74AB.9010307@cn.fujitsu.com> <20081021155454.db6888e4.kamezawa.hiroyu@jp.fujitsu.com> <48FD7EEF.3070803@cn.fujitsu.com> <20081021161621.bb51af90.kamezawa.hiroyu@jp.fujitsu.com> <48FD82E3.9050502@cn.fujitsu.com> <20081021171801.4c16c295.kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20081021171801.4c16c295.kamezawa.hiroyu@jp.fujitsu.com>
From: mel@skynet.ie (Mel Gorman)
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Li Zefan <lizf@cn.fujitsu.com>, balbir@linux.vnet.ibm.com, Paul Menage <menage@google.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Oct 21, 2008 at 05:18:01PM +0900, KAMEZAWA Hiroyuki wrote:
> On Tue, 21 Oct 2008 15:21:07 +0800
> Li Zefan <lizf@cn.fujitsu.com> wrote:
> > dmesg is attached.
> > 
> Thanks....I think I caught some. (added Mel Gorman to CC:)
> 
> NODE_DATA(nid)->spanned_pages just means sum of zone->spanned_pages in node.
> 
> So, If there is a hole between zone, node->spanned_pages doesn't mean
> length of node's memmap....(then, some hole can be skipped.)
> 

This is correct. pgdat->node_spanned_pages is the range of PFNs the node
covers. In some cases, this can even overlap other nodes. There can be
memory holes and there is no guarantee there is memmap present for the holes.
The number of actual pages is pgdat->node_present_pages.

> OMG....Could you try this ? 
> 
> -Kame
> ==
> NODE_DATA(nid)->node_spanned_pages doesn't means width of node's memory
> but means sum of spanned_pages in all zones of node.
> 

Does not necessarily mean that either. Conceivably there could be gaps
between the zones.

> alloc_node_page_cgroup() misunderstand it. This patch tries to use
> the same algorithm as alloc_node_mem_map() for allocating page_cgroup()
> for node.
> 
> Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> 
>  mm/page_cgroup.c |   17 ++++++++++++++---
>  1 file changed, 14 insertions(+), 3 deletions(-)
> 
> Index: linux-2.6.27/mm/page_cgroup.c
> ===================================================================
> --- linux-2.6.27.orig/mm/page_cgroup.c
> +++ linux-2.6.27/mm/page_cgroup.c
> @@ -41,10 +41,18 @@ static int __init alloc_node_page_cgroup
>  {
>  	struct page_cgroup *base, *pc;
>  	unsigned long table_size;
> -	unsigned long start_pfn, nr_pages, index;
> +	unsigned long start, end, start_pfn, nr_pages, index;
>  
> -	start_pfn = NODE_DATA(nid)->node_start_pfn;
> -	nr_pages = NODE_DATA(nid)->node_spanned_pages;
> +	/*
> +	 * Instead of allocating page_cgroup for [start, end)
> +	 * We allocate page_cgroup to the same size of mem_map.
> +	 * See page_alloc.c::alloc_node_mem_map()
> +	 */
> +	start = NODE_DATA(nid)->node_start_pfn & ~(MAX_ORDER_NR_PAGES - 1);
> +	end = NODE_DATA(nid)->node_start_pfn
> +			+ NODE_DATA(nid)->node_spanned_pages;
> +	end = ALIGN(end, MAX_ORDER_NR_PAGES);
> +	nr_pages = end - start;
>  

I don't know what this function is doing, but that will calculate nr_pages
to be the full width of a node, holes and all which is what I think you're
trying to do. Again, remember this could cover another node as you can have
a situation where the pfn ranges are

      node1_pages   |   node0_pages	|  node1_pages
start <---------------------------------------------->end

Maybe this is not a problem for you. It all depends on how you map a PFN
to a table. There is also a concern for memory usage as;

>  	table_size = sizeof(struct page_cgroup) * nr_pages;
>  

this is potentially a very large table.

> @@ -52,6 +60,9 @@ static int __init alloc_node_page_cgroup
>  			table_size, PAGE_SIZE, __pa(MAX_DMA_ADDRESS));
>  	if (!base)
>  		return -ENOMEM;
> +
> +	start_pfn = NODE_DATA(nid)->node_start_pfn;
> +	base = base + start_pfn - start;
>  	for (index = 0; index < nr_pages; index++) {
>  		pc = base + index;
>  		__init_page_cgroup(pc, start_pfn + index);
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
