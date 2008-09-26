Date: Fri, 26 Sep 2008 10:43:36 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH 9/12] memcg allocate all page_cgroup at boot
Message-Id: <20080926104336.d96ab5bd.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20080926100022.8bfb8d4d.nishimura@mxp.nes.nec.co.jp>
References: <20080925151124.25898d22.kamezawa.hiroyu@jp.fujitsu.com>
	<20080925153206.281243dc.kamezawa.hiroyu@jp.fujitsu.com>
	<20080926100022.8bfb8d4d.nishimura@mxp.nes.nec.co.jp>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "balbir@linux.vnet.ibm.com" <balbir@linux.vnet.ibm.com>, "xemul@openvz.org" <xemul@openvz.org>, Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>, Dave Hansen <haveblue@us.ibm.com>, ryov@valinux.co.jp
List-ID: <linux-mm.kvack.org>

On Fri, 26 Sep 2008 10:00:22 +0900
Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp> wrote:

> On Thu, 25 Sep 2008 15:32:06 +0900, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> wrote:
> > Allocate all page_cgroup at boot and remove page_cgroup poitner
> > from struct page. This patch adds an interface as
> > 
> >  struct page_cgroup *lookup_page_cgroup(struct page*)
> > 
> > All FLATMEM/DISCONTIGMEM/SPARSEMEM  and MEMORY_HOTPLUG is supported.
> > 
> > Remove page_cgroup pointer reduces the amount of memory by
> >  - 4 bytes per PAGE_SIZE.
> >  - 8 bytes per PAGE_SIZE
> > if memory controller is disabled. (even if configured.)
> > meta data usage of this is no problem in FLATMEM/DISCONTIGMEM.
> > On SPARSEMEM, this makes mem_section[] size twice.
> > 
> > On usual 8GB x86-32 server, this saves 8MB of NORMAL_ZONE memory.
> > On my x86-64 server with 48GB of memory, this saves 96MB of memory.
> > (and uses xx kbytes for mem_section.)
> > I think this reduction makes sense.
> > 
> > By pre-allocation, kmalloc/kfree in charge/uncharge are removed. 
> > This means
> >   - we're not necessary to be afraid of kmalloc faiulre.
> >     (this can happen because of gfp_mask type.)
> >   - we can avoid calling kmalloc/kfree.
> >   - we can avoid allocating tons of small objects which can be fragmented.
> >   - we can know what amount of memory will be used for this extra-lru handling.
> > 
> > I added printk message as
> > 
> > 	"allocated %ld bytes of page_cgroup"
> >         "please try cgroup_disable=memory option if you don't want"
> > 
> > maybe enough informative for users.
> > 
> > Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> > 
> >  include/linux/memcontrol.h  |   11 -
> >  include/linux/mm_types.h    |    4 
> >  include/linux/mmzone.h      |    9 +
> >  include/linux/page_cgroup.h |   90 +++++++++++++++
> >  mm/Makefile                 |    2 
> >  mm/memcontrol.c             |  258 ++++++++++++--------------------------------
> >  mm/page_alloc.c             |   12 --
> >  mm/page_cgroup.c            |  253 +++++++++++++++++++++++++++++++++++++++++++
> >  8 files changed, 431 insertions(+), 208 deletions(-)
> > 
> > Index: mmotm-2.6.27-rc7+/mm/page_cgroup.c
> > ===================================================================
> > --- /dev/null
> > +++ mmotm-2.6.27-rc7+/mm/page_cgroup.c
> > @@ -0,0 +1,253 @@
> > +#include <linux/mm.h>
> > +#include <linux/mmzone.h>
> > +#include <linux/bootmem.h>
> > +#include <linux/bit_spinlock.h>
> > +#include <linux/page_cgroup.h>
> > +#include <linux/hash.h>
> > +#include <linux/memory.h>
> > +
> > +static void __meminit
> > +__init_page_cgroup(struct page_cgroup *pc, unsigned long pfn)
> > +{
> > +	pc->flags = 0;
> > +	pc->mem_cgroup = NULL;
> > +	pc->page = pfn_to_page(pfn);
> > +}
> > +static unsigned long total_usage = 0;
> > +
> > +#ifdef CONFIG_FLAT_NODE_MEM_MAP
> > +
> > +
> > +void __init pgdat_page_cgroup_init(struct pglist_data *pgdat)
> > +{
> > +	pgdat->node_page_cgroup = NULL;
> > +}
> > +
> > +struct page_cgroup *lookup_page_cgroup(struct page *page)
> > +{
> > +	unsigned long pfn = page_to_pfn(page);
> > +	unsigned long offset;
> > +	struct page_cgroup *base;
> > +
> > +	base = NODE_DATA(page_to_nid(nid))->node_page_cgroup;
> page_to_nid(page) :)
> 
yes..

