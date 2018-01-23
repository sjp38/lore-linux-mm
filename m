Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id AD528800D8
	for <linux-mm@kvack.org>; Tue, 23 Jan 2018 05:44:38 -0500 (EST)
Received: by mail-pf0-f200.google.com with SMTP id e26so7628pfi.15
        for <linux-mm@kvack.org>; Tue, 23 Jan 2018 02:44:38 -0800 (PST)
Received: from EUR01-VE1-obe.outbound.protection.outlook.com (mail-ve1eur01on0104.outbound.protection.outlook.com. [104.47.1.104])
        by mx.google.com with ESMTPS id p7-v6si4677369pll.96.2018.01.23.02.44.35
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Tue, 23 Jan 2018 02:44:36 -0800 (PST)
Subject: Re: [PATCH] kasan: add __asan_report_loadN/storeN_noabort callbacks
References: <891fbd1fe77f46701fb1958e77bdd89651c12643.1516383788.git.andreyknvl@google.com>
From: Andrey Ryabinin <aryabinin@virtuozzo.com>
Message-ID: <b2faf615-b1cd-b3ec-502f-38fef11182a2@virtuozzo.com>
Date: Tue, 23 Jan 2018 13:44:48 +0300
MIME-Version: 1.0
In-Reply-To: <891fbd1fe77f46701fb1958e77bdd89651c12643.1516383788.git.andreyknvl@google.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrey Konovalov <andreyknvl@google.com>, Alexander Potapenko <glider@google.com>, Dmitry Vyukov <dvyukov@google.com>, kasan-dev@googlegroups.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org
Cc: Kostya Serebryany <kcc@google.com>, Evgeniy Stepanov <eugenis@google.com>, Andrew Morton <akpm@linux-foundation.org>

On 01/19/2018 08:44 PM, Andrey Konovalov wrote:
> Instead of __asan_report_load_n_noabort and __asan_report_store_n_noabort
> callbacks Clang emits differently named __asan_report_loadN_noabort and
> __asan_report_storeN_noabort (similar to __asan_loadN/storeN_noabort, whose
> names both GCC and Clang agree on).
> 
> Add callback implementation for __asan_report_loadN/storeN_noabort.
> 

This made me wonder why this wasn't observed before. So I noticed that
inline instrumentation with -fsanitize=kernel-addresss is broken in clang,
and clang never calls __asan_report*() functions. I see that you guys fixed this
just yesterday https://reviews.llvm.org/D42384 .

But it seems that you didn't fix the rest of "if (CompileKernel)" crap.
Clang generates "__asan_report_[load,store]N*" instead of "__asan_report_[load,store]_n*"
only because of this idiocy:

	const std::string SuffixStr = CompileKernel ? "N" : "_n";

See https://github.com/llvm-mirror/llvm/blob/ca19eaabd75f55865efd321b7a6f1d4ba3db8bc8/lib/Transforms/Instrumentation/AddressSanitizer.cpp#L2250

Note that SuffixStr is used *only* for __asan_report_* callbacks, which makes no sense because
we never ever had __asan_report* callbacks with "N" suffix.

So I think that you should just fix the llvm here.

And there is probably one more "if (CompileKernel)" crap in runOnModule()
which breaks globals instrumentation.



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
