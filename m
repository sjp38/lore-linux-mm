Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id 0B2408D0039
	for <linux-mm@kvack.org>; Fri,  4 Feb 2011 04:51:20 -0500 (EST)
Date: Fri, 4 Feb 2011 10:51:06 +0100
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [patch 5/5] memcg: remove direct page_cgroup-to-page pointer
Message-ID: <20110204095106.GC2289@cmpxchg.org>
References: <1296743166-9412-1-git-send-email-hannes@cmpxchg.org>
 <1296743166-9412-6-git-send-email-hannes@cmpxchg.org>
 <20110204091949.e5465acc.kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20110204091949.e5465acc.kamezawa.hiroyu@jp.fujitsu.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, Balbir Singh <balbir@linux.vnet.ibm.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Fri, Feb 04, 2011 at 09:19:49AM +0900, KAMEZAWA Hiroyuki wrote:
> On Thu,  3 Feb 2011 15:26:06 +0100
> Johannes Weiner <hannes@cmpxchg.org> wrote:
> 
> > In struct page_cgroup, we have a full word for flags but only a few
> > are reserved.  Use the remaining upper bits to encode, depending on
> > configuration, the node or the section, to enable page_cgroup-to-page
> > lookups without a direct pointer.
> > 
> > This saves a full word for every page in a system with memory cgroups
> > enabled.
> > 
> > Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>
> 
> In general,
> 
> Acked-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

Thanks!

> A few questions below.

[snip]

> > @@ -117,6 +122,34 @@ static inline void move_unlock_page_cgroup(struct page_cgroup *pc,
> >  	local_irq_restore(*flags);
> >  }
> >  
> > +#ifdef CONFIG_SPARSEMEM
> > +#define PCG_ARRAYID_SHIFT	SECTIONS_SHIFT
> > +#else
> > +#define PCG_ARRAYID_SHIFT	NODES_SHIFT
> > +#endif
> > +
> > +#if (PCG_ARRAYID_SHIFT > BITS_PER_LONG - NR_PCG_FLAGS)
> > +#error Not enough space left in pc->flags to store page_cgroup array IDs
> > +#endif
> > +
> > +/* pc->flags: ARRAY-ID | FLAGS */
> > +
> > +#define PCG_ARRAYID_MASK	((1UL << PCG_ARRAYID_SHIFT) - 1)
> > +
> > +#define PCG_ARRAYID_OFFSET	(sizeof(unsigned long) * 8 - PCG_ARRAYID_SHIFT)
> > +
> > +static inline void set_page_cgroup_array_id(struct page_cgroup *pc,
> > +					    unsigned long id)
> > +{
> > +	pc->flags &= ~(PCG_ARRAYID_MASK << PCG_ARRAYID_OFFSET);
> > +	pc->flags |= (id & PCG_ARRAYID_MASK) << PCG_ARRAYID_OFFSET;
> > +}
> > +
> > +static inline unsigned long page_cgroup_array_id(struct page_cgroup *pc)
> > +{
> > +	return (pc->flags >> PCG_ARRAYID_OFFSET) & PCG_ARRAYID_MASK;
> > +}
> > +
> 
> If a function for looking up a page from a page_cgroup in inline,
> I think these function should be static in page_cgroup.c

I stole all of this from mm.h which does the same for page flags.  Of
course, in their case, most of them are used in more than one file,
but some of them are not and it still has merit to keep related things
together.

Should I just move the functions?  I would like to keep them together
with the _MASK and _OFFSET definitions, so should I move them too?
Suggestion welcome ;)

> > diff --git a/mm/memcontrol.c b/mm/memcontrol.c
> > index 998da06..4e10f46 100644
> > --- a/mm/memcontrol.c
> > +++ b/mm/memcontrol.c
> > @@ -1054,7 +1054,8 @@ unsigned long mem_cgroup_isolate_pages(unsigned long nr_to_scan,
> >  		if (unlikely(!PageCgroupUsed(pc)))
> >  			continue;
> >  
> > -		page = pc->page;
> > +		page = lookup_cgroup_page(pc);
> > +		VM_BUG_ON(pc != lookup_page_cgroup(page));
> 
> If you're afraid of corruption in ->flags bit, checking this in page_cgroup.c
> is better.

I thought I'd keep them visible so we could remove them in a cycle or
two and I am sure they would get lost in mm/page_cgroup.c.  Who looks
at this file regularly? :)

But OTOH, they are under CONFIG_DEBUG_VM and corruption does not get
less likely as more code changes around pc->flags.

So I agree, they should be moved to lookup_page_cgroup() and be kept
indefinitely.

Thanks for your review.

	Hannes

---
Subject: memcg: remove direct page_cgroup-to-page pointer fix

Move pc -> page linkage checks to the lookup function itself.  I no
longer plan on removing them again, so there is no point in keeping
them visible at the callsites.

Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>
---

diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index 4e10f46..8438988 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -1055,7 +1055,6 @@ unsigned long mem_cgroup_isolate_pages(unsigned long nr_to_scan,
 			continue;
 
 		page = lookup_cgroup_page(pc);
-		VM_BUG_ON(pc != lookup_page_cgroup(page));
 
 		if (unlikely(!PageLRU(page)))
 			continue;
@@ -3298,7 +3297,6 @@ static int mem_cgroup_force_empty_list(struct mem_cgroup *mem,
 		spin_unlock_irqrestore(&zone->lru_lock, flags);
 
 		page = lookup_cgroup_page(pc);
-		VM_BUG_ON(pc != lookup_page_cgroup(page));
 
 		ret = mem_cgroup_move_parent(page, pc, mem, GFP_KERNEL);
 		if (ret == -ENOMEM)
diff --git a/mm/page_cgroup.c b/mm/page_cgroup.c
index e5f38e8..6c3f7a6 100644
--- a/mm/page_cgroup.c
+++ b/mm/page_cgroup.c
@@ -45,11 +45,14 @@ struct page_cgroup *lookup_page_cgroup(struct page *page)
 struct page *lookup_cgroup_page(struct page_cgroup *pc)
 {
 	unsigned long pfn;
+	struct page *page;
 	pg_data_t *pgdat;
 
 	pgdat = NODE_DATA(page_cgroup_array_id(pc));
 	pfn = pc - pgdat->node_page_cgroup + pgdat->node_start_pfn;
-	return pfn_to_page(pfn);
+	page = pfn_to_page(pfn);
+	VM_BUG_ON(pc != lookup_page_cgroup(page));
+	return page;
 }
 
 static int __init alloc_node_page_cgroup(int nid)
@@ -117,11 +120,14 @@ struct page_cgroup *lookup_page_cgroup(struct page *page)
 struct page *lookup_cgroup_page(struct page_cgroup *pc)
 {
 	struct mem_section *section;
+	struct page *page;
 	unsigned long nr;
 
 	nr = page_cgroup_array_id(pc);
 	section = __nr_to_section(nr);
-	return pfn_to_page(pc - section->page_cgroup);
+	page = pfn_to_page(pc - section->page_cgroup);
+	VM_BUG_ON(pc != lookup_page_cgroup(page));
+	return page;
 }
 
 /* __alloc_bootmem...() is protected by !slab_available() */

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
