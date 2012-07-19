Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx151.postini.com [74.125.245.151])
	by kanga.kvack.org (Postfix) with SMTP id 27B5F6B005C
	for <linux-mm@kvack.org>; Thu, 19 Jul 2012 05:42:30 -0400 (EDT)
Received: from /spool/local
	by e28smtp03.in.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <aneesh.kumar@linux.vnet.ibm.com>;
	Thu, 19 Jul 2012 15:12:25 +0530
Received: from d28av01.in.ibm.com (d28av01.in.ibm.com [9.184.220.63])
	by d28relay01.in.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id q6J9fipJ1179954
	for <linux-mm@kvack.org>; Thu, 19 Jul 2012 15:11:44 +0530
Received: from d28av01.in.ibm.com (loopback [127.0.0.1])
	by d28av01.in.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id q6JFBHOs001737
	for <linux-mm@kvack.org>; Thu, 19 Jul 2012 20:41:18 +0530
From: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
Subject: Re: [PATCH] hugetlb/cgroup: Simplify pre_destroy callback
In-Reply-To: <5007B034.4030909@huawei.com>
References: <1342589649-15066-1-git-send-email-aneesh.kumar@linux.vnet.ibm.com> <20120718142628.76bf78b3.akpm@linux-foundation.org> <87hat4794l.fsf@skywalker.in.ibm.com> <5007B034.4030909@huawei.com>
Date: Thu, 19 Jul 2012 15:11:44 +0530
Message-ID: <87wr20f5pj.fsf@skywalker.in.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Li Zefan <lizefan@huawei.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, kamezawa.hiroyu@jp.fujitsu.com, mhocko@suse.cz, linux-kernel@vger.kernel.org

Li Zefan <lizefan@huawei.com> writes:

> on 2012/7/19 10:55, Aneesh Kumar K.V wrote:
>
>> Andrew Morton <akpm@linux-foundation.org> writes:
>> 
>>> On Wed, 18 Jul 2012 11:04:09 +0530
>>> "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com> wrote:
>>>
>>>> From: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
>>>>
>>>> Since we cannot fail in hugetlb_cgroup_move_parent, we don't really
>>>> need to check whether cgroup have any change left after that. Also skip
>>>> those hstates for which we don't have any charge in this cgroup.
>>>>
>>>> ...
>>>>
>>>> +	for_each_hstate(h) {
>>>> +		/*
>>>> +		 * if we don't have any charge, skip this hstate
>>>> +		 */
>>>> +		idx = hstate_index(h);
>>>> +		if (res_counter_read_u64(&h_cg->hugepage[idx], RES_USAGE) == 0)
>>>> +			continue;
>>>> +		spin_lock(&hugetlb_lock);
>>>> +		list_for_each_entry(page, &h->hugepage_activelist, lru)
>>>> +			hugetlb_cgroup_move_parent(idx, cgroup, page);
>>>> +		spin_unlock(&hugetlb_lock);
>>>> +		VM_BUG_ON(res_counter_read_u64(&h_cg->hugepage[idx], RES_USAGE));
>>>> +	}
>>>>  out:
>>>>  	return ret;
>>>>  }
>>>
>>> This looks fishy.
>>>
>>> We test RES_USAGE before taking hugetlb_lock.  What prevents some other
>>> thread from increasing RES_USAGE after that test?
>>>
>>> After walking the list we test RES_USAGE after dropping hugetlb_lock. 
>>> What prevents another thread from incrementing RES_USAGE before that
>>> test, triggering the BUG?
>> 
>> IIUC core cgroup will prevent a new task getting added to the cgroup
>> when we are in pre_destroy. Since we already check that the cgroup doesn't
>> have any task, the RES_USAGE cannot increase in pre_destroy.
>> 
>
>
> You're wrong here. We release cgroup_lock before calling pre_destroy and retrieve
> the lock after that, so a task can be attached to the cgroup in this interval.
>

But that means rmdir can be racy right ? What happens if the task got
added, allocated few pages and then moved out ? We still would have task
count 0 but few pages, which we missed to to move to parent cgroup. 

-aneesh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
