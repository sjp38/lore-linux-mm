Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f71.google.com (mail-lf0-f71.google.com [209.85.215.71])
	by kanga.kvack.org (Postfix) with ESMTP id 5E0056B0253
	for <linux-mm@kvack.org>; Fri, 13 May 2016 08:18:38 -0400 (EDT)
Received: by mail-lf0-f71.google.com with SMTP id j8so67132049lfd.0
        for <linux-mm@kvack.org>; Fri, 13 May 2016 05:18:38 -0700 (PDT)
Received: from mail-lf0-x22e.google.com (mail-lf0-x22e.google.com. [2a00:1450:4010:c07::22e])
        by mx.google.com with ESMTPS id ar10si13037836lbc.129.2016.05.13.05.18.37
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 13 May 2016 05:18:37 -0700 (PDT)
Received: by mail-lf0-x22e.google.com with SMTP id y84so87657005lfc.0
        for <linux-mm@kvack.org>; Fri, 13 May 2016 05:18:37 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <1462538722-1574-3-git-send-email-aryabinin@virtuozzo.com>
References: <1462538722-1574-1-git-send-email-aryabinin@virtuozzo.com>
	<1462538722-1574-3-git-send-email-aryabinin@virtuozzo.com>
Date: Fri, 13 May 2016 14:18:36 +0200
Message-ID: <CAG_fn=UE_LuqrJNJs9dWFD5TmazvR=Jjrv4fDnExSy4-WvoT7Q@mail.gmail.com>
Subject: Re: [PATCH 3/4] mm/kasan: add API to check memory regions
From: Alexander Potapenko <glider@google.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrey Ryabinin <aryabinin@virtuozzo.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, kasan-dev <kasan-dev@googlegroups.com>, Linux Memory Management List <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Dmitry Vyukov <dvyukov@google.com>

On Fri, May 6, 2016 at 2:45 PM, Andrey Ryabinin <aryabinin@virtuozzo.com> w=
rote:
> Memory access coded in an assembly won't be seen by KASAN as a compiler
> can instrument only C code. Add kasan_check_[read,write]() API
> which is going to be used to check a certain memory range.
>
> Signed-off-by: Andrey Ryabinin <aryabinin@virtuozzo.com>
> Cc: Alexander Potapenko <glider@google.com>
> Cc: Dmitry Vyukov <dvyukov@google.com>
> ---
>  MAINTAINERS                  |  2 +-
>  include/linux/kasan-checks.h | 12 ++++++++++++
>  mm/kasan/kasan.c             | 12 ++++++++++++
>  3 files changed, 25 insertions(+), 1 deletion(-)
>  create mode 100644 include/linux/kasan-checks.h
>
> diff --git a/MAINTAINERS b/MAINTAINERS
> index 43b85c1..3a9471c 100644
> --- a/MAINTAINERS
> +++ b/MAINTAINERS
> @@ -6363,7 +6363,7 @@ S:        Maintained
>  F:     arch/*/include/asm/kasan.h
>  F:     arch/*/mm/kasan_init*
>  F:     Documentation/kasan.txt
> -F:     include/linux/kasan.h
> +F:     include/linux/kasan*.h
>  F:     lib/test_kasan.c
>  F:     mm/kasan/
>  F:     scripts/Makefile.kasan
> diff --git a/include/linux/kasan-checks.h b/include/linux/kasan-checks.h
> new file mode 100644
> index 0000000..b7f8ace
> --- /dev/null
> +++ b/include/linux/kasan-checks.h
> @@ -0,0 +1,12 @@
> +#ifndef _LINUX_KASAN_CHECKS_H
> +#define _LINUX_KASAN_CHECKS_H
> +
> +#ifdef CONFIG_KASAN
> +void kasan_check_read(const void *p, unsigned int size);
> +void kasan_check_write(const void *p, unsigned int size);
> +#else
> +static inline void kasan_check_read(const void *p, unsigned int size) { =
}
> +static inline void kasan_check_write(const void *p, unsigned int size) {=
 }
> +#endif
> +
> +#endif
> diff --git a/mm/kasan/kasan.c b/mm/kasan/kasan.c
> index 6e4072c..54f0ea7 100644
> --- a/mm/kasan/kasan.c
> +++ b/mm/kasan/kasan.c
> @@ -299,6 +299,18 @@ static void check_memory_region(unsigned long addr,
>         check_memory_region_inline(addr, size, write, ret_ip);
>  }
>
> +void kasan_check_read(const void *p, unsigned int size)
> +{
> +       check_memory_region((unsigned long)p, size, false, _RET_IP_);
> +}
> +EXPORT_SYMBOL(kasan_check_read);
> +
> +void kasan_check_write(const void *p, unsigned int size)
> +{
> +       check_memory_region((unsigned long)p, size, true, _RET_IP_);
> +}
> +EXPORT_SYMBOL(kasan_check_write);
> +
>  #undef memset
>  void *memset(void *addr, int c, size_t len)
>  {
> --
> 2.7.3
>
Acked-by: Alexander Potapenko <glider@google.com>


--=20
Alexander Potapenko
Software Engineer

Google Germany GmbH
Erika-Mann-Stra=C3=9Fe, 33
80636 M=C3=BCnchen

Gesch=C3=A4ftsf=C3=BChrer: Matthew Scott Sucherman, Paul Terence Manicle
Registergericht und -nummer: Hamburg, HRB 86891
Sitz der Gesellschaft: Hamburg

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
