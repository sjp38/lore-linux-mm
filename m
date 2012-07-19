Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx124.postini.com [74.125.245.124])
	by kanga.kvack.org (Postfix) with SMTP id 186506B0069
	for <linux-mm@kvack.org>; Thu, 19 Jul 2012 06:27:50 -0400 (EDT)
Received: from m3.gw.fujitsu.co.jp (unknown [10.0.50.73])
	by fgwmail6.fujitsu.co.jp (Postfix) with ESMTP id A10B03EE0B6
	for <linux-mm@kvack.org>; Thu, 19 Jul 2012 19:27:48 +0900 (JST)
Received: from smail (m3 [127.0.0.1])
	by outgoing.m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 8791D45DEB6
	for <linux-mm@kvack.org>; Thu, 19 Jul 2012 19:27:48 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (s3.gw.fujitsu.co.jp [10.0.50.93])
	by m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 6718A45DEB4
	for <linux-mm@kvack.org>; Thu, 19 Jul 2012 19:27:48 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 584921DB8040
	for <linux-mm@kvack.org>; Thu, 19 Jul 2012 19:27:48 +0900 (JST)
Received: from m1000.s.css.fujitsu.com (m1000.s.css.fujitsu.com [10.240.81.136])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 08D561DB803B
	for <linux-mm@kvack.org>; Thu, 19 Jul 2012 19:27:48 +0900 (JST)
Message-ID: <5007E0A2.70906@jp.fujitsu.com>
Date: Thu, 19 Jul 2012 19:25:38 +0900
From: Kamezawa Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Subject: Re: [PATCH] hugetlb/cgroup: Simplify pre_destroy callback
References: <1342589649-15066-1-git-send-email-aneesh.kumar@linux.vnet.ibm.com> <20120718142628.76bf78b3.akpm@linux-foundation.org> <87hat4794l.fsf@skywalker.in.ibm.com> <5007B034.4030909@huawei.com> <87wr20f5pj.fsf@skywalker.in.ibm.com>
In-Reply-To: <87wr20f5pj.fsf@skywalker.in.ibm.com>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
Cc: Li Zefan <lizefan@huawei.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, mhocko@suse.cz, linux-kernel@vger.kernel.org

(2012/07/19 18:41), Aneesh Kumar K.V wrote:
> Li Zefan <lizefan@huawei.com> writes:
>
>> on 2012/7/19 10:55, Aneesh Kumar K.V wrote:
>>
>>> Andrew Morton <akpm@linux-foundation.org> writes:
>>>
>>>> On Wed, 18 Jul 2012 11:04:09 +0530
>>>> "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com> wrote:
>>>>
>>>>> From: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
>>>>>
>>>>> Since we cannot fail in hugetlb_cgroup_move_parent, we don't really
>>>>> need to check whether cgroup have any change left after that. Also skip
>>>>> those hstates for which we don't have any charge in this cgroup.
>>>>>
>>>>> ...
>>>>>
>>>>> +	for_each_hstate(h) {
>>>>> +		/*
>>>>> +		 * if we don't have any charge, skip this hstate
>>>>> +		 */
>>>>> +		idx = hstate_index(h);
>>>>> +		if (res_counter_read_u64(&h_cg->hugepage[idx], RES_USAGE) == 0)
>>>>> +			continue;
>>>>> +		spin_lock(&hugetlb_lock);
>>>>> +		list_for_each_entry(page, &h->hugepage_activelist, lru)
>>>>> +			hugetlb_cgroup_move_parent(idx, cgroup, page);
>>>>> +		spin_unlock(&hugetlb_lock);
>>>>> +		VM_BUG_ON(res_counter_read_u64(&h_cg->hugepage[idx], RES_USAGE));
>>>>> +	}
>>>>>   out:
>>>>>   	return ret;
>>>>>   }
>>>>
>>>> This looks fishy.
>>>>
>>>> We test RES_USAGE before taking hugetlb_lock.  What prevents some other
>>>> thread from increasing RES_USAGE after that test?
>>>>
>>>> After walking the list we test RES_USAGE after dropping hugetlb_lock.
>>>> What prevents another thread from incrementing RES_USAGE before that
>>>> test, triggering the BUG?
>>>
>>> IIUC core cgroup will prevent a new task getting added to the cgroup
>>> when we are in pre_destroy. Since we already check that the cgroup doesn't
>>> have any task, the RES_USAGE cannot increase in pre_destroy.
>>>
>>
>>
>> You're wrong here. We release cgroup_lock before calling pre_destroy and retrieve
>> the lock after that, so a task can be attached to the cgroup in this interval.
>>
>
> But that means rmdir can be racy right ? What happens if the task got
> added, allocated few pages and then moved out ? We still would have task
> count 0 but few pages, which we missed to to move to parent cgroup.
>

That's a problem even if it's verrrry unlikely.
I'd like to look into it and fix the race in cgroup layer.
But I'm sorry I'm a bit busy in these days...

Thanks,
-Kame


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
