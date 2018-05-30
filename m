Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f70.google.com (mail-pl0-f70.google.com [209.85.160.70])
	by kanga.kvack.org (Postfix) with ESMTP id 0CAFB6B0006
	for <linux-mm@kvack.org>; Wed, 30 May 2018 17:06:55 -0400 (EDT)
Received: by mail-pl0-f70.google.com with SMTP id b31-v6so12014425plb.5
        for <linux-mm@kvack.org>; Wed, 30 May 2018 14:06:55 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id o85-v6sor673086pfj.11.2018.05.30.14.06.53
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 30 May 2018 14:06:53 -0700 (PDT)
Date: Wed, 30 May 2018 14:06:51 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [rfc patch] mm, oom: fix unnecessary killing of additional
 processes
In-Reply-To: <20180528081345.GD1517@dhcp22.suse.cz>
Message-ID: <alpine.DEB.2.21.1805301357100.150424@chino.kir.corp.google.com>
References: <alpine.DEB.2.21.1805241422070.182300@chino.kir.corp.google.com> <20180525072636.GE11881@dhcp22.suse.cz> <alpine.DEB.2.21.1805251227380.158701@chino.kir.corp.google.com> <20180528081345.GD1517@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Mon, 28 May 2018, Michal Hocko wrote:

> > That's not sufficient since the oom reaper is also not able to oom reap if 
> > the mm has blockable mmu notifiers or all memory is shared filebacked 
> > memory, so it immediately sets MMF_OOM_SKIP and additional processes are 
> > oom killed.
> 
> Could you be more specific with a real world example where that is the
> case? I mean the full address space of non-reclaimable file backed
> memory where waiting some more would help? Blockable mmu notifiers are
> a PITA for sure. I wish we could have a better way to deal with them.
> Maybe we can tell them we are in the non-blockable context and have them
> release as much as possible. Still something that a random timeout
> wouldn't help I am afraid.
> 

It's not a random timeout, it's sufficiently long such that we don't oom 
kill several processes needlessly in the very rare case where oom livelock 
would actually prevent the original victim from exiting.  The oom reaper 
processing an mm, finding everything to be mlocked, and immediately 
MMF_OOM_SKIP is inappropriate.  This is rather trivial to reproduce for a 
large memory hogging process that mlocks all of its memory; we 
consistently see spurious and unnecessary oom kills simply because the oom 
reaper has set MMF_OOM_SKIP very early.

This patch introduces a "give up" period such that the oom reaper is still 
allowed to do its good work but only gives up in the hope the victim can 
make forward progress at some substantial period of time in the future.  I 
would understand the objection if oom livelock where the victim cannot 
make forward progress were commonplace, but in the interest of not killing 
several processes needlessly every time a large mlocked process is 
targeted, I think it compels a waiting period.

> Trying to reap a different oom victim when the current one is not making
> progress during the lock contention is certainly something that make
> sense. It has been proposed in the past and we just gave it up because
> it was more complex. Do you have any specific example when this would
> help to justify the additional complexity?
> 

I'm not sure how you're defining complexity, the patch adds ~30 lines of 
code and prevents processes from needlessly being oom killed when oom 
reaping is largely unsuccessful and before the victim finishes 
free_pgtables() and then also allows the oom reaper to operate on multiple 
mm's instead of processing one at a time.  Obviously if there is a delay 
before MMF_OOM_SKIP is set it requires that the oom reaper be able to 
process other mm's, otherwise we stall needlessly for 10s.  Operating on 
multiple mm's in a linked list while waiting for victims to exit during a 
timeout period is thus very much needed, it wouldn't make sense without 
it.

> > But also note that even if oom reaping is possible, in the presence of an 
> > antagonist that continues to allocate memory, that it is possible to oom 
> > kill additional victims unnecessarily if we aren't able to complete 
> > free_pgtables() in exit_mmap() of the original victim.
> 
> If there is unbound source of allocations then we are screwed no matter
> what. We just hope that the allocator will get noticed by the oom killer
> and it will be stopped.
> 

It's not unbounded, it's just an allocator that acts as an antagonist.  At 
the risk of being overly verbose, for system or memcg oom conditions: a 
large mlocked process is oom killed, other processes continue to 
allocate/charge, the oom reaper almost immediately grants MMF_OOM_SKIP 
without being able to free any memory, and the other important processes 
are needlessly oom killed before the original victim can reach 
exit_mmap().  This happens a _lot_.

I'm open to hearing any other suggestions that you have other than waiting 
some time period before MMF_OOM_SKIP gets set to solve this problem.
