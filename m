Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f54.google.com (mail-oi0-f54.google.com [209.85.218.54])
	by kanga.kvack.org (Postfix) with ESMTP id 8F8156B0005
	for <linux-mm@kvack.org>; Fri, 22 Jan 2016 08:59:25 -0500 (EST)
Received: by mail-oi0-f54.google.com with SMTP id k206so48145613oia.1
        for <linux-mm@kvack.org>; Fri, 22 Jan 2016 05:59:25 -0800 (PST)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [2001:e42:101:1:202:181:97:72])
        by mx.google.com with ESMTPS id z3si5861239oby.74.2016.01.22.05.59.24
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Fri, 22 Jan 2016 05:59:24 -0800 (PST)
Subject: Re: [PATCH] mm,oom: Re-enable OOM killer using timers.
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
References: <alpine.DEB.2.10.1601191502230.7346@chino.kir.corp.google.com>
	<201601202336.BJC04687.FOFVOQJOLSFtMH@I-love.SAKURA.ne.jp>
	<alpine.DEB.2.10.1601201538070.18155@chino.kir.corp.google.com>
	<201601212044.AFD30275.OSFFOFJHMVLOQt@I-love.SAKURA.ne.jp>
	<alpine.DEB.2.10.1601211513550.9813@chino.kir.corp.google.com>
In-Reply-To: <alpine.DEB.2.10.1601211513550.9813@chino.kir.corp.google.com>
Message-Id: <201601222259.GJB90663.MLOJtFFOQFVHSO@I-love.SAKURA.ne.jp>
Date: Fri, 22 Jan 2016 22:59:10 +0900
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: rientjes@google.com, hannes@cmpxchg.org, mhocko@kernel.org
Cc: akpm@linux-foundation.org, mgorman@suse.de, torvalds@linux-foundation.org, oleg@redhat.com, hughd@google.com, andrea@kernel.org, riel@redhat.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org

David Rientjes wrote:
> On Thu, 21 Jan 2016, Tetsuo Handa wrote:
> 
> > I consider phases for managing system-wide OOM events as follows.
> > 
> >   (1) Design and use a system with appropriate memory capacity in mind.
> > 
> >   (2) When (1) failed, the OOM killer is invoked. The OOM killer selects
> >       an OOM victim and allow that victim access to memory reserves by
> >       setting TIF_MEMDIE to it.
> > 
> >   (3) When (2) did not solve the OOM condition, start allowing all tasks
> >       access to memory reserves by your approach.
> > 
> >   (4) When (3) did not solve the OOM condition, start selecting more OOM
> >       victims by my approach.
> > 
> >   (5) When (4) did not solve the OOM condition, trigger the kernel panic.
> > 
> 
> This was all mentioned previously, and I suggested that the panic only 
> occur when memory reserves have been depleted, otherwise there is still 
> the potential for the livelock to be solved.  That is a patch that would 
> apply today, before any of this work, since we never want to loop 
> endlessly in the page allocator when memory reserves are fully depleted.
> 
> This is all really quite simple.
> 

So, David is OK with above approach, right?
Then, Michal and Johannes, are you OK with above approach?



What I'm not sure about above approach are handling of !__GFP_NOFAIL &&
!__GFP_FS allocation requests and use of ALLOC_NO_WATERMARKS without
TIF_MEMDIE.

Basically, we want to make small allocation requests success unless
__GFP_NORETRY is given. Currently such allocation requests do not fail
unless TIF_MEMDIE is given by the OOM killer. But how hard do we want to
continue looping when we reach (3) by timeout for waiting for TIF_MEMDIE
task at (2) expires?

Should we give up waiting for TIF_MEMDIE task and make !__GFP_NOFAIL allocation
requests fail (as with OOM condition after oom_killer_disable() is called)?
If our answer is "yes", there is no need to open the memory reserves.
Therefore, I guess our answer is "no".

Now, we open the memory reserves at (3). Since currently !__GFP_NOFAIL &&
!__GFP_FS allocation requests do not call out_of_memory(), current version
of "mm, oom: add global access to memory reserves on livelock" does not
allow such allocation requests access to memory reserves on OOM livelock.

