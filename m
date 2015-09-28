Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f54.google.com (mail-pa0-f54.google.com [209.85.220.54])
	by kanga.kvack.org (Postfix) with ESMTP id 46AA96B0255
	for <linux-mm@kvack.org>; Mon, 28 Sep 2015 18:24:09 -0400 (EDT)
Received: by pacfv12 with SMTP id fv12so189710415pac.2
        for <linux-mm@kvack.org>; Mon, 28 Sep 2015 15:24:09 -0700 (PDT)
Received: from mail-pa0-x236.google.com (mail-pa0-x236.google.com. [2607:f8b0:400e:c03::236])
        by mx.google.com with ESMTPS id we9si31865542pac.164.2015.09.28.15.24.08
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 28 Sep 2015 15:24:08 -0700 (PDT)
Received: by pacex6 with SMTP id ex6so185749042pac.0
        for <linux-mm@kvack.org>; Mon, 28 Sep 2015 15:24:08 -0700 (PDT)
Date: Mon, 28 Sep 2015 15:24:06 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: can't oom-kill zap the victim's memory?
In-Reply-To: <20150925093556.GF16497@dhcp22.suse.cz>
Message-ID: <alpine.DEB.2.10.1509281512330.13657@chino.kir.corp.google.com>
References: <CA+55aFwkvbMrGseOsZNaxgP3wzDoVjkGasBKFxpn07SaokvpXA@mail.gmail.com> <20150920125642.GA2104@redhat.com> <CA+55aFyajHq2W9HhJWbLASFkTx_kLSHtHuY6mDHKxmoW-LnVEw@mail.gmail.com> <20150921134414.GA15974@redhat.com> <20150921142423.GC19811@dhcp22.suse.cz>
 <20150921153252.GA21988@redhat.com> <20150921161203.GD19811@dhcp22.suse.cz> <20150922160608.GA2716@redhat.com> <20150923205923.GB19054@dhcp22.suse.cz> <alpine.DEB.2.10.1509241359100.32488@chino.kir.corp.google.com> <20150925093556.GF16497@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Oleg Nesterov <oleg@redhat.com>, Linus Torvalds <torvalds@linux-foundation.org>, Kyle Walker <kwalker@redhat.com>, Christoph Lameter <cl@linux.com>, Andrew Morton <akpm@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, Vladimir Davydov <vdavydov@parallels.com>, linux-mm <linux-mm@kvack.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Stanislav Kozina <skozina@redhat.com>, Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>

On Fri, 25 Sep 2015, Michal Hocko wrote:

> > > I am still not sure how you want to implement that kernel thread but I
> > > am quite skeptical it would be very much useful because all the current
> > > allocations which end up in the OOM killer path cannot simply back off
> > > and drop the locks with the current allocator semantic.  So they will
> > > be sitting on top of unknown pile of locks whether you do an additional
> > > reclaim (unmap the anon memory) in the direct OOM context or looping
> > > in the allocator and waiting for kthread/workqueue to do its work. The
> > > only argument that I can see is the stack usage but I haven't seen stack
> > > overflows in the OOM path AFAIR.
> > > 
> > 
> > Which locks are you specifically interested in?
> 
> Any locks they were holding before they entered the page allocator (e.g.
> i_mutex is the easiest one to trigger from the userspace but mmap_sem
> might be involved as well because we are doing kmalloc(GFP_KERNEL) with
> mmap_sem held for write). Those would be locked until the page allocator
> returns, which with the current semantic might be _never_.
> 

I agree that i_mutex seems to be one of the most common offenders.  
However, I'm not sure I understand why holding it while trying to allocate 
infinitely for an order-0 allocation is problematic wrt the proposed 
kthread.  The kthread itself need only take mmap_sem for read.  If all 
threads sharing the mm with a victim have been SIGKILL'd, they should get 
TIF_MEMDIE set when reclaim fails and be able to allocate so that they can 
drop mmap_sem.  We must ensure that any holder of mmap_sem cannot quickly 
deplete memory reserves without properly checking for 
fatal_signal_pending().

> > We have already discussed 
> > the usefulness of killing all threads on the system sharing the same ->mm, 
> > meaning all threads that are either holding or want to hold mm->mmap_sem 
> > will be able to allocate into memory reserves.  Any allocator holding 
> > down_write(&mm->mmap_sem) should be able to allocate and drop its lock.  
> > (Are you concerned about MAP_POPULATE?)
> 
> I am not sure I understand. We would have to fail the request in order
> the context which requested the memory could drop the lock. Are we
> talking about the same thing here?
> 

Not fail the request, they should be able to allocate from memory reserves 
when TIF_MEMDIE gets set.  This would require that threads is all gfp 
contexts are able to get TIF_MEMDIE set without an explicit call to 
out_of_memory() for !__GFP_FS.

> > Heh, it's actually imperative to avoid livelocking based on mm->mmap_sem, 
> > it's the reason the code exists.  Any optimizations to that is certainly 
> > welcome, but we definitely need to send SIGKILL to all threads sharing the 
> > mm to make forward progress, otherwise we are going back to pre-2008 
> > livelocks.
> 
> Yes but mm is not shared between processes most of the time. CLONE_VM
> without CLONE_THREAD is more a corner case yet we have to crawl all the
> task_structs for _each_ OOM killer invocation. Yes this is an extreme
> slow path but still might take quite some unnecessarily time.
>  

It must solve the issue you describe, killing other processes that share 
the ->mm, otherwise we have mm->mmap_sem livelock.  We are not concerned 
about iterating over all task_structs in the oom killer as a painpoint, 
such users should already be using oom_kill_allocating_task which is why 
it was introduced.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
