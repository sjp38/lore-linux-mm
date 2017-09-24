Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f69.google.com (mail-it0-f69.google.com [209.85.214.69])
	by kanga.kvack.org (Postfix) with ESMTP id 611716B0038
	for <linux-mm@kvack.org>; Sun, 24 Sep 2017 15:17:53 -0400 (EDT)
Received: by mail-it0-f69.google.com with SMTP id v140so8915881ita.3
        for <linux-mm@kvack.org>; Sun, 24 Sep 2017 12:17:53 -0700 (PDT)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id n63sor2093805ith.147.2017.09.24.12.17.52
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Sun, 24 Sep 2017 12:17:52 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20170921093729.1080368AC1@po15668-vm-win7.idsi0.si.c-s.fr>
References: <20170921093729.1080368AC1@po15668-vm-win7.idsi0.si.c-s.fr>
From: Kees Cook <keescook@chromium.org>
Date: Sun, 24 Sep 2017 12:17:51 -0700
Message-ID: <CAGXu5jJ54+bCcXaPK1ExsxtTDPHNn1+1gywb3TDbe-SEtt1zuQ@mail.gmail.com>
Subject: Re: [PATCH] mm: fix RODATA_TEST failure "rodata_test: test data was
 not read only"
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christophe Leroy <christophe.leroy@c-s.fr>, Michael Ellerman <mpe@ellerman.id.au>
Cc: Jinbum Park <jinb.park7@gmail.com>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, "linuxppc-dev@lists.ozlabs.org" <linuxppc-dev@lists.ozlabs.org>, Andrew Morton <akpm@linux-foundation.org>

On Thu, Sep 21, 2017 at 2:37 AM, Christophe Leroy
<christophe.leroy@c-s.fr> wrote:
> On powerpc, RODATA_TEST fails with message the following messages:
>
> [    6.199505] Freeing unused kernel memory: 528K
> [    6.203935] rodata_test: test data was not read only
>
> This is because GCC allocates it to .data section:
>
> c0695034 g     O .data  00000004 rodata_test_data

Uuuh... that seems like a compiler bug. It's marked "const" -- it
should never end up in .data. I would argue that this has done exactly
what it was supposed to do, and shows that something has gone wrong.
It should always be const. Adding "static" should just change
visibility. (I'm not opposed to the static change, but it seems to
paper over a problem with the compiler...)

-Kees

>
> Since commit 056b9d8a76924 ("mm: remove rodata_test_data export,
> add pr_fmt"), rodata_test_data is used only inside rodata_test.c
> By declaring it static, it gets properly allocated into .rodata
> section instead of .data:
>
> c04df710 l     O .rodata        00000004 rodata_test_data
>
> Signed-off-by: Christophe Leroy <christophe.leroy@c-s.fr>
> ---
>  mm/rodata_test.c | 2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
>
> diff --git a/mm/rodata_test.c b/mm/rodata_test.c
> index 6bb4deb12e78..d908c8769b48 100644
> --- a/mm/rodata_test.c
> +++ b/mm/rodata_test.c
> @@ -14,7 +14,7 @@
>  #include <linux/uaccess.h>
>  #include <asm/sections.h>
>
> -const int rodata_test_data = 0xC3;
> +static const int rodata_test_data = 0xC3;
>
>  void rodata_test(void)
>  {
> --
> 2.13.3
>



-- 
Kees Cook
Pixel Security

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
