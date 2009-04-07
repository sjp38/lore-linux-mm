Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with SMTP id 0F91D5F0001
	for <linux-mm@kvack.org>; Tue,  7 Apr 2009 19:21:31 -0400 (EDT)
Received: by rv-out-0708.google.com with SMTP id f25so2621233rvb.26
        for <linux-mm@kvack.org>; Tue, 07 Apr 2009 16:21:51 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20090407150959.C099D1D046E@basil.firstfloor.org>
References: <20090407509.382219156@firstfloor.org>
	 <20090407150959.C099D1D046E@basil.firstfloor.org>
Date: Wed, 8 Apr 2009 08:21:51 +0900
Message-ID: <28c262360904071621j5bdd8e33u1fbd8534d177a941@mail.gmail.com>
Subject: Re: [PATCH] [3/16] POISON: Handle poisoned pages in page free
From: Minchan Kim <minchan.kim@gmail.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
To: Andi Kleen <andi@firstfloor.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, x86@kernel.org
List-ID: <linux-mm.kvack.org>

Hi, Andi.

On Wed, Apr 8, 2009 at 12:09 AM, Andi Kleen <andi@firstfloor.org> wrote:
>
> Make sure no poisoned pages are put back into the free page
> lists. =C2=A0This can happen with some races.
>
> This is allo slow path in the bad page bits path, so another
> check doesn't really matter.
>
> Signed-off-by: Andi Kleen <ak@linux.intel.com>
>
> ---
> =C2=A0mm/page_alloc.c | =C2=A0 =C2=A09 +++++++++
> =C2=A01 file changed, 9 insertions(+)
>
> Index: linux/mm/page_alloc.c
> =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
> --- linux.orig/mm/page_alloc.c =C2=A02009-04-07 16:39:26.000000000 +0200
> +++ linux/mm/page_alloc.c =C2=A0 =C2=A0 =C2=A0 2009-04-07 16:39:39.000000=
000 +0200
> @@ -228,6 +228,15 @@
> =C2=A0 =C2=A0 =C2=A0 =C2=A0static unsigned long nr_unshown;
>
> =C2=A0 =C2=A0 =C2=A0 =C2=A0/*
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0* Page may have been marked bad before proce=
ss is freeing it.
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0* Make sure it is not put back into the free=
 page lists.
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0*/
> + =C2=A0 =C2=A0 =C2=A0 if (PagePoison(page)) {
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 /* check more flags he=
re... */

How about adding WARNING with some information(ex, pfn, flags..).


> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 return;
> + =C2=A0 =C2=A0 =C2=A0 }
> +
> + =C2=A0 =C2=A0 =C2=A0 /*
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 * Allow a burst of 60 reports, then keep quie=
t for that minute;
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 * or allow a steady drip of one report per se=
cond.
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 */
>
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org. =C2=A0For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=3Dmailto:"dont@kvack.org"> email@kvack.org </a>
>



--=20
Kinds regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
