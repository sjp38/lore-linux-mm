Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f71.google.com (mail-oi0-f71.google.com [209.85.218.71])
	by kanga.kvack.org (Postfix) with ESMTP id BC0AF6B028D
	for <linux-mm@kvack.org>; Mon, 19 Dec 2016 06:39:45 -0500 (EST)
Received: by mail-oi0-f71.google.com with SMTP id j198so277113361oih.5
        for <linux-mm@kvack.org>; Mon, 19 Dec 2016 03:39:45 -0800 (PST)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [2001:e42:101:1:202:181:97:72])
        by mx.google.com with ESMTPS id a3si8987608ota.8.2016.12.19.03.39.44
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Mon, 19 Dec 2016 03:39:44 -0800 (PST)
Subject: Re: [PATCH 4/4] oom-reaper: use madvise_dontneed() instead of
 unmap_page_range()
References: <20161216141556.75130-1-kirill.shutemov@linux.intel.com>
 <20161216141556.75130-4-kirill.shutemov@linux.intel.com>
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Message-ID: <e9dd55e8-4cf0-0e91-ddeb-3004ca8fc611@I-love.SAKURA.ne.jp>
Date: Mon, 19 Dec 2016 20:39:24 +0900
MIME-Version: 1.0
In-Reply-To: <20161216141556.75130-4-kirill.shutemov@linux.intel.com>
Content-Type: text/plain; charset=iso-2022-jp
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Michal Hocko <mhocko@suse.com>, Peter Zijlstra <peterz@infradead.org>, Rik van Riel <riel@redhat.com>, Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org

On 2016/12/16 23:15, Kirill A. Shutemov wrote:
> Logic on whether we can reap pages from the VMA should match what we
> have in madvise_dontneed(). In particular, we should skip, VM_PFNMAP
> VMAs, but we don't now.
> 
> Let's just call madvise_dontneed() from __oom_reap_task_mm(), so we
> won't need to sync the logic in the future.
> 
> Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
> ---
>  mm/internal.h |  7 +++----
>  mm/madvise.c  |  2 +-
>  mm/memory.c   |  2 +-
>  mm/oom_kill.c | 15 ++-------------
>  4 files changed, 7 insertions(+), 19 deletions(-)

madvise_dontneed() calls zap_page_range().
zap_page_range() calls mmu_notifier_invalidate_range_start().
mmu_notifier_invalidate_range_start() calls __mmu_notifier_invalidate_range_start().
__mmu_notifier_invalidate_range_start() calls srcu_read_lock()/srcu_read_unlock().
This means that madvise_dontneed() might sleep.

I don't know what individual notifier will do, but for example

  static const struct mmu_notifier_ops i915_gem_userptr_notifier = {
          .invalidate_range_start = i915_gem_userptr_mn_invalidate_range_start,
  };

i915_gem_userptr_mn_invalidate_range_start() calls flush_workqueue()
which means that we can OOM livelock if work item involves memory allocation.
Some of other notifiers call mutex_lock()/mutex_unlock().

Even if none of currently in-tree notifier users are blocked on memory
allocation, I think it is not guaranteed that future changes/users won't be
blocked on memory allocation.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
