Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f69.google.com (mail-pg0-f69.google.com [74.125.83.69])
	by kanga.kvack.org (Postfix) with ESMTP id 59BCE6B0253
	for <linux-mm@kvack.org>; Thu,  7 Dec 2017 11:30:12 -0500 (EST)
Received: by mail-pg0-f69.google.com with SMTP id f8so5528243pgs.9
        for <linux-mm@kvack.org>; Thu, 07 Dec 2017 08:30:12 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id w9si2445279plp.783.2017.12.07.08.30.07
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 07 Dec 2017 08:30:07 -0800 (PST)
Date: Thu, 7 Dec 2017 17:30:03 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: Multiple oom_reaper BUGs: unmap_page_range racing with exit_mmap
Message-ID: <20171207163003.GM20234@dhcp22.suse.cz>
References: <alpine.DEB.2.10.1712051824050.91099@chino.kir.corp.google.com>
 <20171207113548.GG20234@dhcp22.suse.cz>
 <201712080044.BID56711.FFVOLMStJOQHOF@I-love.SAKURA.ne.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <201712080044.BID56711.FFVOLMStJOQHOF@I-love.SAKURA.ne.jp>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Cc: rientjes@google.com, akpm@linux-foundation.org, aarcange@redhat.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Fri 08-12-17 00:44:11, Tetsuo Handa wrote:
> Michal Hocko wrote:
> > David, could you test with this patch please?
> 
> Even if this patch solved David's case, you need to update
> 
> 	 * tsk_is_oom_victim() cannot be set from under us
> 	 * either because current->mm is already set to NULL
> 	 * under task_lock before calling mmput and oom_mm is
> 	 * set not NULL by the OOM killer only if current->mm
> 	 * is found not NULL while holding the task_lock.
> 
> part as well, for it is the explanation of why
> tsk_is_oom_victim() test was expected to work.

Yes, the same applies for mm_is_oom_victim. I will fixup s@tsk_@mm_@
here.

> Also, do we need to do
> 
>   set_bit(MMF_OOM_SKIP, &mm->flags);
> 
> if mm_is_oom_victim(mm) == false?

I do not think we really need to set MMF_OOM_SKIP if we are not going to
synchronize.

> exit_mmap() is called means that nobody can reach this mm
> except ->signal->oom_mm, and mm_is_oom_victim(mm) == false
> means that this mm cannot be reached by ->signal->oom_mm .
>
> Then, I think we do not need to set MMF_OOM_SKIP on this mm
> at exit_mmap() if mm_is_oom_victim(mm) == false.

yes. I will fold the following in if this turned out to really address
David's issue. But I suspect this will be the case considering the NULL
pmd in the report which would suggest racing with free_pgtable...

Thanks for the review!

---
diff --git a/mm/mmap.c b/mm/mmap.c
index d00a06248ef1..e63b7a576670 100644
--- a/mm/mmap.c
+++ b/mm/mmap.c
@@ -3004,7 +3004,6 @@ void exit_mmap(struct mm_struct *mm)
 	/* Use -1 here to ensure all VMAs in the mm are unmapped */
 	unmap_vmas(&tlb, vma, 0, -1);
 
-	set_bit(MMF_OOM_SKIP, &mm->flags);
 	if (unlikely(mm_is_oom_victim(mm))) {
 		/*
 		 * Wait for oom_reap_task() to stop working on this
@@ -3012,12 +3011,13 @@ void exit_mmap(struct mm_struct *mm)
 		 * calling down_read(), oom_reap_task() will not run
 		 * on this "mm" post up_write().
 		 *
-		 * tsk_is_oom_victim() cannot be set from under us
+		 * mm_is_oom_victim() cannot be set from under us
 		 * either because current->mm is already set to NULL
 		 * under task_lock before calling mmput and oom_mm is
 		 * set not NULL by the OOM killer only if current->mm
 		 * is found not NULL while holding the task_lock.
 		 */
+		set_bit(MMF_OOM_SKIP, &mm->flags);
 		down_write(&mm->mmap_sem);
 		up_write(&mm->mmap_sem);
 	}
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
