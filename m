Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-vk0-f70.google.com (mail-vk0-f70.google.com [209.85.213.70])
	by kanga.kvack.org (Postfix) with ESMTP id 152B86B0005
	for <linux-mm@kvack.org>; Mon, 30 Apr 2018 19:41:27 -0400 (EDT)
Received: by mail-vk0-f70.google.com with SMTP id l75-v6so8441037vke.20
        for <linux-mm@kvack.org>; Mon, 30 Apr 2018 16:41:27 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id e10sor3048878uad.142.2018.04.30.16.41.26
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 30 Apr 2018 16:41:26 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20180419172451.104700-1-dvyukov@google.com>
References: <20180419172451.104700-1-dvyukov@google.com>
From: Kees Cook <keescook@google.com>
Date: Mon, 30 Apr 2018 16:41:24 -0700
Message-ID: <CAGXu5jK_C-xgNOFxtCi3Wt63_ProP0jw2YSiE0fbVhu=J0pNFA@mail.gmail.com>
Subject: Re: [PATCH v2] KASAN: prohibit KASAN+STRUCTLEAK combination
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dmitry Vyukov <dvyukov@google.com>, Andrew Morton <akpm@linux-foundation.org>
Cc: Linux-MM <linux-mm@kvack.org>, kasan-dev <kasan-dev@googlegroups.com>, Fengguang Wu <fengguang.wu@intel.com>, Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>, Andrey Ryabinin <aryabinin@virtuozzo.com>

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

Acked-by: Kees Cook <keescook@chromium.org>

I prefer this change over moving the plugin earlier since that ends up
creating redundant initializers...

Andrew, can you carry this (and possibly include it in bug-fixes for v4.17)?

Thanks!

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
