Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id B817A6B0038
	for <linux-mm@kvack.org>; Thu, 30 Nov 2017 03:31:03 -0500 (EST)
Received: by mail-pf0-f200.google.com with SMTP id n187so4453633pfn.10
        for <linux-mm@kvack.org>; Thu, 30 Nov 2017 00:31:03 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id t65sor959850pgc.61.2017.11.30.00.31.02
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 30 Nov 2017 00:31:02 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20171129215050.158653-3-paullawrence@google.com>
References: <20171129215050.158653-1-paullawrence@google.com> <20171129215050.158653-3-paullawrence@google.com>
From: Dmitry Vyukov <dvyukov@google.com>
Date: Thu, 30 Nov 2017 09:30:41 +0100
Message-ID: <CACT4Y+ZFeCg9Ja5UouHb0KABvR+nSwts2ZV995DnONZVN6nztQ@mail.gmail.com>
Subject: Re: [PATCH v2 2/5] kasan: Add tests for alloca poisonong
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Paul Lawrence <paullawrence@google.com>
Cc: Andrey Ryabinin <aryabinin@virtuozzo.com>, Alexander Potapenko <glider@google.com>, Masahiro Yamada <yamada.masahiro@socionext.com>, Michal Marek <mmarek@suse.com>, LKML <linux-kernel@vger.kernel.org>, kasan-dev <kasan-dev@googlegroups.com>, Linux-MM <linux-mm@kvack.org>, "open list:KERNEL BUILD + fi..." <linux-kbuild@vger.kernel.org>, Matthias Kaehlcke <mka@chromium.org>, Michael Davidson <md@google.com>, Greg Hackmann <ghackmann@google.com>

On Wed, Nov 29, 2017 at 10:50 PM, 'Paul Lawrence' via kasan-dev
<kasan-dev@googlegroups.com> wrote:
> Signed-off-by: Greg Hackmann <ghackmann@google.com>
> Signed-off-by: Paul Lawrence <paullawrence@google.com>
>
>  lib/test_kasan.c | 22 ++++++++++++++++++++++
>  1 file changed, 22 insertions(+)
>
> diff --git a/lib/test_kasan.c b/lib/test_kasan.c
> index ef1a3ac1397e..2724f86c4cef 100644
> --- a/lib/test_kasan.c
> +++ b/lib/test_kasan.c
> @@ -472,6 +472,26 @@ static noinline void __init use_after_scope_test(void)
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
> +       char *p = alloca_array + i;
> +
> +       pr_info("out-of-bounds to right on alloca\n");
> +       *(volatile char *)p;
> +}
> +
>  static int __init kmalloc_tests_init(void)
>  {
>         /*
> @@ -502,6 +522,8 @@ static int __init kmalloc_tests_init(void)
>         memcg_accounted_kmem_cache();
>         kasan_stack_oob();
>         kasan_global_oob();
> +       kasan_alloca_oob_left();
> +       kasan_alloca_oob_right();
>         ksize_unpoisons_memory();
>         copy_user_test();
>         use_after_scope_test();


Reviewed-by: Dmitry Vyukov <dvyukov@google.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
