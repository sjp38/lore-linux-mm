Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg1-f199.google.com (mail-pg1-f199.google.com [209.85.215.199])
	by kanga.kvack.org (Postfix) with ESMTP id A061D6B0266
	for <linux-mm@kvack.org>; Thu,  9 Aug 2018 16:16:28 -0400 (EDT)
Received: by mail-pg1-f199.google.com with SMTP id a26-v6so3272671pgw.7
        for <linux-mm@kvack.org>; Thu, 09 Aug 2018 13:16:28 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id v4-v6sor1915532pgi.231.2018.08.09.13.16.27
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 09 Aug 2018 13:16:27 -0700 (PDT)
Date: Thu, 9 Aug 2018 13:16:25 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH 4/4] mm, oom: Fix unnecessary killing of additional
 processes.
In-Reply-To: <20180806205121.GM10003@dhcp22.suse.cz>
Message-ID: <alpine.DEB.2.21.1808091311030.244858@chino.kir.corp.google.com>
References: <1533389386-3501-1-git-send-email-penguin-kernel@I-love.SAKURA.ne.jp> <1533389386-3501-4-git-send-email-penguin-kernel@I-love.SAKURA.ne.jp> <20180806134550.GO19540@dhcp22.suse.cz> <alpine.DEB.2.21.1808061315220.43071@chino.kir.corp.google.com>
 <20180806205121.GM10003@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>, linux-mm@kvack.org, Roman Gushchin <guro@fb.com>

On Mon, 6 Aug 2018, Michal Hocko wrote:

> > At the risk of continually repeating the same statement, the oom reaper 
> > cannot provide the direct feedback for all possible memory freeing.  
> > Waking up periodically and finding mm->mmap_sem contended is one problem, 
> > but the other problem that I've already shown is the unnecessary oom 
> > killing of additional processes while a thread has already reached 
> > exit_mmap().  The oom reaper cannot free page tables which is problematic 
> > for malloc implementations such as tcmalloc that do not release virtual 
> > memory. 
> 
> But once we know that the exit path is past the point of blocking we can
> have MMF_OOM_SKIP handover from the oom_reaper to the exit path. So the
> oom_reaper doesn't hide the current victim too early and we can safely
> wait for the exit path to reclaim the rest. So there is a feedback
> channel. I would even do not mind to poll for that state few times -
> similar to polling for the mmap_sem. But it would still be some feedback
> rather than a certain amount of time has passed since the last check.
> 

Yes, of course, it would be easy to rely on exit_mmap() to set 
MMF_OOM_SKIP itself and have the oom reaper drop the task from its list 
when we are assured of forward progress.  What polling are you proposing 
other than a timeout based mechanism to do this?

We could set a MMF_EXIT_MMAP in exit_mmap() to specify that it will 
complete free_pgtables() for that mm.  The problem is the same: when does 
the oom reaper decide to set MMF_OOM_SKIP because MMF_EXIT_MMAP has not 
been set in a timely manner?

If this is an argument that the oom reaper should loop checking for 
MMF_EXIT_MMAP and doing schedule_timeout(1) a set number of times rather 
than just setting the jiffies in the mm itself, that's just implementing 
the same thing and doing so in a way where the oom reaper stalls operating 
on a single mm rather than round-robin iterating over mm's in my patch.
