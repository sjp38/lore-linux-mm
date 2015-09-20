Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f45.google.com (mail-pa0-f45.google.com [209.85.220.45])
	by kanga.kvack.org (Postfix) with ESMTP id DF8936B0253
	for <linux-mm@kvack.org>; Sun, 20 Sep 2015 19:19:02 -0400 (EDT)
Received: by padhy16 with SMTP id hy16so99040988pad.1
        for <linux-mm@kvack.org>; Sun, 20 Sep 2015 16:19:02 -0700 (PDT)
Received: from ipmail04.adl6.internode.on.net (ipmail04.adl6.internode.on.net. [150.101.137.141])
        by mx.google.com with ESMTP id sx6si33267667pbc.55.2015.09.20.16.19.00
        for <linux-mm@kvack.org>;
        Sun, 20 Sep 2015 16:19:01 -0700 (PDT)
Date: Mon, 21 Sep 2015 09:18:58 +1000
From: Dave Chinner <david@fromorbit.com>
Subject: Re: [PATCH 2/2] xfs: Print comm name and pid when open-coded
 __GFP_NOFAIL allocation stucks
Message-ID: <20150920231858.GY3902@dastard>
References: <1442732594-4205-1-git-send-email-penguin-kernel@I-love.SAKURA.ne.jp>
 <1442732594-4205-2-git-send-email-penguin-kernel@I-love.SAKURA.ne.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1442732594-4205-2-git-send-email-penguin-kernel@I-love.SAKURA.ne.jp>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Cc: xfs@oss.sgi.com, linux-mm@kvack.org, Michal Hocko <mhocko@suse.com>

On Sun, Sep 20, 2015 at 04:03:14PM +0900, Tetsuo Handa wrote:
> This patch adds comm name and pid to warning messages printed by
> kmem_alloc(), kmem_zone_alloc() and xfs_buf_allocate_memory().
> This will help telling which memory allocations (e.g. kernel worker
> threads, OOM victim tasks, neither) are stalling.
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
>  fs/xfs/kmem.c    | 6 ++++--
>  fs/xfs/xfs_buf.c | 3 ++-
>  2 files changed, 6 insertions(+), 3 deletions(-)
> 
> diff --git a/fs/xfs/kmem.c b/fs/xfs/kmem.c
> index 1fcf90d..95a5b76 100644
> --- a/fs/xfs/kmem.c
> +++ b/fs/xfs/kmem.c
> @@ -54,8 +54,9 @@ kmem_alloc(size_t size, xfs_km_flags_t flags)
>  		if (ptr || (flags & (KM_MAYFAIL|KM_NOSLEEP)))
>  			return ptr;
>  		if (!(++retries % 100))
> -			xfs_err(NULL,
> +			xfs_err(NULL, "%s(%u) "
>  		"possible memory allocation deadlock in %s (mode:0x%x)",
> +					current->comm, current->pid,
>  					__func__, lflags);

The format string will fit on a single line:

		"%s(%u): Possible memory allocation deadlock in %s (mode:0x%x)",

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
