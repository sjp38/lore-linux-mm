Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx144.postini.com [74.125.245.144])
	by kanga.kvack.org (Postfix) with SMTP id 988BF6B0032
	for <linux-mm@kvack.org>; Fri, 28 Jun 2013 02:56:52 -0400 (EDT)
Date: Fri, 28 Jun 2013 16:56:41 +1000
From: Stephen Rothwell <sfr@canb.auug.org.au>
Subject: Re: mmotm 2013-06-27-16-36 uploaded (wait event common)
Message-Id: <20130628165641.2193bfcd78c1f27d6f68f9a5@canb.auug.org.au>
In-Reply-To: <51CD27F3.30104@infradead.org>
References: <20130627233733.BAEB131C3BE@corp2gmr1-1.hot.corp.google.com>
	<51CD1F81.4040202@infradead.org>
	<20130627225139.798e7b00.akpm@linux-foundation.org>
	<51CD27F3.30104@infradead.org>
Mime-Version: 1.0
Content-Type: multipart/signed; protocol="application/pgp-signature";
 micalg="PGP-SHA256";
 boundary="Signature=_Fri__28_Jun_2013_16_56_41_+1000_Dj94cR2p3c9XZpfW"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Randy Dunlap <rdunlap@infradead.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, mm-commits@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, linux-next@vger.kernel.org, Oleg Nesterov <oleg@redhat.com>

--Signature=_Fri__28_Jun_2013_16_56_41_+1000_Dj94cR2p3c9XZpfW
Content-Type: text/plain; charset=US-ASCII
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Hi Guys,

On Thu, 27 Jun 2013 23:06:43 -0700 Randy Dunlap <rdunlap@infradead.org> wro=
te:
>
> On 06/27/13 22:51, Andrew Morton wrote:
> > On Thu, 27 Jun 2013 22:30:41 -0700 Randy Dunlap <rdunlap@infradead.org>=
 wrote:
