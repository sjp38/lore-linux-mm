Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f72.google.com (mail-it0-f72.google.com [209.85.214.72])
	by kanga.kvack.org (Postfix) with ESMTP id 47B236B0033
	for <linux-mm@kvack.org>; Mon,  4 Dec 2017 11:11:34 -0500 (EST)
Received: by mail-it0-f72.google.com with SMTP id a3so12364329itg.7
        for <linux-mm@kvack.org>; Mon, 04 Dec 2017 08:11:34 -0800 (PST)
Received: from EUR01-VE1-obe.outbound.protection.outlook.com (mail-ve1eur01on0113.outbound.protection.outlook.com. [104.47.1.113])
        by mx.google.com with ESMTPS id y139si2831129itc.57.2017.12.04.08.11.32
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Mon, 04 Dec 2017 08:11:33 -0800 (PST)
Subject: Re: [PATCH v3 2/5] kasan/Makefile: Support LLVM style asan
 parameters.
References: <20171201213643.2506-1-paullawrence@google.com>
 <20171201213643.2506-3-paullawrence@google.com>
From: Andrey Ryabinin <aryabinin@virtuozzo.com>
Message-ID: <33f13b1a-494c-67d5-a470-294867c06f9a@virtuozzo.com>
Date: Mon, 4 Dec 2017 19:14:55 +0300
MIME-Version: 1.0
In-Reply-To: <20171201213643.2506-3-paullawrence@google.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Paul Lawrence <paullawrence@google.com>, Alexander Potapenko <glider@google.com>, Dmitry Vyukov <dvyukov@google.com>, Masahiro Yamada <yamada.masahiro@socionext.com>
Cc: linux-kernel@vger.kernel.org, kasan-dev@googlegroups.com, linux-mm@kvack.org, linux-kbuild@vger.kernel.org, Matthias Kaehlcke <mka@chromium.org>, Michael Davidson <md@google.com>, Greg Hackmann <ghackmann@google.com>


On 12/02/2017 12:36 AM, Paul Lawrence wrote:
>

Missing:
	From: Andrey Ryabinin <aryabinin@virtuozzo.com>

Please, don't change authorship of the patches.

> LLVM doesn't understand GCC-style paramters ("--param asan-foo=bar"),
> thus we currently we don't use inline/globals/stack instrumentation
> when building the kernel with clang.
> 
> Add support for LLVM-style parameters ("-mllvm -asan-foo=bar") to
> enable all KASAN features.
> 
> Signed-off-by: Andrey Ryabinin <aryabinin@virtuozzo.com>
> ---
>  scripts/Makefile.kasan | 29 ++++++++++++++++++-----------
>  1 file changed, 18 insertions(+), 11 deletions(-)
> 
> diff --git a/scripts/Makefile.kasan b/scripts/Makefile.kasan
> index 1ce7115aa499..7c00be9216f4 100644
> --- a/scripts/Makefile.kasan
> +++ b/scripts/Makefile.kasan
> @@ -10,10 +10,7 @@ KASAN_SHADOW_OFFSET ?= $(CONFIG_KASAN_SHADOW_OFFSET)
>  



> +   # -fasan-shadow-offset fails without -fsanitize
> +   CFLAGS_KASAN_SHADOW := $(call cc-option, -fsanitize=kernel-address \
> +			-fasan-shadow-offset=$(KASAN_SHADOW_OFFSET), \
> +			$(call cc-option, -fsanitize=kernel-address \
> +			-mllvm -asan-mapping-offset=$(KASAN_SHADOW_OFFSET)))
> +
> +   ifeq ("$(CFLAGS_KASAN_SHADOW)"," ")

This not how it was in my original patch. Why you changed this?
Condition is always false now, so it breaks kasan with 4.9.x gcc.

> +      CFLAGS_KASAN := $(CFLAGS_KASAN_MINIMAL)
> +   else
> +      # Now add all the compiler specific options that are valid standalone
> +      CFLAGS_KASAN := $(CFLAGS_KASAN_SHADOW) \
> +	$(call cc-param,asan-globals=1) \

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
