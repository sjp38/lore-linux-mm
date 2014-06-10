Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-we0-f181.google.com (mail-we0-f181.google.com [74.125.82.181])
	by kanga.kvack.org (Postfix) with ESMTP id B634B6B00DE
	for <linux-mm@kvack.org>; Mon,  9 Jun 2014 23:00:47 -0400 (EDT)
Received: by mail-we0-f181.google.com with SMTP id q59so1429405wes.26
        for <linux-mm@kvack.org>; Mon, 09 Jun 2014 20:00:47 -0700 (PDT)
Received: from szxga02-in.huawei.com (szxga02-in.huawei.com. [119.145.14.65])
        by mx.google.com with ESMTPS id fi1si14453554wib.89.2014.06.09.20.00.44
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Mon, 09 Jun 2014 20:00:46 -0700 (PDT)
Message-ID: <53967465.7070908@huawei.com>
Date: Tue, 10 Jun 2014 10:58:45 +0800
From: Li Zefan <lizefan@huawei.com>
MIME-Version: 1.0
Subject: Re: [PATCH] mm/mempolicy: fix sleeping function called from invalid
 context
References: <53902A44.50005@cn.fujitsu.com> <20140605132339.ddf6df4a0cf5c14d17eb8691@linux-foundation.org> <539192F1.7050308@cn.fujitsu.com> <alpine.DEB.2.02.1406081539140.21744@chino.kir.corp.google.com> <539574F1.2060701@cn.fujitsu.com> <alpine.DEB.2.02.1406090209460.24247@chino.kir.corp.google.com>
In-Reply-To: <alpine.DEB.2.02.1406090209460.24247@chino.kir.corp.google.com>
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: Gu Zheng <guz.fnst@cn.fujitsu.com>, Andrew Morton <akpm@linux-foundation.org>, linux-kernel <linux-kernel@vger.kernel.org>, Tejun Heo <tj@kernel.org>, linux-mm@kvack.org, Cgroups <cgroups@vger.kernel.org>, stable@vger.kernel.org

On 2014/6/9 17:13, David Rientjes wrote:
> On Mon, 9 Jun 2014, Gu Zheng wrote:
> 
>>> I think your patch addresses the problem that you're reporting but misses 
>>> the larger problem with cpuset.mems rebinding on fork().  When the 
>>> forker's task_struct is duplicated (which includes ->mems_allowed) and it 
>>> races with an update to cpuset_being_rebound in update_tasks_nodemask() 
>>> then the task's mems_allowed doesn't get updated.
>>
>> Yes, you are right, this patch just wants to address the bug reported above.
>> The race condition you mentioned above inherently exists there, but it is yet
>> another issue, the rcu lock here makes no sense to it, and I think we need
>> additional sync-mechanisms if want to fix it.
> 
> Yes, the rcu lock is not providing protection for any critical section 
> here that requires (1) the forker's cpuset to be stored in 
> cpuset_being_rebound or (2) the forked thread's cpuset to be rebound by 
> the cpuset nodemask update, and no race involving the two.
>

Yes, this is a long-standing issue. Besides the race you described, the child
task's mems_allowed can be wrong if the cpuset's nodemask changes before the
child has been added to the cgroup's tasklist.

I remember Tejun once said he wanted to disallow task migration between
cgroups during fork, and that should fix this problem.
 
>> But thinking more, though the current implementation has flaw, but I worry
>> about the negative effect if we really want to fix it. Or maybe the fear
>> is unnecessary.:) 
>>
> 
> It needs to be slightly rewritten to work properly without negatively 
> impacting the latency of fork().  Do you have the cycles to do it?
> 

Sounds you have other idea?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
