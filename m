Received: from zps36.corp.google.com (zps36.corp.google.com [172.25.146.36])
	by smtp-out.google.com with ESMTP id m2SIq6hn006721
	for <linux-mm@kvack.org>; Fri, 28 Mar 2008 18:52:06 GMT
Received: from wx-out-0506.google.com (wxdh31.prod.google.com [10.70.134.31])
	by zps36.corp.google.com with ESMTP id m2SIpUCR015862
	for <linux-mm@kvack.org>; Fri, 28 Mar 2008 11:52:05 -0700
Received: by wx-out-0506.google.com with SMTP id h31so469170wxd.11
        for <linux-mm@kvack.org>; Fri, 28 Mar 2008 11:52:05 -0700 (PDT)
Message-ID: <6599ad830803281152g33e693f5s4c7090a503d2751d@mail.gmail.com>
Date: Fri, 28 Mar 2008 11:52:04 -0700
From: "Paul Menage" <menage@google.com>
Subject: Re: [-mm] Add an owner to the mm_struct (v2)
In-Reply-To: <47ED34A4.70604@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
References: <20080328082316.6961.29044.sendpatchset@localhost.localdomain>
	 <6599ad830803280401r68d30e91waaea8eb1de36eb52@mail.gmail.com>
	 <47ECE662.3060506@linux.vnet.ibm.com>
	 <6599ad830803280705o4213c448r991cbf9da6ffe2f1@mail.gmail.com>
	 <47ED0621.4050304@linux.vnet.ibm.com>
	 <6599ad830803280838s19ffc366w1a950ebb12e2907b@mail.gmail.com>
	 <47ED34A4.70604@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: balbir@linux.vnet.ibm.com
Cc: Pavel Emelianov <xemul@openvz.org>, Hugh Dickins <hugh@veritas.com>, Sudhir Kumar <skumar@linux.vnet.ibm.com>, YAMAMOTO Takashi <yamamoto@valinux.co.jp>, lizf@cn.fujitsu.com, linux-kernel@vger.kernel.org, taka@valinux.co.jp, linux-mm@kvack.org, David Rientjes <rientjes@google.com>, Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
List-ID: <linux-mm.kvack.org>

Hi Balbir,

Could you send out the latest version of your patch? I suspect it's
changed a bit based on on this review and it would be good to make
sure we're both on the same page.

On Fri, Mar 28, 2008 at 11:10 AM, Balbir Singh
<balbir@linux.vnet.ibm.com> wrote:
>
>  At fork time, we can have do_fork() run in parallel and we need to protect
>  mm->owner, if several threads are created at the same time. We don't want to
>  overwrite mm->owner for each thread that is created.

Why would you want to overwrite mm->owner for any of the threads? If
they're sharing an existing mm, then that mm must already have an
owner, so no need to update it.

>  > No, I think we need to call it later - after we've cleared current->mm
>  > (from within task_lock(current)) - so we can't rely on p->mm in this
>  > function, we have to pass it in. If we call it before while
>  > current->mm == mm, then we risk a race where the (new or existing)
>  > owner exits and passes it back to us *after* we've done a check to see
>  > if we need to find a new owner. If we ensure that current->mm != mm
>  > before we call mm_update_next_owner(), then we know we're not a
>  > candidate for receiving the ownership if we don't have it already.
>  >
>
>  Yes and we could also check for flags & PF_EXITING
>

A couple of issues with that:

- I'm not sure how that handles the exec case

- assume two users; the owner exits and wants to pass the ownership to
the other user. It finds it, but sees that it's PF_EXITING. What
should it do? If it waits for that other user to exit, it could take a
long time (e.g. core dumps can take many seconds). If it exits
immediately, then it will leave mm->owner pointing to an invalid task.
If it passes ownership to the other task, it might pass it after the
other task had done its mm_update_next_owner() check, which would be
too late.

- assume three users; the owner exits and wants to pass the ownership
to one of the other two users. it searches through the candidates and
finds one of the other users, which is in PF_EXITING, so it skips it.
Just after this it sees that the user count has fallen to two users.
How does it know whether the user that dropped the count was the
PF_EXITING process that it saw previously (in which case it should
keep searching) or the third user that it's not encountered yet (in
which case it's not going to find the other user anywhere in its
search).

>
>  >>  But there is no way to guarantee that, what is the new_owner exec's after we've
>  >>  done the check and assigned. Won't we end up breaking the invariant? How about
>  >>  we have mm_update_new_owner() call in exec_mmap() as well? That way, we can
>  >>  still use owner_lock and keep the invariant.
>  >>
>  >
>  > Oops, I thought that exit_mm() already got called in the execve()
>  > path, but you're right, it doesn't.
>  >
>  > Yes, exit_mmap() should call mm_update_next_owner() after the call to
>  > task_unlock(), i.e. after it's set its new mm.
>  >
>  > So I need to express the invariant more carefully.
>  >
>  > What we need to preserve is that, for every mm at all times, mm->owner
>  > points to a valid task. So either:
>  >
>  > 1) mm->owner->mm == mm AND mm->owner will check to see whether it
>  > needs to pass ownership before it exits or execs.
>  >
>  > OR
>  >
>  > 2) mm->owner is the last user of mm and is about to free mm.
>  >
>  > OR
>  >
>  > 3) mm->owner is currently searching for another user of mm to pass the
>  > ownership to.
>  >
>  > In order to get from state 3 to state 1 safely we have to hold
>  > task_lock(new_owner). Otherwise we can race with an exit or exec in
>  > new_owner, resulting in a process that has already passed the point of
>  > checking current->mm->owner.
>  >
>
>  No.. like you said if we do it after current->mm has changed and is different
>  from mm, then it's safe to find a new owner. I still don't see why we need
>  task_lock(new_owner).

How about the following sequence: A is old owner, B is new owner

A gets to the task_unlock() in exit_mm(): A->mm is now NULL, mm->owner == A
B starts to execve()
A calls mm_update_next_owner()
B gets to the "active_mm = tsk->active_mm" in exec_mmap()
A finds that B->mm == mm
B continues through the critical section, gets past the point where it
needs to check for ownership
A sets mm->owner = B
B finishes its exec, and carries on with its new mmap


> Even if we have task_lock(new_owner), it can still exit or
>  exec later.

Yes, but once we've set mm->owner to the other task and released its
task_lock, the new owner is responsible for handing off the mm to yet
another owner if necessary.

>
>  Why mix task_lock() to protect mm->owner?

We're not protecting mm->owner - we're protecting new_owner->mm

Paul

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