If the cause of OOM livelock is an OOM victim is waiting for a lock which is
held by somebody else which is doing !__GFP_NOFAIL && !__GFP_FS allocation
requests to be released, we will fully deplete memory reserves because only
__GFP_NOFAIL || __GFP_FS allocation requests (e.g. page fault by memory hog
processes) can access memory reserves. To handle this case, what do we want
to do?

Should we allow !__GFP_NOFAIL && !__GFP_FS allocation requests access to
memory reserves by allowing them to call out_of_memory() in order to avoid
needlessly deplete memory reserves? Or, we don't care at all because we
can reach (4) anyway?

----------
diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 6463426..2299374 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -2743,16 +2743,6 @@ __alloc_pages_may_oom(gfp_t gfp_mask, unsigned int order,
 		/* The OOM killer does not needlessly kill tasks for lowmem */
 		if (ac->high_zoneidx < ZONE_NORMAL)
 			goto out;
-		/* The OOM killer does not compensate for IO-less reclaim */
-		if (!(gfp_mask & __GFP_FS)) {
-			/*
-			 * XXX: Page reclaim didn't yield anything,
-			 * and the OOM killer can't be invoked, but
-			 * keep looping as per tradition.
-			 */
-			*did_some_progress = 1;
-			goto out;
-		}
 		if (pm_suspended_storage())
 			goto out;
 		/* The OOM killer may not free memory on a specific node */
----------

Regardless of our answer, we need to decide whether to continue looping, for
there is no guarantee that memory reserves is sufficient to solve OOM livelock.

Should we give up waiting for TIF_MEMDIE task and make !__GFP_NOFAIL allocation
requests fail (as if TIF_MEMDIE was already given by the OOM killer because
we used ALLOC_NO_WATERMARKS)?
If our answer is "yes", there is no need to choose next OOM victim.
Therefore, I guess our answer is "no".

Regardless of our answer, we need to prepare for reaching (4), for it might be
__GFP_NOFAIL allocation request. What is the requirement for choosing next OOM
victim at (4)? An allocating task sees a TIF_MEMDIE task again after
get_page_from_freelist(ALLOC_NO_WATERMARKS) failed after timeout for waiting for
that task at (2) expires? Then, it would kill all tasks immediately because
reaping OOM victim's memory needs some time. We will want to check for another
timeout.



Finally, we will automatically reach (5) after all OOM-killable tasks are
chosen as OOM victims at (4). Here is just an idea for (5). If we change
the OOM killer not to call panic() when there is no more OOM-killable tasks,
it will allow us not to give up immediately after TIF_MEMDIE was given by the
OOM killer. This will increase possibility of making small allocation requests
by TIF_MEMDIE tasks success, for it is almost impossibly unlikely case that
we reach (5).

----------
diff --git a/mm/oom_kill.c b/mm/oom_kill.c
index 6ebc0351..de22c44 100644
--- a/mm/oom_kill.c
+++ b/mm/oom_kill.c
@@ -884,8 +884,10 @@ bool out_of_memory(struct oom_control *oc)
 	}
 
 	p = select_bad_process(oc, &points, totalpages);
-	/* Found nothing?!?! Either we hang forever, or we panic. */
+	/* Found nothing?!?! Either we fail the allocation, or we panic. */
 	if (!p && !is_sysrq_oom(oc)) {
+		if (!(oc->gfp_mask & __GFP_NOFAIL))
+			return false;
 		dump_header(oc, NULL, NULL);
 		panic("Out of memory and no killable processes...\n");
 	}
diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 6463426..798fd68 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -3181,10 +3171,6 @@ retry:
 		goto nopage;
 	}
 
-	/* Avoid allocations with no watermarks from looping endlessly */
-	if (test_thread_flag(TIF_MEMDIE) && !(gfp_mask & __GFP_NOFAIL))
-		goto nopage;
-
 	/*
 	 * Try direct compaction. The first pass is asynchronous. Subsequent
 	 * attempts after direct reclaim are synchronous
----------

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
