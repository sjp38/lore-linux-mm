Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id BBA3B6B004D
	for <linux-mm@kvack.org>; Thu, 11 Jun 2009 22:47:04 -0400 (EDT)
Message-ID: <4A31C258.2050404@cn.fujitsu.com>
Date: Fri, 12 Jun 2009 10:50:00 +0800
From: Li Zefan <lizf@cn.fujitsu.com>
MIME-Version: 1.0
Subject: boot panic with memcg enabled (Was [PATCH 3/4] memcg: don't use bootmem
 allocator in setup code)
References: <Pine.LNX.4.64.0906110820170.2258@melkki.cs.Helsinki.FI>
In-Reply-To: <Pine.LNX.4.64.0906110820170.2258@melkki.cs.Helsinki.FI>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Pekka J Enberg <penberg@cs.helsinki.fi>
Cc: linux-kernel@vger.kernel.org, mingo@elte.hu, hannes@cmpxchg.org, torvalds@linux-foundation.org, yinghai@kernel.org, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Balbir Singh <balbir@linux.vnet.ibm.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

(This patch should have CCed memcg maitainers)

My box failed to boot due to initialization failure of page_cgroup, and
it's caused by this patch:

+	page = alloc_pages_node(nid, GFP_NOWAIT | __GFP_ZERO, order);

I added a printk, and found that order == 11 == MAX_ORDER.

Pekka J Enberg wrote:
> From: Yinghai Lu <yinghai@kernel.org>
> 
> The bootmem allocator is no longer available for page_cgroup_init() because we
> set up the kernel slab allocator much earlier now.
> 
> Cc: Ingo Molnar <mingo@elte.hu>
> Cc: Johannes Weiner <hannes@cmpxchg.org>
> Cc: Linus Torvalds <torvalds@linux-foundation.org>
> Signed-off-by: Yinghai Lu <yinghai@kernel.org>
> Signed-off-by: Pekka Enberg <penberg@cs.helsinki.fi>
> ---
>  mm/page_cgroup.c |   12 ++++++++----
>  1 files changed, 8 insertions(+), 4 deletions(-)
> 
> diff --git a/mm/page_cgroup.c b/mm/page_cgroup.c
> index 791905c..3dd4a90 100644
> --- a/mm/page_cgroup.c
> +++ b/mm/page_cgroup.c
> @@ -47,6 +47,8 @@ static int __init alloc_node_page_cgroup(int nid)
>  	struct page_cgroup *base, *pc;
>  	unsigned long table_size;
>  	unsigned long start_pfn, nr_pages, index;
> +	struct page *page;
> +	unsigned int order;
>  
>  	start_pfn = NODE_DATA(nid)->node_start_pfn;
>  	nr_pages = NODE_DATA(nid)->node_spanned_pages;
> @@ -55,11 +57,13 @@ static int __init alloc_node_page_cgroup(int nid)
>  		return 0;
>  
>  	table_size = sizeof(struct page_cgroup) * nr_pages;
> -
> -	base = __alloc_bootmem_node_nopanic(NODE_DATA(nid),
> -			table_size, PAGE_SIZE, __pa(MAX_DMA_ADDRESS));
> -	if (!base)
> +	order = get_order(table_size);
> +	page = alloc_pages_node(nid, GFP_NOWAIT | __GFP_ZERO, order);
> +	if (!page)
> +		page = alloc_pages_node(-1, GFP_NOWAIT | __GFP_ZERO, order);
> +	if (!page)
>  		return -ENOMEM;
> +	base = page_address(page);
>  	for (index = 0; index < nr_pages; index++) {
>  		pc = base + index;
>  		__init_page_cgroup(pc, start_pfn + index);

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
