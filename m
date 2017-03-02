Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f199.google.com (mail-qk0-f199.google.com [209.85.220.199])
	by kanga.kvack.org (Postfix) with ESMTP id B4AC06B0387
	for <linux-mm@kvack.org>; Thu,  2 Mar 2017 12:19:36 -0500 (EST)
Received: by mail-qk0-f199.google.com with SMTP id j127so10386284qke.2
        for <linux-mm@kvack.org>; Thu, 02 Mar 2017 09:19:36 -0800 (PST)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id d27sor416054qtg.12.1969.12.31.16.00.00
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 02 Mar 2017 09:19:36 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20170302134851.101218-2-andreyknvl@google.com>
References: <20170302134851.101218-1-andreyknvl@google.com> <20170302134851.101218-2-andreyknvl@google.com>
From: Alexander Potapenko <glider@google.com>
Date: Thu, 2 Mar 2017 18:19:35 +0100
Message-ID: <CAG_fn=XKq3tTEf_kg6uoTX2MXfP6AYhe3_QiE9oe1VRnTLk1tA@mail.gmail.com>
Subject: Re: [PATCH v2 1/9] kasan: introduce helper functions for determining
 bug type
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrey Konovalov <andreyknvl@google.com>
Cc: Andrey Ryabinin <aryabinin@virtuozzo.com>, Dmitry Vyukov <dvyukov@google.com>, kasan-dev <kasan-dev@googlegroups.com>, Linux Memory Management List <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On Thu, Mar 2, 2017 at 2:48 PM, Andrey Konovalov <andreyknvl@google.com> wr=
ote:
> Introduce get_shadow_bug_type() function, which determines bug type
> based on the shadow value for a particular kernel address.
> Introduce get_wild_bug_type() function, which determines bug type
> for addresses which don't have a corresponding shadow value.
>
> Signed-off-by: Andrey Konovalov <andreyknvl@google.com>
> ---
>  mm/kasan/report.c | 40 ++++++++++++++++++++++++++++++----------
>  1 file changed, 30 insertions(+), 10 deletions(-)
>
> diff --git a/mm/kasan/report.c b/mm/kasan/report.c
> index f479365530b6..2790b4cadfa3 100644
> --- a/mm/kasan/report.c
> +++ b/mm/kasan/report.c
> @@ -49,7 +49,13 @@ static const void *find_first_bad_addr(const void *add=
r, size_t size)
>         return first_bad_addr;
>  }
>
> -static void print_error_description(struct kasan_access_info *info)
> +static bool addr_has_shadow(struct kasan_access_info *info)
> +{
> +       return (info->access_addr >=3D
> +               kasan_shadow_to_mem((void *)KASAN_SHADOW_START));
> +}
> +
> +static const char *get_shadow_bug_type(struct kasan_access_info *info)
>  {
>         const char *bug_type =3D "unknown-crash";
>         u8 *shadow_addr;
> @@ -96,6 +102,27 @@ static void print_error_description(struct kasan_acce=
ss_info *info)
>                 break;
>         }
>
> +       return bug_type;
> +}
> +
> +const char *get_wild_bug_type(struct kasan_access_info *info)
> +{
> +       const char *bug_type =3D "unknown-crash";
You don't seem to need "unknown-crash" here.
> +       if ((unsigned long)info->access_addr < PAGE_SIZE)
> +               bug_type =3D "null-ptr-deref";
> +       else if ((unsigned long)info->access_addr < TASK_SIZE)
> +               bug_type =3D "user-memory-access";
> +       else
> +               bug_type =3D "wild-memory-access";
> +
> +       return bug_type;
> +}
> +
> +static void print_error_description(struct kasan_access_info *info)
> +{
> +       const char *bug_type =3D get_shadow_bug_type(info);
> +
>         pr_err("BUG: KASAN: %s in %pS at addr %p\n",
>                 bug_type, (void *)info->ip,
>                 info->access_addr);
> @@ -265,18 +292,11 @@ static void print_shadow_for_address(const void *ad=
dr)
>  static void kasan_report_error(struct kasan_access_info *info)
>  {
>         unsigned long flags;
> -       const char *bug_type;
>
>         kasan_start_report(&flags);
>
> -       if (info->access_addr <
> -                       kasan_shadow_to_mem((void *)KASAN_SHADOW_START)) =
{
> -               if ((unsigned long)info->access_addr < PAGE_SIZE)
> -                       bug_type =3D "null-ptr-deref";
> -               else if ((unsigned long)info->access_addr < TASK_SIZE)
> -                       bug_type =3D "user-memory-access";
> -               else
> -                       bug_type =3D "wild-memory-access";
> +       if (!addr_has_shadow(info)) {
> +               const char *bug_type =3D get_wild_bug_type(info);
>                 pr_err("BUG: KASAN: %s on address %p\n",
>                         bug_type, info->access_addr);
>                 pr_err("%s of size %zu by task %s/%d\n",
> --
> 2.12.0.rc1.440.g5b76565f74-goog
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
