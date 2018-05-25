Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f71.google.com (mail-pl0-f71.google.com [209.85.160.71])
	by kanga.kvack.org (Postfix) with ESMTP id C9EA16B0007
	for <linux-mm@kvack.org>; Fri, 25 May 2018 15:36:12 -0400 (EDT)
Received: by mail-pl0-f71.google.com with SMTP id x2-v6so3627892plv.0
        for <linux-mm@kvack.org>; Fri, 25 May 2018 12:36:12 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id q1-v6sor10319013plb.62.2018.05.25.12.36.11
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 25 May 2018 12:36:11 -0700 (PDT)
Date: Fri, 25 May 2018 12:36:08 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [rfc patch] mm, oom: fix unnecessary killing of additional
 processes
In-Reply-To: <20180525072636.GE11881@dhcp22.suse.cz>
Message-ID: <alpine.DEB.2.21.1805251227380.158701@chino.kir.corp.google.com>
References: <alpine.DEB.2.21.1805241422070.182300@chino.kir.corp.google.com> <20180525072636.GE11881@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Fri, 25 May 2018, Michal Hocko wrote:

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
> > 
> > When all memory is mlocked, the oom reaper will not be able to free any
> > substantial amount of memory.  It sets MMF_OOM_SKIP before the victim can
> > unmap and free its memory in exit_mmap() and subsequent oom victims are
> > chosen unnecessarily.  This is trivial to reproduce if all eligible
> > processes on the system have mlocked their memory: the oom killer calls
> > panic() even though forward progress can be made.
> > 
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
> No timeouts please! The proper way to handle this problem is to simply
> teach the oom reaper to handle mlocked areas.

That's not sufficient since the oom reaper is also not able to oom reap if 
the mm has blockable mmu notifiers or all memory is shared filebacked 
memory, so it immediately sets MMF_OOM_SKIP and additional processes are 
oom killed.

The current implementation that relies on MAX_OOM_REAP_RETRIES is acting 
as a timeout already for mm->mmap_sem, but it's doing so without 
attempting to oom reap other victims that may actually allow it to grab 
mm->mmap_sem if the allocator is waiting on a lock.

The solution, as proposed, is to allow the oom reaper to iterate over all 
victims and try to free memory rather than working on each victim one by 
one and giving up.

But also note that even if oom reaping is possible, in the presence of an 
antagonist that continues to allocate memory, that it is possible to oom 
kill additional victims unnecessarily if we aren't able to complete 
free_pgtables() in exit_mmap() of the original victim.

So this patch is solving all three issues: allowing a process to *fully* 
exit (including free_pgtables()) before setting MMF_OOM_SKIP, allows the 
oom reaper to act on parallel victims that may allow a victim to be 
reaped, and preventing additional processes from being killed 
unnecessarily when oom reaping isn't able to free memory (mlock, blockable 
mmu invalidates, all VM_SHARED file backed, small rss, etc).

The vast majority of the time, oom reaping can occur with this change or 
the process can reach exit_mmap() itself; oom livelock appears to be very 
rare with this patch even for mem cgroup constrained oom kills and very 
tight limitation and thus it makes sense to wait for a prolonged period of 
time before killing additional processes unnecessarily.
