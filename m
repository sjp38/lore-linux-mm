Date: Thu, 28 Aug 2008 19:44:54 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [RFC][PATCH 5/14]  memcg: free page_cgroup by RCU
Message-Id: <20080828194454.3fa6d0d0.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <48B678C2.8010807@linux.vnet.ibm.com>
References: <20080822202720.b7977aab.kamezawa.hiroyu@jp.fujitsu.com>
	<20080822203457.d62e394d.kamezawa.hiroyu@jp.fujitsu.com>
	<48B678C2.8010807@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: balbir@linux.vnet.ibm.com
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "nishimura@mxp.nes.nec.co.jp" <nishimura@mxp.nes.nec.co.jp>
List-ID: <linux-mm.kvack.org>

On Thu, 28 Aug 2008 15:36:58 +0530
Balbir Singh <balbir@linux.vnet.ibm.com> wrote:

> 	KAMEZAWA Hiroyuki wrote:
> > Freeing page_cgroup by RCU.
> > 
> > This makes access to page->page_cgroup as RCU-safe.
> > 
> 
> In addition to freeing page_cgroup via RCU, we'll also need to use
> rcu_assign_pointer() and rcu_dereference() to make the access RCU safe.
> 
Yes. but it is not necessary until lockess patches. it's guarded by
lock/unlock_page_cgroup(). So, I didin't mention it here.
But ok, I'll write.

> Oh! I just see that the next set of patches do the correct thing, could you
> please write the change log correctly indicate that this patch release
> page->page_cgroup via RCU.
> 
Sorry, changelog will be fixed.


> > Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> > ---
> >  mm/memcontrol.c |   44 ++++++++++++++++++++++++++++++++++++--------
> >  1 file changed, 36 insertions(+), 8 deletions(-)
> > 
> > Index: mmtom-2.6.27-rc3+/mm/memcontrol.c
> > ===================================================================
> > --- mmtom-2.6.27-rc3+.orig/mm/memcontrol.c
> > +++ mmtom-2.6.27-rc3+/mm/memcontrol.c
> > @@ -588,19 +588,23 @@ unsigned long mem_cgroup_isolate_pages(u
> >   * Free obsolete page_cgroups which is linked to per-cpu drop list.
> >   */
> > 
> > -static void __free_obsolete_page_cgroup(void)
> > +struct page_cgroup_rcu_work {
> > +	struct rcu_head head;
> > +	struct page_cgroup *list;
> > +};
> > +
> > +static void __free_obsolete_page_cgroup_cb(struct rcu_head *head)
> >  {
> >  	struct mem_cgroup *memcg;
> >  	struct page_cgroup *pc, *next;
> >  	struct mem_cgroup_per_zone *mz, *page_mz;
> > -	struct mem_cgroup_sink_list *mcsl;
> > +	struct page_cgroup_rcu_work *work;
> >  	unsigned long flags;
> > 
> > -	mcsl = &get_cpu_var(memcg_sink_list);
> > -	next = mcsl->next;
> > -	mcsl->next = NULL;
> > -	mcsl->count = 0;
> > -	put_cpu_var(memcg_sink_list);
> > +
> > +	work = container_of(head, struct page_cgroup_rcu_work, head);
> > +	next = work->list;
> 
> What do we do with next here? I must be missing it, but where is the page_cgroup
> released?
> 
Maybe chasing diff is a bit complicated here. After this line, linked list of
page_cgroup from 'next' will be freed one by one.

(But this behavior may be changed in the next version.)

> > +	kfree(work);
> > 
> >  	mz = NULL;
> > 
> > @@ -627,6 +631,26 @@ static void __free_obsolete_page_cgroup(
> >  	local_irq_restore(flags);
> >  }
> > 
> > +static int __free_obsolete_page_cgroup(void)
> > +{
> > +	struct page_cgroup_rcu_work *work;
> > +	struct mem_cgroup_sink_list *mcsl;
> > +
> > +	work = kmalloc(sizeof(*work), GFP_ATOMIC);
> > +	if (!work)
> > +		return -ENOMEM;
> > +	INIT_RCU_HEAD(&work->head);
> > +
> > +	mcsl = &get_cpu_var(memcg_sink_list);
> > +	work->list = mcsl->next;
> > +	mcsl->next = NULL;
> > +	mcsl->count = 0;
> > +	put_cpu_var(memcg_sink_list);
> > +
> > +	call_rcu(&work->head, __free_obsolete_page_cgroup_cb);
> > +	return 0;
> > +}
> > +
> 
> I don't like this approach, seems complex, you allocate more memory in
> GFP_ATOMIC context, so that free can be called from RCU context.
> 
We should assume kmalloc() can return NULL.
But I understand you don't like this. allow me consider more.


> >  static void free_obsolete_page_cgroup(struct page_cgroup *pc)
> >  {
> >  	int count;
> > @@ -649,13 +673,17 @@ static DEFINE_MUTEX(memcg_force_drain_mu
> > 
> >  static void mem_cgroup_local_force_drain(struct work_struct *work)
> >  {
> > -	__free_obsolete_page_cgroup();
> > +	int ret;
> > +	do {
> > +		ret = __free_obsolete_page_cgroup();
> 
> We keep repeating till we get 0?
> 
yes. this returns 0 or -ENOMEM. 


Thanks,
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
