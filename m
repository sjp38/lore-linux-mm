Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id 255EF6B02A4
	for <linux-mm@kvack.org>; Fri,  6 Aug 2010 00:15:56 -0400 (EDT)
Received: from m1.gw.fujitsu.co.jp ([10.0.50.71])
	by fgwmail7.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o764FmAx026313
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Fri, 6 Aug 2010 13:15:48 +0900
Received: from smail (m1 [127.0.0.1])
	by outgoing.m1.gw.fujitsu.co.jp (Postfix) with ESMTP id 4A1B445DE50
	for <linux-mm@kvack.org>; Fri,  6 Aug 2010 13:15:48 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (s1.gw.fujitsu.co.jp [10.0.50.91])
	by m1.gw.fujitsu.co.jp (Postfix) with ESMTP id 2080D45DE4D
	for <linux-mm@kvack.org>; Fri,  6 Aug 2010 13:15:48 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id E1D691DB8046
	for <linux-mm@kvack.org>; Fri,  6 Aug 2010 13:15:47 +0900 (JST)
Received: from m105.s.css.fujitsu.com (m105.s.css.fujitsu.com [10.249.87.105])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id 915411DB804C
	for <linux-mm@kvack.org>; Fri,  6 Aug 2010 13:15:47 +0900 (JST)
Date: Fri, 6 Aug 2010 13:10:53 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH 1/4 -mm][memcg] quick ID lookup in memcg
Message-Id: <20100806131053.411dce6d.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <xr93zkx0z8e5.fsf@ninji.mtv.corp.google.com>
References: <20100805184434.3a29c0f9.kamezawa.hiroyu@jp.fujitsu.com>
	<20100805185713.4d09339e.kamezawa.hiroyu@jp.fujitsu.com>
	<xr93zkx0z8e5.fsf@ninji.mtv.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Greg Thelen <gthelen@google.com>
Cc: linux-mm@kvack.org, "balbir@linux.vnet.ibm.com" <balbir@linux.vnet.ibm.com>, "nishimura@mxp.nes.nec.co.jp" <nishimura@mxp.nes.nec.co.jp>, vgoyal@redhat.com, m-ikeda@ds.jp.nec.com, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

On Thu, 05 Aug 2010 21:12:50 -0700
Greg Thelen <gthelen@google.com> wrote:

> KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> writes:
> 
> > From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> >
> > Now, memory cgroup has an ID per cgroup and make use of it at
> >  - hierarchy walk,
> >  - swap recording.
> >
> > This patch is for making more use of it. The final purpose is
> > to replace page_cgroup->mem_cgroup's pointer to an unsigned short.
> >
> > This patch caches a pointer of memcg in an array. By this, we
> > don't have to call css_lookup() which requires radix-hash walk.
> > This saves some amount of memory footprint at lookup memcg via id.
> >
> > Changelog: 20100804
> >  - fixed description in init/Kconfig
> >
> > Changelog: 20100730
> >  - fixed rcu_read_unlock() placement.
> >
> > Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> > ---
> >  init/Kconfig    |   10 ++++++++++
> >  mm/memcontrol.c |   48 ++++++++++++++++++++++++++++++++++--------------
> >  2 files changed, 44 insertions(+), 14 deletions(-)
> >
> > Index: mmotm-0727/mm/memcontrol.c
> > ===================================================================
> > --- mmotm-0727.orig/mm/memcontrol.c
> > +++ mmotm-0727/mm/memcontrol.c
> > @@ -292,6 +292,30 @@ static bool move_file(void)
> >  					&mc.to->move_charge_at_immigrate);
> >  }
> >  
> > +/* 0 is unused */
> > +static atomic_t mem_cgroup_num;
> > +#define NR_MEMCG_GROUPS (CONFIG_MEM_CGROUP_MAX_GROUPS + 1)
> > +static struct mem_cgroup *mem_cgroups[NR_MEMCG_GROUPS] __read_mostly;
> > +
> > +static struct mem_cgroup *id_to_memcg(unsigned short id)
> > +{
> > +	/*
> > +	 * This array is set to NULL when mem_cgroup is freed.
> > +	 * IOW, there are no more references && rcu_synchronized().
> > +	 * This lookup-caching is safe.
> > +	 */
> > +	if (unlikely(!mem_cgroups[id])) {
> > +		struct cgroup_subsys_state *css;
> > +
> > +		rcu_read_lock();
> > +		css = css_lookup(&mem_cgroup_subsys, id);
> > +		rcu_read_unlock();
> > +		if (!css)
> > +			return NULL;
> > +		mem_cgroups[id] = container_of(css, struct mem_cgroup, css);
> > +	}
> > +	return mem_cgroups[id];
> > +}
> 
> I am worried that id may be larger than CONFIG_MEM_CGROUP_MAX_GROUPS and
> cause an illegal array index.  I see that
> mem_cgroup_uncharge_swapcache() uses css_id() to compute 'id'.
> mem_cgroup_num ensures that there are never more than
> CONFIG_MEM_CGROUP_MAX_GROUPS memcg active.  But do we have guarantee
> that the that all of the css_id of each active memcg are less than
> NR_MEMCG_GROUPS?
> 
Yes. kernel/cgroup.c's ID assign routine use the smallest number, always.



