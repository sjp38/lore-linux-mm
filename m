Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f72.google.com (mail-ed1-f72.google.com [209.85.208.72])
	by kanga.kvack.org (Postfix) with ESMTP id 844528E0001
	for <linux-mm@kvack.org>; Mon, 10 Sep 2018 11:11:30 -0400 (EDT)
Received: by mail-ed1-f72.google.com with SMTP id 57-v6so7348331edt.15
        for <linux-mm@kvack.org>; Mon, 10 Sep 2018 08:11:30 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id n4-v6si1414231eda.62.2018.09.10.08.11.28
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 10 Sep 2018 08:11:29 -0700 (PDT)
Date: Mon, 10 Sep 2018 17:11:27 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [RFC PATCH 0/3] rework mmap-exit vs. oom_reaper handover
Message-ID: <20180910151127.GM10951@dhcp22.suse.cz>
References: <1536382452-3443-1-git-send-email-penguin-kernel@I-love.SAKURA.ne.jp>
 <20180910125513.311-1-mhocko@kernel.org>
 <cc772297-5aeb-8410-d902-c224f4717514@i-love.sakura.ne.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <cc772297-5aeb-8410-d902-c224f4717514@i-love.sakura.ne.jp>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>
Cc: linux-mm@kvack.org, Roman Gushchin <guro@fb.com>, Andrew Morton <akpm@linux-foundation.org>

On Mon 10-09-18 23:59:02, Tetsuo Handa wrote:
> Thank you for proposing a patch.
> 
> On 2018/09/10 21:55, Michal Hocko wrote:
> > diff --git a/mm/mmap.c b/mm/mmap.c
> > index 5f2b2b1..99bb9ce 100644
> > --- a/mm/mmap.c
> > +++ b/mm/mmap.c
> > @@ -3091,7 +3081,31 @@ void exit_mmap(struct mm_struct *mm)
> >  	/* update_hiwater_rss(mm) here? but nobody should be looking */
> >  	/* Use -1 here to ensure all VMAs in the mm are unmapped */
> >  	unmap_vmas(&tlb, vma, 0, -1);
> 
> unmap_vmas() might involve hugepage path. Is it safe to race with the OOM reaper?
> 
>   i_mmap_lock_write(vma->vm_file->f_mapping);
>   __unmap_hugepage_range_final(tlb, vma, start, end, NULL);
>   i_mmap_unlock_write(vma->vm_file->f_mapping);

We do not unmap hugetlb pages in the oom reaper.

> > -	free_pgtables(&tlb, vma, FIRST_USER_ADDRESS, USER_PGTABLES_CEILING);
> > +
> > +	/* oom_reaper cannot race with the page tables teardown */
> > +	if (oom)
> > +		down_write(&mm->mmap_sem);
> > +	/*
> > +	 * Hide vma from rmap and truncate_pagecache before freeing
> > +	 * pgtables
> > +	 */
> > +	while (vma) {
> > +		unlink_anon_vmas(vma);
> > +		unlink_file_vma(vma);
> > +		vma = vma->vm_next;
> > +	}
> > +	vma = mm->mmap;
> > +	if (oom) {
> > +		/*
> > +		 * the exit path is guaranteed to finish without any unbound
> > +		 * blocking at this stage so make it clear to the caller.
> > +		 */
> > +		mm->mmap = NULL;
> > +		up_write(&mm->mmap_sem);
> > +	}
> > +
> > +	free_pgd_range(&tlb, vma->vm_start, vma->vm_prev->vm_end,
> > +			FIRST_USER_ADDRESS, USER_PGTABLES_CEILING);
> 
> Are you trying to inline free_pgtables() here? But some architectures are
> using hugetlb_free_pgd_range() which does more than free_pgd_range(). Are
> they really safe (with regard to memory allocation dependency and flags
> manipulation) ?

This is something for me to double check of course. A cursory look
suggests that ppc just does some address manipulations because
free_pgtables can be called from the unmap path and that might cut a
mapping into non-hugeltb pieces. This is not possible in the full tear
down though.

> 
> >  	tlb_finish_mmu(&tlb, 0, -1);
> >  
> >  	/*
> 
> Also, how do you plan to give this thread enough CPU resources, for this thread might
> be SCHED_IDLE priority? Since this thread might not be a thread which is exiting
> (because this is merely a thread which invoked __mmput()), we can't use boosting
> approach. CPU resource might be given eventually unless schedule_timeout_*() is used,
> but it might be deadly slow if allocating threads keep wasting CPU resources.

This is OOM path which is glacial slow path. This is btw. no different
from any other low priority tasks sitting on a lot of memory trying to
release the memory (either by unmapping or exiting). Why should be this
particular case any different?

> Also, why MMF_OOM_SKIP will not be set if the OOM reaper handed over?

The idea is that the mm is not visible to anybody (except for the oom
reaper) anymore. So MMF_OOM_SKIP shouldn't matter.
-- 
Michal Hocko
SUSE Labs
