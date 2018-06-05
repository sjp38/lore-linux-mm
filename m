Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f69.google.com (mail-pg0-f69.google.com [74.125.83.69])
	by kanga.kvack.org (Postfix) with ESMTP id B8DB46B0005
	for <linux-mm@kvack.org>; Tue,  5 Jun 2018 00:25:43 -0400 (EDT)
Received: by mail-pg0-f69.google.com with SMTP id k13-v6so395961pgr.11
        for <linux-mm@kvack.org>; Mon, 04 Jun 2018 21:25:43 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id v1-v6sor1906663pgt.251.2018.06.04.21.25.41
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 04 Jun 2018 21:25:41 -0700 (PDT)
Date: Mon, 4 Jun 2018 21:25:39 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [rfc patch] mm, oom: fix unnecessary killing of additional
 processes
In-Reply-To: <20180601074642.GW15278@dhcp22.suse.cz>
Message-ID: <alpine.DEB.2.21.1806042100200.71129@chino.kir.corp.google.com>
References: <alpine.DEB.2.21.1805241422070.182300@chino.kir.corp.google.com> <20180525072636.GE11881@dhcp22.suse.cz> <alpine.DEB.2.21.1805251227380.158701@chino.kir.corp.google.com> <20180528081345.GD1517@dhcp22.suse.cz> <alpine.DEB.2.21.1805301357100.150424@chino.kir.corp.google.com>
 <20180531063212.GF15278@dhcp22.suse.cz> <alpine.DEB.2.21.1805311400260.74563@chino.kir.corp.google.com> <20180601074642.GW15278@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Fri, 1 Jun 2018, Michal Hocko wrote:

> > We've discussed the mm 
> > having a single blockable mmu notifier.  Regardless of how we arrive at 
> > the point where the oom reaper can't free memory, which could be any of 
> > those three cases, if (1) the original victim is sufficiently large that 
> > follow-up oom kills would become unnecessary and (2) other threads 
> > allocate/charge before the oom victim reaches exit_mmap(), this occurs.
> > 
> > We have examples of cases where oom reaping was successful, but the rss 
> > numbers in the kernel log are very similar to when it was oom killed and 
> > the process is known not to mlock, the reason is because the oom reaper 
> > could free very little memory due to blockable mmu notifiers.
> 
> Please be more specific. Which notifiers these were. Blockable notifiers
> are a PITA and we should be addressing them. That requiers identifying
> them first.
> 

The most common offender seems to be ib_umem_notifier, but I have also 
heard of possible occurrences for mv_invl_range_start() for xen, but that 
would need more investigation.  The rather new invalidate_range callback 
for hmm mirroring could also be problematic.  Any mmu_notifier without 
MMU_INVALIDATE_DOES_NOT_BLOCK causes the mm to immediately be disregarded.  
For this reason, we see testing harnesses often oom killed immediately 
after running a unittest that stresses reclaim or compaction by inducing a 
system-wide oom condition.  The harness spawns the unittest which spawns 
an antagonist memory hog that is intended to be oom killed.  When memory 
is mlocked or there are a large number of threads faulting memory for the 
antagonist, the unittest and the harness itself get oom killed because the 
oom reaper sets MMF_OOM_SKIP; this ends up happening a lot on powerpc.  
The memory hog has mm->mmap_sem readers queued ahead of a writer that is 
doing mmap() so the oom reaper can't grab the sem quickly enough.

I agree that blockable mmu notifiers are a pain, but until such time as 
all can implicitly be MMU_INVALIDATE_DOES_NOT_BLOCK, the oom reaper can 
free all mlocked memory, and the oom reaper waits long enough to grab 
mm->mmap_sem for stalled mm->mmap_sem readers, we need a solution that 
won't oom kill everything running on the system.  I have doubts we'll ever 
reach a point where the oom reaper can do the equivalent of exit_mmap(), 
but it's possible to help solve the immediate issue of all oom kills 
killing many innocent processes while working in a direction to make oom 
reaping more successful at freeing memory.

> > The current implementation is a timeout based solution for mmap_sem, it 
> > just has the oom reaper spinning trying to grab the sem and eventually 
> > gives up.  This patch allows it to currently work on other mm's and 
> > detects the timeout in a different way, with jiffies instead of an 
> > iterator.
> 
> And I argue that anything timeout based is just broken by design. Trying
> n times will at least give you a consistent behavior.

It's not consistent, we see wildly inconsistent results especially on 
power because it depends on the number of queued readers of mm->mmap_sem 
ahead of a writer until such time that a thread doing mmap() can grab it, 
drop it, and allow the oom reaper to grab it for read.  It's so 
inconsistent that we can see the oom reaper successfully grab the sem for 
an oom killed memory hog with 128 faulting threads, and see it fail with 4 
faulting threads.

> Retrying on mmap
> sem makes sense because the lock might be taken for a short time.

It isn't a function of how long mmap_sem is taken for write, it's a 
function of how many readers are ahead of the queued writer.  We don't run 
with thp defrag set to "always" under standard configurations, but users 
of MADV_HUGEPAGE or configs where defrag is set to "always" can 
consistently cause any number of additional processes to be oom killed 
unnecessarily because the readers are performing compaction and the writer 
is queued behind it.

> > I'd love a solution where we can reliably detect an oom livelock and oom 
> > kill additional processes but only after the original victim has had a 
> > chance to do exit_mmap() without a timeout, but I don't see one being 
> > offered.  Given Tetsuo has seen issues with this in the past and suggested 
> > a similar proposal means we are not the only ones feeling pain from this.
> 
> Tetsuo is doing an artificial stress test which doesn't resemble any
> reasonable workload.

Tetsuo's test cases caught the CVE on powerpc which could trivially 
panic the system if configured to panic on any oops and required a 
security fix because it made it easy for any user doing a large mlock.  
His test case here is trivial to reproduce on powerpc and causes several 
additional processes to be oom killed.  It's not artificial, I see many 
test harnesses killed *nightly* because a memory hog is faulting with a 
large number of threads and two or three other threads are doing mmap().  
No mlock.

> > Making mlocked pages reapable would only solve the most trivial reproducer 
> > of this.  Unless the oom reaper can guarantee that it will never block and 
> > can free all memory that exit_mmap() can free, we need to ensure that a 
> > victim has a chance to reach the exit path on its own before killing every 
> > other process on the system.
> > 
> > I'll fix the issue I identified with doing list_add_tail() rather than 
> > list_add(), fix up the commit message per Tetsuo to identify the other 
> > possible ways this can occur other than mlock, remove the rfc tag, and 
> > repost.
> 
> As I've already said. I will nack any timeout based solution until we
> address all particular problems and still see more to come. Here we have
> a clear goal. Address mlocked pages and identify mmu notifier offenders.

I cannot fix all mmu notifiers to not block, I can't fix the configuration 
to allow direct compaction for thp allocations and a large number of 
concurrent faulters, and I cannot fix userspace mlocking a lot of memory.  
It's worthwhile to work in that direction, but it will never be 100% 
possible to avoid.  We must have a solution that prevents innocent 
processes from consistently being oom killed completely unnecessarily.
