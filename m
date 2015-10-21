Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f50.google.com (mail-pa0-f50.google.com [209.85.220.50])
	by kanga.kvack.org (Postfix) with ESMTP id 2960082F64
	for <linux-mm@kvack.org>; Wed, 21 Oct 2015 16:37:31 -0400 (EDT)
Received: by pasz6 with SMTP id z6so64310380pas.2
        for <linux-mm@kvack.org>; Wed, 21 Oct 2015 13:37:30 -0700 (PDT)
Received: from mail-pa0-x22d.google.com (mail-pa0-x22d.google.com. [2607:f8b0:400e:c03::22d])
        by mx.google.com with ESMTPS id pz7si9809182pab.1.2015.10.21.13.37.30
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 21 Oct 2015 13:37:30 -0700 (PDT)
Received: by pasz6 with SMTP id z6so64310128pas.2
        for <linux-mm@kvack.org>; Wed, 21 Oct 2015 13:37:30 -0700 (PDT)
Date: Wed, 21 Oct 2015 13:37:28 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH] mm, slub, kasan: enable user tracking by default with
 KASAN=y
In-Reply-To: <1445444820-27929-1-git-send-email-aryabinin@virtuozzo.com>
Message-ID: <alpine.DEB.2.10.1510211334290.31868@chino.kir.corp.google.com>
References: <1445444820-27929-1-git-send-email-aryabinin@virtuozzo.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrey Ryabinin <aryabinin@virtuozzo.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Alexander Potapenko <glider@google.com>, Dmitriy Vyukov <dvyukov@google.com>

On Wed, 21 Oct 2015, Andrey Ryabinin wrote:

> It's recommended to have slub's user tracking enabled with CONFIG_KASAN,
> because:
> a) User tracking disables slab merging which improves
>     detecting out-of-bounds accesses.
> b) User tracking metadata acts as redzone which also improves
>     detecting out-of-bounds accesses.
> c) User tracking provides additional information about object.
>     This information helps to understand bugs.
> 
> Currently it is not enabled by default. Besides recompiling the kernel
> with KASAN and reinstalling it, user also have to change the boot cmdline,
> which is not very handy.
> 
> Enable slub user tracking by default with KASAN=y, since there is no
> good reason to not do this.
> 
> Signed-off-by: Andrey Ryabinin <aryabinin@virtuozzo.com>

Makes sense.  I don't imagine users of CONFIG_KASAN would be concerned 
about additional performance degradation for better diagnostics.

> ---
>  Documentation/kasan.txt | 3 +--
>  lib/Kconfig.kasan       | 3 +--
>  mm/slub.c               | 2 ++
>  3 files changed, 4 insertions(+), 4 deletions(-)
> 
> diff --git a/Documentation/kasan.txt b/Documentation/kasan.txt
> index 94c88157..3107467 100644
> --- a/Documentation/kasan.txt
> +++ b/Documentation/kasan.txt
> @@ -28,8 +28,7 @@ the latter is 1.1 - 2 times faster. Inline instrumentation requires a GCC
>  version 5.0 or later.
>  
>  Currently KASAN works only with the SLUB memory allocator.
> -For better bug detection and nicer report, enable CONFIG_STACKTRACE and put
> -at least 'slub_debug=U' in the boot cmdline.
> +For better bug detection and nicer report and enable CONFIG_STACKTRACE.
>  
>  To disable instrumentation for specific files or directories, add a line
>  similar to the following to the respective kernel Makefile:

One too many "and"s in that sentence.

> diff --git a/lib/Kconfig.kasan b/lib/Kconfig.kasan
> index 39f24d6..0fee5ac 100644
> --- a/lib/Kconfig.kasan
> +++ b/lib/Kconfig.kasan
> @@ -15,8 +15,7 @@ config KASAN
>  	  global variables requires gcc 5.0 or later.
>  	  This feature consumes about 1/8 of available memory and brings about
>  	  ~x3 performance slowdown.
> -	  For better error detection enable CONFIG_STACKTRACE,
> -	  and add slub_debug=U to boot cmdline.
> +	  For better error detection enable CONFIG_STACKTRACE.
>  
>  choice
>  	prompt "Instrumentation type"
> diff --git a/mm/slub.c b/mm/slub.c
> index ae28dff..f208835 100644
> --- a/mm/slub.c
> +++ b/mm/slub.c
> @@ -463,6 +463,8 @@ static void get_map(struct kmem_cache *s, struct page *page, unsigned long *map)
>   */
>  #ifdef CONFIG_SLUB_DEBUG_ON
>  static int slub_debug = DEBUG_DEFAULT_FLAGS;
> +#elif defined(CONFIG_KASAN)
> +static int slub_debug = SLAB_STORE_USER;
>  #else
>  static int slub_debug;
>  #endif

Typically you would convert the #ifdef to 
#if defined(CONFIG_SLUB_DEBUG_ON) as well.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
