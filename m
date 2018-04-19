Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-vk0-f72.google.com (mail-vk0-f72.google.com [209.85.213.72])
	by kanga.kvack.org (Postfix) with ESMTP id 8E1C66B0007
	for <linux-mm@kvack.org>; Thu, 19 Apr 2018 16:43:13 -0400 (EDT)
Received: by mail-vk0-f72.google.com with SMTP id b195so4244744vkf.2
        for <linux-mm@kvack.org>; Thu, 19 Apr 2018 13:43:13 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id d10sor1863133uad.215.2018.04.19.13.43.12
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 19 Apr 2018 13:43:12 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20180419172451.104700-1-dvyukov@google.com>
References: <20180419172451.104700-1-dvyukov@google.com>
From: Kees Cook <keescook@google.com>
Date: Thu, 19 Apr 2018 13:43:11 -0700
Message-ID: <CAGXu5jK0fWnyQUYP3H5e8hP-6QbtmeC102a-2Mab4CSqj4bpgg@mail.gmail.com>
Subject: Re: [PATCH v2] KASAN: prohibit KASAN+STRUCTLEAK combination
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dmitry Vyukov <dvyukov@google.com>
Cc: Linux-MM <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, kasan-dev <kasan-dev@googlegroups.com>, Fengguang Wu <fengguang.wu@intel.com>, Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>, Andrey Ryabinin <aryabinin@virtuozzo.com>

On Thu, Apr 19, 2018 at 10:24 AM, Dmitry Vyukov <dvyukov@google.com> wrote:
> Currently STRUCTLEAK inserts initialization out of live scope of
> variables from KASAN point of view. This leads to KASAN false
> positive reports. Prohibit this combination for now.
>
> Signed-off-by: Dmitry Vyukov <dvyukov@google.com>
> Cc: linux-mm@kvack.org
> Cc: kasan-dev@googlegroups.com
> Cc: Fengguang Wu <fengguang.wu@intel.com>
> Cc: Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>
> Cc: Andrey Ryabinin <aryabinin@virtuozzo.com>
> Cc: Kees Cook <keescook@google.com>

This seems fine until we have a better solution. Thanks!

Acked-by: Kees Cook <keescook@chromium.org>

-Kees

>
> ---
>
> This combination leads to periodic confusion
> and pointless debugging:
>
> https://marc.info/?l=linux-kernel&m=151991367323082
> https://marc.info/?l=linux-kernel&m=151992229326243
> https://lkml.org/lkml/2017/11/30/33
>
> Changes since v1:
>  - replace KASAN with KASAN_EXTRA
>    Only KASAN_EXTRA enables variable scope checking
> ---
>  arch/Kconfig | 4 ++++
>  1 file changed, 4 insertions(+)
>
> diff --git a/arch/Kconfig b/arch/Kconfig
> index 8e0d665c8d53..75dd23acf133 100644
> --- a/arch/Kconfig
> +++ b/arch/Kconfig
> @@ -464,6 +464,10 @@ config GCC_PLUGIN_LATENT_ENTROPY
>  config GCC_PLUGIN_STRUCTLEAK
>         bool "Force initialization of variables containing userspace addresses"
>         depends on GCC_PLUGINS
> +       # Currently STRUCTLEAK inserts initialization out of live scope of
> +       # variables from KASAN point of view. This leads to KASAN false
> +       # positive reports. Prohibit this combination for now.
> +       depends on !KASAN_EXTRA
>         help
>           This plugin zero-initializes any structures containing a
>           __user attribute. This can prevent some classes of information
> --
> 2.17.0.484.g0c8726318c-goog
>



-- 
Kees Cook
Pixel Security
