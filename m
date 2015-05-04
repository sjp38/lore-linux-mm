Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f42.google.com (mail-wg0-f42.google.com [74.125.82.42])
	by kanga.kvack.org (Postfix) with ESMTP id 700646B0038
	for <linux-mm@kvack.org>; Mon,  4 May 2015 14:02:28 -0400 (EDT)
Received: by wgin8 with SMTP id n8so158156909wgi.0
        for <linux-mm@kvack.org>; Mon, 04 May 2015 11:02:27 -0700 (PDT)
Received: from gum.cmpxchg.org (gum.cmpxchg.org. [85.214.110.215])
        by mx.google.com with ESMTPS id pi4si23851263wjb.84.2015.05.04.11.02.26
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 04 May 2015 11:02:26 -0700 (PDT)
Date: Mon, 4 May 2015 14:02:10 -0400
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [PATCH 0/9] mm: improve OOM mechanism v2
Message-ID: <20150504180210.GA2772@cmpxchg.org>
References: <1430161555-6058-1-git-send-email-hannes@cmpxchg.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1430161555-6058-1-git-send-email-hannes@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Michal Hocko <mhocko@suse.cz>, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, Andrea Arcangeli <aarcange@redhat.com>, Dave Chinner <david@fromorbit.com>, David Rientjes <rientjes@google.com>, Vlastimil Babka <vbabka@suse.cz>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

Hi Andrew,

since patches 8 and 9 are still controversial, would you mind picking
up just 1-7 for now?  They're cleaunps nice to have on their own.

Thanks,
Johannes

On Mon, Apr 27, 2015 at 03:05:46PM -0400, Johannes Weiner wrote:
> There is a possible deadlock scenario between the page allocator and
> the OOM killer.  Most allocations currently retry forever inside the
> page allocator, but when the OOM killer is invoked the chosen victim
> might try taking locks held by the allocating task.  This series, on
> top of many cleanups in the allocator & OOM killer, grants such OOM-
> killing allocations access to the system's memory reserves in order
> for them to make progress without relying on their own kill to exit.
> 
> Changes since v1:
> - drop GFP_NOFS deadlock fix (Dave Chinner)
> - drop low-order deadlock fix (Michal Hocko)
> - fix missing oom_lock in sysrq+f (Michal Hocko)
> - fix PAGE_ALLOC_COSTLY retry condition (Michal Hocko)
> - ALLOC_NO_WATERMARKS only for OOM victims, not all killed tasks (Tetsuo Handa)
> - bump OOM wait timeout from 1s to 5s (Vlastimil Babka & Michal Hocko)
> 
>  drivers/staging/android/lowmemorykiller.c |   2 +-
>  drivers/tty/sysrq.c                       |   2 +
>  include/linux/oom.h                       |  12 +-
>  kernel/exit.c                             |   2 +-
>  mm/memcontrol.c                           |  20 ++--
>  mm/oom_kill.c                             | 167 +++++++---------------------
>  mm/page_alloc.c                           | 161 ++++++++++++---------------
>  7 files changed, 137 insertions(+), 229 deletions(-)
> 
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
