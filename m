Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx176.postini.com [74.125.245.176])
	by kanga.kvack.org (Postfix) with SMTP id 0270B6B0075
	for <linux-mm@kvack.org>; Thu, 19 Jul 2012 07:26:28 -0400 (EDT)
Received: from /spool/local
	by e28smtp03.in.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <aneesh.kumar@linux.vnet.ibm.com>;
	Thu, 19 Jul 2012 16:56:23 +0530
Received: from d28av03.in.ibm.com (d28av03.in.ibm.com [9.184.220.65])
	by d28relay04.in.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id q6JBQKJI50528344
	for <linux-mm@kvack.org>; Thu, 19 Jul 2012 16:56:20 +0530
Received: from d28av03.in.ibm.com (loopback [127.0.0.1])
	by d28av03.in.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id q6JGtdbH024062
	for <linux-mm@kvack.org>; Fri, 20 Jul 2012 02:55:39 +1000
From: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
Subject: Re: [PATCH] hugetlb/cgroup: Simplify pre_destroy callback
In-Reply-To: <5007E0A2.70906@jp.fujitsu.com>
References: <1342589649-15066-1-git-send-email-aneesh.kumar@linux.vnet.ibm.com> <20120718142628.76bf78b3.akpm@linux-foundation.org> <87hat4794l.fsf@skywalker.in.ibm.com> <5007B034.4030909@huawei.com> <87wr20f5pj.fsf@skywalker.in.ibm.com> <5007E0A2.70906@jp.fujitsu.com>
Date: Thu, 19 Jul 2012 16:56:18 +0530
Message-ID: <87r4s8f0v9.fsf@skywalker.in.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Kamezawa Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Li Zefan <lizefan@huawei.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, mhocko@suse.cz, linux-kernel@vger.kernel.org

Kamezawa Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> writes:

>>>>>
>>>>> We test RES_USAGE before taking hugetlb_lock.  What prevents some other
>>>>> thread from increasing RES_USAGE after that test?
>>>>>
>>>>> After walking the list we test RES_USAGE after dropping hugetlb_lock.
>>>>> What prevents another thread from incrementing RES_USAGE before that
>>>>> test, triggering the BUG?
>>>>
>>>> IIUC core cgroup will prevent a new task getting added to the cgroup
>>>> when we are in pre_destroy. Since we already check that the cgroup doesn't
>>>> have any task, the RES_USAGE cannot increase in pre_destroy.
>>>>
>>>
>>>
>>> You're wrong here. We release cgroup_lock before calling pre_destroy and retrieve
>>> the lock after that, so a task can be attached to the cgroup in this interval.
>>>
>>
>> But that means rmdir can be racy right ? What happens if the task got
>> added, allocated few pages and then moved out ? We still would have task
>> count 0 but few pages, which we missed to to move to parent cgroup.
>>
>
> That's a problem even if it's verrrry unlikely.
> I'd like to look into it and fix the race in cgroup layer.
> But I'm sorry I'm a bit busy in these days...
>

How about moving that mutex_unlock(&cgroup_mutex) to memcg callback ? That
can be a patch for 3.5 ? 

-aneesh
 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
