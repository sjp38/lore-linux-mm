Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f200.google.com (mail-wr0-f200.google.com [209.85.128.200])
	by kanga.kvack.org (Postfix) with ESMTP id 2E5D66B04DF
	for <linux-mm@kvack.org>; Mon, 21 Aug 2017 08:10:26 -0400 (EDT)
Received: by mail-wr0-f200.google.com with SMTP id f8so17328866wrf.2
        for <linux-mm@kvack.org>; Mon, 21 Aug 2017 05:10:26 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id y94si9225424wrc.530.2017.08.21.05.10.24
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Mon, 21 Aug 2017 05:10:24 -0700 (PDT)
Date: Mon, 21 Aug 2017 14:10:22 +0200
From: Michal Hocko <mhocko@suse.com>
Subject: Re: [PATCH v2] mm, oom: task_will_free_mem(current) should ignore
 MMF_OOM_SKIP for once.
Message-ID: <20170821121022.GF25956@dhcp22.suse.cz>
References: <1501718104-8099-1-git-send-email-penguin-kernel@I-love.SAKURA.ne.jp>
 <201708191523.BJH90621.MHOOFFQSOLJFtV@I-love.SAKURA.ne.jp>
 <20170821084307.GB25956@dhcp22.suse.cz>
 <201708212041.GAJ05272.VOMOJOFSQLFtHF@I-love.SAKURA.ne.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <201708212041.GAJ05272.VOMOJOFSQLFtHF@I-love.SAKURA.ne.jp>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Cc: akpm@linux-foundation.org, linux-mm@kvack.org, rientjes@google.com, mjaggi@caviumnetworks.com, oleg@redhat.com, vdavydov@virtuozzo.com

