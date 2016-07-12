Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f72.google.com (mail-oi0-f72.google.com [209.85.218.72])
	by kanga.kvack.org (Postfix) with ESMTP id AA33D6B025F
	for <linux-mm@kvack.org>; Tue, 12 Jul 2016 11:43:04 -0400 (EDT)
Received: by mail-oi0-f72.google.com with SMTP id q62so33022466oih.0
        for <linux-mm@kvack.org>; Tue, 12 Jul 2016 08:43:04 -0700 (PDT)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [2001:e42:101:1:202:181:97:72])
        by mx.google.com with ESMTPS id h190si12243550itb.36.2016.07.12.08.43.02
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 12 Jul 2016 08:43:03 -0700 (PDT)
Subject: Re: [PATCH 5/8] mm,oom_reaper: Make OOM reaper use list of mm_struct.
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
References: <1468330163-4405-1-git-send-email-penguin-kernel@I-love.SAKURA.ne.jp>
	<1468330163-4405-6-git-send-email-penguin-kernel@I-love.SAKURA.ne.jp>
	<20160712145119.GP14586@dhcp22.suse.cz>
In-Reply-To: <20160712145119.GP14586@dhcp22.suse.cz>
Message-Id: <201607130042.FFE34886.FtJVOLOFMHQOSF@I-love.SAKURA.ne.jp>
Date: Wed, 13 Jul 2016 00:42:51 +0900
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: mhocko@suse.cz
Cc: akpm@linux-foundation.org, linux-mm@kvack.org, oleg@redhat.com, rientjes@google.com, vdavydov@parallels.com, mst@redhat.com

Michal Hocko wrote:
> On Tue 12-07-16 22:29:20, Tetsuo Handa wrote:
> > find_lock_task_mm() is racy when finding an mm because it returns NULL
> 
> I would rather s@racy@unreliable@
> 
> > when all threads in that thread group passed current->mm == NULL line
> > in exit_mm() while that mm might be still waiting for __mmput() (or the
> > OOM reaper) to reclaim memory used by that mm.
> > 
> > Since OOM reaping is per mm_struct operation, it is natural to use
> > list of mm_struct used by OOM victims. By using list of mm_struct,
> > we can eliminate find_lock_task_mm() usage from the OOM reaper.
> 
> Good. This will reduce the code size, simplify the code and make it more
> reliable.
> 
> > We still have racy find_lock_task_mm() usage in oom_scan_process_thread()
> > which can theoretically cause OOM livelock situation when MMF_OOM_REAPED
> > was set to OOM victim's mm without putting that mm under the OOM reaper's
> > supervision. We must not depend on find_lock_task_mm() not returning NULL.
> 
> But I guess this just makes the changelog confusing without adding a
> large value.
> 
> > Since later patch in the series will change oom_scan_process_thread() not
> > to depend on atomic_read(&task->signal->oom_victims) != 0 &&
> > find_lock_task_mm(task) != NULL, this patch removes exit_oom_victim()
> > on remote thread.
> 
> I have already suggested doing this in a separate patch. Because
> dropping exit_oom_victim has other side effectes (namely for
> oom_killer_disable convergence guarantee).

You can apply
http://lkml.kernel.org/r/1467365190-24640-3-git-send-email-mhocko@kernel.org
at this point.

> 
> Also I would suggest doing set_bit(MMF_OOM_REAPED) from exit_oom_mm and
> (in a follow up patch) rename it to MMF_SKIP_OOM_MM.
> 
> I haven't spotted any other issues.
> 
Oops. Please fold below fix into
"[PATCH 5/8] mm,oom_reaper: Make OOM reaper use list of mm_struct.".

>From ae051fb92b285c0dc4ebc4953fadc755b1ae8a31 Mon Sep 17 00:00:00 2001
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Date: Wed, 13 Jul 2016 00:24:32 +0900
Subject: [PATCH] mm,oom_reaper: Close race on exit_oom_mm().

Previous patch forgot to take a reference on mm, for __mmput() from
mmput() from exit_mm() can drop mm->mm_count till 0 before the OOM
reaper calls exit_oom_mm().

Signed-off-by: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
---
 mm/oom_kill.c | 13 ++++++++-----
 1 file changed, 8 insertions(+), 5 deletions(-)

diff --git a/mm/oom_kill.c b/mm/oom_kill.c
index 715f77d..4c8b686 100644
--- a/mm/oom_kill.c
+++ b/mm/oom_kill.c
@@ -626,21 +626,24 @@ static int oom_reaper(void *unused)
 		if (!list_empty(&oom_mm_list)) {
 			mm = list_first_entry(&oom_mm_list, struct mm_struct,
 					      oom_mm.list);
-			victim = mm->oom_mm.victim;
 			/*
-			 * Take a reference on current victim thread in case
-			 * oom_reap_task() raced with mark_oom_victim() by
-			 * other threads sharing this mm.
+			 * Take references on mm and victim in case
+			 * oom_reap_task() raced with mark_oom_victim() or
+			 * __mmput().
 			 */
+			atomic_inc(&mm->mm_count);
+			victim = mm->oom_mm.victim;
 			get_task_struct(victim);
 		}
 		spin_unlock(&oom_mm_lock);
 		if (!mm)
 			continue;
 		oom_reap_task(victim, mm);
-		put_task_struct(victim);
 		/* Drop references taken by mark_oom_victim() */
 		exit_oom_mm(mm);
+		/* Drop references taken above. */
+		put_task_struct(victim);
+		mmdrop(mm);
 	}
 
 	return 0;
-- 
1.8.3.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
