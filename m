Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f70.google.com (mail-pg0-f70.google.com [74.125.83.70])
	by kanga.kvack.org (Postfix) with ESMTP id E7D3E6B0292
	for <linux-mm@kvack.org>; Sat, 24 Jun 2017 09:26:20 -0400 (EDT)
Received: by mail-pg0-f70.google.com with SMTP id u36so68748077pgn.5
        for <linux-mm@kvack.org>; Sat, 24 Jun 2017 06:26:20 -0700 (PDT)
Received: from mail-pf0-x243.google.com (mail-pf0-x243.google.com. [2607:f8b0:400e:c00::243])
        by mx.google.com with ESMTPS id f8si5883977pln.560.2017.06.24.06.26.20
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 24 Jun 2017 06:26:20 -0700 (PDT)
Received: by mail-pf0-x243.google.com with SMTP id s66so11393711pfs.2
        for <linux-mm@kvack.org>; Sat, 24 Jun 2017 06:26:20 -0700 (PDT)
Date: Sat, 24 Jun 2017 21:26:14 +0800
From: Wei Yang <richard.weiyang@gmail.com>
Subject: Re: [PATCH] mm/page_alloc.c: eliminate unsigned confusion in
 __rmqueue_fallback
Message-ID: <20170624132440.GA40323@WeideMacBook-Pro.local>
Reply-To: Wei Yang <richard.weiyang@gmail.com>
References: <20170621094344.GC22051@dhcp22.suse.cz>
 <20170621185529.2265-1-linux@rasmusvillemoes.dk>
MIME-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha256;
	protocol="application/pgp-signature"; boundary="1LKvkjL3sHcu1TtY"
Content-Disposition: inline
In-Reply-To: <20170621185529.2265-1-linux@rasmusvillemoes.dk>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Rasmus Villemoes <linux@rasmusvillemoes.dk>
Cc: Michal Hocko <mhocko@suse.com>, Andrew Morton <akpm@linux-foundation.org>, Vlastimil Babka <vbabka@suse.cz>, Hillf Danton <hillf.zj@alibaba-inc.com>, Johannes Weiner <hannes@cmpxchg.org>, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, Vinayak Menon <vinmenon@codeaurora.org>, Xishi Qiu <qiuxishi@huawei.com>, Hao Lee <haolee.swjtu@gmail.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org


--1LKvkjL3sHcu1TtY
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Wed, Jun 21, 2017 at 08:55:28PM +0200, Rasmus Villemoes wrote:
>Since current_order starts as MAX_ORDER-1 and is then only
>decremented, the second half of the loop condition seems
>superfluous. However, if order is 0, we may decrement current_order
>past 0, making it UINT_MAX. This is obviously too subtle ([1], [2]).
>
>Since we need to add some comment anyway, change the two variables to
>signed, making the counting-down for loop look more familiar, and
>apparently also making gcc generate slightly smaller code.
>
>[1] https://lkml.org/lkml/2016/6/20/493
>[2] https://lkml.org/lkml/2017/6/19/345
>
>Signed-off-by: Rasmus Villemoes <linux@rasmusvillemoes.dk>
>---
>Michal, something like this, perhaps?
>
>mm/page_alloc.c | 10 +++++++---
> 1 file changed, 7 insertions(+), 3 deletions(-)
>
>diff --git a/mm/page_alloc.c b/mm/page_alloc.c
>index 2302f250d6b1..e656f4da9772 100644
>--- a/mm/page_alloc.c
>+++ b/mm/page_alloc.c
>@@ -2204,19 +2204,23 @@ static bool unreserve_highatomic_pageblock(const s=
truct alloc_context *ac,
>  * list of requested migratetype, possibly along with other pages from th=
e same
>  * block, depending on fragmentation avoidance heuristics. Returns true if
>  * fallback was found so that __rmqueue_smallest() can grab it.
>+ *
>+ * The use of signed ints for order and current_order is a deliberate
>+ * deviation from the rest of this file, to make the for loop
>+ * condition simpler.
>  */
> static inline bool
>-__rmqueue_fallback(struct zone *zone, unsigned int order, int start_migra=
tetype)
>+__rmqueue_fallback(struct zone *zone, int order, int start_migratetype)
> {
> 	struct free_area *area;
>-	unsigned int current_order;
>+	int current_order;
> 	struct page *page;
> 	int fallback_mt;
> 	bool can_steal;
>=20
> 	/* Find the largest possible block of pages in the other list */
> 	for (current_order =3D MAX_ORDER-1;
>-				current_order >=3D order && current_order <=3D MAX_ORDER-1;
>+				current_order >=3D order;
> 				--current_order) {
> 		area =3D &(zone->free_area[current_order]);
> 		fallback_mt =3D find_suitable_fallback(area, current_order,
>--=20
>2.11.0

Looks nice. Why I didn't come up with this change.

Acked-by: Wei Yang <weiyang@gmail.com>

--=20
Wei Yang
Help you, Help me

--1LKvkjL3sHcu1TtY
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQIcBAEBCAAGBQJZTmh2AAoJEKcLNpZP5cTd/+gP/iWLJ7ShsIdTwi75GSS8hBoc
tNTwyFOPSZgc1HkLsEimPp/fYQwbv95eT9d8WHxV95fhgvDyqIRsVLwFkKzxhe3J
fkXySx7zer5CxVLluoewrEkKwM3rLRaEiyomAu4dV5IzXnaGp/oDb1jgU0ynl1QQ
6TP1sipFatoUCeWra6AeEQrwnfMrC2H4p44lOwNOw8e0kKLvksz+Ckg3Uihmbl+a
qG88nZ26U9G1ggVR04MRLMZMifmv2lO2HdzvnHlBdbCTT71h0T5QUUzOB7K0g/sF
JLC36Imx4Xz5TksddZPxW91Lqun1bUftrHoaBN+KiBHrWpKEWvJp/5/j8anO/3/a
XHTMEEcx5mARAXek4d2F071bkgVGkn9KHZc4xgPXSZRseaKnlFSe0KsXqTM8116W
AXCI1KJ5uiQ9U2NIjcs8cSQWC5xiyHTnr2uQh3mbibN6Tzt33ZxuyNzBniia57EV
X2jj2nZRTJS8H8bscG6+6f7m0g/mJ2B7OGQHGx6jTo309HlG9VCzdvrt8e9AxLP2
05GN2N1ngBao2X2ph6YbnBLbim1QuX1OdLfioljR+scMTInB2pg/Tw8PGUfzWlEl
nsXtU6AHpBl4b5ez1GTB5hcA7qLX4aD9gUjN9/EY8JbxQJEX/+cdBUeF2dto6j9c
JfrCDoQNnJFSHJCHXOaE
=5FEK
-----END PGP SIGNATURE-----

--1LKvkjL3sHcu1TtY--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
