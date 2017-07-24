Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ua0-f198.google.com (mail-ua0-f198.google.com [209.85.217.198])
	by kanga.kvack.org (Postfix) with ESMTP id 4EB9E6B0292
	for <linux-mm@kvack.org>; Mon, 24 Jul 2017 07:35:15 -0400 (EDT)
Received: by mail-ua0-f198.google.com with SMTP id 91so83718558uau.10
        for <linux-mm@kvack.org>; Mon, 24 Jul 2017 04:35:15 -0700 (PDT)
Received: from mail-ua0-x22f.google.com (mail-ua0-x22f.google.com. [2607:f8b0:400c:c08::22f])
        by mx.google.com with ESMTPS id l43si4193126uai.375.2017.07.24.04.35.14
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 24 Jul 2017 04:35:14 -0700 (PDT)
Received: by mail-ua0-x22f.google.com with SMTP id 80so75958078uas.0
        for <linux-mm@kvack.org>; Mon, 24 Jul 2017 04:35:14 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20170721210251.3378996-1-arnd@arndb.de>
References: <20170721210251.3378996-1-arnd@arndb.de>
From: Alexander Potapenko <glider@google.com>
Date: Mon, 24 Jul 2017 13:35:11 +0200
Message-ID: <CAG_fn=UzULc1oRfF5BVHXgfKOC6eoGuwwT1cJ9oHJO7hCNzscQ@mail.gmail.com>
Subject: Re: [PATCH] [v2] kasan: avoid -Wmaybe-uninitialized warning
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Arnd Bergmann <arnd@arndb.de>
Cc: Andrey Ryabinin <aryabinin@virtuozzo.com>, Dmitry Vyukov <dvyukov@google.com>, Andrew Morton <akpm@linux-foundation.org>, Andrey Konovalov <andreyknvl@google.com>, kasan-dev <kasan-dev@googlegroups.com>, Linux Memory Management List <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On Fri, Jul 21, 2017 at 11:02 PM, Arnd Bergmann <arnd@arndb.de> wrote:
> gcc-7 produces this warning:
>
> mm/kasan/report.c: In function 'kasan_report':
> mm/kasan/report.c:351:3: error: 'info.first_bad_addr' may be used uniniti=
alized in this function [-Werror=3Dmaybe-uninitialized]
>    print_shadow_for_address(info->first_bad_addr);
>    ^~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
> mm/kasan/report.c:360:27: note: 'info.first_bad_addr' was declared here
>
> The code seems fine as we only print info.first_bad_addr when there is a =
shadow,
> and we always initialize it in that case, but this is relatively hard
> for gcc to figure out after the latest rework. Adding an intialization
> in the other code path gets rid of the warning.
>
> Fixes: b235b9808664 ("kasan: unify report headers")
> Link: https://patchwork.kernel.org/patch/9641417/
> Acked-by: Dmitry Vyukov <dvyukov@google.com>
> Signed-off-by: Arnd Bergmann <arnd@arndb.de>
> ---
> Originally submitted on March 23, but unfortunately is still needed,
> as verified on 4.13-rc1, with aarch64-linux-gcc-7.1.1
>
> v2: add a comment as Andrew suggested
> ---
>  mm/kasan/report.c | 3 +++
>  1 file changed, 3 insertions(+)
>
> diff --git a/mm/kasan/report.c b/mm/kasan/report.c
> index 04bb1d3eb9ec..28fb222ab149 100644
> --- a/mm/kasan/report.c
> +++ b/mm/kasan/report.c
> @@ -111,6 +111,9 @@ static const char *get_wild_bug_type(struct kasan_acc=
ess_info *info)
>  {
>         const char *bug_type =3D "unknown-crash";
>
> +       /* shut up spurious -Wmaybe-uninitialized warning */
> +       info->first_bad_addr =3D (void *)(-1ul);
> +
Why don't we initialize info.first_bad_addr in kasan_report(), where
info is allocated?
>         if ((unsigned long)info->access_addr < PAGE_SIZE)
>                 bug_type =3D "null-ptr-deref";
>         else if ((unsigned long)info->access_addr < TASK_SIZE)
> --
> 2.9.0
>



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
