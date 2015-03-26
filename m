Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f180.google.com (mail-ig0-f180.google.com [209.85.213.180])
	by kanga.kvack.org (Postfix) with ESMTP id 3CD316B0032
	for <linux-mm@kvack.org>; Thu, 26 Mar 2015 15:50:23 -0400 (EDT)
Received: by igbqf9 with SMTP id qf9so1874312igb.1
        for <linux-mm@kvack.org>; Thu, 26 Mar 2015 12:50:23 -0700 (PDT)
Received: from mail-ie0-x22b.google.com (mail-ie0-x22b.google.com. [2607:f8b0:4001:c03::22b])
        by mx.google.com with ESMTPS id y2si5648798ics.105.2015.03.26.12.50.22
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 26 Mar 2015 12:50:22 -0700 (PDT)
Received: by iedfl3 with SMTP id fl3so61997360ied.1
        for <linux-mm@kvack.org>; Thu, 26 Mar 2015 12:50:22 -0700 (PDT)
Date: Thu, 26 Mar 2015 12:50:20 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [patch 03/12] mm: oom_kill: switch test-and-clear of known
 TIF_MEMDIE to clear
In-Reply-To: <20150326110532.GB18560@cmpxchg.org>
Message-ID: <alpine.DEB.2.10.1503261231440.9410@chino.kir.corp.google.com>
References: <1427264236-17249-1-git-send-email-hannes@cmpxchg.org> <1427264236-17249-4-git-send-email-hannes@cmpxchg.org> <alpine.DEB.2.10.1503252025230.16714@chino.kir.corp.google.com> <20150326110532.GB18560@cmpxchg.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>, Huang Ying <ying.huang@intel.com>, Andrea Arcangeli <aarcange@redhat.com>, Dave Chinner <david@fromorbit.com>, Michal Hocko <mhocko@suse.cz>, Theodore Ts'o <tytso@mit.edu>

On Thu, 26 Mar 2015, Johannes Weiner wrote:

> > > exit_oom_victim() already knows that TIF_MEMDIE is set, and nobody
> > > else can clear it concurrently.  Use clear_thread_flag() directly.
> > > 
> > > Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>
> > 
> > For the oom killer, that's true because of task_lock(): we always only set 
> > TIF_MEMDIE when there is a valid p->mm and it's cleared in the exit path 
> > after the unlock, acting as a barrier, when p->mm is set to NULL so it's 
> > no longer a valid victim.  So that part is fine.
> > 
> > The problem is the android low memory killer that does 
> > mark_tsk_oom_victim() without the protection of task_lock(), it's just rcu 
> > protected so the reference to the task itself is guaranteed to still be 
> > valid.
> 
> But this is about *setting* it without a lock.  My point was that once
> TIF_MEMDIE is actually set, the task owns it and nobody else can clear
> it for them, so it's safe to test and clear non-atomically from the
> task's own context.  Am I missing something?
> 

Yes, I'm thinking about the following which already exists before your 
patch:

	tskA			tskB
	----			----
	lowmem_scan()
	-> tskB->mm != NULL
	-> selected = tskB
				exit_mm()
				exit_oom_victim()
				-> TIF_MEMDIE not set, return	
	mark_oom_victim(tskB)
	-> set TIF_MEMDIE

And now if tskA fails to exit then the oom killer is going to stall 
forever because we don't check for p->mm != NULL when testing eligible 
processes for TIF_MEMDIE.

So there's nothing wrong with your patch, I'm just digesting all of this 
new mark_oom_victim() stuff.

Acked-by: David Rientjes <rientjes@google.com>

I think the lmk should be doing this, in addition:


android, lmk: avoid setting TIF_MEMDIE if process has already exited

TIF_MEMDIE should not be set on a process if it does not have a valid 
->mm, and this is protected by task_lock().

If TIF_MEMDIE gets set after the mm has detached, and the process fails to 
exit, then the oom killer will defer forever waiting for it to exit.

Make sure that the mm is still valid before setting TIF_MEMDIE by way of 
mark_tsk_oom_victim().

Signed-off-by: David Rientjes <rientjes@google.com>
---
diff --git a/drivers/staging/android/lowmemorykiller.c b/drivers/staging/android/lowmemorykiller.c
--- a/drivers/staging/android/lowmemorykiller.c
+++ b/drivers/staging/android/lowmemorykiller.c
@@ -156,20 +156,27 @@ static unsigned long lowmem_scan(struct shrinker *s, struct shrink_control *sc)
 			     p->pid, p->comm, oom_score_adj, tasksize);
 	}
 	if (selected) {
-		lowmem_print(1, "send sigkill to %d (%s), adj %hd, size %d\n",
-			     selected->pid, selected->comm,
-			     selected_oom_score_adj, selected_tasksize);
-		lowmem_deathpending_timeout = jiffies + HZ;
+		task_lock(selected);
+		if (!selected->mm) {
+			/* Already exited, cannot do mark_tsk_oom_victim() */
+			task_unlock(selected);
+			goto out;
+		}
 		/*
 		 * FIXME: lowmemorykiller shouldn't abuse global OOM killer
 		 * infrastructure. There is no real reason why the selected
 		 * task should have access to the memory reserves.
 		 */
 		mark_tsk_oom_victim(selected);
+		task_unlock(selected);
+		lowmem_print(1, "send sigkill to %d (%s), adj %hd, size %d\n",
+			     selected->pid, selected->comm,
+			     selected_oom_score_adj, selected_tasksize);
+		lowmem_deathpending_timeout = jiffies + HZ;
 		send_sig(SIGKILL, selected, 0);
 		rem += selected_tasksize;
 	}
-
+out:
 	lowmem_print(4, "lowmem_scan %lu, %x, return %lu\n",
 		     sc->nr_to_scan, sc->gfp_mask, rem);
 	rcu_read_unlock();

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
