Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f71.google.com (mail-ed1-f71.google.com [209.85.208.71])
	by kanga.kvack.org (Postfix) with ESMTP id 080CD6B0003
	for <linux-mm@kvack.org>; Fri, 13 Jul 2018 10:26:16 -0400 (EDT)
Received: by mail-ed1-f71.google.com with SMTP id b12-v6so12193702edi.12
        for <linux-mm@kvack.org>; Fri, 13 Jul 2018 07:26:15 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id r16-v6si872759eds.213.2018.07.13.07.26.13
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 13 Jul 2018 07:26:14 -0700 (PDT)
Date: Fri, 13 Jul 2018 16:26:12 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [patch -mm] mm, oom: remove oom_lock from exit_mmap
Message-ID: <20180713142612.GD19960@dhcp22.suse.cz>
References: <alpine.DEB.2.21.1807121432370.170100@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.21.1807121432370.170100@chino.kir.corp.google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Thu 12-07-18 14:34:00, David Rientjes wrote:
[...]
> diff --git a/mm/oom_kill.c b/mm/oom_kill.c
> index 0fe4087d5151..e6328cef090f 100644
> --- a/mm/oom_kill.c
> +++ b/mm/oom_kill.c
> @@ -488,9 +488,11 @@ void __oom_reap_task_mm(struct mm_struct *mm)
>  	 * Tell all users of get_user/copy_from_user etc... that the content
>  	 * is no longer stable. No barriers really needed because unmapping
>  	 * should imply barriers already and the reader would hit a page fault
> -	 * if it stumbled over a reaped memory.
> +	 * if it stumbled over a reaped memory. If MMF_UNSTABLE is already set,
> +	 * reaping as already occurred so nothing left to do.
>  	 */
> -	set_bit(MMF_UNSTABLE, &mm->flags);
> +	if (test_and_set_bit(MMF_UNSTABLE, &mm->flags))
> +		return;

This could lead to pre mature oom victim selection
oom_reaper			exiting victim
oom_reap_task			exit_mmap
  __oom_reap_task_mm		  __oom_reap_task_mm
				    test_and_set_bit(MMF_UNSTABLE) # wins the race
  test_and_set_bit(MMF_UNSTABLE)
set_bit(MMF_OOM_SKIP) # new victim can be selected now.

Besides that, why should we back off in the first place. We can
race the two without any problems AFAICS. We already do have proper
synchronization between the two due to mmap_sem and MMF_OOM_SKIP.

diff --git a/mm/mmap.c b/mm/mmap.c
index fc41c0543d7f..4642964f7741 100644
--- a/mm/mmap.c
+++ b/mm/mmap.c
@@ -3073,9 +3073,7 @@ void exit_mmap(struct mm_struct *mm)
 		 * which clears VM_LOCKED, otherwise the oom reaper cannot
 		 * reliably test it.
 		 */
-		mutex_lock(&oom_lock);
 		__oom_reap_task_mm(mm);
-		mutex_unlock(&oom_lock);
 
 		set_bit(MMF_OOM_SKIP, &mm->flags);
 		down_write(&mm->mmap_sem);
diff --git a/mm/oom_kill.c b/mm/oom_kill.c
index 32e6f7becb40..f11108af122d 100644
--- a/mm/oom_kill.c
+++ b/mm/oom_kill.c
@@ -529,28 +529,9 @@ void __oom_reap_task_mm(struct mm_struct *mm)
 
 static bool oom_reap_task_mm(struct task_struct *tsk, struct mm_struct *mm)
 {
-	bool ret = true;
-
-	/*
-	 * We have to make sure to not race with the victim exit path
-	 * and cause premature new oom victim selection:
-	 * oom_reap_task_mm		exit_mm
-	 *   mmget_not_zero
-	 *				  mmput
-	 *				    atomic_dec_and_test
-	 *				  exit_oom_victim
-	 *				[...]
-	 *				out_of_memory
-	 *				  select_bad_process
-	 *				    # no TIF_MEMDIE task selects new victim
-	 *  unmap_page_range # frees some memory
-	 */
-	mutex_lock(&oom_lock);
-
 	if (!down_read_trylock(&mm->mmap_sem)) {
-		ret = false;
 		trace_skip_task_reaping(tsk->pid);
-		goto unlock_oom;
+		return false;
 	}
 
 	/*
@@ -562,7 +543,7 @@ static bool oom_reap_task_mm(struct task_struct *tsk, struct mm_struct *mm)
 	if (mm_has_blockable_invalidate_notifiers(mm)) {
 		up_read(&mm->mmap_sem);
 		schedule_timeout_idle(HZ);
-		goto unlock_oom;
+		return true;
 	}
 
 	/*
@@ -589,9 +570,7 @@ static bool oom_reap_task_mm(struct task_struct *tsk, struct mm_struct *mm)
 	up_read(&mm->mmap_sem);
 
 	trace_finish_task_reaping(tsk->pid);
-unlock_oom:
-	mutex_unlock(&oom_lock);
-	return ret;
+	return true;
 }
 
 #define MAX_OOM_REAP_RETRIES 10
-- 
Michal Hocko
SUSE Labs
