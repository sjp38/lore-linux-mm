Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f69.google.com (mail-wm0-f69.google.com [74.125.82.69])
	by kanga.kvack.org (Postfix) with ESMTP id E28306B007E
	for <linux-mm@kvack.org>; Tue, 19 Apr 2016 10:17:25 -0400 (EDT)
Received: by mail-wm0-f69.google.com with SMTP id l6so16835044wml.3
        for <linux-mm@kvack.org>; Tue, 19 Apr 2016 07:17:25 -0700 (PDT)
Received: from mail-wm0-f67.google.com (mail-wm0-f67.google.com. [74.125.82.67])
        by mx.google.com with ESMTPS id n9si471402wjz.199.2016.04.19.07.17.24
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 19 Apr 2016 07:17:24 -0700 (PDT)
Received: by mail-wm0-f67.google.com with SMTP id l6so5583723wml.3
        for <linux-mm@kvack.org>; Tue, 19 Apr 2016 07:17:24 -0700 (PDT)
Date: Tue, 19 Apr 2016 10:17:22 -0400
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH 3/3] mm, oom_reaper: clear TIF_MEMDIE for all tasks
 queued for oom_reaper
Message-ID: <20160419141722.GB4126@dhcp22.suse.cz>
References: <1459951996-12875-4-git-send-email-mhocko@kernel.org>
 <201604072055.GAI52128.tHLVOFJOQMFOFS@I-love.SAKURA.ne.jp>
 <20160408113425.GF29820@dhcp22.suse.cz>
 <201604161151.ECG35947.FFLtSFVQJOHOOM@I-love.SAKURA.ne.jp>
 <20160417115422.GA21757@dhcp22.suse.cz>
 <201604182059.JFB76917.OFJMHFLSOtQVFO@I-love.SAKURA.ne.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <201604182059.JFB76917.OFJMHFLSOtQVFO@I-love.SAKURA.ne.jp>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Cc: linux-mm@kvack.org, rientjes@google.com, akpm@linux-foundation.org

On Mon 18-04-16 20:59:51, Tetsuo Handa wrote:
> Michal Hocko wrote:
> > On Sat 16-04-16 11:51:11, Tetsuo Handa wrote:
> > > Michal Hocko wrote:
> > > > On Thu 07-04-16 20:55:34, Tetsuo Handa wrote:
> > > > > Michal Hocko wrote:
> > > > > > The first obvious one is when the oom victim clears its mm and gets
> > > > > > stuck later on. oom_reaper would back of on find_lock_task_mm returning
> > > > > > NULL. We can safely try to clear TIF_MEMDIE in this case because such a
> > > > > > task would be ignored by the oom killer anyway. The flag would be
> > > > > > cleared by that time already most of the time anyway.
> > > > > 
> > > > > I didn't understand what this wants to tell. The OOM victim will clear
> > > > > TIF_MEMDIE as soon as it sets current->mm = NULL.
> > > > 
> > > > No it clears the flag _after_ it returns from mmput. There is no
> > > > guarantee it won't get stuck somewhere on the way there - e.g. exit_aio
> > > > waits for completion and who knows what else might get stuck.
> > > 
> > > OK. Then, I think an OOM livelock scenario shown below is possible.
> > > 
> > >  (1) First OOM victim (where mm->mm_users == 1) is selected by the first
> > >      round of out_of_memory() call.
> > > 
> > >  (2) The OOM reaper calls atomic_inc_not_zero(&mm->mm_users).
> > > 
> > >  (3) The OOM victim calls mmput() from exit_mm() from do_exit().
> > >      mmput() returns immediately because atomic_dec_and_test(&mm->mm_users)
> > >      returns false because of (2).
> > > 
> > >  (4) The OOM reaper reaps memory and then calls mmput().
> > >      mmput() calls exit_aio() etc. and waits for completion because
> > >      atomic_dec_and_test(&mm->mm_users) is now true.
> > > 
> > >  (5) Second OOM victim (which is the parent of the first OOM victim)
> > >      is selected by the next round of out_of_memory() call.
> > > 
> > >  (6) The OOM reaper is waiting for completion of the first OOM victim's
> > >      memory while the second OOM victim is waiting for the OOM reaper to
> > >      reap memory.
> > > 
> > > Where is the guarantee that exit_aio() etc. called from mmput() by the
> > > OOM reaper does not depend on memory allocation (i.e. the OOM reaper is
> > > not blocked forever inside __oom_reap_task())?
> > 
> > You should realize that the mmput is called _after_ we have reclaimed
> > victim's address space. So there should be some memory freed by that
> > time which reduce the likelyhood of a lockup due to memory allocation
> > request if it is really needed for exit_aio.
> 
> Not always true. mmput() is called when down_read_trylock(&mm->mmap_sem) failed.
> It is possible that the OOM victim was about to call up_write(&mm->mmap_sem) when
> down_read_trylock(&mm->mmap_sem) failed, and it is possible that the OOM victim
> runs until returning from mmput() from exit_mm() from do_exit() when the OOM
> reaper was preempted between down_read_trylock(&mm->mmap_sem) and mmput().
> Under such race, the OOM reaper will call mmput() without reclaiming the OOM
> victim's address space.

You are right! For some reason I have missed that.

> > But you have a good point here. We want to strive for robustness of
> > oom_reaper as much as possible. We have dropped the munlock patch because
> > of the robustness so I guess we want this to be fixed as well. The
> > reason for blocking might be different from memory pressure I guess.
> 
> The reality of race/dependency is more complicated than we can imagine.
> 
> > 
> > Here is what should work - I have only compile tested it. I will prepare
> > the proper patch later this week with other oom reaper patches or after
> > I come back from LSF/MM.
> 
> Excuse me, but is system_wq suitable for queuing operations which may take
> unpredictable duration to flush?
> 
>   system_wq is the one used by schedule[_delayed]_work[_on]().
>   Multi-CPU multi-threaded.  There are users which expect relatively
>   short queue flush time.  Don't queue works which can run for too
>   long.

An alternative would be using a dedicated WQ with WQ_MEM_RECLAIM which I
am not really sure would be justified considering we are talking about a
highly unlikely event. You do not want to consume resources permanently
for an eventual and not fatal event.

> Many users including SysRq-f depend on system_wq being flushed shortly.

Critical work shouldn't really rely on system_wq, full stop. There is
just too much going on on that WQ and it is simply impossible to
guarantee anything.

> We
> haven't guaranteed that SysRq-f can always fire and select a different OOM
> victim, but you proposed always clearing TIF_MEMDIE without thinking the
> possibility of the OOM victim with mmap_sem held for write being stuck at
> unkillable wait.
> 
> I wonder about your definition of "robustness". You are almost always missing
> the worst scenario. You are trying to manage OOM without defining default:
> label in a switch statement. I don't think your approach is robust.

I am trying to be as robust as it is viable. You have to realize we are
in the catastrophic path already and there is simply no deterministic
way out.
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
