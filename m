Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx188.postini.com [74.125.245.188])
	by kanga.kvack.org (Postfix) with SMTP id 649B26B004D
	for <linux-mm@kvack.org>; Fri, 13 Apr 2012 15:12:22 -0400 (EDT)
Received: by iajr24 with SMTP id r24so6311393iaj.14
        for <linux-mm@kvack.org>; Fri, 13 Apr 2012 12:12:21 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <1330629779-1449-1-git-send-email-daniel.vetter@ffwll.ch>
References: <20120229153216.8c3ae31d.akpm@linux-foundation.org>
	<1330629779-1449-1-git-send-email-daniel.vetter@ffwll.ch>
Date: Fri, 13 Apr 2012 21:12:21 +0200
Message-ID: <CAMuHMdXBEiDGyJQ+szoBKxo0pS=n3xKfpb=F+rNkMQUv4SdTQA@mail.gmail.com>
Subject: Re: [PATCH] mm: extend prefault helpers to fault in more than PAGE_SIZE
From: Geert Uytterhoeven <geert@linux-m68k.org>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Daniel Vetter <daniel.vetter@ffwll.ch>
Cc: Andrew Morton <akpm@linux-foundation.org>, Intel Graphics Development <intel-gfx@lists.freedesktop.org>, DRI Development <dri-devel@lists.freedesktop.org>, LKML <linux-kernel@vger.kernel.org>, Linux MM <linux-mm@kvack.org>, Linux-Next <linux-next@vger.kernel.org>

On Thu, Mar 1, 2012 at 20:22, Daniel Vetter <daniel.vetter@ffwll.ch> wrote:
> +/* Multipage variants of the above prefault helpers, useful if more than
> + * PAGE_SIZE of date needs to be prefaulted. These are separate from the=
 above
> + * functions (which only handle up to PAGE_SIZE) to avoid clobbering the
> + * filemap.c hotpaths. */
> +static inline int fault_in_multipages_writeable(char __user *uaddr, int =
size)
> +{
> + =C2=A0 =C2=A0 =C2=A0 int ret;
> + =C2=A0 =C2=A0 =C2=A0 const char __user *end =3D uaddr + size - 1;

Please drop the const.

> +
> + =C2=A0 =C2=A0 =C2=A0 if (unlikely(size =3D=3D 0))
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 return 0;
> +
> + =C2=A0 =C2=A0 =C2=A0 /*
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0* Writing zeroes into userspace here is OK, =
because we know that if
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0* the zero gets there, we'll be overwriting =
it.
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0*/
> + =C2=A0 =C2=A0 =C2=A0 while (uaddr <=3D end) {
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 ret =3D __put_user(0, =
uaddr);
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 if (ret !=3D 0)
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 return ret;
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 uaddr +=3D PAGE_SIZE;
> + =C2=A0 =C2=A0 =C2=A0 }
> +
> + =C2=A0 =C2=A0 =C2=A0 /* Check whether the range spilled into the next p=
age. */
> + =C2=A0 =C2=A0 =C2=A0 if (((unsigned long)uaddr & PAGE_MASK) =3D=3D
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 ((unsigned long)end & PAGE_MASK))
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 ret =3D __put_user(0, =
end);

include/linux/pagemap.h:483:3: error: read-only location '*end' used
as 'asm' output

Now in -next:

http://kisskb.ellerman.id.au/kisskb/buildresult/6100650/
http://kisskb.ellerman.id.au/kisskb/buildresult/6100673/
http://kisskb.ellerman.id.au/kisskb/buildresult/6100860/

Gr{oetje,eeting}s,

=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 Geert

--
Geert Uytterhoeven -- There's lots of Linux beyond ia32 -- geert@linux-m68k=
.org

In personal conversations with technical people, I call myself a hacker. Bu=
t
when I'm talking to journalists I just say "programmer" or something like t=
hat.
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0=C2=A0 =C2=A0=C2=A0 -- Linus Torvalds

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
