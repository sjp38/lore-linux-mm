Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx185.postini.com [74.125.245.185])
	by kanga.kvack.org (Postfix) with SMTP id C15146B005A
	for <linux-mm@kvack.org>; Fri, 21 Dec 2012 07:46:31 -0500 (EST)
Received: by mail-we0-f173.google.com with SMTP id z2so2069304wey.4
        for <linux-mm@kvack.org>; Fri, 21 Dec 2012 04:46:30 -0800 (PST)
From: Michal Nazarewicz <mina86@mina86.com>
Subject: Re: [PATCH] mm: compare MIGRATE_ISOLATE selectively
In-Reply-To: <20121221010902.GD2686@blaptop>
References: <1355981152-2505-1-git-send-email-minchan@kernel.org> <xa1tfw30hgfb.fsf@mina86.com> <20121221010902.GD2686@blaptop>
Date: Fri, 21 Dec 2012 13:46:23 +0100
Message-ID: <xa1tr4mjpo80.fsf@mina86.com>
MIME-Version: 1.0
Content-Type: multipart/mixed; boundary="=-=-="
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

--=-=-=
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: quoted-printable

> On Thu, Dec 20, 2012 at 04:49:44PM +0100, Michal Nazarewicz wrote:
>> Perhaps =E2=80=9Cis_migrate_isolate=E2=80=9D to match already existing =
=E2=80=9Cis_migrate_cma=E2=80=9D?

On Fri, Dec 21 2012, Minchan Kim wrote:
> Good poking. In fact, while I made this patch, I was very tempted by rena=
ming
> is_migrate_cma to cma_pageblock.
>
>         is_migrate_cma(mt)
>
> I don't know who start to use "mt" instead of "migratetype" but anyway, i=
t's
> not a good idea.
>
>         is_migrate_cma(migratetype)
>
> It's very clear for me because migratetype is per pageblock, we can know =
the
> function works per pageblock unit.
>
>> Especially as the =E2=80=9Cmt_isolated_pageblock=E2=80=9D sound confusin=
g to me, it
>> implies that it works on pageblocks which it does not.
>
> -ENOPARSE.
>
> migratetype works on pageblock.

migratetype is a number, which can be assigned to a pageblock.  In some
transitional cases, the migratetype associated with a page can differ
from the migratetype associated with the pageblock the page is in.  As
such, I think it's confusing to add =E2=80=9Cpageblock=E2=80=9D to the name=
 of the
function which does not read migratetype from pageblock but rather
operates on the number it is provided.

> I admit mt is really dirty but I used page_alloc.c already has lots of
> mt, SIGH.

I don't really have an issue with =E2=80=9Cmt=E2=80=9D myself, especially s=
ince the few
times =E2=80=9Cmt=E2=80=9D is used in page_alloc.c it is a local variable w=
hich I don't
think needs a long descriptive name since context is all there.

> How about this?
>
> 1. Let's change all "mt" with "migratetype" again.
> 2. use is_migrate_isolate and is_migrate_cma for "migratetype".
> 3. use is_migrate_isolate_page instead of page_isolated_pageblock for
>    "page".

Like I've said.  Personally I don't really think 1 is needed, but 2 and
3 look good to me.

--=20
Best regards,                                         _     _
.o. | Liege of Serenely Enlightened Majesty of      o' \,=3D./ `o
..o | Computer Science,  Micha=C5=82 =E2=80=9Cmina86=E2=80=9D Nazarewicz   =
 (o o)
ooo +----<email/xmpp: mpn@google.com>--------------ooO--(_)--Ooo--
--=-=-=
Content-Type: multipart/signed; boundary="==-=-=";
	micalg=pgp-sha1; protocol="application/pgp-signature"

--==-=-=
Content-Type: text/plain


--==-=-=
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.11 (GNU/Linux)

iQIcBAEBAgAGBQJQ1FofAAoJECBgQBJQdR/0jiIP/jrryaTKAjAoBj4jyX7qtFXi
utw9C5umaqLKIQOmErQSAwHdIbyrwnqPnITXKvOjV2oLUTScJ4idlbVWvxogvCub
BSlVyw3/IARt14F2NEN8PkTib4EJNAOHPDIirVn/UId10Dy4u4iPKE4KXkNqtAEE
juM+s8GMt4gFsZ25b3QbvBFlsn4PNKap629KLZ1J3yvdq+Gp1ldWJKnZyKHtsIsy
UkzurFKX+qJYK8dUoDaFnkgcMInaZFhf7GRe9L6FIdRcUECBoDdzX6cnCJnn+ru8
XBBczIv0N/WXhw4NA7uTX+Jn8dSY0LDjYiKoDjdaDgG4SFtS5FspexCMCH2uVnIl
bEOqj+9K9tiCgfvcc4d0xV7IFFvu+6UnDuA9/ktKhX+zSGcjOwJAT5v/b2scuR5d
PalqlvS8PTVByjhjm1g33e4EMyBu6wBe3QrGav0/8qcWkEuf73lWtOF4Rok9yy/s
+/SvO4FljTKRpqNu2eJMHh6Qhw3YQDAI4lnvCgAohwPadUxrA8T36gbseEXdzv1Z
NQP/ipgNkEM0MrZAMtIpqq5jczeJTClzY1XoE4d3+iOwmbRoEpVeqbMRj5rixkIA
BgA384AjldkI+Esbsn+G6IXhu9XSM7SPfFBssPXYPa2GsHOBQ1V0zBWJ2+lrvRoI
1SMUcvpOSsuttlRbrjlA
=h6PU
-----END PGP SIGNATURE-----
--==-=-=--

--=-=-=--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
