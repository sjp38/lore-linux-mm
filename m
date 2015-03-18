Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f179.google.com (mail-wi0-f179.google.com [209.85.212.179])
	by kanga.kvack.org (Postfix) with ESMTP id 5644B6B0038
	for <linux-mm@kvack.org>; Wed, 18 Mar 2015 17:38:35 -0400 (EDT)
Received: by wibdy8 with SMTP id dy8so101510430wib.0
        for <linux-mm@kvack.org>; Wed, 18 Mar 2015 14:38:35 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id a6si31113538wjy.131.2015.03.18.14.38.33
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Wed, 18 Mar 2015 14:38:33 -0700 (PDT)
Date: Thu, 19 Mar 2015 08:38:35 +1100
From: NeilBrown <neilb@suse.de>
Subject: Re: [PATCH] mm: Use GFP_KERNEL allocation for the page cache in
 page_cache_read
Message-ID: <20150319083835.2115ba11@notabene.brown>
In-Reply-To: <20150318154540.GN17241@dhcp22.suse.cz>
References: <1426687766-518-1-git-send-email-mhocko@suse.cz>
	<20150318154540.GN17241@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
 boundary="Sig_/1X99F=CxQqkz7Vl=FyGDiO5"; protocol="application/pgp-signature"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>
Cc: Andrew Morton <akpm@linux-foundation.org>, Al Viro <viro@zeniv.linux.org.uk>, Johannes Weiner <hannes@cmpxchg.org>, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, Sage Weil <sage@inktank.com>, Mark Fasheh <mfasheh@suse.com>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>

--Sig_/1X99F=CxQqkz7Vl=FyGDiO5
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: quoted-printable

On Wed, 18 Mar 2015 16:45:40 +0100 Michal Hocko <mhocko@suse.cz> wrote:

> What do you think about this v2? I cannot say I would like it but I
> really dislike the whole mapping_gfp_mask API to be honest.
> ---
> >From d88010d6f5f59d7eb87b691e27e201d12cab9141 Mon Sep 17 00:00:00 2001
> From: Michal Hocko <mhocko@suse.cz>
> Date: Wed, 18 Mar 2015 16:06:40 +0100
> Subject: [PATCH] mm: Allow __GFP_FS for page_cache_read page cache alloca=
tion
>=20
> page_cache_read has been historically using page_cache_alloc_cold to
> allocate a new page. This means that mapping_gfp_mask is used as the
> base for the gfp_mask. Many filesystems are setting this mask to
> GFP_NOFS to prevent from fs recursion issues. page_cache_read is,
> however, not called from the fs layer so it doesn't need this
> protection. Even ceph and ocfs2 which call filemap_fault from their
> fault handlers seem to be OK because they are not taking any fs lock
> before invoking generic implementation.
>=20
> The protection might be even harmful. There is a strong push to fail
> GFP_NOFS allocations rather than loop within allocator indefinitely with
> a very limited reclaim ability. Once we start failing those requests
> the OOM killer might be triggered prematurely because the page cache
> allocation failure is propagated up the page fault path and end up in
> pagefault_out_of_memory.
>=20
> Add __GFP_FS and __GFPIO to the gfp mask which is coming from the
> mapping to fix this issue.
>=20
> Reported-by: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
> Signed-off-by: Michal Hocko <mhocko@suse.cz>
> ---
>  mm/filemap.c | 10 +++++++++-
>  1 file changed, 9 insertions(+), 1 deletion(-)
>=20
> diff --git a/mm/filemap.c b/mm/filemap.c
> index 968cd8e03d2e..8b50d5eb52b2 100644
> --- a/mm/filemap.c
> +++ b/mm/filemap.c
> @@ -1752,7 +1752,15 @@ static int page_cache_read(struct file *file, pgof=
f_t offset)
>  	int ret;
> =20
>  	do {
> -		page =3D page_cache_alloc_cold(mapping);
> +		gfp_t page_cache_gfp =3D mapping_gfp_mask(mapping)|__GFP_COLD;
> +
> +		/*
> +		 * This code is not called from the fs layer so we do not need
> +		 * reclaim recursion protection. !GFP_FS might fail too easy
> +		 * and trigger OOM killer prematuraly.
> +		 */
> +		page_cache_gfp |=3D __GFP_FS | __GFP_IO;
> +		page =3D __page_cache_alloc(page_cache_gfp);
>  		if (!page)
>  			return -ENOMEM;
> =20

Nearly half the places in the kernel which call mapping_gfp_mask() remove t=
he
__GFP_FS bit.

That suggests to me that it might make sense to have
   mapping_gfp_mask_fs()
and
   mapping_gfp_mask_nofs()

and let the presence of __GFP_FS (and __GFP_IO) be determined by the
call-site rather than the filesystem.

However I am a bit concerned about drivers/block/loop.c.
Might a filesystem read on the loop block device wait for a page_cache_read=
()
on the loop-mounted file?  In that case you really don't want __GFP_FS set
when allocating that page.

NeilBrown

--Sig_/1X99F=CxQqkz7Vl=FyGDiO5
Content-Type: application/pgp-signature
Content-Description: OpenPGP digital signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQIVAwUBVQnwWznsnt1WYoG5AQKsqhAAsn5v7qH5uB4x6Nwrg5IF122R0DvhfZ4a
Y6bFLghZkX9DuraqIY2NkCCIew5V0zELMf2VTP4t0dz1ZQPcAoKD2THRfW2f4iTE
yfyMH2nYdwJ6YQUP7fowOGmZJMCWMgQLbVkGNe63k4EjTJUMh/nbzicWHQWw5HKQ
gPmgiJScAkavJ8p9mTFkZ/T3po/3H5eATASkqgJMQMQvQp6MXYsnNtC1RXwJ8BBt
FxNfuGJKaU4n1H83GP5qHeOykBz7Fh1QHPXcUTtboKBoTWqAGWEf7dbmWvJz7/41
d8FHRFY3xKJzOpMq/U1nH8zcDV8D5B4fI/UQEmPyi7NlorOAPH69hTORK0npc+cI
LGvOB20guDOyu54M81xrit388M0p1JhNYzUKG6dLOs1+s+oLfIkbB3aukJRjiCI/
qQ3G+T0/UauYBYWxtU6y9IkTbM/nrz1yFfQJIHAhw4NdFMqfb03A1TOgrFQDmUUI
+VtdqOR5vbAY1/oOID9z6iqYZFAZZCRJw4+9WrVas9DPt4S7z8QXUA0itlteEuVy
rOfxMuKWXX6JhWQ6NVGSpY7TDZY1cxywdpCtFveHLC2p2C/zDLJ6El64K46OeeS2
C4Via+Vu8Na4+uOHhb/VtLjgR8qB5b6qST5zD7/5KAx4i3FrCA0kK9gVJpi68tAZ
pMEHvIk6G7g=
=Ts/v
-----END PGP SIGNATURE-----

--Sig_/1X99F=CxQqkz7Vl=FyGDiO5--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
