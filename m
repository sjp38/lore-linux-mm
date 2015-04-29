Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f45.google.com (mail-pa0-f45.google.com [209.85.220.45])
	by kanga.kvack.org (Postfix) with ESMTP id 42A2E6B0032
	for <linux-mm@kvack.org>; Wed, 29 Apr 2015 00:58:12 -0400 (EDT)
Received: by pacyx8 with SMTP id yx8so16918611pac.1
        for <linux-mm@kvack.org>; Tue, 28 Apr 2015 21:58:12 -0700 (PDT)
Received: from mail-pa0-x232.google.com (mail-pa0-x232.google.com. [2607:f8b0:400e:c03::232])
        by mx.google.com with ESMTPS id f3si37788233pdl.5.2015.04.28.21.58.11
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 28 Apr 2015 21:58:11 -0700 (PDT)
Received: by pabsx10 with SMTP id sx10so16819496pab.3
        for <linux-mm@kvack.org>; Tue, 28 Apr 2015 21:58:11 -0700 (PDT)
Date: Wed, 29 Apr 2015 13:57:59 +0900
From: Minchan Kim <minchan@kernel.org>
Subject: Re: [PATCH v3 3/3] proc: add kpageidle file
Message-ID: <20150429045759.GA27051@blaptop>
References: <cover.1430217477.git.vdavydov@parallels.com>
 <4c24a6bf2c9711dd4dbb72a43a16eba6867527b7.1430217477.git.vdavydov@parallels.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <4c24a6bf2c9711dd4dbb72a43a16eba6867527b7.1430217477.git.vdavydov@parallels.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vladimir Davydov <vdavydov@parallels.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>, Greg Thelen <gthelen@google.com>, Michel Lespinasse <walken@google.com>, David Rientjes <rientjes@google.com>, Pavel Emelyanov <xemul@parallels.com>, Cyrill Gorcunov <gorcunov@openvz.org>, Jonathan Corbet <corbet@lwn.net>, linux-api@vger.kernel.org, linux-doc@vger.kernel.org, linux-mm@kvack.org, cgroups@vger.kernel.org, linux-kernel@vger.kernel.org

On Tue, Apr 28, 2015 at 03:24:42PM +0300, Vladimir Davydov wrote:
> Knowing the portion of memory that is not used by a certain application
> or memory cgroup (idle memory) can be useful for partitioning the system
> efficiently, e.g. by setting memory cgroup limits appropriately.
> Currently, the only means to estimate the amount of idle memory provided
> by the kernel is /proc/PID/{clear_refs,smaps}: the user can clear the
> access bit for all pages mapped to a particular process by writing 1 to
> clear_refs, wait for some time, and then count smaps:Referenced.
> However, this method has two serious shortcomings:
> 
>  - it does not count unmapped file pages
>  - it affects the reclaimer logic
> 
> To overcome these drawbacks, this patch introduces two new page flags,
> Idle and Young, and a new proc file, /proc/kpageidle. A page's Idle flag
> can only be set from userspace by writing 1 to /proc/kpageidle at the
> offset corresponding to the page, and it is cleared whenever the page is
> accessed either through page tables (it is cleared in page_referenced()
> in this case) or using the read(2) system call (mark_page_accessed()).
> Thus by setting the Idle flag for pages of a particular workload, which
> can be found e.g. by reading /proc/PID/pagemap, waiting for some time to
> let the workload access its working set, and then reading the kpageidle
> file, one can estimate the amount of pages that are not used by the
> workload.
> 
> The Young page flag is used to avoid interference with the memory
> reclaimer. A page's Young flag is set whenever the Access bit of a page
> table entry pointing to the page is cleared by writing to kpageidle. If
> page_referenced() is called on a Young page, it will add 1 to its return
> value, therefore concealing the fact that the Access bit was cleared.
> 
> Note, since there is no room for extra page flags on 32 bit, this
> feature uses extended page flags when compiled on 32 bit.
> 
> Signed-off-by: Vladimir Davydov <vdavydov@parallels.com>
> ---
>  Documentation/vm/pagemap.txt |   10 ++-
>  fs/proc/page.c               |  154 ++++++++++++++++++++++++++++++++++++++++++
>  fs/proc/task_mmu.c           |    4 +-
>  include/linux/mm.h           |   88 ++++++++++++++++++++++++
>  include/linux/page-flags.h   |    9 +++
>  include/linux/page_ext.h     |    4 ++
>  mm/Kconfig                   |   12 ++++
>  mm/debug.c                   |    4 ++
>  mm/page_ext.c                |    3 +
>  mm/rmap.c                    |    7 ++
>  mm/swap.c                    |    2 +
>  11 files changed, 295 insertions(+), 2 deletions(-)
> 
> diff --git a/Documentation/vm/pagemap.txt b/Documentation/vm/pagemap.txt
> index a9b7afc8fbc6..ac6fd32a9296 100644
> --- a/Documentation/vm/pagemap.txt
> +++ b/Documentation/vm/pagemap.txt
> @@ -5,7 +5,7 @@ pagemap is a new (as of 2.6.25) set of interfaces in the kernel that allow
>  userspace programs to examine the page tables and related information by
>  reading files in /proc.
>  
> -There are four components to pagemap:
> +There are five components to pagemap:
>  
>   * /proc/pid/pagemap.  This file lets a userspace process find out which
>     physical frame each virtual page is mapped to.  It contains one 64-bit
> @@ -69,6 +69,14 @@ There are four components to pagemap:
>     memory cgroup each page is charged to, indexed by PFN. Only available when
>     CONFIG_MEMCG is set.
>  
> + * /proc/kpageidle.  For each page this file contains a 64-bit number, which
> +   equals 1 if the page is idle or 0 otherwise, indexed by PFN. A page is
> +   considered idle if it has not been accessed since it was marked idle. To
> +   mark a page idle one should write 1 to this file at the offset corresponding
> +   to the page. Only user memory pages can be marked idle, for other page types
> +   input is silently ignored. Writing to this file beyond max PFN results in
> +   the ENXIO error. Only available when CONFIG_IDLE_PAGE_TRACKING is set.
> +

How about using kpageflags for reading part?

I mean PG_idle is one of the page flags and we already have a feature to
parse of each PFN flag so we could reuse existing feature for reading
idleness.

-- 
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
