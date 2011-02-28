Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with ESMTP id C0A4F8D0039
	for <linux-mm@kvack.org>; Mon, 28 Feb 2011 04:29:56 -0500 (EST)
Received: from m4.gw.fujitsu.co.jp (unknown [10.0.50.74])
	by fgwmail6.fujitsu.co.jp (Postfix) with ESMTP id C06383EE0BC
	for <linux-mm@kvack.org>; Mon, 28 Feb 2011 18:29:52 +0900 (JST)
Received: from smail (m4 [127.0.0.1])
	by outgoing.m4.gw.fujitsu.co.jp (Postfix) with ESMTP id A667C45DE53
	for <linux-mm@kvack.org>; Mon, 28 Feb 2011 18:29:52 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (s4.gw.fujitsu.co.jp [10.0.50.94])
	by m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 8B98245DE51
	for <linux-mm@kvack.org>; Mon, 28 Feb 2011 18:29:52 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id 745DEE78003
	for <linux-mm@kvack.org>; Mon, 28 Feb 2011 18:29:52 +0900 (JST)
Received: from ml13.s.css.fujitsu.com (ml13.s.css.fujitsu.com [10.249.87.103])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id F00991DB8037
	for <linux-mm@kvack.org>; Mon, 28 Feb 2011 18:29:51 +0900 (JST)
Date: Mon, 28 Feb 2011 18:23:22 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [RFC PATCH] page_cgroup: Reduce allocation overhead for
 page_cgroup array for CONFIG_SPARSEMEM v4
Message-Id: <20110228182322.a34cc1fd.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20110228091256.GA4648@tiehlicka.suse.cz>
References: <20110223151047.GA7275@tiehlicka.suse.cz>
	<1298485162.7236.4.camel@nimitz>
	<20110224134045.GA22122@tiehlicka.suse.cz>
	<20110225122522.8c4f1057.kamezawa.hiroyu@jp.fujitsu.com>
	<20110225095357.GA23241@tiehlicka.suse.cz>
	<20110228095347.7510b1d4.kamezawa.hiroyu@jp.fujitsu.com>
	<20110228091256.GA4648@tiehlicka.suse.cz>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>
Cc: Dave Hansen <dave@linux.vnet.ibm.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Mon, 28 Feb 2011 10:12:56 +0100
Michal Hocko <mhocko@suse.cz> wrote:

