Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f197.google.com (mail-wr0-f197.google.com [209.85.128.197])
	by kanga.kvack.org (Postfix) with ESMTP id 185826B0292
	for <linux-mm@kvack.org>; Fri, 23 Jun 2017 08:45:56 -0400 (EDT)
Received: by mail-wr0-f197.google.com with SMTP id 23so6248896wry.4
        for <linux-mm@kvack.org>; Fri, 23 Jun 2017 05:45:56 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id j17si4230975wrc.8.2017.06.23.05.45.54
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Fri, 23 Jun 2017 05:45:54 -0700 (PDT)
Date: Fri, 23 Jun 2017 14:45:51 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH] mm,oom_kill: Close race window of needlessly selecting
 new victims.
Message-ID: <20170623124550.GX5308@dhcp22.suse.cz>
References: <201706210217.v5L2HAZc081021@www262.sakura.ne.jp>
 <alpine.DEB.2.10.1706211325340.101895@chino.kir.corp.google.com>
 <201706220053.v5M0rmOU078764@www262.sakura.ne.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <201706220053.v5M0rmOU078764@www262.sakura.ne.jp>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>
Cc: David Rientjes <rientjes@google.com>, akpm@linux-foundation.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Thu 22-06-17 09:53:48, Tetsuo Handa wrote:
> David Rientjes wrote:
> > On Wed, 21 Jun 2017, Tetsuo Handa wrote:
> > > Umm... So, you are pointing out that select_bad_process() aborts based on
> > > TIF_MEMDIE or MMF_OOM_SKIP is broken because victim threads can be removed
> > >  from global task list or cgroup's task list. Then, the OOM killer will have to
> > > wait until all mm_struct of interested OOM domain (system wide or some cgroup)
> > > is reaped by the OOM reaper. Simplest way is to wait until all mm_struct are
> > > reaped by the OOM reaper, for currently we are not tracking which memory cgroup
> > > each mm_struct belongs to, are we? But that can cause needless delay when
> > > multiple OOM events occurred in different OOM domains. Do we want to (and can we)
> > > make it possible to tell whether each mm_struct queued to the OOM reaper's list
> > > belongs to the thread calling out_of_memory() ?
> > > 
> > 
> > I am saying that taking mmget() in mark_oom_victim() and then only 
> > dropping it with mmput_async() after it can grab mm->mmap_sem, which the 
> > exit path itself takes, or the oom reaper happens to schedule, causes 
> > __mmput() to be called much later and thus we remove the process from the 
> > tasklist or call cgroup_exit() earlier than the memory can be unmapped 
> > with your patch.  As a result, subsequent calls to the oom killer kills 
> > everything before the original victim's mm can undergo __mmput() because 
> > the oom reaper still holds the reference.
> 
> Here is "wait for all mm_struct are reaped by the OOM reaper" version.

Well, this is getting more and more hairy. I think we should explore the
possibility of oom_reaper vs. exit_mmap working together after all.

Yes, I've said that a solution fully withing the oom proper would be
preferable but this just grows into complex hairy mess. Maybe we just
find out that oom_reaper vs. exit_mmap is just not feasible and we will
reconsider this approach in the end but let's try a clean solution
first. As I've said there is nothing fundamentally hard about parallel
unmapping MADV_DONTNEED does that already. We just have to iron out
those tiny details.
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
