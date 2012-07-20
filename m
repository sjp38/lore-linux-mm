Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx108.postini.com [74.125.245.108])
	by kanga.kvack.org (Postfix) with SMTP id 52C246B004D
	for <linux-mm@kvack.org>; Thu, 19 Jul 2012 21:22:53 -0400 (EDT)
Received: from m4.gw.fujitsu.co.jp (unknown [10.0.50.74])
	by fgwmail5.fujitsu.co.jp (Postfix) with ESMTP id D48133EE081
	for <linux-mm@kvack.org>; Fri, 20 Jul 2012 10:22:51 +0900 (JST)
Received: from smail (m4 [127.0.0.1])
	by outgoing.m4.gw.fujitsu.co.jp (Postfix) with ESMTP id B8D3745DE52
	for <linux-mm@kvack.org>; Fri, 20 Jul 2012 10:22:51 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (s4.gw.fujitsu.co.jp [10.0.50.94])
	by m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 9732345DE51
	for <linux-mm@kvack.org>; Fri, 20 Jul 2012 10:22:51 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id 87AE0E08008
	for <linux-mm@kvack.org>; Fri, 20 Jul 2012 10:22:51 +0900 (JST)
Received: from m1000.s.css.fujitsu.com (m1000.s.css.fujitsu.com [10.240.81.136])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id 2E794E08001
	for <linux-mm@kvack.org>; Fri, 20 Jul 2012 10:22:51 +0900 (JST)
Message-ID: <5008B25D.5000902@jp.fujitsu.com>
Date: Fri, 20 Jul 2012 10:20:29 +0900
From: Kamezawa Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Subject: Re: + hugetlb-cgroup-simplify-pre_destroy-callback.patch added to
 -mm tree
References: <20120718212637.133475C0050@hpza9.eem.corp.google.com> <20120719113915.GC2864@tiehlicka.suse.cz> <87r4s8gcwe.fsf@skywalker.in.ibm.com> <20120719123820.GG2864@tiehlicka.suse.cz> <87ipdjc15j.fsf@skywalker.in.ibm.com> <5008AEC2.9090707@jp.fujitsu.com>
In-Reply-To: <5008AEC2.9090707@jp.fujitsu.com>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
Cc: Michal Hocko <mhocko@suse.cz>, akpm@linux-foundation.org, mm-commits@vger.kernel.org, liwanp@linux.vnet.ibm.com, Tejun Heo <htejun@gmail.com>, Li Zefan <lizefan@huawei.com>, cgroups mailinglist <cgroups@vger.kernel.org>, linux-mm@kvack.org

(2012/07/20 10:05), Kamezawa Hiroyuki wrote:
> (2012/07/19 22:48), Aneesh Kumar K.V wrote:
>> Michal Hocko <mhocko@suse.cz> writes:
>>
>>> On Thu 19-07-12 17:51:05, Aneesh Kumar K.V wrote:
>>>> Michal Hocko <mhocko@suse.cz> writes:
>>>>
>>>>>  From 621ed1c9dab63bd82205bd5266eb9974f86a0a3f Mon Sep 17 00:00:00 2001
>>>>> From: Michal Hocko <mhocko@suse.cz>
>>>>> Date: Thu, 19 Jul 2012 13:23:23 +0200
>>>>> Subject: [PATCH] cgroup: keep cgroup_mutex locked for pre_destroy
>>>>>
>>>>> 3fa59dfb (cgroup: fix potential deadlock in pre_destroy) dropped the
>>>>> cgroup_mutex lock while calling pre_destroy callbacks because memory
>>>>> controller could deadlock because force_empty triggered reclaim.
>>>>> Since "memcg: move charges to root cgroup if use_hierarchy=0" there is
>>>>> no reclaim going on from mem_cgroup_force_empty though so we can safely
>>>>> keep the cgroup_mutex locked. This has an advantage that no tasks might
>>>>> be added during pre_destroy callback and so the handlers don't have to
>>>>> consider races when new tasks add new charges. This simplifies the
>>>>> implementation.
>>>>> ---
>>>>>   kernel/cgroup.c |    2 --
>>>>>   1 file changed, 2 deletions(-)
>>>>>
>>>>> diff --git a/kernel/cgroup.c b/kernel/cgroup.c
>>>>> index 0f3527d..9dba05d 100644
>>>>> --- a/kernel/cgroup.c
>>>>> +++ b/kernel/cgroup.c
>>>>> @@ -4181,7 +4181,6 @@ again:
>>>>>           mutex_unlock(&cgroup_mutex);
>>>>>           return -EBUSY;
>>>>>       }
>>>>> -    mutex_unlock(&cgroup_mutex);
>>>>>
>>>>>       /*
>>>>>        * In general, subsystem has no css->refcnt after pre_destroy(). But
>>>>> @@ -4204,7 +4203,6 @@ again:
>>>>>           return ret;
>>>>>       }
>>>>>
>>>>> -    mutex_lock(&cgroup_mutex);
>>>>>       parent = cgrp->parent;
>>>>>       if (atomic_read(&cgrp->count) || !list_empty(&cgrp->children)) {
>>>>>           clear_bit(CGRP_WAIT_ON_RMDIR, &cgrp->flags);
>>>>
>>>> mem_cgroup_force_empty still calls
>>>>
>>>> lru_add_drain_all
>>>>     ->schedule_on_each_cpu
>>>>          -> get_online_cpus
>>>>             ->mutex_lock(&cpu_hotplug.lock);
>>>>
>>>> So wont we deadlock ?
>>>
>>> Yes you are right. I got it wrong. I thought that the reclaim is the
>>> main problem. It won't be that easy then and the origin mm patch
>>> (hugetlb-cgroup-simplify-pre_destroy-callback.patch) still needs a fix
>>> or to be dropped.
>>
>
> Aha, then the problematic schedule_on_each_cpu(), Andrew pointed out in this month,
> is in front of us :( ...and drain_all_stock_sync() should be fixed too.
> Hmm...
>
>> We just need to remove the VM_BUG_ON() right ? The rest of the patch is
>> good right ? Otherwise how about the below
>>
>
> I'm personally okay but....ugly ?
>

Hmm, can't cgroup_lock() be implemented as


void cgroup_lock()
{
	get_online_cpus()
	lock_memory_hotplug()
	mutex_lock(&cgroup_mutex);
}


?

Thanks,
-Kame




--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