> On Mon 28-02-11 09:53:47, KAMEZAWA Hiroyuki wrote:
> > On Fri, 25 Feb 2011 10:53:57 +0100
> > Michal Hocko <mhocko@suse.cz> wrote:
> > 
> > > On Fri 25-02-11 12:25:22, KAMEZAWA Hiroyuki wrote:
> > > > On Thu, 24 Feb 2011 14:40:45 +0100
> [...]
> > > > The patch itself is fine but please update the description.
> > > 
> > > I have updated the description but kept those parts which describe how
> > > the memory is wasted for different configurations. Do you have any tips
> > > how it can be improved?
> > > 
> > 
> > This part was in your description.
> > ==
> > We can reduce the internal fragmentation either by imeplementing 2
> > dimensional array and allocate kmalloc aligned sizes for each entry (as
> > suggested in https://lkml.org/lkml/2011/2/23/232) or we can get rid of
> > kmalloc altogether and allocate directly from the buddy allocator (use
> > alloc_pages_exact) as suggested by Dave Hansen.
> > ==
> > 
> > please remove 2 dimentional..... etc. That's just a history.
> 
> I just wanted to mention both approaches. OK, I can remove that, of
> course.
> 
> > > > 
> > > > But have some comments, below.
> > > [...]
> > > > > -/* __alloc_bootmem...() is protected by !slab_available() */
> > > > > +static void *__init_refok alloc_mcg_table(size_t size, int nid)
> > > > > +{
> > > > > +	void *addr = NULL;
> > > > > +	if((addr = alloc_pages_exact(size, GFP_KERNEL | __GFP_NOWARN)))
> > > > > +		return addr;
> > > > > +
> > > > > +	if (node_state(nid, N_HIGH_MEMORY)) {
> > > > > +		addr = kmalloc_node(size, GFP_KERNEL | __GFP_NOWARN, nid);
> > > > > +		if (!addr)
> > > > > +			addr = vmalloc_node(size, nid);
> > > > > +	} else {
> > > > > +		addr = kmalloc(size, GFP_KERNEL | __GFP_NOWARN);
> > > > > +		if (!addr)
> > > > > +			addr = vmalloc(size);
> > > > > +	}
> > > > > +
> > > > > +	return addr;
> > > > > +}
> > > > 
> > > > What is the case we need to call kmalloc_node() even when alloc_pages_exact() fails ?
> > > > vmalloc() may need to be called when the size of chunk is larger than
> > > > MAX_ORDER or there is fragmentation.....
> > > 
> > > I kept the original kmalloc with fallback to vmalloc because vmalloc is
> > > more scarce resource (especially on i386 where we can have memory
> > > hotplug configured as well).
> > > 
> > 
> > My point is, if alloc_pages_exact() failes because of order of the page,
> > kmalloc() will always fail. 
> 
> You are right. I thought that kmalloc can make a difference due to reclaim
> but the reclaim is already triggered by alloc_pages_exact and if it doesn't
> succeed there are not big chances to have those pages ready for kmalloc.
> 
> > Please remove kmalloc().
> 
> OK.
> 
> Thanks for the review again and the updated patch is bellow:
> 
> Change since v3
> - updated changelog - to not mentioned 2dim. solution
> - get rid of kmalloc fallback based on Kame's suggestion.
> - free_page_cgroup accidentally returned void* (we do not need any return value
>   there)
> 
> Changes since v2
> - rename alloc_mcg_table to alloc_page_cgroup
> - free__mcg_table renamed to free_page_cgroup
> - get VM_BUG_ON(!slab_is_available()) back into the allocation path
> 
> ---
> From 84a9555741b59cb2a0a67b023e4bd0f92c670ca1 Mon Sep 17 00:00:00 2001
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
> We can reduce the internal fragmentation by using alloc_pages_exact
> which allocates PAGE_SIZE aligned blocks so we will get down to <4kB
> wasted memory per section which is much better.
> 
> We still need a fallback to vmalloc because we have no guarantees that
> we will have a continuous memory of that size (order-10) later on during
> the hotplug events.
> 
> Signed-off-by: Michal Hocko <mhocko@suse.cz>
> CC: Dave Hansen <dave@linux.vnet.ibm.com>
> CC: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

Acked-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

But...nitpick, it may be from my fault..



> ---
>  mm/page_cgroup.c |   54 +++++++++++++++++++++++++++++++-----------------------
>  1 files changed, 31 insertions(+), 23 deletions(-)
> 
> diff --git a/mm/page_cgroup.c b/mm/page_cgroup.c
> index 5bffada..eae3cd2 100644
> --- a/mm/page_cgroup.c
> +++ b/mm/page_cgroup.c
> @@ -105,7 +105,33 @@ struct page_cgroup *lookup_page_cgroup(struct page *page)
>  	return section->page_cgroup + pfn;
>  }
>  
> -/* __alloc_bootmem...() is protected by !slab_available() */
> +static void *__init_refok alloc_page_cgroup(size_t size, int nid)
> +{
> +	void *addr = NULL;
> +	if((addr = alloc_pages_exact(size, GFP_KERNEL | __GFP_NOWARN)))
> +		return addr;
> +
> +	if (node_state(nid, N_HIGH_MEMORY))
> +		addr = vmalloc_node(size, nid);
> +	else
> +		addr = vmalloc(size);
> +
> +	return addr;
> +}
> +
> +static void free_page_cgroup(void *addr)
> +{
> +	if (is_vmalloc_addr(addr)) {
> +		vfree(addr);
> +	} else {
> +		struct page *page = virt_to_page(addr);
> +		if (!PageReserved(page)) { /* Is bootmem ? */

I think we never see PageReserved if we just use alloc_pages_exact()/vmalloc().
Maybe my old patch was not enough and this kind of junks are remaining in
the original code.


Thanks,
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
