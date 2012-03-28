Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx102.postini.com [74.125.245.102])
	by kanga.kvack.org (Postfix) with SMTP id C37C26B00FD
	for <linux-mm@kvack.org>; Wed, 28 Mar 2012 09:51:23 -0400 (EDT)
Received: from /spool/local
	by e28smtp01.in.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <aneesh.kumar@linux.vnet.ibm.com>;
	Wed, 28 Mar 2012 19:11:19 +0530
Received: from d28av03.in.ibm.com (d28av03.in.ibm.com [9.184.220.65])
	by d28relay01.in.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id q2SDedL31499190
	for <linux-mm@kvack.org>; Wed, 28 Mar 2012 19:10:39 +0530
Received: from d28av03.in.ibm.com (loopback [127.0.0.1])
	by d28av03.in.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id q2SJ9qtI009029
	for <linux-mm@kvack.org>; Thu, 29 Mar 2012 06:09:53 +1100
From: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
Subject: Re: [PATCH -V4 04/10] memcg: Add HugeTLB extension
In-Reply-To: <20120328113304.GE20949@tiehlicka.suse.cz>
References: <1331919570-2264-1-git-send-email-aneesh.kumar@linux.vnet.ibm.com> <1331919570-2264-5-git-send-email-aneesh.kumar@linux.vnet.ibm.com> <20120328113304.GE20949@tiehlicka.suse.cz>User-Agent: Notmuch/0.11.1+346~g13d19c3 (http://notmuchmail.org) Emacs/23.3.1 (x86_64-pc-linux-gnu)
Date: Wed, 28 Mar 2012 19:10:36 +0530
Message-ID: <87d37wetd7.fsf@skywalker.in.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>
Cc: linux-mm@kvack.org, mgorman@suse.de, kamezawa.hiroyu@jp.fujitsu.com, dhillf@gmail.com, aarcange@redhat.com, akpm@linux-foundation.org, hannes@cmpxchg.org, linux-kernel@vger.kernel.org, cgroups@vger.kernel.org

Michal Hocko <mhocko@suse.cz> writes:

> On Fri 16-03-12 23:09:24, Aneesh Kumar K.V wrote:
>> From: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
>> 
>> This patch implements a memcg extension that allows us to control
>> HugeTLB allocations via memory controller.
>
> And the infrastructure is not used at this stage (you forgot to
> mention).
> The changelog should be much more descriptive.


Will update the changelog.

>
>> 
>> Signed-off-by: Aneesh Kumar K.V <aneesh.kumar@linux.vnet.ibm.com>
>> ---
>>  include/linux/hugetlb.h    |    1 +
>>  include/linux/memcontrol.h |   42 +++++++++++++
>>  init/Kconfig               |    8 +++
>>  mm/hugetlb.c               |    2 +-
>>  mm/memcontrol.c            |  138 ++++++++++++++++++++++++++++++++++++++++++++
>>  5 files changed, 190 insertions(+), 1 deletions(-)
>> 
> [...]
>> diff --git a/init/Kconfig b/init/Kconfig
>> index 3f42cd6..f0eb8aa 100644
>> --- a/init/Kconfig
>> +++ b/init/Kconfig
>> @@ -725,6 +725,14 @@ config CGROUP_PERF
>>  
>>  	  Say N if unsure.
>>  
>> +config MEM_RES_CTLR_HUGETLB
>> +	bool "Memory Resource Controller HugeTLB Extension (EXPERIMENTAL)"
>> +	depends on CGROUP_MEM_RES_CTLR && HUGETLB_PAGE && EXPERIMENTAL
>> +	default n
>> +	help
>> +	  Add HugeTLB management to memory resource controller. When you
>> +	  enable this, you can put a per cgroup limit on HugeTLB usage.
>
> How does it interact with the hard/soft limists etc...


There is no softlimit support for HugeTLB extension.

>
> [...]
>> diff --git a/mm/memcontrol.c b/mm/memcontrol.c
>> index 6728a7a..4b36c5e 100644
>> --- a/mm/memcontrol.c
>> +++ b/mm/memcontrol.c
>> @@ -235,6 +235,10 @@ struct mem_cgroup {
>>  	 */
>>  	struct res_counter memsw;
>>  	/*
>> +	 * the counter to account for hugepages from hugetlb.
>> +	 */
>> +	struct res_counter hugepage[HUGE_MAX_HSTATE];
>> +	/*
>>  	 * Per cgroup active and inactive list, similar to the
>>  	 * per zone LRU lists.
>>  	 */
>> @@ -3156,6 +3160,128 @@ static inline int mem_cgroup_move_swap_account(swp_entry_t entry,
>>  }
>>  #endif
>>  
>> +#ifdef CONFIG_MEM_RES_CTLR_HUGETLB
>> +static bool mem_cgroup_have_hugetlb_usage(struct mem_cgroup *memcg)
>> +{
>> +	int idx;
>> +	for (idx = 0; idx < hugetlb_max_hstate; idx++) {
>
> Maybe we should expose for_each_hstate as well...


That will not really help here. If we use for_each_hstate then we will
need to use hstate_index to get the index.

>
>> +		if (memcg->hugepage[idx].usage > 0)
>> +			return 1;
>> +	}
>> +	return 0;
>> +}
>> +
>> +int mem_cgroup_hugetlb_charge_page(int idx, unsigned long nr_pages,
>> +				   struct mem_cgroup **ptr)
>> +{
>> +	int ret = 0;
>> +	struct mem_cgroup *memcg;
>> +	struct res_counter *fail_res;
>> +	unsigned long csize = nr_pages * PAGE_SIZE;
>> +
>> +	if (mem_cgroup_disabled())
>> +		return 0;
>> +again:
>> +	rcu_read_lock();
>> +	memcg = mem_cgroup_from_task(current);
>> +	if (!memcg)
>> +		memcg = root_mem_cgroup;
>> +	if (mem_cgroup_is_root(memcg)) {
>> +		rcu_read_unlock();
>> +		goto done;
>> +	}
>> +	if (!css_tryget(&memcg->css)) {
>> +		rcu_read_unlock();
>> +		goto again;
>> +	}
>> +	rcu_read_unlock();
>> +
>> +	ret = res_counter_charge(&memcg->hugepage[idx], csize, &fail_res);
>> +	css_put(&memcg->css);
>> +done:
>> +	*ptr = memcg;
>
> Why do we set ptr even for the failure case after we dropped a
> reference?


That ensures that *ptr is NULL. 

>
>> +	return ret;
>> +}
>> +
>> +void mem_cgroup_hugetlb_commit_charge(int idx, unsigned long nr_pages,
>> +				      struct mem_cgroup *memcg,
>> +				      struct page *page)
>> +{
>> +	struct page_cgroup *pc;
>> +
>> +	if (mem_cgroup_disabled())
>> +		return;
>> +
>> +	pc = lookup_page_cgroup(page);
>> +	lock_page_cgroup(pc);
>> +	if (unlikely(PageCgroupUsed(pc))) {
>> +		unlock_page_cgroup(pc);
>> +		mem_cgroup_hugetlb_uncharge_memcg(idx, nr_pages, memcg);
>> +		return;
>> +	}
>> +	pc->mem_cgroup = memcg;
>> +	/*
>> +	 * We access a page_cgroup asynchronously without lock_page_cgroup().
>> +	 * Especially when a page_cgroup is taken from a page, pc->mem_cgroup
>> +	 * is accessed after testing USED bit. To make pc->mem_cgroup visible
>> +	 * before USED bit, we need memory barrier here.
>> +	 * See mem_cgroup_add_lru_list(), etc.
>> +	 */
>> +	smp_wmb();
>
> Is this really necessary for hugetlb pages as well?

I used to do that in cgroup_rmdir path, I later changed that part of the code. I
will look at the patches again to see if we really need this.


>
>> +	SetPageCgroupUsed(pc);
>> +
>> +	unlock_page_cgroup(pc);
>> +	return;
>> +}
>> +
> [...]
>> @@ -4887,6 +5013,7 @@ err_cleanup:
>>  static struct cgroup_subsys_state * __ref
>>  mem_cgroup_create(struct cgroup_subsys *ss, struct cgroup *cont)
>>  {
>> +	int idx;
>>  	struct mem_cgroup *memcg, *parent;
>>  	long error = -ENOMEM;
>>  	int node;
>> @@ -4929,9 +5056,14 @@ mem_cgroup_create(struct cgroup_subsys *ss, struct cgroup *cont)
>>  		 * mem_cgroup(see mem_cgroup_put).
>>  		 */
>>  		mem_cgroup_get(parent);
>> +		for (idx = 0; idx < HUGE_MAX_HSTATE; idx++)
>
> Do we have to init all hstates or is hugetlb_max_hstate enough?


Yes. we do call mem_cgroup_create for root cgroup before initialzing
hugetlb hstate.

>
>> +			res_counter_init(&memcg->hugepage[idx],
>> +					 &parent->hugepage[idx]);
>>  	} else {
>>  		res_counter_init(&memcg->res, NULL);
>>  		res_counter_init(&memcg->memsw, NULL);
>> +		for (idx = 0; idx < HUGE_MAX_HSTATE; idx++)
>> +			res_counter_init(&memcg->hugepage[idx], NULL);
>
> Same here
> -- 

-aneesh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
