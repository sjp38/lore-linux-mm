Received: from sd0109e.au.ibm.com (d23rh905.au.ibm.com [202.81.18.225])
	by e23smtp04.au.ibm.com (8.13.1/8.13.1) with ESMTP id m5J3EI1W009204
	for <linux-mm@kvack.org>; Thu, 19 Jun 2008 13:14:18 +1000
Received: from d23av01.au.ibm.com (d23av01.au.ibm.com [9.190.234.96])
	by sd0109e.au.ibm.com (8.13.8/8.13.8/NCO v9.0) with ESMTP id m5J3Dp8D116090
	for <linux-mm@kvack.org>; Thu, 19 Jun 2008 13:13:51 +1000
Received: from d23av01.au.ibm.com (loopback [127.0.0.1])
	by d23av01.au.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id m5J3DooV029605
	for <linux-mm@kvack.org>; Thu, 19 Jun 2008 13:13:51 +1000
Message-ID: <4859CEE7.9030505@linux.vnet.ibm.com>
Date: Thu, 19 Jun 2008 08:43:43 +0530
From: Balbir Singh <balbir@linux.vnet.ibm.com>
Reply-To: balbir@linux.vnet.ibm.com
MIME-Version: 1.0
Subject: Re: Question : memrlimit cgroup's task_move (2.6.26-rc5-mm3)
References: <20080619121435.f868c110.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20080619121435.f868c110.kamezawa.hiroyu@jp.fujitsu.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "menage@google.com" <menage@google.com>, "containers@lists.osdl.org" <containers@lists.osdl.org>
List-ID: <linux-mm.kvack.org>

KAMEZAWA Hiroyuki wrote:
> I used memrlimit cgroup at the first time.
> 
> May I ask a question about memrlimit cgroup ?
> 
> In following 
> ==
> static void memrlimit_cgroup_move_task(struct cgroup_subsys *ss,
>                                         struct cgroup *cgrp,
>                                         struct cgroup *old_cgrp,
>                                         struct task_struct *p)
> {
>         struct mm_struct *mm;
>         struct memrlimit_cgroup *memrcg, *old_memrcg;
> 
> <snip>
>         if (res_counter_charge(&memrcg->as_res, (mm->total_vm << PAGE_SHIFT)))
>                 goto out;
>         res_counter_uncharge(&old_memrcg->as_res, (mm->total_vm << PAGE_SHIFT));
> ==
> This is a callback for task_attach(). and this never fails.
> 
> What happens when the moved task, which move-of-charge fails, exits ?
> 

Good question - I am working on this, some of the logic should move to
can_attach(). I'll try and experiment with it and send out a fix.

> ==
> % mkdir /dev/cgroup/memrlimit/group_01
> % mkdir /dev/cgroup/memrlimit/group_02
> % echo 1G > /dev/cgroup/memrlimit/group_01/memrlimit.limit_in_bytes
> % echo 0 >  /dev/cgroup/memrlimit/group_02/memrlimit.limit_in_bytes
> % echo $$ > /dev/cgroup/memrlimit/group_01/tasks
> % echo $$ > /dev/cgroup/memrlimit/group_02/tasks
> % exit
> == you'll see WARNING ==
> 
> I think the charge of the new group goes to minus. right ?
> (and old group's charge never goes down.)
> I don't think this is "no problem".
> 
> What kind of patch is necessary to fix this ?
> task_attach() should be able to fail in future ?
> 
> I'm sorry if I misunderstand something or this is already in TODO list.
> 

It's already on the TODO list. Thanks for keeping me reminded about it.

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
