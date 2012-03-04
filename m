Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx151.postini.com [74.125.245.151])
	by kanga.kvack.org (Postfix) with SMTP id CB0E06B00EC
	for <linux-mm@kvack.org>; Sun,  4 Mar 2012 13:07:40 -0500 (EST)
Received: from /spool/local
	by e28smtp07.in.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <aneesh.kumar@linux.vnet.ibm.com>;
	Sun, 4 Mar 2012 23:37:37 +0530
Received: from d28av01.in.ibm.com (d28av01.in.ibm.com [9.184.220.63])
	by d28relay04.in.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id q24I7Vag4116510
	for <linux-mm@kvack.org>; Sun, 4 Mar 2012 23:37:31 +0530
Received: from d28av01.in.ibm.com (loopback [127.0.0.1])
	by d28av01.in.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id q24I7VRO004772
	for <linux-mm@kvack.org>; Sun, 4 Mar 2012 23:37:31 +0530
From: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
Subject: Re: [PATCH -V2 4/9] memcg: Add non reclaim resource tracking to memcg
In-Reply-To: <20120302173816.9796f243.kamezawa.hiroyu@jp.fujitsu.com>
References: <1330593380-1361-1-git-send-email-aneesh.kumar@linux.vnet.ibm.com> <1330593380-1361-5-git-send-email-aneesh.kumar@linux.vnet.ibm.com> <20120302173816.9796f243.kamezawa.hiroyu@jp.fujitsu.com>
Date: Sun, 04 Mar 2012 23:37:22 +0530
Message-ID: <87ipikdyud.fsf@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: linux-mm@kvack.org, mgorman@suse.de, dhillf@gmail.com, aarcange@redhat.com, mhocko@suse.cz, akpm@linux-foundation.org, hannes@cmpxchg.org, linux-kernel@vger.kernel.org, cgroups@vger.kernel.org

On Fri, 2 Mar 2012 17:38:16 +0900, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> wrote:
> On Thu,  1 Mar 2012 14:46:15 +0530
> "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com> wrote:
> 
> > From: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
> > 
> > Non reclaim resources include hugetlb pages or ramfs pages.
> > Both these file systems are memory based and they don't support
> > page reclaim. So enforcing memory controller limit during actual
> > page allocation doesn't make sense for them. Instead we would
> > enforce the limit during mmap and keep track of the mmap range
> > along with memcg information in charge list.
> > 
> > We could have multiple non reclaim resources which we want to track
> > indepedently, like huge pages with different huge page size.
> > 
> > Current code don't allow removal of memcg if they have any non
> > reclaim resource charge.
> 
> Hmmm why ? The reason is from coding trouble ? Or it's the spec. ?


Not it is not the spec. It is just that I haven't got around
implementing the needed changes. In order to be able to remove 
cgroup with reclaim resource charges, we should be tracking all the
charge list (which is currently attached to inode or to vm_area_struct)
in struct mem_cgroup, so that on memcg removal, we move those regions in
charge list to point to parent memcg. 

