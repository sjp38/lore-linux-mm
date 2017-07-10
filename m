Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f70.google.com (mail-pg0-f70.google.com [74.125.83.70])
	by kanga.kvack.org (Postfix) with ESMTP id 10B276B049F
	for <linux-mm@kvack.org>; Mon, 10 Jul 2017 06:29:15 -0400 (EDT)
Received: by mail-pg0-f70.google.com with SMTP id 123so112160298pgj.4
        for <linux-mm@kvack.org>; Mon, 10 Jul 2017 03:29:15 -0700 (PDT)
Received: from EUR01-VE1-obe.outbound.protection.outlook.com (mail-ve1eur01on0125.outbound.protection.outlook.com. [104.47.1.125])
        by mx.google.com with ESMTPS id i62si1746535pli.511.2017.07.10.03.29.13
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Mon, 10 Jul 2017 03:29:14 -0700 (PDT)
Subject: Re: [PATCH 2/4] kasan: added functions for unpoisoning stack
 variables
References: <20170706220114.142438-1-ghackmann@google.com>
 <20170706220114.142438-3-ghackmann@google.com>
From: Andrey Ryabinin <aryabinin@virtuozzo.com>
Message-ID: <d3f1ab84-3fe2-f4ea-5481-82bc63b9d09c@virtuozzo.com>
Date: Mon, 10 Jul 2017 13:31:05 +0300
MIME-Version: 1.0
In-Reply-To: <20170706220114.142438-3-ghackmann@google.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Greg Hackmann <ghackmann@google.com>, Alexander Potapenko <glider@google.com>, Dmitry Vyukov <dvyukov@google.com>, Masahiro Yamada <yamada.masahiro@socionext.com>, Michal Marek <mmarek@suse.com>
Cc: linux-kernel@vger.kernel.org, kasan-dev@googlegroups.com, linux-mm@kvack.org, linux-kbuild@vger.kernel.org, Matthias Kaehlcke <mka@chromium.org>, Michael Davidson <md@google.com>



On 07/07/2017 01:01 AM, Greg Hackmann wrote:
> From: Alexander Potapenko <glider@google.com>
> 
> As a code-size optimization, LLVM builds since r279383 may
> bulk-manipulate the shadow region when (un)poisoning large memory
> blocks.  This requires new callbacks that simply do an uninstrumented
> memset().
> 
> This fixes linking the Clang-built kernel when using KASAN.
> 
> Signed-off-by: Alexander Potapenko <glider@google.com>
> [ghackmann@google.com: fix memset() parameters, and tweak
>  commit message to describe new callbacks]
> Signed-off-by: Greg Hackmann <ghackmann@google.com>
> ---
>  mm/kasan/kasan.c | 15 +++++++++++++++
>  1 file changed, 15 insertions(+)
> 
> diff --git a/mm/kasan/kasan.c b/mm/kasan/kasan.c
> index 892b626f564b..89911e5c69f9 100644
> --- a/mm/kasan/kasan.c
> +++ b/mm/kasan/kasan.c
> @@ -828,6 +828,21 @@ void __asan_allocas_unpoison(const void *stack_top, const void *stack_bottom)
>  }
>  EXPORT_SYMBOL(__asan_allocas_unpoison);
>  
> +/* Emitted by the compiler to [un]poison local variables. */
> +#define DEFINE_ASAN_SET_SHADOW(byte) \
> +	void __asan_set_shadow_##byte(const void *addr, size_t size)	\
> +	{								\
> +		__memset((void *)addr, 0x##byte, size);			\
> +	}								\
> +	EXPORT_SYMBOL(__asan_set_shadow_##byte)
> +
> +DEFINE_ASAN_SET_SHADOW(00);
> +DEFINE_ASAN_SET_SHADOW(f1);
> +DEFINE_ASAN_SET_SHADOW(f2);
> +DEFINE_ASAN_SET_SHADOW(f3);
> +DEFINE_ASAN_SET_SHADOW(f5);
> +DEFINE_ASAN_SET_SHADOW(f8);

I think we can remove f8 as it should be used only by use-after-return instrumentation.
We don't use it in the kernel

> +
>  #ifdef CONFIG_MEMORY_HOTPLUG
>  static int kasan_mem_notifier(struct notifier_block *nb,
>  			unsigned long action, void *data)
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
