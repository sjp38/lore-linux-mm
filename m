Received: from sd0109e.au.ibm.com (d23rh905.au.ibm.com [202.81.18.225])
	by e23smtp03.au.ibm.com (8.13.1/8.13.1) with ESMTP id m8QC48dm006967
	for <linux-mm@kvack.org>; Fri, 26 Sep 2008 22:04:08 +1000
Received: from d23av03.au.ibm.com (d23av03.au.ibm.com [9.190.234.97])
	by sd0109e.au.ibm.com (8.13.8/8.13.8/NCO v9.1) with ESMTP id m8QC2Tnu308028
	for <linux-mm@kvack.org>; Fri, 26 Sep 2008 22:02:50 +1000
Received: from d23av03.au.ibm.com (loopback [127.0.0.1])
	by d23av03.au.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id m8QC2SLO030299
	for <linux-mm@kvack.org>; Fri, 26 Sep 2008 22:02:29 +1000
Message-ID: <48DCCF49.8040403@linux.vnet.ibm.com>
Date: Fri, 26 Sep 2008 17:32:17 +0530
From: Balbir Singh <balbir@linux.vnet.ibm.com>
Reply-To: balbir@linux.vnet.ibm.com
MIME-Version: 1.0
Subject: Re: [PATCH] mm owner: fix race between swapoff and exit
References: <Pine.LNX.4.64.0809250117220.26422@blonde.site> <48DCC068.30706@gmail.com>
In-Reply-To: <48DCC068.30706@gmail.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Jiri Slaby <jirislaby@gmail.com>
Cc: Hugh Dickins <hugh@veritas.com>, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, KAMEZAWA Hiroyuki <kamezawa.hiroyuki@jp.fujitsu.com>, Paul Menage <menage@google.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Jiri Slaby wrote:
> Hugh Dickins napsal(a):
>> From: Balbir Singh <balbir@linux.vnet.ibm.com>
>>
>> There's a race between mm->owner assignment and swapoff, more easily
>> seen when task slab poisoning is turned on.  The condition occurs when
>> try_to_unuse() runs in parallel with an exiting task.  A similar race
>> can occur with callers of get_task_mm(), such as /proc/<pid>/<mmstats>
>> or ptrace or page migration.
>>
>> CPU0                                    CPU1
>>                                         try_to_unuse
>>                                         looks at mm = task0->mm
>>                                         increments mm->mm_users
>> task 0 exits
>> mm->owner needs to be updated, but no
>> new owner is found (mm_users > 1, but
>> no other task has task->mm = task0->mm)
>> mm_update_next_owner() leaves
>>                                         mmput(mm) decrements mm->mm_users
>> task0 freed
>>                                         dereferencing mm->owner fails
>>
>> The fix is to notify the subsystem via mm_owner_changed callback(),
>> if no new owner is found, by specifying the new task as NULL.
>>
>> Jiri Slaby:
>> mm->owner was set to NULL prior to calling cgroup_mm_owner_callbacks(), but
>> must be set after that, so as not to pass NULL as old owner causing oops.
>>
>> Daisuke Nishimura:
>> mm_update_next_owner() may set mm->owner to NULL, but mem_cgroup_from_task()
>> and its callers need to take account of this situation to avoid oops.
> 
> What about
> memrlimit-setup-the-memrlimit-controller-mm_owner-fix
> ? It adds check for `old' being NULL.
> 

The memrlimit patches are not yet in mainline (they are in -mm).

> BTW there is also mm->owner = NULL; movement in the patch to the line before
> the callbacks are invoked which I don't understand much (why to inform
> anybody about NULL->NULL change?), but the first hunk seems reasonable to me.
> 

It is not in the hunk being posted for inclusion in 2.6.27-rc

> [...]
>> --- 2.6.27-rc7/kernel/cgroup.c	2008-08-06 08:36:20.000000000 +0100
>> +++ linux/kernel/cgroup.c	2008-09-24 17:17:32.000000000 +0100
>> @@ -2738,14 +2738,15 @@ void cgroup_fork_callbacks(struct task_s
>>   */
>>  void cgroup_mm_owner_callbacks(struct task_struct *old, struct task_struct *new)
>>  {
>> -	struct cgroup *oldcgrp, *newcgrp;
>> +	struct cgroup *oldcgrp, *newcgrp = NULL;
>>  
>>  	if (need_mm_owner_callback) {
>>  		int i;
>>  		for (i = 0; i < CGROUP_SUBSYS_COUNT; i++) {
>>  			struct cgroup_subsys *ss = subsys[i];
>>  			oldcgrp = task_cgroup(old, ss->subsys_id);
>> -			newcgrp = task_cgroup(new, ss->subsys_id);
>> +			if (new)
>> +				newcgrp = task_cgroup(new, ss->subsys_id);
>>  			if (oldcgrp == newcgrp)
>>  				continue;
>>  			if (ss->mm_owner_changed)
>> --- 2.6.27-rc7/kernel/exit.c	2008-09-10 07:37:25.000000000 +0100
>> +++ linux/kernel/exit.c	2008-09-24 17:17:32.000000000 +0100
>> @@ -627,6 +625,16 @@ retry:
>>  	} while_each_thread(g, c);
>>  
>>  	read_unlock(&tasklist_lock);
>> +	/*
>> +	 * We found no owner yet mm_users > 1: this implies that we are
>> +	 * most likely racing with swapoff (try_to_unuse()) or /proc or
>> +	 * ptrace or page migration (get_task_mm()).  Mark owner as NULL,
>> +	 * so that subsystems can understand the callback and take action.
>> +	 */
>> +	down_write(&mm->mmap_sem);
>> +	cgroup_mm_owner_callbacks(mm->owner, NULL);
>> +	mm->owner = NULL;
>> +	up_write(&mm->mmap_sem);
>>  	return;
>>  
>>  assign_new_owner:
> 


-- 
	Balbir

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
