Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f42.google.com (mail-pa0-f42.google.com [209.85.220.42])
	by kanga.kvack.org (Postfix) with ESMTP id A1BFF6B006C
	for <linux-mm@kvack.org>; Mon,  9 Jun 2014 06:09:05 -0400 (EDT)
Received: by mail-pa0-f42.google.com with SMTP id lj1so609021pab.29
        for <linux-mm@kvack.org>; Mon, 09 Jun 2014 03:09:05 -0700 (PDT)
Received: from heian.cn.fujitsu.com ([59.151.112.132])
        by mx.google.com with ESMTP id gc1si30266944pbb.94.2014.06.09.03.09.03
        for <linux-mm@kvack.org>;
        Mon, 09 Jun 2014 03:09:04 -0700 (PDT)
Message-ID: <53958539.1070904@cn.fujitsu.com>
Date: Mon, 9 Jun 2014 17:58:17 +0800
From: Gu Zheng <guz.fnst@cn.fujitsu.com>
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
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-kernel <linux-kernel@vger.kernel.org>, Tejun Heo <tj@kernel.org>, linux-mm@kvack.org, Cgroups <cgroups@vger.kernel.org>, stable@vger.kernel.org, Li Zefan <lizefan@huawei.com>

Hi David,

On 06/09/2014 05:13 PM, David Rientjes wrote:

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
>> But thinking more, though the current implementation has flaw, but I worry
>> about the negative effect if we really want to fix it. Or maybe the fear
>> is unnecessary.:) 
>>
> 
> It needs to be slightly rewritten to work properly without negatively 
> impacting the latency of fork().  Do you have the cycles to do it?
> 

To be honest, I'm busy with other schedule. And if you(or other
guys) have proper proposal, please go ahead.

To Tejun, Li and Andrew:
Any comment? Or could you apply this *bug fix* first?

Regards,
Gu

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
