Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f47.google.com (mail-wm0-f47.google.com [74.125.82.47])
	by kanga.kvack.org (Postfix) with ESMTP id 4285A6B0005
	for <linux-mm@kvack.org>; Wed, 17 Feb 2016 11:17:46 -0500 (EST)
Received: by mail-wm0-f47.google.com with SMTP id c200so221985573wme.0
        for <linux-mm@kvack.org>; Wed, 17 Feb 2016 08:17:46 -0800 (PST)
Received: from mail-wm0-f51.google.com (mail-wm0-f51.google.com. [74.125.82.51])
        by mx.google.com with ESMTPS id 200si23055667wms.27.2016.02.17.08.17.44
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 17 Feb 2016 08:17:45 -0800 (PST)
Received: by mail-wm0-f51.google.com with SMTP id g62so35480192wme.0
        for <linux-mm@kvack.org>; Wed, 17 Feb 2016 08:17:44 -0800 (PST)
Date: Wed, 17 Feb 2016 17:17:42 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH 2/6] mm,oom: don't abort on exiting processes when
 selecting a victim.
Message-ID: <20160217161742.GS29196@dhcp22.suse.cz>
References: <20160217125418.GF29196@dhcp22.suse.cz>
 <201602172207.GAG52105.FOtMJOFQOVSFHL@I-love.SAKURA.ne.jp>
 <20160217140006.GM29196@dhcp22.suse.cz>
 <201602172339.JBJ57868.tSQVJLHMFFOOFO@I-love.SAKURA.ne.jp>
 <20160217150127.GR29196@dhcp22.suse.cz>
 <201602180029.HHG73447.QSFOHJOtLVOFFM@I-love.SAKURA.ne.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <201602180029.HHG73447.QSFOHJOtLVOFFM@I-love.SAKURA.ne.jp>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Cc: akpm@linux-foundation.org, rientjes@google.com, mgorman@suse.de, oleg@redhat.com, torvalds@linux-foundation.org, hughd@google.com, andrea@kernel.org, riel@redhat.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Thu 18-02-16 00:29:35, Tetsuo Handa wrote:
> Michal Hocko wrote:
> > > > > Please see http://lkml.kernel.org/r/201602151958.HCJ48972.FFOFOLMHSQVJtO@I-love.SAKURA.ne.jp .
> > > > 
> > > > I have missed this one. Reading...
> > > > 
> > > > Hmm, so you are not referring to OOM killed task but naturally exiting
> > > > thread which is racing with the OOM killer. I guess you have a point
> > > > there! Could you update the changelog with the above example and repost
> > > > please?
> > > > 
> > > Yes and I resent that patch as v2.
> > > 
> > > I think that the same problem exists for any task_will_free_mem()-based
> > > optimizations. Can we eliminate them because these optimized paths are not
> > > handled by the OOM reaper which means that we have no means other than
> > > "[PATCH 5/6] mm,oom: Re-enable OOM killer using timers." ?
> > 
> > Well, only oom_kill_process usage of task_will_free_mem might be a
> > problem because out_of_memory operates on the current task so it must be
> > in the allocation path and access to memory reserves should help it to
> > continue.
> 
> Allowing access to memory reserves by task_will_free_mem(current) in
> out_of_memory() will help current to continue, but that does not guarantee
> that current will not be later blocked at down_read(&current->mm->mmap_sem).
> It is possible that one of threads sharing current thread's memory is calling
> out_of_memory() from mmap() and is waiting for current to set
> current->mm = NULL.
>
> > Wrt. oom_kill_process this will be more tricky. I guess we want to
> > teach oom_reaper to operate on such a task which would be a more robust
> > solution than removing the check altogether.
> > 
> 
> Thus, I think there is no difference between task_will_free_mem(current)
> case and task_will_free_mem(p) case.

Yes you are right! I completely managed to confuse and misled myself.

> We want to teach the OOM reaper to
> operate whenever TIF_MEMDIE is set. But this means that we want
> mm_is_reapable() check because there might be !SIGKILL && !PF_EXITING
> threads when we run these optimized paths.

> We will need to use timer if mm_is_reapable() == false after all.

Or we should re-evaluate those heuristics for multithreaded processes.
Does it even make sense to shortcut and block the OOM killer if the
single thread is exiting? Only very small amount of memory gets released
during its exit anyway. Don't we want to catch only the group exit to
catch fatal_signal_pending -> exit_signals -> exit_mm -> allocation
cases? I am not really sure what to check for, to be honest though.

> Why don't you accept timer based workaround now, even if you have a plan
> to update the OOM reaper for handling these optimized paths?

Because I believe that the timeout based solutions are distracting from
a proper solution which would be based on actual algorithm/heurstic that
can be measured and evaluated. And because I can see future discussion
of whether $FOO or $BAR is a better timeout... I really do not see any
reason to rush into quick solutions now.

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
