Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f72.google.com (mail-lf0-f72.google.com [209.85.215.72])
	by kanga.kvack.org (Postfix) with ESMTP id 0D50A6B0005
	for <linux-mm@kvack.org>; Mon, 23 May 2016 07:21:45 -0400 (EDT)
Received: by mail-lf0-f72.google.com with SMTP id m138so41098214lfm.0
        for <linux-mm@kvack.org>; Mon, 23 May 2016 04:21:44 -0700 (PDT)
Received: from mail-wm0-f67.google.com (mail-wm0-f67.google.com. [74.125.82.67])
        by mx.google.com with ESMTPS id f143si13540582wme.52.2016.05.23.04.21.43
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 23 May 2016 04:21:43 -0700 (PDT)
Received: by mail-wm0-f67.google.com with SMTP id q62so13881890wmg.3
        for <linux-mm@kvack.org>; Mon, 23 May 2016 04:21:43 -0700 (PDT)
Date: Mon, 23 May 2016 13:21:41 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH 2/2] mm,oom: Do oom_task_origin() test in oom_badness().
Message-ID: <20160523112141.GO2278@dhcp22.suse.cz>
References: <1463796090-7948-1-git-send-email-penguin-kernel@I-love.SAKURA.ne.jp>
 <20160523081919.GI2278@dhcp22.suse.cz>
 <201605231959.IHB04619.OtLFOJSQHFVMFO@I-love.SAKURA.ne.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <201605231959.IHB04619.OtLFOJSQHFVMFO@I-love.SAKURA.ne.jp>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Cc: akpm@linux-foundation.org, rientjes@google.com, linux-mm@kvack.org

On Mon 23-05-16 19:59:30, Tetsuo Handa wrote:
> Michal Hocko wrote:
> > On Sat 21-05-16 11:01:30, Tetsuo Handa wrote:
> > > Currently, oom_scan_process_thread() returns OOM_SCAN_SELECT if
> > > oom_task_origin() returned true. But this might cause OOM livelock.
> > > 
> > > If the OOM killer finds a task with oom_task_origin(task) == true,
> > > it means that that task is either inside try_to_unuse() from swapoff
> > > path or unmerge_and_remove_all_rmap_items() from ksm's run_store path.
> > > 
> > > Let's take a look at try_to_unuse() as an example. Although there is
> > > signal_pending() test inside the iteration loop, there are operations
> > > (e.g. mmput(), wait_on_page_*()) which might block in unkillable state
> > > waiting for other threads which might allocate memory.
> > > 
> > > Therefore, sending SIGKILL to a task with oom_task_origin(task) == true
> > > can not guarantee that that task shall not stuck at unkillable waits.
> > > Once the OOM reaper reaped that task's memory (or gave up reaping it),
> > > the OOM killer must not select that task again when oom_task_origin(task)
> > > returned true. We need to select different victims until that task can
> > > hit signal_pending() test or finish the iteration loop.
> > > 
> > > Since oom_badness() is a function which returns score of the given thread
> > > group with eligibility/livelock test, it is more natural and safer to let
> > > oom_badness() return highest score when oom_task_origin(task) == true.
> > > 
> > > This patch moves oom_task_origin() test from oom_scan_process_thread() to
> > > after MMF_OOM_REAPED test inside oom_badness(), changes the callers to
> > > receive the score using "unsigned long" variable, and eliminates
> > > OOM_SCAN_SELECT path in the callers.
> > 
> > I do not think this is the right approach. If the problem is real then
> > the patch just papers over deficiency of the oom_task_origin which
> > should be addressed instead.
> > 
> > > Signed-off-by: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
> > 
> > Nacked-by: Michal Hocko <mhocko@suse.com>
> > 
> 
> Quoting from http://lkml.kernel.org/r/20160523075524.GG2278@dhcp22.suse.cz :
> > > Is it guaranteed that try_to_unuse() from swapoff is never blocked on memory
> > > allocation (e.g. mmput(), wait_on_page_*()) ?
> > 
> > It shouldn't. All the waiting should be killable. If not it is a bug and
> > should be fixed.
> 
> So, you think that we should replace mmput() with mmput_async(), lock_page()
> with lock_page_killable(), wait_on_page_bit() with wait_on_page_bit_killable(),
> mutex_lock() with mutex_lock_killable(), down_read() with down_read_killable()
> and so on, don't you?

Yes where appropriate. And even more importantly. First think whether
you are trying to address a real problem. It doesn't make any sense to
complicate the code for something that is simply not realistic. In this
particular case we are talking about _root_ doing a potentially
expensive operation and I am pretty sure no reasonable admin would do it
under a high memory pressure. So all the cases you are trying to address
are maybe completely unrealistic.
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
