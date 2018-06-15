Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f69.google.com (mail-pg0-f69.google.com [74.125.83.69])
	by kanga.kvack.org (Postfix) with ESMTP id CF0096B0010
	for <linux-mm@kvack.org>; Fri, 15 Jun 2018 19:15:43 -0400 (EDT)
Received: by mail-pg0-f69.google.com with SMTP id v133-v6so3772258pgb.10
        for <linux-mm@kvack.org>; Fri, 15 Jun 2018 16:15:43 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id x12-v6sor2644036pfn.98.2018.06.15.16.15.41
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 15 Jun 2018 16:15:41 -0700 (PDT)
Date: Fri, 15 Jun 2018 16:15:39 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [patch] mm, oom: fix unnecessary killing of additional
 processes
In-Reply-To: <20180615065541.GA24039@dhcp22.suse.cz>
Message-ID: <alpine.DEB.2.21.1806151559360.49038@chino.kir.corp.google.com>
References: <alpine.DEB.2.21.1805241422070.182300@chino.kir.corp.google.com> <alpine.DEB.2.21.1806141339580.4543@chino.kir.corp.google.com> <20180615065541.GA24039@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Fri, 15 Jun 2018, Michal Hocko wrote:

> > Signed-off-by: David Rientjes <rientjes@google.com>
> 
> Nacked-by: Michal Hocko <mhocko@suse.com>
> as already explained elsewhere in this email thread.
> 

I don't find this to be surprising, but I'm not sure that it actually 
matters if you won't fix a regression that you introduced.  Tetsuo 
initially found this issue and presented a similar solution, so I think 
his feedback on this is more important since it would fix a problem for 
him as well.

> > ---
> >  Note: I understand there is an objection based on timeout based delays.
> >  This is currently the only possible way to avoid oom killing important
> >  processes completely unnecessarily.  If the oom reaper can someday free
> >  all memory, including mlocked memory and those mm's with blockable mmu
> >  notifiers, and is guaranteed to always be able to grab mm->mmap_sem,
> >  this can be removed.  I do not believe any such guarantee is possible
> >  and consider the massive killing of additional processes unnecessarily
> >  to be a regression introduced by the oom reaper and its very quick
> >  setting of MMF_OOM_SKIP to allow additional processes to be oom killed.
> 
> If you find oom reaper more harmful than useful I would be willing to
> ack a comman line option to disable it. Especially when you keep
> claiming that the lockups are not really happening in your environment.
> 

There's no need to disable it, we simply need to ensure that it doesn't 
set MMF_OOM_SKIP too early, which my patch does.  We also need to avoid 
setting MMF_OOM_SKIP in exit_mmap() until after all memory has been freed, 
i.e. after free_pgtables().

I'd be happy to make the this timeout configurable, however, and default 
it to perhaps one second as the blockable mmu notifier timeout in your own 
code does.  I find it somewhat sad that we'd need a sysctl for this, but 
if that will appease you and it will help to move this into -mm then we 
can do that.

> Other than that I've already pointed to a more robust solution. If you
> are reluctant to try it out I will do, but introducing a timeout is just
> papering over the real problem. Maybe we will not reach the state that
> _all_ the memory is reapable but we definitely should try to make as
> much as possible to be reapable and I do not see any fundamental
> problems in that direction.

You introduced the timeout already, I'm sure you realized yourself that 
the oom reaper sets MMF_OOM_SKIP much too early.  Trying to grab 
mm->mmap_sem 10 times in a row with HZ/10 sleeps in between is a timeout.  
If there are blockable mmu notifiers, your code puts the oom reaper to 
sleep for HZ before setting MMF_OOM_SKIP, which is a timeout.  This patch 
moves the timeout to reaching exit_mmap() where we actually free all 
memory possible and still allow for additional oom killing if there is a 
very rare oom livelock.

You haven't provided any data that suggests oom livelocking isn't a very 
rare event and that we need to respond immediately by randomly killing 
more and more processes rather than wait a bounded period of time to allow 
for forward progress to be made.  I have constantly provided data showing 
oom livelock in our fleet is extremely rare, less than 0.04% of the time.  
Yet your solution is to kill many processes so this 0.04% is fast.

The reproducer on powerpc is very simple.  Do an mmap() and mlock() the 
length.  Fork one 120MB process that does that and two 60MB processes that 
do that in a 128MB memcg.

[  402.064375] Killed process 17024 (a.out) total-vm:134080kB, anon-rss:122032kB, file-rss:1600kB
[  402.107521] Killed process 17026 (a.out) total-vm:64448kB, anon-rss:44736kB, file-rss:1600kB

Completely reproducible and completely unnecessary.  Killing two processes 
pointlessly when the first oom kill would have been successful.

Killing processes is important, optimizing for 0.04% of cases of true oom 
livelock by insisting everybody tolerate excessive oom killing is not.  If 
you have data to suggest the 0.04% is higher, please present it.  I'd be 
interested in any data you have that suggests its higher and has even 
1/1,000,000th oom occurrence rate that I have shown.

It's inappropriate to merge code that oom kills many processes 
unnecessarily when one happens to be mlocked or have blockable mmu 
notifiers or when mm->mmap_sem can't be grabbed fast enough but forward 
progress is actually being made.  It's a regression, and it impacts real 
users.  Insisting that we fix the problem you introduced by making all mmu 
notifiers unblockable and mlocked memory can always be reaped and 
mm->mmap_sem can always be grabbed within a second is irresponsible.
