Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with ESMTP id 853E98D0039
	for <linux-mm@kvack.org>; Sun, 27 Feb 2011 20:00:07 -0500 (EST)
Received: from m2.gw.fujitsu.co.jp (unknown [10.0.50.72])
	by fgwmail6.fujitsu.co.jp (Postfix) with ESMTP id 6A6CF3EE0B6
	for <linux-mm@kvack.org>; Mon, 28 Feb 2011 10:00:02 +0900 (JST)
Received: from smail (m2 [127.0.0.1])
	by outgoing.m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 5284845DE67
	for <linux-mm@kvack.org>; Mon, 28 Feb 2011 10:00:02 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (s2.gw.fujitsu.co.jp [10.0.50.92])
	by m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 3933A45DE55
	for <linux-mm@kvack.org>; Mon, 28 Feb 2011 10:00:02 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 255811DB803C
	for <linux-mm@kvack.org>; Mon, 28 Feb 2011 10:00:02 +0900 (JST)
Received: from ml13.s.css.fujitsu.com (ml13.s.css.fujitsu.com [10.249.87.103])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id DBC91E08002
	for <linux-mm@kvack.org>; Mon, 28 Feb 2011 10:00:01 +0900 (JST)
Date: Mon, 28 Feb 2011 09:53:47 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [RFC PATCH] page_cgroup: Reduce allocation overhead for
 page_cgroup array for CONFIG_SPARSEMEM v3
Message-Id: <20110228095347.7510b1d4.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20110225095357.GA23241@tiehlicka.suse.cz>
References: <20110223151047.GA7275@tiehlicka.suse.cz>
	<1298485162.7236.4.camel@nimitz>
	<20110224134045.GA22122@tiehlicka.suse.cz>
	<20110225122522.8c4f1057.kamezawa.hiroyu@jp.fujitsu.com>
	<20110225095357.GA23241@tiehlicka.suse.cz>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>
Cc: Dave Hansen <dave@linux.vnet.ibm.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Fri, 25 Feb 2011 10:53:57 +0100
Michal Hocko <mhocko@suse.cz> wrote:

> On Fri 25-02-11 12:25:22, KAMEZAWA Hiroyuki wrote:
> > On Thu, 24 Feb 2011 14:40:45 +0100
> > Michal Hocko <mhocko@suse.cz> wrote:
> > 
> > > Here is the second version of the patch. I have used alloc_pages_exact
> > > instead of the complex double array approach.
> > > 
> > > I still fallback to kmalloc/vmalloc because hotplug can happen quite
> > > some time after boot and we can end up not having enough continuous
> > > pages at that time. 
> > > 
> > > I am also thinking whether it would make sense to introduce
> > > alloc_pages_exact_node function which would allocate pages from the
> > > given node.
> > > 
> > > Any thoughts?
> > 
> > The patch itself is fine but please update the description.
> 
> I have updated the description but kept those parts which describe how
> the memory is wasted for different configurations. Do you have any tips
> how it can be improved?
> 

