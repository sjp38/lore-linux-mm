Received: from d23relay03.au.ibm.com (d23relay03.au.ibm.com [202.81.18.234])
	by e23smtp06.au.ibm.com (8.13.1/8.13.1) with ESMTP id m463iOmU031999
	for <linux-mm@kvack.org>; Tue, 6 May 2008 13:44:24 +1000
Received: from d23av03.au.ibm.com (d23av03.au.ibm.com [9.190.234.97])
	by d23relay03.au.ibm.com (8.13.8/8.13.8/NCO v8.7) with ESMTP id m463ifWk4042906
	for <linux-mm@kvack.org>; Tue, 6 May 2008 13:44:41 +1000
Received: from d23av03.au.ibm.com (loopback [127.0.0.1])
	by d23av03.au.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id m463inZF017353
	for <linux-mm@kvack.org>; Tue, 6 May 2008 13:44:49 +1000
Message-ID: <481FD3FC.4010407@linux.vnet.ibm.com>
Date: Tue, 06 May 2008 09:13:56 +0530
From: Balbir Singh <balbir@linux.vnet.ibm.com>
Reply-To: balbir@linux.vnet.ibm.com
MIME-Version: 1.0
Subject: Re: [-mm][PATCH 2/4] Enhance cgroup mm_owner_changed callback to
 add task information
References: <20080503213726.3140.68845.sendpatchset@localhost.localdomain> <20080503213804.3140.26503.sendpatchset@localhost.localdomain> <20080505151504.98c28f7c.akpm@linux-foundation.org>
In-Reply-To: <20080505151504.98c28f7c.akpm@linux-foundation.org>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, skumar@linux.vnet.ibm.com, yamamoto@valinux.co.jp, menage@google.com, lizf@cn.fujitsu.com, linux-kernel@vger.kernel.org, rientjes@google.com, xemul@openvz.org, kamezawa.hiroyu@jp.fujitsu.com
List-ID: <linux-mm.kvack.org>

Andrew Morton wrote:
> On Sun, 04 May 2008 03:08:04 +0530
> Balbir Singh <balbir@linux.vnet.ibm.com> wrote:
> 
>>
>> This patch adds an additional field to the mm_owner callbacks. This field
>> is required to get to the mm that changed.
>>
>> Signed-off-by: Balbir Singh <balbir@linux.vnet.ibm.com>
>> ---
>>
>>  include/linux/cgroup.h |    3 ++-
>>  kernel/cgroup.c        |    2 +-
>>  2 files changed, 3 insertions(+), 2 deletions(-)
>>
>> diff -puN kernel/cgroup.c~cgroup-add-task-to-mm--owner-callbacks kernel/cgroup.c
>> --- linux-2.6.25/kernel/cgroup.c~cgroup-add-task-to-mm--owner-callbacks	2008-05-04 02:53:05.000000000 +0530
>> +++ linux-2.6.25-balbir/kernel/cgroup.c	2008-05-04 02:53:05.000000000 +0530
>> @@ -2772,7 +2772,7 @@ void cgroup_mm_owner_callbacks(struct ta
>>  			if (oldcgrp == newcgrp)
>>  				continue;
>>  			if (ss->mm_owner_changed)
>> -				ss->mm_owner_changed(ss, oldcgrp, newcgrp);
>> +				ss->mm_owner_changed(ss, oldcgrp, newcgrp, new);
>>  		}
>>  	}
>>  }
>> diff -puN include/linux/cgroup.h~cgroup-add-task-to-mm--owner-callbacks include/linux/cgroup.h
>> --- linux-2.6.25/include/linux/cgroup.h~cgroup-add-task-to-mm--owner-callbacks	2008-05-04 02:53:05.000000000 +0530
>> +++ linux-2.6.25-balbir/include/linux/cgroup.h	2008-05-04 02:53:05.000000000 +0530
>> @@ -310,7 +310,8 @@ struct cgroup_subsys {
>>  	 */
>>  	void (*mm_owner_changed)(struct cgroup_subsys *ss,
>>  					struct cgroup *old,
>> -					struct cgroup *new);
>> +					struct cgroup *new,
>> +					struct task_struct *p);
> 
> If mm_owner_changed() had any documentation I'd suggest that it be updated.
> Sneaky.
> 

No, there's no documentation besides the comments. I'll go ahead and update
cgroups.txt with some documentation.

> The existing comment:
> 
> 	/*
> 	 * This routine is called with the task_lock of mm->owner held
> 	 */
> 	void (*mm_owner_changed)(struct cgroup_subsys *ss,
> 					struct cgroup *old,
> 					struct cgroup *new);
> 
> Is rather mysterious.  To what mm does it refer?

This callback is called when the mm->owner field that points to/owns a cgroup
changes as a result of the owner exiting.

-- 
	Warm Regards,
	Balbir Singh
	Linux Technology Center
	IBM, ISTL

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
