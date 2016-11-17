Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f71.google.com (mail-wm0-f71.google.com [74.125.82.71])
	by kanga.kvack.org (Postfix) with ESMTP id 7051C6B0354
	for <linux-mm@kvack.org>; Thu, 17 Nov 2016 15:01:55 -0500 (EST)
Received: by mail-wm0-f71.google.com with SMTP id i131so57922859wmf.3
        for <linux-mm@kvack.org>; Thu, 17 Nov 2016 12:01:55 -0800 (PST)
Received: from mail-wm0-x232.google.com (mail-wm0-x232.google.com. [2a00:1450:400c:c09::232])
        by mx.google.com with ESMTPS id fj9si4330981wjb.13.2016.11.17.12.01.53
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 17 Nov 2016 12:01:53 -0800 (PST)
Received: by mail-wm0-x232.google.com with SMTP id f82so169541484wmf.1
        for <linux-mm@kvack.org>; Thu, 17 Nov 2016 12:01:53 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <1479376267-18486-1-git-send-email-mpe@ellerman.id.au>
References: <1479376267-18486-1-git-send-email-mpe@ellerman.id.au>
From: Kees Cook <keescook@chromium.org>
Date: Thu, 17 Nov 2016 12:01:51 -0800
Message-ID: <CAGXu5j++5zg8+uLyMfYgq4jiUg_1AM6kKyD_ZgKUczrsg2yiTA@mail.gmail.com>
Subject: Re: [PATCH v2] slab: Add POISON_POINTER_DELTA to ZERO_SIZE_PTR
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michael Ellerman <mpe@ellerman.id.au>
Cc: Andrew Morton <akpm@linux-foundation.org>, Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, "kernel-hardening@lists.openwall.com" <kernel-hardening@lists.openwall.com>

On Thu, Nov 17, 2016 at 1:51 AM, Michael Ellerman <mpe@ellerman.id.au> wrote:
> POISON_POINTER_DELTA is defined in poison.h, and is intended to be used
> to shift poison values so that they don't alias userspace.
>
> We should add it to ZERO_SIZE_PTR so that attackers can't use
> ZERO_SIZE_PTR as a way to get a non-NULL pointer to userspace.
>
> Currently ZERO_OR_NULL_PTR() uses a trick of doing a single check that
> x <= ZERO_SIZE_PTR, and ignoring the fact that it also matches 1-15.
> That no longer really works once we add the poison delta, so split it
> into two checks. Assign x to a temporary to avoid evaluating it
> twice (suggested by Kees Cook).
>
> Signed-off-by: Michael Ellerman <mpe@ellerman.id.au>

I continue to like this idea. If we want to avoid the loss of the 1-15
check, we could just explicitly retain it, see craziness below...

> ---
>  include/linux/slab.h | 10 +++++++---
>  1 file changed, 7 insertions(+), 3 deletions(-)
>
> v2: Rework ZERO_OR_NULL_PTR() to do the two checks separately.
>
> diff --git a/include/linux/slab.h b/include/linux/slab.h
> index 084b12bad198..404419d9860f 100644
> --- a/include/linux/slab.h
> +++ b/include/linux/slab.h
> @@ -12,6 +12,7 @@
>  #define        _LINUX_SLAB_H
>
>  #include <linux/gfp.h>
> +#include <linux/poison.h>
>  #include <linux/types.h>
>  #include <linux/workqueue.h>
>
> @@ -109,10 +110,13 @@
>   * ZERO_SIZE_PTR can be passed to kfree though in the same way that NULL can.
>   * Both make kfree a no-op.
>   */
> -#define ZERO_SIZE_PTR ((void *)16)

#define __ZERO_SIZE_PTR((void *)16)
#define ZERO_SIZE_PTR ((void *)(__ZERO_SIZE_PTR + POISON_POINTER_DELTA))

>
> -#define ZERO_OR_NULL_PTR(x) ((unsigned long)(x) <= \
> -                               (unsigned long)ZERO_SIZE_PTR)
> +#define ZERO_OR_NULL_PTR(x)                            \
> +       ({                                              \
> +               void *p = (void *)(x);                  \
              (p < __ZERO_SIZE_PTR || p == ZERO_SIZE_PTR);      \
> +       })

#undef __ZERO_SIZE_PTR

?

Anyone else have thoughts on this?

-Kees

-- 
Kees Cook
Nexus Security

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