This part was in your description.
==
We can reduce the internal fragmentation either by imeplementing 2
dimensional array and allocate kmalloc aligned sizes for each entry (as
suggested in https://lkml.org/lkml/2011/2/23/232) or we can get rid of
kmalloc altogether and allocate directly from the buddy allocator (use
alloc_pages_exact) as suggested by Dave Hansen.
==

please remove 2 dimentional..... etc. That's just a history.




> > 
> > But have some comments, below.
> [...]
> > > -/* __alloc_bootmem...() is protected by !slab_available() */
> > > +static void *__init_refok alloc_mcg_table(size_t size, int nid)
> > > +{
> > > +	void *addr = NULL;
> > > +	if((addr = alloc_pages_exact(size, GFP_KERNEL | __GFP_NOWARN)))
> > > +		return addr;
> > > +
> > > +	if (node_state(nid, N_HIGH_MEMORY)) {
> > > +		addr = kmalloc_node(size, GFP_KERNEL | __GFP_NOWARN, nid);
> > > +		if (!addr)
> > > +			addr = vmalloc_node(size, nid);
> > > +	} else {
> > > +		addr = kmalloc(size, GFP_KERNEL | __GFP_NOWARN);
> > > +		if (!addr)
> > > +			addr = vmalloc(size);
> > > +	}
> > > +
> > > +	return addr;
> > > +}
> > 
> > What is the case we need to call kmalloc_node() even when alloc_pages_exact() fails ?
> > vmalloc() may need to be called when the size of chunk is larger than
> > MAX_ORDER or there is fragmentation.....
> 
> I kept the original kmalloc with fallback to vmalloc because vmalloc is
> more scarce resource (especially on i386 where we can have memory
> hotplug configured as well).
> 

My point is, if alloc_pages_exact() failes because of order of the page,
kmalloc() will always fail. Please remove kmalloc().

> > 
> > And the function name, alloc_mcg_table(), I don't like it because this is an
> > allocation for page_cgroup.
> > 
> > How about alloc_page_cgroup() simply ?
> 
> OK, I have no preferences for the name. alloc_page_cgroup sounds good as
> well.
> 
> I have also added VM_BUG_ON(!slab_is_available()) back to the allocation
> path.
> 
> Thanks for the review. The updated patch is bellow:
> 

kmalloc() is unnecessary, again.


> Changes since v2
> - rename alloc_mcg_table to alloc_page_cgroup
> - free__mcg_table renamed to free_page_cgroup
> - get VM_BUG_ON(!slab_is_available()) back into the allocation path
> --- 
> From 9b34baf57f410a628bf45f2b35b23fdf38feae79 Mon Sep 17 00:00:00 2001
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
> suggested in https://lkml.org/lkml/2011/2/23/232) or allocate directly
> from the buddy allocator (use alloc_pages_exact) as suggested by Dave
> Hansen.
> 
> The later solution is much simpler and the internal fragmentation is
> comparable (~1 page per section). The initialization is done during the
> boot (unless we are doing memory hotplug) so we shouldn't have any
> issues from memory fragmentation and alloc_pages_exact should succeed.
> 
> We still need a fallback to kmalloc/vmalloc because we have no
> guarantees that we will have a continuous memory of that size (order-10)
> later on during the hotplug events.
> 
> Signed-off-by: Michal Hocko <mhocko@suse.cz>
> CC: Dave Hansen <dave@linux.vnet.ibm.com>
> CC: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> ---
>  mm/page_cgroup.c |   62 ++++++++++++++++++++++++++++++++++-------------------
>  1 files changed, 40 insertions(+), 22 deletions(-)
> 
> diff --git a/mm/page_cgroup.c b/mm/page_cgroup.c
> index 5bffada..ae322dc 100644
> --- a/mm/page_cgroup.c
> +++ b/mm/page_cgroup.c
> @@ -106,6 +106,42 @@ struct page_cgroup *lookup_page_cgroup(struct page *page)
>  }
>  
>  /* __alloc_bootmem...() is protected by !slab_available() */
> +static void *__init_refok alloc_page_cgroup(size_t size, int nid)
> +{
> +	void *addr = NULL;
> +	if((addr = alloc_pages_exact(size, GFP_KERNEL | __GFP_NOWARN)))
> +		return addr;
> +
> +	VM_BUG_ON(!slab_is_available());
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
> +
> +static void *free_page_cgroup(void *addr)
> +{
> +	if (is_vmalloc_addr(addr)) {
> +		vfree(addr);
> +	} else {
> +		struct page *page = virt_to_page(addr);
> +		if (!PageReserved(page)) { /* Is bootmem ? */
> +			if (!PageSlab(page)) {
> +				size_t table_size = sizeof(struct page_cgroup) * PAGES_PER_SECTION;
> +				free_pages_exact(addr, table_size);
> +			} else
> +				kfree(addr);
> +		}
> +	}
> +}
> +
>  static int __init_refok init_section_page_cgroup(unsigned long pfn)
>  {
>  	struct mem_section *section = __pfn_to_section(pfn);
> @@ -114,19 +150,9 @@ static int __init_refok init_section_page_cgroup(unsigned long pfn)
>  	int nid, index;
>  
>  	if (!section->page_cgroup) {
> -		nid = page_to_nid(pfn_to_page(pfn));
>  		table_size = sizeof(struct page_cgroup) * PAGES_PER_SECTION;
> -		VM_BUG_ON(!slab_is_available());
> -		if (node_state(nid, N_HIGH_MEMORY)) {
> -			base = kmalloc_node(table_size,
> -				GFP_KERNEL | __GFP_NOWARN, nid);
> -			if (!base)
> -				base = vmalloc_node(table_size, nid);
> -		} else {
> -			base = kmalloc(table_size, GFP_KERNEL | __GFP_NOWARN);
> -			if (!base)
> -				base = vmalloc(table_size);
> -		}
> +		nid = page_to_nid(pfn_to_page(pfn));
> +		base = alloc_page_cgroup(table_size, nid);
>  		/*
>  		 * The value stored in section->page_cgroup is (base - pfn)
>  		 * and it does not point to the memory block allocated above,
> @@ -170,16 +196,8 @@ void __free_page_cgroup(unsigned long pfn)
>  	if (!ms || !ms->page_cgroup)
>  		return;
>  	base = ms->page_cgroup + pfn;
> -	if (is_vmalloc_addr(base)) {
> -		vfree(base);
> -		ms->page_cgroup = NULL;
> -	} else {
> -		struct page *page = virt_to_page(base);
> -		if (!PageReserved(page)) { /* Is bootmem ? */
> -			kfree(base);
> -			ms->page_cgroup = NULL;
> -		}
> -	}
> +	free_page_cgroup(base);
> +	ms->page_cgroup = NULL;
>  }
>  
>  int __meminit online_page_cgroup(unsigned long start_pfn,
> -- 
> 1.7.2.3
> 
> -- 
> Michal Hocko
> SUSE Labs
> SUSE LINUX s.r.o.
> Lihovarska 1060/12
> 190 00 Praha 9    
> Czech Republic
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
