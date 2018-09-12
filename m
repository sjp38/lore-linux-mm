Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f69.google.com (mail-ed1-f69.google.com [209.85.208.69])
	by kanga.kvack.org (Postfix) with ESMTP id CB5F58E0001
	for <linux-mm@kvack.org>; Wed, 12 Sep 2018 03:18:45 -0400 (EDT)
Received: by mail-ed1-f69.google.com with SMTP id 57-v6so478725edt.15
        for <linux-mm@kvack.org>; Wed, 12 Sep 2018 00:18:45 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id c10-v6si533682edk.121.2018.09.12.00.18.44
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 12 Sep 2018 00:18:44 -0700 (PDT)
Date: Wed, 12 Sep 2018 09:18:42 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [RFC PATCH 0/3] rework mmap-exit vs. oom_reaper handover
Message-ID: <20180912071842.GY10951@dhcp22.suse.cz>
References: <7e123109-fe7d-65cf-883e-74850fd2cf86@i-love.sakura.ne.jp>
 <20180910164411.GN10951@dhcp22.suse.cz>
 <201809120306.w8C36JbS080965@www262.sakura.ne.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <201809120306.w8C36JbS080965@www262.sakura.ne.jp>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>
Cc: linux-mm@kvack.org, Roman Gushchin <guro@fb.com>, Andrew Morton <akpm@linux-foundation.org>

On Wed 12-09-18 12:06:19, Tetsuo Handa wrote:
> Michal Hocko wrote:
> > On Tue 11-09-18 00:40:23, Tetsuo Handa wrote:
> > > >> Also, why MMF_OOM_SKIP will not be set if the OOM reaper handed over?
> > > > 
> > > > The idea is that the mm is not visible to anybody (except for the oom
> > > > reaper) anymore. So MMF_OOM_SKIP shouldn't matter.
> > > > 
> > > 
> > > I think it absolutely matters. The OOM killer waits until MMF_OOM_SKIP is set
> > > on a mm which is visible via task_struct->signal->oom_mm .
> > 
> > Hmm, I have to re-read the exit path once again and see when we unhash
> > the task and how many dangerous things we do in the mean time. I might
> > have been overly optimistic and you might be right that we indeed have
> > to set MMF_OOM_SKIP after all.
> 
> What a foolhardy attempt!
> 
> Commit d7a94e7e11badf84 ("oom: don't count on mm-less current process") says
> 
>     out_of_memory() doesn't trigger the OOM killer if the current task is
>     already exiting or it has fatal signals pending, and gives the task
>     access to memory reserves instead.  However, doing so is wrong if
>     out_of_memory() is called by an allocation (e.g. from exit_task_work())
>     after the current task has already released its memory and cleared
>     TIF_MEMDIE at exit_mm().  If we again set TIF_MEMDIE to post-exit_mm()
>     current task, the OOM killer will be blocked by the task sitting in the
>     final schedule() waiting for its parent to reap it.  It will trigger an
>     OOM livelock if its parent is unable to reap it due to doing an
>     allocation and waiting for the OOM killer to kill it.
> 
> and your
> 
> +               /*
> +                * the exit path is guaranteed to finish without any unbound
> +                * blocking at this stage so make it clear to the caller.
> +                */

This comment was meant to tell that the tear down will not block for
unbound amount of time.

> attempt is essentially same with "we keep TIF_MEMDIE of post-exit_mm() task".
> 
> That is, we can't expect that the OOM victim can finish without any unbound
> blocking. We have no choice but timeout based heuristic if we don't want to
> set MMF_OOM_SKIP even with your customized version of free_pgtables().

OK, I will fold the following to the patch

commit e57a1e84db95906e6505de26db896f1b66b5b057
Author: Michal Hocko <mhocko@suse.com>
Date:   Tue Sep 11 13:09:16 2018 +0200

    fold me "mm, oom: hand over MMF_OOM_SKIP to exit path if it is guranteed to finish"
    
    - the task is still visible to the OOM killer after exit_mmap terminates
      so we should set MMF_OOM_SKIP from that path to be sure the oom killer
      doesn't get stuck on this task (see d7a94e7e11badf84 for more context)
      - per Tetsuo

diff --git a/mm/mmap.c b/mm/mmap.c
index 99bb9ce29bc5..64e8ccce5282 100644
--- a/mm/mmap.c
+++ b/mm/mmap.c
@@ -3097,8 +3097,9 @@ void exit_mmap(struct mm_struct *mm)
 	vma = mm->mmap;
 	if (oom) {
 		/*
-		 * the exit path is guaranteed to finish without any unbound
-		 * blocking at this stage so make it clear to the caller.
+		 * the exit path is guaranteed to finish the memory tear down
+		 * without any unbound blocking at this stage so make it clear
+		 * to the oom_reaper
 		 */
 		mm->mmap = NULL;
 		up_write(&mm->mmap_sem);
@@ -3118,6 +3119,13 @@ void exit_mmap(struct mm_struct *mm)
 		vma = remove_vma(vma);
 	}
 	vm_unacct_memory(nr_accounted);
+
+	/*
+	 * Now that the full address space is torn down, make sure the
+	 * OOM killer skips over this task
+	 */
+	if (oom)
+		set_bit(MMF_OOM_SKIP, &mm->flags);
 }
 
 /* Insert vm structure into process list sorted by address

-- 
Michal Hocko
SUSE Labs
