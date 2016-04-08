Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f49.google.com (mail-wm0-f49.google.com [74.125.82.49])
	by kanga.kvack.org (Postfix) with ESMTP id 8C6E46B007E
	for <linux-mm@kvack.org>; Fri,  8 Apr 2016 07:34:28 -0400 (EDT)
Received: by mail-wm0-f49.google.com with SMTP id 191so15317111wmq.0
        for <linux-mm@kvack.org>; Fri, 08 Apr 2016 04:34:28 -0700 (PDT)
Received: from mail-wm0-f67.google.com (mail-wm0-f67.google.com. [74.125.82.67])
        by mx.google.com with ESMTPS id 13si13025065wjv.41.2016.04.08.04.34.27
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 08 Apr 2016 04:34:27 -0700 (PDT)
Received: by mail-wm0-f67.google.com with SMTP id a140so3642710wma.2
        for <linux-mm@kvack.org>; Fri, 08 Apr 2016 04:34:27 -0700 (PDT)
Date: Fri, 8 Apr 2016 13:34:25 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH 3/3] mm, oom_reaper: clear TIF_MEMDIE for all tasks
 queued for oom_reaper
Message-ID: <20160408113425.GF29820@dhcp22.suse.cz>
References: <1459951996-12875-1-git-send-email-mhocko@kernel.org>
 <1459951996-12875-4-git-send-email-mhocko@kernel.org>
 <201604072055.GAI52128.tHLVOFJOQMFOFS@I-love.SAKURA.ne.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <201604072055.GAI52128.tHLVOFJOQMFOFS@I-love.SAKURA.ne.jp>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Cc: linux-mm@kvack.org, rientjes@google.com, akpm@linux-foundation.org, linux-kernel@vger.kernel.org

On Thu 07-04-16 20:55:34, Tetsuo Handa wrote:
> Michal Hocko wrote:
> > The first obvious one is when the oom victim clears its mm and gets
> > stuck later on. oom_reaper would back of on find_lock_task_mm returning
> > NULL. We can safely try to clear TIF_MEMDIE in this case because such a
> > task would be ignored by the oom killer anyway. The flag would be
> > cleared by that time already most of the time anyway.
> 
> I didn't understand what this wants to tell. The OOM victim will clear
> TIF_MEMDIE as soon as it sets current->mm = NULL.

No it clears the flag _after_ it returns from mmput. There is no
guarantee it won't get stuck somewhere on the way there - e.g. exit_aio
waits for completion and who knows what else might get stuck.

> Even if the oom victim
> clears its mm and gets stuck later on (e.g. at exit_task_work()),
> TIF_MEMDIE was already cleared by that moment by the OOM victim.
> 
> > 
> > The less obvious one is when the oom reaper fails due to mmap_sem
> > contention. Even if we clear TIF_MEMDIE for this task then it is not
> > very likely that we would select another task too easily because
> > we haven't reaped the last victim and so it would be still the #1
> > candidate. There is a rare race condition possible when the current
> > victim terminates before the next select_bad_process but considering
> > that oom_reap_task had retried several times before giving up then
> > this sounds like a borderline thing.
> 
> Is it helpful? Allowing the OOM killer to select the same thread again
> simply makes the kernel log buffer flooded with the OOM kill messages.

I am trying to be as conservative as possible here. The likelyhood of
mmap sem contention will be reduced considerably after my
down_write_killable series will get merged. If this turns out to be a
problem (trivial to spot as the same task will be killed again) then we
can think about a fix for that (e.g. ignore the task if the has been
selected more than N times).

> I think we should not allow the OOM killer to select the same thread again
> by e.g. doing tsk->signal->oom_score_adj = OOM_SCORE_ADJ_MIN regardless of
> whether reaping that thread's memory succeeded or not.

I think this comes with some risk and so it should go as a separate
patch with a full justification why the outcome is better. Especially
after the mmap_sem contention will be reduced by other means.
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
