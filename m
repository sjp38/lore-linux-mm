Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id 5A7CD6B0351
	for <linux-mm@kvack.org>; Wed, 22 Mar 2017 12:34:26 -0400 (EDT)
Received: by mail-pf0-f197.google.com with SMTP id n11so192385643pfg.7
        for <linux-mm@kvack.org>; Wed, 22 Mar 2017 09:34:26 -0700 (PDT)
Received: from mail-pf0-x234.google.com (mail-pf0-x234.google.com. [2607:f8b0:400e:c00::234])
        by mx.google.com with ESMTPS id j21si2366083pgg.373.2017.03.22.09.34.25
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 22 Mar 2017 09:34:25 -0700 (PDT)
Received: by mail-pf0-x234.google.com with SMTP id p189so71359503pfp.1
        for <linux-mm@kvack.org>; Wed, 22 Mar 2017 09:34:25 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20170322160647.32032-1-aryabinin@virtuozzo.com>
References: <20170322160647.32032-1-aryabinin@virtuozzo.com>
From: Andrey Konovalov <andreyknvl@google.com>
Date: Wed, 22 Mar 2017 17:34:24 +0100
Message-ID: <CAAeHK+zt9U+_8o4-k1mTvHsNTVGnKbzy7jVz2jn=TkNFf2neHQ@mail.gmail.com>
Subject: Re: [PATCH] kasan: report only the first error
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrey Ryabinin <aryabinin@virtuozzo.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Mark Rutland <mark.rutland@arm.com>, Alexander Potapenko <glider@google.com>, Dmitry Vyukov <dvyukov@google.com>, kasan-dev <kasan-dev@googlegroups.com>, Linux Memory Management List <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On Wed, Mar 22, 2017 at 5:06 PM, Andrey Ryabinin
<aryabinin@virtuozzo.com> wrote:
> Disable kasan after the first report. There are several reasons for this:
>  * Single bug quite often has multiple invalid memory accesses causing
>     storm in the dmesg.
>  * Write OOB access might corrupt metadata so the next report will print
>     bogus alloc/free stacktraces.
>  * Reports after the first easily could be not bugs by itself but just side
>     effects of the first one.
>
> Given that multiple reports only do harm, it makes sense to disable
> kasan after the first one. Except for the tests in lib/test_kasan.c
> as we obviously want to see all reports from test.

Hi Andrey,

Could you make it configurable via CONFIG_KASAN_SOMETHING (which can
default to showing only the first report)?

I sometimes use KASAN to see what bad accesses a particular bug
causes, and seeing all of them (even knowing that they may be
corrupt/induced) helps a lot.

Thanks!

>
> Signed-off-by: Andrey Ryabinin <aryabinin@virtuozzo.com>
> ---
>  lib/test_kasan.c  | 9 +++++++++
>  mm/kasan/report.c | 7 +++++++
>  2 files changed, 16 insertions(+)
>
> diff --git a/lib/test_kasan.c b/lib/test_kasan.c
> index 0b1d314..5112663 100644
> --- a/lib/test_kasan.c
> +++ b/lib/test_kasan.c
> @@ -11,6 +11,7 @@
>
>  #define pr_fmt(fmt) "kasan test: %s " fmt, __func__
>
> +#include <linux/atomic.h>
>  #include <linux/delay.h>
>  #include <linux/kernel.h>
>  #include <linux/mman.h>
> @@ -21,6 +22,8 @@
>  #include <linux/uaccess.h>
>  #include <linux/module.h>
>
> +extern atomic_t kasan_report_count;
> +
>  /*
>   * Note: test functions are marked noinline so that their names appear in
>   * reports.
> @@ -474,6 +477,9 @@ static noinline void __init use_after_scope_test(void)
>
>  static int __init kmalloc_tests_init(void)
>  {
> +       /* Rise reports limit high enough to see all the following bugs */
> +       atomic_set(&kasan_report_count, 100);
> +
>         kmalloc_oob_right();
>         kmalloc_oob_left();
>         kmalloc_node_oob_right();
> @@ -499,6 +505,9 @@ static int __init kmalloc_tests_init(void)
>         ksize_unpoisons_memory();
>         copy_user_test();
>         use_after_scope_test();
> +
> +       /* kasan is unreliable now, disable reports */
> +       atomic_set(&kasan_report_count, 0);
>         return -EAGAIN;
>  }
>
> diff --git a/mm/kasan/report.c b/mm/kasan/report.c
> index 718a10a..7eab229 100644
> --- a/mm/kasan/report.c
> +++ b/mm/kasan/report.c
> @@ -13,6 +13,7 @@
>   *
>   */
>
> +#include <linux/atomic.h>
>  #include <linux/ftrace.h>
>  #include <linux/kernel.h>
>  #include <linux/mm.h>
> @@ -354,6 +355,9 @@ static void kasan_report_error(struct kasan_access_info *info)
>         kasan_end_report(&flags);
>  }
>
> +atomic_t kasan_report_count = ATOMIC_INIT(1);
> +EXPORT_SYMBOL_GPL(kasan_report_count);
> +
>  void kasan_report(unsigned long addr, size_t size,
>                 bool is_write, unsigned long ip)
>  {
> @@ -362,6 +366,9 @@ void kasan_report(unsigned long addr, size_t size,
>         if (likely(!kasan_report_enabled()))
>                 return;
>
> +       if (atomic_dec_if_positive(&kasan_report_count) < 0)
> +               return;
> +
>         disable_trace_on_warning();
>
>         info.access_addr = (void *)addr;
> --
> 2.10.2
>
> --
> You received this message because you are subscribed to the Google Groups "kasan-dev" group.
> To unsubscribe from this group and stop receiving emails from it, send an email to kasan-dev+unsubscribe@googlegroups.com.
> To post to this group, send email to kasan-dev@googlegroups.com.
> To view this discussion on the web visit https://groups.google.com/d/msgid/kasan-dev/20170322160647.32032-1-aryabinin%40virtuozzo.com.
> For more options, visit https://groups.google.com/d/optout.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
