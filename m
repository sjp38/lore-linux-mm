Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx136.postini.com [74.125.245.136])
	by kanga.kvack.org (Postfix) with SMTP id 643AC6B0081
	for <linux-mm@kvack.org>; Wed, 13 Jun 2012 07:04:38 -0400 (EDT)
Received: from m4.gw.fujitsu.co.jp (unknown [10.0.50.74])
	by fgwmail5.fujitsu.co.jp (Postfix) with ESMTP id 7B2F13EE0C3
	for <linux-mm@kvack.org>; Wed, 13 Jun 2012 20:04:36 +0900 (JST)
Received: from smail (m4 [127.0.0.1])
	by outgoing.m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 6177045DE51
	for <linux-mm@kvack.org>; Wed, 13 Jun 2012 20:04:36 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (s4.gw.fujitsu.co.jp [10.0.50.94])
	by m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 2AC2345DE4E
	for <linux-mm@kvack.org>; Wed, 13 Jun 2012 20:04:36 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id 0FE691DB803B
	for <linux-mm@kvack.org>; Wed, 13 Jun 2012 20:04:36 +0900 (JST)
Received: from m106.s.css.fujitsu.com (m106.s.css.fujitsu.com [10.240.81.146])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id BB1A81DB802F
	for <linux-mm@kvack.org>; Wed, 13 Jun 2012 20:04:35 +0900 (JST)
Message-ID: <4FD87332.8030805@jp.fujitsu.com>
Date: Wed, 13 Jun 2012 20:02:10 +0900
From: Kamezawa Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Subject: Re: [PATCH -V8 11/16] hugetlb/cgroup: Add charge/uncharge routines
 for hugetlb cgroup
References: <1339232401-14392-1-git-send-email-aneesh.kumar@linux.vnet.ibm.com> <1339232401-14392-12-git-send-email-aneesh.kumar@linux.vnet.ibm.com> <4FD6F8F9.2040901@jp.fujitsu.com> <87ipewold0.fsf@skywalker.in.ibm.com>
In-Reply-To: <87ipewold0.fsf@skywalker.in.ibm.com>
Content-Type: text/plain; charset=ISO-2022-JP
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
Cc: linux-mm@kvack.org, dhillf@gmail.com, rientjes@google.com, mhocko@suse.cz, akpm@linux-foundation.org, hannes@cmpxchg.org, linux-kernel@vger.kernel.org, cgroups@vger.kernel.org

(2012/06/12 19:50), Aneesh Kumar K.V wrote:
> Kamezawa Hiroyuki<kamezawa.hiroyu@jp.fujitsu.com>  writes:
> 
>> (2012/06/09 17:59), Aneesh Kumar K.V wrote:
>>> From: "Aneesh Kumar K.V"<aneesh.kumar@linux.vnet.ibm.com>
>>>
>>> This patchset add the charge and uncharge routines for hugetlb cgroup.
>>> This will be used in later patches when we allocate/free HugeTLB
>>> pages.
>>>
>>> Signed-off-by: Aneesh Kumar K.V<aneesh.kumar@linux.vnet.ibm.com>
>>
>>
>> I'm sorry if following has been already pointed out.
>>
>>> ---
>>>    mm/hugetlb_cgroup.c |   87 +++++++++++++++++++++++++++++++++++++++++++++++++++
>>>    1 file changed, 87 insertions(+)
>>>
>>> diff --git a/mm/hugetlb_cgroup.c b/mm/hugetlb_cgroup.c
>>> index 20a32c5..48efd5a 100644
>>> --- a/mm/hugetlb_cgroup.c
>>> +++ b/mm/hugetlb_cgroup.c
>>> @@ -105,6 +105,93 @@ static int hugetlb_cgroup_pre_destroy(struct cgroup *cgroup)
>>>    	   return -EBUSY;
>>>    }
>>>
>>> +int hugetlb_cgroup_charge_page(int idx, unsigned long nr_pages,
>>> +			       struct hugetlb_cgroup **ptr)
>>> +{
>>> +	int ret = 0;
>>> +	struct res_counter *fail_res;
>>> +	struct hugetlb_cgroup *h_cg = NULL;
>>> +	unsigned long csize = nr_pages * PAGE_SIZE;
>>> +
>>> +	if (hugetlb_cgroup_disabled())
>>> +		goto done;
>>> +	/*
>>> +	 * We don't charge any cgroup if the compound page have less
>>> +	 * than 3 pages.
>>> +	 */
>>> +	if (hstates[idx].order<   2)
>>> +		goto done;
>>> +again:
>>> +	rcu_read_lock();
>>> +	h_cg = hugetlb_cgroup_from_task(current);
>>> +	if (!h_cg)
>>> +		h_cg = root_h_cgroup;
>>> +
>>> +	if (!css_tryget(&h_cg->css)) {
>>> +		rcu_read_unlock();
>>> +		goto again;
>>> +	}
>>> +	rcu_read_unlock();
>>> +
>>> +	ret = res_counter_charge(&h_cg->hugepage[idx], csize,&fail_res);
>>> +	css_put(&h_cg->css);
>>> +done:
>>> +	*ptr = h_cg;
>>> +	return ret;
>>> +}
>>> +
>>
>> Memory cgroup uses very complicated 'charge' routine for handling pageout...
>> which gets sleep.
>>
>> For hugetlbfs, it has not sleep routine, you can do charge in simple way.
>> I guess...get/put here is overkill.
>>
>> For example, h_cg cannot be freed while it has tasks. So, if 'current' is
>> belongs to the cgroup, it cannot be disappear. Then, you don't need get/put,
>> additional atomic ops for holding cgroup.
>>
>> 	rcu_read_lock();
>> 	h_cg = hugetlb_cgroup_from_task(current);
>> 	ret = res_counter_charge(&h_cg->hugetpage[idx], csize,&fail_res);
>> 	rcu_read_unlock();
>>
>> 	return ret;
>>
> 
> What if the task got moved ot of the cgroup and cgroup got deleted by an
> rmdir ?
> 

I think 
 - yes, the task, 'current', can be moved off from the cgroup.
 - rcu_read_lock() prevents ->destroy() cgroup.

Then, the concern is that the cgroup may have resource usage even after
->pre_destroy() is called. We don't have any serialization between
charging <-> task_move <-> rmdir().

How about taking
	write_lock(&mm->mmap_sem)
	write_unlock(&mm->mmap_sem)

at moving task (->attach()) ? This will serialize task-move and charging
without any realistic performance impact. If tasks cannot move, rmdir
never happens.

Maybe you can do this later as an optimization. So, please take this as
an suggestion.

Thanks,
-Kame

















--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
