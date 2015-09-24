Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f53.google.com (mail-pa0-f53.google.com [209.85.220.53])
	by kanga.kvack.org (Postfix) with ESMTP id 0A4E76B026E
	for <linux-mm@kvack.org>; Thu, 24 Sep 2015 17:15:37 -0400 (EDT)
Received: by pacgz1 with SMTP id gz1so1072767pac.3
        for <linux-mm@kvack.org>; Thu, 24 Sep 2015 14:15:36 -0700 (PDT)
Received: from mail-pa0-x235.google.com (mail-pa0-x235.google.com. [2607:f8b0:400e:c03::235])
        by mx.google.com with ESMTPS id ek3si333398pbb.43.2015.09.24.14.15.36
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 24 Sep 2015 14:15:36 -0700 (PDT)
Received: by pacfv12 with SMTP id fv12so84868287pac.2
        for <linux-mm@kvack.org>; Thu, 24 Sep 2015 14:15:36 -0700 (PDT)
Date: Thu, 24 Sep 2015 14:15:34 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: can't oom-kill zap the victim's memory?
In-Reply-To: <20150923205923.GB19054@dhcp22.suse.cz>
Message-ID: <alpine.DEB.2.10.1509241359100.32488@chino.kir.corp.google.com>
References: <1442512783-14719-1-git-send-email-kwalker@redhat.com> <20150919150316.GB31952@redhat.com> <CA+55aFwkvbMrGseOsZNaxgP3wzDoVjkGasBKFxpn07SaokvpXA@mail.gmail.com> <20150920125642.GA2104@redhat.com> <CA+55aFyajHq2W9HhJWbLASFkTx_kLSHtHuY6mDHKxmoW-LnVEw@mail.gmail.com>
 <20150921134414.GA15974@redhat.com> <20150921142423.GC19811@dhcp22.suse.cz> <20150921153252.GA21988@redhat.com> <20150921161203.GD19811@dhcp22.suse.cz> <20150922160608.GA2716@redhat.com> <20150923205923.GB19054@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Oleg Nesterov <oleg@redhat.com>, Linus Torvalds <torvalds@linux-foundation.org>, Kyle Walker <kwalker@redhat.com>, Christoph Lameter <cl@linux.com>, Andrew Morton <akpm@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, Vladimir Davydov <vdavydov@parallels.com>, linux-mm <linux-mm@kvack.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Stanislav Kozina <skozina@redhat.com>, Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>

On Wed, 23 Sep 2015, Michal Hocko wrote:

> I am still not sure how you want to implement that kernel thread but I
> am quite skeptical it would be very much useful because all the current
> allocations which end up in the OOM killer path cannot simply back off
> and drop the locks with the current allocator semantic.  So they will
> be sitting on top of unknown pile of locks whether you do an additional
> reclaim (unmap the anon memory) in the direct OOM context or looping
> in the allocator and waiting for kthread/workqueue to do its work. The
> only argument that I can see is the stack usage but I haven't seen stack
> overflows in the OOM path AFAIR.
> 

Which locks are you specifically interested in?  We have already discussed 
the usefulness of killing all threads on the system sharing the same ->mm, 
meaning all threads that are either holding or want to hold mm->mmap_sem 
will be able to allocate into memory reserves.  Any allocator holding 
down_write(&mm->mmap_sem) should be able to allocate and drop its lock.  
(Are you concerned about MAP_POPULATE?)

> > Finally. Whatever we do, we need to change oom_kill_process() first,
> > and I think we should do this regardless. The "Kill all user processes
> > sharing victim->mm" logic looks wrong and suboptimal/overcomplicated.
> > I'll try to make some patches tomorrow if I have time...
> 
> That would be appreciated. I do not like that part either. At least we
> shouldn't go over the whole list when we have a good chance that the mm
> is not shared with other processes.
> 

Heh, it's actually imperative to avoid livelocking based on mm->mmap_sem, 
it's the reason the code exists.  Any optimizations to that is certainly 
welcome, but we definitely need to send SIGKILL to all threads sharing the 
mm to make forward progress, otherwise we are going back to pre-2008 
livelocks.

> Yes I am not really sure why oom_score_adj is not per-mm and we are
> doing that per signal struct to be honest. It doesn't make much sense as
> the mm_struct is the primary source of information for the oom victim
> selection. And the fact that mm might be shared withtout sharing signals
> make it double the reason to have it in mm.
> 
> It seems David has already tried that 2ff05b2b4eac ("oom: move oom_adj
> value from task_struct to mm_struct") but it was later reverted by
> 0753ba01e126 ("mm: revert "oom: move oom_adj value""). I do not agree
> with the reasoning there because vfork is documented to have undefined
> behavior
> "
>        if the process created by vfork() either modifies any data other
>        than a variable of type pid_t used to store the return value
>        from vfork(), or returns from the function in which vfork() was
>        called, or calls any other function before successfully calling
>        _exit(2) or one of the exec(3) family of functions.
> "
> Maybe we can revisit this... It would make the whole semantic much more
> straightforward. The current situation when you kill a task which might
> share the mm with OOM unkillable task is clearly suboptimal and
> confusing.
> 

How do you reconcile this with commit 28b83c5193e7 ("oom: move oom_adj 
value from task_struct to signal_struct")?  We also must appreciate the 
real-world usecase for an oom disabled process doing fork(), setting 
/proc/child/oom_score_adj to non-disabled, and exec().

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
