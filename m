Date: Thu, 20 Mar 2008 14:07:03 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH 7/7] memcg: freeing page_cgroup at suitable chance
Message-Id: <20080320140703.935073df.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <1205962399.6437.30.camel@lappy>
References: <20080314185954.5cd51ff6.kamezawa.hiroyu@jp.fujitsu.com>
	<20080314192253.edb38762.kamezawa.hiroyu@jp.fujitsu.com>
	<1205962399.6437.30.camel@lappy>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Peter Zijlstra <a.p.zijlstra@chello.nl>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "balbir@linux.vnet.ibm.com" <balbir@linux.vnet.ibm.com>, xemul@openvz.org, "hugh@veritas.com" <hugh@veritas.com>
List-ID: <linux-mm.kvack.org>

On Wed, 19 Mar 2008 22:33:19 +0100
Peter Zijlstra <a.p.zijlstra@chello.nl> wrote:

> On Fri, 2008-03-14 at 19:22 +0900, KAMEZAWA Hiroyuki wrote:
> > This patch is for freeing page_cgroup if a chunk of pages are freed.
> > 
> > How this works 
> >  * when the order of free page reaches PCGRP_SHRINK_ORDER, pcgrp is freed.
> >    This will be done by RCU.
> > 
> > I think this works well because
> >    - unnecessary freeing will not occur in busy servers.
> 
> So we'll OOM instead?
> 
Hmm. I think page_cgroup will not be able to be freed under OOM because
pages, which are accounted, are not able to be freed.
"Free If Unnecessary" is what we can here.

My purpose is just for making wise use of memory a bit more.

I'm now considering to adjust page_cgroup's chunk order to be smaller than
page-migration-type. Then, we can guarantee that

We don't allocate page_cgroup against
  - kernel pages (pages in not-movable migrate type)
  - huge pages



