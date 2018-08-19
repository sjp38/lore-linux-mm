Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf1-f199.google.com (mail-pf1-f199.google.com [209.85.210.199])
	by kanga.kvack.org (Postfix) with ESMTP id 9DB006B1612
	for <linux-mm@kvack.org>; Sun, 19 Aug 2018 19:45:40 -0400 (EDT)
Received: by mail-pf1-f199.google.com with SMTP id c13-v6so6869169pfo.14
        for <linux-mm@kvack.org>; Sun, 19 Aug 2018 16:45:40 -0700 (PDT)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id j2-v6sor1929194pgf.196.2018.08.19.16.45.39
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Sun, 19 Aug 2018 16:45:39 -0700 (PDT)
Date: Sun, 19 Aug 2018 16:45:36 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH 4/4] mm, oom: Fix unnecessary killing of additional
 processes.
In-Reply-To: <20180810090735.GY1644@dhcp22.suse.cz>
Message-ID: <alpine.DEB.2.21.1808191632230.193150@chino.kir.corp.google.com>
References: <1533389386-3501-1-git-send-email-penguin-kernel@I-love.SAKURA.ne.jp> <1533389386-3501-4-git-send-email-penguin-kernel@I-love.SAKURA.ne.jp> <20180806134550.GO19540@dhcp22.suse.cz> <alpine.DEB.2.21.1808061315220.43071@chino.kir.corp.google.com>
 <20180806205121.GM10003@dhcp22.suse.cz> <alpine.DEB.2.21.1808091311030.244858@chino.kir.corp.google.com> <20180810090735.GY1644@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>, linux-mm@kvack.org, Roman Gushchin <guro@fb.com>


> > > > At the risk of continually repeating the same statement, the oom reaper 
> > > > cannot provide the direct feedback for all possible memory freeing.  
> > > > Waking up periodically and finding mm->mmap_sem contended is one problem, 
> > > > but the other problem that I've already shown is the unnecessary oom 
> > > > killing of additional processes while a thread has already reached 
> > > > exit_mmap().  The oom reaper cannot free page tables which is problematic 
> > > > for malloc implementations such as tcmalloc that do not release virtual 
> > > > memory. 
> > > 
> > > But once we know that the exit path is past the point of blocking we can
> > > have MMF_OOM_SKIP handover from the oom_reaper to the exit path. So the
> > > oom_reaper doesn't hide the current victim too early and we can safely
> > > wait for the exit path to reclaim the rest. So there is a feedback
> > > channel. I would even do not mind to poll for that state few times -
> > > similar to polling for the mmap_sem. But it would still be some feedback
> > > rather than a certain amount of time has passed since the last check.
> > > 
> > 
> > Yes, of course, it would be easy to rely on exit_mmap() to set 
> > MMF_OOM_SKIP itself and have the oom reaper drop the task from its list 
> > when we are assured of forward progress.  What polling are you proposing 
> > other than a timeout based mechanism to do this?
> 
> I was thinking about doing something like the following
> - oom_reaper checks the amount of victim's memory after it is done with
>   reaping (e.g. by calling oom_badness before and after). If it wasn't able to
>   reclaim much then return false and keep retrying with the existing
>   mechanism

I'm not sure how you define the threshold to consider what is substantial 
memory freeing.

> - once a flag (e.g. MMF_OOM_MMAP) is set it bails out and won't set the
>   MMF_OOM_SKIP flag.
> 
> > We could set a MMF_EXIT_MMAP in exit_mmap() to specify that it will 
> > complete free_pgtables() for that mm.  The problem is the same: when does 
> > the oom reaper decide to set MMF_OOM_SKIP because MMF_EXIT_MMAP has not 
> > been set in a timely manner?
> 
> reuse the current retry policy which is the number of attempts rather
> than any timeout.
> 
> > If this is an argument that the oom reaper should loop checking for 
> > MMF_EXIT_MMAP and doing schedule_timeout(1) a set number of times rather 
> > than just setting the jiffies in the mm itself, that's just implementing 
> > the same thing and doing so in a way where the oom reaper stalls operating 
> > on a single mm rather than round-robin iterating over mm's in my patch.
> 
> I've said earlier that I do not mind doing round robin in the oom repaer
> but this is certainly more complex than what we do now and I haven't
> seen any actual example where it would matter. OOM reaper is a safely
> measure. Nothing should fall apart if it is slow. The primary work
> should be happening from the exit path anyway.

The oom reaper will always be unable to free some memory, such as page 
tables.  If it can't grab mm->mmap_sem in a reasonable amount of time, it 
also can give up early.  The munlock() case is another example.  We 
experience unnecessary oom killing during free_pgtables() where the 
single-threaded exit_mmap() is freeing an enormous amount of page tables 
(usually a malloc implementation such as tcmalloc that does not free 
virtual memory) and other processes are faulting faster than we can free.  
It's a combination of a multiprocessor system and a lot of virtual memory 
from the original victim.  This is the same case as being unable to 
munlock quickly enough in exit_mmap() to free the memory.

We must wait until free_pgtables() completes in exit_mmap() before killing 
additional processes in the large majority (99.96% of cases from my data) 
of instances where oom livelock does not occur.  In the remainder of 
situations, livelock has been prevented by what the oom reaper has been 
able to free.  We can, of course, not do free_pgtables() from the oom 
reaper.  So my approach was to allow for a reasonable amount of time for 
the victim to free a lot of memory before declaring that additional 
processes must be oom killed.  It would be functionally similar to having 
the oom reaper retry many, many more times than 10 and having a linked 
list of mm_structs to reap.  I don't care one way or another if it's a 
timeout based solution or many, many retries that have schedule_timeout() 
that yields the same time period in the end.
