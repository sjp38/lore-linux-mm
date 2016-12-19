Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wj0-f198.google.com (mail-wj0-f198.google.com [209.85.210.198])
	by kanga.kvack.org (Postfix) with ESMTP id D05236B0297
	for <linux-mm@kvack.org>; Mon, 19 Dec 2016 09:00:11 -0500 (EST)
Received: by mail-wj0-f198.google.com with SMTP id j10so47806126wjb.3
        for <linux-mm@kvack.org>; Mon, 19 Dec 2016 06:00:11 -0800 (PST)
Received: from mail-wm0-f66.google.com (mail-wm0-f66.google.com. [74.125.82.66])
        by mx.google.com with ESMTPS id up6si18618108wjc.5.2016.12.19.06.00.10
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 19 Dec 2016 06:00:10 -0800 (PST)
Received: by mail-wm0-f66.google.com with SMTP id a20so18863256wme.2
        for <linux-mm@kvack.org>; Mon, 19 Dec 2016 06:00:10 -0800 (PST)
Date: Mon, 19 Dec 2016 15:00:09 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH 4/4] oom-reaper: use madvise_dontneed() instead of
 unmap_page_range()
Message-ID: <20161219140008.GF5164@dhcp22.suse.cz>
References: <20161216141556.75130-1-kirill.shutemov@linux.intel.com>
 <20161216141556.75130-4-kirill.shutemov@linux.intel.com>
 <e9dd55e8-4cf0-0e91-ddeb-3004ca8fc611@I-love.SAKURA.ne.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <e9dd55e8-4cf0-0e91-ddeb-3004ca8fc611@I-love.SAKURA.ne.jp>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Peter Zijlstra <peterz@infradead.org>, Rik van Riel <riel@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Mon 19-12-16 20:39:24, Tetsuo Handa wrote:
> On 2016/12/16 23:15, Kirill A. Shutemov wrote:
> > Logic on whether we can reap pages from the VMA should match what we
> > have in madvise_dontneed(). In particular, we should skip, VM_PFNMAP
> > VMAs, but we don't now.
> > 
> > Let's just call madvise_dontneed() from __oom_reap_task_mm(), so we
> > won't need to sync the logic in the future.
> > 
> > Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
> > ---
> >  mm/internal.h |  7 +++----
> >  mm/madvise.c  |  2 +-
> >  mm/memory.c   |  2 +-
> >  mm/oom_kill.c | 15 ++-------------
> >  4 files changed, 7 insertions(+), 19 deletions(-)
> 
> madvise_dontneed() calls zap_page_range().
> zap_page_range() calls mmu_notifier_invalidate_range_start().
> mmu_notifier_invalidate_range_start() calls __mmu_notifier_invalidate_range_start().
> __mmu_notifier_invalidate_range_start() calls srcu_read_lock()/srcu_read_unlock().
> This means that madvise_dontneed() might sleep.
> 
> I don't know what individual notifier will do, but for example
> 
>   static const struct mmu_notifier_ops i915_gem_userptr_notifier = {
>           .invalidate_range_start = i915_gem_userptr_mn_invalidate_range_start,
>   };
> 
> i915_gem_userptr_mn_invalidate_range_start() calls flush_workqueue()
> which means that we can OOM livelock if work item involves memory allocation.
> Some of other notifiers call mutex_lock()/mutex_unlock().
> 
> Even if none of currently in-tree notifier users are blocked on memory
> allocation, I think it is not guaranteed that future changes/users won't be
> blocked on memory allocation.

Yes I agree. The reason I didn't go with zap_page_range was that I
didn't want to rely on any external code path. Moreover I believe that
we even do not have to care about mmu notifiers. The task is dead and
nobody should be watching its address space. If somebody still does then
it would get SEGV anyway. Or am I missing something?

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
