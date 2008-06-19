Received: from d28relay02.in.ibm.com (d28relay02.in.ibm.com [9.184.220.59])
	by e28esmtp04.in.ibm.com (8.13.1/8.13.1) with ESMTP id m5JCUX9a007389
	for <linux-mm@kvack.org>; Thu, 19 Jun 2008 18:00:33 +0530
Received: from d28av05.in.ibm.com (d28av05.in.ibm.com [9.184.220.67])
	by d28relay02.in.ibm.com (8.13.8/8.13.8/NCO v9.0) with ESMTP id m5JCTeIc749600
	for <linux-mm@kvack.org>; Thu, 19 Jun 2008 17:59:40 +0530
Received: from d28av05.in.ibm.com (loopback [127.0.0.1])
	by d28av05.in.ibm.com (8.13.1/8.13.3) with ESMTP id m5JCUWhL010369
	for <linux-mm@kvack.org>; Thu, 19 Jun 2008 18:00:33 +0530
Message-ID: <485A5160.5070901@linux.vnet.ibm.com>
Date: Thu, 19 Jun 2008 18:00:24 +0530
From: Balbir Singh <balbir@linux.vnet.ibm.com>
Reply-To: balbir@linux.vnet.ibm.com
MIME-Version: 1.0
Subject: Re: Question : memrlimit cgroup's task_move (2.6.26-rc5-mm3)
References: <20080619121435.f868c110.kamezawa.hiroyu@jp.fujitsu.com> <4859CEE7.9030505@linux.vnet.ibm.com> <20080619122429.138a1d32.kamezawa.hiroyu@jp.fujitsu.com> <20080619192227.972ded64.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20080619192227.972ded64.kamezawa.hiroyu@jp.fujitsu.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "menage@google.com" <menage@google.com>, "containers@lists.osdl.org" <containers@lists.osdl.org>
List-ID: <linux-mm.kvack.org>

KAMEZAWA Hiroyuki wrote:
> On Thu, 19 Jun 2008 12:24:29 +0900
> KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> wrote:
> 
>> On Thu, 19 Jun 2008 08:43:43 +0530
>> Balbir Singh <balbir@linux.vnet.ibm.com> wrote:
>>
>>>> I think the charge of the new group goes to minus. right ?
>>>> (and old group's charge never goes down.)
>>>> I don't think this is "no problem".
>>>>
>>>> What kind of patch is necessary to fix this ?
>>>> task_attach() should be able to fail in future ?
>>>>
>>>> I'm sorry if I misunderstand something or this is already in TODO list.
>>>>
>>> It's already on the TODO list. Thanks for keeping me reminded about it.
>>>
>> Okay, I'm looking foward to see how can_attach and roll-back(if necessary)
>> is implemnted.
>> As you know, I'm interested in how to handle failure of task move.
>>
> One more thing...
> Now, charge is done at
> 
>  - vm is inserted (special case?)
>  - vm is expanded (mmap is called, stack growth...)
> 
> And uncharge is done at
>  - vm is removed (success of munmap)
>  - exit_mm is called (exit of process)
> 
> But it seems charging at may_expand_vm() is not good.
> The mmap can fail after may_expand_vm() because of various reason,
> but charge is already done at may_expand_vm()....and no roll-back.
> 
> == an easy example of leak in stack growth handling ==
> [root@iridium kamezawa]# cat /opt/cgroup/test/memrlimit.usage_in_bytes
> 71921664
> [root@iridium kamezawa]# ulimit -s 3
> [root@iridium kamezawa]# ls
> Killed
> [root@iridium kamezawa]# ls
> Killed
> [root@iridium kamezawa]# ls
> Killed
> [root@iridium kamezawa]# ls
> Killed
> [root@iridium kamezawa]# ls
> Killed
> [root@iridium kamezawa]# ulimit -s unlimited
> [root@iridium kamezawa]# cat /opt/cgroup/test/memrlimit.usage_in_bytes
> 72368128
> [root@iridium kamezawa]#

Aaah.. I see.. I had it in place earlier, but moved them to may_expand_vm() on
review suggestions. I can move it out or try to unroll when things fail. I'll
experiment a bit more. Is there any particular method you prefer?

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
