Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-vc0-f174.google.com (mail-vc0-f174.google.com [209.85.220.174])
	by kanga.kvack.org (Postfix) with ESMTP id 454746B0036
	for <linux-mm@kvack.org>; Wed, 10 Sep 2014 10:33:53 -0400 (EDT)
Received: by mail-vc0-f174.google.com with SMTP id hy10so4248479vcb.5
        for <linux-mm@kvack.org>; Wed, 10 Sep 2014 07:33:53 -0700 (PDT)
Received: from mail-vc0-x229.google.com (mail-vc0-x229.google.com [2607:f8b0:400c:c03::229])
        by mx.google.com with ESMTPS id iy2si7036334vdb.3.2014.09.10.07.33.52
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Wed, 10 Sep 2014 07:33:52 -0700 (PDT)
Received: by mail-vc0-f169.google.com with SMTP id ik5so2137302vcb.14
        for <linux-mm@kvack.org>; Wed, 10 Sep 2014 07:33:52 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <alpine.LNX.2.00.1409101613500.5523@pobox.suse.cz>
References: <alpine.LNX.2.00.1409092319370.5523@pobox.suse.cz>
	<20140909162114.44b3e98cf925f125e84a8a06@linux-foundation.org>
	<alpine.LNX.2.00.1409100702190.5523@pobox.suse.cz>
	<20140910140759.GC31903@thunk.org>
	<alpine.LNX.2.00.1409101613500.5523@pobox.suse.cz>
Date: Wed, 10 Sep 2014 18:33:52 +0400
Message-ID: <CAPAsAGyYoPjThA1EV46jYiGX2UzqF1oD4JJueNKh9V1XvAXjcA@mail.gmail.com>
Subject: Re: [PATCH] mm/sl[aou]b: make kfree() aware of error pointers
From: Andrey Ryabinin <ryabinin.a.a@gmail.com>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jiri Kosina <jkosina@suse.cz>
Cc: Theodore Ts'o <tytso@mit.edu>, Andrew Morton <akpm@linux-foundation.org>, Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, LKML <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Dan Carpenter <dan.carpenter@oracle.com>

2014-09-10 18:24 GMT+04:00 Jiri Kosina <jkosina@suse.cz>:
> On Wed, 10 Sep 2014, Theodore Ts'o wrote:
>
>> So I wouldn't be so sure that we don't have these sorts of bugs hiding
>> somewhere; and it's extremely easy for them to sneak in.  That being
>> said, I'm not in favor of making changes to kfree; I'd much rather
>> depending on better testing and static checkers to fix them, since
>> kfree *is* a hot path.
>
> I of course have no objections to this check being added to whatever
> static checker, that would be very welcome improvement.
>
> Still, I believe that kernel shouldn't be just ignoring kfree(ERR_PTR)
> happening. Would something like the below be more acceptable?
>
>
>
> From: Jiri Kosina <jkosina@suse.cz>
> Subject: [PATCH] mm/sl[aou]b: make kfree() aware of error pointers
>
> Freeing if ERR_PTR is not covered by ZERO_OR_NULL_PTR() check already
> present in kfree(), but it happens in the wild and has disastrous effects.
>
> Issue a warning and don't proceed trying to free the memory if
> CONFIG_DEBUG_SLAB is set.
>

This won't work cause CONFIG_DEBUG_SLAB  is only for CONFIG_SLAB=y

How about just VM_BUG_ON(IS_ERR(ptr)); ?


> Inspired by a9cfcd63e8d ("ext4: avoid trying to kfree an ERR_PTR pointer").
>
> Signed-off-by: Jiri Kosina <jkosina@suse.cz>
> ---
>  mm/slab.c | 6 ++++++
>  mm/slob.c | 7 ++++++-
>  mm/slub.c | 7 ++++++-
>  3 files changed, 18 insertions(+), 2 deletions(-)
>
> diff --git a/mm/slab.c b/mm/slab.c
> index a467b30..6f49d6b 100644
> --- a/mm/slab.c
> +++ b/mm/slab.c
> @@ -3612,6 +3612,12 @@ void kfree(const void *objp)
>
>         trace_kfree(_RET_IP_, objp);
>
> +#ifdef CONFIG_DEBUG_SLAB
> +       if (unlikely(IS_ERR(objp))) {
> +                       WARN(1, "trying to free ERR_PTR\n");
> +                       return;
> +       }
> +#endif
>         if (unlikely(ZERO_OR_NULL_PTR(objp)))
>                 return;
>         local_irq_save(flags);
> diff --git a/mm/slob.c b/mm/slob.c
> index 21980e0..66422a0 100644
> --- a/mm/slob.c
> +++ b/mm/slob.c
> @@ -488,7 +488,12 @@ void kfree(const void *block)
>         struct page *sp;
>
>         trace_kfree(_RET_IP_, block);
> -
> +#ifdef CONFIG_DEBUG_SLAB
> +       if (unlikely(IS_ERR(block))) {
> +               WARN(1, "trying to free ERR_PTR\n");
> +               return;
> +       }
> +#endif
>         if (unlikely(ZERO_OR_NULL_PTR(block)))
>                 return;
>         kmemleak_free(block);
> diff --git a/mm/slub.c b/mm/slub.c
> index 3e8afcc..21155ae 100644
> --- a/mm/slub.c
> +++ b/mm/slub.c
> @@ -3337,7 +3337,12 @@ void kfree(const void *x)
>         void *object = (void *)x;
>
>         trace_kfree(_RET_IP_, x);
> -
> +#ifdef CONFIG_DEBUG_SLAB
> +       if (unlikely(IS_ERR(x))) {
> +               WARN(1, "trying to free ERR_PTR\n");
> +               return;
> +       }
> +#endif
>         if (unlikely(ZERO_OR_NULL_PTR(x)))
>                 return;
>
>
> --
> Jiri Kosina
> SUSE Labs
>
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>



-- 
Best regards,
Andrey Ryabinin

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
