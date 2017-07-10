Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f70.google.com (mail-oi0-f70.google.com [209.85.218.70])
	by kanga.kvack.org (Postfix) with ESMTP id 55E6A6B0492
	for <linux-mm@kvack.org>; Mon, 10 Jul 2017 04:44:37 -0400 (EDT)
Received: by mail-oi0-f70.google.com with SMTP id f134so7517918oig.14
        for <linux-mm@kvack.org>; Mon, 10 Jul 2017 01:44:37 -0700 (PDT)
Received: from mail-oi0-x22a.google.com (mail-oi0-x22a.google.com. [2607:f8b0:4003:c06::22a])
        by mx.google.com with ESMTPS id j6si7272597oib.318.2017.07.10.01.44.36
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 10 Jul 2017 01:44:36 -0700 (PDT)
Received: by mail-oi0-x22a.google.com with SMTP id 191so68942004oii.2
        for <linux-mm@kvack.org>; Mon, 10 Jul 2017 01:44:36 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20170706220114.142438-2-ghackmann@google.com>
References: <20170706220114.142438-1-ghackmann@google.com> <20170706220114.142438-2-ghackmann@google.com>
From: Dmitry Vyukov <dvyukov@google.com>
Date: Mon, 10 Jul 2017 10:44:15 +0200
Message-ID: <CACT4Y+YWLc3n-PBcD1Cmu_FLGSDd+vyTTyeBamk2bBZhdWJSoA@mail.gmail.com>
Subject: Re: [PATCH 1/4] kasan: support alloca() poisoning
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Greg Hackmann <ghackmann@google.com>
Cc: Andrey Ryabinin <aryabinin@virtuozzo.com>, Alexander Potapenko <glider@google.com>, Masahiro Yamada <yamada.masahiro@socionext.com>, Michal Marek <mmarek@suse.com>, LKML <linux-kernel@vger.kernel.org>, kasan-dev <kasan-dev@googlegroups.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "open list:KERNEL BUILD + fi..." <linux-kbuild@vger.kernel.org>, Matthias Kaehlcke <mka@chromium.org>, Michael Davidson <md@google.com>

