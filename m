Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f71.google.com (mail-oi0-f71.google.com [209.85.218.71])
	by kanga.kvack.org (Postfix) with ESMTP id 5D2FB800D8
	for <linux-mm@kvack.org>; Tue, 23 Jan 2018 10:34:25 -0500 (EST)
Received: by mail-oi0-f71.google.com with SMTP id u194so404826oie.20
        for <linux-mm@kvack.org>; Tue, 23 Jan 2018 07:34:25 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id p9sor250173otg.80.2018.01.23.07.34.24
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 23 Jan 2018 07:34:24 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <b2faf615-b1cd-b3ec-502f-38fef11182a2@virtuozzo.com>
References: <891fbd1fe77f46701fb1958e77bdd89651c12643.1516383788.git.andreyknvl@google.com>
 <b2faf615-b1cd-b3ec-502f-38fef11182a2@virtuozzo.com>
From: Andrey Konovalov <andreyknvl@google.com>
Date: Tue, 23 Jan 2018 16:34:23 +0100
Message-ID: <CAAeHK+xCHOm1=FKwxvzgYak+HsDkGSkN7ZGxHw-zSNa_R6RqZQ@mail.gmail.com>
Subject: Re: [PATCH] kasan: add __asan_report_loadN/storeN_noabort callbacks
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrey Ryabinin <aryabinin@virtuozzo.com>
Cc: Alexander Potapenko <glider@google.com>, Dmitry Vyukov <dvyukov@google.com>, kasan-dev <kasan-dev@googlegroups.com>, Linux Memory Management List <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Kostya Serebryany <kcc@google.com>, Evgeniy Stepanov <eugenis@google.com>, Andrew Morton <akpm@linux-foundation.org>

On Tue, Jan 23, 2018 at 11:44 AM, Andrey Ryabinin
<aryabinin@virtuozzo.com> wrote:
> On 01/19/2018 08:44 PM, Andrey Konovalov wrote:
>> Instead of __asan_report_load_n_noabort and __asan_report_store_n_noabort
>> callbacks Clang emits differently named __asan_report_loadN_noabort and
>> __asan_report_storeN_noabort (similar to __asan_loadN/storeN_noabort, whose
>> names both GCC and Clang agree on).
>>
>> Add callback implementation for __asan_report_loadN/storeN_noabort.
>>
>
> This made me wonder why this wasn't observed before. So I noticed that
> inline instrumentation with -fsanitize=kernel-addresss is broken in clang,
> and clang never calls __asan_report*() functions. I see that you guys fixed this
> just yesterday https://reviews.llvm.org/D42384 .

Correct.

>
> But it seems that you didn't fix the rest of "if (CompileKernel)" crap.
> Clang generates "__asan_report_[load,store]N*" instead of "__asan_report_[load,store]_n*"
> only because of this idiocy:
>
>         const std::string SuffixStr = CompileKernel ? "N" : "_n";
>
> See https://github.com/llvm-mirror/llvm/blob/ca19eaabd75f55865efd321b7a6f1d4ba3db8bc8/lib/Transforms/Instrumentation/AddressSanitizer.cpp#L2250
>
> Note that SuffixStr is used *only* for __asan_report_* callbacks, which makes no sense because
> we never ever had __asan_report* callbacks with "N" suffix.
>
> So I think that you should just fix the llvm here.

I think you are right.

I thought that GCC uses different and inconsistent callback names for
the kernel and user space, but that doesn't seem to be the case.

I submitted an LLVM change: https://reviews.llvm.org/D42423

Please discard this patch.

>
> And there is probably one more "if (CompileKernel)" crap in runOnModule()
> which breaks globals instrumentation.

Right, this will be fixed at some point.

>
>
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