> >  /*
> >   * Maximum loops in mem_cgroup_hierarchical_reclaim(), used for soft
> >   * limit reclaim to prevent infinite loops, if they ever occur.
> > @@ -1824,18 +1848,7 @@ static void mem_cgroup_cancel_charge(str
> >   * it's concern. (dropping refcnt from swap can be called against removed
> >   * memcg.)
> >   */
> > -static struct mem_cgroup *mem_cgroup_lookup(unsigned short id)
> > -{
> > -	struct cgroup_subsys_state *css;
> >  
> > -	/* ID 0 is unused ID */
> > -	if (!id)
> > -		return NULL;
> > -	css = css_lookup(&mem_cgroup_subsys, id);
> > -	if (!css)
> > -		return NULL;
> > -	return container_of(css, struct mem_cgroup, css);
> > -}
> >  
> >  struct mem_cgroup *try_get_mem_cgroup_from_page(struct page *page)
> >  {
> > @@ -1856,7 +1869,7 @@ struct mem_cgroup *try_get_mem_cgroup_fr
> >  		ent.val = page_private(page);
> >  		id = lookup_swap_cgroup(ent);
> >  		rcu_read_lock();
> > -		mem = mem_cgroup_lookup(id);
> > +		mem = id_to_memcg(id);
> >  		if (mem && !css_tryget(&mem->css))
> >  			mem = NULL;
> >  		rcu_read_unlock();
> > @@ -2208,7 +2221,7 @@ __mem_cgroup_commit_charge_swapin(struct
> >  
> >  		id = swap_cgroup_record(ent, 0);
> >  		rcu_read_lock();
> > -		memcg = mem_cgroup_lookup(id);
> > +		memcg = id_to_memcg(id);
> >  		if (memcg) {
> >  			/*
> >  			 * This recorded memcg can be obsolete one. So, avoid
> > @@ -2472,7 +2485,7 @@ void mem_cgroup_uncharge_swap(swp_entry_
> >  
> >  	id = swap_cgroup_record(ent, 0);
> >  	rcu_read_lock();
> > -	memcg = mem_cgroup_lookup(id);
> > +	memcg = id_to_memcg(id);
> >  	if (memcg) {
> >  		/*
> >  		 * We uncharge this because swap is freed.
> > @@ -3988,6 +4001,9 @@ static struct mem_cgroup *mem_cgroup_all
> >  	struct mem_cgroup *mem;
> >  	int size = sizeof(struct mem_cgroup);
> >  
> > +	if (atomic_read(&mem_cgroup_num) == NR_MEMCG_GROUPS)
> > +		return NULL;
> > +
> 
> I think that multiple tasks to be simultaneously running
> mem_cgroup_create().  Therefore more than NR_MEMCG_GROUPS memcg may be
> created.
> 

No. cgroup_mutex() is held.

Thanks,
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
