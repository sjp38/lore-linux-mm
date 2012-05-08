Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx185.postini.com [74.125.245.185])
	by kanga.kvack.org (Postfix) with SMTP id 67D916B0044
	for <linux-mm@kvack.org>; Tue,  8 May 2012 16:16:10 -0400 (EDT)
Received: by pbbrp2 with SMTP id rp2so10973182pbb.14
        for <linux-mm@kvack.org>; Tue, 08 May 2012 13:16:09 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20120507193202.GA11518@sgi.com>
References: <20120507193202.GA11518@sgi.com>
Date: Tue, 8 May 2012 13:16:08 -0700
Message-ID: <CAE9FiQXuaJqq9HH-_mOqJHM4Veyz-Yw85we7=26b=dkfgW73dQ@mail.gmail.com>
Subject: Re: [patch] mm: nobootmem: fix sign extend problem in __free_pages_memory()
From: Yinghai Lu <yinghai@kernel.org>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Russ Anderson <rja@sgi.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, David Miller <davem@davemloft.net>

On Mon, May 7, 2012 at 12:32 PM, Russ Anderson <rja@sgi.com> wrote:
> Systems with 8 TBytes of memory or greater can hit a problem
> where only the the first 8 TB of memory shows up. =A0This is
> due to "int i" being smaller than "unsigned long start_aligned",
> causing the high bits to be dropped.

when you have 8T installed, you should get [0,2g), [4g, 8T+2g)

if you have more than that. [2g, 4g) could be added as ram together
with MMIO....

>
> The fix is to change i to unsigned long to match start_aligned
> and end_aligned.
>
> Thanks to Jack Steiner (steiner@sgi.com) for assistance tracking
> this down.
>
> Signed-off-by: Russ Anderson <rja@sgi.com>
>
> ---
> =A0mm/nobootmem.c | =A0 =A03 +--
> =A01 file changed, 1 insertion(+), 2 deletions(-)
>
> Index: linux/mm/nobootmem.c
> =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
> --- linux.orig/mm/nobootmem.c =A0 2012-05-05 08:39:39.470845187 -0500
> +++ linux/mm/nobootmem.c =A0 =A0 =A0 =A02012-05-05 08:39:42.714784530 -05=
00
> @@ -82,8 +82,7 @@ void __init free_bootmem_late(unsigned l
>
> =A0static void __init __free_pages_memory(unsigned long start, unsigned l=
ong end)
> =A0{
> - =A0 =A0 =A0 int i;
> - =A0 =A0 =A0 unsigned long start_aligned, end_aligned;
> + =A0 =A0 =A0 unsigned long i, start_aligned, end_aligned;
> =A0 =A0 =A0 =A0int order =3D ilog2(BITS_PER_LONG);
>
> =A0 =A0 =A0 =A0start_aligned =3D (start + (BITS_PER_LONG - 1)) & ~(BITS_P=
ER_LONG - 1);

Acked-by: Yinghai Lu <yinghai@kernel.org>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
