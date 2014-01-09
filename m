Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f176.google.com (mail-wi0-f176.google.com [209.85.212.176])
	by kanga.kvack.org (Postfix) with ESMTP id B993D6B0031
	for <linux-mm@kvack.org>; Thu,  9 Jan 2014 04:22:11 -0500 (EST)
Received: by mail-wi0-f176.google.com with SMTP id hq4so6637193wib.15
        for <linux-mm@kvack.org>; Thu, 09 Jan 2014 01:22:11 -0800 (PST)
Received: from mail-we0-x22f.google.com (mail-we0-x22f.google.com [2a00:1450:400c:c03::22f])
        by mx.google.com with ESMTPS id ui5si930482wjc.22.2014.01.09.01.22.11
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Thu, 09 Jan 2014 01:22:11 -0800 (PST)
Received: by mail-we0-f175.google.com with SMTP id w62so2464666wes.6
        for <linux-mm@kvack.org>; Thu, 09 Jan 2014 01:22:11 -0800 (PST)
From: Michal Nazarewicz <mina86@mina86.com>
Subject: Re: [PATCH 7/7] mm/page_alloc: don't merge MIGRATE_(CMA|ISOLATE) pages on buddy
In-Reply-To: <1389251087-10224-8-git-send-email-iamjoonsoo.kim@lge.com>
References: <1389251087-10224-1-git-send-email-iamjoonsoo.kim@lge.com> <1389251087-10224-8-git-send-email-iamjoonsoo.kim@lge.com>
Date: Thu, 09 Jan 2014 10:22:02 +0100
Message-ID: <xa1t61ptbjd1.fsf@mina86.com>
MIME-Version: 1.0
Content-Type: multipart/mixed; boundary="=-=-="
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joonsoo Kim <iamjoonsoo.kim@lge.com>, Andrew Morton <akpm@linux-foundation.org>
Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Rik van Riel <riel@redhat.com>, Jiang Liu <jiang.liu@huawei.com>, Mel Gorman <mgorman@suse.de>, Cody P Schafer <cody@linux.vnet.ibm.com>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>, Minchan Kim <minchan@kernel.org>, Andi Kleen <ak@linux.intel.com>, Wei Yongjun <yongjun_wei@trendmicro.com.cn>, Tang Chen <tangchen@cn.fujitsu.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Joonsoo Kim <js1304@gmail.com>

--=-=-=
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: quoted-printable

On Thu, Jan 09 2014, Joonsoo Kim wrote:
> If (MAX_ORDER-1) is greater than pageblock order, there is a possibility
> to merge different migratetype pages and to be linked in unintended
> freelist.
>
> While I test CMA, CMA pages are merged and linked into MOVABLE freelist
> by above issue and then, the pages change their migratetype to UNMOVABLE =
by
> try_to_steal_freepages(). After that, CMA to this region always fail.
>
> To prevent this, we should not merge the page on MIGRATE_(CMA|ISOLATE)
> freelist.

This is strange.  CMA regions are always multiplies of max-pages (or
pageblocks whichever is larger), so MOVABLE free pages should never be
inside of a CMA region.

If what you're describing happens, it looks like an issue somewhere
else.

> Signed-off-by: Joonsoo Kim <iamjoonsoo.kim@lge.com>
>
> diff --git a/mm/page_alloc.c b/mm/page_alloc.c
> index 2548b42..ea99cee 100644
> --- a/mm/page_alloc.c
> +++ b/mm/page_alloc.c
> @@ -581,6 +581,15 @@ static inline void __free_one_page(struct page *page,
>  			__mod_zone_freepage_state(zone, 1 << order,
>  						  migratetype);
>  		} else {
> +			int buddy_mt =3D get_buddy_migratetype(buddy);
> +
> +			/* We don't want to merge cma, isolate pages */
> +			if (unlikely(order >=3D pageblock_order) &&
> +				migratetype !=3D buddy_mt &&
> +				(migratetype >=3D MIGRATE_PCPTYPES ||
> +				buddy_mt >=3D MIGRATE_PCPTYPES)) {
> +				break;
> +			}
>  			list_del(&buddy->lru);
>  			zone->free_area[order].nr_free--;
>  			rmv_page_order(buddy);
> --=20
> 1.7.9.5
>

--=20
Best regards,                                         _     _
.o. | Liege of Serenely Enlightened Majesty of      o' \,=3D./ `o
..o | Computer Science,  Micha=C5=82 =E2=80=9Cmina86=E2=80=9D Nazarewicz   =
 (o o)
ooo +--<mpn@google.com>--<xmpp:mina86@jabber.org>--ooO--(_)--Ooo--

--=-=-=
Content-Type: multipart/signed; boundary="==-=-=";
	micalg=pgp-sha1; protocol="application/pgp-signature"

--==-=-=
Content-Type: text/plain


--==-=-=
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.11 (GNU/Linux)

iQIcBAEBAgAGBQJSzmo6AAoJECBgQBJQdR/0hXcP+gNcSKtRGUP6Z1/0L4u+rMIp
oJqXjZ1M6kSzqPYeTEZhHqJLOMLYJfEmDAzUkP3xeVvnqv0HatHjcn5JDklkv9PT
gOQ1sflANnIwIw930rVLQQM5s0QhR4gic+CnJ7Sc9YPadopn1l+JQHy/93ylXruU
/+g23QCFS+uQoQZ6HqhJS2AXXworLMTi9IA/YA1PuMXLDpnlhLFh9tkeJeWIR+rX
Frr7U35NeZtWyKbHSZttULJGFAtscD0mdHP79Bnqzosyqi92HyjSoIjzOCe4ptkM
FMie0i9Rx/NiRVRNOzQrsI7ryr1RR/lXhbcmTYyvMfxBuzbXW3/r1gQEIuJvDpJ/
Us9zl2ayWpFvjgBE9m/4vawZO/+PGVsv74iVcL60KgEuftAPyYHqkYeAf8cI8WOh
CgKpR6oyUOFp81kX0GeEJ2b5JJh+lOzmufg4Ow1eLgQWpBY/u02hQ/sLyEpHgqiu
ZfgYBNP5horayy6VqIrnw1/oIBg2CUp31RQtJ5sB+AaGHTtd7cw1X8PblLWRJvsn
ErdJKRJV1fe/bnwD3EEt5iI8Y9oCOB6mTI5pHWhdIunBEG0//J8qYpqk+U9jfB6Q
BsLwO55NOyC5MzRmaXLcLGmmn+ENfPDrcugtmwqOK1SNKK2NOKN6Q0cGuu0Sa+8Z
2fcUX72K8i+6h1sDR1vt
=vPh+
-----END PGP SIGNATURE-----
--==-=-=--

--=-=-=--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
