Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx113.postini.com [74.125.245.113])
	by kanga.kvack.org (Postfix) with SMTP id C14BA6B004D
	for <linux-mm@kvack.org>; Fri, 20 Jul 2012 15:18:49 -0400 (EDT)
Received: from /spool/local
	by e28smtp07.in.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <aneesh.kumar@linux.vnet.ibm.com>;
	Sat, 21 Jul 2012 00:48:44 +0530
Received: from d28av03.in.ibm.com (d28av03.in.ibm.com [9.184.220.65])
	by d28relay01.in.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id q6KJIelh63766720
	for <linux-mm@kvack.org>; Sat, 21 Jul 2012 00:48:42 +0530
Received: from d28av03.in.ibm.com (loopback [127.0.0.1])
	by d28av03.in.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id q6L0lwYU029602
	for <linux-mm@kvack.org>; Sat, 21 Jul 2012 10:47:59 +1000
From: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
Subject: Re: + hugetlb-cgroup-simplify-pre_destroy-callback.patch added to -mm tree
In-Reply-To: <20120720080639.GC12434@tiehlicka.suse.cz>
References: <20120718212637.133475C0050@hpza9.eem.corp.google.com> <20120719113915.GC2864@tiehlicka.suse.cz> <87r4s8gcwe.fsf@skywalker.in.ibm.com> <20120719123820.GG2864@tiehlicka.suse.cz> <87ipdjc15j.fsf@skywalker.in.ibm.com> <20120720080639.GC12434@tiehlicka.suse.cz>
Date: Sat, 21 Jul 2012 00:48:34 +0530
Message-ID: <87d33qmeb9.fsf@skywalker.in.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>
Cc: akpm@linux-foundation.org, mm-commits@vger.kernel.org, kamezawa.hiroyu@jp.fujitsu.com, liwanp@linux.vnet.ibm.com, Tejun Heo <htejun@gmail.com>, Li Zefan <lizefan@huawei.com>, cgroups mailinglist <cgroups@vger.kernel.org>, linux-mm@kvack.org

Michal Hocko <mhocko@suse.cz> writes:

> On Thu 19-07-12 19:18:24, Aneesh Kumar K.V wrote:
>> Michal Hocko <mhocko@suse.cz> writes:
>> 
>> > On Thu 19-07-12 17:51:05, Aneesh Kumar K.V wrote:
>> >> Michal Hocko <mhocko@suse.cz> writes:
>> >> 
>> >> > From 621ed1c9dab63bd82205bd5266eb9974f86a0a3f Mon Sep 17 00:00:00 2001
>> >> > From: Michal Hocko <mhocko@suse.cz>
>> >> > Date: Thu, 19 Jul 2012 13:23:23 +0200
>> >> > Subject: [PATCH] cgroup: keep cgroup_mutex locked for pre_destroy
>> >> >
>> >> > 3fa59dfb (cgroup: fix potential deadlock in pre_destroy) dropped the
>> >> > cgroup_mutex lock while calling pre_destroy callbacks because memory
>> >> > controller could deadlock because force_empty triggered reclaim.
>> >> > Since "memcg: move charges to root cgroup if use_hierarchy=0" there is
>> >> > no reclaim going on from mem_cgroup_force_empty though so we can safely
>> >> > keep the cgroup_mutex locked. This has an advantage that no tasks might
>> >> > be added during pre_destroy callback and so the handlers don't have to
>> >> > consider races when new tasks add new charges. This simplifies the
>> >> > implementation.
>> >> > ---
>> >> >  kernel/cgroup.c |    2 --
>> >> >  1 file changed, 2 deletions(-)
>> >> >
>> >> > diff --git a/kernel/cgroup.c b/kernel/cgroup.c
>> >> > index 0f3527d..9dba05d 100644
>> >> > --- a/kernel/cgroup.c
>> >> > +++ b/kernel/cgroup.c
>> >> > @@ -4181,7 +4181,6 @@ again:
>> >> >  		mutex_unlock(&cgroup_mutex);
>> >> >  		return -EBUSY;
>> >> >  	}
>> >> > -	mutex_unlock(&cgroup_mutex);
>> >> >
>> >> >  	/*
>> >> >  	 * In general, subsystem has no css->refcnt after pre_destroy(). But
>> >> > @@ -4204,7 +4203,6 @@ again:
>> >> >  		return ret;
>> >> >  	}
>> >> >
>> >> > -	mutex_lock(&cgroup_mutex);
>> >> >  	parent = cgrp->parent;
>> >> >  	if (atomic_read(&cgrp->count) || !list_empty(&cgrp->children)) {
>> >> >  		clear_bit(CGRP_WAIT_ON_RMDIR, &cgrp->flags);
>> >> 
>> >> mem_cgroup_force_empty still calls 
>> >> 
>> >> lru_add_drain_all 
>> >>    ->schedule_on_each_cpu
>> >>         -> get_online_cpus
>> >>            ->mutex_lock(&cpu_hotplug.lock);
>> >> 
>> >> So wont we deadlock ?
>> >
>> > Yes you are right. I got it wrong. I thought that the reclaim is the
>> > main problem. It won't be that easy then and the origin mm patch
>> > (hugetlb-cgroup-simplify-pre_destroy-callback.patch) still needs a fix
>> > or to be dropped.
>> 
>> We just need to remove the VM_BUG_ON() right ? The rest of the patch is
>> good right ? Otherwise how about the below
>
> You can keep VM_BUG_ON with the patch below and also remove the check
> for cgroup_task_count || &cgroup->children because that is checked in
> cgroup_rmdir already.
>

Does cgroup_rmdir do a cgroup_task_count check ? I do see that it check
cgroup->childern and cgroup->count. But cgroup->count is not same as
task_count right ?

May be we need to push the task_count check also to rmdir so that
pre_destory doesn't need to check this 

-aneesh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
