Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f199.google.com (mail-wr0-f199.google.com [209.85.128.199])
	by kanga.kvack.org (Postfix) with ESMTP id 3A1AB6B0279
	for <linux-mm@kvack.org>; Thu, 15 Jun 2017 08:20:37 -0400 (EDT)
Received: by mail-wr0-f199.google.com with SMTP id q97so3191707wrb.14
        for <linux-mm@kvack.org>; Thu, 15 Jun 2017 05:20:37 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id 30si404451wrr.268.2017.06.15.05.20.34
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 15 Jun 2017 05:20:35 -0700 (PDT)
Date: Thu, 15 Jun 2017 14:20:31 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [patch] mm, oom: prevent additional oom kills before memory is
 freed
Message-ID: <20170615122031.GL1486@dhcp22.suse.cz>
References: <alpine.DEB.2.10.1706141632100.93071@chino.kir.corp.google.com>
 <20170615103909.GG1486@dhcp22.suse.cz>
 <201706151953.HFH78657.tFFLOOOQHSMVFJ@I-love.SAKURA.ne.jp>
 <20170615110119.GI1486@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170615110119.GI1486@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Cc: rientjes@google.com, akpm@linux-foundation.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Thu 15-06-17 13:01:19, Michal Hocko wrote:
> On Thu 15-06-17 19:53:24, Tetsuo Handa wrote:
> > Michal Hocko wrote:
> > > On Wed 14-06-17 16:43:03, David Rientjes wrote:
> > > > If mm->mm_users is not incremented because it is already zero by the oom
> > > > reaper, meaning the final refcount has been dropped, do not set
> > > > MMF_OOM_SKIP prematurely.
> > > > 
> > > > __mmput() may not have had a chance to do exit_mmap() yet, so memory from
> > > > a previous oom victim is still mapped.
> > > 
> > > true and do we have a _guarantee_ it will do it? E.g. can somebody block
> > > exit_aio from completing? Or can somebody hold mmap_sem and thus block
> > > ksm_exit resp. khugepaged_exit from completing? The reason why I was
> > > conservative and set such a mm as MMF_OOM_SKIP was because I couldn't
> > > give a definitive answer to those questions. And we really _want_ to
> > > have a guarantee of a forward progress here. Killing an additional
> > > proecess is a price to pay and if that doesn't trigger normall it sounds
> > > like a reasonable compromise to me.
> > 
> > Right. If you want this patch, __oom_reap_task_mm() must not return true without
> > setting MMF_OOM_SKIP (in other words, return false if __oom_reap_task_mm()
> > does not set MMF_OOM_SKIP). The most important role of the OOM reaper is to
> > guarantee that the OOM killer is re-enabled within finite time, for __mmput()
> > cannot guarantee that MMF_OOM_SKIP is set within finite time.
> 
> An alternative would be to allow reaping and exit_mmap race. The unmap
> part should just work I guess. We just have to be careful to not race
> with free_pgtables and that shouldn't be too hard to implement (e.g.
> (ab)use mmap_sem for write there). I haven't thought that through
> completely though so I might miss something of course.

Just to illustrate what I've had in mind. This is completely untested
(not even compile tested) and it may be completely broken but let's try
to evaluate this approach.
---
diff --git a/mm/mmap.c b/mm/mmap.c
index 3bd5ecd20d4d..761ba1dc9ec6 100644
--- a/mm/mmap.c
+++ b/mm/mmap.c
@@ -2962,7 +2962,13 @@ void exit_mmap(struct mm_struct *mm)
 	/* Use -1 here to ensure all VMAs in the mm are unmapped */
 	unmap_vmas(&tlb, vma, 0, -1);
 
+	/*
+	 * oom reaper might race with exit_mmap so make sure we won't free
+	 * page tables under its feet
+	 */
+	down_write(&mm->mmap_sem);
 	free_pgtables(&tlb, vma, FIRST_USER_ADDRESS, USER_PGTABLES_CEILING);
+	up_write(&mm->mmap_sem);
 	tlb_finish_mmu(&tlb, 0, -1);
 
 	/*
diff --git a/mm/oom_kill.c b/mm/oom_kill.c
index 0e2c925e7826..3df464f0f48b 100644
--- a/mm/oom_kill.c
+++ b/mm/oom_kill.c
@@ -494,16 +494,6 @@ static bool __oom_reap_task_mm(struct task_struct *tsk, struct mm_struct *mm)
 	}
 
 	/*
-	 * increase mm_users only after we know we will reap something so
-	 * that the mmput_async is called only when we have reaped something
-	 * and delayed __mmput doesn't matter that much
-	 */
-	if (!mmget_not_zero(mm)) {
-		up_read(&mm->mmap_sem);
-		goto unlock_oom;
-	}
-
-	/*
 	 * Tell all users of get_user/copy_from_user etc... that the content
 	 * is no longer stable. No barriers really needed because unmapping
 	 * should imply barriers already and the reader would hit a page fault
@@ -537,13 +527,6 @@ static bool __oom_reap_task_mm(struct task_struct *tsk, struct mm_struct *mm)
 			K(get_mm_counter(mm, MM_FILEPAGES)),
 			K(get_mm_counter(mm, MM_SHMEMPAGES)));
 	up_read(&mm->mmap_sem);
-
-	/*
-	 * Drop our reference but make sure the mmput slow path is called from a
-	 * different context because we shouldn't risk we get stuck there and
-	 * put the oom_reaper out of the way.
-	 */
-	mmput_async(mm);
 unlock_oom:
 	mutex_unlock(&oom_lock);
 	return ret;
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
