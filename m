Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f69.google.com (mail-pa0-f69.google.com [209.85.220.69])
	by kanga.kvack.org (Postfix) with ESMTP id E5BA96B0253
	for <linux-mm@kvack.org>; Fri, 22 Jul 2016 07:09:53 -0400 (EDT)
Received: by mail-pa0-f69.google.com with SMTP id q2so187635573pap.1
        for <linux-mm@kvack.org>; Fri, 22 Jul 2016 04:09:53 -0700 (PDT)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [2001:e42:101:1:202:181:97:72])
        by mx.google.com with ESMTPS id q9si15408310pab.37.2016.07.22.04.09.52
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Fri, 22 Jul 2016 04:09:52 -0700 (PDT)
Subject: Re: [PATCH v3 0/8] Change OOM killer to use list of mm_struct.
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
References: <1468330163-4405-1-git-send-email-penguin-kernel@I-love.SAKURA.ne.jp>
	<20160721112140.GG26379@dhcp22.suse.cz>
In-Reply-To: <20160721112140.GG26379@dhcp22.suse.cz>
Message-Id: <201607222009.DII64068.VHMSQJtOOFOLFF@I-love.SAKURA.ne.jp>
Date: Fri, 22 Jul 2016 20:09:42 +0900
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: mhocko@suse.cz
Cc: akpm@linux-foundation.org, linux-mm@kvack.org, oleg@redhat.com, rientjes@google.com, vdavydov@parallels.com, mst@redhat.com

Michal Hocko wrote:
> On Tue 12-07-16 22:29:15, Tetsuo Handa wrote:
> > This series is an update of
> > http://lkml.kernel.org/r/201607080058.BFI87504.JtFOOFQFVHSLOM@I-love.SAKURA.ne.jp .
> > 
> > This series is based on top of linux-next-20160712 +
> > http://lkml.kernel.org/r/1467201562-6709-1-git-send-email-mhocko@kernel.org .
> 
> I was thinking about this vs. signal_struct::oom_mm [1] and came to the
> conclusion that as of now they are mostly equivalent wrt. oom livelock
> detection and coping with it. So for now any of them should be good to
> go. Good!
> 
> Now what about future plans? I would like to get rid of TIF_MEMDIE
> altogether and give access to memory reserves to oom victim when they
> allocate the memory. Something like:

Before doing so, can we handle a silent hang up caused by lowmem livelock
at http://lkml.kernel.org/r/20160211225929.GU14668@dastard ? It is a nearly
7 years old bug (since commit 35cd78156c499ef8 "vmscan: throttle direct
reclaim when too many pages are isolated already") which got no progress
so far.

Also, can we apply "[RFC PATCH 2/6] oom, suspend: fix oom_killer_disable vs.
pm suspend properly" at
http://lkml.kernel.org/r/1467365190-24640-3-git-send-email-mhocko@kernel.org
regardless of oom_mm_list vs. signal_struct::oom_mm ? While it would be
preferable to wait for a few seconds to see if !__GFP_NOFAIL allocation
requester can terminate and release memory after the OOM killer is disabled,
looping __GFP_NOFAIL allocation requester forever until out of battery or
thermal runaway when a suspend event was triggered due to low battery or
thermal is a silly choice.

> diff --git a/mm/page_alloc.c b/mm/page_alloc.c
> index 788e4f22e0bb..34446f49c2e1 100644
> --- a/mm/page_alloc.c
> +++ b/mm/page_alloc.c
> @@ -3358,7 +3358,7 @@ gfp_to_alloc_flags(gfp_t gfp_mask)
>  			alloc_flags |= ALLOC_NO_WATERMARKS;
>  		else if (!in_interrupt() &&
>  				((current->flags & PF_MEMALLOC) ||
> -				 unlikely(test_thread_flag(TIF_MEMDIE))))
> +				 tsk_is_oom_victim(current))
>  			alloc_flags |= ALLOC_NO_WATERMARKS;
>  	}
>  #ifdef CONFIG_CMA
> 
> where tsk_is_oom_victim wouldn't require the given task to go via
> out_of_memory. This would solve some of the problems we have right now
> when a thread doesn't get access to memory reserves because it never
> reaches out_of_memory (e.g. recently mentioned mempool_alloc doing
> __GFP_NORETRY). It would also make the code easier to follow. If we want
> to implement that we need an easy to implement tsk_is_oom_victim
> obviously. With the signal_struct::oom_mm this is really trivial thing.
> I am not sure we can do that with the mm list though because we are
> loosing the task->mm at certain point in time.

bool tsk_is_oom_victim(void)
{
	return current->mm && test_bit(MMF_OOM_KILLED, &current->mm->flags) &&
		 (fatal_signal_pending(current) || (current->flags & PF_EXITING));
}

