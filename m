Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f72.google.com (mail-ed1-f72.google.com [209.85.208.72])
	by kanga.kvack.org (Postfix) with ESMTP id EA5768E0001
	for <linux-mm@kvack.org>; Fri, 14 Sep 2018 10:15:00 -0400 (EDT)
Received: by mail-ed1-f72.google.com with SMTP id r25-v6so3879000edc.7
        for <linux-mm@kvack.org>; Fri, 14 Sep 2018 07:15:00 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id 38-v6si609672edt.374.2018.09.14.07.14.59
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 14 Sep 2018 07:14:59 -0700 (PDT)
Date: Fri, 14 Sep 2018 16:14:57 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [RFC PATCH 0/3] rework mmap-exit vs. oom_reaper handover
Message-ID: <20180914141457.GB6081@dhcp22.suse.cz>
References: <70a92ca8-ca3e-2586-d52a-36c5ef6f7e43@i-love.sakura.ne.jp>
 <20180912075054.GZ10951@dhcp22.suse.cz>
 <20180912134203.GJ10951@dhcp22.suse.cz>
 <4ed2213e-c4ca-4ef2-2cc0-17b5c5447325@i-love.sakura.ne.jp>
 <20180913090950.GD20287@dhcp22.suse.cz>
 <c70a8b7c-d1d2-66de-d87e-13a4a410335b@i-love.sakura.ne.jp>
 <20180913113538.GE20287@dhcp22.suse.cz>
 <0897639b-a1d9-2da1-0a1e-a3eeed799a0f@i-love.sakura.ne.jp>
 <20180913134032.GF20287@dhcp22.suse.cz>
 <792a95e1-b81d-b220-f00b-27b7abf969f4@i-love.sakura.ne.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <792a95e1-b81d-b220-f00b-27b7abf969f4@i-love.sakura.ne.jp>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>
Cc: linux-mm@kvack.org, Roman Gushchin <guro@fb.com>, Andrew Morton <akpm@linux-foundation.org>, David Rientjes <rientjes@google.com>

On Fri 14-09-18 22:54:45, Tetsuo Handa wrote:
> On 2018/09/13 22:40, Michal Hocko wrote:
> > On Thu 13-09-18 20:53:24, Tetsuo Handa wrote:
> >> On 2018/09/13 20:35, Michal Hocko wrote:
> >>>> Next question.
> >>>>
> >>>>         /* Use -1 here to ensure all VMAs in the mm are unmapped */
> >>>>         unmap_vmas(&tlb, vma, 0, -1);
> >>>>
> >>>> in exit_mmap() will now race with the OOM reaper. And unmap_vmas() will handle
> >>>> VM_HUGETLB or VM_PFNMAP or VM_SHARED or !vma_is_anonymous() vmas, won't it?
> >>>> Then, is it guaranteed to be safe if the OOM reaper raced with unmap_vmas() ?
> >>>
> >>> I do not understand the question. unmap_vmas is basically MADV_DONTNEED
> >>> and that doesn't require the exclusive mmap_sem lock so yes it should be
> >>> safe those two to race (modulo bugs of course but I am not aware of any
> >>> there).
> >>>  
> >>
> >> You need to verify that races we observed with VM_LOCKED can't happen
> >> for VM_HUGETLB / VM_PFNMAP / VM_SHARED / !vma_is_anonymous() cases.
> > 
> > Well, VM_LOCKED is kind of special because that is not a permanent state
> > which might change. VM_HUGETLB, VM_PFNMAP resp VM_SHARED are not changed
> > throughout the vma lifetime.
> > 
> OK, next question.
> Is it guaranteed that arch_exit_mmap(mm) is safe with the OOM reaper?

I do not see any obvious problem and we used to allow to race unmaping
in exit and oom_reaper paths before we had to handle mlocked vmas
specially.
 
> Well, anyway, diffstat of your proposal would be
> 
>  include/linux/oom.h |  2 --
>  mm/internal.h       |  3 +++
>  mm/memory.c         | 28 ++++++++++++--------
>  mm/mmap.c           | 73 +++++++++++++++++++++++++++++++----------------------
>  mm/oom_kill.c       | 46 ++++++++++++++++++++++++---------
>  5 files changed, 98 insertions(+), 54 deletions(-)
> 
> trying to hand over only __free_pgtables() part at the risk of
> setting MMF_OOM_SKIP without reclaiming any memory due to dropping
> __oom_reap_task_mm() and scattering down_write()/up_write() inside
> exit_mmap(), while diffstat of my proposal (not tested yet) would be
> 
>  include/linux/mm_types.h |   2 +
>  include/linux/oom.h      |   3 +-
>  include/linux/sched.h    |   2 +-
>  kernel/fork.c            |  11 +++
>  mm/mmap.c                |  42 ++++-------
>  mm/oom_kill.c            | 182 ++++++++++++++++++++++-------------------------
>  6 files changed, 117 insertions(+), 125 deletions(-)
> 
> trying to wait until __mmput() completes and also trying to handle
> multiple OOM victims in parallel.
> 
> You are refusing timeout based approach but I don't think this is
> something we have to be frayed around the edge about possibility of
> overlooking races/bugs because you don't want to use timeout. And you
> have never showed that timeout based approach cannot work well enough.

I have tried to explain why I do not like the timeout based approach
several times alreay and I am getting fed up repeating it over and over
again.  The main point though is that we know _what_ we are waiting for
and _how_ we are synchronizing different parts rather than let's wait
some time and hopefully something happens.

Moreover, we have a backoff mechanism. The new class of oom victims
with a large amount of memory in page tables can fit into that
model. The new model adds few more branches to the exit path so if this
is acceptable for other mm developers then I think this is much more
preferrable to add a diffrent retry mechanism.
-- 
Michal Hocko
SUSE Labs
