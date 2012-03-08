Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx103.postini.com [74.125.245.103])
	by kanga.kvack.org (Postfix) with SMTP id 6F89C6B002C
	for <linux-mm@kvack.org>; Thu,  8 Mar 2012 06:48:40 -0500 (EST)
Received: from /spool/local
	by e28smtp04.in.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <aneesh.kumar@linux.vnet.ibm.com>;
	Thu, 8 Mar 2012 17:18:34 +0530
Received: from d28av02.in.ibm.com (d28av02.in.ibm.com [9.184.220.64])
	by d28relay02.in.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id q28BmTpe2072622
	for <linux-mm@kvack.org>; Thu, 8 Mar 2012 17:18:30 +0530
Received: from d28av02.in.ibm.com (loopback [127.0.0.1])
	by d28av02.in.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id q28HJ562022832
	for <linux-mm@kvack.org>; Fri, 9 Mar 2012 04:19:05 +1100
From: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
Subject: Re: [PATCH -V2 4/9] memcg: Add non reclaim resource tracking to memcg
In-Reply-To: <20120308145628.f911419d.kamezawa.hiroyu@jp.fujitsu.com>
References: <1330593380-1361-1-git-send-email-aneesh.kumar@linux.vnet.ibm.com> <1330593380-1361-5-git-send-email-aneesh.kumar@linux.vnet.ibm.com> <20120302173816.9796f243.kamezawa.hiroyu@jp.fujitsu.com> <87ipikdyud.fsf@linux.vnet.ibm.com> <20120308145628.f911419d.kamezawa.hiroyu@jp.fujitsu.com>
Date: Thu, 08 Mar 2012 17:18:21 +0530
Message-ID: <871up39uuy.fsf@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: linux-mm@kvack.org, mgorman@suse.de, dhillf@gmail.com, aarcange@redhat.com, mhocko@suse.cz, akpm@linux-foundation.org, hannes@cmpxchg.org, linux-kernel@vger.kernel.org, cgroups@vger.kernel.org

On Thu, 8 Mar 2012 14:56:28 +0900, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> wrote:
> On Sun, 04 Mar 2012 23:37:22 +0530
> "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com> wrote:
> 
> > On Fri, 2 Mar 2012 17:38:16 +0900, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> wrote:
> > > On Thu,  1 Mar 2012 14:46:15 +0530
> > > "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com> wrote:
> > > 
> > > > From: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
> 
> > > 
> > > > +	help
> > > > +	  Add non reclaim resource management to memory resource controller.
> > > > +	  Currently only HugeTLB pages will be managed using this extension.
> > > > +	  The controller limit is enforced during mmap(2), so that
> > > > +	  application can fall back to allocations using smaller page size
> > > > +	  if the memory controller limit prevented them from allocating HugeTLB
> > > > +	  pages.
> > > > +
> > > 
> > > Hm. In other thread, KMEM accounting is discussed. There is 2 proposals and
> > >  - 1st is accounting only reclaimable slabs (as dcache etc.)
> > >  - 2nd is accounting all slab allocations.
> > > 
> > > Here, 2nd one includes NORECLAIM kmem cache. (Discussion is not ended.)
> > > 
> > > So, for your developments,  How about MEM_RES_CTLR_HUGEPAGE ?
> > 
> > Frankly I didn't like the noreclaim name, I also didn't want to indicate
> > HUGEPAGE, because the code doesn't make any huge page assumption.
> 
> You can add this config for HUGEPAGE interfaces.
> Later we can sort out other configs.
> 

Will do