>                                                The only way I can see
> this would fly would be preserving TIF_MEMDIE and setting it for all
> threads but I am not sure this is very much better and puts the mm list
> approach to a worse possition from my POV.
> 

But do we still need ALLOC_NO_WATERMARKS for OOM victims? I didn't have a
chance to post below series but I'm suspecting that we need to distinguish
"threads killed by the OOM killer" and "threads killed by SIGKILL" and
"threads normally exiting via exit()".


>From 23a73b9a1243460e7cfc30638ac88a38f93677fa Mon Sep 17 00:00:00 2001
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Date: Fri, 19 Feb 2016 13:22:20 +0900
Subject: [PATCH 1/3] mm,page_alloc: do not loop __GFP_NOFAIL allocation after
 the OOM killer is disabled.

Currently, we are calling panic() from out_of_memory() if the OOM killer
failed to find a process to OOM-kill. But the caller of __GFP_NOFAIL
allocations may not want to call panic() now because ALLOC_NO_WATERMARKS
is not tried yet.

This patch changes out_of_memory() to return false in order to allow the
caller to decide whether to call panic(), and allows __GFP_NOFAIL
allocation requester to try ALLOC_NO_WATERMARKS before calling panic().

This patch changes __GFP_NOFAIL allocation requester to call panic()
when the OOM killer is disabled. While it would be preferable to wait
for a few seconds to see if !__GFP_NOFAIL allocation requester can
terminate and release memory, looping until out of battery or thermal
runaway is bad.

Signed-off-by: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
---
 include/linux/oom.h |  1 +
 mm/oom_kill.c       | 14 +++++++++-----
 mm/page_alloc.c     | 37 +++++++++++++++++++++++--------------
 3 files changed, 33 insertions(+), 19 deletions(-)

diff --git a/include/linux/oom.h b/include/linux/oom.h
index 45993b8..7b0e476 100644
--- a/include/linux/oom.h
+++ b/include/linux/oom.h
@@ -90,6 +90,7 @@ extern enum oom_scan_t oom_scan_process_thread(struct oom_control *oc,
 		struct task_struct *task, unsigned long totalpages);

 extern bool out_of_memory(struct oom_control *oc);
+extern void out_of_memory_panic(struct oom_control *oc);

 extern void exit_oom_victim(struct task_struct *tsk);

diff --git a/mm/oom_kill.c b/mm/oom_kill.c
index d7bb9c1..0ed12ce 100644
--- a/mm/oom_kill.c
+++ b/mm/oom_kill.c
@@ -406,6 +406,12 @@ static void dump_header(struct oom_control *oc, struct task_struct *p,
 		dump_tasks(memcg, oc->nodemask);
 }

+void out_of_memory_panic(struct oom_control *oc)
+{
+	dump_header(oc, NULL, NULL);
+	panic("Out of memory and no killable processes...\n");
+}
+
 /*
  * Number of OOM victims in flight
  */
@@ -892,11 +898,9 @@ bool out_of_memory(struct oom_control *oc)
 	}

 	p = select_bad_process(oc, &points, totalpages);