> >=20
> >> On 06/27/13 16:37, akpm@linux-foundation.org wrote:
> >>> The mm-of-the-moment snapshot 2013-06-27-16-36 has been uploaded to
> >>>
> >>>    http://www.ozlabs.org/~akpm/mmotm/
> >>>
> >>> mmotm-readme.txt says
> >>>
> >>> README for mm-of-the-moment:
> >>>
> >>> http://www.ozlabs.org/~akpm/mmotm/
> >>>
> >>
> >> My builds are littered with hundreds of warnings like this one:
> >>
> >> drivers/tty/tty_ioctl.c:220:6: warning: the omitted middle operand in =
?: will always be 'true', suggest explicit middle operand [-Wparentheses]
> >>
> >> I guess due to this line from wait_event_common():
> >>
> >> +		__ret =3D __wait_no_timeout(tout) ?: (tout) ?: 1;
> >>
> >=20
> > Ah, sorry, I missed that.  Had I noticed it, I would have spat it back
> > on taste grounds alone, it being unfit for human consumption.
> >=20
> > Something like this?
> >=20
> > --- a/include/linux/wait.h~wait-introduce-wait_event_commonwq-condition=
-state-timeout-fix
> > +++ a/include/linux/wait.h
> > @@ -196,7 +196,11 @@ wait_queue_head_t *bit_waitqueue(void *,
> >  	for (;;) {							\
> >  		prepare_to_wait(&wq, &__wait, state);			\
> >  		if (condition) {					\
> > -			__ret =3D __wait_no_timeout(tout) ?: __tout ?: 1;	\
> > +			__ret =3D __wait_no_timeout(tout);		\
> > +			if (!__ret)					\
> > +				__ret =3D __tout;				\
> > +				if (!__ret)				\
> > +					__ret =3D 1;			\
> >  			break;						\
> >  		}							\
> >  									\
> >=20
> >=20
>=20
> That does reduce the number of warnings, but the wait_event_common() macro
> needs similar treatment.  I.e., I am still getting those warnings, just n=
ot
> quite as many. (down from 2 per source code line to 1 per source code line
> which contains some kind of wait...)

I added the following to linux-next today:
(sorry Randy, I forgot the Reported-by:, Andrew please add)

From: Stephen Rothwell <sfr@canb.auug.org.au>
Date: Fri, 28 Jun 2013 16:52:58 +1000
Subject: [PATCH] fix warnings from ?: operator in wait.h

Signed-off-by: Stephen Rothwell <sfr@canb.auug.org.au>
---
 include/linux/wait.h | 18 ++++++++++++++----
 1 file changed, 14 insertions(+), 4 deletions(-)

diff --git a/include/linux/wait.h b/include/linux/wait.h
index 1c08a6c..f3b793d 100644
--- a/include/linux/wait.h
+++ b/include/linux/wait.h
@@ -197,7 +197,12 @@ wait_queue_head_t *bit_waitqueue(void *, int);
 	for (;;) {							\
 		__ret =3D prepare_to_wait_event(&wq, &__wait, state);	\
 		if (condition) {					\
-			__ret =3D __wait_no_timeout(tout) ?: __tout ?: 1;	\
+			__ret =3D __wait_no_timeout(tout);		\
+			if (!__ret) {					\
+				__ret =3D __tout;				\
+				if (!__ret)				\
+					__ret =3D 1;			\
+			}						\
 			break;						\
 		}							\
 									\
@@ -218,9 +223,14 @@ wait_queue_head_t *bit_waitqueue(void *, int);
 #define wait_event_common(wq, condition, state, tout)			\
 ({									\
 	long __ret;							\
-	if (condition)							\
-		__ret =3D __wait_no_timeout(tout) ?: (tout) ?: 1;		\
-	else								\
+	if (condition) {						\
+		__ret =3D __wait_no_timeout(tout);			\
+		if (!__ret) {						\
+			__ret =3D (tout);					\
+			if (!__ret)					\
+				__ret =3D 1;				\
+		}							\
+	} else								\
 		__ret =3D __wait_event_common(wq, condition, state, tout);\
 	__ret;								\
 })
--=20
1.8.3.1

--=20
Cheers,
Stephen Rothwell                    sfr@canb.auug.org.au

--Signature=_Fri__28_Jun_2013_16_56_41_+1000_Dj94cR2p3c9XZpfW
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.20 (GNU/Linux)

iQIcBAEBCAAGBQJRzTOtAAoJEECxmPOUX5FEQGgP/jdZotcz6/Z1peB6gkL30T7O
DPSteegSjtWejGtleV2fBAkGzZOE1/I+CnYWbB8ol/3w/t8d8orBNzT+Z/hVw1XJ
Rm7crBXNAhMnNY2ekRclWl53k+m6Zs+SQrbBn8uMPJTZ0k0zNS5oOefGQSKD4fq1
Jv7DSfH2Pn6vtBt+9h8tH7UuBaftYg4n5qIqdTM41L27HiwAYOHnvx4uarjcf+CV
2UlHMoKLMTXJMEmc2lmM/2bzDUQvPVHlV7J3slDCJ7yxeaxQb9qxTaQ/dNe8o0R1
+AIWlWDMC0DQevB7EfPeMRSv1jBfJNBjlD6RVpB+BtN5F1YpbDri5BXwI26BsB3q
WAJyCzGQWGDAnD1CeS9GPRbPtUK9i5AzEDPDcF8UiPi6ITdKVSyNnx16L9kcE0Sh
IE0Mj26nUECeeDVWnoJJ1QMQCWkgnulJ6oZBH/XJmVBc0b+aHWMvt9J4L7hZkVFV
qwM/wjx9EyysJ/MwJ1MhsfuTHjNrxm+VSpM8gHfdX+g5s0pZn5SeqXQKY60ufLyh
i0cnAqzmP4AJkAvWxiYFddeMQpxrdTWrw3HCcXfLcRtIXcpHjtiTZ0AElEFA0tVH
pV0UBOMpqnA1LIrdMbXxhxw6XcFMYEyCA+mXZEonFPf5fvrLML0fcOCfYtc300xH
0L15fw7q/v2Q9UFWJ9kJ
=81mh
-----END PGP SIGNATURE-----

--Signature=_Fri__28_Jun_2013_16_56_41_+1000_Dj94cR2p3c9XZpfW--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