On Fri, Jul 7, 2017 at 12:01 AM, Greg Hackmann <ghackmann@google.com> wrote:
> clang's AddressSanitizer implementation adds redzones on either side of
> alloca()ed buffers.  These redzones are 32-byte aligned and at least 32
> bytes long.
>
> __asan_alloca_poison() is passed the size and address of the allocated
> buffer, *excluding* the redzones on either side.  The left redzone will
> always be to the immediate left of this buffer; but AddressSanitizer may
> need to add padding between the end of the buffer and the right redzone.
> If there are any 8-byte chunks inside this padding, we should poison
> those too.
>
> __asan_allocas_unpoison() is just passed the top and bottom of the
> dynamic stack area, so unpoisoning is simpler.
>
> Signed-off-by: Greg Hackmann <ghackmann@google.com>
> ---
>  lib/test_kasan.c  | 22 ++++++++++++++++++++++
>  mm/kasan/kasan.c  | 26 ++++++++++++++++++++++++++
>  mm/kasan/kasan.h  |  8 ++++++++
>  mm/kasan/report.c |  3 +++
>  4 files changed, 59 insertions(+)
>
> diff --git a/lib/test_kasan.c b/lib/test_kasan.c
> index a25c9763fce1..f774fcafb696 100644
> --- a/lib/test_kasan.c
> +++ b/lib/test_kasan.c
> @@ -473,6 +473,26 @@ static noinline void __init use_after_scope_test(void)
>         p[1023] = 1;
>  }
>
> +static noinline void __init kasan_alloca_oob_left(void)
> +{
> +       volatile int i = 10;
> +       char alloca_array[i];
> +       char *p = alloca_array - 1;
> +
> +       pr_info("out-of-bounds to left on alloca\n");
> +       *(volatile char *)p;
> +}
> +
> +static noinline void __init kasan_alloca_oob_right(void)
> +{
> +       volatile int i = 10;
> +       char alloca_array[i];
> +       char *p = alloca_array + round_up(i, 8);
> +
> +       pr_info("out-of-bounds to right on alloca\n");
> +       *(volatile char *)p;
> +}
> +
>  static int __init kmalloc_tests_init(void)
>  {
>         /*
> @@ -503,6 +523,8 @@ static int __init kmalloc_tests_init(void)
>         memcg_accounted_kmem_cache();
>         kasan_stack_oob();
>         kasan_global_oob();
> +       kasan_alloca_oob_left();
> +       kasan_alloca_oob_right();
>         ksize_unpoisons_memory();
>         copy_user_test();
>         use_after_scope_test();
> diff --git a/mm/kasan/kasan.c b/mm/kasan/kasan.c
> index c81549d5c833..892b626f564b 100644
> --- a/mm/kasan/kasan.c
> +++ b/mm/kasan/kasan.c
> @@ -802,6 +802,32 @@ void __asan_unpoison_stack_memory(const void *addr, size_t size)
>  }
>  EXPORT_SYMBOL(__asan_unpoison_stack_memory);
>
> +/* Emitted by compiler to poison alloca()ed objects. */
> +void __asan_alloca_poison(unsigned long addr, size_t size)
> +{
> +       size_t rounded_up_size = round_up(size, KASAN_SHADOW_SCALE_SIZE);
> +       size_t padding_size = round_up(size, KASAN_ALLOCA_REDZONE_SIZE) -
> +                       round_up(size, KASAN_SHADOW_SCALE_SIZE);

Perhaps s/round_up(size, KASAN_SHADOW_SCALE_SIZE)/rounded_up_size/
because we already calculated that.

> +
> +       const void *left_redzone = (const void *)(addr -
> +                       KASAN_ALLOCA_REDZONE_SIZE);
> +       const void *right_redzone = (const void *)(addr + rounded_up_size);

Please check that size is rounded to KASAN_ALLOCA_REDZONE_SIZE. That's
the expectation, right? That can change is clang silently.

> +       kasan_poison_shadow(left_redzone, KASAN_ALLOCA_REDZONE_SIZE,
> +                       KASAN_ALLOCA_LEFT);
> +       kasan_poison_shadow(right_redzone,
> +                       padding_size + KASAN_ALLOCA_REDZONE_SIZE,
> +                       KASAN_ALLOCA_RIGHT);

We also need to poison the unaligned part at the end of the object
from size to rounded_up_size. You can see how we do it for heap
objects.

> +}
> +EXPORT_SYMBOL(__asan_alloca_poison);
> +/* Emitted by compiler to unpoison alloca()ed areas when the stack unwinds. */
> +void __asan_allocas_unpoison(const void *stack_top, const void *stack_bottom)
> +{
> +       kasan_unpoison_shadow(stack_top, stack_bottom - stack_top);
> +}
> +EXPORT_SYMBOL(__asan_allocas_unpoison);
> +
>  #ifdef CONFIG_MEMORY_HOTPLUG
>  static int kasan_mem_notifier(struct notifier_block *nb,
>                         unsigned long action, void *data)
> diff --git a/mm/kasan/kasan.h b/mm/kasan/kasan.h
> index 1229298cce64..b857dc70d6a2 100644
> --- a/mm/kasan/kasan.h
> +++ b/mm/kasan/kasan.h
> @@ -23,6 +23,14 @@
>  #define KASAN_STACK_PARTIAL     0xF4
>  #define KASAN_USE_AFTER_SCOPE   0xF8
>
> +/*
> + * alloca redzone shadow values
> + */
> +#define KASAN_ALLOCA_LEFT      0xCA
> +#define KASAN_ALLOCA_RIGHT     0xCB
> +
> +#define KASAN_ALLOCA_REDZONE_SIZE      32
> +
>  /* Don't break randconfig/all*config builds */
>  #ifndef KASAN_ABI_VERSION
>  #define KASAN_ABI_VERSION 1
> diff --git a/mm/kasan/report.c b/mm/kasan/report.c
> index beee0e980e2d..c6a5b7ab9e3a 100644
> --- a/mm/kasan/report.c
> +++ b/mm/kasan/report.c
> @@ -101,6 +101,9 @@ static const char *get_shadow_bug_type(struct kasan_access_info *info)
>                 break;
>         case KASAN_USE_AFTER_SCOPE:
>                 bug_type = "use-after-scope";
> +       case KASAN_ALLOCA_LEFT:
> +       case KASAN_ALLOCA_RIGHT:
> +               bug_type = "alloca-out-of-bounds";
>                 break;
>         }
>
> --
> 2.13.2.725.g09c95d1e9-goog
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
