Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx200.postini.com [74.125.245.200])
	by kanga.kvack.org (Postfix) with SMTP id 48B876B0083
	for <linux-mm@kvack.org>; Thu, 19 Jul 2012 08:21:22 -0400 (EDT)
Received: from /spool/local
	by e23smtp03.au.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <aneesh.kumar@linux.vnet.ibm.com>;
	Thu, 19 Jul 2012 12:09:39 +1000
Received: from d23av01.au.ibm.com (d23av01.au.ibm.com [9.190.234.96])
	by d23relay05.au.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id q6JCD0BT7340302
	for <linux-mm@kvack.org>; Thu, 19 Jul 2012 22:13:03 +1000
Received: from d23av01.au.ibm.com (loopback [127.0.0.1])
	by d23av01.au.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id q6JCLAIj006523
	for <linux-mm@kvack.org>; Thu, 19 Jul 2012 22:21:11 +1000
From: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
Subject: Re: + hugetlb-cgroup-simplify-pre_destroy-callback.patch added to -mm tree
In-Reply-To: <20120719113915.GC2864@tiehlicka.suse.cz>
References: <20120718212637.133475C0050@hpza9.eem.corp.google.com> <20120719113915.GC2864@tiehlicka.suse.cz>
Date: Thu, 19 Jul 2012 17:51:05 +0530
Message-ID: <87r4s8gcwe.fsf@skywalker.in.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>, akpm@linux-foundation.org
Cc: mm-commits@vger.kernel.org, kamezawa.hiroyu@jp.fujitsu.com, liwanp@linux.vnet.ibm.com, Tejun Heo <htejun@gmail.com>, Li Zefan <lizefan@huawei.com>, cgroups mailinglist <cgroups@vger.kernel.org>, linux-mm@kvack.org

Michal Hocko <mhocko@suse.cz> writes:

