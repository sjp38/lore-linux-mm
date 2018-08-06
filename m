Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf1-f197.google.com (mail-pf1-f197.google.com [209.85.210.197])
	by kanga.kvack.org (Postfix) with ESMTP id 2F40A6B0006
	for <linux-mm@kvack.org>; Mon,  6 Aug 2018 16:19:22 -0400 (EDT)
Received: by mail-pf1-f197.google.com with SMTP id n17-v6so9112611pff.17
        for <linux-mm@kvack.org>; Mon, 06 Aug 2018 13:19:22 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id r17-v6sor3348517pge.40.2018.08.06.13.19.20
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 06 Aug 2018 13:19:20 -0700 (PDT)
Date: Mon, 6 Aug 2018 13:19:18 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH 4/4] mm, oom: Fix unnecessary killing of additional
 processes.
In-Reply-To: <20180806134550.GO19540@dhcp22.suse.cz>
Message-ID: <alpine.DEB.2.21.1808061315220.43071@chino.kir.corp.google.com>
References: <1533389386-3501-1-git-send-email-penguin-kernel@I-love.SAKURA.ne.jp> <1533389386-3501-4-git-send-email-penguin-kernel@I-love.SAKURA.ne.jp> <20180806134550.GO19540@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>, linux-mm@kvack.org, Roman Gushchin <guro@fb.com>

On Mon, 6 Aug 2018, Michal Hocko wrote:

> On Sat 04-08-18 22:29:46, Tetsuo Handa wrote:
> > David Rientjes is complaining about current behavior that the OOM killer
> > selects next OOM victim as soon as MMF_OOM_SKIP is set even if
> > __oom_reap_task_mm() returned without any progress.
> > 
> > To address this problem, this patch adds a timeout with whether the OOM
> > score of an OOM victim's memory is decreasing over time as a feedback,
> > after MMF_OOM_SKIP is set by the OOM reaper or exit_mmap().
> 
> I still hate any feedback mechanism based on time. We have seen that
> these paths are completely non-deterministic time wise that building
> any heuristic on top of it just sounds wrong.
> 
> Yes we have problems that the oom reaper doesn't handle all types of
> memory yet. We should cover most of reasonably large memory types by
> now. There is still mlock to take care of and that would be much
> preferable to work on ragardless the retry mechanism becuase this work
> will simply not handle that case either.
> 
> So I do not really see this would be an improvement. I still stand by my
> argument that any retry mechanism should be based on the direct feedback
> from the oom reaper rather than some magic "this took that long without
> any progress".
> 

At the risk of continually repeating the same statement, the oom reaper 
cannot provide the direct feedback for all possible memory freeing.  
Waking up periodically and finding mm->mmap_sem contended is one problem, 
but the other problem that I've already shown is the unnecessary oom 
killing of additional processes while a thread has already reached 
exit_mmap().  The oom reaper cannot free page tables which is problematic 
for malloc implementations such as tcmalloc that do not release virtual 
memory.  For binaries with heaps that are very large, sometimes over 
100GB, this is a substantial amount of memory and we have seen unnecessary 
oom killing before and during free_pgtables() of the victim.  This is long 
after the oom reaper would operate on any mm.
