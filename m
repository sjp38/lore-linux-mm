Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f51.google.com (mail-pa0-f51.google.com [209.85.220.51])
	by kanga.kvack.org (Postfix) with ESMTP id E35476B003B
	for <linux-mm@kvack.org>; Thu,  4 Sep 2014 05:24:09 -0400 (EDT)
Received: by mail-pa0-f51.google.com with SMTP id rd3so19638579pab.38
        for <linux-mm@kvack.org>; Thu, 04 Sep 2014 02:24:08 -0700 (PDT)
Received: from ipmail05.adl6.internode.on.net (ipmail05.adl6.internode.on.net. [150.101.137.143])
        by mx.google.com with ESMTP id mu4si2246564pdb.253.2014.09.04.02.23.47
        for <linux-mm@kvack.org>;
        Thu, 04 Sep 2014 02:23:48 -0700 (PDT)
Date: Thu, 4 Sep 2014 19:23:29 +1000
From: Dave Chinner <david@fromorbit.com>
Subject: Re: [PATCH] mm: clear __GFP_FS when PF_MEMALLOC_NOIO is set
Message-ID: <20140904092329.GN20473@dastard>
References: <1409723694-16047-1-git-send-email-junxiao.bi@oracle.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1409723694-16047-1-git-send-email-junxiao.bi@oracle.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Junxiao Bi <junxiao.bi@oracle.com>
Cc: akpm@linux-foundation.org, xuejiufei@huawei.com, ming.lei@canonical.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org

On Wed, Sep 03, 2014 at 01:54:54PM +0800, Junxiao Bi wrote:
> commit 21caf2fc1931 ("mm: teach mm by current context info to not do I/O during memory allocation")
> introduces PF_MEMALLOC_NOIO flag to avoid doing I/O inside memory allocation, __GFP_IO is cleared
> when this flag is set, but __GFP_FS implies __GFP_IO, it should also be cleared. Or it may still
> run into I/O, like in superblock shrinker.
> 
> Signed-off-by: Junxiao Bi <junxiao.bi@oracle.com>
> Cc: joyce.xue <xuejiufei@huawei.com>
> Cc: Ming Lei <ming.lei@canonical.com>
> ---
>  include/linux/sched.h |    6 ++++--
>  1 file changed, 4 insertions(+), 2 deletions(-)
> 
> diff --git a/include/linux/sched.h b/include/linux/sched.h
> index 5c2c885..2fb2c47 100644
> --- a/include/linux/sched.h
> +++ b/include/linux/sched.h
> @@ -1936,11 +1936,13 @@ extern void thread_group_cputime_adjusted(struct task_struct *p, cputime_t *ut,
>  #define tsk_used_math(p) ((p)->flags & PF_USED_MATH)
>  #define used_math() tsk_used_math(current)
>  
> -/* __GFP_IO isn't allowed if PF_MEMALLOC_NOIO is set in current->flags */
> +/* __GFP_IO isn't allowed if PF_MEMALLOC_NOIO is set in current->flags
> + * __GFP_FS is also cleared as it implies __GFP_IO.
> + */
>  static inline gfp_t memalloc_noio_flags(gfp_t flags)
>  {
>  	if (unlikely(current->flags & PF_MEMALLOC_NOIO))
> -		flags &= ~__GFP_IO;
> +		flags &= ~(__GFP_IO | __GFP_FS);
>  	return flags;
>  }

You also need to mask all the shrink_control->gfp_mask
initialisations in mm/vmscan.c. The current code only masks the page
reclaim gfp_mask, not those that are passed to the shrinkers.

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
