Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f45.google.com (mail-pa0-f45.google.com [209.85.220.45])
	by kanga.kvack.org (Postfix) with ESMTP id 8F50A6B0072
	for <linux-mm@kvack.org>; Fri, 27 Feb 2015 19:07:33 -0500 (EST)
Received: by pablf10 with SMTP id lf10so26501675pab.6
        for <linux-mm@kvack.org>; Fri, 27 Feb 2015 16:07:33 -0800 (PST)
Received: from ozlabs.org (ozlabs.org. [2401:3900:2:1::2])
        by mx.google.com with ESMTPS id xm5si7301308pbc.140.2015.02.27.16.07.31
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 27 Feb 2015 16:07:31 -0800 (PST)
From: Rusty Russell <rusty@rustcorp.com.au>
Subject: Re: [PATCH 2/2] kasan, module: move MODULE_ALIGN macro into <linux/moduleloader.h>
In-Reply-To: <1425049816-11385-2-git-send-email-a.ryabinin@samsung.com>
References: <1425049816-11385-1-git-send-email-a.ryabinin@samsung.com> <1425049816-11385-2-git-send-email-a.ryabinin@samsung.com>
Date: Sat, 28 Feb 2015 09:31:40 +1030
Message-ID: <87bnkfklgr.fsf@rustcorp.com.au>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrey Ryabinin <a.ryabinin@samsung.com>, Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Dmitry Vyukov <dvyukov@google.com>

Andrey Ryabinin <a.ryabinin@samsung.com> writes:
> include/linux/moduleloader.h is more suitable place for this macro.
> Also change alignment to PAGE_SIZE for CONFIG_KASAN=n as such
> alignment already assumed in several places.
>
> Signed-off-by: Andrey Ryabinin <a.ryabinin@samsung.com>
> Cc: Dmitry Vyukov <dvyukov@google.com>
> Cc: Rusty Russell <rusty@rustcorp.com.au>

Acked-by: Rusty Russell <rusty@rustcorp.com.au>

Thanks,
Rusty.

> ---
>  include/linux/kasan.h        | 4 ----
>  include/linux/moduleloader.h | 8 ++++++++
>  2 files changed, 8 insertions(+), 4 deletions(-)
>
> diff --git a/include/linux/kasan.h b/include/linux/kasan.h
> index 5fa48a2..5bb0744 100644
> --- a/include/linux/kasan.h
> +++ b/include/linux/kasan.h
> @@ -50,15 +50,11 @@ void kasan_krealloc(const void *object, size_t new_size);
>  void kasan_slab_alloc(struct kmem_cache *s, void *object);
>  void kasan_slab_free(struct kmem_cache *s, void *object);
>  
> -#define MODULE_ALIGN (PAGE_SIZE << KASAN_SHADOW_SCALE_SHIFT)
> -
>  int kasan_module_alloc(void *addr, size_t size);
>  void kasan_free_shadow(const struct vm_struct *vm);
>  
>  #else /* CONFIG_KASAN */
>  
> -#define MODULE_ALIGN 1
> -
>  static inline void kasan_unpoison_shadow(const void *address, size_t size) {}
>  
>  static inline void kasan_enable_current(void) {}
> diff --git a/include/linux/moduleloader.h b/include/linux/moduleloader.h
> index f755626..4d0cb9b 100644
> --- a/include/linux/moduleloader.h
> +++ b/include/linux/moduleloader.h
> @@ -84,4 +84,12 @@ void module_arch_cleanup(struct module *mod);
>  
>  /* Any cleanup before freeing mod->module_init */
>  void module_arch_freeing_init(struct module *mod);
> +
> +#ifdef CONFIG_KASAN
> +#include <linux/kasan.h>
> +#define MODULE_ALIGN (PAGE_SIZE << KASAN_SHADOW_SCALE_SHIFT)
> +#else
> +#define MODULE_ALIGN PAGE_SIZE
> +#endif
> +
>  #endif
> -- 
> 2.3.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
