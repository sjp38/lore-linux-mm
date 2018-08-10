Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f69.google.com (mail-ed1-f69.google.com [209.85.208.69])
	by kanga.kvack.org (Postfix) with ESMTP id E2F7D6B0003
	for <linux-mm@kvack.org>; Fri, 10 Aug 2018 05:07:38 -0400 (EDT)
Received: by mail-ed1-f69.google.com with SMTP id h26-v6so3072799eds.14
        for <linux-mm@kvack.org>; Fri, 10 Aug 2018 02:07:38 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id o31-v6si1229930edc.358.2018.08.10.02.07.36
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 10 Aug 2018 02:07:37 -0700 (PDT)
Date: Fri, 10 Aug 2018 11:07:35 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH 4/4] mm, oom: Fix unnecessary killing of additional
 processes.
Message-ID: <20180810090735.GY1644@dhcp22.suse.cz>
References: <1533389386-3501-1-git-send-email-penguin-kernel@I-love.SAKURA.ne.jp>
 <1533389386-3501-4-git-send-email-penguin-kernel@I-love.SAKURA.ne.jp>
 <20180806134550.GO19540@dhcp22.suse.cz>
 <alpine.DEB.2.21.1808061315220.43071@chino.kir.corp.google.com>
 <20180806205121.GM10003@dhcp22.suse.cz>
 <alpine.DEB.2.21.1808091311030.244858@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.21.1808091311030.244858@chino.kir.corp.google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>, linux-mm@kvack.org, Roman Gushchin <guro@fb.com>

On Thu 09-08-18 13:16:25, David Rientjes wrote:
> On Mon, 6 Aug 2018, Michal Hocko wrote:
> 
> > > At the risk of continually repeating the same statement, the oom reaper 
> > > cannot provide the direct feedback for all possible memory freeing.  
> > > Waking up periodically and finding mm->mmap_sem contended is one problem, 
> > > but the other problem that I've already shown is the unnecessary oom 
> > > killing of additional processes while a thread has already reached 
> > > exit_mmap().  The oom reaper cannot free page tables which is problematic 
> > > for malloc implementations such as tcmalloc that do not release virtual 
> > > memory. 
> > 
> > But once we know that the exit path is past the point of blocking we can
> > have MMF_OOM_SKIP handover from the oom_reaper to the exit path. So the
> > oom_reaper doesn't hide the current victim too early and we can safely
> > wait for the exit path to reclaim the rest. So there is a feedback
> > channel. I would even do not mind to poll for that state few times -
> > similar to polling for the mmap_sem. But it would still be some feedback
> > rather than a certain amount of time has passed since the last check.
> > 
> 
> Yes, of course, it would be easy to rely on exit_mmap() to set 
> MMF_OOM_SKIP itself and have the oom reaper drop the task from its list 
> when we are assured of forward progress.  What polling are you proposing 
> other than a timeout based mechanism to do this?

I was thinking about doing something like the following
- oom_reaper checks the amount of victim's memory after it is done with
  reaping (e.g. by calling oom_badness before and after). If it wasn't able to
  reclaim much then return false and keep retrying with the existing
  mechanism
- once a flag (e.g. MMF_OOM_MMAP) is set it bails out and won't set the
  MMF_OOM_SKIP flag.

> We could set a MMF_EXIT_MMAP in exit_mmap() to specify that it will 
> complete free_pgtables() for that mm.  The problem is the same: when does 
> the oom reaper decide to set MMF_OOM_SKIP because MMF_EXIT_MMAP has not 
> been set in a timely manner?

reuse the current retry policy which is the number of attempts rather
than any timeout.

> If this is an argument that the oom reaper should loop checking for 
> MMF_EXIT_MMAP and doing schedule_timeout(1) a set number of times rather 
> than just setting the jiffies in the mm itself, that's just implementing 
> the same thing and doing so in a way where the oom reaper stalls operating 
> on a single mm rather than round-robin iterating over mm's in my patch.

I've said earlier that I do not mind doing round robin in the oom repaer
but this is certainly more complex than what we do now and I haven't
seen any actual example where it would matter. OOM reaper is a safely
measure. Nothing should fall apart if it is slow. The primary work
should be happening from the exit path anyway.
-- 
Michal Hocko
SUSE Labs
