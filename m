Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id E845F6B0005
	for <linux-mm@kvack.org>; Thu, 31 May 2018 17:16:38 -0400 (EDT)
Received: by mail-pf0-f200.google.com with SMTP id b25-v6so13271463pfn.10
        for <linux-mm@kvack.org>; Thu, 31 May 2018 14:16:38 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id p11-v6sor3018471pgr.127.2018.05.31.14.16.35
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 31 May 2018 14:16:36 -0700 (PDT)
Date: Thu, 31 May 2018 14:16:34 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [rfc patch] mm, oom: fix unnecessary killing of additional
 processes
In-Reply-To: <20180531063212.GF15278@dhcp22.suse.cz>
Message-ID: <alpine.DEB.2.21.1805311400260.74563@chino.kir.corp.google.com>
References: <alpine.DEB.2.21.1805241422070.182300@chino.kir.corp.google.com> <20180525072636.GE11881@dhcp22.suse.cz> <alpine.DEB.2.21.1805251227380.158701@chino.kir.corp.google.com> <20180528081345.GD1517@dhcp22.suse.cz> <alpine.DEB.2.21.1805301357100.150424@chino.kir.corp.google.com>
 <20180531063212.GF15278@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Thu, 31 May 2018, Michal Hocko wrote:

> > It's not a random timeout, it's sufficiently long such that we don't oom 
> > kill several processes needlessly in the very rare case where oom livelock 
> > would actually prevent the original victim from exiting.  The oom reaper 
> > processing an mm, finding everything to be mlocked, and immediately 
> > MMF_OOM_SKIP is inappropriate.  This is rather trivial to reproduce for a 
> > large memory hogging process that mlocks all of its memory; we 
> > consistently see spurious and unnecessary oom kills simply because the oom 
> > reaper has set MMF_OOM_SKIP very early.
> 
> It takes quite some additional steps for admin to allow a large amount
> of mlocked memory and such an application should be really careful to
> not consume too much memory. So how come this is something you see that
> consistently? Is this some sort of bug or an unfortunate workload side
> effect? I am asking this because I really want to see how relevant this
> really is.
> 

The bug is that the oom reaper sets MMF_OOM_SKIP almost immediately after 
the victim has been chosen for oom kill and we get follow-up oom kills, 
not that the process is able to mlock a large amount of memory.  Mlock 
here is only being discussed as a single example.  Tetsuo has brought up 
the example of all shared file-backed memory.  We've discussed the mm 
having a single blockable mmu notifier.  Regardless of how we arrive at 
the point where the oom reaper can't free memory, which could be any of 
those three cases, if (1) the original victim is sufficiently large that 
follow-up oom kills would become unnecessary and (2) other threads 
allocate/charge before the oom victim reaches exit_mmap(), this occurs.

We have examples of cases where oom reaping was successful, but the rss 
numbers in the kernel log are very similar to when it was oom killed and 
the process is known not to mlock, the reason is because the oom reaper 
could free very little memory due to blockable mmu notifiers.

> But the waiting periods just turn out to be a really poor design. There
> will be no good timeout to fit for everybody. We can do better and as
> long as this is the case the timeout based solution should be really
> rejected. It is a shortcut that doesn't really solve the underlying
> problem.
> 

The current implementation is a timeout based solution for mmap_sem, it 
just has the oom reaper spinning trying to grab the sem and eventually 
gives up.  This patch allows it to currently work on other mm's and 
detects the timeout in a different way, with jiffies instead of an 
iterator.

I'd love a solution where we can reliably detect an oom livelock and oom 
kill additional processes but only after the original victim has had a 
chance to do exit_mmap() without a timeout, but I don't see one being 
offered.  Given Tetsuo has seen issues with this in the past and suggested 
a similar proposal means we are not the only ones feeling pain from this.

> > I'm open to hearing any other suggestions that you have other than waiting 
> > some time period before MMF_OOM_SKIP gets set to solve this problem.
> 
> I've already offered one. Make mlocked pages reapable.

Making mlocked pages reapable would only solve the most trivial reproducer 
of this.  Unless the oom reaper can guarantee that it will never block and 
can free all memory that exit_mmap() can free, we need to ensure that a 
victim has a chance to reach the exit path on its own before killing every 
other process on the system.

I'll fix the issue I identified with doing list_add_tail() rather than 
list_add(), fix up the commit message per Tetsuo to identify the other 
possible ways this can occur other than mlock, remove the rfc tag, and 
repost.
