Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f69.google.com (mail-ed1-f69.google.com [209.85.208.69])
	by kanga.kvack.org (Postfix) with ESMTP id 3186B8E0001
	for <linux-mm@kvack.org>; Mon, 10 Sep 2018 12:44:15 -0400 (EDT)
Received: by mail-ed1-f69.google.com with SMTP id z56-v6so7404744edz.10
        for <linux-mm@kvack.org>; Mon, 10 Sep 2018 09:44:15 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id w45-v6si6100457edw.39.2018.09.10.09.44.13
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 10 Sep 2018 09:44:13 -0700 (PDT)
Date: Mon, 10 Sep 2018 18:44:11 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [RFC PATCH 0/3] rework mmap-exit vs. oom_reaper handover
Message-ID: <20180910164411.GN10951@dhcp22.suse.cz>
References: <1536382452-3443-1-git-send-email-penguin-kernel@I-love.SAKURA.ne.jp>
 <20180910125513.311-1-mhocko@kernel.org>
 <cc772297-5aeb-8410-d902-c224f4717514@i-love.sakura.ne.jp>
 <20180910151127.GM10951@dhcp22.suse.cz>
 <7e123109-fe7d-65cf-883e-74850fd2cf86@i-love.sakura.ne.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <7e123109-fe7d-65cf-883e-74850fd2cf86@i-love.sakura.ne.jp>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>
Cc: linux-mm@kvack.org, Roman Gushchin <guro@fb.com>, Andrew Morton <akpm@linux-foundation.org>

On Tue 11-09-18 00:40:23, Tetsuo Handa wrote:
> On 2018/09/11 0:11, Michal Hocko wrote:
> > On Mon 10-09-18 23:59:02, Tetsuo Handa wrote:
> >> Thank you for proposing a patch.
> >>
> >> On 2018/09/10 21:55, Michal Hocko wrote:
> >>> diff --git a/mm/mmap.c b/mm/mmap.c
> >>> index 5f2b2b1..99bb9ce 100644
> >>> --- a/mm/mmap.c
> >>> +++ b/mm/mmap.c
> >>> @@ -3091,7 +3081,31 @@ void exit_mmap(struct mm_struct *mm)
> >>>  	/* update_hiwater_rss(mm) here? but nobody should be looking */
> >>>  	/* Use -1 here to ensure all VMAs in the mm are unmapped */
> >>>  	unmap_vmas(&tlb, vma, 0, -1);
> >>
> >> unmap_vmas() might involve hugepage path. Is it safe to race with the OOM reaper?
> >>
> >>   i_mmap_lock_write(vma->vm_file->f_mapping);
> >>   __unmap_hugepage_range_final(tlb, vma, start, end, NULL);
> >>   i_mmap_unlock_write(vma->vm_file->f_mapping);
> > 
> > We do not unmap hugetlb pages in the oom reaper.
> > 
> 
> But the OOM reaper can run while __unmap_hugepage_range_final() is in progress.
> Then, I worry an overlooked race similar to clearing VM_LOCKED flag.

But VM_HUGETLB is a persistent flag unlike VM_LOCKED IIRC.
 
> >>>  	tlb_finish_mmu(&tlb, 0, -1);
> >>>  
> >>>  	/*
> >>
> >> Also, how do you plan to give this thread enough CPU resources, for this thread might
> >> be SCHED_IDLE priority? Since this thread might not be a thread which is exiting
> >> (because this is merely a thread which invoked __mmput()), we can't use boosting
> >> approach. CPU resource might be given eventually unless schedule_timeout_*() is used,
> >> but it might be deadly slow if allocating threads keep wasting CPU resources.
> > 
> > This is OOM path which is glacial slow path. This is btw. no different
> > from any other low priority tasks sitting on a lot of memory trying to
> > release the memory (either by unmapping or exiting). Why should be this
> > particular case any different?
> > 
> 
> Not a problem if not under OOM situation. Since the OOM killer keeps wasting
> CPU resources until memory reclaim completes, we want to solve OOM situation
> as soon as possible.

OK, it seems that yet again we have a deep disagreement here. The point
of the OOM is to get the system out of the desperate situation. The
objective is to free up _some_ memory. Your QoS is completely off at
that moment.
 
> >> Also, why MMF_OOM_SKIP will not be set if the OOM reaper handed over?
> > 
> > The idea is that the mm is not visible to anybody (except for the oom
> > reaper) anymore. So MMF_OOM_SKIP shouldn't matter.
> > 
> 
> I think it absolutely matters. The OOM killer waits until MMF_OOM_SKIP is set
> on a mm which is visible via task_struct->signal->oom_mm .

Hmm, I have to re-read the exit path once again and see when we unhash
the task and how many dangerous things we do in the mean time. I might
have been overly optimistic and you might be right that we indeed have
to set MMF_OOM_SKIP after all.
-- 
Michal Hocko
SUSE Labs
