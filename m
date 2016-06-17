Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f69.google.com (mail-wm0-f69.google.com [74.125.82.69])
	by kanga.kvack.org (Postfix) with ESMTP id C76C86B0005
	for <linux-mm@kvack.org>; Fri, 17 Jun 2016 08:26:51 -0400 (EDT)
Received: by mail-wm0-f69.google.com with SMTP id r190so9190635wmr.0
        for <linux-mm@kvack.org>; Fri, 17 Jun 2016 05:26:51 -0700 (PDT)
Received: from mail-wm0-f47.google.com (mail-wm0-f47.google.com. [74.125.82.47])
        by mx.google.com with ESMTPS id w6si4845084wma.71.2016.06.17.05.26.50
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 17 Jun 2016 05:26:50 -0700 (PDT)
Received: by mail-wm0-f47.google.com with SMTP id m124so110512205wme.1
        for <linux-mm@kvack.org>; Fri, 17 Jun 2016 05:26:50 -0700 (PDT)
Date: Fri, 17 Jun 2016 14:26:49 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH 07/10] mm, oom: fortify task_will_free_mem
Message-ID: <20160617122647.GF21670@dhcp22.suse.cz>
References: <20160613112746.GD6518@dhcp22.suse.cz>
 <201606162154.CGE05294.HJQOSMFFVFtOOL@I-love.SAKURA.ne.jp>
 <20160616142940.GK6836@dhcp22.suse.cz>
 <201606170040.FGC21882.FMLHOtVSFFJOQO@I-love.SAKURA.ne.jp>
 <20160616155347.GO6836@dhcp22.suse.cz>
 <201606172038.IIE43237.FtLMVSFOOHJFQO@I-love.SAKURA.ne.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <201606172038.IIE43237.FtLMVSFOOHJFQO@I-love.SAKURA.ne.jp>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Cc: linux-mm@kvack.org, rientjes@google.com, oleg@redhat.com, vdavydov@parallels.com, akpm@linux-foundation.org, linux-kernel@vger.kernel.org

On Fri 17-06-16 20:38:01, Tetsuo Handa wrote:
> Michal Hocko wrote:
> > > > Anyway, would you be OK with the patch if I added the current->mm check
> > > > and resolve its necessity in a separate patch?
> > > 
> > > Please correct task_will_free_mem() in oom_kill_process() as well.
> > 
> > We cannot hold task_lock over all task_will_free_mem I am even not sure
> > we have to develop an elaborate way to make it raceless just for the nommu
> > case. The current case is simple as we cannot race here. Is that
> > sufficient for you?
> 
> We can use find_lock_task_mm() inside mark_oom_victim().
> That is, call wake_oom_reaper() from mark_oom_victim() like
> 
> void mark_oom_victim(struct task_struct *tsk, bool can_use_oom_reaper)
> {
> 	WARN_ON(oom_killer_disabled);
> 	/* OOM killer might race with memcg OOM */
> 	tsk = find_lock_task_mm(tsk);
> 	if (!tsk)
> 		return;
> 	if (test_and_set_tsk_thread_flag(tsk, TIF_MEMDIE)) {
> 		task_unlock(tsk);
> 		return;
> 	}
> 	task_unlock(tsk);
> 	atomic_inc(&tsk->signal->oom_victims);
> 	/*
> 	 * Make sure that the task is woken up from uninterruptible sleep
> 	 * if it is frozen because OOM killer wouldn't be able to free
> 	 * any memory and livelock. freezing_slow_path will tell the freezer
> 	 * that TIF_MEMDIE tasks should be ignored.
> 	 */
> 	__thaw_task(tsk);
> 	atomic_inc(&oom_victims);
> 	if (can_use_oom_reaper)
> 		wake_oom_reaper(tsk);
> }
> 
> and move mark_oom_victim() by normal path to after task_unlock(victim).
> 
>  	do_send_sig_info(SIGKILL, SEND_SIG_FORCED, victim, true);
> -	mark_oom_victim(victim);
> 
> -	if (can_oom_reap)
> -		wake_oom_reaper(victim);
> +	wake_oom_reaper(victim, can_oom_reap);

I do not like this because then we would have to check the reapability
from inside the oom_reaper again.

But let me ask again. Does this really matter so much just because of
nommu where we can fall in different traps? Can we simply focus on mmu
(aka vast majority of cases) make it work reliably and see what we can
do with nommu later?

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
