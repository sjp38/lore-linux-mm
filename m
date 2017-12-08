Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-vk0-f70.google.com (mail-vk0-f70.google.com [209.85.213.70])
	by kanga.kvack.org (Postfix) with ESMTP id 708826B0268
	for <linux-mm@kvack.org>; Fri,  8 Dec 2017 04:25:49 -0500 (EST)
Received: by mail-vk0-f70.google.com with SMTP id p143so5418713vkf.1
        for <linux-mm@kvack.org>; Fri, 08 Dec 2017 01:25:49 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id 5sor2700614vki.262.2017.12.08.01.25.48
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 08 Dec 2017 01:25:48 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20171204191735.132544-3-paullawrence@google.com>
References: <20171204191735.132544-1-paullawrence@google.com> <20171204191735.132544-3-paullawrence@google.com>
From: Alexander Potapenko <glider@google.com>
Date: Fri, 8 Dec 2017 10:25:46 +0100
Message-ID: <CAG_fn=Xgx+bL85nENTL5K9z=5NBmERub=YEYwkpTYFVphLhPFg@mail.gmail.com>
Subject: Re: [PATCH v4 2/5] kasan/Makefile: Support LLVM style asan parameters.
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Paul Lawrence <paullawrence@google.com>
Cc: Andrey Ryabinin <aryabinin@virtuozzo.com>, Dmitry Vyukov <dvyukov@google.com>, Masahiro Yamada <yamada.masahiro@socionext.com>, LKML <linux-kernel@vger.kernel.org>, kasan-dev <kasan-dev@googlegroups.com>, Linux Memory Management List <linux-mm@kvack.org>, Linux Kbuild mailing list <linux-kbuild@vger.kernel.org>, Matthias Kaehlcke <mka@chromium.org>, Michael Davidson <md@google.com>, Greg Hackmann <ghackmann@google.com>

On Mon, Dec 4, 2017 at 8:17 PM, Paul Lawrence <paullawrence@google.com> wro=
te:
> From: Andrey Ryabinin <aryabinin@virtuozzo.com>
>
> LLVM doesn't understand GCC-style paramters ("--param asan-foo=3Dbar"),
> thus we currently we don't use inline/globals/stack instrumentation
> when building the kernel with clang.
>
> Add support for LLVM-style parameters ("-mllvm -asan-foo=3Dbar") to
> enable all KASAN features.
>
> Signed-off-by: Andrey Ryabinin <aryabinin@virtuozzo.com>
> Signed-off-by: Paul Lawrence <paullawrence@google.com>
> ---
>  scripts/Makefile.kasan | 29 ++++++++++++++++++-----------
>  1 file changed, 18 insertions(+), 11 deletions(-)
>
> diff --git a/scripts/Makefile.kasan b/scripts/Makefile.kasan
> index 1ce7115aa499..d5a1a4b6d079 100644
> --- a/scripts/Makefile.kasan
> +++ b/scripts/Makefile.kasan
> @@ -10,10 +10,7 @@ KASAN_SHADOW_OFFSET ?=3D $(CONFIG_KASAN_SHADOW_OFFSET)
>
>  CFLAGS_KASAN_MINIMAL :=3D -fsanitize=3Dkernel-address
>
> -CFLAGS_KASAN :=3D $(call cc-option, -fsanitize=3Dkernel-address \
> -               -fasan-shadow-offset=3D$(KASAN_SHADOW_OFFSET) \
> -               --param asan-stack=3D1 --param asan-globals=3D1 \
> -               --param asan-instrumentation-with-call-threshold=3D$(call=
_threshold))
> +cc-param =3D $(call cc-option, -mllvm -$(1), $(call cc-option, --param $=
(1)))
>
>  ifeq ($(call cc-option, $(CFLAGS_KASAN_MINIMAL) -Werror),)
>     ifneq ($(CONFIG_COMPILE_TEST),y)
> @@ -21,13 +18,23 @@ ifeq ($(call cc-option, $(CFLAGS_KASAN_MINIMAL) -Werr=
or),)
>              -fsanitize=3Dkernel-address is not supported by compiler)
>     endif
>  else
> -    ifeq ($(CFLAGS_KASAN),)
> -        ifneq ($(CONFIG_COMPILE_TEST),y)
> -            $(warning CONFIG_KASAN: compiler does not support all option=
s.\
> -                Trying minimal configuration)
> -        endif
> -        CFLAGS_KASAN :=3D $(CFLAGS_KASAN_MINIMAL)
> -    endif
> +   # -fasan-shadow-offset fails without -fsanitize
Would be nice to have a comment here explaining that
-fasan-shadow-offset is a GCC flag whereas -asan-mapping-offset is an
LLVM one.
> +   CFLAGS_KASAN_SHADOW :=3D $(call cc-option, -fsanitize=3Dkernel-addres=
s \
> +                       -fasan-shadow-offset=3D$(KASAN_SHADOW_OFFSET), \
> +                       $(call cc-option, -fsanitize=3Dkernel-address \
> +                       -mllvm -asan-mapping-offset=3D$(KASAN_SHADOW_OFFS=
ET)))
> +
> +   ifeq ($(strip $(CFLAGS_KASAN_SHADOW)),)
> +      CFLAGS_KASAN :=3D $(CFLAGS_KASAN_MINIMAL)
> +   else
> +      # Now add all the compiler specific options that are valid standal=
one
> +      CFLAGS_KASAN :=3D $(CFLAGS_KASAN_SHADOW) \
> +       $(call cc-param,asan-globals=3D1) \
> +       $(call cc-param,asan-instrumentation-with-call-threshold=3D$(call=
_threshold)) \
> +       $(call cc-param,asan-stack=3D1) \
> +       $(call cc-param,asan-use-after-scope=3D1)
> +   endif
> +
>  endif
>
>  CFLAGS_KASAN +=3D $(call cc-option, -fsanitize-address-use-after-scope)
> --
> 2.15.0.531.g2ccb3012c9-goog
>
Reviewed-by: Alexander Potapenko <glider@google.com>


--=20
Alexander Potapenko
Software Engineer

Google Germany GmbH
Erika-Mann-Stra=C3=9Fe, 33
80636 M=C3=BCnchen

Gesch=C3=A4ftsf=C3=BChrer: Paul Manicle, Halimah DeLaine Prado
Registergericht und -nummer: Hamburg, HRB 86891
Sitz der Gesellschaft: Hamburg

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
