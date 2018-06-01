Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f197.google.com (mail-wr0-f197.google.com [209.85.128.197])
	by kanga.kvack.org (Postfix) with ESMTP id 978606B0005
	for <linux-mm@kvack.org>; Fri,  1 Jun 2018 03:46:48 -0400 (EDT)
Received: by mail-wr0-f197.google.com with SMTP id k18-v6so2254493wrn.8
        for <linux-mm@kvack.org>; Fri, 01 Jun 2018 00:46:48 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id i55-v6si3538321eda.40.2018.06.01.00.46.45
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Fri, 01 Jun 2018 00:46:45 -0700 (PDT)
Date: Fri, 1 Jun 2018 09:46:42 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [rfc patch] mm, oom: fix unnecessary killing of additional
 processes
Message-ID: <20180601074642.GW15278@dhcp22.suse.cz>
References: <alpine.DEB.2.21.1805241422070.182300@chino.kir.corp.google.com>
 <20180525072636.GE11881@dhcp22.suse.cz>
 <alpine.DEB.2.21.1805251227380.158701@chino.kir.corp.google.com>
 <20180528081345.GD1517@dhcp22.suse.cz>
 <alpine.DEB.2.21.1805301357100.150424@chino.kir.corp.google.com>
 <20180531063212.GF15278@dhcp22.suse.cz>
 <alpine.DEB.2.21.1805311400260.74563@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.21.1805311400260.74563@chino.kir.corp.google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Thu 31-05-18 14:16:34, David Rientjes wrote:
> On Thu, 31 May 2018, Michal Hocko wrote:
> 
> > > It's not a random timeout, it's sufficiently long such that we don't oom 
> > > kill several processes needlessly in the very rare case where oom livelock 
> > > would actually prevent the original victim from exiting.  The oom reaper 
> > > processing an mm, finding everything to be mlocked, and immediately 
> > > MMF_OOM_SKIP is inappropriate.  This is rather trivial to reproduce for a 
> > > large memory hogging process that mlocks all of its memory; we 
> > > consistently see spurious and unnecessary oom kills simply because the oom 
> > > reaper has set MMF_OOM_SKIP very early.
> > 
> > It takes quite some additional steps for admin to allow a large amount
> > of mlocked memory and such an application should be really careful to
> > not consume too much memory. So how come this is something you see that
> > consistently? Is this some sort of bug or an unfortunate workload side
> > effect? I am asking this because I really want to see how relevant this
> > really is.
> > 
> 
> The bug is that the oom reaper sets MMF_OOM_SKIP almost immediately after 
> the victim has been chosen for oom kill and we get follow-up oom kills, 
> not that the process is able to mlock a large amount of memory.  Mlock 
> here is only being discussed as a single example.  Tetsuo has brought up 
> the example of all shared file-backed memory.

How is such a case even possible? File backed memory is reclaimable and
as such should be gone by the time we hit the OOM killer. If that is not
the case then I fail how wait slightly longer helps anything.

> We've discussed the mm 
> having a single blockable mmu notifier.  Regardless of how we arrive at 
> the point where the oom reaper can't free memory, which could be any of 
> those three cases, if (1) the original victim is sufficiently large that 
> follow-up oom kills would become unnecessary and (2) other threads 
> allocate/charge before the oom victim reaches exit_mmap(), this occurs.
> 
> We have examples of cases where oom reaping was successful, but the rss 
> numbers in the kernel log are very similar to when it was oom killed and 
> the process is known not to mlock, the reason is because the oom reaper 
> could free very little memory due to blockable mmu notifiers.

Please be more specific. Which notifiers these were. Blockable notifiers
are a PITA and we should be addressing them. That requiers identifying
them first.

> > But the waiting periods just turn out to be a really poor design. There
> > will be no good timeout to fit for everybody. We can do better and as
> > long as this is the case the timeout based solution should be really
> > rejected. It is a shortcut that doesn't really solve the underlying
> > problem.
> > 
> 
> The current implementation is a timeout based solution for mmap_sem, it 
> just has the oom reaper spinning trying to grab the sem and eventually 
> gives up.  This patch allows it to currently work on other mm's and 
> detects the timeout in a different way, with jiffies instead of an 
> iterator.

And I argue that anything timeout based is just broken by design. Trying
n times will at least give you a consistent behavior. Retrying on mmap
sem makes sense because the lock might be taken for a short time.
Retrying on a memory oom reaper doesn't reclaim is just pointless
waiting for somebody else doing the work. See the difference?

> I'd love a solution where we can reliably detect an oom livelock and oom 
> kill additional processes but only after the original victim has had a 
> chance to do exit_mmap() without a timeout, but I don't see one being 
> offered.  Given Tetsuo has seen issues with this in the past and suggested 
> a similar proposal means we are not the only ones feeling pain from this.

Tetsuo is doing an artificial stress test which doesn't resemble any
reasonable workload. This is good to catch different corner cases but
nothing even close to base any design on. I will definitely nack any
attempt to add a timeout based solution based on such a non-realistic
tests. If we have realistic workloads then try to address them and
resort to any timeout or other hacks as the last option.
 
> > > I'm open to hearing any other suggestions that you have other than waiting 
> > > some time period before MMF_OOM_SKIP gets set to solve this problem.
> > 
> > I've already offered one. Make mlocked pages reapable.
> 
> Making mlocked pages reapable would only solve the most trivial reproducer 
> of this.  Unless the oom reaper can guarantee that it will never block and 
> can free all memory that exit_mmap() can free, we need to ensure that a 
> victim has a chance to reach the exit path on its own before killing every 
> other process on the system.
> 
> I'll fix the issue I identified with doing list_add_tail() rather than 
> list_add(), fix up the commit message per Tetsuo to identify the other 
> possible ways this can occur other than mlock, remove the rfc tag, and 
> repost.

As I've already said. I will nack any timeout based solution until we
address all particular problems and still see more to come. Here we have
a clear goal. Address mlocked pages and identify mmu notifier offenders.
-- 
Michal Hocko
SUSE Labs
