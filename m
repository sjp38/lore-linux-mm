Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f46.google.com (mail-pa0-f46.google.com [209.85.220.46])
	by kanga.kvack.org (Postfix) with ESMTP id 101AE6B0038
	for <linux-mm@kvack.org>; Tue, 22 Sep 2015 01:13:22 -0400 (EDT)
Received: by padhy16 with SMTP id hy16so137078466pad.1
        for <linux-mm@kvack.org>; Mon, 21 Sep 2015 22:13:21 -0700 (PDT)
Received: from ipmail06.adl6.internode.on.net (ipmail06.adl6.internode.on.net. [150.101.137.145])
        by mx.google.com with ESMTP id k13si43111082pbq.238.2015.09.21.22.12.56
        for <linux-mm@kvack.org>;
        Mon, 21 Sep 2015 22:13:21 -0700 (PDT)
Date: Tue, 22 Sep 2015 15:12:53 +1000
From: Dave Chinner <david@fromorbit.com>
Subject: Re: [PATCH v2] xfs: Print comm name and pid when open-coded
 __GFP_NOFAIL allocation stucks
Message-ID: <20150922051253.GB3902@dastard>
References: <20150920231858.GY3902@dastard>
 <1442798637-5941-1-git-send-email-penguin-kernel@I-love.SAKURA.ne.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1442798637-5941-1-git-send-email-penguin-kernel@I-love.SAKURA.ne.jp>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Cc: xfs@oss.sgi.com, linux-mm@kvack.org, Michal Hocko <mhocko@suse.com>

On Mon, Sep 21, 2015 at 10:23:57AM +0900, Tetsuo Handa wrote:
> This patch adds comm name and pid to warning messages printed by
> kmem_alloc(), kmem_zone_alloc() and xfs_buf_allocate_memory().
> This will help telling which memory allocations (e.g. kernel worker
> threads, OOM victim tasks, neither) are stalling because these functions
> are passing __GFP_NOWARN which suppresses not only backtrace but comm name
> and pid.
> 
>   [  135.568662] Out of memory: Kill process 9593 (a.out) score 998 or sacrifice child
>   [  135.570195] Killed process 9593 (a.out) total-vm:4700kB, anon-rss:488kB, file-rss:0kB
>   [  137.473691] XFS: kworker/u16:29(383) possible memory allocation deadlock in xfs_buf_allocate_memory (mode:0x1250)
>   [  137.497662] XFS: a.out(8944) possible memory allocation deadlock in xfs_buf_allocate_memory (mode:0x1250)
>   [  137.598219] XFS: a.out(9658) possible memory allocation deadlock in xfs_buf_allocate_memory (mode:0x1250)
>   [  139.494529] XFS: kworker/u16:29(383) possible memory allocation deadlock in xfs_buf_allocate_memory (mode:0x1250)
>   [  139.517196] XFS: a.out(8944) possible memory allocation deadlock in xfs_buf_allocate_memory (mode:0x1250)
>   [  139.616396] XFS: a.out(9658) possible memory allocation deadlock in xfs_buf_allocate_memory (mode:0x1250)
>   [  141.512753] XFS: kworker/u16:29(383) possible memory allocation deadlock in xfs_buf_allocate_memory (mode:0x1250)
>   [  141.531421] XFS: a.out(8944) possible memory allocation deadlock in xfs_buf_allocate_memory (mode:0x1250)
>   [  141.633574] XFS: a.out(9658) possible memory allocation deadlock in xfs_buf_allocate_memory (mode:0x1250)
> 
> (Strictly speaking, we want task_lock()/task_unlock() when reading comm name.)
> 
> Signed-off-by: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
> Cc: Michal Hocko <mhocko@suse.com>
> ---
>  fs/xfs/kmem.c    | 10 ++++++----
>  fs/xfs/xfs_buf.c |  3 ++-
>  2 files changed, 8 insertions(+), 5 deletions(-)
> 
> diff --git a/fs/xfs/kmem.c b/fs/xfs/kmem.c
> index a7a3a63..735095a 100644
> --- a/fs/xfs/kmem.c
> +++ b/fs/xfs/kmem.c
> @@ -55,8 +55,9 @@ kmem_alloc(size_t size, xfs_km_flags_t flags)
>  			return ptr;
>  		if (!(++retries % 100))
>  			xfs_err(NULL,
> -		"possible memory allocation deadlock in %s (mode:0x%x)",
> -					__func__, lflags);
> +				"%s(%u) possible memory allocation deadlock in %s (mode:0x%x)",
> +				current->comm, current->pid,
> +				__func__, lflags);

<=80 columns, please.

Cheers,

Dave.
-- 
Dave Chinner
david@fromorbit.com

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
