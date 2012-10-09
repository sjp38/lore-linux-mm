Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx111.postini.com [74.125.245.111])
	by kanga.kvack.org (Postfix) with SMTP id 79ECC6B002B
	for <linux-mm@kvack.org>; Tue,  9 Oct 2012 07:38:09 -0400 (EDT)
Date: Tue, 9 Oct 2012 13:38:02 +0200
From: Thierry Reding <thierry.reding@avionic-design.de>
Subject: Re: CMA broken in next-20120926
Message-ID: <20121009113802.GA19276@avionic-0098.mockup.avionic-design.de>
References: <20120928105113.GA18883@avionic-0098.mockup.avionic-design.de>
 <201210091040.10811.b.zolnierkie@samsung.com>
 <20121009101143.GQ29125@suse.de>
 <201210091308.30306.b.zolnierkie@samsung.com>
MIME-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="k1lZvvs/B4yU6o8G"
Content-Disposition: inline
In-Reply-To: <201210091308.30306.b.zolnierkie@samsung.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Bartlomiej Zolnierkiewicz <b.zolnierkie@samsung.com>
Cc: Mel Gorman <mgorman@suse.de>, Minchan Kim <minchan@kernel.org>, Peter Ujfalusi <peter.ujfalusi@ti.com>, Andrew Morton <akpm@linux-foundation.org>, Marek Szyprowski <m.szyprowski@samsung.com>, Michal Nazarewicz <mina86@mina86.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Kyungmin Park <kyungmin.park@samsung.com>, Mark Brown <broonie@opensource.wolfsonmicro.com>


--k1lZvvs/B4yU6o8G
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Tue, Oct 09, 2012 at 01:08:30PM +0200, Bartlomiej Zolnierkiewicz wrote:
> On Tuesday 09 October 2012 12:11:43 Mel Gorman wrote:
> > On Tue, Oct 09, 2012 at 10:40:10AM +0200, Bartlomiej Zolnierkiewicz wro=
te:
> > > I also need following patch to make CONFIG_CMA=3Dy && CONFIG_COMPACTI=
ON=3Dy case
> > > work:
> > >=20
> > > From: Bartlomiej Zolnierkiewicz <b.zolnierkie@samsung.com>
> > > Subject: [PATCH] mm: compaction: cache if a pageblock was scanned and=
 no pages were isolated - cma fix
