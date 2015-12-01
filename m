Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f46.google.com (mail-wm0-f46.google.com [74.125.82.46])
	by kanga.kvack.org (Postfix) with ESMTP id 6BBE06B0038
	for <linux-mm@kvack.org>; Tue,  1 Dec 2015 08:07:41 -0500 (EST)
Received: by wmec201 with SMTP id c201so204380556wme.0
        for <linux-mm@kvack.org>; Tue, 01 Dec 2015 05:07:41 -0800 (PST)
Received: from mail-wm0-f50.google.com (mail-wm0-f50.google.com. [74.125.82.50])
        by mx.google.com with ESMTPS id y127si35761919wmy.71.2015.12.01.05.07.40
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 01 Dec 2015 05:07:40 -0800 (PST)
Received: by wmww144 with SMTP id w144so12467831wmw.0
        for <linux-mm@kvack.org>; Tue, 01 Dec 2015 05:07:40 -0800 (PST)
Date: Tue, 1 Dec 2015 14:07:38 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [RFC PATCH -v2] mm, oom: introduce oom reaper
Message-ID: <20151201130738.GE4567@dhcp22.suse.cz>
References: <1448467018-20603-1-git-send-email-mhocko@kernel.org>
 <1448640772-30147-1-git-send-email-mhocko@kernel.org>
 <20151127163900.GY19677@suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20151127163900.GY19677@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>, David Rientjes <rientjes@google.com>, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, Rik van Riel <riel@redhat.com>, Hugh Dickins <hughd@google.com>, Oleg Nesterov <oleg@redhat.com>, Andrea Argangeli <andrea@kernel.org>, LKML <linux-kernel@vger.kernel.org>

On Fri 27-11-15 16:39:00, Mel Gorman wrote:
> On Fri, Nov 27, 2015 at 05:12:52PM +0100, Michal Hocko wrote:
> > From: Michal Hocko <mhocko@suse.com>
> > 
> > This is based on the idea from Mel Gorman discussed during LSFMM 2015 and
> > independently brought up by Oleg Nesterov.
> > 
> > <SNIP>
> > 
> > Signed-off-by: Michal Hocko <mhocko@suse.com>
> 
> Other than a few small issues below, I didn't spot anything out of the
> ordinary so
> 
> Acked-by: Mel Gorman <mgorman@suse.de>

Thanks!

> 
> > +	tlb_gather_mmu(&tlb, mm, 0, -1);
> > +	for (vma = mm->mmap ; vma; vma = vma->vm_next) {
> > +		if (is_vm_hugetlb_page(vma))
> > +			continue;
> > +
> > +		/*
> > +		 * Only anonymous pages have a good chance to be dropped
> > +		 * without additional steps which we cannot afford as we
> > +		 * are OOM already.
> > +		 */
> > +		if (vma_is_anonymous(vma) || !(vma->vm_flags & VM_SHARED))
> > +			unmap_page_range(&tlb, vma, vma->vm_start, vma->vm_end,
> > +					 &details);
> > +	}
> 
> Care to add a comment why clean file pages should not be discarded? I'm
> assuming it's because you assume they were discarded already by normal
> reclaim before OOM.

Yes that is exactly my thinking. We are OOM so all the reclaim attempts
have failed already. Clean page cache is highly improbable and we do not
want to waste cycles without a good reason. Even though oom_reaper thread
doesn't care so much about few cycles it still has mm ref count elevated
so it might block a real exit_mmap.

I will add a comment:
diff --git a/mm/oom_kill.c b/mm/oom_kill.c
index 3efd1efc8cd1..ece3eda4ee99 100644
--- a/mm/oom_kill.c
+++ b/mm/oom_kill.c
@@ -454,6 +454,11 @@ static bool __oom_reap_vmas(struct mm_struct *mm)
 		 * Only anonymous pages have a good chance to be dropped
 		 * without additional steps which we cannot afford as we
 		 * are OOM already.
+		 *
+		 * We do not even care about fs backed pages because all
+		 * which are reclaimable have already been reclaimed and
+		 * we do not want to block exit_mmap by keeping mm ref
+		 * count elevated without a good reason.
 		 */
 		if (vma_is_anonymous(vma) || !(vma->vm_flags & VM_SHARED))
 			unmap_page_range(&tlb, vma, vma->vm_start, vma->vm_end,

> There is a slightly possibility they are been kept
> alive because the OOM victim is constantly referencing them so they get
> activated or that there might be additional work to discard buffers but
> I'm not 100% sure that's your logic.
> 
> > @@ -421,6 +528,7 @@ void mark_oom_victim(struct task_struct *tsk)
> >  	/* OOM killer might race with memcg OOM */
> >  	if (test_and_set_tsk_thread_flag(tsk, TIF_MEMDIE))
> >  		return;
> > +
> >  	/*
> >  	 * Make sure that the task is woken up from uninterruptible sleep
> >  	 * if it is frozen because OOM killer wouldn't be able to free
> 
> Unnecessary whitespace change.

removed

> 
> > @@ -607,15 +716,23 @@ void oom_kill_process(struct oom_control *oc, struct task_struct *p,
> >  			continue;
> >  		if (same_thread_group(p, victim))
> >  			continue;
> > -		if (unlikely(p->flags & PF_KTHREAD))
> > -			continue;
> > -		if (p->signal->oom_score_adj == OOM_SCORE_ADJ_MIN)
> > +		if (unlikely(p->flags & PF_KTHREAD) ||
> > +		    p->signal->oom_score_adj == OOM_SCORE_ADJ_MIN) {
> > +			/*
> > +			 * We cannot usee oom_reaper for the mm shared by this process
> > +			 * because it wouldn't get killed and so the memory might be
> > +			 * still used.
> > +			 */
> > +			can_oom_reap = false;
> >  			continue;
> 
> s/usee/use/

Fixed

Thanks!
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
