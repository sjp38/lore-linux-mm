Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f69.google.com (mail-oi0-f69.google.com [209.85.218.69])
	by kanga.kvack.org (Postfix) with ESMTP id 164126B0498
	for <linux-mm@kvack.org>; Mon, 10 Jul 2017 04:48:08 -0400 (EDT)
Received: by mail-oi0-f69.google.com with SMTP id t194so7514770oif.8
        for <linux-mm@kvack.org>; Mon, 10 Jul 2017 01:48:08 -0700 (PDT)
Received: from mail-oi0-x22b.google.com (mail-oi0-x22b.google.com. [2607:f8b0:4003:c06::22b])
        by mx.google.com with ESMTPS id u67si7747366oia.234.2017.07.10.01.48.07
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 10 Jul 2017 01:48:07 -0700 (PDT)
Received: by mail-oi0-x22b.google.com with SMTP id p188so68854034oia.0
        for <linux-mm@kvack.org>; Mon, 10 Jul 2017 01:48:07 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20170706220114.142438-4-ghackmann@google.com>
References: <20170706220114.142438-1-ghackmann@google.com> <20170706220114.142438-4-ghackmann@google.com>
From: Dmitry Vyukov <dvyukov@google.com>
Date: Mon, 10 Jul 2017 10:47:46 +0200
Message-ID: <CACT4Y+Zr530Hj90adwBpLW_U6VY7AomAM+VZctZTtW4GA8ULpQ@mail.gmail.com>
Subject: Re: [PATCH 3/4] kasan: support LLVM-style asan parameters
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Greg Hackmann <ghackmann@google.com>
Cc: Andrey Ryabinin <aryabinin@virtuozzo.com>, Alexander Potapenko <glider@google.com>, Masahiro Yamada <yamada.masahiro@socionext.com>, Michal Marek <mmarek@suse.com>, LKML <linux-kernel@vger.kernel.org>, kasan-dev <kasan-dev@googlegroups.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "open list:KERNEL BUILD + fi..." <linux-kbuild@vger.kernel.org>, Matthias Kaehlcke <mka@chromium.org>, Michael Davidson <md@google.com>

On Fri, Jul 7, 2017 at 12:01 AM, Greg Hackmann <ghackmann@google.com> wrote:
> Use cc-option to figure out whether the compiler's sanitizer uses
> LLVM-style parameters ("-mllvm -asan-foo=bar") or GCC-style parameters
> ("--param asan-foo=bar").
>
> Signed-off-by: Greg Hackmann <ghackmann@google.com>
> ---
>  scripts/Makefile.kasan | 10 +++++++++-
>  1 file changed, 9 insertions(+), 1 deletion(-)
>
> diff --git a/scripts/Makefile.kasan b/scripts/Makefile.kasan
> index 9576775a86f6..b66ae4b4546b 100644
> --- a/scripts/Makefile.kasan
> +++ b/scripts/Makefile.kasan
> @@ -9,11 +9,19 @@ KASAN_SHADOW_OFFSET ?= $(CONFIG_KASAN_SHADOW_OFFSET)
>
>  CFLAGS_KASAN_MINIMAL := -fsanitize=kernel-address
>
> -CFLAGS_KASAN := $(call cc-option, -fsanitize=kernel-address \
> +CFLAGS_KASAN_GCC := $(call cc-option, -fsanitize=kernel-address \
>                 -fasan-shadow-offset=$(KASAN_SHADOW_OFFSET) \
>                 --param asan-stack=1 --param asan-globals=1 \
>                 --param asan-instrumentation-with-call-threshold=$(call_threshold))
>
> +CFLAGS_KASAN_LLVM := $(call cc-option, -fsanitize=kernel-address \
> +               -mllvm -asan-mapping-offset=$(KASAN_SHADOW_OFFSET) \
> +               -mllvm -asan-stack=1 -mllvm -asan-globals=1 \
> +               -mllvm -asan-use-after-scope=1 \
> +               -mllvm -asan-instrumentation-with-call-threshold=$(call_threshold))
> +
> +CFLAGS_KASAN := $(CFLAGS_KASAN_GCC) $(CFLAGS_KASAN_LLVM)
> +
>  ifeq ($(call cc-option, $(CFLAGS_KASAN_MINIMAL) -Werror),)
>     ifneq ($(CONFIG_COMPILE_TEST),y)
>          $(warning Cannot use CONFIG_KASAN: \

Reviewed-by: Dmitry Vyukov <dvyukov@google.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
