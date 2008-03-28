Received: from d28relay02.in.ibm.com (d28relay02.in.ibm.com [9.184.220.59])
	by e28smtp06.in.ibm.com (8.13.1/8.13.1) with ESMTP id m2SIESQ9032650
	for <linux-mm@kvack.org>; Fri, 28 Mar 2008 23:44:28 +0530
Received: from d28av01.in.ibm.com (d28av01.in.ibm.com [9.184.220.63])
	by d28relay02.in.ibm.com (8.13.8/8.13.8/NCO v8.7) with ESMTP id m2SIERSm1147018
	for <linux-mm@kvack.org>; Fri, 28 Mar 2008 23:44:27 +0530
Received: from d28av01.in.ibm.com (loopback [127.0.0.1])
	by d28av01.in.ibm.com (8.13.1/8.13.3) with ESMTP id m2SIEYEG001796
	for <linux-mm@kvack.org>; Fri, 28 Mar 2008 18:14:35 GMT
Message-ID: <47ED34A4.70604@linux.vnet.ibm.com>
Date: Fri, 28 Mar 2008 23:40:44 +0530
From: Balbir Singh <balbir@linux.vnet.ibm.com>
Reply-To: balbir@linux.vnet.ibm.com
MIME-Version: 1.0
Subject: Re: [-mm] Add an owner to the mm_struct (v2)
References: <20080328082316.6961.29044.sendpatchset@localhost.localdomain> <6599ad830803280401r68d30e91waaea8eb1de36eb52@mail.gmail.com> <47ECE662.3060506@linux.vnet.ibm.com> <6599ad830803280705o4213c448r991cbf9da6ffe2f1@mail.gmail.com> <47ED0621.4050304@linux.vnet.ibm.com> <6599ad830803280838s19ffc366w1a950ebb12e2907b@mail.gmail.com>
In-Reply-To: <6599ad830803280838s19ffc366w1a950ebb12e2907b@mail.gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Paul Menage <menage@google.com>
Cc: Pavel Emelianov <xemul@openvz.org>, Hugh Dickins <hugh@veritas.com>, Sudhir Kumar <skumar@linux.vnet.ibm.com>, YAMAMOTO Takashi <yamamoto@valinux.co.jp>, lizf@cn.fujitsu.com, linux-kernel@vger.kernel.org, taka@valinux.co.jp, linux-mm@kvack.org, David Rientjes <rientjes@google.com>, Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
List-ID: <linux-mm.kvack.org>

Paul Menage wrote:
> On Fri, Mar 28, 2008 at 7:52 AM, Balbir Singh <balbir@linux.vnet.ibm.com> wrote:
>>  mm->owner_lock is there to protect mm->owner field from changing simultaneously
>>  as tasks fork/exit.
>>
> 
> But the *hardware* already does that for you - individual writes to
> pointers are already atomic operations and so will be serialized.
> Using a lock to guard something only does anything useful if at least
> one of the critical regions that takes the lock consists of more than
> a single atomic operation, or if you have a mixture of read sections
> and write sections. Now it's true that your critical region in
> mm_fork_init_owner() is more than a single atomic op, but I'm arguing
> below that it's a no-op. So that just leaves the single region
> 
> spin_lock(&mm->owner_lock);
> mm->owner = new_owner;
> spin_unlock(&mm->owner_lock);
> 
> which isn't observably different if you remove the spinlock.
> 

At fork time, we can have do_fork() run in parallel and we need to protect
mm->owner, if several threads are created at the same time. We don't want to
overwrite mm->owner for each thread that is created.

>>  Oh! yes.. my bad again. The check should have been p == p->thread_group, but
>>  that is not required either. The check should now ideally be
>>
>>  if (!(clone_flags & CLONE_VM))
>>
> 
> OK, so if the new thread has its own mm (and hence will already have
> mm->owner set up to point to p in mm_init()) then we do:
> 
>>  +       if (mm->owner != p)
>>  +               rcu_assign_pointer(mm->owner, p->group_leader);
> 
> which is a no-op since we know mm->owner == p.
> 
>>  Yes.. I think we need to call it earlier.
>>
> 
> No, I think we need to call it later - after we've cleared current->mm
> (from within task_lock(current)) - so we can't rely on p->mm in this
> function, we have to pass it in. If we call it before while
> current->mm == mm, then we risk a race where the (new or existing)
> owner exits and passes it back to us *after* we've done a check to see
> if we need to find a new owner. If we ensure that current->mm != mm
> before we call mm_update_next_owner(), then we know we're not a
> candidate for receiving the ownership if we don't have it already.
> 

Yes and we could also check for flags & PF_EXITING

>>  But there is no way to guarantee that, what is the new_owner exec's after we've
>>  done the check and assigned. Won't we end up breaking the invariant? How about
>>  we have mm_update_new_owner() call in exec_mmap() as well? That way, we can
>>  still use owner_lock and keep the invariant.
>>
> 
> Oops, I thought that exit_mm() already got called in the execve()
> path, but you're right, it doesn't.
> 
> Yes, exit_mmap() should call mm_update_next_owner() after the call to
> task_unlock(), i.e. after it's set its new mm.
> 
> So I need to express the invariant more carefully.
> 
> What we need to preserve is that, for every mm at all times, mm->owner
> points to a valid task. So either:
> 
> 1) mm->owner->mm == mm AND mm->owner will check to see whether it
> needs to pass ownership before it exits or execs.
> 
> OR
> 
> 2) mm->owner is the last user of mm and is about to free mm.
> 
> OR
> 
> 3) mm->owner is currently searching for another user of mm to pass the
> ownership to.
> 
> In order to get from state 3 to state 1 safely we have to hold
> task_lock(new_owner). Otherwise we can race with an exit or exec in
> new_owner, resulting in a process that has already passed the point of
> checking current->mm->owner.
> 

No.. like you said if we do it after current->mm has changed and is different
from mm, then it's safe to find a new owner. I still don't see why we need
task_lock(new_owner). Even if we have task_lock(new_owner), it can still exit or
exec later.

> I don't see why we need mm->owner_lock to maintain this invariant.
> (But am quite prepared to be proven wrong).
> 

Why mix task_lock() to protect mm->owner? owner_lock can provide the protection
you are talking about.


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
