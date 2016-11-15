Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f70.google.com (mail-wm0-f70.google.com [74.125.82.70])
	by kanga.kvack.org (Postfix) with ESMTP id D083D6B02A6
	for <linux-mm@kvack.org>; Tue, 15 Nov 2016 12:37:40 -0500 (EST)
Received: by mail-wm0-f70.google.com with SMTP id m203so4883092wma.2
        for <linux-mm@kvack.org>; Tue, 15 Nov 2016 09:37:40 -0800 (PST)
Received: from mail-wm0-x22f.google.com (mail-wm0-x22f.google.com. [2a00:1450:400c:c09::22f])
        by mx.google.com with ESMTPS id v186si3877368wma.24.2016.11.15.09.37.39
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 15 Nov 2016 09:37:39 -0800 (PST)
Received: by mail-wm0-x22f.google.com with SMTP id g23so181799218wme.1
        for <linux-mm@kvack.org>; Tue, 15 Nov 2016 09:37:39 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <1479207422-6535-1-git-send-email-mpe@ellerman.id.au>
References: <1479207422-6535-1-git-send-email-mpe@ellerman.id.au>
From: Kees Cook <keescook@chromium.org>
Date: Tue, 15 Nov 2016 09:37:37 -0800
Message-ID: <CAGXu5j+3pD7Ss_PBY9H_A6B5-Ers2wYqFJ1y4iryKzqc=jCxXg@mail.gmail.com>
Subject: Re: [PATCH] slab: Add POISON_POINTER_DELTA to ZERO_SIZE_PTR
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michael Ellerman <mpe@ellerman.id.au>
Cc: Andrew Morton <akpm@linux-foundation.org>, Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, "kernel-hardening@lists.openwall.com" <kernel-hardening@lists.openwall.com>

On Tue, Nov 15, 2016 at 2:57 AM, Michael Ellerman <mpe@ellerman.id.au> wrote:
> POISON_POINTER_DELTA is defined in poison.h, and is intended to be used
> to shift poison values so that they don't alias userspace.
>
> We should add it to ZERO_SIZE_PTR so that attackers can't use
> ZERO_SIZE_PTR as a way to get a pointer to userspace.

Ah, when dealing with a 0-sized malloc or similar? Do you have
pointers to exploits that rely on this?

Regardless, normally PAN/SMAP-like things should be sufficient to
protect against this. Additionally, on everything but x86_64 and
arm64, POISON_POINTER_DELTA == 0, if I'm reading correctly:

#ifdef CONFIG_ILLEGAL_POINTER_VALUE
# define POISON_POINTER_DELTA _AC(CONFIG_ILLEGAL_POINTER_VALUE, UL)
#else
# define POISON_POINTER_DELTA 0
#endif

...

config ILLEGAL_POINTER_VALUE
       hex
       default 0 if X86_32
       default 0xdead000000000000 if X86_64

...

config ILLEGAL_POINTER_VALUE
        hex
        default 0xdead000000000000

Is the plan to add ILLEGAL_POINTER_VALUE for powerpc too? And either
way, this patch, IIUC, will break the ZERO_OR_NULL_PTR() check, since
suddenly all of userspace will match it. (Though maybe that's okay?)

-Kees

>
> Signed-off-by: Michael Ellerman <mpe@ellerman.id.au>
> ---
>  include/linux/slab.h | 3 ++-
>  1 file changed, 2 insertions(+), 1 deletion(-)
>
> diff --git a/include/linux/slab.h b/include/linux/slab.h
> index 084b12bad198..17ddd7aea2dd 100644
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
> @@ -109,7 +110,7 @@
>   * ZERO_SIZE_PTR can be passed to kfree though in the same way that NULL can.
>   * Both make kfree a no-op.
>   */
> -#define ZERO_SIZE_PTR ((void *)16)
> +#define ZERO_SIZE_PTR ((void *)(16 + POISON_POINTER_DELTA))
>
>  #define ZERO_OR_NULL_PTR(x) ((unsigned long)(x) <= \
>                                 (unsigned long)ZERO_SIZE_PTR)
> --
> 2.7.4
>



-- 
Kees Cook
Nexus Security

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