> On Wed 18-07-12 14:26:36, Andrew Morton wrote:
>> 
>> The patch titled
>>      Subject: hugetlb/cgroup: simplify pre_destroy callback
>> has been added to the -mm tree.  Its filename is
>>      hugetlb-cgroup-simplify-pre_destroy-callback.patch
>> 
>> Before you just go and hit "reply", please:
>>    a) Consider who else should be cc'ed
>>    b) Prefer to cc a suitable mailing list as well
>>    c) Ideally: find the original patch on the mailing list and do a
>>       reply-to-all to that, adding suitable additional cc's
>> 
>> *** Remember to use Documentation/SubmitChecklist when testing your code ***
>> 
>> The -mm tree is included into linux-next and is updated
>> there every 3-4 working days
>> 
>> ------------------------------------------------------
>> From: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
>> Subject: hugetlb/cgroup: simplify pre_destroy callback
>> 
>> Since we cannot fail in hugetlb_cgroup_move_parent(), we don't really need
>> to check whether cgroup have any change left after that.  Also skip those
>> hstates for which we don't have any charge in this cgroup.
>
> IIUC this depends on a non-existent (cgroup) patch. I guess something
> like the patch at the end should address it. I haven't tested it though
> so it is not signed-off-by yet.
>
>> Based on an earlier patch from Wanpeng Li.
>> 
>> Signed-off-by: Aneesh Kumar K.V <aneesh.kumar@linux.vnet.ibm.com>
>> Signed-off-by: Wanpeng Li <liwanp@linux.vnet.ibm.com>
>> Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
>> Cc: Michal Hocko <mhocko@suse.cz>
>> Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
>> ---
>> 
>>  mm/hugetlb_cgroup.c |   49 ++++++++++++++++++------------------------
>>  1 file changed, 21 insertions(+), 28 deletions(-)
>> 
>> diff -puN mm/hugetlb_cgroup.c~hugetlb-cgroup-simplify-pre_destroy-callback mm/hugetlb_cgroup.c
>> --- a/mm/hugetlb_cgroup.c~hugetlb-cgroup-simplify-pre_destroy-callback
>> +++ a/mm/hugetlb_cgroup.c
>> @@ -65,18 +65,6 @@ static inline struct hugetlb_cgroup *par
>>  	return hugetlb_cgroup_from_cgroup(cg->parent);
>>  }
>>  
>> -static inline bool hugetlb_cgroup_have_usage(struct cgroup *cg)
>> -{
>> -	int idx;
>> -	struct hugetlb_cgroup *h_cg = hugetlb_cgroup_from_cgroup(cg);
>> -
>> -	for (idx = 0; idx < hugetlb_max_hstate; idx++) {
>> -		if ((res_counter_read_u64(&h_cg->hugepage[idx], RES_USAGE)) > 0)
>> -			return true;
>> -	}
>> -	return false;
>> -}
>> -
>>  static struct cgroup_subsys_state *hugetlb_cgroup_create(struct cgroup *cgroup)
>>  {
>>  	int idx;
>> @@ -159,24 +147,29 @@ static int hugetlb_cgroup_pre_destroy(st
>>  {
>>  	struct hstate *h;
>>  	struct page *page;
>> -	int ret = 0, idx = 0;
>> +	int ret = 0, idx;
>> +	struct hugetlb_cgroup *h_cg = hugetlb_cgroup_from_cgroup(cgroup);
>>  
>> -	do {
>> -		if (cgroup_task_count(cgroup) ||
>> -		    !list_empty(&cgroup->children)) {
>> -			ret = -EBUSY;
>> -			goto out;
>> -		}
>> -		for_each_hstate(h) {
>> -			spin_lock(&hugetlb_lock);
>> -			list_for_each_entry(page, &h->hugepage_activelist, lru)
>> -				hugetlb_cgroup_move_parent(idx, cgroup, page);
>>  
>> -			spin_unlock(&hugetlb_lock);
>> -			idx++;
>> -		}
>> -		cond_resched();
>> -	} while (hugetlb_cgroup_have_usage(cgroup));
>> +	if (cgroup_task_count(cgroup) ||
>> +	    !list_empty(&cgroup->children)) {
>> +		ret = -EBUSY;
>> +		goto out;
>> +	}
>> +
>> +	for_each_hstate(h) {
>> +		/*
>> +		 * if we don't have any charge, skip this hstate
>> +		 */
>> +		idx = hstate_index(h);
>> +		if (res_counter_read_u64(&h_cg->hugepage[idx], RES_USAGE) == 0)
>> +			continue;
>> +		spin_lock(&hugetlb_lock);
>> +		list_for_each_entry(page, &h->hugepage_activelist, lru)
>> +			hugetlb_cgroup_move_parent(idx, cgroup, page);
>> +		spin_unlock(&hugetlb_lock);
>> +		VM_BUG_ON(res_counter_read_u64(&h_cg->hugepage[idx], RES_USAGE));
>> +	}
>>  out:
>>  	return ret;
>>  }
>> _
>
> ---
> From 621ed1c9dab63bd82205bd5266eb9974f86a0a3f Mon Sep 17 00:00:00 2001
> From: Michal Hocko <mhocko@suse.cz>
> Date: Thu, 19 Jul 2012 13:23:23 +0200
> Subject: [PATCH] cgroup: keep cgroup_mutex locked for pre_destroy
>
> 3fa59dfb (cgroup: fix potential deadlock in pre_destroy) dropped the
> cgroup_mutex lock while calling pre_destroy callbacks because memory
> controller could deadlock because force_empty triggered reclaim.
> Since "memcg: move charges to root cgroup if use_hierarchy=0" there is
> no reclaim going on from mem_cgroup_force_empty though so we can safely
> keep the cgroup_mutex locked. This has an advantage that no tasks might
> be added during pre_destroy callback and so the handlers don't have to
> consider races when new tasks add new charges. This simplifies the
> implementation.
> ---
>  kernel/cgroup.c |    2 --
>  1 file changed, 2 deletions(-)
>
> diff --git a/kernel/cgroup.c b/kernel/cgroup.c
> index 0f3527d..9dba05d 100644
> --- a/kernel/cgroup.c
> +++ b/kernel/cgroup.c
> @@ -4181,7 +4181,6 @@ again:
>  		mutex_unlock(&cgroup_mutex);
>  		return -EBUSY;
>  	}
> -	mutex_unlock(&cgroup_mutex);
>
>  	/*
>  	 * In general, subsystem has no css->refcnt after pre_destroy(). But
> @@ -4204,7 +4203,6 @@ again:
>  		return ret;
>  	}
>
> -	mutex_lock(&cgroup_mutex);
>  	parent = cgrp->parent;
>  	if (atomic_read(&cgrp->count) || !list_empty(&cgrp->children)) {
>  		clear_bit(CGRP_WAIT_ON_RMDIR, &cgrp->flags);

mem_cgroup_force_empty still calls 

lru_add_drain_all 
   ->schedule_on_each_cpu
        -> get_online_cpus
           ->mutex_lock(&cpu_hotplug.lock);

So wont we deadlock ?

-aneesh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
