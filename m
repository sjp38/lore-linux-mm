Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id 4AA996B0008
	for <linux-mm@kvack.org>; Fri, 25 May 2018 15:44:30 -0400 (EDT)
Received: by mail-pf0-f199.google.com with SMTP id z1-v6so3482348pfh.3
        for <linux-mm@kvack.org>; Fri, 25 May 2018 12:44:30 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id t193-v6sor7128407pgc.248.2018.05.25.12.44.29
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 25 May 2018 12:44:29 -0700 (PDT)
Date: Fri, 25 May 2018 12:44:27 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [rfc patch] mm, oom: fix unnecessary killing of additional
 processes
In-Reply-To: <201805250019.w4P0J3Dl018566@www262.sakura.ne.jp>
Message-ID: <alpine.DEB.2.21.1805251237110.158701@chino.kir.corp.google.com>
References: <alpine.DEB.2.21.1805241422070.182300@chino.kir.corp.google.com> <201805250019.w4P0J3Dl018566@www262.sakura.ne.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>
Cc: Michal Hocko <mhocko@suse.com>, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Fri, 25 May 2018, Tetsuo Handa wrote:

> > The oom reaper ensures forward progress by setting MMF_OOM_SKIP itself if
> > it cannot reap an mm.  This can happen for a variety of reasons,
> > including:
> > 
> >  - the inability to grab mm->mmap_sem in a sufficient amount of time,
> > 
> >  - when the mm has blockable mmu notifiers that could cause the oom reaper
> >    to stall indefinitely,
> > 
> > but we can also add a third when the oom reaper can "reap" an mm but doing
> > so is unlikely to free any amount of memory:
> > 
> >  - when the mm's memory is fully mlocked.
> 
>    - when the mm's memory is fully mlocked (needs privilege) or
>      fully shared (does not need privilege)
> 

Good point, that is another way that unnecessary oom killing can occur 
because the oom reaper sets MMF_OOM_SKIP far too early.  I can make the 
change to the commit message.

Also, I noticed in my patch that oom_reap_task() should be doing 
list_add_tail() rather than list_add() to enqueue the mm for reaping 
again.

> > This is the same issue where the exit path sets MMF_OOM_SKIP before
> > unmapping memory and additional processes can be chosen unnecessarily
> > because the oom killer is racing with exit_mmap().
> > 
> > We can't simply defer setting MMF_OOM_SKIP, however, because if there is
> > a true oom livelock in progress, it never gets set and no additional
> > killing is possible.
> > 
> > To fix this, this patch introduces a per-mm reaping timeout, initially set
> > at 10s.  It requires that the oom reaper's list becomes a properly linked
> > list so that other mm's may be reaped while waiting for an mm's timeout to
> > expire.
> 
> I already proposed more simpler one at https://patchwork.kernel.org/patch/9877991/ .
> 

It's a similar idea, and I'm glad that we agree that some kind of per-mm 
delay is required to avoid this problem.  I think yours is simpler, but 
consider the other two changes in my patch:

 - in the normal exit path, absent any timeout for the mm, we only set
   MMF_OOM_SKIP after free_pgtables() when it is known we will not free
   any additional memory, which can also cause unnecessary oom killing
   because the oom killer races with free_pgtables(), and

 - the oom reaper now operates over all concurrent victims instead of
   repeatedly trying to take mm->mmap_sem of the first victim, sleeping
   many times, retrying, giving up, and moving on the next victim.
   Allowing the oom reaper to iterate through all victims can allow
   memory freeing such that an allocator may be able to drop mm->mmap_sem.

In fact, with my patch, I don't know of any condition where we kill 
additional processes unnecessarily *unless* the victim cannot be oom 
reaped or complete memory freeing in the exit path within 10 seconds.  
Given how rare oom livelock appears in practice, I think the 10 seconds is 
justified because right now it is _trivial_ to oom kill many victims 
completely unnecessarily.
