Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f72.google.com (mail-it0-f72.google.com [209.85.214.72])
	by kanga.kvack.org (Postfix) with ESMTP id C2C5028026B
	for <linux-mm@kvack.org>; Sun, 25 Sep 2016 20:49:27 -0400 (EDT)
Received: by mail-it0-f72.google.com with SMTP id j69so60589955itb.1
        for <linux-mm@kvack.org>; Sun, 25 Sep 2016 17:49:27 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id m184si4939334itd.81.2016.09.25.17.49.26
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 25 Sep 2016 17:49:27 -0700 (PDT)
Message-ID: <1474850960.17726.48.camel@redhat.com>
Subject: Re: [PATCH] mm: check VMA flags to avoid invalid PROT_NONE NUMA
 balancing
From: Rik van Riel <riel@redhat.com>
Date: Sun, 25 Sep 2016 20:49:20 -0400
In-Reply-To: <CA+55aFyL+qFsJpxQufgRKgWeB6Yj0e1oapdu5mdU9_t+zwtBjg@mail.gmail.com>
References: <20160911225425.10388-1-lstoakes@gmail.com>
	 <20160925184731.GA20480@lucifer>
	 <CA+55aFwtHAT_ukyE=+s=3twW8v8QExLxpVcfEDyLihf+pn9qeA@mail.gmail.com>
	 <1474842875.17726.38.camel@redhat.com>
	 <CA+55aFyL+qFsJpxQufgRKgWeB6Yj0e1oapdu5mdU9_t+zwtBjg@mail.gmail.com>
Content-Type: multipart/signed; micalg="pgp-sha256";
	protocol="application/pgp-signature"; boundary="=-ThUb+ux4Vw7kTXofnSWa"
Mime-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>, Hugh Dickins <hughd@google.com>
Cc: Lorenzo Stoakes <lstoakes@gmail.com>, linux-mm <linux-mm@kvack.org>, Mel Gorman <mgorman@techsingularity.net>, tbsaunde@tbsaunde.org, robert@ocallahan.org, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>


--=-ThUb+ux4Vw7kTXofnSWa
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Sun, 2016-09-25 at 15:50 -0700, Linus Torvalds wrote:
> On Sun, Sep 25, 2016 at 3:34 PM, Rik van Riel <riel@redhat.com>
> wrote:
> >=20
> >=20
> > The patch looks good to me, too.
> >=20
> > Acked-by: Rik van Riel <riel@redhat.com>
>=20
> Thanks, amended the commit since I hadn't pushed out yet.
>=20
> Btw, the only reason this bug could happen is that we do that
> "force=3D1" for remote vm accesses, which turns into FOLL_FORCE, which
> in turn will turn into us allowing an access even when we technically
> shouldn't.
>=20
> I'd really like to re-open the "drop FOLL_FORCE entirely" discussion,
> because the thing really is disgusting.
>=20
> I realize that debuggers etc sometimes would want to punch through
> PROT_NONE protections,

Reading the code for a little bit, it looks like get_user_pages
interprets both PROT_NONE and PAGE_NUMA ptes as present, and will
simply return the page to the caller.

Furthermore, if a page in a PROT_NONE VMA is actually not present,
it should be faulted in with PROT_NONE permissions, after which
the page is passed to the debugger.

That is, punching through PROT_NONE permissions should only happen
from outside of the process. Inside the process, PROT_NONE should
be preserved regardless of FOLL_FORCE.

--=20
All Rights Reversed.
--=-ThUb+ux4Vw7kTXofnSWa
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part
Content-Transfer-Encoding: 7bit

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQEcBAABCAAGBQJX6HCQAAoJEM553pKExN6DfmMIALBz2Vo3MKN6pxtAB+8NBpqw
87WZ8wAcMU3t/+7otSjpFZJJifwv96tcRYlaU83l0+9+hLyvuyLUw3a1J0QkuGai
fbkmUuZrAPvYp0AoGtcprnTOqQPXNRMyvDIYckHFN6M1YjOoMHYCb2hyyh9kDUlD
sWeXe42CUO9TgvMrcr3Pt/wwbFX02LNEWhzu/C112k+31waJcSAG6PzZt9AZ4b6m
9lVaPXYNGlmHuXcbAylFzviCwNO2b/JA8U7S2CetIQC7KPZb1YEqlwN7E8KcnmRB
eAAQIMRDG1lKzQbsql+gGeol03fRSCaz4a4Xmaw6yH/tLeHGEk+KC9CH7ERw9H8=
=t1gA
-----END PGP SIGNATURE-----

--=-ThUb+ux4Vw7kTXofnSWa--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