> > >=20
> > > Patch "mm: compaction: cache if a pageblock was scanned and no pages
> > > were isolated" needs a following fix to successfully boot next-201210=
02
> > > kernel (same with next-20121008) with CONFIG_CMA=3Dy and CONFIG_COMPA=
CTION=3Dy
> > > (with applied -fix1, -fix2, -fix3 patches from Mel Gorman and also wi=
th
> > > cmatest module from Thierry Reding compiled in).
> > >=20
> >=20
> > Why is it needed to make it boot? CMA should not care about the
>=20
> It boots without Thierry's cmatest module but then fails on CMA
> allocation attempt (I used out-of-tree /dev/cma_test interface to
> generate CMA allocation request from user-space).
>=20
> > PG_migrate_skip hint being set because it should always ignore it in
> > alloc_contig_range() due to cc->ignore_skip_hint. It's not obvious to
> > me why this fixes a boot failure and I wonder if it's papering over some
> > underlying problem. Can you provide more details please?
>=20
> I just compared CONFIG_COMPACTION=3Dn and =3Dy cases initially, figured
> out the difference and did the change.  However on a closer look it
> seems that {get,clear,set}_pageblock_skip() use incorrect bit ranges
> (please compare to bit ranges used by {get,set}_pageblock_flags()
> used for migration types) and can overwrite pageblock migratetype of
> the next pageblock in the bitmap (I wonder how could this code ever
> worked before?).
>=20
> > > Signed-off-by: Bartlomiej Zolnierkiewicz <b.zolnierkie@samsung.com>
> > > Signed-off-by: Kyungmin Park <kyungmin.park@samsung.com>
> > > ---
> > >  mm/compaction.c |    3 ++-
> > >  1 file changed, 2 insertions(+), 1 deletion(-)
> > >=20
> > > Index: b/mm/compaction.c
> > > =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
> > > --- a/mm/compaction.c	2012-10-08 18:10:53.491679716 +0200
> > > +++ b/mm/compaction.c	2012-10-08 18:11:33.615679713 +0200
> > > @@ -117,7 +117,8 @@ static void update_pageblock_skip(struct
> > >  			bool migrate_scanner)
> > >  {
> > >  	struct zone *zone =3D cc->zone;
> > > -	if (!page)
> > > +
> > > +	if (!page || cc->ignore_skip_hint)
> > >  		return;
> > > =20
> > >  	if (!nr_isolated) {
>=20
> The patch below also fixes the issue for me:
>=20
> From: Bartlomiej Zolnierkiewicz <b.zolnierkie@samsung.com>
> Subject: [PATCH] mm: compaction: fix bit ranges in {get,clear,set}_pagebl=
ock_skip()=20
>=20
> {get,clear,set}_pageblock_skip() use incorrect bit ranges (please compare
> to bit ranges used by {get,set}_pageblock_flags() used for migration type=
s)
> and can overwrite pageblock migratetype of the next pageblock in the bitm=
ap.
>=20
> Signed-off-by: Bartlomiej Zolnierkiewicz <b.zolnierkie@samsung.com>
> Signed-off-by: Kyungmin Park <kyungmin.park@samsung.com>
> ---
>  include/linux/pageblock-flags.h |    6 +++---
>  1 file changed, 3 insertions(+), 3 deletions(-)
>=20
> Index: b/include/linux/pageblock-flags.h
> =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
> --- a/include/linux/pageblock-flags.h	2012-10-09 12:50:20.366340001 +0200
> +++ b/include/linux/pageblock-flags.h	2012-10-09 12:50:31.794339996 +0200
> @@ -71,13 +71,13 @@ void set_pageblock_flags_group(struct pa
>  #ifdef CONFIG_COMPACTION
>  #define get_pageblock_skip(page) \
>  			get_pageblock_flags_group(page, PB_migrate_skip,     \
> -							PB_migrate_skip + 1)
> +							PB_migrate_skip)
>  #define clear_pageblock_skip(page) \
>  			set_pageblock_flags_group(page, 0, PB_migrate_skip,  \
> -							PB_migrate_skip + 1)
> +							PB_migrate_skip)
>  #define set_pageblock_skip(page) \
>  			set_pageblock_flags_group(page, 1, PB_migrate_skip,  \
> -							PB_migrate_skip + 1)
> +							PB_migrate_skip)
>  #endif /* CONFIG_COMPACTION */
> =20
>  #define get_pageblock_flags(page) \

Tested-by: Thierry Reding <thierry.reding@avionic-design.de>

--k1lZvvs/B4yU6o8G
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.19 (GNU/Linux)

iQIcBAEBAgAGBQJQdAyaAAoJEN0jrNd/PrOhEJkQAKVrFdPL5XHZMLnmOjpnw6jm
mxWr2Y14UholY2xjRsGjK5Ghh59u2861arfC/isFD4ut1L1eWFTae2H265Fr/Rlo
xtFUdjUoddqPMVvgiavqfCb81nADehCDnt0vmh0u8eF7N8wASVoGbA8X6GhlLhj5
zYJk1tKwXkcY5qaOxcrGE/b8jWKUrcMlSN+j8+s2N47ivD6zBfyTs+6dwjmhdBMU
ofWTVW7rtP7c5F8h/2Wl6PlFyTN7C2rTP3WzCcZNEwHpNMxCRoEOvkWvMOoGaBOj
JbMA44HVo4gC/NNoHCAftmjlZSBuMfvcsolTGqCC3F+bKPcexU+ZBPULl71AIZT/
NphDL8ARgIFy+IRFY/ZvLdCOu2lz5LU6V15iEiMix+85HdSn8UcvT7/BfCyyncty
3Jxv61S0NhhwDv00qs03eCw5lkNiC2ssEeVgCZs2aexcGiAsbmlt5xgI4AqBapEQ
T4whmz2YtwPv7uhEs89xklGtlqnKXvOcompkJ5FKiGbsMy2o41MGl4WXg14BTLxP
3bjjSzjzHCHkx1U87b401/2BhEcvVbBRhz9Pg1f7JdsFkWcJRX4trTvD+FBYqz30
znal0AnL6aSHYaFRhLNoy8VoeNepJzeZ0cNHZ+PQpLwKigk2a/P+EirF+pBIpmMO
3zQ65AbHIhOti5Tti/zf
=iVgo
-----END PGP SIGNATURE-----

--k1lZvvs/B4yU6o8G--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