> 
> 
> > 
> > Signed-off-by: Aneesh Kumar K.V <aneesh.kumar@linux.vnet.ibm.com>
> > ---
> >  include/linux/memcontrol.h |   11 +++
> >  init/Kconfig               |   11 +++
> >  mm/memcontrol.c            |  198 +++++++++++++++++++++++++++++++++++++++++++-
> >  3 files changed, 219 insertions(+), 1 deletions(-)
> > 
> > diff --git a/include/linux/memcontrol.h b/include/linux/memcontrol.h
> > index 4d34356..59d93ee 100644
> > --- a/include/linux/memcontrol.h
> > +++ b/include/linux/memcontrol.h
> > @@ -171,6 +171,17 @@ void mem_cgroup_split_huge_fixup(struct page *head);
> >  bool mem_cgroup_bad_page_check(struct page *page);
> >  void mem_cgroup_print_bad_page(struct page *page);
> >  #endif
> > +extern long mem_cgroup_try_noreclaim_charge(struct list_head *chg_list,
> > +					    unsigned long from,
> > +					    unsigned long to, int idx);
> > +extern void mem_cgroup_noreclaim_uncharge(struct list_head *chg_list,
> > +					  int idx, unsigned long nr_pages);
> > +extern void mem_cgroup_commit_noreclaim_charge(struct list_head *chg_list,
> > +					       unsigned long from,
> > +					       unsigned long to);
> > +extern long mem_cgroup_truncate_chglist_range(struct list_head *chg_list,
> > +					      unsigned long from,
> > +					      unsigned long to, int idx);
> >  #else /* CONFIG_CGROUP_MEM_RES_CTLR */
> >  struct mem_cgroup;
> >  
> > diff --git a/init/Kconfig b/init/Kconfig
> > index 3f42cd6..c4306f7 100644
> > --- a/init/Kconfig
> > +++ b/init/Kconfig
> > @@ -673,6 +673,17 @@ config CGROUP_MEM_RES_CTLR
> >  	  This config option also selects MM_OWNER config option, which
> >  	  could in turn add some fork/exit overhead.
> >  
> > +config MEM_RES_CTLR_NORECLAIM
> > +	bool "Memory Resource Controller non reclaim Extension"
> > +	depends on CGROUP_MEM_RES_CTLR
> 
> EXPERIMENTAL please.
> 

Will do

> 
> > +	help
> > +	  Add non reclaim resource management to memory resource controller.
> > +	  Currently only HugeTLB pages will be managed using this extension.
> > +	  The controller limit is enforced during mmap(2), so that
> > +	  application can fall back to allocations using smaller page size
> > +	  if the memory controller limit prevented them from allocating HugeTLB
> > +	  pages.
> > +
> 
> Hm. In other thread, KMEM accounting is discussed. There is 2 proposals and
>  - 1st is accounting only reclaimable slabs (as dcache etc.)
>  - 2nd is accounting all slab allocations.
> 
> Here, 2nd one includes NORECLAIM kmem cache. (Discussion is not ended.)
> 
> So, for your developments,  How about MEM_RES_CTLR_HUGEPAGE ?

Frankly I didn't like the noreclaim name, I also didn't want to indicate
HUGEPAGE, because the code doesn't make any huge page assumption.


> 
> With your design, memory.hugeltb.XX.xxxxxx files area added and
> the interface is divided from other noreclaim mems. If necessary,
> iwe can change the scope of config without affecting user space by refactoring
> after having this features.
> 
> BTW, please set default n because this will forbid rmdir of cgroup.
> 


Will do

> 
> 
> >  config CGROUP_MEM_RES_CTLR_SWAP
> >  	bool "Memory Resource Controller Swap Extension"
> >  	depends on CGROUP_MEM_RES_CTLR && SWAP
> > diff --git a/mm/memcontrol.c b/mm/memcontrol.c
> > index 6728a7a..b00d028 100644
> > --- a/mm/memcontrol.c
> > +++ b/mm/memcontrol.c
> > @@ -49,6 +49,7 @@
> >  #include <linux/page_cgroup.h>
> >  #include <linux/cpu.h>
> >  #include <linux/oom.h>
> > +#include <linux/region.h>
> >  #include "internal.h"
> >  #include <net/sock.h>
> >  #include <net/tcp_memcontrol.h>
> > @@ -214,6 +215,11 @@ static void mem_cgroup_threshold(struct mem_cgroup *memcg);
> >  static void mem_cgroup_oom_notify(struct mem_cgroup *memcg);
> >  
> >  /*
> > + * Currently only hugetlbfs pages are tracked using no reclaim
> > + * resource count. So we need only MAX_HSTATE res counter
> > + */
> > +#define MEMCG_MAX_NORECLAIM HUGE_MAX_HSTATE
> > +/*
> >   * The memory controller data structure. The memory controller controls both
> >   * page cache and RSS per cgroup. We would eventually like to provide
> >   * statistics based on the statistics developed by Rik Van Riel for clock-pro,
> > @@ -235,6 +241,11 @@ struct mem_cgroup {
> >  	 */
> >  	struct res_counter memsw;
> >  	/*
> > +	 * the counter to account for non reclaim resources
> > +	 * like hugetlb pages
> > +	 */
> > +	struct res_counter no_rcl_res[MEMCG_MAX_NORECLAIM];
> 
> struct res_counter hugepages;
> 
> will be ok.
> 

