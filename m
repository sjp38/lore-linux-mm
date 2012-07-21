Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx151.postini.com [74.125.245.151])
	by kanga.kvack.org (Postfix) with SMTP id 554A96B005D
	for <linux-mm@kvack.org>; Sat, 21 Jul 2012 00:07:34 -0400 (EDT)
Received: from m1.gw.fujitsu.co.jp (unknown [10.0.50.71])
	by fgwmail6.fujitsu.co.jp (Postfix) with ESMTP id 54B343EE0BC
	for <linux-mm@kvack.org>; Sat, 21 Jul 2012 13:07:32 +0900 (JST)
Received: from smail (m1 [127.0.0.1])
	by outgoing.m1.gw.fujitsu.co.jp (Postfix) with ESMTP id 3B89445DE59
	for <linux-mm@kvack.org>; Sat, 21 Jul 2012 13:07:32 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (s1.gw.fujitsu.co.jp [10.0.50.91])
	by m1.gw.fujitsu.co.jp (Postfix) with ESMTP id 18F6145DE56
	for <linux-mm@kvack.org>; Sat, 21 Jul 2012 13:07:32 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id 0BB321DB8052
	for <linux-mm@kvack.org>; Sat, 21 Jul 2012 13:07:32 +0900 (JST)
Received: from m1000.s.css.fujitsu.com (m1000.s.css.fujitsu.com [10.240.81.136])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id B4F0B1DB804B
	for <linux-mm@kvack.org>; Sat, 21 Jul 2012 13:07:31 +0900 (JST)
Message-ID: <500A2A79.5030705@jp.fujitsu.com>
Date: Sat, 21 Jul 2012 13:05:13 +0900
From: Kamezawa Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Subject: Re: + hugetlb-cgroup-simplify-pre_destroy-callback.patch added to
 -mm tree
References: <20120718212637.133475C0050@hpza9.eem.corp.google.com> <20120719113915.GC2864@tiehlicka.suse.cz> <87r4s8gcwe.fsf@skywalker.in.ibm.com> <20120719123820.GG2864@tiehlicka.suse.cz> <87ipdjc15j.fsf@skywalker.in.ibm.com> <20120720080639.GC12434@tiehlicka.suse.cz> <87d33qmeb9.fsf@skywalker.in.ibm.com> <20120720195643.GC21218@google.com> <500A107D.9060404@jp.fujitsu.com> <20120721024657.GA7962@dhcp-172-17-108-109.mtv.corp.google.com>
In-Reply-To: <20120721024657.GA7962@dhcp-172-17-108-109.mtv.corp.google.com>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tejun Heo <htejun@gmail.com>
Cc: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, Michal Hocko <mhocko@suse.cz>, akpm@linux-foundation.org, mm-commits@vger.kernel.org, liwanp@linux.vnet.ibm.com, Li Zefan <lizefan@huawei.com>, cgroups mailinglist <cgroups@vger.kernel.org>, linux-mm@kvack.org

(2012/07/21 11:46), Tejun Heo wrote:
> Hello, Kamezawa-san.
>
> On Sat, Jul 21, 2012 at 11:14:21AM +0900, Kamezawa Hiroyuki wrote:
>> I'm sorry I misunderstand. The problem is following.
>>
>>          CPU A                       CPU B
>>      mutex_unlock()
>>                                  mutex_lock()
>>      ->pre_destroy()             attach task
>>        commit res->usage=0       mutex_unlock()
>>                                  increase res->usage
>>                                  detach task
>>      mutex_lock()
>>      check css's refcount=0
>>       ....continue destroy.
>>
>> Now, I thinks memcg's check is not enough but putting the -EBUSY there
>> not to forget this race.
>>
>>
>> I think a patch to stop task-attach and create child cgroup if  CGRP_WAIT_ON_RMDIR
>> is set is required. And that's enough..
>
> The *ONLY* reason we're not marking the cgroup dead after the checking
> whether the cgroup has children or task at the top of cgroup_rmdir()
> is because memcg might fail ->pre_destroy() and cancel the cgroup
> removal.  We can't commit to removal because memcg might fail.
>
> Now, if memcg drops the deprecated behavior, we can simply commit to
> removal *before* starting calling pre_destroy() and it doesn't matter
> at all whether we hold cgroup_mutex across pre_destroy or not and
> cgroup core will simply deny any addition to the cgroup committed to
> death.  (and remove a handsome amount of ugly code in the process)
>
> So, the *ONLY* reason this can't be fixed properly from cgroup core is
> because memcg's pre_destory() might fail and it doesn't make much
> sense to me to implement add a workaround at this point when the whole
> problem will go away once memcg's pre_destroy() is updated.
>
> So, please update memcg and drop the __DEPRECATED flag, so that the
> cgroup core can drop at least this particular part of misdesign. :(
>

Maybe it's better to remove memcg's pre_destroy() at all and do the job
in asynchronus thread called by ->destroy().

I'll cook a patch again.

-Kame


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
