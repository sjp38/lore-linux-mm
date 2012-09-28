Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx202.postini.com [74.125.245.202])
	by kanga.kvack.org (Postfix) with SMTP id 720846B0068
	for <linux-mm@kvack.org>; Fri, 28 Sep 2012 06:51:22 -0400 (EDT)
Date: Fri, 28 Sep 2012 12:51:13 +0200
From: Thierry Reding <thierry.reding@avionic-design.de>
Subject: Re: CMA broken in next-20120926
Message-ID: <20120928105113.GA18883@avionic-0098.mockup.avionic-design.de>
References: <20120927112911.GA25959@avionic-0098.mockup.avionic-design.de>
 <20120927151159.4427fc8f.akpm@linux-foundation.org>
 <20120928054330.GA27594@bbox>
 <20120928083722.GM3429@suse.de>
 <50656459.70309@ti.com>
 <20120928102728.GN3429@suse.de>
 <20120928103207.GA22811@avionic-0098.mockup.avionic-design.de>
 <20120928103815.GA15219@avionic-0098.mockup.avionic-design.de>
MIME-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="T4sUOijqQbZv57TR"
Content-Disposition: inline
In-Reply-To: <20120928103815.GA15219@avionic-0098.mockup.avionic-design.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: Peter Ujfalusi <peter.ujfalusi@ti.com>, Minchan Kim <minchan@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Marek Szyprowski <m.szyprowski@samsung.com>, Michal Nazarewicz <mina86@mina86.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Bartlomiej Zolnierkiewicz <b.zolnierkie@samsung.com>, Kyungmin Park <kyungmin.park@samsung.com>, Mark Brown <broonie@opensource.wolfsonmicro.com>


--T4sUOijqQbZv57TR
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Fri, Sep 28, 2012 at 12:38:15PM +0200, Thierry Reding wrote:
> On Fri, Sep 28, 2012 at 12:32:07PM +0200, Thierry Reding wrote:
> > On Fri, Sep 28, 2012 at 11:27:28AM +0100, Mel Gorman wrote:
> > > On Fri, Sep 28, 2012 at 11:48:25AM +0300, Peter Ujfalusi wrote:
> > > > Hi,
> > > >=20
> > > > On 09/28/2012 11:37 AM, Mel Gorman wrote:
> > > > >> I hope this patch fixes the bug. If this patch fixes the problem
> > > > >> but has some problem about description or someone has better ide=
a,
> > > > >> feel free to modify and resend to akpm, Please.
> > > > >>
> > > > >=20
> > > > > A full revert is overkill. Can the following patch be tested as a
> > > > > potential replacement please?
> > > > >=20
> > > > > ---8<---
> > > > > mm: compaction: Iron out isolate_freepages_block() and isolate_fr=
eepages_range() -fix1
> > > > >=20
> > > > > CMA is reported to be broken in next-20120926. Minchan Kim pointe=
d out
> > > > > that this was due to nr_scanned !=3D total_isolated in the case o=
f CMA
> > > > > because PageBuddy pages are one scan but many isolations in CMA. =
This
> > > > > patch should address the problem.
> > > > >=20
> > > > > This patch is a fix for
> > > > > mm-compaction-acquire-the-zone-lock-as-late-as-possible-fix-2.pat=
ch
> > > > >=20
> > > > > Signed-off-by: Mel Gorman <mgorman@suse.de>
> > > >=20
> > > > linux-next + this patch alone also works for me.
> > > >=20
> > > > Tested-by: Peter Ujfalusi <peter.ujfalusi@ti.com>
> > >=20
> > > Thanks Peter. I expect it also works for Thierry as I expect you were
> > > suffering the same problem but obviously confirmation of that would b=
e nice.
> >=20
> > I've been running a few tests and indeed this solves the obvious problem
> > that the coherent pool cannot be created at boot (which in turn caused
> > the ethernet adapter to fail on Tegra).
> >=20
> > However I've been working on the Tegra DRM driver, which uses CMA to
> > allocate large chunks of framebuffer memory and these are now failing.
> > I'll need to check if Minchan's patch solves that problem as well.
>=20
> Indeed, with Minchan's patch the DRM can allocate the framebuffer
> without a problem. Something else must be wrong then.

However, depending on the size of the allocation it also happens with
Minchan's patch. What I see is this:

[   60.736729] alloc_contig_range test_pages_isolated(1e900, 1f0e9) failed
[   60.743572] alloc_contig_range test_pages_isolated(1ea00, 1f1e9) failed
[   60.750424] alloc_contig_range test_pages_isolated(1ea00, 1f2e9) failed
[   60.757239] alloc_contig_range test_pages_isolated(1ec00, 1f3e9) failed
[   60.764066] alloc_contig_range test_pages_isolated(1ec00, 1f4e9) failed
[   60.770893] alloc_contig_range test_pages_isolated(1ec00, 1f5e9) failed
[   60.777698] alloc_contig_range test_pages_isolated(1ec00, 1f6e9) failed
[   60.784526] alloc_contig_range test_pages_isolated(1f000, 1f7e9) failed
[   60.791148] drm tegra: Failed to alloc buffer: 8294400

I'm pretty sure this did work before next-20120926.

Thierry

--T4sUOijqQbZv57TR
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.19 (GNU/Linux)

iQIcBAEBAgAGBQJQZYEhAAoJEN0jrNd/PrOhkioP/idDx/MA9xrd9IkshuS06B7c
3mW7ZrZmHdVxQjTGzINoqwyh/rzvGBEATB+DMG2BHTfaASHWzDrVflutLeHB9z2C
bqF0tBO2ori8IXmCl3QMYwEzFfSn5afv9lD4sPwzsHVWFQslhtgeFXuPAvNONiCc
4G4OixoEMRQ1SqHKn4aJPrhLxV8/yBg6vnmZgqFJNRrKibYGi1uq1ktPEO3KSC40
nKykMb+U9ZQJkTK3JlTkrevLjypozxFrr/IFVihufDPzHKN/ynTdnXDxROmFlXri
grHFPvY+7oQcwDTompJblVcyKg27wXLlmkXYiw4MuM+ENLRhsiwV3gZUu2KRckQS
NhLSI6jDdOgO2Ax+zgV/glakeOtnmDWSMNqZYChZT2aOpRxUzFmdheRiaUEdUpCJ
T+5TbpSER2zKlkjSGgWbAt6xmoLYDOaBAAg40jNyfYsL0fg5k2dSsya20skEpVTz
DgNWo9e4TDkDaSZkkzVYoXYX0+fZL/1+bKIwfoi/QrX2wzRHKqwYk+Cl/c1t18Nz
L0/4eimBxPyVnd19QzykSaejvQesOg3HBcmzHijoRxoQvTUDNIoxazvrlz76T5SA
qdPSvev47NoZ1vlPd8PdVns8TcmeuEuk0apDIIzBzCsLwiNuMfE/1r1zXvwjwPSc
8IYrDaDk9arP2GjIgLaG
=PCVb
-----END PGP SIGNATURE-----

--T4sUOijqQbZv57TR--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
