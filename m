Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id 40AD06B0003
	for <linux-mm@kvack.org>; Mon, 28 May 2018 12:03:49 -0400 (EDT)
Received: by mail-pf0-f200.google.com with SMTP id d20-v6so7583094pfn.16
        for <linux-mm@kvack.org>; Mon, 28 May 2018 09:03:49 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id bi10-v6si28039063plb.399.2018.05.28.09.03.47
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Mon, 28 May 2018 09:03:48 -0700 (PDT)
Date: Mon, 28 May 2018 10:13:45 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [rfc patch] mm, oom: fix unnecessary killing of additional
 processes
Message-ID: <20180528081345.GD1517@dhcp22.suse.cz>
References: <alpine.DEB.2.21.1805241422070.182300@chino.kir.corp.google.com>
 <20180525072636.GE11881@dhcp22.suse.cz>
 <alpine.DEB.2.21.1805251227380.158701@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.21.1805251227380.158701@chino.kir.corp.google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Fri 25-05-18 12:36:08, David Rientjes wrote:
> On Fri, 25 May 2018, Michal Hocko wrote:
> 
> > > The oom reaper ensures forward progress by setting MMF_OOM_SKIP itself if
> > > it cannot reap an mm.  This can happen for a variety of reasons,
> > > including:
> > > 
> > >  - the inability to grab mm->mmap_sem in a sufficient amount of time,
> > > 
> > >  - when the mm has blockable mmu notifiers that could cause the oom reaper
> > >    to stall indefinitely,
> > > 
> > > but we can also add a third when the oom reaper can "reap" an mm but doing
> > > so is unlikely to free any amount of memory:
> > > 
> > >  - when the mm's memory is fully mlocked.
> > > 
> > > When all memory is mlocked, the oom reaper will not be able to free any
> > > substantial amount of memory.  It sets MMF_OOM_SKIP before the victim can
> > > unmap and free its memory in exit_mmap() and subsequent oom victims are
> > > chosen unnecessarily.  This is trivial to reproduce if all eligible
> > > processes on the system have mlocked their memory: the oom killer calls
> > > panic() even though forward progress can be made.
> > > 
> > > This is the same issue where the exit path sets MMF_OOM_SKIP before
> > > unmapping memory and additional processes can be chosen unnecessarily
> > > because the oom killer is racing with exit_mmap().
> > > 
> > > We can't simply defer setting MMF_OOM_SKIP, however, because if there is
> > > a true oom livelock in progress, it never gets set and no additional
> > > killing is possible.
> > > 
> > > To fix this, this patch introduces a per-mm reaping timeout, initially set
> > > at 10s.  It requires that the oom reaper's list becomes a properly linked
> > > list so that other mm's may be reaped while waiting for an mm's timeout to
> > > expire.
> > 
> > No timeouts please! The proper way to handle this problem is to simply
> > teach the oom reaper to handle mlocked areas.
> 
> That's not sufficient since the oom reaper is also not able to oom reap if 
> the mm has blockable mmu notifiers or all memory is shared filebacked 
> memory, so it immediately sets MMF_OOM_SKIP and additional processes are 
> oom killed.

Could you be more specific with a real world example where that is the
case? I mean the full address space of non-reclaimable file backed
memory where waiting some more would help? Blockable mmu notifiers are
a PITA for sure. I wish we could have a better way to deal with them.
Maybe we can tell them we are in the non-blockable context and have them
release as much as possible. Still something that a random timeout
wouldn't help I am afraid.

> The current implementation that relies on MAX_OOM_REAP_RETRIES is acting 
> as a timeout already for mm->mmap_sem, but it's doing so without 
> attempting to oom reap other victims that may actually allow it to grab 
> mm->mmap_sem if the allocator is waiting on a lock.

Trying to reap a different oom victim when the current one is not making
progress during the lock contention is certainly something that make
sense. It has been proposed in the past and we just gave it up because
it was more complex. Do you have any specific example when this would
help to justify the additional complexity?

> The solution, as proposed, is to allow the oom reaper to iterate over all 
> victims and try to free memory rather than working on each victim one by 
> one and giving up.
> 
> But also note that even if oom reaping is possible, in the presence of an 
> antagonist that continues to allocate memory, that it is possible to oom 
> kill additional victims unnecessarily if we aren't able to complete 
> free_pgtables() in exit_mmap() of the original victim.

If there is unbound source of allocations then we are screwed no matter
what. We just hope that the allocator will get noticed by the oom killer
and it will be stopped.

That being said. I do not object for justified improvements in the oom
reaping. But I absolutely detest some random timeouts and will nack
implementations based on them until it is absolutely clear there is no
other way around.
-- 
Michal Hocko
SUSE Labs
