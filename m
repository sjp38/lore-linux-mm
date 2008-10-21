Message-ID: <48FD9D30.2030500@cn.fujitsu.com>
Date: Tue, 21 Oct 2008 17:13:20 +0800
From: Li Zefan <lizf@cn.fujitsu.com>
MIME-Version: 1.0
Subject: Re: [memcg BUG] unable to handle kernel NULL pointer derefence at
 00000000
References: <20081017194804.fce28258.nishimura@mxp.nes.nec.co.jp>	<20081017195601.0b9abda1.nishimura@mxp.nes.nec.co.jp>	<6599ad830810201253u3bca41d4rabe48eb1ec1d529f@mail.gmail.com>	<20081021101430.d2629a81.kamezawa.hiroyu@jp.fujitsu.com>	<48FD6901.6050301@linux.vnet.ibm.com>	<20081021143955.eeb86d49.kamezawa.hiroyu@jp.fujitsu.com>	<48FD74AB.9010307@cn.fujitsu.com>	<20081021155454.db6888e4.kamezawa.hiroyu@jp.fujitsu.com>	<48FD7EEF.3070803@cn.fujitsu.com>	<20081021161621.bb51af90.kamezawa.hiroyu@jp.fujitsu.com>	<48FD82E3.9050502@cn.fujitsu.com>	<20081021171801.4c16c295.kamezawa.hiroyu@jp.fujitsu.com>	<48FD943D.5090709@cn.fujitsu.com> <20081021175735.0c3d3534.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20081021175735.0c3d3534.kamezawa.hiroyu@jp.fujitsu.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: balbir@linux.vnet.ibm.com, Paul Menage <menage@google.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, linux-mm@kvack.org, mel@csn.ul.ie
List-ID: <linux-mm.kvack.org>

KAMEZAWA Hiroyuki wrote:
> On Tue, 21 Oct 2008 16:35:09 +0800
> Li Zefan <lizf@cn.fujitsu.com> wrote:
> 
>> KAMEZAWA Hiroyuki wrote:
>>> On Tue, 21 Oct 2008 15:21:07 +0800
>>> Li Zefan <lizf@cn.fujitsu.com> wrote:
>>>> dmesg is attached.
>>>>
>>> Thanks....I think I caught some. (added Mel Gorman to CC:)
>>>
>>> NODE_DATA(nid)->spanned_pages just means sum of zone->spanned_pages in node.
>>>
>>> So, If there is a hole between zone, node->spanned_pages doesn't mean
>>> length of node's memmap....(then, some hole can be skipped.)
>>>
>>> OMG....Could you try this ? 
>>>
>> No luck, the same bug still exists. :(
>>
> This is a little fixed one..
> 

I tried the patch, but it doesn't solve the problem..

> please..
> -Kame
> ==
> NODE_DATA(nid)->node_spanned_pages doesn't means width of node's memory.
> 
> alloc_node_page_cgroup() misunderstand it. This patch tries to use
> the same algorithm as alloc_node_mem_map() for allocating page_cgroup()
> for node.
> 
> Changelog:
>  - fixed range of initialization loop.
> 
> Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> 
>  mm/page_cgroup.c |   19 +++++++++++++++----
>  1 file changed, 15 insertions(+), 4 deletions(-)
> 
> Index: linux-2.6.27/mm/page_cgroup.c
> ===================================================================
> --- linux-2.6.27.orig/mm/page_cgroup.c
> +++ linux-2.6.27/mm/page_cgroup.c
> @@ -9,6 +9,8 @@
>  static void __meminit
>  __init_page_cgroup(struct page_cgroup *pc, unsigned long pfn)
>  {
> +	if (!pfn_valid(pfn))
> +		return;
>  	pc->flags = 0;
>  	pc->mem_cgroup = NULL;
>  	pc->page = pfn_to_page(pfn);
> @@ -41,10 +43,18 @@ static int __init alloc_node_page_cgroup
>  {
>  	struct page_cgroup *base, *pc;
>  	unsigned long table_size;
> -	unsigned long start_pfn, nr_pages, index;
> +	unsigned long start, end, start_pfn, nr_pages, index;
>  
> +	/*
> +	 * Instead of allocating page_cgroup for [start, end)
> +	 * We allocate page_cgroup to the same size of mem_map.
> +	 * See page_alloc.c::alloc_node_mem_map()
> +	 */
>  	start_pfn = NODE_DATA(nid)->node_start_pfn;
> -	nr_pages = NODE_DATA(nid)->node_spanned_pages;
> +	start = start_pfn & ~(MAX_ORDER_NR_PAGES - 1);
> +	end = start_pfn	+ NODE_DATA(nid)->node_spanned_pages;
> +	end = ALIGN(end, MAX_ORDER_NR_PAGES);
> +	nr_pages = end - start;
>  
>  	table_size = sizeof(struct page_cgroup) * nr_pages;
>  
> @@ -52,11 +62,12 @@ static int __init alloc_node_page_cgroup
>  			table_size, PAGE_SIZE, __pa(MAX_DMA_ADDRESS));
>  	if (!base)
>  		return -ENOMEM;
> +
>  	for (index = 0; index < nr_pages; index++) {
>  		pc = base + index;
> -		__init_page_cgroup(pc, start_pfn + index);
> +		__init_page_cgroup(pc, start + index);
>  	}
> -	NODE_DATA(nid)->node_page_cgroup = base;
> +	NODE_DATA(nid)->node_page_cgroup = base + start_pfn - start;
>  	total_usage += table_size;
>  	return 0;
>  }
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
