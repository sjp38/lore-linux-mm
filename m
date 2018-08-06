Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f70.google.com (mail-wm0-f70.google.com [74.125.82.70])
	by kanga.kvack.org (Postfix) with ESMTP id B1AE66B000C
	for <linux-mm@kvack.org>; Mon,  6 Aug 2018 16:51:25 -0400 (EDT)
Received: by mail-wm0-f70.google.com with SMTP id s18-v6so10019388wmh.0
        for <linux-mm@kvack.org>; Mon, 06 Aug 2018 13:51:25 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id v21-v6si11079548wrc.122.2018.08.06.13.51.23
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 06 Aug 2018 13:51:23 -0700 (PDT)
Date: Mon, 6 Aug 2018 22:51:21 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH 4/4] mm, oom: Fix unnecessary killing of additional
 processes.
Message-ID: <20180806205121.GM10003@dhcp22.suse.cz>
References: <1533389386-3501-1-git-send-email-penguin-kernel@I-love.SAKURA.ne.jp>
 <1533389386-3501-4-git-send-email-penguin-kernel@I-love.SAKURA.ne.jp>
 <20180806134550.GO19540@dhcp22.suse.cz>
 <alpine.DEB.2.21.1808061315220.43071@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.21.1808061315220.43071@chino.kir.corp.google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>, linux-mm@kvack.org, Roman Gushchin <guro@fb.com>

On Mon 06-08-18 13:19:18, David Rientjes wrote:
> On Mon, 6 Aug 2018, Michal Hocko wrote:
> 
> > On Sat 04-08-18 22:29:46, Tetsuo Handa wrote:
> > > David Rientjes is complaining about current behavior that the OOM killer
> > > selects next OOM victim as soon as MMF_OOM_SKIP is set even if
> > > __oom_reap_task_mm() returned without any progress.
> > > 
> > > To address this problem, this patch adds a timeout with whether the OOM
> > > score of an OOM victim's memory is decreasing over time as a feedback,
> > > after MMF_OOM_SKIP is set by the OOM reaper or exit_mmap().
> > 
> > I still hate any feedback mechanism based on time. We have seen that
> > these paths are completely non-deterministic time wise that building
> > any heuristic on top of it just sounds wrong.
> > 
> > Yes we have problems that the oom reaper doesn't handle all types of
> > memory yet. We should cover most of reasonably large memory types by
> > now. There is still mlock to take care of and that would be much
> > preferable to work on ragardless the retry mechanism becuase this work
> > will simply not handle that case either.
> > 
> > So I do not really see this would be an improvement. I still stand by my
> > argument that any retry mechanism should be based on the direct feedback
> > from the oom reaper rather than some magic "this took that long without
> > any progress".
> > 
> 
> At the risk of continually repeating the same statement, the oom reaper 
> cannot provide the direct feedback for all possible memory freeing.  
> Waking up periodically and finding mm->mmap_sem contended is one problem, 
> but the other problem that I've already shown is the unnecessary oom 
> killing of additional processes while a thread has already reached 
> exit_mmap().  The oom reaper cannot free page tables which is problematic 
> for malloc implementations such as tcmalloc that do not release virtual 
> memory. 

But once we know that the exit path is past the point of blocking we can
have MMF_OOM_SKIP handover from the oom_reaper to the exit path. So the
oom_reaper doesn't hide the current victim too early and we can safely
wait for the exit path to reclaim the rest. So there is a feedback
channel. I would even do not mind to poll for that state few times -
similar to polling for the mmap_sem. But it would still be some feedback
rather than a certain amount of time has passed since the last check.

> For binaries with heaps that are very large, sometimes over 
> 100GB, this is a substantial amount of memory and we have seen unnecessary 
> oom killing before and during free_pgtables() of the victim.  This is long 
> after the oom reaper would operate on any mm.

Well, a specific example would be really helpful. I have to admit I
haven't seen many oom victim without any memory mapped to the address
space. I can construct pathological corner cases of course but well, is
this a reasonable usecase to base the implementation on? A malicious user
can usually find other ways how to hurt the system and that's why it
should be contained.
-- 
Michal Hocko
SUSE Labs
