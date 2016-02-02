Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f176.google.com (mail-pf0-f176.google.com [209.85.192.176])
	by kanga.kvack.org (Postfix) with ESMTP id D201E6B0009
	for <linux-mm@kvack.org>; Tue,  2 Feb 2016 17:51:43 -0500 (EST)
Received: by mail-pf0-f176.google.com with SMTP id 65so1817102pfd.2
        for <linux-mm@kvack.org>; Tue, 02 Feb 2016 14:51:43 -0800 (PST)
Received: from mail-pf0-x22c.google.com (mail-pf0-x22c.google.com. [2607:f8b0:400e:c00::22c])
        by mx.google.com with ESMTPS id st8si4535804pab.53.2016.02.02.14.51.42
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 02 Feb 2016 14:51:42 -0800 (PST)
Received: by mail-pf0-x22c.google.com with SMTP id w123so1864632pfb.0
        for <linux-mm@kvack.org>; Tue, 02 Feb 2016 14:51:42 -0800 (PST)
Date: Tue, 2 Feb 2016 14:51:41 -0800 (PST)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH 1/2] mm, oom: introduce oom reaper
In-Reply-To: <20160202085758.GE19910@dhcp22.suse.cz>
Message-ID: <alpine.DEB.2.10.1602021437140.9118@chino.kir.corp.google.com>
References: <1452094975-551-1-git-send-email-mhocko@kernel.org> <1452094975-551-2-git-send-email-mhocko@kernel.org> <alpine.DEB.2.10.1601271651530.17979@chino.kir.corp.google.com> <20160128214247.GD621@dhcp22.suse.cz> <alpine.DEB.2.10.1602011843250.31751@chino.kir.corp.google.com>
 <20160202085758.GE19910@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>, Linus Torvalds <torvalds@linux-foundation.org>, Oleg Nesterov <oleg@redhat.com>, Hugh Dickins <hughd@google.com>, Andrea Argangeli <andrea@kernel.org>, Rik van Riel <riel@redhat.com>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>

On Tue, 2 Feb 2016, Michal Hocko wrote:

> > Not exclude them, but I would have expected untrack_pfn().
> 
> My understanding is that vm_normal_page will do the right thing for
> those mappings - especially for CoW VM_PFNMAP which are normal pages
> AFAIU. Wrt. to untrack_pfn I was relying that the victim will eventually
> enter exit_mmap and do the remaining house keepining. Maybe I am missing
> something but untrack_pfn shouldn't lead to releasing a considerable
> amount of memory. So is this really necessary or we can wait for
> exit_mmap?
> 

I think if you move the code to mm/memory.c that you may find a greater 
opportunity to share code with the implementations there and this will 
take care of itself :)  I'm concerned about this also from a 
maintainability standpoint where a future patch might modify one 
implementation while forgetting about the other.  I think there's a great 
opportunity here for a really clean and shiny interfance that doesn't 
introduce any more complexity.

> > The problem is that this is racy and quite easy to trigger: imagine if 
> > __oom_reap_vmas() finds mm->mm_users == 0, because the memory of the 
> > victim has been freed, and then another system-wide oom condition occurs 
> > before the oom reaper's mm_to_reap has been set to NULL.
> 
> Yes I realize this is potentially racy. I just didn't consider the race
> important enough to justify task queuing in the first submission. Tetsuo
> was pushing for this already and I tried to push back for simplicity in
> the first submission. But ohh well... I will queue up a patch to do this
> on top. I plan to repost the full patchset shortly.
> 

Ok, thanks!  It should probably be dropped from -mm in the interim until 
it has some acked-by's, but I think those will come pretty quickly once 
it's refreshed if all of this is handled.

> > In this case, the oom reaper has ignored the next victim and doesn't do 
> > anything; the simple race has prevented it from zapping memory and does 
> > not reduce the livelock probability.
> > 
> > This can be solved either by queueing mm's to reap or involving the oom 
> > reaper into the oom killer synchronization itself.
> 
> as we have already discussed previously oom reaper is really tricky to
> be called from the direct OOM context. I will go with queuing. 
>  

Hmm, I wasn't referring to oom context: it would be possible without 
queueing with an mm_to_reap_lock (or cmpxchg) in the oom reaper and when 
the final mmput() is done.  Set it when the mm is ready for reaping, clear 
it when the mm is being destroyed, and test it before calling the oom 
killer.  I think we'd want to defer the oom killer until potential reaping 
could be done anyway and I don't anticipate an issue where oom_reaper 
fails to schedule.

> > I'm baffled by any reference to "memcg oom heavy loads", I don't 
> > understand this paragraph, sorry.  If a memcg is oom, we shouldn't be
> > disrupting the global runqueue by running oom_reaper at a high priority.  
> > The disruption itself is not only in first wakeup but also in how long the 
> > reaper can run and when it is rescheduled: for a lot of memory this is 
> > potentially long.  The reaper is best-effort, as the changelog indicates, 
> > and we shouldn't have a reliance on this high priority: oom kill exiting 
> > can't possibly be expected to be immediate.  This high priority should be 
> > removed so memcg oom conditions are isolated and don't affect other loads.
> 
> If this is a concern then I would be tempted to simply disable oom
> reaper for memcg oom altogether. For me it is much more important that
> the reaper, even though a best effort, is guaranteed to schedule if
> something goes terribly wrong on the machine.
> 

I don't believe the higher priority guarantees it is able to schedule any 
more than it was guaranteed to schedule before.  It will run, but it won't 
preempt other innocent processes in disjoint memcgs or cpusets.  It's not 
only a memcg issue, but it also impacts disjoint cpuset mems and mempolicy 
nodemasks.  I think it would be disappointing to leave those out.  I think 
the higher priority should simply be removed in terms of fairness.

Other than these issues, I don't see any reason why a refreshed series 
wouldn't be immediately acked.  Thanks very much for continuing to work on 
this!

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