> > +	if (unlikely(!base))
> > +		return NULL;
> > +
> > +	offset = pfn - NODE_DATA(page_to_nid(page))->node_start_pfn;
> > +	return base + offset;
> > +}
> > +
> > +static int __init alloc_node_page_cgroup(int nid)
> > +{
> > +	struct page_cgroup *base, *pc;
> > +	unsigned long table_size;
> > +	unsigned long start_pfn, nr_pages, index;
> > +
> > +	start_pfn = NODE_DATA(nid)->node_start_pfn;
> > +	nr_pages = NODE_DATA(nid)->node_spanned_pages;
> > +
> > +	table_size = sizeof(struct page_cgroup) * nr_pages;
> > +
> > +	base = __alloc_bootmem_node_nopanic(NODE_DATA(nid),
> > +			table_size, PAGE_SIZE, __pa(MAX_DMA_ADDRESS));
> > +	if (!base)
> > +		return -ENOMEM;
> > +	for (index = 0; index < nr_pages; index++) {
> > +		pc = base + index;
> > +		__init_page_cgroup(pc, start_pfn + index);
> > +	}
> > +	NODE_DATA(nid)->node_page_cgroup = base;
> > +	total_usage += table_size;
> > +	return 0;
> > +}
> > +
> > +void __init free_node_page_cgroup(int nid)
> > +{
> > +	unsigned long table_size;
> > +	unsigned long nr_pages;
> > +	struct page_cgroup *base;
> > +
> > +	base = NODE_DATA(nid)->node_page_cgroup;
> > +	if (!base)
> > +		return;
> > +	nr_pages = NODE_DATA(nid)->node_spanned_pages;
> > +
> > +	table_size = sizeof(struct page_cgroup) * nr_pages;
> > +
> > +	free_bootmem_node(NODE_DATA(nid),
> > +			(unsigned long)base, table_size);
> > +	NODE_DATA(nid)->node_page_cgroup = NULL;
> > +}
> > +
> Hmm, who uses this function?
> 
Uh, ok. unnecessary. (In my first version, this allocation error
just shows Warning. Now, it panics.)

Appearently, FLATMEM check is not enough...

> (snip)
> 
> > @@ -812,49 +708,41 @@ __mem_cgroup_uncharge_common(struct page
> >  
> >  	if (mem_cgroup_subsys.disabled)
> >  		return;
> > +	/* check the condition we can know from page */
> >  
> > -	/*
> > -	 * Check if our page_cgroup is valid
> > -	 */
> > -	lock_page_cgroup(page);
> > -	pc = page_get_page_cgroup(page);
> > -	if (unlikely(!pc))
> > -		goto unlock;
> > -
> > -	VM_BUG_ON(pc->page != page);
> > +	pc = lookup_page_cgroup(page);
> > +	if (unlikely(!pc || !PageCgroupUsed(pc)))
> > +		return;
> > +	preempt_disable();
> > +	lock_page_cgroup(pc);
> > +	if (unlikely(page_mapped(page))) {
> > +		unlock_page_cgroup(pc);
> > +		preempt_enable();
> > +		return;
> > +	}
> Just for clarification, in what sequence will the page be mapped here?
> mem_cgroup_uncharge_page checks whether the page is mapped.
> 
Please think about folloing situation.

   There is a SwapCache which is referred from 2 process, A, B.
   A maps it.
   B doesn't maps it.

   And now, process A exits.

	CPU0(process A)				CPU1 (process B)
 
    zap_pte_range()
    => page remove from rmap			=> charge() (do_swap_page)
	=> set page->mapcount->0          	
		=> uncharge()			=> set page->mapcount=1

This race is what patch 12/12 is fixed.
This only happens on cursed SwapCache.


> > +	ClearPageCgroupUsed(pc);
> > +	unlock_page_cgroup(pc);
> >  
> > -	if ((ctype == MEM_CGROUP_CHARGE_TYPE_MAPPED)
> > -	    && ((PageCgroupCache(pc) || page_mapped(page))))
> > -		goto unlock;
> > -retry:
> >  	mem = pc->mem_cgroup;
> >  	mz = page_cgroup_zoneinfo(pc);
> > +
> >  	spin_lock_irqsave(&mz->lru_lock, flags);
> > -	if (ctype == MEM_CGROUP_CHARGE_TYPE_MAPPED &&
> > -	    unlikely(mem != pc->mem_cgroup)) {
> > -		/* MAPPED account can be done without lock_page().
> > -		   Check race with mem_cgroup_move_account() */
> > -		spin_unlock_irqrestore(&mz->lru_lock, flags);
> > -		goto retry;
> > -	}
> By these changes, ctype becomes unnecessary so it can be removed.
> 
Uh, maybe it can be removed.

> >  	__mem_cgroup_remove_list(mz, pc);
> >  	spin_unlock_irqrestore(&mz->lru_lock, flags);
> > -
> > -	page_assign_page_cgroup(page, NULL);
> > -	unlock_page_cgroup(page);
> > -
> > -
> > -	res_counter_uncharge(&mem->res, PAGE_SIZE);
> > +	pc->mem_cgroup = NULL;
> >  	css_put(&mem->css);
> > +	preempt_enable();
> > +	res_counter_uncharge(&mem->res, PAGE_SIZE);
> >  
> > -	kmem_cache_free(page_cgroup_cache, pc);
> >  	return;
> > -unlock:
> > -	unlock_page_cgroup(page);
> >  }
> >  

Thank you for review.

Regards,
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
