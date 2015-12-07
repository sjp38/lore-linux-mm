Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f52.google.com (mail-wm0-f52.google.com [74.125.82.52])
	by kanga.kvack.org (Postfix) with ESMTP id 3003A6B0278
	for <linux-mm@kvack.org>; Mon,  7 Dec 2015 11:07:21 -0500 (EST)
Received: by wmec201 with SMTP id c201so157245990wme.1
        for <linux-mm@kvack.org>; Mon, 07 Dec 2015 08:07:20 -0800 (PST)
Received: from mail-wm0-f54.google.com (mail-wm0-f54.google.com. [74.125.82.54])
        by mx.google.com with ESMTPS id bn4si27487671wjb.162.2015.12.07.08.07.19
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 07 Dec 2015 08:07:19 -0800 (PST)
Received: by wmww144 with SMTP id w144so146745556wmw.1
        for <linux-mm@kvack.org>; Mon, 07 Dec 2015 08:07:19 -0800 (PST)
Date: Mon, 7 Dec 2015 17:07:18 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [RFC PATCH -v2] mm, oom: introduce oom reaper
Message-ID: <20151207160718.GA20774@dhcp22.suse.cz>
References: <1448467018-20603-1-git-send-email-mhocko@kernel.org>
 <1448640772-30147-1-git-send-email-mhocko@kernel.org>
 <201511281339.JHH78172.SLOQFOFHVFOMJt@I-love.SAKURA.ne.jp>
 <201511290110.FJB87096.OHJLVQOSFFtMFO@I-love.SAKURA.ne.jp>
 <20151201132927.GG4567@dhcp22.suse.cz>
 <201512052133.IAE00551.LSOQFtMFFVOHOJ@I-love.SAKURA.ne.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <201512052133.IAE00551.LSOQFtMFFVOHOJ@I-love.SAKURA.ne.jp>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Cc: linux-mm@kvack.org, akpm@linux-foundation.org, torvalds@linux-foundation.org, mgorman@suse.de, rientjes@google.com, riel@redhat.com, hughd@google.com, oleg@redhat.com, andrea@kernel.org, linux-kernel@vger.kernel.org

On Sat 05-12-15 21:33:47, Tetsuo Handa wrote:
> Michal Hocko wrote:
> > On Sun 29-11-15 01:10:10, Tetsuo Handa wrote:
> > > Tetsuo Handa wrote:
> > > > > Users of mmap_sem which need it for write should be carefully reviewed
> > > > > to use _killable waiting as much as possible and reduce allocations
> > > > > requests done with the lock held to absolute minimum to reduce the risk
> > > > > even further.
> > > > 
> > > > It will be nice if we can have down_write_killable()/down_read_killable().
> > > 
> > > It will be nice if we can also have __GFP_KILLABLE.
> > 
> > Well, we already do this implicitly because OOM killer will
> > automatically do mark_oom_victim if it has fatal_signal_pending and then
> > __alloc_pages_slowpath fails the allocation if the memory reserves do
> > not help to finish the allocation.
> 
> I don't think so because !__GFP_FS && !__GFP_NOFAIL allocations do not do
> mark_oom_victim() even if fatal_signal_pending() is true because
> out_of_memory() is not called.

OK you are right about GFP_NOFS allocations. I didn't consider them
because I still think that GFP_NOFS needs a separate solution. Ideally
systematic one but if this is really urgent and cannot wait for it then
we can at least check for fatal_signal_pending in __alloc_pages_may_oom.
Something like:
diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 728b7a129df3..42a78aee36f3 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -2754,9 +2754,11 @@ __alloc_pages_may_oom(gfp_t gfp_mask, unsigned int order,
 			/*
 			 * XXX: Page reclaim didn't yield anything,
 			 * and the OOM killer can't be invoked, but
-			 * keep looping as per tradition.
+			 * keep looping as per tradition. Do not bother
+			 * if we are killed already though
 			 */
-			*did_some_progress = 1;
+			if (!fatal_signal_pending(current))
+				*did_some_progress = 1;
 			goto out;
 		}
 		if (pm_suspended_storage())