My goal was to make this patch not to mention hugepages, because
it doesn't really have any depedency on hugepages. That is one of the reason
for adding MEMCG_MAX_NORECLAIM. Later if we want other in memory file system
(shmemfs) to limit the resource usage in a similar fashion, we should be
able to use this memcg changes.

May be for this patchset I can make the changes you suggested and later
when we want to reuse the code make it more generic ?


> 
> > +	/*
> >  	 * Per cgroup active and inactive list, similar to the
> >  	 * per zone LRU lists.
> >  	 */
> > @@ -4887,6 +4898,7 @@ err_cleanup:
> >  static struct cgroup_subsys_state * __ref
> >  mem_cgroup_create(struct cgroup_subsys *ss, struct cgroup *cont)
> >  {
> > +	int idx;
> >  	struct mem_cgroup *memcg, *parent;
> >  	long error = -ENOMEM;
> >  	int node;
> > @@ -4922,6 +4934,10 @@ mem_cgroup_create(struct cgroup_subsys *ss, struct cgroup *cont)
> >  	if (parent && parent->use_hierarchy) {
> >  		res_counter_init(&memcg->res, &parent->res);
> >  		res_counter_init(&memcg->memsw, &parent->memsw);
> > +		for (idx = 0; idx < MEMCG_MAX_NORECLAIM; idx++) {
> > +			res_counter_init(&memcg->no_rcl_res[idx],
> > +					 &parent->no_rcl_res[idx]);
> > +		}
> 
> You can remove this kinds of loop and keep your implemenation simple.


Can you explain this ? How can we remote the loop ?. We want to track
each huge page size as a seperate resource. 

> 
> >  		/*
> >  		 * We increment refcnt of the parent to ensure that we can
> >  		 * safely access it on res_counter_charge/uncharge.
> > @@ -4932,6 +4948,8 @@ mem_cgroup_create(struct cgroup_subsys *ss, struct cgroup *cont)
> >  	} else {
> >  		res_counter_init(&memcg->res, NULL);
> >  		res_counter_init(&memcg->memsw, NULL);
> > +		for (idx = 0; idx < MEMCG_MAX_NORECLAIM; idx++)
> > +			res_counter_init(&memcg->no_rcl_res[idx], NULL);
> >  	}
> >  	memcg->last_scanned_node = MAX_NUMNODES;
> >  	INIT_LIST_HEAD(&memcg->oom_notify);
> > @@ -4950,8 +4968,22 @@ free_out:
> >  static int mem_cgroup_pre_destroy(struct cgroup_subsys *ss,
> >  					struct cgroup *cont)
> >  {
> > +	int idx;
> > +	u64 val;
> >  	struct mem_cgroup *memcg = mem_cgroup_from_cont(cont);
> > -
> > +	/*
> > +	 * We don't allow a cgroup deletion if it have some
> > +	 * non reclaim resource charged against it. We can
> > +	 * update the charge list to point to parent cgroup
> > +	 * and allow this cgroup deletion here. But that
> > +	 * involve tracking all the chg list which have this
> > +	 * cgroup reference.
> > +	 */
> 
> I don't like this..... until this is fixed, default should be "N".


Yes. Will update Kconfig

> 
> 
> 
> > +	for (idx = 0; idx < MEMCG_MAX_NORECLAIM; idx++) {
> > +		val = res_counter_read_u64(&memcg->no_rcl_res[idx], RES_USAGE);
> > +		if (val)
> > +			return -EBUSY;
> > +	}
> >  	return mem_cgroup_force_empty(memcg, false);
> >  }
> >  
> > @@ -5489,6 +5521,170 @@ static void mem_cgroup_move_task(struct cgroup_subsys *ss,
> >  }
> >  #endif
> >  
> > +#ifdef CONFIG_MEM_RES_CTLR_NORECLAIM
> > +/*
> > + * For supporting resource control on non reclaim pages like hugetlbfs
> > + * and ramfs, we enforce limit during mmap time. We also maintain
> > + * a chg list for these resource, which track the range alog with
> > + * memcg information. We need to have seperate chg_list for shared
> > + * and private mapping. Shared mapping are mostly maintained in
> > + * file inode and private mapping in vm_area_struct.
> > + */
> > +long mem_cgroup_try_noreclaim_charge(struct list_head *chg_list,
> > +				     unsigned long from, unsigned long to,
> > +				     int idx)
> > +{
> > +	long chg;
> > +	int ret = 0;
> > +	unsigned long csize;
> > +	struct mem_cgroup *memcg;
> > +	struct res_counter *fail_res;
> > +
> > +	/*
> > +	 * Get the task cgroup within rcu_readlock and also
> > +	 * get cgroup reference to make sure cgroup destroy won't
> > +	 * race with page_charge. We don't allow a cgroup destroy
> > +	 * when the cgroup have some charge against it
> > +	 */
> > +	rcu_read_lock();
> > +	memcg = mem_cgroup_from_task(current);
> > +	css_get(&memcg->css);
> 
> css_tryget() ?
> 


Why ?

> 
> > +	rcu_read_unlock();
> > +
> > +	chg = region_chg(chg_list, from, to, (unsigned long)memcg);
> > +	if (chg < 0)
> > +		goto err_out;
> 
> I don't think all NORECLAIM objects has 'region' ;)
> Makeing this dedicated for hugetlbfs will be good.
> 
> 

Will do. This should be no reclaim fs objects. 


> 
> > +
> > +	if (mem_cgroup_is_root(memcg))
> > +		goto err_out;
> > +
> > +	csize = chg * PAGE_SIZE;
> > +	ret = res_counter_charge(&memcg->no_rcl_res[idx], csize, &fail_res);
> > +
> > +err_out:
> > +	/* Now that we have charged we can drop cgroup reference */
> > +	css_put(&memcg->css);
> > +	if (!ret)
> > +		return chg;
> > +
> > +	/* We don't worry about region_uncharge */
> > +	return ret;
> > +}
> > +
> > +void mem_cgroup_noreclaim_uncharge(struct list_head *chg_list,
> > +				   int idx, unsigned long nr_pages)
> > +{
> > +	struct mem_cgroup *memcg;
> > +	unsigned long csize = nr_pages * PAGE_SIZE;
> > +
> > +	rcu_read_lock();
> > +	memcg = mem_cgroup_from_task(current);
> > +
> > +	if (!mem_cgroup_is_root(memcg))
> > +		res_counter_uncharge(&memcg->no_rcl_res[idx], csize);
> 
> What happens a task using hugeltb is moved to root cgroup ?
> 

When task migrate we don't move the charge. So after the task get moved
to root cgroup, the resource counter will not get charged. 



> 
> > +	rcu_read_unlock();
> > +	/*
> > +	 * We could ideally remove zero size regions from
> > +	 * resv map hcg_regions here
> > +	 */
> > +	return;
> > +}
> > +
> > +void mem_cgroup_commit_noreclaim_charge(struct list_head *chg_list,
> > +					unsigned long from, unsigned long to)
> > +{
> > +	struct mem_cgroup *memcg;
> > +
> > +	rcu_read_lock();
> > +	memcg = mem_cgroup_from_task(current);
> > +	region_add(chg_list, from, to, (unsigned long)memcg);
> > +	rcu_read_unlock();
> > +	return;
> > +}
> 
> Why we have both of try_charge() and charge ?
> 
> 

try_charge and commit_charge ?. We do the below sequence:

try_charge()
alloc_page()
commit_charge()

We actually do memcg charging in try_charge, but the charge list won't
be updated to indicate the region boundaries in try_charge. That is
because, if alloc_page() failed, we will not be able to undo the region
boundary update, because we don't have enough information there to find
which region got added/updated by the previous try_charge(). Hence we split the
charging into two steps: try_charge and commit_charge and update region
boundaries in commit_charge()


> > +
> > +long mem_cgroup_truncate_chglist_range(struct list_head *chg_list,
> > +				       unsigned long from, unsigned long to,
> > +				       int idx)
> > +{
> > +	long chg = 0, csize;
> > +	struct mem_cgroup *memcg;
> > +	struct file_region *rg, *trg;
> > +
> > +	/* Locate the region we are either in or before. */
> > +	list_for_each_entry(rg, chg_list, link)
> > +		if (from <= rg->to)
> > +			break;
> > +	if (&rg->link == chg_list)
> > +		return 0;
> > +
> > +	/* If we are in the middle of a region then adjust it. */
> > +	if (from > rg->from) {
> > +		if (to < rg->to) {
> > +			struct file_region *nrg;
> > +			/* rg->from from to rg->to */
> > +			nrg = kmalloc(sizeof(*nrg), GFP_KERNEL);
> > +			/*
> > +			 * If we fail to allocate we return the
> > +			 * with the 0 charge . Later a complete
> > +			 * truncate will reclaim the left over space
> > +			 */
> > +			if (!nrg)
> > +				return 0;
> > +			nrg->from = to;
> > +			nrg->to = rg->to;
> > +			nrg->data = rg->data;
> > +			INIT_LIST_HEAD(&nrg->link);
> > +			list_add(&nrg->link, &rg->link);
> > +
> > +			/* Adjust the rg entry */
> > +			rg->to = from;
> > +			chg = to - from;
> > +			memcg = (struct mem_cgroup *)rg->data;
> > +			if (!mem_cgroup_is_root(memcg)) {
> > +				csize = chg * PAGE_SIZE;
> > +				res_counter_uncharge(&memcg->no_rcl_res[idx], csize);
> > +			}
> > +			return chg;
> > +		}
> > +		chg = rg->to - from;
> > +		rg->to = from;
> > +		memcg = (struct mem_cgroup *)rg->data;
> > +		if (!mem_cgroup_is_root(memcg)) {
> > +			csize = chg * PAGE_SIZE;
> > +			res_counter_uncharge(&memcg->no_rcl_res[idx], csize);
> > +		}
> > +		rg = list_entry(rg->link.next, typeof(*rg), link);
> > +	}
> > +	/* Drop any remaining regions till to */
> > +	list_for_each_entry_safe(rg, trg, rg->link.prev, link) {
> > +		if (rg->from >= to)
> > +			break;
> > +		if (&rg->link == chg_list)
> > +			break;
> > +		if (rg->to > to) {
> > +			/* rg->from to rg->to */
> > +			chg += to - rg->from;
> > +			rg->from = to;
> > +			memcg = (struct mem_cgroup *)rg->data;
> > +			if (!mem_cgroup_is_root(memcg)) {
> > +				csize = (to - rg->from) * PAGE_SIZE;
> > +				res_counter_uncharge(&memcg->no_rcl_res[idx], csize);
> > +			}
> > +			return chg;
> > +		}
> > +		chg += rg->to - rg->from;
> > +		memcg = (struct mem_cgroup *)rg->data;
> > +		if (!mem_cgroup_is_root(memcg)) {
> > +			csize = (rg->to - rg->from) * PAGE_SIZE;
> > +			res_counter_uncharge(&memcg->no_rcl_res[idx], csize);
> > +		}
> > +		list_del(&rg->link);
> > +		kfree(rg);
> > +	}
> > +	return chg;
> > +}
> > +#endif
> > +
> 
> Can't we move most of this to region.c ?

The difference between this and region_truncate_range is we do memcg
uncharge here. I am not sure we can move this change to region.c
because of struct mem_cgroup dependency here. What we can do is to
update region_truncate to take a callback that will be called before
destroying a region.


Thanks for the review,
-aneesh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
