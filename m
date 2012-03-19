Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx187.postini.com [74.125.245.187])
	by kanga.kvack.org (Postfix) with SMTP id 8BBC96B00E8
	for <linux-mm@kvack.org>; Mon, 19 Mar 2012 02:53:48 -0400 (EDT)
Received: from /spool/local
	by e28smtp07.in.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <aneesh.kumar@linux.vnet.ibm.com>;
	Mon, 19 Mar 2012 12:23:00 +0530
Received: from d28av05.in.ibm.com (d28av05.in.ibm.com [9.184.220.67])
	by d28relay02.in.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id q2J6qtAm4014312
	for <linux-mm@kvack.org>; Mon, 19 Mar 2012 12:22:55 +0530
Received: from d28av05.in.ibm.com (loopback [127.0.0.1])
	by d28av05.in.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id q2JCNME2023189
	for <linux-mm@kvack.org>; Mon, 19 Mar 2012 23:23:23 +1100
From: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
Subject: Re: [PATCH -V4 04/10] memcg: Add HugeTLB extension
In-Reply-To: <4F669C2E.1010502@jp.fujitsu.com>
References: <1331919570-2264-1-git-send-email-aneesh.kumar@linux.vnet.ibm.com> <1331919570-2264-5-git-send-email-aneesh.kumar@linux.vnet.ibm.com> <4F669C2E.1010502@jp.fujitsu.com>
Date: Mon, 19 Mar 2012 12:22:53 +0530
Message-ID: <874ntlkrp6.fsf@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: linux-mm@kvack.org, mgorman@suse.de, dhillf@gmail.com, aarcange@redhat.com, mhocko@suse.cz, akpm@linux-foundation.org, hannes@cmpxchg.org, linux-kernel@vger.kernel.org, cgroups@vger.kernel.org

On Mon, 19 Mar 2012 11:38:38 +0900, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> wrote:
> (2012/03/17 2:39), Aneesh Kumar K.V wrote:
> 
> > From: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
> > 
> > This patch implements a memcg extension that allows us to control
> > HugeTLB allocations via memory controller.
> > 
> 
> 
> If you write some details here, it will be helpful for review and
> seeing log after merge.

Will add more info.

> 
> 
> > Signed-off-by: Aneesh Kumar K.V <aneesh.kumar@linux.vnet.ibm.com>
> > ---
> >  include/linux/hugetlb.h    |    1 +
> >  include/linux/memcontrol.h |   42 +++++++++++++
> >  init/Kconfig               |    8 +++
> >  mm/hugetlb.c               |    2 +-
> >  mm/memcontrol.c            |  138 ++++++++++++++++++++++++++++++++++++++++++++
> >  5 files changed, 190 insertions(+), 1 deletions(-)

....

> > +#ifdef CONFIG_MEM_RES_CTLR_HUGETLB
> > +static bool mem_cgroup_have_hugetlb_usage(struct mem_cgroup *memcg)
> > +{
> > +	int idx;
> > +	for (idx = 0; idx < hugetlb_max_hstate; idx++) {
> > +		if (memcg->hugepage[idx].usage > 0)
> > +			return 1;
> > +	}
> > +	return 0;
> > +}
> 
> 
> Please use res_counter_read_u64() rather than reading the value directly.
> 

The open-coded variant is mostly derived from mem_cgroup_force_empty. I
have updated the patch to use res_counter_read_u64. 

> 
> > +
> > +int mem_cgroup_hugetlb_charge_page(int idx, unsigned long nr_pages,
> > +				   struct mem_cgroup **ptr)
> > +{
> > +	int ret = 0;
> > +	struct mem_cgroup *memcg;
> > +	struct res_counter *fail_res;
> > +	unsigned long csize = nr_pages * PAGE_SIZE;
> > +
> > +	if (mem_cgroup_disabled())
> > +		return 0;
> > +again:
> > +	rcu_read_lock();
> > +	memcg = mem_cgroup_from_task(current);
> > +	if (!memcg)
> > +		memcg = root_mem_cgroup;
> > +	if (mem_cgroup_is_root(memcg)) {
> > +		rcu_read_unlock();
> > +		goto done;
> > +	}
> 
> 
> One concern is.... Now, yes, memory cgroup doesn't account root cgroup
> and doesn't update res->usage to avoid updating shared counter overheads
> when memcg is not mounted. But memory.usage_in_bytes files works
> for root memcg with reading percpu statistics.
> 
> So, how about counting usage for root cgroup even if it cannot be limited ?
> Considering hugetlb fs usage, updating res_counter here doesn't have
> performance problem of false sharing..
> Then, you can remove root_mem_cgroup() checks inserted several places.
> 

Yes. That is a good idea. Will update the patch.


> <snip>
> 
> >  	struct mem_cgroup *memcg = mem_cgroup_from_cont(cont);
> > +	/*
> > +	 * Don't allow memcg removal if we have HugeTLB resource
> > +	 * usage.
> > +	 */
> > +	if (mem_cgroup_have_hugetlb_usage(memcg))
> > +		return -EBUSY;
> >  
> >  	return mem_cgroup_force_empty(memcg, false);
> >  }
> 
> 
> Is this fixed by patch 8+9 ?

Yes. 

-aneesh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