> >    - page_cgroup will be removed at necessary point (allocating Hugepage,etc..)
> >    - If tons of pages are freed (ex. big file is removed), page_cgroup will
> >      be removed.
> > 
> > 
> > Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsuc.com>
> > 
> > 
> >  include/linux/page_cgroup.h |   15 +++++++++++-
> >  mm/page_alloc.c             |    3 ++
> >  mm/page_cgroup.c            |   54 ++++++++++++++++++++++++++++++++++++++++++++
> >  3 files changed, 71 insertions(+), 1 deletion(-)
> > 
> > Index: mm-2.6.25-rc5-mm1/include/linux/page_cgroup.h
> > ===================================================================
> > --- mm-2.6.25-rc5-mm1.orig/include/linux/page_cgroup.h
> > +++ mm-2.6.25-rc5-mm1/include/linux/page_cgroup.h
> > @@ -39,6 +39,12 @@ DECLARE_PER_CPU(struct page_cgroup_cache
> >  #define PCGRP_SHIFT	(CONFIG_CGROUP_PAGE_CGROUP_ORDER)
> >  #define PCGRP_SIZE	(1 << PCGRP_SHIFT)
> >  
> > +#if PCGRP_SHIFT + 3 >= MAX_ORDER
> > +#define PCGRP_SHRINK_ORDER	(MAX_ORDER - 1)
> > +#else
> > +#define PCGRP_SHRINK_ORDER	(PCGRP_SHIFT + 3)
> > +#endif
> > +
> >  /*
> >   * Lookup and return page_cgroup struct.
> >   * returns NULL when
> > @@ -70,12 +76,19 @@ get_page_cgroup(struct page *page, gfp_t
> >  	return (ret)? ret : __get_page_cgroup(page, gfpmask, allocate);
> >  }
> >  
> > +void try_to_shrink_page_cgroup(struct page *page, int order);
> > +
> >  #else
> >  
> > -static struct page_cgroup *
> > +static inline struct page_cgroup *
> >  get_page_cgroup(struct page *page, gfp_t gfpmask, bool allocate)
> >  {
> >  	return NULL;
> >  }
> > +static inline void try_to_shrink_page_cgroup(struct page *page, int order)
> > +{
> > +	return;
> > +}
> > +#define PCGRP_SHRINK_ORDER	(MAX_ORDER)
> >  #endif
> >  #endif
> > Index: mm-2.6.25-rc5-mm1/mm/page_cgroup.c
> > ===================================================================
> > --- mm-2.6.25-rc5-mm1.orig/mm/page_cgroup.c
> > +++ mm-2.6.25-rc5-mm1/mm/page_cgroup.c
> > @@ -12,6 +12,7 @@
> >   */
> >  
> >  #include <linux/mm.h>
> > +#include <linux/mmzone.h>
> >  #include <linux/slab.h>
> >  #include <linux/radix-tree.h>
> >  #include <linux/memcontrol.h>
> > @@ -80,6 +81,7 @@ static void save_result(struct page_cgro
> >  	pcp = &__get_cpu_var(pcpu_page_cgroup_cache);
> >  	pcp->ents[hash].idx = idx;
> >  	pcp->ents[hash].base = base;
> > +	smp_wmb();
> 
> Lacks a comments outlining the race and a pointer to the matching
> barrier.
> 
ok, will fix.


> >  	preempt_enable();
> >  }
> >  
> > @@ -156,6 +158,58 @@ out:
> >  	return pc;
> >  }
> >  
> > +/* Must be called under zone->lock */
> > +void try_to_shrink_page_cgroup(struct page *page, int order)
> > +{
> > +	unsigned long pfn = page_to_pfn(page);
> > +	int nid = page_to_nid(page);
> > +	int idx = pfn >> PCGRP_SHIFT;
> > +	int hnum = (PAGE_CGROUP_NR_CACHE - 1);
> > +	struct page_cgroup_cache *pcp;
> > +	struct page_cgroup_head *head;
> > +	struct page_cgroup_root *root;
> > +	unsigned long end_pfn;
> > +	int cpu;
> > +
> > +
> > +	root = root_dir[nid];
> > +	if (!root || in_interrupt() || (order < PCGRP_SHIFT))
> > +		return;
> > +
> > +	pfn = page_to_pfn(page);
> > +	end_pfn = pfn + (1 << order);
> > +
> > +	while (pfn != end_pfn) {
> > +		idx = pfn >> PCGRP_SHIFT;
> > +		/* Is this pfn has entry ? */
> > +		rcu_read_lock();
> > +		head = radix_tree_lookup(&root->root_node, idx);
> > +		rcu_read_unlock();
> 
> What stops head from being freed here
> 
We have zone->lock here.
I'll add comments.

> > +		if (!head) {
> > +			pfn += (1 << PCGRP_SHIFT);
> > +			continue;
> > +		}
> > +		/* It's guaranteed that no one access to this pfn/idx
> > +		   because there is no reference to this page. */
> > +		hnum = (idx) & (PAGE_CGROUP_NR_CACHE - 1);
> > +		for_each_online_cpu(cpu) {
> > +			pcp = &per_cpu(pcpu_page_cgroup_cache, cpu);
> > +			smp_rmb();
> 
> Another unadorned barrier - presumably the pair for the one above.
> 
will fix.

> > +			if (pcp->ents[hnum].idx == idx)
> > +				pcp->ents[hnum].base = NULL;
> > +		}
> 
> This is rather expensive... but I can't seem to come up with another way
> around this. However, would it make sense to place this after, and make
> it conditional on the following condition; so that we'll not iterate all
> cpus only to find we couldn't free the radix tree item.
> 
ok. new version has some improvement on this.


> > +		if (spin_trylock(&root->tree_lock)) {
> > +			/* radix tree is freed by RCU. so they will not call
> > +			   free_pages() right now.*/
> > +			radix_tree_delete(&root->root_node, idx);
> > +			spin_unlock(&root->tree_lock);
> > +			/* We can free this in lazy fashion .*/
> > +			free_page_cgroup(head);
> 
> No RCU based freeing? I'd expected a call_rcu(), otherwise we race with
> lookups.
> 
SLAB itself is SLAB_DESTROY_BY_RCU. I'll add comments here.


> > +		}
> > +		pfn += (1 << PCGRP_SHIFT);
> > +	}
> > +}
> > +
> >  __init int page_cgroup_init(void)
> >  {
> >  	int nid;
> > Index: mm-2.6.25-rc5-mm1/mm/page_alloc.c
> > ===================================================================
> > --- mm-2.6.25-rc5-mm1.orig/mm/page_alloc.c
> > +++ mm-2.6.25-rc5-mm1/mm/page_alloc.c
> > @@ -45,6 +45,7 @@
> >  #include <linux/fault-inject.h>
> >  #include <linux/page-isolation.h>
> >  #include <linux/memcontrol.h>
> > +#include <linux/page_cgroup.h>
> >  
> >  #include <asm/tlbflush.h>
> >  #include <asm/div64.h>
> > @@ -463,6 +464,8 @@ static inline void __free_one_page(struc
> >  		order++;
> >  	}
> >  	set_page_order(page, order);
> > +	if (order >= PCGRP_SHRINK_ORDER)
> > +		try_to_shrink_page_cgroup(page, order);
> 
> So we only shrink if the buddy managed to coalesce the free pages into a
> high enough order free page, under a high enough load this might never
> happen.
> 
yes.

> This worries me somewhat, can you at least outline the worst case upper
> bound of memory consumption so we can check if this is acceptable?
> 
I'm now considering to make this to be not configurable and to change
this order to be migrate_type_order.

> Also, this is the very hart of the buddy system, doesn't this regress
> performance of the page-allocator under certain loads?
> 
I'm afraid of it, too. Maybe "removing tons of pages at once" workload
will be affected. But current memory resource controller calls tons of
kfree(). I doubt we can see the cost of this behavior.

I'm looking for better knobs to control this behavior.
(If much amounts of memory is free, we don't have to free this immediately.)

Thanks,
-Kame





--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