On Mon 21-08-17 20:41:52, Tetsuo Handa wrote:
> Michal Hocko wrote:
> > On Sat 19-08-17 15:23:19, Tetsuo Handa wrote:
> > > Tetsuo Handa wrote at http://lkml.kernel.org/r/201708102328.ACD34352.OHFOLJMQVSFOFt@I-love.SAKURA.ne.jp :
> > > > Michal Hocko wrote:
> > > > > On Thu 10-08-17 21:10:30, Tetsuo Handa wrote:
> > > > > > Michal Hocko wrote:
> > > > > > > On Tue 08-08-17 11:14:50, Tetsuo Handa wrote:
> > > > > > > > Michal Hocko wrote:
> > > > > > > > > On Sat 05-08-17 10:02:55, Tetsuo Handa wrote:
> > > > > > > > > > Michal Hocko wrote:
> > > > > > > > > > > On Wed 26-07-17 20:33:21, Tetsuo Handa wrote:
> > > > > > > > > > > > My question is, how can users know it if somebody was OOM-killed needlessly
> > > > > > > > > > > > by allowing MMF_OOM_SKIP to race.
> > > > > > > > > > > 
> > > > > > > > > > > Is it really important to know that the race is due to MMF_OOM_SKIP?
> > > > > > > > > > 
> > > > > > > > > > Yes, it is really important. Needlessly selecting even one OOM victim is
> > > > > > > > > > a pain which is difficult to explain to and persuade some of customers.
> > > > > > > > > 
> > > > > > > > > How is this any different from a race with a task exiting an releasing
> > > > > > > > > some memory after we have crossed the point of no return and will kill
> > > > > > > > > something?
> > > > > > > > 
> > > > > > > > I'm not complaining about an exiting task releasing some memory after we have
> > > > > > > > crossed the point of no return.
> > > > > > > > 
> > > > > > > > What I'm saying is that we can postpone "the point of no return" if we ignore
> > > > > > > > MMF_OOM_SKIP for once (both this "oom_reaper: close race without using oom_lock"
> > > > > > > > thread and "mm, oom: task_will_free_mem(current) should ignore MMF_OOM_SKIP for
> > > > > > > > once." thread). These are race conditions we can avoid without crystal ball.
> > > > > > > 
> > > > > > > If those races are really that common than we can handle them even
> > > > > > > without "try once more" tricks. Really this is just an ugly hack. If you
> > > > > > > really care then make sure that we always try to allocate from memory
> > > > > > > reserves before going down the oom path. In other words, try to find a
> > > > > > > robust solution rather than tweaks around a problem.
> > > > > > 
> > > > > > Since your "mm, oom: allow oom reaper to race with exit_mmap" patch removes
> > > > > > oom_lock serialization from the OOM reaper, possibility of calling out_of_memory()
> > > > > > due to successful mutex_trylock(&oom_lock) would increase when the OOM reaper set
> > > > > > MMF_OOM_SKIP quickly.
> > > > > > 
> > > > > > What if task_is_oom_victim(current) became true and MMF_OOM_SKIP was set
> > > > > > on current->mm between after __gfp_pfmemalloc_flags() returned 0 and before
> > > > > > out_of_memory() is called (due to successful mutex_trylock(&oom_lock)) ?
> > > > > > 
> > > > > > Excuse me? Are you suggesting to try memory reserves before
> > > > > > task_is_oom_victim(current) becomes true?
> > > > > 
> > > > > No what I've tried to say is that if this really is a real problem,
> > > > > which I am not sure about, then the proper way to handle that is to
> > > > > attempt to allocate from memory reserves for an oom victim. I would be
> > > > > even willing to take the oom_lock back into the oom reaper path if the
> > > > > former turnes out to be awkward to implement. But all this assumes this
> > > > > is a _real_ problem.
> > > > 
> > > > Aren't we back to square one? My question is, how can users know it if
> > > > somebody was OOM-killed needlessly by allowing MMF_OOM_SKIP to race.
> > > > 
> > > > You don't want to call get_page_from_freelist() from out_of_memory(), do you?
> > > > But without passing a flag "whether get_page_from_freelist() with memory reserves
> > > > was already attempted if current thread is an OOM victim" to task_will_free_mem()
> > > > in out_of_memory() and a flag "whether get_page_from_freelist() without memory
> > > > reserves was already attempted if current thread is not an OOM victim" to
> > > > test_bit(MMF_OOM_SKIP) in oom_evaluate_task(), we won't be able to know
> > > > if somebody was OOM-killed needlessly by allowing MMF_OOM_SKIP to race.
> > > 
> > > Michal, I did not get your answer, and your "mm, oom: do not rely on
> > > TIF_MEMDIE for memory reserves access" did not help solving this problem.
> > > (I confirmed it by reverting your "mm, oom: allow oom reaper to race with
> > > exit_mmap" and applying Andrea's "mm: oom: let oom_reap_task and exit_mmap
> > > run concurrently" and this patch on top of linux-next-20170817.)
> > 
> > By "this patch" you probably mean a BUG_ON(tsk_is_oom_victim) somewhere
> > in task_will_free_mem right? I do not see anything like that in you
> > email.
> 
> I wrote
> 
>   You can confirm it by adding "BUG_ON(1);" at "task->oom_kill_free_check_raced = 1;"
>   of this patch.
> 
> in the patch description.

Ahh, OK so it was in the changelog. Your wording suggested a debugging
patch which you forgot to add.
 
> > 
> > > [  204.413605] Out of memory: Kill process 9286 (a.out) score 930 or sacrifice child
> > > [  204.416241] Killed process 9286 (a.out) total-vm:4198476kB, anon-rss:72kB, file-rss:0kB, shmem-rss:3465520kB
> > > [  204.419783] oom_reaper: reaped process 9286 (a.out), now anon-rss:0kB, file-rss:0kB, shmem-rss:3465720kB
> > > [  204.455864] ------------[ cut here ]------------
> > > [  204.457921] kernel BUG at mm/oom_kill.c:786!
> > > 
> > > Therefore, I propose this patch for inclusion.
> > 
> > i've already told you that this is a wrong approach to handle a possible
> > race and offered you an alternative. I realy fail to see why you keep
> > reposting it. So to make myself absolutely clear
> > 
> > Nacked-by: Michal Hocko <mhocko@suse.com> to the patch below.
> 
> Where is your alternative?

Sigh... Let me repeat for the last time (this whole thread is largely a
waste of time to be honest). Find a _robust_ solution rather than
fiddling with try-once-more kind of hacks. E.g. do an allocation attempt
_before_ we do any disruptive action (aka kill a victim). This would
help other cases when we race with an exiting tasks or somebody managed
to free memory while we were selecting an oom victim which can take
quite some time.
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