-	/* Found nothing?!?! Either we hang forever, or we panic. */
-	if (!p && !is_sysrq_oom(oc)) {
-		dump_header(oc, NULL, NULL);
-		panic("Out of memory and no killable processes...\n");
-	}
+	/* Found nothing?!?! Let the caller fail the allocation or panic. */
+	if (!p && !is_sysrq_oom(oc))
+		return false;
 	if (p && p != (void *)-1UL) {
 		oom_kill_process(oc, p, points, totalpages, NULL,
 				 "Out of memory");
diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 85e7588..a2da66c 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -2870,21 +2870,30 @@ __alloc_pages_may_oom(gfp_t gfp_mask, unsigned int order,
 			goto out;
 	}
 	/* Exhausted what can be done so it's blamo time */
-	if (out_of_memory(&oc) || WARN_ON_ONCE(gfp_mask & __GFP_NOFAIL)) {
+	if (out_of_memory(&oc))
 		*did_some_progress = 1;
-
-		if (gfp_mask & __GFP_NOFAIL) {
-			page = get_page_from_freelist(gfp_mask, order,
-					ALLOC_NO_WATERMARKS|ALLOC_CPUSET, ac);
-			/*
-			 * fallback to ignore cpuset restriction if our nodes
-			 * are depleted
-			 */
-			if (!page)
-				page = get_page_from_freelist(gfp_mask, order,
-					ALLOC_NO_WATERMARKS, ac);
-		}
-	}
+	/*
+	 * The OOM killer is disabled or there are no OOM-killable processes.
+	 * This is the last chance for __GFP_NOFAIL allocations to retry.
+	 */
+	else if (gfp_mask & __GFP_NOFAIL) {
+		*did_some_progress = 1;
+		page = get_page_from_freelist(gfp_mask, order,
+					      ALLOC_NO_WATERMARKS|ALLOC_CPUSET,
+					      ac);
+		if (page)
+			goto out;
+		/*
+		 * fallback to ignore cpuset restriction if our nodes
+		 * are depleted
+		 */
+		page = get_page_from_freelist(gfp_mask, order,
+					      ALLOC_NO_WATERMARKS, ac);
+		/* Exhausted what can be done so it's time to panic. */
+		if (!page)
+			out_of_memory_panic(&oc);
+	} else if (!oom_killer_disabled)
+		out_of_memory_panic(&oc);
 out:
 	mutex_unlock(&oom_lock);
 	return page;
-- 
1.8.3.1

>From 45f9ae8ab7efd5a6c3770afaccd2eaed58cb1d45 Mon Sep 17 00:00:00 2001
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Date: Fri, 19 Feb 2016 13:29:25 +0900
Subject: [PATCH 2/3] mm,page_alloc: favor exiting tasks over normal tasks.

While the OOM reaper likely can reap memory used by OOM victims before
they terminate, it is possible that the OOM reaper cannot reap their
memory due to sharing it with OOM-unkillable processes or memory reaped
by the OOM reaper is preferentially used by them.

This patch allows exiting tasks (either fatal_signal_pending() or
PF_EXITING) tasks to access some of memory reserves, in order to
make sure that they can try harder before the OOM killer decides
to choose next OOM victim.

Signed-off-by: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
---
 mm/page_alloc.c | 3 +++
 1 file changed, 3 insertions(+)

diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index a2da66c..e29e596 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -3078,6 +3078,9 @@ gfp_to_alloc_flags(gfp_t gfp_mask)
 				((current->flags & PF_MEMALLOC) ||
 				 unlikely(test_thread_flag(TIF_MEMDIE))))
 			alloc_flags |= ALLOC_NO_WATERMARKS;
+		else if (!in_interrupt() && (fatal_signal_pending(current) ||
+					     (current->flags & PF_EXITING)))
+			alloc_flags |= ALLOC_HARDER;
 	}
 #ifdef CONFIG_CMA
 	if (gfpflags_to_migratetype(gfp_mask) == MIGRATE_MOVABLE)
-- 
1.8.3.1

>From bb2e5cfa41901b88f711b0e17bf273e491b911bb Mon Sep 17 00:00:00 2001
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Date: Fri, 19 Feb 2016 13:42:38 +0900
Subject: [PATCH 3/3] mm,page_alloc: do not give up looping

Since the OOM reaper (and timeout based next OOM victim selection) can
guarantee that memory reserves are refilled as long as the OOM killer
is invoked, we don't need to fail !__GFP_NOFAIL allocations as soon as
chosen for an OOM-victim. Also, we don't need to call panic() as soon as
all OOM-killable processes are OOM-killed.

Signed-off-by: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
---
 mm/page_alloc.c | 10 ++--------
 1 file changed, 2 insertions(+), 8 deletions(-)

diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index e29e596..7b194b4 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -2893,7 +2893,7 @@ __alloc_pages_may_oom(gfp_t gfp_mask, unsigned int order,
 		if (!page)
 			out_of_memory_panic(&oc);
 	} else if (!oom_killer_disabled)
-		out_of_memory_panic(&oc);
+		*did_some_progress = 1;
 out:
 	mutex_unlock(&oom_lock);
 	return page;
@@ -3074,9 +3074,7 @@ gfp_to_alloc_flags(gfp_t gfp_mask)
 			alloc_flags |= ALLOC_NO_WATERMARKS;
 		else if (in_serving_softirq() && (current->flags & PF_MEMALLOC))
 			alloc_flags |= ALLOC_NO_WATERMARKS;
-		else if (!in_interrupt() &&
-				((current->flags & PF_MEMALLOC) ||
-				 unlikely(test_thread_flag(TIF_MEMDIE))))
+		else if (!in_interrupt() && (current->flags & PF_MEMALLOC))
 			alloc_flags |= ALLOC_NO_WATERMARKS;
 		else if (!in_interrupt() && (fatal_signal_pending(current) ||
 					     (current->flags & PF_EXITING)))
@@ -3303,10 +3301,6 @@ retry:
 		goto nopage;
 	}

-	/* Avoid allocations with no watermarks from looping endlessly */
-	if (test_thread_flag(TIF_MEMDIE) && !(gfp_mask & __GFP_NOFAIL))
-		goto nopage;
-
 	/*
 	 * Try direct compaction. The first pass is asynchronous. Subsequent
 	 * attempts after direct reclaim are synchronous
-- 
1.8.3.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
