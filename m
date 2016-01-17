Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f181.google.com (mail-ig0-f181.google.com [209.85.213.181])
	by kanga.kvack.org (Postfix) with ESMTP id 523396B0009
	for <linux-mm@kvack.org>; Sun, 17 Jan 2016 05:02:54 -0500 (EST)
Received: by mail-ig0-f181.google.com with SMTP id mw1so33458296igb.1
        for <linux-mm@kvack.org>; Sun, 17 Jan 2016 02:02:54 -0800 (PST)
Received: from mail-ig0-x234.google.com (mail-ig0-x234.google.com. [2607:f8b0:4001:c05::234])
        by mx.google.com with ESMTPS id 82si11755872ioi.171.2016.01.17.02.02.53
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 17 Jan 2016 02:02:53 -0800 (PST)
Received: by mail-ig0-x234.google.com with SMTP id mw1so33458223igb.1
        for <linux-mm@kvack.org>; Sun, 17 Jan 2016 02:02:53 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <5698866F.1070802@nextfour.com>
References: <5698866F.1070802@nextfour.com>
Date: Sun, 17 Jan 2016 12:02:53 +0200
Message-ID: <CAOJsxLFXts1USPU827A1zaZsggER7CVzZah7TGKzNHzqF8Ttsg@mail.gmail.com>
Subject: Re: [PATCH] mm: make apply_to_page_range more robust
From: Pekka Enberg <penberg@kernel.org>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: =?UTF-8?Q?Mika_Penttil=C3=A4?= <mika.penttila@nextfour.com>
Cc: LKML <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>

On Fri, Jan 15, 2016 at 7:41 AM, Mika Penttil=C3=A4
<mika.penttila@nextfour.com> wrote:
> Recent changes (4.4.0+) in module loader triggered oops on ARM. While
> loading a module, size in :
>
> apply_to_page_range(struct mm_struct *mm, unsigned long addr,   unsigned
> long size, pte_fn_t fn, void *data);
>
> can be 0 triggering the bug  BUG_ON(addr >=3D end);.
>
> Fix by letting call with zero size succeed.
>
> --Mika
>
> Signed-off-by: mika.penttila@nextfour.com

Reviewed-by: Pekka Enberg <penberg@kernel.org>

We could also replace that BUG_ON() with a WARN_ON() and return -EINVAL.

> ---
>
> diff --git a/mm/memory.c b/mm/memory.c
> index c387430..c3d1a2e 100644
> --- a/mm/memory.c
> +++ b/mm/memory.c
> @@ -1884,6 +1884,9 @@ int apply_to_page_range(struct mm_struct *mm,
> unsigned long addr,
>         unsigned long end =3D addr + size;
>         int err;
>
> +       if (!size)
> +               return 0;
> +
>         BUG_ON(addr >=3D end);
>         pgd =3D pgd_offset(mm, addr);
>         do {
>
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=3Dmailto:"dont@kvack.org"> email@kvack.org </a>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
