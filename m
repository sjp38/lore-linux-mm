Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f50.google.com (mail-wm0-f50.google.com [74.125.82.50])
	by kanga.kvack.org (Postfix) with ESMTP id DEBA76B0254
	for <linux-mm@kvack.org>; Wed,  9 Mar 2016 15:09:15 -0500 (EST)
Received: by mail-wm0-f50.google.com with SMTP id n186so1261356wmn.1
        for <linux-mm@kvack.org>; Wed, 09 Mar 2016 12:09:15 -0800 (PST)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id p134si267372wmb.103.2016.03.09.12.09.14
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 09 Mar 2016 12:09:14 -0800 (PST)
Date: Wed, 9 Mar 2016 12:09:12 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH v5 5/7] mm, kasan: Stackdepot implementation. Enable
 stackdepot for SLAB
Message-Id: <20160309120912.83a82c79fd2bf6d21ab2c16a@linux-foundation.org>
In-Reply-To: <dcbbfeb740af239902695557999b45e70e93a877.1457519440.git.glider@google.com>
References: <cover.1457519440.git.glider@google.com>
	<dcbbfeb740af239902695557999b45e70e93a877.1457519440.git.glider@google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Alexander Potapenko <glider@google.com>
Cc: adech.fo@gmail.com, cl@linux.com, dvyukov@google.com, ryabinin.a.a@gmail.com, rostedt@goodmis.org, iamjoonsoo.kim@lge.com, js1304@gmail.com, kcc@google.com, kasan-dev@googlegroups.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Wed,  9 Mar 2016 12:05:46 +0100 Alexander Potapenko <glider@google.com> wrote:

> Implement the stack depot and provide CONFIG_STACKDEPOT.
> Stack depot will allow KASAN store allocation/deallocation stack traces
> for memory chunks. The stack traces are stored in a hash table and
> referenced by handles which reside in the kasan_alloc_meta and
> kasan_free_meta structures in the allocated memory chunks.
> 
> IRQ stack traces are cut below the IRQ entry point to avoid unnecessary
> duplication.
> 
> Right now stackdepot support is only enabled in SLAB allocator.
> Once KASAN features in SLAB are on par with those in SLUB we can switch
> SLUB to stackdepot as well, thus removing the dependency on SLUB stack
> bookkeeping, which wastes a lot of memory.
> 
> This patch is based on the "mm: kasan: stack depots" patch originally
> prepared by Dmitry Chernenkov.
> 

Have you identified other potential clients for the stackdepot code?

> --- /dev/null
> +++ b/include/linux/stackdepot.h
> @@ -0,0 +1,32 @@
> +/*
> + * A generic stack depot implementation
> + *
> + * Author: Alexander Potapenko <glider@google.com>
> + * Copyright (C) 2016 Google, Inc.
> + *
> + * Based on code by Dmitry Chernenkov.
> + *
> + * This program is free software; you can redistribute it and/or modify
> + * it under the terms of the GNU General Public License as published by
> + * the Free Software Foundation; either version 2 of the License, or
> + * (at your option) any later version.
> + *
> + * This program is distributed in the hope that it will be useful,
> + * but WITHOUT ANY WARRANTY; without even the implied warranty of
> + * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
> + * GNU General Public License for more details.
> + *
> + */
> +
> +#ifndef _LINUX_STACKDEPOT_H
> +#define _LINUX_STACKDEPOT_H
> +
> +typedef u32 depot_stack_handle;

I'll rename this to depot_stack_handle_t, which is a pretty strong
kernel convention.

> +struct stack_trace;
> +
> +depot_stack_handle depot_save_stack(struct stack_trace *trace, gfp_t flags);
> +
> +void depot_fetch_stack(depot_stack_handle handle, struct stack_trace *trace);
> +
> +#endif
> diff --git a/lib/Kconfig b/lib/Kconfig
> index ee38a3f..8a60a53 100644
> --- a/lib/Kconfig
> +++ b/lib/Kconfig
> @@ -543,4 +543,7 @@ config ARCH_HAS_PMEM_API
>  config ARCH_HAS_MMIO_FLUSH
>  	bool
>  
> +config STACKDEPOT
> +  bool
> +
>  endmenu
> diff --git a/lib/Kconfig.kasan b/lib/Kconfig.kasan
> index 0e4d2b3..468316d 100644
> --- a/lib/Kconfig.kasan
> +++ b/lib/Kconfig.kasan
> @@ -7,6 +7,7 @@ config KASAN
>  	bool "KASan: runtime memory debugger"
>  	depends on SLUB_DEBUG || (SLAB && !DEBUG_SLAB)
>  	select CONSTRUCTORS
> +  select STACKDEPOT if SLAB
>  	help
>  	  Enables kernel address sanitizer - runtime memory debugger,
>  	  designed to find out-of-bounds accesses and use-after-free bugs.

Something weird happened to the Kconfig whitespace.  I'll fix that.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
