Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id CFA398D0039
	for <linux-mm@kvack.org>; Thu, 24 Feb 2011 22:32:01 -0500 (EST)
Received: from m3.gw.fujitsu.co.jp (unknown [10.0.50.73])
	by fgwmail6.fujitsu.co.jp (Postfix) with ESMTP id 288853EE0C0
	for <linux-mm@kvack.org>; Fri, 25 Feb 2011 12:31:58 +0900 (JST)
Received: from smail (m3 [127.0.0.1])
	by outgoing.m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 0021445DE57
	for <linux-mm@kvack.org>; Fri, 25 Feb 2011 12:31:58 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (s3.gw.fujitsu.co.jp [10.0.50.93])
	by m3.gw.fujitsu.co.jp (Postfix) with ESMTP id D264F45DE4D
	for <linux-mm@kvack.org>; Fri, 25 Feb 2011 12:31:57 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id C3C28E08005
	for <linux-mm@kvack.org>; Fri, 25 Feb 2011 12:31:57 +0900 (JST)
Received: from m105.s.css.fujitsu.com (m105.s.css.fujitsu.com [10.249.87.105])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 7811CE08002
	for <linux-mm@kvack.org>; Fri, 25 Feb 2011 12:31:57 +0900 (JST)
Date: Fri, 25 Feb 2011 12:25:22 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [RFC PATCH] page_cgroup: Reduce allocation overhead for
 page_cgroup array for CONFIG_SPARSEMEM v2
Message-Id: <20110225122522.8c4f1057.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20110224134045.GA22122@tiehlicka.suse.cz>
References: <20110223151047.GA7275@tiehlicka.suse.cz>
	<1298485162.7236.4.camel@nimitz>
	<20110224134045.GA22122@tiehlicka.suse.cz>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>
Cc: Dave Hansen <dave@linux.vnet.ibm.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Thu, 24 Feb 2011 14:40:45 +0100
Michal Hocko <mhocko@suse.cz> wrote:

> Here is the second version of the patch. I have used alloc_pages_exact
> instead of the complex double array approach.
> 
> I still fallback to kmalloc/vmalloc because hotplug can happen quite
> some time after boot and we can end up not having enough continuous
> pages at that time. 
> 
> I am also thinking whether it would make sense to introduce
> alloc_pages_exact_node function which would allocate pages from the
> given node.
> 
> Any thoughts?

The patch itself is fine but please update the description.

But have some comments, below.

> ---
> From e8909bbd1d759de274a6ed7812530e576ad8bc44 Mon Sep 17 00:00:00 2001
> From: Michal Hocko <mhocko@suse.cz>
> Date: Thu, 24 Feb 2011 11:25:44 +0100
> Subject: [PATCH] page_cgroup: Reduce allocation overhead for page_cgroup array for CONFIG_SPARSEMEM
> 
> Currently we are allocating a single page_cgroup array per memory
> section (stored in mem_section->base) when CONFIG_SPARSEMEM is selected.
> This is correct but memory inefficient solution because the allocated
> memory (unless we fall back to vmalloc) is not kmalloc friendly:
>         - 32b - 16384 entries (20B per entry) fit into 327680B so the
>           524288B slab cache is used
>         - 32b with PAE - 131072 entries with 2621440B fit into 4194304B
>         - 64b - 32768 entries (40B per entry) fit into 2097152 cache
> 
> This is ~37% wasted space per memory section and it sumps up for the
> whole memory. On a x86_64 machine it is something like 6MB per 1GB of
> RAM.
> 
> We can reduce the internal fragmentation either by imeplementing 2
> dimensional array and allocate kmalloc aligned sizes for each entry (as
> suggested in https://lkml.org/lkml/2011/2/23/232) or we can get rid of
> kmalloc altogether and allocate directly from the buddy allocator (use
> alloc_pages_exact) as suggested by Dave Hansen.
> 
> The later solution is much simpler and the internal fragmentation is
> comparable (~1 page per section).
> 
> We still need a fallback to kmalloc/vmalloc because we have no
> guarantees that we will have a continuous memory of that size (order-10)
> later on the hotplug events.
> 
> Signed-off-by: Michal Hocko <mhocko@suse.cz>
> ---
>  mm/page_cgroup.c |   62 ++++++++++++++++++++++++++++++++++--------------------
>  1 files changed, 39 insertions(+), 23 deletions(-)
> 
> diff --git a/mm/page_cgroup.c b/mm/page_cgroup.c
> index 5bffada..eaae7de 100644
> --- a/mm/page_cgroup.c
> +++ b/mm/page_cgroup.c
> @@ -105,7 +105,41 @@ struct page_cgroup *lookup_page_cgroup(struct page *page)
>  	return section->page_cgroup + pfn;
>  }
>  
> -/* __alloc_bootmem...() is protected by !slab_available() */
> +static void *__init_refok alloc_mcg_table(size_t size, int nid)
> +{
> +	void *addr = NULL;
> +	if((addr = alloc_pages_exact(size, GFP_KERNEL | __GFP_NOWARN)))
> +		return addr;
> +
> +	if (node_state(nid, N_HIGH_MEMORY)) {
> +		addr = kmalloc_node(size, GFP_KERNEL | __GFP_NOWARN, nid);
> +		if (!addr)
> +			addr = vmalloc_node(size, nid);
> +	} else {
> +		addr = kmalloc(size, GFP_KERNEL | __GFP_NOWARN);
> +		if (!addr)
> +			addr = vmalloc(size);
> +	}
> +
> +	return addr;
> +}

What is the case we need to call kmalloc_node() even when alloc_pages_exact() fails ?
vmalloc() may need to be called when the size of chunk is larger than
MAX_ORDER or there is fragmentation.....

And the function name, alloc_mcg_table(), I don't like it because this is an
allocation for page_cgroup.

How about alloc_page_cgroup() simply ?


Thanks,
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
