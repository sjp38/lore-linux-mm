Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx167.postini.com [74.125.245.167])
	by kanga.kvack.org (Postfix) with SMTP id 1DFC06B0083
	for <linux-mm@kvack.org>; Thu, 16 Feb 2012 08:32:09 -0500 (EST)
Received: by pbcwz17 with SMTP id wz17so3120348pbc.14
        for <linux-mm@kvack.org>; Thu, 16 Feb 2012 05:32:08 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <1329393696-4802-2-git-send-email-daniel.vetter@ffwll.ch>
References: <1329393696-4802-1-git-send-email-daniel.vetter@ffwll.ch>
	<1329393696-4802-2-git-send-email-daniel.vetter@ffwll.ch>
Date: Thu, 16 Feb 2012 21:32:08 +0800
Message-ID: <CAJd=RBBr4EkCwAaS3xZZrm0QE71Z0soyZXTuwXyBn6ohp3pU2Q@mail.gmail.com>
Subject: Re: [PATCH] mm: extend prefault helpers to fault in more than PAGE_SIZE
From: Hillf Danton <dhillf@gmail.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Daniel Vetter <daniel.vetter@ffwll.ch>
Cc: Andrew Morton <akpm@linux-foundation.org>, Intel Graphics Development <intel-gfx@lists.freedesktop.org>, DRI Development <dri-devel@lists.freedesktop.org>, LKML <linux-kernel@vger.kernel.org>, Linux MM <linux-mm@kvack.org>

On Thu, Feb 16, 2012 at 8:01 PM, Daniel Vetter <daniel.vetter@ffwll.ch> wro=
te:
> @@ -416,17 +417,20 @@ static inline int fault_in_pages_writeable(char __u=
ser *uaddr, int size)
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 * Writing zeroes into userspace here is OK, b=
ecause we know that if
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 * the zero gets there, we'll be overwriting i=
t.
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 */
> - =C2=A0 =C2=A0 =C2=A0 ret =3D __put_user(0, uaddr);
> + =C2=A0 =C2=A0 =C2=A0 while (uaddr <=3D end) {
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 ret =3D __put_user(0, =
uaddr);
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 if (ret !=3D 0)
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 return ret;
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 uaddr +=3D PAGE_SIZE;
> + =C2=A0 =C2=A0 =C2=A0 }

What if
             uaddr & ~PAGE_MASK =3D=3D PAGE_SIZE -3 &&
                end & ~PAGE_MASK =3D=3D 2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
