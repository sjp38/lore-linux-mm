Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f198.google.com (mail-wr0-f198.google.com [209.85.128.198])
	by kanga.kvack.org (Postfix) with ESMTP id 729D56B0005
	for <linux-mm@kvack.org>; Tue,  5 Jun 2018 04:57:12 -0400 (EDT)
Received: by mail-wr0-f198.google.com with SMTP id j14-v6so1011899wro.7
        for <linux-mm@kvack.org>; Tue, 05 Jun 2018 01:57:12 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id y20-v6si2437681edm.267.2018.06.05.01.57.10
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 05 Jun 2018 01:57:10 -0700 (PDT)
Date: Tue, 5 Jun 2018 10:57:07 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [rfc patch] mm, oom: fix unnecessary killing of additional
 processes
Message-ID: <20180605085707.GV19202@dhcp22.suse.cz>
References: <alpine.DEB.2.21.1805241422070.182300@chino.kir.corp.google.com>
 <20180525072636.GE11881@dhcp22.suse.cz>
 <alpine.DEB.2.21.1805251227380.158701@chino.kir.corp.google.com>
 <20180528081345.GD1517@dhcp22.suse.cz>
 <alpine.DEB.2.21.1805301357100.150424@chino.kir.corp.google.com>
 <20180531063212.GF15278@dhcp22.suse.cz>
 <alpine.DEB.2.21.1805311400260.74563@chino.kir.corp.google.com>
 <20180601074642.GW15278@dhcp22.suse.cz>
 <alpine.DEB.2.21.1806042100200.71129@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.21.1806042100200.71129@chino.kir.corp.google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Mon 04-06-18 21:25:39, David Rientjes wrote:
> On Fri, 1 Jun 2018, Michal Hocko wrote:
> 
> > > We've discussed the mm 
> > > having a single blockable mmu notifier.  Regardless of how we arrive at 
> > > the point where the oom reaper can't free memory, which could be any of 
> > > those three cases, if (1) the original victim is sufficiently large that 
> > > follow-up oom kills would become unnecessary and (2) other threads 
> > > allocate/charge before the oom victim reaches exit_mmap(), this occurs.
> > > 
> > > We have examples of cases where oom reaping was successful, but the rss 
> > > numbers in the kernel log are very similar to when it was oom killed and 
> > > the process is known not to mlock, the reason is because the oom reaper 
> > > could free very little memory due to blockable mmu notifiers.
> > 
> > Please be more specific. Which notifiers these were. Blockable notifiers
> > are a PITA and we should be addressing them. That requiers identifying
> > them first.
> > 
> 
> The most common offender seems to be ib_umem_notifier, but I have also 
> heard of possible occurrences for mv_invl_range_start() for xen, but that 
> would need more investigation.  The rather new invalidate_range callback 
> for hmm mirroring could also be problematic.  Any mmu_notifier without 
> MMU_INVALIDATE_DOES_NOT_BLOCK causes the mm to immediately be disregarded.  

Yes, this is unfortunate and it was meant as a stop gap quick fix with a
long term vision to be fixed properly. I am pretty sure that we can do
much better here. Teach mmu_notifier_invalidate_range_start to get a
non-block flag and back out on ranges that would block. I am pretty sure
that notifiers can be targeted a lot and so we can still process some
vmas at least.

> For this reason, we see testing harnesses often oom killed immediately 
> after running a unittest that stresses reclaim or compaction by inducing a 
> system-wide oom condition.  The harness spawns the unittest which spawns 
> an antagonist memory hog that is intended to be oom killed.  When memory 
> is mlocked or there are a large number of threads faulting memory for the 
> antagonist, the unittest and the harness itself get oom killed because the 
> oom reaper sets MMF_OOM_SKIP; this ends up happening a lot on powerpc.  
> The memory hog has mm->mmap_sem readers queued ahead of a writer that is 
> doing mmap() so the oom reaper can't grab the sem quickly enough.

How come the writer doesn't back off. mmap paths should be taking an
exclusive mmap sem in killable sleep so it should back off. Or is the
holder of the lock deep inside mmap path doing something else and not
backing out with the exclusive lock held?
 
[...]

> > As I've already said. I will nack any timeout based solution until we
> > address all particular problems and still see more to come. Here we have
> > a clear goal. Address mlocked pages and identify mmu notifier offenders.
> 
> I cannot fix all mmu notifiers to not block, I can't fix the configuration 
> to allow direct compaction for thp allocations and a large number of 
> concurrent faulters, and I cannot fix userspace mlocking a lot of memory.  
> It's worthwhile to work in that direction, but it will never be 100% 
> possible to avoid.  We must have a solution that prevents innocent 
> processes from consistently being oom killed completely unnecessarily.

None of the above has been attempted and shown not worth doing. The oom
even should be a rare thing to happen so I absolutely do not see any
reason to rush any misdesigned fix to be done right now.

-- 
Michal Hocko
SUSE Labs