__GFP_KILLABLE sounds like adding more mess to the current situation
to me. Weak reclaim context which is unkillable is simply a bad
design. Putting __GFP_KILLABLE doesn't make it work properly.

But this is unrelated I believe and should be discussed in a separate
email thread.

[...]

> > > Although currently it can't
> > > be perfect because reclaim functions called from __alloc_pages_slowpath() use
> > > unkillable waits, starting from just bail out as with __GFP_NORETRY when
> > > fatal_signal_pending(current) is true will be helpful.
> > > 
> > > So far I'm hitting no problem with testers except the one using mmap()/munmap().
> > > 
> > > I think that cmpxchg() was not needed.
> > 
> > It is not needed right now but I would rather not depend on the oom
> > mutex here. This is not a hot path where an atomic would add an
> > overhead.
> 
> Current patch can allow oom_reaper() to call mmdrop(mm) before
> wake_oom_reaper() calls atomic_inc(&mm->mm_count) because sequence like
> 
>   oom_reaper() (a realtime thread)         wake_oom_reaper() (current thread)         Current OOM victim
> 
>   oom_reap_vmas(mm); /* mm = Previous OOM victim */
>   WRITE_ONCE(mm_to_reap, NULL);
>                                            old_mm = cmpxchg(&mm_to_reap, NULL, mm); /* mm = Current OOM victim */
>                                            if (!old_mm) {
>   wait_event_freezable(oom_reaper_wait, (mm = READ_ONCE(mm_to_reap)));
>   oom_reap_vmas(mm); /* mm = Current OOM victim, undo atomic_inc(&mm->mm_count) done by oom_kill_process() */
>   WRITE_ONCE(mm_to_reap, NULL);
>                                                                                       exit and release mm
>                                            atomic_inc(&mm->mm_count); /* mm = Current OOM victim */
>                                            wake_up(&oom_reaper_wait);
> 
>   wait_event_freezable(oom_reaper_wait, (mm = READ_ONCE(mm_to_reap))); /* mm = Next OOM victim */
> 
> is possible.

Yes you are right! The reference count should be incremented before
publishing the new mm_to_reap. I thought that an elevated ref. count by
the caller would be enough but this was clearly wrong. Does the update
below looks better?

diff --git a/mm/oom_kill.c b/mm/oom_kill.c
index 3431dcdb0a13..32ebf84795d8 100644
--- a/mm/oom_kill.c
+++ b/mm/oom_kill.c
@@ -511,19 +511,21 @@ static void wake_oom_reaper(struct mm_struct *mm)
 		return;
 
 	/*
+	 * Pin the given mm. Use mm_count instead of mm_users because
+	 * we do not want to delay the address space tear down.
+	 */
+	atomic_inc(&mm->mm_count);
+
+	/*
 	 * Make sure that only a single mm is ever queued for the reaper
 	 * because multiple are not necessary and the operation might be
 	 * disruptive so better reduce it to the bare minimum.
 	 */
 	old_mm = cmpxchg(&mm_to_reap, NULL, mm);
-	if (!old_mm) {
-		/*
-		 * Pin the given mm. Use mm_count instead of mm_users because
-		 * we do not want to delay the address space tear down.
-		 */
-		atomic_inc(&mm->mm_count);
+	if (!old_mm)
 		wake_up(&oom_reaper_wait);
-	}
+	else
+		mmdrop(mm);
 }
 
 /**


> If you are serious about execution ordering, we should protect mm_to_reap
> using smp_mb__after_atomic_inc(), rcu_assign_pointer()/rcu_dereference() etc.
> in addition to my patch.

cmpxchg should imply the full mem. barrier on the success AFAIR so the
increment should be visible before publishing the new mm. mmdrop could
be simply atomic_dec because our caller should hold a reference already
but I guess we do not have to optimize this super slow path and rather
be consisten with the rest of the code which decrements via mmdrop.

[...]

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
