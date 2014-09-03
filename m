Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-vc0-f182.google.com (mail-vc0-f182.google.com [209.85.220.182])
	by kanga.kvack.org (Postfix) with ESMTP id 38D486B0035
	for <linux-mm@kvack.org>; Wed,  3 Sep 2014 08:20:36 -0400 (EDT)
Received: by mail-vc0-f182.google.com with SMTP id im17so8568876vcb.41
        for <linux-mm@kvack.org>; Wed, 03 Sep 2014 05:20:36 -0700 (PDT)
Received: from mail-vc0-f172.google.com (mail-vc0-f172.google.com [209.85.220.172])
        by mx.google.com with ESMTPS id ts8si798091vdc.34.2014.09.03.05.20.35
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Wed, 03 Sep 2014 05:20:35 -0700 (PDT)
Received: by mail-vc0-f172.google.com with SMTP id ij19so8671675vcb.17
        for <linux-mm@kvack.org>; Wed, 03 Sep 2014 05:20:35 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <1409723694-16047-1-git-send-email-junxiao.bi@oracle.com>
References: <1409723694-16047-1-git-send-email-junxiao.bi@oracle.com>
Date: Wed, 3 Sep 2014 08:20:35 -0400
Message-ID: <CAHQdGtTWjD5szmwtcv0fXxgmhdYea1h9wYddwhhPxnP5wBaToA@mail.gmail.com>
Subject: Re: [PATCH] mm: clear __GFP_FS when PF_MEMALLOC_NOIO is set
From: Trond Myklebust <trond.myklebust@primarydata.com>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Junxiao Bi <junxiao.bi@oracle.com>
Cc: david@fromorbit.com, akpm@linux-foundation.org, xuejiufei@huawei.com, ming.lei@canonical.com, Linux Kernel mailing list <linux-kernel@vger.kernel.org>, linux-mm@kvack.org, Devel FS Linux <linux-fsdevel@vger.kernel.org>

On Wed, Sep 3, 2014 at 1:54 AM, Junxiao Bi <junxiao.bi@oracle.com> wrote:
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
>         if (unlikely(current->flags & PF_MEMALLOC_NOIO))
> -               flags &= ~__GFP_IO;
> +               flags &= ~(__GFP_IO | __GFP_FS);
>         return flags;
>  }
>

Shouldn't this be a stable fix? If it is needed, then it will affect
all kernels that define PF_MEMALLOC_NOIO.

-- 
Trond Myklebust

Linux NFS client maintainer, PrimaryData

trond.myklebust@primarydata.com

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