> 
> > > 
> > > 
> > > >  config CGROUP_MEM_RES_CTLR_SWAP
> > > >  	bool "Memory Resource Controller Swap Extension"
> > > >  	depends on CGROUP_MEM_RES_CTLR && SWAP
> > > > diff --git a/mm/memcontrol.c b/mm/memcontrol.c
> > > > index 6728a7a..b00d028 100644
> > > > --- a/mm/memcontrol.c
> > > > +++ b/mm/memcontrol.c
> > > > @@ -49,6 +49,7 @@
> > > >  #include <linux/page_cgroup.h>
> > > >  #include <linux/cpu.h>
> > > >  #include <linux/oom.h>
> > > > +#include <linux/region.h>
> > > >  #include "internal.h"
> > > >  #include <net/sock.h>
> > > >  #include <net/tcp_memcontrol.h>
> > > > @@ -214,6 +215,11 @@ static void mem_cgroup_threshold(struct mem_cgroup *memcg);
> > > >  static void mem_cgroup_oom_notify(struct mem_cgroup *memcg);
> > > >  
> > > >  /*
> > > > + * Currently only hugetlbfs pages are tracked using no reclaim
> > > > + * resource count. So we need only MAX_HSTATE res counter
> > > > + */
> > > > +#define MEMCG_MAX_NORECLAIM HUGE_MAX_HSTATE
> > > > +/*
> > > >   * The memory controller data structure. The memory controller controls both
> > > >   * page cache and RSS per cgroup. We would eventually like to provide
> > > >   * statistics based on the statistics developed by Rik Van Riel for clock-pro,
> > > > @@ -235,6 +241,11 @@ struct mem_cgroup {
> > > >  	 */
> > > >  	struct res_counter memsw;
> > > >  	/*
> > > > +	 * the counter to account for non reclaim resources
> > > > +	 * like hugetlb pages
> > > > +	 */
> > > > +	struct res_counter no_rcl_res[MEMCG_MAX_NORECLAIM];
> > > 
> > > struct res_counter hugepages;
> > > 
> > > will be ok.
> > > 
> > 
> > My goal was to make this patch not to mention hugepages, because
> > it doesn't really have any depedency on hugepages. That is one of the reason
> > for adding MEMCG_MAX_NORECLAIM. Later if we want other in memory file system
> > (shmemfs) to limit the resource usage in a similar fashion, we should be
> > able to use this memcg changes.
> > 
> > May be for this patchset I can make the changes you suggested and later
> > when we want to reuse the code make it more generic ?
> > 
> 
> yes. If there is no user interface change, internal code change will be welcomed.
> 

Ok

> 
> > 
> > > 
> > > > +	/*
> > > >  	 * Per cgroup active and inactive list, similar to the
> > > >  	 * per zone LRU lists.
> > > >  	 */
> > > > @@ -4887,6 +4898,7 @@ err_cleanup:
> > > >  static struct cgroup_subsys_state * __ref
> > > >  mem_cgroup_create(struct cgroup_subsys *ss, struct cgroup *cont)
> > > >  {
> > > > +	int idx;
> > > >  	struct mem_cgroup *memcg, *parent;
> > > >  	long error = -ENOMEM;
> > > >  	int node;
> > > > @@ -4922,6 +4934,10 @@ mem_cgroup_create(struct cgroup_subsys *ss, struct cgroup *cont)
> > > >  	if (parent && parent->use_hierarchy) {
> > > >  		res_counter_init(&memcg->res, &parent->res);
> > > >  		res_counter_init(&memcg->memsw, &parent->memsw);
> > > > +		for (idx = 0; idx < MEMCG_MAX_NORECLAIM; idx++) {
> > > > +			res_counter_init(&memcg->no_rcl_res[idx],
> > > > +					 &parent->no_rcl_res[idx]);
> > > > +		}
> > > 
> > > You can remove this kinds of loop and keep your implemenation simple.
> > 
> > 
> > Can you explain this ? How can we remote the loop ?. We want to track
> > each huge page size as a seperate resource. 
> > 
> Ah, sorry. I miseed it. please ignore.
> 
> 
> 
> > > > +long mem_cgroup_try_noreclaim_charge(struct list_head *chg_list,
> > > > +				     unsigned long from, unsigned long to,
> > > > +				     int idx)
> > > > +{
> > > > +	long chg;
> > > > +	int ret = 0;
> > > > +	unsigned long csize;
> > > > +	struct mem_cgroup *memcg;
> > > > +	struct res_counter *fail_res;
> > > > +
> > > > +	/*
> > > > +	 * Get the task cgroup within rcu_readlock and also
> > > > +	 * get cgroup reference to make sure cgroup destroy won't
> > > > +	 * race with page_charge. We don't allow a cgroup destroy
> > > > +	 * when the cgroup have some charge against it
> > > > +	 */
> > > > +	rcu_read_lock();
> > > > +	memcg = mem_cgroup_from_task(current);
> > > > +	css_get(&memcg->css);
> > > 
> > > css_tryget() ?
> > > 
> > 
> > 
> > Why ?
> > 
> 
> current<->cgroup relationship isn't under any locks. So, we do speculative
> access with rcu_read_lock() and css_tryget().
> 

Will update.

Right now i am redoing the patch to see if enforcing limit during
page fault (alloc_huge_page()) and page free (free_huge_page()) simplifies
the patchset. Only problem with that approach is, application should have
a clear idea about it's hugepage usage, or else enforcing the limit at
fault time will result in application getting SIGBUS. But otherwise the approach
simplifies the cgroup removal and brings the code much closer to memcg
design.

-aneesh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
