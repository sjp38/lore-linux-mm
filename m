Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id 939A46B0253
	for <linux-mm@kvack.org>; Thu, 30 Nov 2017 03:31:49 -0500 (EST)
Received: by mail-pf0-f200.google.com with SMTP id f64so4462988pfd.6
        for <linux-mm@kvack.org>; Thu, 30 Nov 2017 00:31:49 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id 64sor1114146pfj.8.2017.11.30.00.31.48
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 30 Nov 2017 00:31:48 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20171129215050.158653-4-paullawrence@google.com>
References: <20171129215050.158653-1-paullawrence@google.com> <20171129215050.158653-4-paullawrence@google.com>
From: Dmitry Vyukov <dvyukov@google.com>
Date: Thu, 30 Nov 2017 09:31:27 +0100
Message-ID: <CACT4Y+b4btzSD1vJDa30o+67uq-sgFnU0FBEAfL9xrT7GyC9HQ@mail.gmail.com>
Subject: Re: [PATCH v2 3/5] kasan: added functions for unpoisoning stack variables
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Paul Lawrence <paullawrence@google.com>
Cc: Andrey Ryabinin <aryabinin@virtuozzo.com>, Alexander Potapenko <glider@google.com>, Masahiro Yamada <yamada.masahiro@socionext.com>, Michal Marek <mmarek@suse.com>, LKML <linux-kernel@vger.kernel.org>, kasan-dev <kasan-dev@googlegroups.com>, Linux-MM <linux-mm@kvack.org>, "open list:KERNEL BUILD + fi..." <linux-kbuild@vger.kernel.org>, Matthias Kaehlcke <mka@chromium.org>, Michael Davidson <md@google.com>, Greg Hackmann <ghackmann@google.com>

On Wed, Nov 29, 2017 at 10:50 PM, 'Paul Lawrence' via kasan-dev
<kasan-dev@googlegroups.com> wrote:
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
> Signed-off-by: Paul Lawrence <paullawrence@google.com>
>
> ---
>  mm/kasan/kasan.c | 15 +++++++++++++++
>  1 file changed, 15 insertions(+)
>
> diff --git a/mm/kasan/kasan.c b/mm/kasan/kasan.c
> index f86f862f41f8..89565a1ec417 100644
> --- a/mm/kasan/kasan.c
> +++ b/mm/kasan/kasan.c
> @@ -768,6 +768,21 @@ void __asan_allocas_unpoison(const void *stack_top, const void *stack_bottom)
>  }
>  EXPORT_SYMBOL(__asan_allocas_unpoison);
>
> +/* Emitted by the compiler to [un]poison local variables. */
> +#define DEFINE_ASAN_SET_SHADOW(byte) \
> +       void __asan_set_shadow_##byte(const void *addr, size_t size)    \
> +       {                                                               \
> +               __memset((void *)addr, 0x##byte, size);                 \
> +       }                                                               \
> +       EXPORT_SYMBOL(__asan_set_shadow_##byte)
> +
> +DEFINE_ASAN_SET_SHADOW(00);
> +DEFINE_ASAN_SET_SHADOW(f1);
> +DEFINE_ASAN_SET_SHADOW(f2);
> +DEFINE_ASAN_SET_SHADOW(f3);
> +DEFINE_ASAN_SET_SHADOW(f5);
> +DEFINE_ASAN_SET_SHADOW(f8);
> +
>  #ifdef CONFIG_MEMORY_HOTPLUG
>  static int __meminit kasan_mem_notifier(struct notifier_block *nb,
>                         unsigned long action, void *data)


Reviewed-by: Dmitry Vyukov <dvyukov@google.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
