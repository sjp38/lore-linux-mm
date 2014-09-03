Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f179.google.com (mail-ig0-f179.google.com [209.85.213.179])
	by kanga.kvack.org (Postfix) with ESMTP id AA6DF6B0035
	for <linux-mm@kvack.org>; Wed,  3 Sep 2014 19:10:02 -0400 (EDT)
Received: by mail-ig0-f179.google.com with SMTP id r2so114631igi.0
        for <linux-mm@kvack.org>; Wed, 03 Sep 2014 16:10:02 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id uz5si13545063pbc.204.2014.09.03.16.10.01
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 03 Sep 2014 16:10:01 -0700 (PDT)
Date: Wed, 3 Sep 2014 16:10:00 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH] mm: clear __GFP_FS when PF_MEMALLOC_NOIO is set
Message-Id: <20140903161000.f383fa4c1a4086de054cb6a0@linux-foundation.org>
In-Reply-To: <1409723694-16047-1-git-send-email-junxiao.bi@oracle.com>
References: <1409723694-16047-1-git-send-email-junxiao.bi@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Junxiao Bi <junxiao.bi@oracle.com>
Cc: david@fromorbit.com, xuejiufei@huawei.com, ming.lei@canonical.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org

On Wed,  3 Sep 2014 13:54:54 +0800 Junxiao Bi <junxiao.bi@oracle.com> wrote:

> commit 21caf2fc1931 ("mm: teach mm by current context info to not do I/O during memory allocation")
> introduces PF_MEMALLOC_NOIO flag to avoid doing I/O inside memory allocation, __GFP_IO is cleared
> when this flag is set, but __GFP_FS implies __GFP_IO, it should also be cleared. Or it may still
> run into I/O, like in superblock shrinker.

Is there an actual bug which inspired this fix?  If so, please describe
it.

I don't think it's accurate to say that __GFP_FS implies __GFP_IO. 
Where did that info come from?

And the superblock shrinker is a good example of why this shouldn't be
the case.  The main thing that code does is to reclaim clean fs objects
without performing IO.  AFAICT the proposed patch will significantly
weaken PF_MEMALLOC_NOIO allocation attempts by needlessly preventing
the kernel from reclaiming such objects?

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

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
