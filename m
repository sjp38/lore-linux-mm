Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f70.google.com (mail-pg0-f70.google.com [74.125.83.70])
	by kanga.kvack.org (Postfix) with ESMTP id 451056B0492
	for <linux-mm@kvack.org>; Mon, 17 Jul 2017 17:42:46 -0400 (EDT)
Received: by mail-pg0-f70.google.com with SMTP id s4so2587087pgr.3
        for <linux-mm@kvack.org>; Mon, 17 Jul 2017 14:42:46 -0700 (PDT)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [2001:e42:101:1:202:181:97:72])
        by mx.google.com with ESMTPS id c7si245685pfb.46.2017.07.17.14.42.44
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Mon, 17 Jul 2017 14:42:45 -0700 (PDT)
Subject: Re: [PATCH v2] mm/page_alloc: Wait for oom_lock before retrying.
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
References: <1500202791-5427-1-git-send-email-penguin-kernel@I-love.SAKURA.ne.jp>
	<20170717152440.GM12888@dhcp22.suse.cz>
In-Reply-To: <20170717152440.GM12888@dhcp22.suse.cz>
Message-Id: <201707180642.IHF86993.OFMLVOOFJQHSFt@I-love.SAKURA.ne.jp>
Date: Tue, 18 Jul 2017 06:42:31 +0900
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: mhocko@kernel.org
Cc: linux-mm@kvack.org, hannes@cmpxchg.org, rientjes@google.com, linux-kernel@vger.kernel.org

Michal Hocko wrote:
> On Sun 16-07-17 19:59:51, Tetsuo Handa wrote:
> > Since the whole memory reclaim path has never been designed to handle the
> > scheduling priority inversions, those locations which are assuming that
> > execution of some code path shall eventually complete without using
> > synchronization mechanisms can get stuck (livelock) due to scheduling
> > priority inversions, for CPU time is not guaranteed to be yielded to some
> > thread doing such code path.
> > 
> > mutex_trylock() in __alloc_pages_may_oom() (waiting for oom_lock) and
> > schedule_timeout_killable(1) in out_of_memory() (already held oom_lock) is
> > one of such locations, and it was demonstrated using artificial stressing
> > that the system gets stuck effectively forever because SCHED_IDLE priority
> > thread is unable to resume execution at schedule_timeout_killable(1) if
> > a lot of !SCHED_IDLE priority threads are wasting CPU time [1].
> > 
> > To solve this problem properly, complete redesign and rewrite of the whole
> > memory reclaim path will be needed. But we are not going to think about
> > reimplementing the the whole stack (at least for foreseeable future).
> > 
> > Thus, this patch workarounds livelock by forcibly yielding enough CPU time
> > to the thread holding oom_lock by using mutex_lock_killable() mechanism,
> > so that the OOM killer/reaper can use CPU time yielded by this patch.
> > Of course, this patch does not help if the cause of lack of CPU time is
> > somewhere else (e.g. executing CPU intensive computation with very high
> > scheduling priority), but that is not fault of this patch.
> > This patch only manages not to lockup if the cause of lack of CPU time is
> > direct reclaim storm wasting CPU time without making any progress while
> > waiting for oom_lock.
> 
> I have to think about this some more. Hitting much more on the oom_lock
> is a problem while __oom_reap_task_mm still depends on the oom_lock. With
> http://lkml.kernel.org/r/20170626130346.26314-1-mhocko@kernel.org it
> doesn't do anymore.

I suggested preserving oom_lock serialization when setting MMF_OOM_SKIP in
reply to that post (unless we use some trick for force calling
get_page_from_freelist() after confirming that there is no !MMF_OOM_SKIP mm).

> 
> Also this whole reasoning is little bit dubious to me. The whole reclaim
> stack might still preempt the holder of the lock so you are addressin
> only a very specific contention case where everybody hits the oom. I
> suspect that a differently constructed testcase might result in the same
> problem.

I think that direct reclaim/compaction is primary source of CPU time
consumption, for there will be nothing more to do other than
get_page_from_freelist() and schedule_timeout_uninterruptible() if
we are waiting for somebody else to make progress using the OOM killer.
Thus, if we wait using mutex_lock_killable(), direct reclaim/compaction
will not be called (i.e. the rest of whole reclaim stack will not preempt
the holder of the oom_lock) after each allocating thread failed to acquire
the oom_lock.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
