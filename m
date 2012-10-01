Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx148.postini.com [74.125.245.148])
	by kanga.kvack.org (Postfix) with SMTP id 101336B005D
	for <linux-mm@kvack.org>; Mon,  1 Oct 2012 10:24:56 -0400 (EDT)
Date: Mon, 1 Oct 2012 16:24:29 +0200
From: Thierry Reding <thierry.reding@avionic-design.de>
Subject: Re: CMA broken in next-20120926
Message-ID: <20121001142428.GA2798@avionic-0098.mockup.avionic-design.de>
References: <20120928054330.GA27594@bbox>
 <20120928083722.GM3429@suse.de>
 <50656459.70309@ti.com>
 <20120928102728.GN3429@suse.de>
 <20120928103207.GA22811@avionic-0098.mockup.avionic-design.de>
 <20120928103815.GA15219@avionic-0098.mockup.avionic-design.de>
 <20120928105113.GA18883@avionic-0098.mockup.avionic-design.de>
 <20120928110712.GB29125@suse.de>
 <20120928113924.GA25342@avionic-0098.mockup.avionic-design.de>
 <20120928124332.GC29125@suse.de>
MIME-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="FsscpQKzF/jJk6ya"
Content-Disposition: inline
In-Reply-To: <20120928124332.GC29125@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: Peter Ujfalusi <peter.ujfalusi@ti.com>, Minchan Kim <minchan@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Marek Szyprowski <m.szyprowski@samsung.com>, Michal Nazarewicz <mina86@mina86.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Bartlomiej Zolnierkiewicz <b.zolnierkie@samsung.com>, Kyungmin Park <kyungmin.park@samsung.com>, Mark Brown <broonie@opensource.wolfsonmicro.com>


--FsscpQKzF/jJk6ya
Content-Type: multipart/mixed; boundary="tsOsTdHNUZQcU9Ye"
Content-Disposition: inline


--tsOsTdHNUZQcU9Ye
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Fri, Sep 28, 2012 at 01:43:32PM +0100, Mel Gorman wrote:
> On Fri, Sep 28, 2012 at 01:39:24PM +0200, Thierry Reding wrote:
> > On Fri, Sep 28, 2012 at 12:07:12PM +0100, Mel Gorman wrote:
> > > On Fri, Sep 28, 2012 at 12:51:13PM +0200, Thierry Reding wrote:
> > > > On Fri, Sep 28, 2012 at 12:38:15PM +0200, Thierry Reding wrote:
> > > > > On Fri, Sep 28, 2012 at 12:32:07PM +0200, Thierry Reding wrote:
> > > > > > On Fri, Sep 28, 2012 at 11:27:28AM +0100, Mel Gorman wrote:
> > > > > > > On Fri, Sep 28, 2012 at 11:48:25AM +0300, Peter Ujfalusi wrot=
e:
> > > > > > > > Hi,
> > > > > > > >=20
> > > > > > > > On 09/28/2012 11:37 AM, Mel Gorman wrote:
> > > > > > > > >> I hope this patch fixes the bug. If this patch fixes the=
 problem
> > > > > > > > >> but has some problem about description or someone has be=
tter idea,
> > > > > > > > >> feel free to modify and resend to akpm, Please.
> > > > > > > > >>
> > > > > > > > >=20
> > > > > > > > > A full revert is overkill. Can the following patch be tes=
ted as a
> > > > > > > > > potential replacement please?
> > > > > > > > >=20
> > > > > > > > > ---8<---
> > > > > > > > > mm: compaction: Iron out isolate_freepages_block() and is=
olate_freepages_range() -fix1
> > > > > > > > >=20
> > > > > > > > > CMA is reported to be broken in next-20120926. Minchan Ki=
m pointed out
> > > > > > > > > that this was due to nr_scanned !=3D total_isolated in th=
e case of CMA
> > > > > > > > > because PageBuddy pages are one scan but many isolations =
in CMA. This
> > > > > > > > > patch should address the problem.
> > > > > > > > >=20
> > > > > > > > > This patch is a fix for
> > > > > > > > > mm-compaction-acquire-the-zone-lock-as-late-as-possible-f=
ix-2.patch
> > > > > > > > >=20
> > > > > > > > > Signed-off-by: Mel Gorman <mgorman@suse.de>
> > > > > > > >=20
> > > > > > > > linux-next + this patch alone also works for me.
> > > > > > > >=20
> > > > > > > > Tested-by: Peter Ujfalusi <peter.ujfalusi@ti.com>
> > > > > > >=20
> > > > > > > Thanks Peter. I expect it also works for Thierry as I expect =
you were
> > > > > > > suffering the same problem but obviously confirmation of that=
 would be nice.
> > > > > >=20
> > > > > > I've been running a few tests and indeed this solves the obviou=
s problem
> > > > > > that the coherent pool cannot be created at boot (which in turn=
 caused
> > > > > > the ethernet adapter to fail on Tegra).
> > > > > >=20
> > > > > > However I've been working on the Tegra DRM driver, which uses C=
MA to
> > > > > > allocate large chunks of framebuffer memory and these are now f=
ailing.
> > > > > > I'll need to check if Minchan's patch solves that problem as we=
ll.
> > > > >=20
> > > > > Indeed, with Minchan's patch the DRM can allocate the framebuffer
> > > > > without a problem. Something else must be wrong then.
> > > >=20
> > > > However, depending on the size of the allocation it also happens wi=
th
> > > > Minchan's patch. What I see is this:
> > > >=20
> > > > [   60.736729] alloc_contig_range test_pages_isolated(1e900, 1f0e9)=
 failed
> > > > [   60.743572] alloc_contig_range test_pages_isolated(1ea00, 1f1e9)=
 failed
> > > > [   60.750424] alloc_contig_range test_pages_isolated(1ea00, 1f2e9)=
 failed
> > > > [   60.757239] alloc_contig_range test_pages_isolated(1ec00, 1f3e9)=
 failed
> > > > [   60.764066] alloc_contig_range test_pages_isolated(1ec00, 1f4e9)=
 failed
> > > > [   60.770893] alloc_contig_range test_pages_isolated(1ec00, 1f5e9)=
 failed
> > > > [   60.777698] alloc_contig_range test_pages_isolated(1ec00, 1f6e9)=
 failed
> > > > [   60.784526] alloc_contig_range test_pages_isolated(1f000, 1f7e9)=
 failed
> > > > [   60.791148] drm tegra: Failed to alloc buffer: 8294400
> > > >=20
> > > > I'm pretty sure this did work before next-20120926.
> > > >=20
> > >=20
> > > Can you double check this please?
> > >=20
> > > This is a separate bug but may be related to the same series. However=
, CMA should
> > > be ignoring the "skip" hints and because it's sync compaction it shou=
ld
> > > not be exiting due to lock contention. Maybe Marek will spot it.
> >=20
> > I've written a small test module that tries to allocate growing blocks
> > of contiguous memory and it seems like with your patch this always fails
> > at 8 MiB.
>=20
> You earlier said it also happens with Minchan's but your statment here
> is less clear. Does Minchan's also fail on the 8MiB boundary? Second,
> did the test module work with next-20120926?

The cmatest module that I use tries to allocate blocks from 4 KiB to 256
MiB (in increments of powers of two). With next-20120926 this always
fails at 8 MiB, independent of the CMA size setting (though I didn't
test setting the CMA size to <=3D 8 MiB, I assumed that would make the 8
MiB allocation fail anyway). Note that I had to apply the attached patch
which fixes a build failure on next-20120926. I believe that Mark Brown
posted a similar fix a few days ago. I'm also attaching a log from the
module's test run. There's also an interesting page allocation failure
at the very end of that log which I have not seen with next-20120925.

I've run the same tests on next-20120925 with the CMA size set to 256
MiB and only the 256 MiB allocation fails. This is normal since there
are other modules that already allocate smaller buffers from CMA, so a
whole 256 MiB won't be available.

Vanilla 3.6-rc6 shows the same behaviour as next-20120925. I will try
3.6-rc7 next since that's what next-20120926 is based on. If that
succeeds I'll try to bisect between 3.6-rc7 and next-20120926 to find
the culprit, but that will probably take some more time as I need to
apply at least one other commit on top to get the board to boot at all.

So this really isn't all that new, but I just wanted to confirm my
results from last week. We'll see if bisection shows up something
interesting.

Thierry

--tsOsTdHNUZQcU9Ye
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline; filename="mm-compaction-buildfix.patch"
Content-Transfer-Encoding: quoted-printable

diff --git a/include/linux/pageblock-flags.h b/include/linux/pageblock-flag=
s.h
index eed27f4..9ed5841 100644
--- a/include/linux/pageblock-flags.h
+++ b/include/linux/pageblock-flags.h
@@ -30,7 +30,7 @@ enum pageblock_bits {
 	PB_migrate,
 	PB_migrate_end =3D PB_migrate + 3 - 1,
 			/* 3 bits required for migrate types */
-#ifdef CONFIG_COMPACTION
+#if defined(CONFIG_COMPACTION) || defined(CONFIG_CMA)
 	PB_migrate_skip,/* If set the block is skipped by compaction */
 #endif /* CONFIG_COMPACTION */
 	NR_PAGEBLOCK_BITS
@@ -68,7 +68,7 @@ unsigned long get_pageblock_flags_group(struct page *page,
 void set_pageblock_flags_group(struct page *page, unsigned long flags,
 					int start_bitidx, int end_bitidx);
=20
-#ifdef CONFIG_COMPACTION
+#if defined(CONFIG_COMPACTION) || defined(CONFIG_CMA)
 #define get_pageblock_skip(page) \
 			get_pageblock_flags_group(page, PB_migrate_skip,     \
 							PB_migrate_skip + 1)

--tsOsTdHNUZQcU9Ye
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline; filename="cmatest.log"

modprobe cmatest
[  241.358384] cma: dma_alloc_from_contiguous(cma cf473fc0, count 1, align 0)
[  241.365687] cma: dma_alloc_from_contiguous(): memory range at c08c6000 is busy, retrying
[  241.374024] cma: dma_alloc_from_contiguous(): memory range at c08c6020 is busy, retrying
[  241.382343] cma: dma_alloc_from_contiguous(): memory range at c08c6040 is busy, retrying
[  241.390630] cma: dma_alloc_from_contiguous(): memory range at c08c6060 is busy, retrying
[  241.398920] cma: dma_alloc_from_contiguous(): memory range at c08c6080 is busy, retrying
[  241.407203] cma: dma_alloc_from_contiguous(): memory range at c08c60a0 is busy, retrying
[  241.415455] cma: dma_alloc_from_contiguous(): memory range at c08c60c0 is busy, retrying
[  241.423742] cma: dma_alloc_from_contiguous(): memory range at c08c60e0 is busy, retrying
[  241.432021] cma: dma_alloc_from_contiguous(): memory range at c08c6100 is busy, retrying
[  241.440301] cma: dma_alloc_from_contiguous(): memory range at c08c6120 is busy, retrying
[  241.448581] cma: dma_alloc_from_contiguous(): memory range at c08c6140 is busy, retrying
[  241.456862] cma: dma_alloc_from_contiguous(): memory range at c08c6160 is busy, retrying
[  241.465118] cma: dma_alloc_from_contiguous(): memory range at c08c6180 is busy, retrying
[  241.473399] cma: dma_alloc_from_contiguous(): memory range at c08c61a0 is busy, retrying
[  241.481678] cma: dma_alloc_from_contiguous(): memory range at c08c61c0 is busy, retrying
[  241.489960] cma: dma_alloc_from_contiguous(): memory range at c08c61e0 is busy, retrying
[  241.498251] cma: dma_alloc_from_contiguous(): memory range at c08c6200 is busy, retrying
[  241.506535] cma: dma_alloc_from_contiguous(): memory range at c08c6220 is busy, retrying
[  241.514791] cma: dma_alloc_from_contiguous(): memory range at c08c6240 is busy, retrying
[  241.523072] cma: dma_alloc_from_contiguous(): memory range at c08c6260 is busy, retrying
[  241.531352] cma: dma_alloc_from_contiguous(): memory range at c08c6280 is busy, retrying
[  241.539634] cma: dma_alloc_from_contiguous(): memory range at c08c62a0 is busy, retrying
[  241.547912] cma: dma_alloc_from_contiguous(): memory range at c08c62c0 is busy, retrying
[  241.556164] cma: dma_alloc_from_contiguous(): memory range at c08c62e0 is busy, retrying
[  241.564443] cma: dma_alloc_from_contiguous(): memory range at c08c6300 is busy, retrying
[  241.572722] cma: dma_alloc_from_contiguous(): memory range at c08c6320 is busy, retrying
[  241.581003] cma: dma_alloc_from_contiguous(): memory range at c08c6340 is busy, retrying
[  241.589282] cma: dma_alloc_from_contiguous(): memory range at c08c6360 is busy, retrying
[  241.597561] cma: dma_alloc_from_contiguous(): memory range at c08c6380 is busy, retrying
[  241.605814] cma: dma_alloc_from_contiguous(): memory range at c08c63a0 is busy, retrying
[  241.614104] cma: dma_alloc_from_contiguous(): memory range at c08c63c0 is busy, retrying
[  241.622396] cma: dma_alloc_from_contiguous(): returned c08c63e0
[  241.628340] successfully allocated 4096 bytes
[  241.632685] cma: dma_release_from_contiguous(page c08c63e0)
[  241.638259] cma: dma_alloc_from_contiguous(cma cf473fc0, count 2, align 1)
[  241.645308] cma: dma_alloc_from_contiguous(): memory range at c08c6000 is busy, retrying
[  241.653612] cma: dma_alloc_from_contiguous(): memory range at c08c6040 is busy, retrying
[  241.661892] cma: dma_alloc_from_contiguous(): memory range at c08c6080 is busy, retrying
[  241.670172] cma: dma_alloc_from_contiguous(): memory range at c08c60c0 is busy, retrying
[  241.678452] cma: dma_alloc_from_contiguous(): memory range at c08c6100 is busy, retrying
[  241.686736] cma: dma_alloc_from_contiguous(): memory range at c08c6140 is busy, retrying
[  241.694989] cma: dma_alloc_from_contiguous(): memory range at c08c6180 is busy, retrying
[  241.703279] cma: dma_alloc_from_contiguous(): memory range at c08c61c0 is busy, retrying
[  241.711560] cma: dma_alloc_from_contiguous(): memory range at c08c6200 is busy, retrying
[  241.719838] cma: dma_alloc_from_contiguous(): memory range at c08c6240 is busy, retrying
[  241.728116] cma: dma_alloc_from_contiguous(): memory range at c08c6280 is busy, retrying
[  241.736367] cma: dma_alloc_from_contiguous(): memory range at c08c62c0 is busy, retrying
[  241.744648] cma: dma_alloc_from_contiguous(): memory range at c08c6300 is busy, retrying
[  241.752927] cma: dma_alloc_from_contiguous(): memory range at c08c6340 is busy, retrying
[  241.761209] cma: dma_alloc_from_contiguous(): memory range at c08c6380 is busy, retrying
[  241.769484] cma: dma_alloc_from_contiguous(): returned c08c63c0
[  241.775416] successfully allocated 8192 bytes
[  241.779781] cma: dma_release_from_contiguous(page c08c63c0)
[  241.785342] cma: dma_alloc_from_contiguous(cma cf473fc0, count 4, align 2)
[  241.792408] cma: dma_alloc_from_contiguous(): memory range at c08c6000 is busy, retrying
[  241.800687] cma: dma_alloc_from_contiguous(): memory range at c08c6080 is busy, retrying
[  241.808967] cma: dma_alloc_from_contiguous(): memory range at c08c6100 is busy, retrying
[  241.817248] cma: dma_alloc_from_contiguous(): memory range at c08c6180 is busy, retrying
[  241.825501] cma: dma_alloc_from_contiguous(): memory range at c08c6200 is busy, retrying
[  241.833783] cma: dma_alloc_from_contiguous(): memory range at c08c6280 is busy, retrying
[  241.842062] cma: dma_alloc_from_contiguous(): memory range at c08c6300 is busy, retrying
[  241.850341] cma: dma_alloc_from_contiguous(): returned c08c6380
[  241.856299] successfully allocated 16384 bytes
[  241.860751] cma: dma_release_from_contiguous(page c08c6380)
[  241.866312] cma: dma_alloc_from_contiguous(cma cf473fc0, count 8, align 3)
[  241.873378] cma: dma_alloc_from_contiguous(): memory range at c08c6000 is busy, retrying
[  241.881667] cma: dma_alloc_from_contiguous(): memory range at c08c6100 is busy, retrying
[  241.889960] cma: dma_alloc_from_contiguous(): memory range at c08c6200 is busy, retrying
[  241.898245] cma: dma_alloc_from_contiguous(): returned c08c6300
[  241.904257] successfully allocated 32768 bytes
[  241.908711] cma: dma_release_from_contiguous(page c08c6300)
[  241.914274] cma: dma_alloc_from_contiguous(cma cf473fc0, count 16, align 4)
[  241.921433] cma: dma_alloc_from_contiguous(): memory range at c08c6000 is busy, retrying
[  241.929704] cma: dma_alloc_from_contiguous(): returned c08c6200
[  241.935815] successfully allocated 65536 bytes
[  241.940270] cma: dma_release_from_contiguous(page c08c6200)
[  241.945835] cma: dma_alloc_from_contiguous(cma cf473fc0, count 32, align 5)
[  241.953005] cma: dma_alloc_from_contiguous(): returned c08c6000
[  241.959358] successfully allocated 131072 bytes
[  241.963879] cma: dma_release_from_contiguous(page c08c6000)
[  241.969464] cma: dma_alloc_from_contiguous(cma cf473fc0, count 64, align 6)
[  241.976633] cma: dma_alloc_from_contiguous(): returned c08c7000
[  241.983362] successfully allocated 262144 bytes
[  241.987912] cma: dma_release_from_contiguous(page c08c7000)
[  241.993494] cma: dma_alloc_from_contiguous(cma cf473fc0, count 128, align 7)
[  242.000780] cma: dma_alloc_from_contiguous(): returned c08c8000
[  242.008388] successfully allocated 524288 bytes
[  242.012918] cma: dma_release_from_contiguous(page c08c8000)
[  242.018550] cma: dma_alloc_from_contiguous(cma cf473fc0, count 256, align 8)
[  242.026035] cma: dma_alloc_from_contiguous(): returned c08ca000
[  242.035433] successfully allocated 1048576 bytes
[  242.040096] cma: dma_release_from_contiguous(page c08ca000)
[  242.045776] cma: dma_alloc_from_contiguous(cma cf473fc0, count 512, align 8)
[  242.054059] cma: dma_alloc_from_contiguous(): memory range at c08ce000 is busy, retrying
[  242.063072] cma: dma_alloc_from_contiguous(): memory range at c08d0000 is busy, retrying
[  242.071782] cma: dma_alloc_from_contiguous(): returned c08d2000
[  242.082982] successfully allocated 2097152 bytes
[  242.087671] cma: dma_release_from_contiguous(page c08d2000)
[  242.093494] cma: dma_alloc_from_contiguous(cma cf473fc0, count 1024, align 8)
[  242.101253] cma: dma_alloc_from_contiguous(): returned c08ce000
[  242.115323] successfully allocated 4194304 bytes
[  242.120063] cma: dma_release_from_contiguous(page c08ce000)
[  242.126198] cma: dma_alloc_from_contiguous(cma cf473fc0, count 2048, align 8)
[  242.133650] alloc_contig_range test_pages_isolated(fc00, 10400) failed
[  242.140183] cma: dma_alloc_from_contiguous(): memory range at c08ce000 is busy, retrying
[  242.148473] alloc_contig_range test_pages_isolated(fc00, 10500) failed
[  242.154987] cma: dma_alloc_from_contiguous(): memory range at c08d0000 is busy, retrying
[  242.163274] alloc_contig_range test_pages_isolated(fc00, 10600) failed
[  242.169804] cma: dma_alloc_from_contiguous(): memory range at c08d2000 is busy, retrying
[  242.178084] alloc_contig_range test_pages_isolated(fc00, 10700) failed
[  242.184597] cma: dma_alloc_from_contiguous(): memory range at c08d4000 is busy, retrying
[  242.192882] alloc_contig_range test_pages_isolated(10000, 10800) failed
[  242.199498] cma: dma_alloc_from_contiguous(): memory range at c08d6000 is busy, retrying
[  242.207777] alloc_contig_range test_pages_isolated(10000, 10900) failed
[  242.214377] cma: dma_alloc_from_contiguous(): memory range at c08d8000 is busy, retrying
[  242.222663] alloc_contig_range test_pages_isolated(10000, 10a00) failed
[  242.229280] cma: dma_alloc_from_contiguous(): memory range at c08da000 is busy, retrying
[  242.237559] alloc_contig_range test_pages_isolated(10000, 10b00) failed
[  242.244159] cma: dma_alloc_from_contiguous(): memory range at c08dc000 is busy, retrying
[  242.252466] alloc_contig_range test_pages_isolated(10400, 10c00) failed
[  242.259082] cma: dma_alloc_from_contiguous(): memory range at c08de000 is busy, retrying
[  242.267362] alloc_contig_range test_pages_isolated(10400, 10d00) failed
[  242.273962] cma: dma_alloc_from_contiguous(): memory range at c08e0000 is busy, retrying
[  242.282247] alloc_contig_range test_pages_isolated(10400, 10e00) failed
[  242.288866] cma: dma_alloc_from_contiguous(): memory range at c08e2000 is busy, retrying
[  242.297152] alloc_contig_range test_pages_isolated(10400, 10f00) failed
[  242.303752] cma: dma_alloc_from_contiguous(): memory range at c08e4000 is busy, retrying
[  242.312037] alloc_contig_range test_pages_isolated(10800, 11000) failed
[  242.318653] cma: dma_alloc_from_contiguous(): memory range at c08e6000 is busy, retrying
[  242.326932] alloc_contig_range test_pages_isolated(10800, 11100) failed
[  242.333532] cma: dma_alloc_from_contiguous(): memory range at c08e8000 is busy, retrying
[  242.341818] alloc_contig_range test_pages_isolated(10800, 11200) failed
[  242.348435] cma: dma_alloc_from_contiguous(): memory range at c08ea000 is busy, retrying
[  242.356714] alloc_contig_range test_pages_isolated(10800, 11300) failed
[  242.363314] cma: dma_alloc_from_contiguous(): memory range at c08ec000 is busy, retrying
[  242.371597] alloc_contig_range test_pages_isolated(10c00, 11400) failed
[  242.378213] cma: dma_alloc_from_contiguous(): memory range at c08ee000 is busy, retrying
[  242.386494] alloc_contig_range test_pages_isolated(10c00, 11500) failed
[  242.393093] cma: dma_alloc_from_contiguous(): memory range at c08f0000 is busy, retrying
[  242.401377] alloc_contig_range test_pages_isolated(10c00, 11600) failed
[  242.407996] cma: dma_alloc_from_contiguous(): memory range at c08f2000 is busy, retrying
[  242.416269] alloc_contig_range test_pages_isolated(10c00, 11700) failed
[  242.422888] cma: dma_alloc_from_contiguous(): memory range at c08f4000 is busy, retrying
[  242.431164] alloc_contig_range test_pages_isolated(11000, 11800) failed
[  242.437784] cma: dma_alloc_from_contiguous(): memory range at c08f6000 is busy, retrying
[  242.446048] alloc_contig_range test_pages_isolated(11000, 11900) failed
[  242.452669] cma: dma_alloc_from_contiguous(): memory range at c08f8000 is busy, retrying
[  242.460946] alloc_contig_range test_pages_isolated(11000, 11a00) failed
[  242.467564] cma: dma_alloc_from_contiguous(): memory range at c08fa000 is busy, retrying
[  242.475829] alloc_contig_range test_pages_isolated(11000, 11b00) failed
[  242.482449] cma: dma_alloc_from_contiguous(): memory range at c08fc000 is busy, retrying
[  242.490724] alloc_contig_range test_pages_isolated(11400, 11c00) failed
[  242.497350] cma: dma_alloc_from_contiguous(): memory range at c08fe000 is busy, retrying
[  242.505619] alloc_contig_range test_pages_isolated(11400, 11d00) failed
[  242.512237] cma: dma_alloc_from_contiguous(): memory range at c0900000 is busy, retrying
[  242.520514] alloc_contig_range test_pages_isolated(11400, 11e00) failed
[  242.527133] cma: dma_alloc_from_contiguous(): memory range at c0902000 is busy, retrying
[  242.535397] alloc_contig_range test_pages_isolated(11400, 11f00) failed
[  242.542017] cma: dma_alloc_from_contiguous(): memory range at c0904000 is busy, retrying
[  242.550312] alloc_contig_range test_pages_isolated(11800, 12000) failed
[  242.556931] cma: dma_alloc_from_contiguous(): memory range at c0906000 is busy, retrying
[  242.565196] alloc_contig_range test_pages_isolated(11800, 12100) failed
[  242.571815] cma: dma_alloc_from_contiguous(): memory range at c0908000 is busy, retrying
[  242.580093] alloc_contig_range test_pages_isolated(11800, 12200) failed
[  242.586712] cma: dma_alloc_from_contiguous(): memory range at c090a000 is busy, retrying
[  242.594977] alloc_contig_range test_pages_isolated(11800, 12300) failed
[  242.601597] cma: dma_alloc_from_contiguous(): memory range at c090c000 is busy, retrying
[  242.609873] alloc_contig_range test_pages_isolated(11c00, 12400) failed
[  242.616491] cma: dma_alloc_from_contiguous(): memory range at c090e000 is busy, retrying
[  242.624756] alloc_contig_range test_pages_isolated(11c00, 12500) failed
[  242.631376] cma: dma_alloc_from_contiguous(): memory range at c0910000 is busy, retrying
[  242.639653] alloc_contig_range test_pages_isolated(11c00, 12600) failed
[  242.646252] cma: dma_alloc_from_contiguous(): memory range at c0912000 is busy, retrying
[  242.654540] alloc_contig_range test_pages_isolated(11c00, 12700) failed
[  242.661158] cma: dma_alloc_from_contiguous(): memory range at c0914000 is busy, retrying
[  242.669445] alloc_contig_range test_pages_isolated(12000, 12800) failed
[  242.676044] cma: dma_alloc_from_contiguous(): memory range at c0916000 is busy, retrying
[  242.684331] alloc_contig_range test_pages_isolated(12000, 12900) failed
[  242.690948] cma: dma_alloc_from_contiguous(): memory range at c0918000 is busy, retrying
[  242.699235] alloc_contig_range test_pages_isolated(12000, 12a00) failed
[  242.705835] cma: dma_alloc_from_contiguous(): memory range at c091a000 is busy, retrying
[  242.714124] alloc_contig_range test_pages_isolated(12000, 12b00) failed
[  242.720740] cma: dma_alloc_from_contiguous(): memory range at c091c000 is busy, retrying
[  242.729019] alloc_contig_range test_pages_isolated(12400, 12c00) failed
[  242.735619] cma: dma_alloc_from_contiguous(): memory range at c091e000 is busy, retrying
[  242.743906] alloc_contig_range test_pages_isolated(12400, 12d00) failed
[  242.750523] cma: dma_alloc_from_contiguous(): memory range at c0920000 is busy, retrying
[  242.758802] alloc_contig_range test_pages_isolated(12400, 12e00) failed
[  242.765403] cma: dma_alloc_from_contiguous(): memory range at c0922000 is busy, retrying
[  242.773690] alloc_contig_range test_pages_isolated(12400, 12f00) failed
[  242.780307] cma: dma_alloc_from_contiguous(): memory range at c0924000 is busy, retrying
[  242.788585] alloc_contig_range test_pages_isolated(12800, 13000) failed
[  242.795184] cma: dma_alloc_from_contiguous(): memory range at c0926000 is busy, retrying
[  242.803472] alloc_contig_range test_pages_isolated(12800, 13100) failed
[  242.810091] cma: dma_alloc_from_contiguous(): memory range at c0928000 is busy, retrying
[  242.818371] alloc_contig_range test_pages_isolated(12800, 13200) failed
[  242.824972] cma: dma_alloc_from_contiguous(): memory range at c092a000 is busy, retrying
[  242.833261] alloc_contig_range test_pages_isolated(12800, 13300) failed
[  242.839878] cma: dma_alloc_from_contiguous(): memory range at c092c000 is busy, retrying
[  242.848178] alloc_contig_range test_pages_isolated(12c00, 13400) failed
[  242.854777] cma: dma_alloc_from_contiguous(): memory range at c092e000 is busy, retrying
[  242.863065] alloc_contig_range test_pages_isolated(12c00, 13500) failed
[  242.869682] cma: dma_alloc_from_contiguous(): memory range at c0930000 is busy, retrying
[  242.877962] alloc_contig_range test_pages_isolated(12c00, 13600) failed
[  242.884561] cma: dma_alloc_from_contiguous(): memory range at c0932000 is busy, retrying
[  242.892848] alloc_contig_range test_pages_isolated(12c00, 13700) failed
[  242.899473] cma: dma_alloc_from_contiguous(): memory range at c0934000 is busy, retrying
[  242.907754] alloc_contig_range test_pages_isolated(13000, 13800) failed
[  242.914353] cma: dma_alloc_from_contiguous(): memory range at c0936000 is busy, retrying
[  242.922641] alloc_contig_range test_pages_isolated(13000, 13900) failed
[  242.929257] cma: dma_alloc_from_contiguous(): memory range at c0938000 is busy, retrying
[  242.937547] alloc_contig_range test_pages_isolated(13000, 13a00) failed
[  242.944148] cma: dma_alloc_from_contiguous(): memory range at c093a000 is busy, retrying
[  242.952435] alloc_contig_range test_pages_isolated(13000, 13b00) failed
[  242.959053] cma: dma_alloc_from_contiguous(): memory range at c093c000 is busy, retrying
[  242.967331] alloc_contig_range test_pages_isolated(13400, 13c00) failed
[  242.973930] cma: dma_alloc_from_contiguous(): memory range at c093e000 is busy, retrying
[  242.982216] alloc_contig_range test_pages_isolated(13400, 13d00) failed
[  242.988834] cma: dma_alloc_from_contiguous(): memory range at c0940000 is busy, retrying
[  242.997115] alloc_contig_range test_pages_isolated(13400, 13e00) failed
[  243.003715] cma: dma_alloc_from_contiguous(): memory range at c0942000 is busy, retrying
[  243.012003] alloc_contig_range test_pages_isolated(13400, 13f00) failed
[  243.018638] cma: dma_alloc_from_contiguous(): memory range at c0944000 is busy, retrying
[  243.026919] alloc_contig_range test_pages_isolated(13800, 14000) failed
[  243.033518] cma: dma_alloc_from_contiguous(): memory range at c0946000 is busy, retrying
[  243.041807] alloc_contig_range test_pages_isolated(13800, 14100) failed
[  243.048423] cma: dma_alloc_from_contiguous(): memory range at c0948000 is busy, retrying
[  243.056702] alloc_contig_range test_pages_isolated(13800, 14200) failed
[  243.063303] cma: dma_alloc_from_contiguous(): memory range at c094a000 is busy, retrying
[  243.071590] alloc_contig_range test_pages_isolated(13800, 14300) failed
[  243.078205] cma: dma_alloc_from_contiguous(): memory range at c094c000 is busy, retrying
[  243.086485] alloc_contig_range test_pages_isolated(13c00, 14400) failed
[  243.093084] cma: dma_alloc_from_contiguous(): memory range at c094e000 is busy, retrying
[  243.101378] alloc_contig_range test_pages_isolated(13c00, 14500) failed
[  243.107995] cma: dma_alloc_from_contiguous(): memory range at c0950000 is busy, retrying
[  243.116261] alloc_contig_range test_pages_isolated(13c00, 14600) failed
[  243.122880] cma: dma_alloc_from_contiguous(): memory range at c0952000 is busy, retrying
[  243.131157] alloc_contig_range test_pages_isolated(13c00, 14700) failed
[  243.137776] cma: dma_alloc_from_contiguous(): memory range at c0954000 is busy, retrying
[  243.146039] alloc_contig_range test_pages_isolated(14000, 14800) failed
[  243.152677] cma: dma_alloc_from_contiguous(): memory range at c0956000 is busy, retrying
[  243.160957] alloc_contig_range test_pages_isolated(14000, 14900) failed
[  243.167576] cma: dma_alloc_from_contiguous(): memory range at c0958000 is busy, retrying
[  243.175843] alloc_contig_range test_pages_isolated(14000, 14a00) failed
[  243.182460] cma: dma_alloc_from_contiguous(): memory range at c095a000 is busy, retrying
[  243.190747] alloc_contig_range test_pages_isolated(14000, 14b00) failed
[  243.197366] cma: dma_alloc_from_contiguous(): memory range at c095c000 is busy, retrying
[  243.205631] alloc_contig_range test_pages_isolated(14400, 14c00) failed
[  243.212249] cma: dma_alloc_from_contiguous(): memory range at c095e000 is busy, retrying
[  243.220528] alloc_contig_range test_pages_isolated(14400, 14d00) failed
[  243.227148] cma: dma_alloc_from_contiguous(): memory range at c0960000 is busy, retrying
[  243.235414] alloc_contig_range test_pages_isolated(14400, 14e00) failed
[  243.242034] cma: dma_alloc_from_contiguous(): memory range at c0962000 is busy, retrying
[  243.250313] alloc_contig_range test_pages_isolated(14400, 14f00) failed
[  243.256934] cma: dma_alloc_from_contiguous(): memory range at c0964000 is busy, retrying
[  243.265199] alloc_contig_range test_pages_isolated(14800, 15000) failed
[  243.271816] cma: dma_alloc_from_contiguous(): memory range at c0966000 is busy, retrying
[  243.280097] alloc_contig_range test_pages_isolated(14800, 15100) failed
[  243.286716] cma: dma_alloc_from_contiguous(): memory range at c0968000 is busy, retrying
[  243.294983] alloc_contig_range test_pages_isolated(14800, 15200) failed
[  243.301610] cma: dma_alloc_from_contiguous(): memory range at c096a000 is busy, retrying
[  243.309895] alloc_contig_range test_pages_isolated(14800, 15300) failed
[  243.316514] cma: dma_alloc_from_contiguous(): memory range at c096c000 is busy, retrying
[  243.324779] alloc_contig_range test_pages_isolated(14c00, 15400) failed
[  243.331397] cma: dma_alloc_from_contiguous(): memory range at c096e000 is busy, retrying
[  243.339675] alloc_contig_range test_pages_isolated(14c00, 15500) failed
[  243.346276] cma: dma_alloc_from_contiguous(): memory range at c0970000 is busy, retrying
[  243.354565] alloc_contig_range test_pages_isolated(14c00, 15600) failed
[  243.361181] cma: dma_alloc_from_contiguous(): memory range at c0972000 is busy, retrying
[  243.369461] alloc_contig_range test_pages_isolated(14c00, 15700) failed
[  243.376061] cma: dma_alloc_from_contiguous(): memory range at c0974000 is busy, retrying
[  243.384346] alloc_contig_range test_pages_isolated(15000, 15800) failed
[  243.390964] cma: dma_alloc_from_contiguous(): memory range at c0976000 is busy, retrying
[  243.399246] alloc_contig_range test_pages_isolated(15000, 15900) failed
[  243.405846] cma: dma_alloc_from_contiguous(): memory range at c0978000 is busy, retrying
[  243.414136] alloc_contig_range test_pages_isolated(15000, 15a00) failed
[  243.420754] cma: dma_alloc_from_contiguous(): memory range at c097a000 is busy, retrying
[  243.429034] alloc_contig_range test_pages_isolated(15000, 15b00) failed
[  243.435633] cma: dma_alloc_from_contiguous(): memory range at c097c000 is busy, retrying
[  243.443932] alloc_contig_range test_pages_isolated(15400, 15c00) failed
[  243.450570] cma: dma_alloc_from_contiguous(): memory range at c097e000 is busy, retrying
[  243.458857] alloc_contig_range test_pages_isolated(15400, 15d00) failed
[  243.465457] cma: dma_alloc_from_contiguous(): memory range at c0980000 is busy, retrying
[  243.473747] alloc_contig_range test_pages_isolated(15400, 15e00) failed
[  243.480365] cma: dma_alloc_from_contiguous(): memory range at c0982000 is busy, retrying
[  243.488647] alloc_contig_range test_pages_isolated(15400, 15f00) failed
[  243.495246] cma: dma_alloc_from_contiguous(): memory range at c0984000 is busy, retrying
[  243.503544] alloc_contig_range test_pages_isolated(15800, 16000) failed
[  243.510160] cma: dma_alloc_from_contiguous(): memory range at c0986000 is busy, retrying
[  243.518442] alloc_contig_range test_pages_isolated(15800, 16100) failed
[  243.525042] cma: dma_alloc_from_contiguous(): memory range at c0988000 is busy, retrying
[  243.533331] alloc_contig_range test_pages_isolated(15800, 16200) failed
[  243.539950] cma: dma_alloc_from_contiguous(): memory range at c098a000 is busy, retrying
[  243.548232] alloc_contig_range test_pages_isolated(15800, 16300) failed
[  243.554832] cma: dma_alloc_from_contiguous(): memory range at c098c000 is busy, retrying
[  243.563118] alloc_contig_range test_pages_isolated(15c00, 16400) failed
[  243.569734] cma: dma_alloc_from_contiguous(): memory range at c098e000 is busy, retrying
[  243.578015] alloc_contig_range test_pages_isolated(15c00, 16500) failed
[  243.584615] cma: dma_alloc_from_contiguous(): memory range at c0990000 is busy, retrying
[  243.592904] alloc_contig_range test_pages_isolated(15c00, 16600) failed
[  243.599520] cma: dma_alloc_from_contiguous(): memory range at c0992000 is busy, retrying
[  243.607799] alloc_contig_range test_pages_isolated(15c00, 16700) failed
[  243.614400] cma: dma_alloc_from_contiguous(): memory range at c0994000 is busy, retrying
[  243.622687] alloc_contig_range test_pages_isolated(16000, 16800) failed
[  243.629305] cma: dma_alloc_from_contiguous(): memory range at c0996000 is busy, retrying
[  243.637588] alloc_contig_range test_pages_isolated(16000, 16900) failed
[  243.644188] cma: dma_alloc_from_contiguous(): memory range at c0998000 is busy, retrying
[  243.652478] alloc_contig_range test_pages_isolated(16000, 16a00) failed
[  243.659095] cma: dma_alloc_from_contiguous(): memory range at c099a000 is busy, retrying
[  243.667377] alloc_contig_range test_pages_isolated(16000, 16b00) failed
[  243.673977] cma: dma_alloc_from_contiguous(): memory range at c099c000 is busy, retrying
[  243.682265] alloc_contig_range test_pages_isolated(16400, 16c00) failed
[  243.688883] cma: dma_alloc_from_contiguous(): memory range at c099e000 is busy, retrying
[  243.697173] alloc_contig_range test_pages_isolated(16400, 16d00) failed
[  243.703774] cma: dma_alloc_from_contiguous(): memory range at c09a0000 is busy, retrying
[  243.712086] alloc_contig_range test_pages_isolated(16400, 16e00) failed
[  243.718704] cma: dma_alloc_from_contiguous(): memory range at c09a2000 is busy, retrying
[  243.726987] alloc_contig_range test_pages_isolated(16400, 16f00) failed
[  243.733587] cma: dma_alloc_from_contiguous(): memory range at c09a4000 is busy, retrying
[  243.741877] alloc_contig_range test_pages_isolated(16800, 17000) failed
[  243.748515] cma: dma_alloc_from_contiguous(): memory range at c09a6000 is busy, retrying
[  243.756801] alloc_contig_range test_pages_isolated(16800, 17100) failed
[  243.763402] cma: dma_alloc_from_contiguous(): memory range at c09a8000 is busy, retrying
[  243.771692] alloc_contig_range test_pages_isolated(16800, 17200) failed
[  243.778308] cma: dma_alloc_from_contiguous(): memory range at c09aa000 is busy, retrying
[  243.786592] alloc_contig_range test_pages_isolated(16800, 17300) failed
[  243.793193] cma: dma_alloc_from_contiguous(): memory range at c09ac000 is busy, retrying
[  243.801480] alloc_contig_range test_pages_isolated(16c00, 17400) failed
[  243.808096] cma: dma_alloc_from_contiguous(): memory range at c09ae000 is busy, retrying
[  243.816362] alloc_contig_range test_pages_isolated(16c00, 17500) failed
[  243.822981] cma: dma_alloc_from_contiguous(): memory range at c09b0000 is busy, retrying
[  243.831261] alloc_contig_range test_pages_isolated(16c00, 17600) failed
[  243.837880] cma: dma_alloc_from_contiguous(): memory range at c09b2000 is busy, retrying
[  243.846147] alloc_contig_range test_pages_isolated(16c00, 17700) failed
[  243.852766] cma: dma_alloc_from_contiguous(): memory range at c09b4000 is busy, retrying
[  243.861044] alloc_contig_range test_pages_isolated(17000, 17800) failed
[  243.867663] cma: dma_alloc_from_contiguous(): memory range at c09b6000 is busy, retrying
[  243.875930] alloc_contig_range test_pages_isolated(17000, 17900) failed
[  243.882550] cma: dma_alloc_from_contiguous(): memory range at c09b8000 is busy, retrying
[  243.890831] alloc_contig_range test_pages_isolated(17000, 17a00) failed
[  243.897457] cma: dma_alloc_from_contiguous(): memory range at c09ba000 is busy, retrying
[  243.905730] alloc_contig_range test_pages_isolated(17000, 17b00) failed
[  243.912350] cma: dma_alloc_from_contiguous(): memory range at c09bc000 is busy, retrying
[  243.920628] alloc_contig_range test_pages_isolated(17400, 17c00) failed
[  243.927245] cma: dma_alloc_from_contiguous(): memory range at c09be000 is busy, retrying
[  243.935513] alloc_contig_range test_pages_isolated(17400, 17d00) failed
[  243.942132] cma: dma_alloc_from_contiguous(): memory range at c09c0000 is busy, retrying
[  243.950411] alloc_contig_range test_pages_isolated(17400, 17e00) failed
[  243.957032] cma: dma_alloc_from_contiguous(): memory range at c09c2000 is busy, retrying
[  243.965475] alloc_contig_range test_pages_isolated(17400, 17f00) failed
[  243.972097] cma: dma_alloc_from_contiguous(): memory range at c09c4000 is busy, retrying
[  243.980377] alloc_contig_range test_pages_isolated(17800, 18000) failed
[  243.986995] cma: dma_alloc_from_contiguous(): memory range at c09c6000 is busy, retrying
[  243.995265] alloc_contig_range test_pages_isolated(17800, 18100) failed
[  244.001883] cma: dma_alloc_from_contiguous(): memory range at c09c8000 is busy, retrying
[  244.010163] alloc_contig_range test_pages_isolated(17800, 18200) failed
[  244.016797] cma: dma_alloc_from_contiguous(): memory range at c09ca000 is busy, retrying
[  244.025065] alloc_contig_range test_pages_isolated(17800, 18300) failed
[  244.032048] cma: dma_alloc_from_contiguous(): memory range at c09cc000 is busy, retrying
[  244.040371] alloc_contig_range test_pages_isolated(17c00, 18400) failed
[  244.047012] cma: dma_alloc_from_contiguous(): memory range at c09ce000 is busy, retrying
[  244.055282] alloc_contig_range test_pages_isolated(17c00, 18500) failed
[  244.061984] cma: dma_alloc_from_contiguous(): memory range at c09d0000 is busy, retrying
[  244.070292] alloc_contig_range test_pages_isolated(17c00, 18600) failed
[  244.076912] cma: dma_alloc_from_contiguous(): memory range at c09d2000 is busy, retrying
[  244.085180] alloc_contig_range test_pages_isolated(17c00, 18700) failed
[  244.091797] cma: dma_alloc_from_contiguous(): memory range at c09d4000 is busy, retrying
[  244.100092] alloc_contig_range test_pages_isolated(18000, 18800) failed
[  244.106709] cma: dma_alloc_from_contiguous(): memory range at c09d6000 is busy, retrying
[  244.114976] alloc_contig_range test_pages_isolated(18000, 18900) failed
[  244.121597] cma: dma_alloc_from_contiguous(): memory range at c09d8000 is busy, retrying
[  244.129878] alloc_contig_range test_pages_isolated(18000, 18a00) failed
[  244.136498] cma: dma_alloc_from_contiguous(): memory range at c09da000 is busy, retrying
[  244.144764] alloc_contig_range test_pages_isolated(18000, 18b00) failed
[  244.151382] cma: dma_alloc_from_contiguous(): memory range at c09dc000 is busy, retrying
[  244.159808] alloc_contig_range test_pages_isolated(18400, 18c00) failed
[  244.166407] cma: dma_alloc_from_contiguous(): memory range at c09de000 is busy, retrying
[  244.174701] alloc_contig_range test_pages_isolated(18400, 18d00) failed
[  244.181315] cma: dma_alloc_from_contiguous(): memory range at c09e0000 is busy, retrying
[  244.189594] alloc_contig_range test_pages_isolated(18400, 18e00) failed
[  244.196195] cma: dma_alloc_from_contiguous(): memory range at c09e2000 is busy, retrying
[  244.204479] alloc_contig_range test_pages_isolated(18400, 18f00) failed
[  244.211093] cma: dma_alloc_from_contiguous(): memory range at c09e4000 is busy, retrying
[  244.219370] alloc_contig_range test_pages_isolated(18800, 19000) failed
[  244.225969] cma: dma_alloc_from_contiguous(): memory range at c09e6000 is busy, retrying
[  244.234253] alloc_contig_range test_pages_isolated(18800, 19100) failed
[  244.240865] cma: dma_alloc_from_contiguous(): memory range at c09e8000 is busy, retrying
[  244.249141] alloc_contig_range test_pages_isolated(18800, 19200) failed
[  244.255742] cma: dma_alloc_from_contiguous(): memory range at c09ea000 is busy, retrying
[  244.264140] alloc_contig_range test_pages_isolated(18800, 19300) failed
[  244.270759] cma: dma_alloc_from_contiguous(): memory range at c09ec000 is busy, retrying
[  244.279036] alloc_contig_range test_pages_isolated(18c00, 19400) failed
[  244.285636] cma: dma_alloc_from_contiguous(): memory range at c09ee000 is busy, retrying
[  244.293914] alloc_contig_range test_pages_isolated(18c00, 19500) failed
[  244.300539] cma: dma_alloc_from_contiguous(): memory range at c09f0000 is busy, retrying
[  244.308817] alloc_contig_range test_pages_isolated(18c00, 19600) failed
[  244.315417] cma: dma_alloc_from_contiguous(): memory range at c09f2000 is busy, retrying
[  244.323697] alloc_contig_range test_pages_isolated(18c00, 19700) failed
[  244.330314] cma: dma_alloc_from_contiguous(): memory range at c09f4000 is busy, retrying
[  244.338588] alloc_contig_range test_pages_isolated(19000, 19800) failed
[  244.345188] cma: dma_alloc_from_contiguous(): memory range at c09f6000 is busy, retrying
[  244.353486] alloc_contig_range test_pages_isolated(19000, 19900) failed
[  244.360276] cma: dma_alloc_from_contiguous(): memory range at c09f8000 is busy, retrying
[  244.368588] alloc_contig_range test_pages_isolated(19000, 19a00) failed
[  244.375190] cma: dma_alloc_from_contiguous(): memory range at c09fa000 is busy, retrying
[  244.383476] alloc_contig_range test_pages_isolated(19000, 19b00) failed
[  244.390090] cma: dma_alloc_from_contiguous(): memory range at c09fc000 is busy, retrying
[  244.398373] alloc_contig_range test_pages_isolated(19400, 19c00) failed
[  244.404972] cma: dma_alloc_from_contiguous(): memory range at c09fe000 is busy, retrying
[  244.413254] alloc_contig_range test_pages_isolated(19400, 19d00) failed
[  244.419867] cma: dma_alloc_from_contiguous(): memory range at c0a00000 is busy, retrying
[  244.428143] alloc_contig_range test_pages_isolated(19400, 19e00) failed
[  244.434743] cma: dma_alloc_from_contiguous(): memory range at c0a02000 is busy, retrying
[  244.443022] alloc_contig_range test_pages_isolated(19400, 19f00) failed
[  244.449635] cma: dma_alloc_from_contiguous(): memory range at c0a04000 is busy, retrying
[  244.457999] alloc_contig_range test_pages_isolated(19800, 1a000) failed
[  244.464598] cma: dma_alloc_from_contiguous(): memory range at c0a06000 is busy, retrying
[  244.472877] alloc_contig_range test_pages_isolated(19800, 1a100) failed
[  244.479489] cma: dma_alloc_from_contiguous(): memory range at c0a08000 is busy, retrying
[  244.487764] alloc_contig_range test_pages_isolated(19800, 1a200) failed
[  244.494364] cma: dma_alloc_from_contiguous(): memory range at c0a0a000 is busy, retrying
[  244.502651] alloc_contig_range test_pages_isolated(19800, 1a300) failed
[  244.509265] cma: dma_alloc_from_contiguous(): memory range at c0a0c000 is busy, retrying
[  244.517540] alloc_contig_range test_pages_isolated(19c00, 1a400) failed
[  244.524141] cma: dma_alloc_from_contiguous(): memory range at c0a0e000 is busy, retrying
[  244.532419] alloc_contig_range test_pages_isolated(19c00, 1a500) failed
[  244.539032] cma: dma_alloc_from_contiguous(): memory range at c0a10000 is busy, retrying
[  244.547308] alloc_contig_range test_pages_isolated(19c00, 1a600) failed
[  244.553908] cma: dma_alloc_from_contiguous(): memory range at c0a12000 is busy, retrying
[  244.562331] alloc_contig_range test_pages_isolated(19c00, 1a700) failed
[  244.568945] cma: dma_alloc_from_contiguous(): memory range at c0a14000 is busy, retrying
[  244.577219] alloc_contig_range test_pages_isolated(1a000, 1a800) failed
[  244.583818] cma: dma_alloc_from_contiguous(): memory range at c0a16000 is busy, retrying
[  244.592096] alloc_contig_range test_pages_isolated(1a000, 1a900) failed
[  244.598710] cma: dma_alloc_from_contiguous(): memory range at c0a18000 is busy, retrying
[  244.606985] alloc_contig_range test_pages_isolated(1a000, 1aa00) failed
[  244.613585] cma: dma_alloc_from_contiguous(): memory range at c0a1a000 is busy, retrying
[  244.621863] alloc_contig_range test_pages_isolated(1a000, 1ab00) failed
[  244.628476] cma: dma_alloc_from_contiguous(): memory range at c0a1c000 is busy, retrying
[  244.636751] alloc_contig_range test_pages_isolated(1a400, 1ac00) failed
[  244.643350] cma: dma_alloc_from_contiguous(): memory range at c0a1e000 is busy, retrying
[  244.651651] alloc_contig_range test_pages_isolated(1a400, 1ad00) failed
[  244.658378] cma: dma_alloc_from_contiguous(): memory range at c0a20000 is busy, retrying
[  244.666668] alloc_contig_range test_pages_isolated(1a400, 1ae00) failed
[  244.673270] cma: dma_alloc_from_contiguous(): memory range at c0a22000 is busy, retrying
[  244.681549] alloc_contig_range test_pages_isolated(1a400, 1af00) failed
[  244.688163] cma: dma_alloc_from_contiguous(): memory range at c0a24000 is busy, retrying
[  244.696447] alloc_contig_range test_pages_isolated(1a800, 1b000) failed
[  244.703046] cma: dma_alloc_from_contiguous(): memory range at c0a26000 is busy, retrying
[  244.711324] alloc_contig_range test_pages_isolated(1a800, 1b100) failed
[  244.717938] cma: dma_alloc_from_contiguous(): memory range at c0a28000 is busy, retrying
[  244.726205] alloc_contig_range test_pages_isolated(1a800, 1b200) failed
[  244.732820] cma: dma_alloc_from_contiguous(): memory range at c0a2a000 is busy, retrying
[  244.741094] alloc_contig_range test_pages_isolated(1a800, 1b300) failed
[  244.747709] cma: dma_alloc_from_contiguous(): memory range at c0a2c000 is busy, retrying
[  244.755973] alloc_contig_range test_pages_isolated(1ac00, 1b400) failed
[  244.762768] cma: dma_alloc_from_contiguous(): memory range at c0a2e000 is busy, retrying
[  244.771060] alloc_contig_range test_pages_isolated(1ac00, 1b500) failed
[  244.777675] cma: dma_alloc_from_contiguous(): memory range at c0a30000 is busy, retrying
[  244.785941] alloc_contig_range test_pages_isolated(1ac00, 1b600) failed
[  244.792556] cma: dma_alloc_from_contiguous(): memory range at c0a32000 is busy, retrying
[  244.800831] alloc_contig_range test_pages_isolated(1ac00, 1b700) failed
[  244.807445] cma: dma_alloc_from_contiguous(): memory range at c0a34000 is busy, retrying
[  244.815708] alloc_contig_range test_pages_isolated(1b000, 1b800) failed
[  244.822322] cma: dma_alloc_from_contiguous(): memory range at c0a36000 is busy, retrying
[  244.830595] alloc_contig_range test_pages_isolated(1b000, 1b900) failed
[  244.837211] cma: dma_alloc_from_contiguous(): memory range at c0a38000 is busy, retrying
[  244.845478] alloc_contig_range test_pages_isolated(1b000, 1ba00) failed
[  244.852094] cma: dma_alloc_from_contiguous(): memory range at c0a3a000 is busy, retrying
[  244.860511] alloc_contig_range test_pages_isolated(1b000, 1bb00) failed
[  244.867126] cma: dma_alloc_from_contiguous(): memory range at c0a3c000 is busy, retrying
[  244.875390] alloc_contig_range test_pages_isolated(1b400, 1bc00) failed
[  244.882004] cma: dma_alloc_from_contiguous(): memory range at c0a3e000 is busy, retrying
[  244.890276] alloc_contig_range test_pages_isolated(1b400, 1bd00) failed
[  244.896899] cma: dma_alloc_from_contiguous(): memory range at c0a40000 is busy, retrying
[  244.905163] alloc_contig_range test_pages_isolated(1b400, 1be00) failed
[  244.911778] cma: dma_alloc_from_contiguous(): memory range at c0a42000 is busy, retrying
[  244.920053] alloc_contig_range test_pages_isolated(1b400, 1bf00) failed
[  244.926668] cma: dma_alloc_from_contiguous(): memory range at c0a44000 is busy, retrying
[  244.934933] alloc_contig_range test_pages_isolated(1b800, 1c000) failed
[  244.941546] cma: dma_alloc_from_contiguous(): memory range at c0a46000 is busy, retrying
[  244.949842] alloc_contig_range test_pages_isolated(1b800, 1c100) failed
[  244.956543] cma: dma_alloc_from_contiguous(): memory range at c0a48000 is busy, retrying
[  244.964818] alloc_contig_range test_pages_isolated(1b800, 1c200) failed
[  244.971435] cma: dma_alloc_from_contiguous(): memory range at c0a4a000 is busy, retrying
[  244.979709] alloc_contig_range test_pages_isolated(1b800, 1c300) failed
[  244.986309] cma: dma_alloc_from_contiguous(): memory range at c0a4c000 is busy, retrying
[  244.994586] alloc_contig_range test_pages_isolated(1bc00, 1c400) failed
[  245.001196] cma: dma_alloc_from_contiguous(): memory range at c0a4e000 is busy, retrying
[  245.009473] alloc_contig_range test_pages_isolated(1bc00, 1c500) failed
[  245.016073] cma: dma_alloc_from_contiguous(): memory range at c0a50000 is busy, retrying
[  245.024366] alloc_contig_range test_pages_isolated(1bc00, 1c600) failed
[  245.030980] cma: dma_alloc_from_contiguous(): memory range at c0a52000 is busy, retrying
[  245.039256] alloc_contig_range test_pages_isolated(1bc00, 1c700) failed
[  245.045858] cma: dma_alloc_from_contiguous(): memory range at c0a54000 is busy, retrying
[  245.054135] alloc_contig_range test_pages_isolated(1c000, 1c800) failed
[  245.060929] cma: dma_alloc_from_contiguous(): memory range at c0a56000 is busy, retrying
[  245.069224] alloc_contig_range test_pages_isolated(1c000, 1c900) failed
[  245.075825] cma: dma_alloc_from_contiguous(): memory range at c0a58000 is busy, retrying
[  245.084106] alloc_contig_range test_pages_isolated(1c000, 1ca00) failed
[  245.090719] cma: dma_alloc_from_contiguous(): memory range at c0a5a000 is busy, retrying
[  245.099001] alloc_contig_range test_pages_isolated(1c000, 1cb00) failed
[  245.105602] cma: dma_alloc_from_contiguous(): memory range at c0a5c000 is busy, retrying
[  245.113882] alloc_contig_range test_pages_isolated(1c400, 1cc00) failed
[  245.120494] cma: dma_alloc_from_contiguous(): memory range at c0a5e000 is busy, retrying
[  245.128773] alloc_contig_range test_pages_isolated(1c400, 1cd00) failed
[  245.135372] cma: dma_alloc_from_contiguous(): memory range at c0a60000 is busy, retrying
[  245.143653] alloc_contig_range test_pages_isolated(1c400, 1ce00) failed
[  245.150267] cma: dma_alloc_from_contiguous(): memory range at c0a62000 is busy, retrying
[  245.158624] alloc_contig_range test_pages_isolated(1c400, 1cf00) failed
[  245.165224] cma: dma_alloc_from_contiguous(): memory range at c0a64000 is busy, retrying
[  245.173505] alloc_contig_range test_pages_isolated(1c800, 1d000) failed
[  245.180118] cma: dma_alloc_from_contiguous(): memory range at c0a66000 is busy, retrying
[  245.188393] alloc_contig_range test_pages_isolated(1c800, 1d100) failed
[  245.194995] cma: dma_alloc_from_contiguous(): memory range at c0a68000 is busy, retrying
[  245.203272] alloc_contig_range test_pages_isolated(1c800, 1d200) failed
[  245.209885] cma: dma_alloc_from_contiguous(): memory range at c0a6a000 is busy, retrying
[  245.218161] alloc_contig_range test_pages_isolated(1c800, 1d300) failed
[  245.224763] cma: dma_alloc_from_contiguous(): memory range at c0a6c000 is busy, retrying
[  245.233041] alloc_contig_range test_pages_isolated(1cc00, 1d400) failed
[  245.239652] cma: dma_alloc_from_contiguous(): memory range at c0a6e000 is busy, retrying
[  245.247948] alloc_contig_range test_pages_isolated(1cc00, 1d500) failed
[  245.254548] cma: dma_alloc_from_contiguous(): memory range at c0a70000 is busy, retrying
[  245.263005] alloc_contig_range test_pages_isolated(1cc00, 1d600) failed
[  245.269621] cma: dma_alloc_from_contiguous(): memory range at c0a72000 is busy, retrying
[  245.277898] alloc_contig_range test_pages_isolated(1cc00, 1d700) failed
[  245.284498] cma: dma_alloc_from_contiguous(): memory range at c0a74000 is busy, retrying
[  245.292775] alloc_contig_range test_pages_isolated(1d000, 1d800) failed
[  245.299394] cma: dma_alloc_from_contiguous(): memory range at c0a76000 is busy, retrying
[  245.307673] alloc_contig_range test_pages_isolated(1d000, 1d900) failed
[  245.314273] cma: dma_alloc_from_contiguous(): memory range at c0a78000 is busy, retrying
[  245.322554] alloc_contig_range test_pages_isolated(1d000, 1da00) failed
[  245.329166] cma: dma_alloc_from_contiguous(): memory range at c0a7a000 is busy, retrying
[  245.337442] alloc_contig_range test_pages_isolated(1d000, 1db00) failed
[  245.344043] cma: dma_alloc_from_contiguous(): memory range at c0a7c000 is busy, retrying
[  245.352319] alloc_contig_range test_pages_isolated(1d400, 1dc00) failed
[  245.359056] cma: dma_alloc_from_contiguous(): memory range at c0a7e000 is busy, retrying
[  245.367347] alloc_contig_range test_pages_isolated(1d400, 1dd00) failed
[  245.373947] cma: dma_alloc_from_contiguous(): memory range at c0a80000 is busy, retrying
[  245.382226] alloc_contig_range test_pages_isolated(1d400, 1de00) failed
[  245.388839] cma: dma_alloc_from_contiguous(): memory range at c0a82000 is busy, retrying
[  245.397114] alloc_contig_range test_pages_isolated(1d400, 1df00) failed
[  245.403714] cma: dma_alloc_from_contiguous(): memory range at c0a84000 is busy, retrying
[  245.411993] alloc_contig_range test_pages_isolated(1d800, 1e000) failed
[  245.418604] cma: dma_alloc_from_contiguous(): memory range at c0a86000 is busy, retrying
[  245.426884] alloc_contig_range test_pages_isolated(1d800, 1e100) failed
[  245.433483] cma: dma_alloc_from_contiguous(): memory range at c0a88000 is busy, retrying
[  245.441763] alloc_contig_range test_pages_isolated(1d800, 1e200) failed
[  245.448375] cma: dma_alloc_from_contiguous(): memory range at c0a8a000 is busy, retrying
[  245.456826] alloc_contig_range test_pages_isolated(1d800, 1e300) failed
[  245.463429] cma: dma_alloc_from_contiguous(): memory range at c0a8c000 is busy, retrying
[  245.471709] alloc_contig_range test_pages_isolated(1dc00, 1e400) failed
[  245.478321] cma: dma_alloc_from_contiguous(): memory range at c0a8e000 is busy, retrying
[  245.486599] alloc_contig_range test_pages_isolated(1dc00, 1e500) failed
[  245.493199] cma: dma_alloc_from_contiguous(): memory range at c0a90000 is busy, retrying
[  245.501487] alloc_contig_range test_pages_isolated(1dc00, 1e600) failed
[  245.508102] cma: dma_alloc_from_contiguous(): memory range at c0a92000 is busy, retrying
[  245.516368] alloc_contig_range test_pages_isolated(1dc00, 1e700) failed
[  245.522982] cma: dma_alloc_from_contiguous(): memory range at c0a94000 is busy, retrying
[  245.531254] alloc_contig_range test_pages_isolated(1e000, 1e800) failed
[  245.537868] cma: dma_alloc_from_contiguous(): memory range at c0a96000 is busy, retrying
[  245.546134] alloc_contig_range test_pages_isolated(1e000, 1e900) failed
[  245.552768] cma: dma_alloc_from_contiguous(): memory range at c0a98000 is busy, retrying
[  245.561186] alloc_contig_range test_pages_isolated(1e000, 1ea00) failed
[  245.567802] cma: dma_alloc_from_contiguous(): memory range at c0a9a000 is busy, retrying
[  245.576067] alloc_contig_range test_pages_isolated(1e000, 1eb00) failed
[  245.582682] cma: dma_alloc_from_contiguous(): memory range at c0a9c000 is busy, retrying
[  245.590957] alloc_contig_range test_pages_isolated(1e400, 1ec00) failed
[  245.597570] cma: dma_alloc_from_contiguous(): memory range at c0a9e000 is busy, retrying
[  245.605838] alloc_contig_range test_pages_isolated(1e400, 1ed00) failed
[  245.612452] cma: dma_alloc_from_contiguous(): memory range at c0aa0000 is busy, retrying
[  245.620725] alloc_contig_range test_pages_isolated(1e400, 1ee00) failed
[  245.627340] cma: dma_alloc_from_contiguous(): memory range at c0aa2000 is busy, retrying
[  245.635605] alloc_contig_range test_pages_isolated(1e400, 1ef00) failed
[  245.642219] cma: dma_alloc_from_contiguous(): memory range at c0aa4000 is busy, retrying
[  245.650491] alloc_contig_range test_pages_isolated(1e800, 1f000) failed
[  245.657232] cma: dma_alloc_from_contiguous(): memory range at c0aa6000 is busy, retrying
[  245.665512] alloc_contig_range test_pages_isolated(1e800, 1f100) failed
[  245.672127] cma: dma_alloc_from_contiguous(): memory range at c0aa8000 is busy, retrying
[  245.680404] alloc_contig_range test_pages_isolated(1e800, 1f200) failed
[  245.687020] cma: dma_alloc_from_contiguous(): memory range at c0aaa000 is busy, retrying
[  245.695284] alloc_contig_range test_pages_isolated(1e800, 1f300) failed
[  245.701906] cma: dma_alloc_from_contiguous(): memory range at c0aac000 is busy, retrying
[  245.710181] alloc_contig_range test_pages_isolated(1ec00, 1f400) failed
[  245.716794] cma: dma_alloc_from_contiguous(): memory range at c0aae000 is busy, retrying
[  245.725058] alloc_contig_range test_pages_isolated(1ec00, 1f500) failed
[  245.731673] cma: dma_alloc_from_contiguous(): memory range at c0ab0000 is busy, retrying
[  245.739947] alloc_contig_range test_pages_isolated(1ec00, 1f600) failed
[  245.746561] cma: dma_alloc_from_contiguous(): memory range at c0ab2000 is busy, retrying
[  245.754826] alloc_contig_range test_pages_isolated(1ec00, 1f700) failed
[  245.761573] cma: dma_alloc_from_contiguous(): memory range at c0ab4000 is busy, retrying
[  245.769858] alloc_contig_range test_pages_isolated(1f000, 1f800) failed
[  245.776472] cma: dma_alloc_from_contiguous(): memory range at c0ab6000 is busy, retrying
[  245.784542] cma: dma_alloc_from_contiguous(): returned   (null)
[  245.790457] failed to allocate 8388608 bytes
[  245.794717] cma: dma_alloc_from_contiguous(cma cf473fc0, count 4096, align 8)
[  245.802434] alloc_contig_range test_pages_isolated(fc00, 10c00) failed
[  245.808964] cma: dma_alloc_from_contiguous(): memory range at c08ce000 is busy, retrying
[  245.817381] alloc_contig_range test_pages_isolated(fc00, 10d00) failed
[  245.823897] cma: dma_alloc_from_contiguous(): memory range at c08d0000 is busy, retrying
[  245.832311] alloc_contig_range test_pages_isolated(fc00, 10e00) failed
[  245.838839] cma: dma_alloc_from_contiguous(): memory range at c08d2000 is busy, retrying
[  245.847269] alloc_contig_range test_pages_isolated(fc00, 10f00) failed
[  245.853785] cma: dma_alloc_from_contiguous(): memory range at c08d4000 is busy, retrying
[  245.862280] alloc_contig_range test_pages_isolated(10000, 11000) failed
[  245.868901] cma: dma_alloc_from_contiguous(): memory range at c08d6000 is busy, retrying
[  245.877315] alloc_contig_range test_pages_isolated(10000, 11100) failed
[  245.883916] cma: dma_alloc_from_contiguous(): memory range at c08d8000 is busy, retrying
[  245.892328] alloc_contig_range test_pages_isolated(10000, 11200) failed
[  245.898955] cma: dma_alloc_from_contiguous(): memory range at c08da000 is busy, retrying
[  245.907368] alloc_contig_range test_pages_isolated(10000, 11300) failed
[  245.913970] cma: dma_alloc_from_contiguous(): memory range at c08dc000 is busy, retrying
[  245.922381] alloc_contig_range test_pages_isolated(10400, 11400) failed
[  245.928998] cma: dma_alloc_from_contiguous(): memory range at c08de000 is busy, retrying
[  245.937407] alloc_contig_range test_pages_isolated(10400, 11500) failed
[  245.944008] cma: dma_alloc_from_contiguous(): memory range at c08e0000 is busy, retrying
[  245.952421] alloc_contig_range test_pages_isolated(10400, 11600) failed
[  245.959170] cma: dma_alloc_from_contiguous(): memory range at c08e2000 is busy, retrying
[  245.967587] alloc_contig_range test_pages_isolated(10400, 11700) failed
[  245.974189] cma: dma_alloc_from_contiguous(): memory range at c08e4000 is busy, retrying
[  245.982596] alloc_contig_range test_pages_isolated(10800, 11800) failed
[  245.989210] cma: dma_alloc_from_contiguous(): memory range at c08e6000 is busy, retrying
[  245.997618] alloc_contig_range test_pages_isolated(10800, 11900) failed
[  246.004221] cma: dma_alloc_from_contiguous(): memory range at c08e8000 is busy, retrying
[  246.012631] alloc_contig_range test_pages_isolated(10800, 11a00) failed
[  246.019504] cma: dma_alloc_from_contiguous(): memory range at c08ea000 is busy, retrying
[  246.027934] alloc_contig_range test_pages_isolated(10800, 11b00) failed
[  246.034537] cma: dma_alloc_from_contiguous(): memory range at c08ec000 is busy, retrying
[  246.042948] alloc_contig_range test_pages_isolated(10c00, 11c00) failed
[  246.049562] cma: dma_alloc_from_contiguous(): memory range at c08ee000 is busy, retrying
[  246.058065] alloc_contig_range test_pages_isolated(10c00, 11d00) failed
[  246.064667] cma: dma_alloc_from_contiguous(): memory range at c08f0000 is busy, retrying
[  246.073086] alloc_contig_range test_pages_isolated(10c00, 11e00) failed
[  246.079702] cma: dma_alloc_from_contiguous(): memory range at c08f2000 is busy, retrying
[  246.088114] alloc_contig_range test_pages_isolated(10c00, 11f00) failed
[  246.094715] cma: dma_alloc_from_contiguous(): memory range at c08f4000 is busy, retrying
[  246.103164] alloc_contig_range test_pages_isolated(11000, 12000) failed
[  246.109778] cma: dma_alloc_from_contiguous(): memory range at c08f6000 is busy, retrying
[  246.118191] alloc_contig_range test_pages_isolated(11000, 12100) failed
[  246.124792] cma: dma_alloc_from_contiguous(): memory range at c08f8000 is busy, retrying
[  246.133208] alloc_contig_range test_pages_isolated(11000, 12200) failed
[  246.139824] cma: dma_alloc_from_contiguous(): memory range at c08fa000 is busy, retrying
[  246.148254] alloc_contig_range test_pages_isolated(11000, 12300) failed
[  246.154856] cma: dma_alloc_from_contiguous(): memory range at c08fc000 is busy, retrying
[  246.163471] alloc_contig_range test_pages_isolated(11400, 12400) failed
[  246.170091] cma: dma_alloc_from_contiguous(): memory range at c08fe000 is busy, retrying
[  246.178504] alloc_contig_range test_pages_isolated(11400, 12500) failed
[  246.185106] cma: dma_alloc_from_contiguous(): memory range at c0900000 is busy, retrying
[  246.193521] alloc_contig_range test_pages_isolated(11400, 12600) failed
[  246.200141] cma: dma_alloc_from_contiguous(): memory range at c0902000 is busy, retrying
[  246.208552] alloc_contig_range test_pages_isolated(11400, 12700) failed
[  246.215153] cma: dma_alloc_from_contiguous(): memory range at c0904000 is busy, retrying
[  246.223561] alloc_contig_range test_pages_isolated(11800, 12800) failed
[  246.230178] cma: dma_alloc_from_contiguous(): memory range at c0906000 is busy, retrying
[  246.238587] alloc_contig_range test_pages_isolated(11800, 12900) failed
[  246.245189] cma: dma_alloc_from_contiguous(): memory range at c0908000 is busy, retrying
[  246.253601] alloc_contig_range test_pages_isolated(11800, 12a00) failed
[  246.260289] cma: dma_alloc_from_contiguous(): memory range at c090a000 is busy, retrying
[  246.268707] alloc_contig_range test_pages_isolated(11800, 12b00) failed
[  246.275310] cma: dma_alloc_from_contiguous(): memory range at c090c000 is busy, retrying
[  246.283722] alloc_contig_range test_pages_isolated(11c00, 12c00) failed
[  246.290337] cma: dma_alloc_from_contiguous(): memory range at c090e000 is busy, retrying
[  246.298755] alloc_contig_range test_pages_isolated(11c00, 12d00) failed
[  246.305357] cma: dma_alloc_from_contiguous(): memory range at c0910000 is busy, retrying
[  246.313769] alloc_contig_range test_pages_isolated(11c00, 12e00) failed
[  246.320385] cma: dma_alloc_from_contiguous(): memory range at c0912000 is busy, retrying
[  246.328795] alloc_contig_range test_pages_isolated(11c00, 12f00) failed
[  246.335396] cma: dma_alloc_from_contiguous(): memory range at c0914000 is busy, retrying
[  246.343805] alloc_contig_range test_pages_isolated(12000, 13000) failed
[  246.350419] cma: dma_alloc_from_contiguous(): memory range at c0916000 is busy, retrying
[  246.358969] alloc_contig_range test_pages_isolated(12000, 13100) failed
[  246.365571] cma: dma_alloc_from_contiguous(): memory range at c0918000 is busy, retrying
[  246.373986] alloc_contig_range test_pages_isolated(12000, 13200) failed
[  246.380600] cma: dma_alloc_from_contiguous(): memory range at c091a000 is busy, retrying
[  246.389011] alloc_contig_range test_pages_isolated(12000, 13300) failed
[  246.395614] cma: dma_alloc_from_contiguous(): memory range at c091c000 is busy, retrying
[  246.404025] alloc_contig_range test_pages_isolated(12400, 13400) failed
[  246.410640] cma: dma_alloc_from_contiguous(): memory range at c091e000 is busy, retrying
[  246.419048] alloc_contig_range test_pages_isolated(12400, 13500) failed
[  246.425649] cma: dma_alloc_from_contiguous(): memory range at c0920000 is busy, retrying
[  246.434063] alloc_contig_range test_pages_isolated(12400, 13600) failed
[  246.440677] cma: dma_alloc_from_contiguous(): memory range at c0922000 is busy, retrying
[  246.449104] alloc_contig_range test_pages_isolated(12400, 13700) failed
[  246.455706] cma: dma_alloc_from_contiguous(): memory range at c0924000 is busy, retrying
[  246.464232] alloc_contig_range test_pages_isolated(12800, 13800) failed
[  246.470851] cma: dma_alloc_from_contiguous(): memory range at c0926000 is busy, retrying
[  246.479265] alloc_contig_range test_pages_isolated(12800, 13900) failed
[  246.485867] cma: dma_alloc_from_contiguous(): memory range at c0928000 is busy, retrying
[  246.494279] alloc_contig_range test_pages_isolated(12800, 13a00) failed
[  246.500906] cma: dma_alloc_from_contiguous(): memory range at c092a000 is busy, retrying
[  246.509317] alloc_contig_range test_pages_isolated(12800, 13b00) failed
[  246.515918] cma: dma_alloc_from_contiguous(): memory range at c092c000 is busy, retrying
[  246.524331] alloc_contig_range test_pages_isolated(12c00, 13c00) failed
[  246.530948] cma: dma_alloc_from_contiguous(): memory range at c092e000 is busy, retrying
[  246.539359] alloc_contig_range test_pages_isolated(12c00, 13d00) failed
[  246.545960] cma: dma_alloc_from_contiguous(): memory range at c0930000 is busy, retrying
[  246.554374] alloc_contig_range test_pages_isolated(12c00, 13e00) failed
[  246.561168] cma: dma_alloc_from_contiguous(): memory range at c0932000 is busy, retrying
[  246.569597] alloc_contig_range test_pages_isolated(12c00, 13f00) failed
[  246.576200] cma: dma_alloc_from_contiguous(): memory range at c0934000 is busy, retrying
[  246.584612] alloc_contig_range test_pages_isolated(13000, 14000) failed
[  246.591225] cma: dma_alloc_from_contiguous(): memory range at c0936000 is busy, retrying
[  246.599633] alloc_contig_range test_pages_isolated(13000, 14100) failed
[  246.606235] cma: dma_alloc_from_contiguous(): memory range at c0938000 is busy, retrying
[  246.614644] alloc_contig_range test_pages_isolated(13000, 14200) failed
[  246.621258] cma: dma_alloc_from_contiguous(): memory range at c093a000 is busy, retrying
[  246.629668] alloc_contig_range test_pages_isolated(13000, 14300) failed
[  246.636272] cma: dma_alloc_from_contiguous(): memory range at c093c000 is busy, retrying
[  246.644683] alloc_contig_range test_pages_isolated(13400, 14400) failed
[  246.651296] cma: dma_alloc_from_contiguous(): memory range at c093e000 is busy, retrying
[  246.659796] alloc_contig_range test_pages_isolated(13400, 14500) failed
[  246.666398] cma: dma_alloc_from_contiguous(): memory range at c0940000 is busy, retrying
[  246.674812] alloc_contig_range test_pages_isolated(13400, 14600) failed
[  246.681426] cma: dma_alloc_from_contiguous(): memory range at c0942000 is busy, retrying
[  246.689837] alloc_contig_range test_pages_isolated(13400, 14700) failed
[  246.696459] cma: dma_alloc_from_contiguous(): memory range at c0944000 is busy, retrying
[  246.704856] alloc_contig_range test_pages_isolated(13800, 14800) failed
[  246.711472] cma: dma_alloc_from_contiguous(): memory range at c0946000 is busy, retrying
[  246.719879] alloc_contig_range test_pages_isolated(13800, 14900) failed
[  246.726497] cma: dma_alloc_from_contiguous(): memory range at c0948000 is busy, retrying
[  246.734895] alloc_contig_range test_pages_isolated(13800, 14a00) failed
[  246.741512] cma: dma_alloc_from_contiguous(): memory range at c094a000 is busy, retrying
[  246.749937] alloc_contig_range test_pages_isolated(13800, 14b00) failed
[  246.756747] cma: dma_alloc_from_contiguous(): memory range at c094c000 is busy, retrying
[  246.765155] alloc_contig_range test_pages_isolated(13c00, 14c00) failed
[  246.771775] cma: dma_alloc_from_contiguous(): memory range at c094e000 is busy, retrying
[  246.780187] alloc_contig_range test_pages_isolated(13c00, 14d00) failed
[  246.786804] cma: dma_alloc_from_contiguous(): memory range at c0950000 is busy, retrying
[  246.795204] alloc_contig_range test_pages_isolated(13c00, 14e00) failed
[  246.801825] cma: dma_alloc_from_contiguous(): memory range at c0952000 is busy, retrying
[  246.810238] alloc_contig_range test_pages_isolated(13c00, 14f00) failed
[  246.816856] cma: dma_alloc_from_contiguous(): memory range at c0954000 is busy, retrying
[  246.825254] alloc_contig_range test_pages_isolated(14000, 15000) failed
[  246.831872] cma: dma_alloc_from_contiguous(): memory range at c0956000 is busy, retrying
[  246.840282] alloc_contig_range test_pages_isolated(14000, 15100) failed
[  246.846899] cma: dma_alloc_from_contiguous(): memory range at c0958000 is busy, retrying
[  246.855300] alloc_contig_range test_pages_isolated(14000, 15200) failed
[  246.861998] cma: dma_alloc_from_contiguous(): memory range at c095a000 is busy, retrying
[  246.870423] alloc_contig_range test_pages_isolated(14000, 15300) failed
[  246.877040] cma: dma_alloc_from_contiguous(): memory range at c095c000 is busy, retrying
[  246.885437] alloc_contig_range test_pages_isolated(14400, 15400) failed
[  246.892053] cma: dma_alloc_from_contiguous(): memory range at c095e000 is busy, retrying
[  246.900473] alloc_contig_range test_pages_isolated(14400, 15500) failed
[  246.907089] cma: dma_alloc_from_contiguous(): memory range at c0960000 is busy, retrying
[  246.915490] alloc_contig_range test_pages_isolated(14400, 15600) failed
[  246.922107] cma: dma_alloc_from_contiguous(): memory range at c0962000 is busy, retrying
[  246.930516] alloc_contig_range test_pages_isolated(14400, 15700) failed
[  246.937134] cma: dma_alloc_from_contiguous(): memory range at c0964000 is busy, retrying
[  246.945531] alloc_contig_range test_pages_isolated(14800, 15800) failed
[  246.952147] cma: dma_alloc_from_contiguous(): memory range at c0966000 is busy, retrying
[  246.960692] alloc_contig_range test_pages_isolated(14800, 15900) failed
[  246.967309] cma: dma_alloc_from_contiguous(): memory range at c0968000 is busy, retrying
[  246.975711] alloc_contig_range test_pages_isolated(14800, 15a00) failed
[  246.982327] cma: dma_alloc_from_contiguous(): memory range at c096a000 is busy, retrying
[  246.990735] alloc_contig_range test_pages_isolated(14800, 15b00) failed
[  246.997352] cma: dma_alloc_from_contiguous(): memory range at c096c000 is busy, retrying
[  247.005751] alloc_contig_range test_pages_isolated(14c00, 15c00) failed
[  247.012368] cma: dma_alloc_from_contiguous(): memory range at c096e000 is busy, retrying
[  247.020787] alloc_contig_range test_pages_isolated(14c00, 15d00) failed
[  247.027404] cma: dma_alloc_from_contiguous(): memory range at c0970000 is busy, retrying
[  247.035803] alloc_contig_range test_pages_isolated(14c00, 15e00) failed
[  247.042419] cma: dma_alloc_from_contiguous(): memory range at c0972000 is busy, retrying
[  247.050846] alloc_contig_range test_pages_isolated(14c00, 15f00) failed
[  247.057534] cma: dma_alloc_from_contiguous(): memory range at c0974000 is busy, retrying
[  247.065941] alloc_contig_range test_pages_isolated(15000, 16000) failed
[  247.072557] cma: dma_alloc_from_contiguous(): memory range at c0976000 is busy, retrying
[  247.080963] alloc_contig_range test_pages_isolated(15000, 16100) failed
[  247.087579] cma: dma_alloc_from_contiguous(): memory range at c0978000 is busy, retrying
[  247.095976] alloc_contig_range test_pages_isolated(15000, 16200) failed
[  247.102600] cma: dma_alloc_from_contiguous(): memory range at c097a000 is busy, retrying
[  247.111009] alloc_contig_range test_pages_isolated(15000, 16300) failed
[  247.117626] cma: dma_alloc_from_contiguous(): memory range at c097c000 is busy, retrying
[  247.126023] alloc_contig_range test_pages_isolated(15400, 16400) failed
[  247.132638] cma: dma_alloc_from_contiguous(): memory range at c097e000 is busy, retrying
[  247.141045] alloc_contig_range test_pages_isolated(15400, 16500) failed
[  247.147661] cma: dma_alloc_from_contiguous(): memory range at c0980000 is busy, retrying
[  247.156059] alloc_contig_range test_pages_isolated(15400, 16600) failed
[  247.162890] cma: dma_alloc_from_contiguous(): memory range at c0982000 is busy, retrying
[  247.171314] alloc_contig_range test_pages_isolated(15400, 16700) failed
[  247.177931] cma: dma_alloc_from_contiguous(): memory range at c0984000 is busy, retrying
[  247.186329] alloc_contig_range test_pages_isolated(15800, 16800) failed
[  247.192945] cma: dma_alloc_from_contiguous(): memory range at c0986000 is busy, retrying
[  247.201353] alloc_contig_range test_pages_isolated(15800, 16900) failed
[  247.207970] cma: dma_alloc_from_contiguous(): memory range at c0988000 is busy, retrying
[  247.216369] alloc_contig_range test_pages_isolated(15800, 16a00) failed
[  247.222984] cma: dma_alloc_from_contiguous(): memory range at c098a000 is busy, retrying
[  247.231392] alloc_contig_range test_pages_isolated(15800, 16b00) failed
[  247.238008] cma: dma_alloc_from_contiguous(): memory range at c098c000 is busy, retrying
[  247.246403] alloc_contig_range test_pages_isolated(15c00, 16c00) failed
[  247.253020] cma: dma_alloc_from_contiguous(): memory range at c098e000 is busy, retrying
[  247.261521] alloc_contig_range test_pages_isolated(15c00, 16d00) failed
[  247.268139] cma: dma_alloc_from_contiguous(): memory range at c0990000 is busy, retrying
[  247.276550] alloc_contig_range test_pages_isolated(15c00, 16e00) failed
[  247.283153] cma: dma_alloc_from_contiguous(): memory range at c0992000 is busy, retrying
[  247.291568] alloc_contig_range test_pages_isolated(15c00, 16f00) failed
[  247.298192] cma: dma_alloc_from_contiguous(): memory range at c0994000 is busy, retrying
[  247.306603] alloc_contig_range test_pages_isolated(16000, 17000) failed
[  247.313204] cma: dma_alloc_from_contiguous(): memory range at c0996000 is busy, retrying
[  247.321614] alloc_contig_range test_pages_isolated(16000, 17100) failed
[  247.328229] cma: dma_alloc_from_contiguous(): memory range at c0998000 is busy, retrying
[  247.336643] alloc_contig_range test_pages_isolated(16000, 17200) failed
[  247.343244] cma: dma_alloc_from_contiguous(): memory range at c099a000 is busy, retrying
[  247.351677] alloc_contig_range test_pages_isolated(16000, 17300) failed
[  247.358437] cma: dma_alloc_from_contiguous(): memory range at c099c000 is busy, retrying
[  247.366863] alloc_contig_range test_pages_isolated(16400, 17400) failed
[  247.373464] cma: dma_alloc_from_contiguous(): memory range at c099e000 is busy, retrying
[  247.381897] alloc_contig_range test_pages_isolated(16400, 17500) failed
[  247.388514] cma: dma_alloc_from_contiguous(): memory range at c09a0000 is busy, retrying
[  247.396933] alloc_contig_range test_pages_isolated(16400, 17600) failed
[  247.403534] cma: dma_alloc_from_contiguous(): memory range at c09a2000 is busy, retrying
[  247.411949] alloc_contig_range test_pages_isolated(16400, 17700) failed
[  247.418564] cma: dma_alloc_from_contiguous(): memory range at c09a4000 is busy, retrying
[  247.426975] alloc_contig_range test_pages_isolated(16800, 17800) failed
[  247.433575] cma: dma_alloc_from_contiguous(): memory range at c09a6000 is busy, retrying
[  247.441990] alloc_contig_range test_pages_isolated(16800, 17900) failed
[  247.448606] cma: dma_alloc_from_contiguous(): memory range at c09a8000 is busy, retrying
[  247.457154] alloc_contig_range test_pages_isolated(16800, 17a00) failed
[  247.463756] cma: dma_alloc_from_contiguous(): memory range at c09aa000 is busy, retrying
[  247.472168] alloc_contig_range test_pages_isolated(16800, 17b00) failed
[  247.478783] cma: dma_alloc_from_contiguous(): memory range at c09ac000 is busy, retrying
[  247.487189] alloc_contig_range test_pages_isolated(16c00, 17c00) failed
[  247.493791] cma: dma_alloc_from_contiguous(): memory range at c09ae000 is busy, retrying
[  247.502206] alloc_contig_range test_pages_isolated(16c00, 17d00) failed
[  247.508820] cma: dma_alloc_from_contiguous(): memory range at c09b0000 is busy, retrying
[  247.517230] alloc_contig_range test_pages_isolated(16c00, 17e00) failed
[  247.523831] cma: dma_alloc_from_contiguous(): memory range at c09b2000 is busy, retrying
[  247.532244] alloc_contig_range test_pages_isolated(16c00, 17f00) failed
[  247.538858] cma: dma_alloc_from_contiguous(): memory range at c09b4000 is busy, retrying
[  247.547267] alloc_contig_range test_pages_isolated(17000, 18000) failed
[  247.553869] cma: dma_alloc_from_contiguous(): memory range at c09b6000 is busy, retrying
[  247.562419] alloc_contig_range test_pages_isolated(17000, 18100) failed
[  247.569035] cma: dma_alloc_from_contiguous(): memory range at c09b8000 is busy, retrying
[  247.577446] alloc_contig_range test_pages_isolated(17000, 18200) failed
[  247.584048] cma: dma_alloc_from_contiguous(): memory range at c09ba000 is busy, retrying
[  247.592461] alloc_contig_range test_pages_isolated(17000, 18300) failed
[  247.599076] cma: dma_alloc_from_contiguous(): memory range at c09bc000 is busy, retrying
[  247.607485] alloc_contig_range test_pages_isolated(17400, 18400) failed
[  247.614085] cma: dma_alloc_from_contiguous(): memory range at c09be000 is busy, retrying
[  247.622497] alloc_contig_range test_pages_isolated(17400, 18500) failed
[  247.629112] cma: dma_alloc_from_contiguous(): memory range at c09c0000 is busy, retrying
[  247.637522] alloc_contig_range test_pages_isolated(17400, 18600) failed
[  247.644123] cma: dma_alloc_from_contiguous(): memory range at c09c2000 is busy, retrying
[  247.652554] alloc_contig_range test_pages_isolated(17400, 18700) failed
[  247.659292] cma: dma_alloc_from_contiguous(): memory range at c09c4000 is busy, retrying
[  247.667715] alloc_contig_range test_pages_isolated(17800, 18800) failed
[  247.674317] cma: dma_alloc_from_contiguous(): memory range at c09c6000 is busy, retrying
[  247.682727] alloc_contig_range test_pages_isolated(17800, 18900) failed
[  247.689342] cma: dma_alloc_from_contiguous(): memory range at c09c8000 is busy, retrying
[  247.697756] alloc_contig_range test_pages_isolated(17800, 18a00) failed
[  247.704357] cma: dma_alloc_from_contiguous(): memory range at c09ca000 is busy, retrying
[  247.712767] alloc_contig_range test_pages_isolated(17800, 18b00) failed
[  247.719382] cma: dma_alloc_from_contiguous(): memory range at c09cc000 is busy, retrying
[  247.727791] alloc_contig_range test_pages_isolated(17c00, 18c00) failed
[  247.734392] cma: dma_alloc_from_contiguous(): memory range at c09ce000 is busy, retrying
[  247.742805] alloc_contig_range test_pages_isolated(17c00, 18d00) failed
[  247.749419] cma: dma_alloc_from_contiguous(): memory range at c09d0000 is busy, retrying
[  247.757993] alloc_contig_range test_pages_isolated(17c00, 18e00) failed
[  247.764596] cma: dma_alloc_from_contiguous(): memory range at c09d2000 is busy, retrying
[  247.773012] alloc_contig_range test_pages_isolated(17c00, 18f00) failed
[  247.779627] cma: dma_alloc_from_contiguous(): memory range at c09d4000 is busy, retrying
[  247.788036] alloc_contig_range test_pages_isolated(18000, 19000) failed
[  247.794636] cma: dma_alloc_from_contiguous(): memory range at c09d6000 is busy, retrying
[  247.803049] alloc_contig_range test_pages_isolated(18000, 19100) failed
[  247.809663] cma: dma_alloc_from_contiguous(): memory range at c09d8000 is busy, retrying
[  247.818071] alloc_contig_range test_pages_isolated(18000, 19200) failed
[  247.824672] cma: dma_alloc_from_contiguous(): memory range at c09da000 is busy, retrying
[  247.833087] alloc_contig_range test_pages_isolated(18000, 19300) failed
[  247.839702] cma: dma_alloc_from_contiguous(): memory range at c09dc000 is busy, retrying
[  247.848110] alloc_contig_range test_pages_isolated(18400, 19400) failed
[  247.854710] cma: dma_alloc_from_contiguous(): memory range at c09de000 is busy, retrying
[  247.863199] alloc_contig_range test_pages_isolated(18400, 19500) failed
[  247.869816] cma: dma_alloc_from_contiguous(): memory range at c09e0000 is busy, retrying
[  247.878224] alloc_contig_range test_pages_isolated(18400, 19600) failed
[  247.884827] cma: dma_alloc_from_contiguous(): memory range at c09e2000 is busy, retrying
[  247.893235] alloc_contig_range test_pages_isolated(18400, 19700) failed
[  247.899858] cma: dma_alloc_from_contiguous(): memory range at c09e4000 is busy, retrying
[  247.908265] alloc_contig_range test_pages_isolated(18800, 19800) failed
[  247.914866] cma: dma_alloc_from_contiguous(): memory range at c09e6000 is busy, retrying
[  247.923278] alloc_contig_range test_pages_isolated(18800, 19900) failed
[  247.929895] cma: dma_alloc_from_contiguous(): memory range at c09e8000 is busy, retrying
[  247.938305] alloc_contig_range test_pages_isolated(18800, 19a00) failed
[  247.944907] cma: dma_alloc_from_contiguous(): memory range at c09ea000 is busy, retrying
[  247.953333] alloc_contig_range test_pages_isolated(18800, 19b00) failed
[  247.960080] cma: dma_alloc_from_contiguous(): memory range at c09ec000 is busy, retrying
[  247.968498] alloc_contig_range test_pages_isolated(18c00, 19c00) failed
[  247.975099] cma: dma_alloc_from_contiguous(): memory range at c09ee000 is busy, retrying
[  247.983508] alloc_contig_range test_pages_isolated(18c00, 19d00) failed
[  247.990122] cma: dma_alloc_from_contiguous(): memory range at c09f0000 is busy, retrying
[  247.998533] alloc_contig_range test_pages_isolated(18c00, 19e00) failed
[  248.005135] cma: dma_alloc_from_contiguous(): memory range at c09f2000 is busy, retrying
[  248.013548] alloc_contig_range test_pages_isolated(18c00, 19f00) failed
[  248.020542] cma: dma_alloc_from_contiguous(): memory range at c09f4000 is busy, retrying
[  248.028973] alloc_contig_range test_pages_isolated(19000, 1a000) failed
[  248.035576] cma: dma_alloc_from_contiguous(): memory range at c09f6000 is busy, retrying
[  248.043991] alloc_contig_range test_pages_isolated(19000, 1a100) failed
[  248.050606] cma: dma_alloc_from_contiguous(): memory range at c09f8000 is busy, retrying
[  248.059114] alloc_contig_range test_pages_isolated(19000, 1a200) failed
[  248.065716] cma: dma_alloc_from_contiguous(): memory range at c09fa000 is busy, retrying
[  248.074129] alloc_contig_range test_pages_isolated(19000, 1a300) failed
[  248.080744] cma: dma_alloc_from_contiguous(): memory range at c09fc000 is busy, retrying
[  248.089153] alloc_contig_range test_pages_isolated(19400, 1a400) failed
[  248.095753] cma: dma_alloc_from_contiguous(): memory range at c09fe000 is busy, retrying
[  248.104176] alloc_contig_range test_pages_isolated(19400, 1a500) failed
[  248.110792] cma: dma_alloc_from_contiguous(): memory range at c0a00000 is busy, retrying
[  248.119202] alloc_contig_range test_pages_isolated(19400, 1a600) failed
[  248.125803] cma: dma_alloc_from_contiguous(): memory range at c0a02000 is busy, retrying
[  248.134207] alloc_contig_range test_pages_isolated(19400, 1a700) failed
[  248.140822] cma: dma_alloc_from_contiguous(): memory range at c0a04000 is busy, retrying
[  248.149224] alloc_contig_range test_pages_isolated(19800, 1a800) failed
[  248.155825] cma: dma_alloc_from_contiguous(): memory range at c0a06000 is busy, retrying
[  248.164459] alloc_contig_range test_pages_isolated(19800, 1a900) failed
[  248.171076] cma: dma_alloc_from_contiguous(): memory range at c0a08000 is busy, retrying
[  248.179482] alloc_contig_range test_pages_isolated(19800, 1aa00) failed
[  248.186085] cma: dma_alloc_from_contiguous(): memory range at c0a0a000 is busy, retrying
[  248.194499] alloc_contig_range test_pages_isolated(19800, 1ab00) failed
[  248.201114] cma: dma_alloc_from_contiguous(): memory range at c0a0c000 is busy, retrying
[  248.209522] alloc_contig_range test_pages_isolated(19c00, 1ac00) failed
[  248.216124] cma: dma_alloc_from_contiguous(): memory range at c0a0e000 is busy, retrying
[  248.224538] alloc_contig_range test_pages_isolated(19c00, 1ad00) failed
[  248.231151] cma: dma_alloc_from_contiguous(): memory range at c0a10000 is busy, retrying
[  248.239562] alloc_contig_range test_pages_isolated(19c00, 1ae00) failed
[  248.246164] cma: dma_alloc_from_contiguous(): memory range at c0a12000 is busy, retrying
[  248.254596] alloc_contig_range test_pages_isolated(19c00, 1af00) failed
[  248.261293] cma: dma_alloc_from_contiguous(): memory range at c0a14000 is busy, retrying
[  248.269718] alloc_contig_range test_pages_isolated(1a000, 1b000) failed
[  248.276319] cma: dma_alloc_from_contiguous(): memory range at c0a16000 is busy, retrying
[  248.284730] alloc_contig_range test_pages_isolated(1a000, 1b100) failed
[  248.291345] cma: dma_alloc_from_contiguous(): memory range at c0a18000 is busy, retrying
[  248.299763] alloc_contig_range test_pages_isolated(1a000, 1b200) failed
[  248.306364] cma: dma_alloc_from_contiguous(): memory range at c0a1a000 is busy, retrying
[  248.314777] alloc_contig_range test_pages_isolated(1a000, 1b300) failed
[  248.321391] cma: dma_alloc_from_contiguous(): memory range at c0a1c000 is busy, retrying
[  248.329797] alloc_contig_range test_pages_isolated(1a400, 1b400) failed
[  248.336397] cma: dma_alloc_from_contiguous(): memory range at c0a1e000 is busy, retrying
[  248.344805] alloc_contig_range test_pages_isolated(1a400, 1b500) failed
[  248.351420] cma: dma_alloc_from_contiguous(): memory range at c0a20000 is busy, retrying
[  248.359996] alloc_contig_range test_pages_isolated(1a400, 1b600) failed
[  248.366612] cma: dma_alloc_from_contiguous(): memory range at c0a22000 is busy, retrying
[  248.375011] alloc_contig_range test_pages_isolated(1a400, 1b700) failed
[  248.381629] cma: dma_alloc_from_contiguous(): memory range at c0a24000 is busy, retrying
[  248.390036] alloc_contig_range test_pages_isolated(1a800, 1b800) failed
[  248.396651] cma: dma_alloc_from_contiguous(): memory range at c0a26000 is busy, retrying
[  248.405043] alloc_contig_range test_pages_isolated(1a800, 1b900) failed
[  248.411659] cma: dma_alloc_from_contiguous(): memory range at c0a28000 is busy, retrying
[  248.420068] alloc_contig_range test_pages_isolated(1a800, 1ba00) failed
[  248.426686] cma: dma_alloc_from_contiguous(): memory range at c0a2a000 is busy, retrying
[  248.435082] alloc_contig_range test_pages_isolated(1a800, 1bb00) failed
[  248.441698] cma: dma_alloc_from_contiguous(): memory range at c0a2c000 is busy, retrying
[  248.450103] alloc_contig_range test_pages_isolated(1ac00, 1bc00) failed
[  248.456835] cma: dma_alloc_from_contiguous(): memory range at c0a2e000 is busy, retrying
[  248.465240] alloc_contig_range test_pages_isolated(1ac00, 1bd00) failed
[  248.471856] cma: dma_alloc_from_contiguous(): memory range at c0a30000 is busy, retrying
[  248.480265] alloc_contig_range test_pages_isolated(1ac00, 1be00) failed
[  248.486883] cma: dma_alloc_from_contiguous(): memory range at c0a32000 is busy, retrying
[  248.495282] alloc_contig_range test_pages_isolated(1ac00, 1bf00) failed
[  248.501907] cma: dma_alloc_from_contiguous(): memory range at c0a34000 is busy, retrying
[  248.510316] alloc_contig_range test_pages_isolated(1b000, 1c000) failed
[  248.516930] cma: dma_alloc_from_contiguous(): memory range at c0a36000 is busy, retrying
[  248.525329] alloc_contig_range test_pages_isolated(1b000, 1c100) failed
[  248.531945] cma: dma_alloc_from_contiguous(): memory range at c0a38000 is busy, retrying
[  248.540355] alloc_contig_range test_pages_isolated(1b000, 1c200) failed
[  248.546991] cma: dma_alloc_from_contiguous(): memory range at c0a3a000 is busy, retrying
[  248.555391] alloc_contig_range test_pages_isolated(1b000, 1c300) failed
[  248.562139] cma: dma_alloc_from_contiguous(): memory range at c0a3c000 is busy, retrying
[  248.570558] alloc_contig_range test_pages_isolated(1b400, 1c400) failed
[  248.577174] cma: dma_alloc_from_contiguous(): memory range at c0a3e000 is busy, retrying
[  248.585570] alloc_contig_range test_pages_isolated(1b400, 1c500) failed
[  248.592186] cma: dma_alloc_from_contiguous(): memory range at c0a40000 is busy, retrying
[  248.600591] alloc_contig_range test_pages_isolated(1b400, 1c600) failed
[  248.607208] cma: dma_alloc_from_contiguous(): memory range at c0a42000 is busy, retrying
[  248.615606] alloc_contig_range test_pages_isolated(1b400, 1c700) failed
[  248.622222] cma: dma_alloc_from_contiguous(): memory range at c0a44000 is busy, retrying
[  248.630628] alloc_contig_range test_pages_isolated(1b800, 1c800) failed
[  248.637245] cma: dma_alloc_from_contiguous(): memory range at c0a46000 is busy, retrying
[  248.645643] alloc_contig_range test_pages_isolated(1b800, 1c900) failed
[  248.652260] cma: dma_alloc_from_contiguous(): memory range at c0a48000 is busy, retrying
[  248.660752] alloc_contig_range test_pages_isolated(1b800, 1ca00) failed
[  248.667375] cma: dma_alloc_from_contiguous(): memory range at c0a4a000 is busy, retrying
[  248.675777] alloc_contig_range test_pages_isolated(1b800, 1cb00) failed
[  248.682396] cma: dma_alloc_from_contiguous(): memory range at c0a4c000 is busy, retrying
[  248.690804] alloc_contig_range test_pages_isolated(1bc00, 1cc00) failed
[  248.697442] cma: dma_alloc_from_contiguous(): memory range at c0a4e000 is busy, retrying
[  248.705905] alloc_contig_range test_pages_isolated(1bc00, 1cd00) failed
[  248.712523] cma: dma_alloc_from_contiguous(): memory range at c0a50000 is busy, retrying
[  248.720938] alloc_contig_range test_pages_isolated(1bc00, 1ce00) failed
[  248.727559] cma: dma_alloc_from_contiguous(): memory range at c0a52000 is busy, retrying
[  248.735960] alloc_contig_range test_pages_isolated(1bc00, 1cf00) failed
[  248.742580] cma: dma_alloc_from_contiguous(): memory range at c0a54000 is busy, retrying
[  248.750995] alloc_contig_range test_pages_isolated(1c000, 1d000) failed
[  248.757776] cma: dma_alloc_from_contiguous(): memory range at c0a56000 is busy, retrying
[  248.766183] alloc_contig_range test_pages_isolated(1c000, 1d100) failed
[  248.772800] cma: dma_alloc_from_contiguous(): memory range at c0a58000 is busy, retrying
[  248.781211] alloc_contig_range test_pages_isolated(1c000, 1d200) failed
[  248.787827] cma: dma_alloc_from_contiguous(): memory range at c0a5a000 is busy, retrying
[  248.796226] alloc_contig_range test_pages_isolated(1c000, 1d300) failed
[  248.802843] cma: dma_alloc_from_contiguous(): memory range at c0a5c000 is busy, retrying
[  248.811248] alloc_contig_range test_pages_isolated(1c400, 1d400) failed
[  248.817865] cma: dma_alloc_from_contiguous(): memory range at c0a5e000 is busy, retrying
[  248.826263] alloc_contig_range test_pages_isolated(1c400, 1d500) failed
[  248.832881] cma: dma_alloc_from_contiguous(): memory range at c0a60000 is busy, retrying
[  248.841291] alloc_contig_range test_pages_isolated(1c400, 1d600) failed
[  248.847928] cma: dma_alloc_from_contiguous(): memory range at c0a62000 is busy, retrying
[  248.856325] alloc_contig_range test_pages_isolated(1c400, 1d700) failed
[  248.863054] cma: dma_alloc_from_contiguous(): memory range at c0a64000 is busy, retrying
[  248.871485] alloc_contig_range test_pages_isolated(1c800, 1d800) failed
[  248.878104] cma: dma_alloc_from_contiguous(): memory range at c0a66000 is busy, retrying
[  248.886512] alloc_contig_range test_pages_isolated(1c800, 1d900) failed
[  248.893113] cma: dma_alloc_from_contiguous(): memory range at c0a68000 is busy, retrying
[  248.901538] alloc_contig_range test_pages_isolated(1c800, 1da00) failed
[  248.908154] cma: dma_alloc_from_contiguous(): memory range at c0a6a000 is busy, retrying
[  248.916568] alloc_contig_range test_pages_isolated(1c800, 1db00) failed
[  248.923169] cma: dma_alloc_from_contiguous(): memory range at c0a6c000 is busy, retrying
[  248.931583] alloc_contig_range test_pages_isolated(1cc00, 1dc00) failed
[  248.938197] cma: dma_alloc_from_contiguous(): memory range at c0a6e000 is busy, retrying
[  248.946603] alloc_contig_range test_pages_isolated(1cc00, 1dd00) failed
[  248.953206] cma: dma_alloc_from_contiguous(): memory range at c0a70000 is busy, retrying
[  248.961807] alloc_contig_range test_pages_isolated(1cc00, 1de00) failed
[  248.968424] cma: dma_alloc_from_contiguous(): memory range at c0a72000 is busy, retrying
[  248.976837] alloc_contig_range test_pages_isolated(1cc00, 1df00) failed
[  248.983439] cma: dma_alloc_from_contiguous(): memory range at c0a74000 is busy, retrying
[  248.991851] alloc_contig_range test_pages_isolated(1d000, 1e000) failed
[  248.998464] cma: dma_alloc_from_contiguous(): memory range at c0a76000 is busy, retrying
[  249.006872] alloc_contig_range test_pages_isolated(1d000, 1e100) failed
[  249.013473] cma: dma_alloc_from_contiguous(): memory range at c0a78000 is busy, retrying
[  249.021902] alloc_contig_range test_pages_isolated(1d000, 1e200) failed
[  249.028517] cma: dma_alloc_from_contiguous(): memory range at c0a7a000 is busy, retrying
[  249.036927] alloc_contig_range test_pages_isolated(1d000, 1e300) failed
[  249.043529] cma: dma_alloc_from_contiguous(): memory range at c0a7c000 is busy, retrying
[  249.051939] alloc_contig_range test_pages_isolated(1d400, 1e400) failed
[  249.058755] cma: dma_alloc_from_contiguous(): memory range at c0a7e000 is busy, retrying
[  249.067180] alloc_contig_range test_pages_isolated(1d400, 1e500) failed
[  249.073781] cma: dma_alloc_from_contiguous(): memory range at c0a80000 is busy, retrying
[  249.082197] alloc_contig_range test_pages_isolated(1d400, 1e600) failed
[  249.088811] cma: dma_alloc_from_contiguous(): memory range at c0a82000 is busy, retrying
[  249.097230] alloc_contig_range test_pages_isolated(1d400, 1e700) failed
[  249.103832] cma: dma_alloc_from_contiguous(): memory range at c0a84000 is busy, retrying
[  249.112240] alloc_contig_range test_pages_isolated(1d800, 1e800) failed
[  249.118855] cma: dma_alloc_from_contiguous(): memory range at c0a86000 is busy, retrying
[  249.127266] alloc_contig_range test_pages_isolated(1d800, 1e900) failed
[  249.133868] cma: dma_alloc_from_contiguous(): memory range at c0a88000 is busy, retrying
[  249.142278] alloc_contig_range test_pages_isolated(1d800, 1ea00) failed
[  249.148911] cma: dma_alloc_from_contiguous(): memory range at c0a8a000 is busy, retrying
[  249.157398] alloc_contig_range test_pages_isolated(1d800, 1eb00) failed
[  249.164000] cma: dma_alloc_from_contiguous(): memory range at c0a8c000 is busy, retrying
[  249.172412] alloc_contig_range test_pages_isolated(1dc00, 1ec00) failed
[  249.179025] cma: dma_alloc_from_contiguous(): memory range at c0a8e000 is busy, retrying
[  249.187429] alloc_contig_range test_pages_isolated(1dc00, 1ed00) failed
[  249.194030] cma: dma_alloc_from_contiguous(): memory range at c0a90000 is busy, retrying
[  249.202444] alloc_contig_range test_pages_isolated(1dc00, 1ee00) failed
[  249.209059] cma: dma_alloc_from_contiguous(): memory range at c0a92000 is busy, retrying
[  249.217469] alloc_contig_range test_pages_isolated(1dc00, 1ef00) failed
[  249.224072] cma: dma_alloc_from_contiguous(): memory range at c0a94000 is busy, retrying
[  249.232481] alloc_contig_range test_pages_isolated(1e000, 1f000) failed
[  249.239092] cma: dma_alloc_from_contiguous(): memory range at c0a96000 is busy, retrying
[  249.247503] alloc_contig_range test_pages_isolated(1e000, 1f100) failed
[  249.254105] cma: dma_alloc_from_contiguous(): memory range at c0a98000 is busy, retrying
[  249.262657] alloc_contig_range test_pages_isolated(1e000, 1f200) failed
[  249.269272] cma: dma_alloc_from_contiguous(): memory range at c0a9a000 is busy, retrying
[  249.277683] alloc_contig_range test_pages_isolated(1e000, 1f300) failed
[  249.284285] cma: dma_alloc_from_contiguous(): memory range at c0a9c000 is busy, retrying
[  249.292695] alloc_contig_range test_pages_isolated(1e400, 1f400) failed
[  249.299317] cma: dma_alloc_from_contiguous(): memory range at c0a9e000 is busy, retrying
[  249.307722] alloc_contig_range test_pages_isolated(1e400, 1f500) failed
[  249.314323] cma: dma_alloc_from_contiguous(): memory range at c0aa0000 is busy, retrying
[  249.322737] alloc_contig_range test_pages_isolated(1e400, 1f600) failed
[  249.329352] cma: dma_alloc_from_contiguous(): memory range at c0aa2000 is busy, retrying
[  249.337761] alloc_contig_range test_pages_isolated(1e400, 1f700) failed
[  249.344362] cma: dma_alloc_from_contiguous(): memory range at c0aa4000 is busy, retrying
[  249.352773] alloc_contig_range test_pages_isolated(1e800, 1f800) failed
[  249.359455] cma: dma_alloc_from_contiguous(): memory range at c0aa6000 is busy, retrying
[  249.367539] cma: dma_alloc_from_contiguous(): returned   (null)
[  249.373444] failed to allocate 16777216 bytes
[  249.377799] cma: dma_alloc_from_contiguous(cma cf473fc0, count 8192, align 8)
[  249.386092] alloc_contig_range test_pages_isolated(fc00, 11c00) failed
[  249.392630] cma: dma_alloc_from_contiguous(): memory range at c08ce000 is busy, retrying
[  249.401361] alloc_contig_range test_pages_isolated(fc00, 11d00) failed
[  249.407895] cma: dma_alloc_from_contiguous(): memory range at c08d0000 is busy, retrying
[  249.416576] alloc_contig_range test_pages_isolated(fc00, 11e00) failed
[  249.423095] cma: dma_alloc_from_contiguous(): memory range at c08d2000 is busy, retrying
[  249.431773] alloc_contig_range test_pages_isolated(fc00, 11f00) failed
[  249.438304] cma: dma_alloc_from_contiguous(): memory range at c08d4000 is busy, retrying
[  249.446999] alloc_contig_range test_pages_isolated(10000, 12000) failed
[  249.453604] cma: dma_alloc_from_contiguous(): memory range at c08d6000 is busy, retrying
[  249.462563] alloc_contig_range test_pages_isolated(10000, 12100) failed
[  249.469183] cma: dma_alloc_from_contiguous(): memory range at c08d8000 is busy, retrying
[  249.477869] alloc_contig_range test_pages_isolated(10000, 12200) failed
[  249.484474] cma: dma_alloc_from_contiguous(): memory range at c08da000 is busy, retrying
[  249.493152] alloc_contig_range test_pages_isolated(10000, 12300) failed
[  249.499778] cma: dma_alloc_from_contiguous(): memory range at c08dc000 is busy, retrying
[  249.508447] alloc_contig_range test_pages_isolated(10400, 12400) failed
[  249.515051] cma: dma_alloc_from_contiguous(): memory range at c08de000 is busy, retrying
[  249.523725] alloc_contig_range test_pages_isolated(10400, 12500) failed
[  249.530342] cma: dma_alloc_from_contiguous(): memory range at c08e0000 is busy, retrying
[  249.539020] alloc_contig_range test_pages_isolated(10400, 12600) failed
[  249.545624] cma: dma_alloc_from_contiguous(): memory range at c08e2000 is busy, retrying
[  249.554302] alloc_contig_range test_pages_isolated(10400, 12700) failed
[  249.561032] cma: dma_alloc_from_contiguous(): memory range at c08e4000 is busy, retrying
[  249.569731] alloc_contig_range test_pages_isolated(10800, 12800) failed
[  249.576335] cma: dma_alloc_from_contiguous(): memory range at c08e6000 is busy, retrying
[  249.585012] alloc_contig_range test_pages_isolated(10800, 12900) failed
[  249.591632] cma: dma_alloc_from_contiguous(): memory range at c08e8000 is busy, retrying
[  249.600316] alloc_contig_range test_pages_isolated(10800, 12a00) failed
[  249.606935] cma: dma_alloc_from_contiguous(): memory range at c08ea000 is busy, retrying
[  249.615595] alloc_contig_range test_pages_isolated(10800, 12b00) failed
[  249.622216] cma: dma_alloc_from_contiguous(): memory range at c08ec000 is busy, retrying
[  249.630893] alloc_contig_range test_pages_isolated(10c00, 12c00) failed
[  249.637512] cma: dma_alloc_from_contiguous(): memory range at c08ee000 is busy, retrying
[  249.646176] alloc_contig_range test_pages_isolated(10c00, 12d00) failed
[  249.652797] cma: dma_alloc_from_contiguous(): memory range at c08f0000 is busy, retrying
[  249.661668] alloc_contig_range test_pages_isolated(10c00, 12e00) failed
[  249.668289] cma: dma_alloc_from_contiguous(): memory range at c08f2000 is busy, retrying
[  249.676964] alloc_contig_range test_pages_isolated(10c00, 12f00) failed
[  249.683568] cma: dma_alloc_from_contiguous(): memory range at c08f4000 is busy, retrying
[  249.692240] alloc_contig_range test_pages_isolated(11000, 13000) failed
[  249.698864] cma: dma_alloc_from_contiguous(): memory range at c08f6000 is busy, retrying
[  249.707536] alloc_contig_range test_pages_isolated(11000, 13100) failed
[  249.714142] cma: dma_alloc_from_contiguous(): memory range at c08f8000 is busy, retrying
[  249.722815] alloc_contig_range test_pages_isolated(11000, 13200) failed
[  249.729432] cma: dma_alloc_from_contiguous(): memory range at c08fa000 is busy, retrying
[  249.738106] alloc_contig_range test_pages_isolated(11000, 13300) failed
[  249.744711] cma: dma_alloc_from_contiguous(): memory range at c08fc000 is busy, retrying
[  249.753403] alloc_contig_range test_pages_isolated(11400, 13400) failed
[  249.760190] cma: dma_alloc_from_contiguous(): memory range at c08fe000 is busy, retrying
[  249.768882] alloc_contig_range test_pages_isolated(11400, 13500) failed
[  249.775487] cma: dma_alloc_from_contiguous(): memory range at c0900000 is busy, retrying
[  249.784164] alloc_contig_range test_pages_isolated(11400, 13600) failed
[  249.790781] cma: dma_alloc_from_contiguous(): memory range at c0902000 is busy, retrying
[  249.799459] alloc_contig_range test_pages_isolated(11400, 13700) failed
[  249.806064] cma: dma_alloc_from_contiguous(): memory range at c0904000 is busy, retrying
[  249.814739] alloc_contig_range test_pages_isolated(11800, 13800) failed
[  249.821356] cma: dma_alloc_from_contiguous(): memory range at c0906000 is busy, retrying
[  249.830028] alloc_contig_range test_pages_isolated(11800, 13900) failed
[  249.836646] cma: dma_alloc_from_contiguous(): memory range at c0908000 is busy, retrying
[  249.845313] alloc_contig_range test_pages_isolated(11800, 13a00) failed
[  249.851932] cma: dma_alloc_from_contiguous(): memory range at c090a000 is busy, retrying
[  249.860793] alloc_contig_range test_pages_isolated(11800, 13b00) failed
[  249.867415] cma: dma_alloc_from_contiguous(): memory range at c090c000 is busy, retrying
[  249.876080] alloc_contig_range test_pages_isolated(11c00, 13c00) failed
[  249.882698] cma: dma_alloc_from_contiguous(): memory range at c090e000 is busy, retrying
[  249.891380] alloc_contig_range test_pages_isolated(11c00, 13d00) failed
[  249.898007] cma: dma_alloc_from_contiguous(): memory range at c0910000 is busy, retrying
[  249.906682] alloc_contig_range test_pages_isolated(11c00, 13e00) failed
[  249.913287] cma: dma_alloc_from_contiguous(): memory range at c0912000 is busy, retrying
[  249.921963] alloc_contig_range test_pages_isolated(11c00, 13f00) failed
[  249.928580] cma: dma_alloc_from_contiguous(): memory range at c0914000 is busy, retrying
[  249.937257] alloc_contig_range test_pages_isolated(12000, 14000) failed
[  249.943862] cma: dma_alloc_from_contiguous(): memory range at c0916000 is busy, retrying
[  249.952538] alloc_contig_range test_pages_isolated(12000, 14100) failed
[  249.959363] cma: dma_alloc_from_contiguous(): memory range at c0918000 is busy, retrying
[  249.968057] alloc_contig_range test_pages_isolated(12000, 14200) failed
[  249.974662] cma: dma_alloc_from_contiguous(): memory range at c091a000 is busy, retrying
[  249.983347] alloc_contig_range test_pages_isolated(12000, 14300) failed
[  249.989964] cma: dma_alloc_from_contiguous(): memory range at c091c000 is busy, retrying
[  249.998636] alloc_contig_range test_pages_isolated(12400, 14400) failed
[  250.005240] cma: dma_alloc_from_contiguous(): memory range at c091e000 is busy, retrying
[  250.013913] alloc_contig_range test_pages_isolated(12400, 14500) failed
[  250.020691] cma: dma_alloc_from_contiguous(): memory range at c0920000 is busy, retrying
[  250.029394] alloc_contig_range test_pages_isolated(12400, 14600) failed
[  250.035999] cma: dma_alloc_from_contiguous(): memory range at c0922000 is busy, retrying
[  250.044678] alloc_contig_range test_pages_isolated(12400, 14700) failed
[  250.051314] cma: dma_alloc_from_contiguous(): memory range at c0924000 is busy, retrying
[  250.060198] alloc_contig_range test_pages_isolated(12800, 14800) failed
[  250.066822] cma: dma_alloc_from_contiguous(): memory range at c0926000 is busy, retrying
[  250.075485] alloc_contig_range test_pages_isolated(12800, 14900) failed
[  250.082106] cma: dma_alloc_from_contiguous(): memory range at c0928000 is busy, retrying
[  250.090782] alloc_contig_range test_pages_isolated(12800, 14a00) failed
[  250.097413] cma: dma_alloc_from_contiguous(): memory range at c092a000 is busy, retrying
[  250.106074] alloc_contig_range test_pages_isolated(12800, 14b00) failed
[  250.112695] cma: dma_alloc_from_contiguous(): memory range at c092c000 is busy, retrying
[  250.121364] alloc_contig_range test_pages_isolated(12c00, 14c00) failed
[  250.127985] cma: dma_alloc_from_contiguous(): memory range at c092e000 is busy, retrying
[  250.136656] alloc_contig_range test_pages_isolated(12c00, 14d00) failed
[  250.143261] cma: dma_alloc_from_contiguous(): memory range at c0930000 is busy, retrying
[  250.151939] alloc_contig_range test_pages_isolated(12c00, 14e00) failed
[  250.158644] cma: dma_alloc_from_contiguous(): memory range at c0932000 is busy, retrying
[  250.167335] alloc_contig_range test_pages_isolated(12c00, 14f00) failed
[  250.173939] cma: dma_alloc_from_contiguous(): memory range at c0934000 is busy, retrying
[  250.182615] alloc_contig_range test_pages_isolated(13000, 15000) failed
[  250.189233] cma: dma_alloc_from_contiguous(): memory range at c0936000 is busy, retrying
[  250.197909] alloc_contig_range test_pages_isolated(13000, 15100) failed
[  250.204513] cma: dma_alloc_from_contiguous(): memory range at c0938000 is busy, retrying
[  250.213188] alloc_contig_range test_pages_isolated(13000, 15200) failed
[  250.219805] cma: dma_alloc_from_contiguous(): memory range at c093a000 is busy, retrying
[  250.228476] alloc_contig_range test_pages_isolated(13000, 15300) failed
[  250.235082] cma: dma_alloc_from_contiguous(): memory range at c093c000 is busy, retrying
[  250.243752] alloc_contig_range test_pages_isolated(13400, 15400) failed
[  250.250367] cma: dma_alloc_from_contiguous(): memory range at c093e000 is busy, retrying
[  250.259254] alloc_contig_range test_pages_isolated(13400, 15500) failed
[  250.265859] cma: dma_alloc_from_contiguous(): memory range at c0940000 is busy, retrying
[  250.274539] alloc_contig_range test_pages_isolated(13400, 15600) failed
[  250.281157] cma: dma_alloc_from_contiguous(): memory range at c0942000 is busy, retrying
[  250.289830] alloc_contig_range test_pages_isolated(13400, 15700) failed
[  250.296455] cma: dma_alloc_from_contiguous(): memory range at c0944000 is busy, retrying
[  250.305116] alloc_contig_range test_pages_isolated(13800, 15800) failed
[  250.311735] cma: dma_alloc_from_contiguous(): memory range at c0946000 is busy, retrying
[  250.320404] alloc_contig_range test_pages_isolated(13800, 15900) failed
[  250.327023] cma: dma_alloc_from_contiguous(): memory range at c0948000 is busy, retrying
[  250.335683] alloc_contig_range test_pages_isolated(13800, 15a00) failed
[  250.342302] cma: dma_alloc_from_contiguous(): memory range at c094a000 is busy, retrying
[  250.350994] alloc_contig_range test_pages_isolated(13800, 15b00) failed
[  250.357849] cma: dma_alloc_from_contiguous(): memory range at c094c000 is busy, retrying
[  250.366541] alloc_contig_range test_pages_isolated(13c00, 15c00) failed
[  250.373146] cma: dma_alloc_from_contiguous(): memory range at c094e000 is busy, retrying
[  250.381862] alloc_contig_range test_pages_isolated(13c00, 15d00) failed
[  250.388480] cma: dma_alloc_from_contiguous(): memory range at c0950000 is busy, retrying
[  250.397168] alloc_contig_range test_pages_isolated(13c00, 15e00) failed
[  250.403773] cma: dma_alloc_from_contiguous(): memory range at c0952000 is busy, retrying
[  250.412451] alloc_contig_range test_pages_isolated(13c00, 15f00) failed
[  250.419069] cma: dma_alloc_from_contiguous(): memory range at c0954000 is busy, retrying
[  250.427736] alloc_contig_range test_pages_isolated(14000, 16000) failed
[  250.434341] cma: dma_alloc_from_contiguous(): memory range at c0956000 is busy, retrying
[  250.443024] alloc_contig_range test_pages_isolated(14000, 16100) failed
[  250.449642] cma: dma_alloc_from_contiguous(): memory range at c0958000 is busy, retrying
[  250.458427] alloc_contig_range test_pages_isolated(14000, 16200) failed
[  250.465032] cma: dma_alloc_from_contiguous(): memory range at c095a000 is busy, retrying
[  250.473717] alloc_contig_range test_pages_isolated(14000, 16300) failed
[  250.480334] cma: dma_alloc_from_contiguous(): memory range at c095c000 is busy, retrying
[  250.489009] alloc_contig_range test_pages_isolated(14400, 16400) failed
[  250.495612] cma: dma_alloc_from_contiguous(): memory range at c095e000 is busy, retrying
[  250.504295] alloc_contig_range test_pages_isolated(14400, 16500) failed
[  250.510913] cma: dma_alloc_from_contiguous(): memory range at c0960000 is busy, retrying
[  250.519584] alloc_contig_range test_pages_isolated(14400, 16600) failed
[  250.526188] cma: dma_alloc_from_contiguous(): memory range at c0962000 is busy, retrying
[  250.534863] alloc_contig_range test_pages_isolated(14400, 16700) failed
[  250.541481] cma: dma_alloc_from_contiguous(): memory range at c0964000 is busy, retrying
[  250.550147] alloc_contig_range test_pages_isolated(14800, 16800) failed
[  250.556936] cma: dma_alloc_from_contiguous(): memory range at c0966000 is busy, retrying
[  250.565619] alloc_contig_range test_pages_isolated(14800, 16900) failed
[  250.572240] cma: dma_alloc_from_contiguous(): memory range at c0968000 is busy, retrying
[  250.580911] alloc_contig_range test_pages_isolated(14800, 16a00) failed
[  250.587532] cma: dma_alloc_from_contiguous(): memory range at c096a000 is busy, retrying
[  250.596193] alloc_contig_range test_pages_isolated(14800, 16b00) failed
[  250.602813] cma: dma_alloc_from_contiguous(): memory range at c096c000 is busy, retrying
[  250.611486] alloc_contig_range test_pages_isolated(14c00, 16c00) failed
[  250.618106] cma: dma_alloc_from_contiguous(): memory range at c096e000 is busy, retrying
[  250.626775] alloc_contig_range test_pages_isolated(14c00, 16d00) failed
[  250.633381] cma: dma_alloc_from_contiguous(): memory range at c0970000 is busy, retrying
[  250.642055] alloc_contig_range test_pages_isolated(14c00, 16e00) failed
[  250.648693] cma: dma_alloc_from_contiguous(): memory range at c0972000 is busy, retrying
[  250.657533] alloc_contig_range test_pages_isolated(14c00, 16f00) failed
[  250.664138] cma: dma_alloc_from_contiguous(): memory range at c0974000 is busy, retrying
[  250.672816] alloc_contig_range test_pages_isolated(15000, 17000) failed
[  250.679433] cma: dma_alloc_from_contiguous(): memory range at c0976000 is busy, retrying
[  250.688104] alloc_contig_range test_pages_isolated(15000, 17100) failed
[  250.694709] cma: dma_alloc_from_contiguous(): memory range at c0978000 is busy, retrying
[  250.703392] alloc_contig_range test_pages_isolated(15000, 17200) failed
[  250.710010] cma: dma_alloc_from_contiguous(): memory range at c097a000 is busy, retrying
[  250.718680] alloc_contig_range test_pages_isolated(15000, 17300) failed
[  250.725284] cma: dma_alloc_from_contiguous(): memory range at c097c000 is busy, retrying
[  250.733959] alloc_contig_range test_pages_isolated(15400, 17400) failed
[  250.740576] cma: dma_alloc_from_contiguous(): memory range at c097e000 is busy, retrying
[  250.749246] alloc_contig_range test_pages_isolated(15400, 17500) failed
[  250.755850] cma: dma_alloc_from_contiguous(): memory range at c0980000 is busy, retrying
[  250.764695] alloc_contig_range test_pages_isolated(15400, 17600) failed
[  250.771314] cma: dma_alloc_from_contiguous(): memory range at c0982000 is busy, retrying
[  250.779989] alloc_contig_range test_pages_isolated(15400, 17700) failed
[  250.786606] cma: dma_alloc_from_contiguous(): memory range at c0984000 is busy, retrying
[  250.795272] alloc_contig_range test_pages_isolated(15800, 17800) failed
[  250.801890] cma: dma_alloc_from_contiguous(): memory range at c0986000 is busy, retrying
[  250.810561] alloc_contig_range test_pages_isolated(15800, 17900) failed
[  250.817180] cma: dma_alloc_from_contiguous(): memory range at c0988000 is busy, retrying
[  250.825844] alloc_contig_range test_pages_isolated(15800, 17a00) failed
[  250.832464] cma: dma_alloc_from_contiguous(): memory range at c098a000 is busy, retrying
[  250.841134] alloc_contig_range test_pages_isolated(15800, 17b00) failed
[  250.847754] cma: dma_alloc_from_contiguous(): memory range at c098c000 is busy, retrying
[  250.856415] alloc_contig_range test_pages_isolated(15c00, 17c00) failed
[  250.863138] cma: dma_alloc_from_contiguous(): memory range at c098e000 is busy, retrying
[  250.871837] alloc_contig_range test_pages_isolated(15c00, 17d00) failed
[  250.878460] cma: dma_alloc_from_contiguous(): memory range at c0990000 is busy, retrying
[  250.887135] alloc_contig_range test_pages_isolated(15c00, 17e00) failed
[  250.893739] cma: dma_alloc_from_contiguous(): memory range at c0992000 is busy, retrying
[  250.902431] alloc_contig_range test_pages_isolated(15c00, 17f00) failed
[  250.909050] cma: dma_alloc_from_contiguous(): memory range at c0994000 is busy, retrying
[  250.917736] alloc_contig_range test_pages_isolated(16000, 18000) failed
[  250.924341] cma: dma_alloc_from_contiguous(): memory range at c0996000 is busy, retrying
[  250.933022] alloc_contig_range test_pages_isolated(16000, 18100) failed
[  250.939639] cma: dma_alloc_from_contiguous(): memory range at c0998000 is busy, retrying
[  250.948331] alloc_contig_range test_pages_isolated(16000, 18200) failed
[  250.954938] cma: dma_alloc_from_contiguous(): memory range at c099a000 is busy, retrying
[  250.963829] alloc_contig_range test_pages_isolated(16000, 18300) failed
[  250.970453] cma: dma_alloc_from_contiguous(): memory range at c099c000 is busy, retrying
[  250.979131] alloc_contig_range test_pages_isolated(16400, 18400) failed
[  250.985735] cma: dma_alloc_from_contiguous(): memory range at c099e000 is busy, retrying
[  250.994411] alloc_contig_range test_pages_isolated(16400, 18500) failed
[  251.001034] cma: dma_alloc_from_contiguous(): memory range at c09a0000 is busy, retrying
[  251.009710] alloc_contig_range test_pages_isolated(16400, 18600) failed
[  251.016316] cma: dma_alloc_from_contiguous(): memory range at c09a2000 is busy, retrying
[  251.025014] alloc_contig_range test_pages_isolated(16400, 18700) failed
[  251.031635] cma: dma_alloc_from_contiguous(): memory range at c09a4000 is busy, retrying
[  251.040310] alloc_contig_range test_pages_isolated(16800, 18800) failed
[  251.046927] cma: dma_alloc_from_contiguous(): memory range at c09a6000 is busy, retrying
[  251.055589] alloc_contig_range test_pages_isolated(16800, 18900) failed
[  251.062341] cma: dma_alloc_from_contiguous(): memory range at c09a8000 is busy, retrying
[  251.071029] alloc_contig_range test_pages_isolated(16800, 18a00) failed
[  251.077649] cma: dma_alloc_from_contiguous(): memory range at c09aa000 is busy, retrying
[  251.086311] alloc_contig_range test_pages_isolated(16800, 18b00) failed
[  251.092932] cma: dma_alloc_from_contiguous(): memory range at c09ac000 is busy, retrying
[  251.101608] alloc_contig_range test_pages_isolated(16c00, 18c00) failed
[  251.108227] cma: dma_alloc_from_contiguous(): memory range at c09ae000 is busy, retrying
[  251.116905] alloc_contig_range test_pages_isolated(16c00, 18d00) failed
[  251.123509] cma: dma_alloc_from_contiguous(): memory range at c09b0000 is busy, retrying
[  251.132186] alloc_contig_range test_pages_isolated(16c00, 18e00) failed
[  251.138803] cma: dma_alloc_from_contiguous(): memory range at c09b2000 is busy, retrying
[  251.147474] alloc_contig_range test_pages_isolated(16c00, 18f00) failed
[  251.154078] cma: dma_alloc_from_contiguous(): memory range at c09b4000 is busy, retrying
[  251.162897] alloc_contig_range test_pages_isolated(17000, 19000) failed
[  251.169515] cma: dma_alloc_from_contiguous(): memory range at c09b6000 is busy, retrying
[  251.178190] alloc_contig_range test_pages_isolated(17000, 19100) failed
[  251.184796] cma: dma_alloc_from_contiguous(): memory range at c09b8000 is busy, retrying
[  251.193472] alloc_contig_range test_pages_isolated(17000, 19200) failed
[  251.200091] cma: dma_alloc_from_contiguous(): memory range at c09ba000 is busy, retrying
[  251.208764] alloc_contig_range test_pages_isolated(17000, 19300) failed
[  251.215370] cma: dma_alloc_from_contiguous(): memory range at c09bc000 is busy, retrying
[  251.224042] alloc_contig_range test_pages_isolated(17400, 19400) failed
[  251.230658] cma: dma_alloc_from_contiguous(): memory range at c09be000 is busy, retrying
[  251.239337] alloc_contig_range test_pages_isolated(17400, 19500) failed
[  251.245941] cma: dma_alloc_from_contiguous(): memory range at c09c0000 is busy, retrying
[  251.254641] alloc_contig_range test_pages_isolated(17400, 19600) failed
[  251.261393] cma: dma_alloc_from_contiguous(): memory range at c09c2000 is busy, retrying
[  251.270078] alloc_contig_range test_pages_isolated(17400, 19700) failed
[  251.276695] cma: dma_alloc_from_contiguous(): memory range at c09c4000 is busy, retrying
[  251.285354] alloc_contig_range test_pages_isolated(17800, 19800) failed
[  251.291974] cma: dma_alloc_from_contiguous(): memory range at c09c6000 is busy, retrying
[  251.300654] alloc_contig_range test_pages_isolated(17800, 19900) failed
[  251.307272] cma: dma_alloc_from_contiguous(): memory range at c09c8000 is busy, retrying
[  251.315931] alloc_contig_range test_pages_isolated(17800, 19a00) failed
[  251.322551] cma: dma_alloc_from_contiguous(): memory range at c09ca000 is busy, retrying
[  251.331229] alloc_contig_range test_pages_isolated(17800, 19b00) failed
[  251.337848] cma: dma_alloc_from_contiguous(): memory range at c09cc000 is busy, retrying
[  251.346516] alloc_contig_range test_pages_isolated(17c00, 19c00) failed
[  251.353121] cma: dma_alloc_from_contiguous(): memory range at c09ce000 is busy, retrying
[  251.361872] alloc_contig_range test_pages_isolated(17c00, 19d00) failed
[  251.368496] cma: dma_alloc_from_contiguous(): memory range at c09d0000 is busy, retrying
[  251.377173] alloc_contig_range test_pages_isolated(17c00, 19e00) failed
[  251.383777] cma: dma_alloc_from_contiguous(): memory range at c09d2000 is busy, retrying
[  251.392450] alloc_contig_range test_pages_isolated(17c00, 19f00) failed
[  251.399076] cma: dma_alloc_from_contiguous(): memory range at c09d4000 is busy, retrying
[  251.407803] alloc_contig_range test_pages_isolated(18000, 1a000) failed
[  251.414407] cma: dma_alloc_from_contiguous(): memory range at c09d6000 is busy, retrying
[  251.423090] alloc_contig_range test_pages_isolated(18000, 1a100) failed
[  251.429711] cma: dma_alloc_from_contiguous(): memory range at c09d8000 is busy, retrying
[  251.438384] alloc_contig_range test_pages_isolated(18000, 1a200) failed
[  251.444988] cma: dma_alloc_from_contiguous(): memory range at c09da000 is busy, retrying
[  251.453664] alloc_contig_range test_pages_isolated(18000, 1a300) failed
[  251.460414] cma: dma_alloc_from_contiguous(): memory range at c09dc000 is busy, retrying
[  251.469101] alloc_contig_range test_pages_isolated(18400, 1a400) failed
[  251.475705] cma: dma_alloc_from_contiguous(): memory range at c09de000 is busy, retrying
[  251.484381] alloc_contig_range test_pages_isolated(18400, 1a500) failed
[  251.490999] cma: dma_alloc_from_contiguous(): memory range at c09e0000 is busy, retrying
[  251.499681] alloc_contig_range test_pages_isolated(18400, 1a600) failed
[  251.506287] cma: dma_alloc_from_contiguous(): memory range at c09e2000 is busy, retrying
[  251.514963] alloc_contig_range test_pages_isolated(18400, 1a700) failed
[  251.521580] cma: dma_alloc_from_contiguous(): memory range at c09e4000 is busy, retrying
[  251.530252] alloc_contig_range test_pages_isolated(18800, 1a800) failed
[  251.536869] cma: dma_alloc_from_contiguous(): memory range at c09e6000 is busy, retrying
[  251.545530] alloc_contig_range test_pages_isolated(18800, 1a900) failed
[  251.552170] cma: dma_alloc_from_contiguous(): memory range at c09e8000 is busy, retrying
[  251.560924] alloc_contig_range test_pages_isolated(18800, 1aa00) failed
[  251.567551] cma: dma_alloc_from_contiguous(): memory range at c09ea000 is busy, retrying
[  251.576218] alloc_contig_range test_pages_isolated(18800, 1ab00) failed
[  251.582839] cma: dma_alloc_from_contiguous(): memory range at c09ec000 is busy, retrying
[  251.591508] alloc_contig_range test_pages_isolated(18c00, 1ac00) failed
[  251.598131] cma: dma_alloc_from_contiguous(): memory range at c09ee000 is busy, retrying
[  251.606806] alloc_contig_range test_pages_isolated(18c00, 1ad00) failed
[  251.613411] cma: dma_alloc_from_contiguous(): memory range at c09f0000 is busy, retrying
[  251.622094] alloc_contig_range test_pages_isolated(18c00, 1ae00) failed
[  251.628715] cma: dma_alloc_from_contiguous(): memory range at c09f2000 is busy, retrying
[  251.637391] alloc_contig_range test_pages_isolated(18c00, 1af00) failed
[  251.643996] cma: dma_alloc_from_contiguous(): memory range at c09f4000 is busy, retrying
[  251.652672] alloc_contig_range test_pages_isolated(19000, 1b000) failed
[  251.659421] cma: dma_alloc_from_contiguous(): memory range at c09f6000 is busy, retrying
[  251.668115] alloc_contig_range test_pages_isolated(19000, 1b100) failed
[  251.674720] cma: dma_alloc_from_contiguous(): memory range at c09f8000 is busy, retrying
[  251.683405] alloc_contig_range test_pages_isolated(19000, 1b200) failed
[  251.690022] cma: dma_alloc_from_contiguous(): memory range at c09fa000 is busy, retrying
[  251.698700] alloc_contig_range test_pages_isolated(19000, 1b300) failed
[  251.705305] cma: dma_alloc_from_contiguous(): memory range at c09fc000 is busy, retrying
[  251.713988] alloc_contig_range test_pages_isolated(19400, 1b400) failed
[  251.720605] cma: dma_alloc_from_contiguous(): memory range at c09fe000 is busy, retrying
[  251.729276] alloc_contig_range test_pages_isolated(19400, 1b500) failed
[  251.735881] cma: dma_alloc_from_contiguous(): memory range at c0a00000 is busy, retrying
[  251.744558] alloc_contig_range test_pages_isolated(19400, 1b600) failed
[  251.751175] cma: dma_alloc_from_contiguous(): memory range at c0a02000 is busy, retrying
[  251.759920] alloc_contig_range test_pages_isolated(19400, 1b700) failed
[  251.766538] cma: dma_alloc_from_contiguous(): memory range at c0a04000 is busy, retrying
[  251.775201] alloc_contig_range test_pages_isolated(19800, 1b800) failed
[  251.781819] cma: dma_alloc_from_contiguous(): memory range at c0a06000 is busy, retrying
[  251.790491] alloc_contig_range test_pages_isolated(19800, 1b900) failed
[  251.797110] cma: dma_alloc_from_contiguous(): memory range at c0a08000 is busy, retrying
[  251.805767] alloc_contig_range test_pages_isolated(19800, 1ba00) failed
[  251.812387] cma: dma_alloc_from_contiguous(): memory range at c0a0a000 is busy, retrying
[  251.821054] alloc_contig_range test_pages_isolated(19800, 1bb00) failed
[  251.827673] cma: dma_alloc_from_contiguous(): memory range at c0a0c000 is busy, retrying
[  251.836337] alloc_contig_range test_pages_isolated(19c00, 1bc00) failed
[  251.842955] cma: dma_alloc_from_contiguous(): memory range at c0a0e000 is busy, retrying
[  251.851644] alloc_contig_range test_pages_isolated(19c00, 1bd00) failed
[  251.858358] cma: dma_alloc_from_contiguous(): memory range at c0a10000 is busy, retrying
[  251.867046] alloc_contig_range test_pages_isolated(19c00, 1be00) failed
[  251.873652] cma: dma_alloc_from_contiguous(): memory range at c0a12000 is busy, retrying
[  251.882334] alloc_contig_range test_pages_isolated(19c00, 1bf00) failed
[  251.888952] cma: dma_alloc_from_contiguous(): memory range at c0a14000 is busy, retrying
[  251.897632] alloc_contig_range test_pages_isolated(1a000, 1c000) failed
[  251.904235] cma: dma_alloc_from_contiguous(): memory range at c0a16000 is busy, retrying
[  251.912911] alloc_contig_range test_pages_isolated(1a000, 1c100) failed
[  251.919528] cma: dma_alloc_from_contiguous(): memory range at c0a18000 is busy, retrying
[  251.928202] alloc_contig_range test_pages_isolated(1a000, 1c200) failed
[  251.934806] cma: dma_alloc_from_contiguous(): memory range at c0a1a000 is busy, retrying
[  251.943481] alloc_contig_range test_pages_isolated(1a000, 1c300) failed
[  251.950100] cma: dma_alloc_from_contiguous(): memory range at c0a1c000 is busy, retrying
[  251.958914] alloc_contig_range test_pages_isolated(1a400, 1c400) failed
[  251.965518] cma: dma_alloc_from_contiguous(): memory range at c0a1e000 is busy, retrying
[  251.974196] alloc_contig_range test_pages_isolated(1a400, 1c500) failed
[  251.980813] cma: dma_alloc_from_contiguous(): memory range at c0a20000 is busy, retrying
[  251.989486] alloc_contig_range test_pages_isolated(1a400, 1c600) failed
[  251.996092] cma: dma_alloc_from_contiguous(): memory range at c0a22000 is busy, retrying
[  252.004767] alloc_contig_range test_pages_isolated(1a400, 1c700) failed
[  252.011386] cma: dma_alloc_from_contiguous(): memory range at c0a24000 is busy, retrying
[  252.020156] alloc_contig_range test_pages_isolated(1a800, 1c800) failed
[  252.026773] cma: dma_alloc_from_contiguous(): memory range at c0a26000 is busy, retrying
[  252.035434] alloc_contig_range test_pages_isolated(1a800, 1c900) failed
[  252.042054] cma: dma_alloc_from_contiguous(): memory range at c0a28000 is busy, retrying
[  252.050727] alloc_contig_range test_pages_isolated(1a800, 1ca00) failed
[  252.057418] cma: dma_alloc_from_contiguous(): memory range at c0a2a000 is busy, retrying
[  252.066093] alloc_contig_range test_pages_isolated(1a800, 1cb00) failed
[  252.072712] cma: dma_alloc_from_contiguous(): memory range at c0a2c000 is busy, retrying
[  252.081382] alloc_contig_range test_pages_isolated(1ac00, 1cc00) failed
[  252.088001] cma: dma_alloc_from_contiguous(): memory range at c0a2e000 is busy, retrying
[  252.096681] alloc_contig_range test_pages_isolated(1ac00, 1cd00) failed
[  252.103285] cma: dma_alloc_from_contiguous(): memory range at c0a30000 is busy, retrying
[  252.111960] alloc_contig_range test_pages_isolated(1ac00, 1ce00) failed
[  252.118577] cma: dma_alloc_from_contiguous(): memory range at c0a32000 is busy, retrying
[  252.127255] alloc_contig_range test_pages_isolated(1ac00, 1cf00) failed
[  252.133859] cma: dma_alloc_from_contiguous(): memory range at c0a34000 is busy, retrying
[  252.142532] alloc_contig_range test_pages_isolated(1b000, 1d000) failed
[  252.149168] cma: dma_alloc_from_contiguous(): memory range at c0a36000 is busy, retrying
[  252.157944] alloc_contig_range test_pages_isolated(1b000, 1d100) failed
[  252.164548] cma: dma_alloc_from_contiguous(): memory range at c0a38000 is busy, retrying
[  252.173221] alloc_contig_range test_pages_isolated(1b000, 1d200) failed
[  252.179838] cma: dma_alloc_from_contiguous(): memory range at c0a3a000 is busy, retrying
[  252.188513] alloc_contig_range test_pages_isolated(1b000, 1d300) failed
[  252.195117] cma: dma_alloc_from_contiguous(): memory range at c0a3c000 is busy, retrying
[  252.203789] alloc_contig_range test_pages_isolated(1b400, 1d400) failed
[  252.210406] cma: dma_alloc_from_contiguous(): memory range at c0a3e000 is busy, retrying
[  252.219077] alloc_contig_range test_pages_isolated(1b400, 1d500) failed
[  252.225681] cma: dma_alloc_from_contiguous(): memory range at c0a40000 is busy, retrying
[  252.234358] alloc_contig_range test_pages_isolated(1b400, 1d600) failed
[  252.240977] cma: dma_alloc_from_contiguous(): memory range at c0a42000 is busy, retrying
[  252.249648] alloc_contig_range test_pages_isolated(1b400, 1d700) failed
[  252.256254] cma: dma_alloc_from_contiguous(): memory range at c0a44000 is busy, retrying
[  252.265158] alloc_contig_range test_pages_isolated(1b800, 1d800) failed
[  252.271776] cma: dma_alloc_from_contiguous(): memory range at c0a46000 is busy, retrying
[  252.280452] alloc_contig_range test_pages_isolated(1b800, 1d900) failed
[  252.287071] cma: dma_alloc_from_contiguous(): memory range at c0a48000 is busy, retrying
[  252.295739] alloc_contig_range test_pages_isolated(1b800, 1da00) failed
[  252.302366] cma: dma_alloc_from_contiguous(): memory range at c0a4a000 is busy, retrying
[  252.311048] alloc_contig_range test_pages_isolated(1b800, 1db00) failed
[  252.317668] cma: dma_alloc_from_contiguous(): memory range at c0a4c000 is busy, retrying
[  252.326331] alloc_contig_range test_pages_isolated(1bc00, 1dc00) failed
[  252.332951] cma: dma_alloc_from_contiguous(): memory range at c0a4e000 is busy, retrying
[  252.341617] alloc_contig_range test_pages_isolated(1bc00, 1dd00) failed
[  252.348236] cma: dma_alloc_from_contiguous(): memory range at c0a50000 is busy, retrying
[  252.357026] alloc_contig_range test_pages_isolated(1bc00, 1de00) failed
[  252.363631] cma: dma_alloc_from_contiguous(): memory range at c0a52000 is busy, retrying
[  252.372308] alloc_contig_range test_pages_isolated(1bc00, 1df00) failed
[  252.378925] cma: dma_alloc_from_contiguous(): memory range at c0a54000 is busy, retrying
[  252.387596] alloc_contig_range test_pages_isolated(1c000, 1e000) failed
[  252.394199] cma: dma_alloc_from_contiguous(): memory range at c0a56000 is busy, retrying
[  252.402873] alloc_contig_range test_pages_isolated(1c000, 1e100) failed
[  252.409492] cma: dma_alloc_from_contiguous(): memory range at c0a58000 is busy, retrying
[  252.418166] alloc_contig_range test_pages_isolated(1c000, 1e200) failed
[  252.424771] cma: dma_alloc_from_contiguous(): memory range at c0a5a000 is busy, retrying
[  252.433448] alloc_contig_range test_pages_isolated(1c000, 1e300) failed
[  252.440065] cma: dma_alloc_from_contiguous(): memory range at c0a5c000 is busy, retrying
[  252.448759] alloc_contig_range test_pages_isolated(1c400, 1e400) failed
[  252.455362] cma: dma_alloc_from_contiguous(): memory range at c0a5e000 is busy, retrying
[  252.464163] alloc_contig_range test_pages_isolated(1c400, 1e500) failed
[  252.470782] cma: dma_alloc_from_contiguous(): memory range at c0a60000 is busy, retrying
[  252.479460] alloc_contig_range test_pages_isolated(1c400, 1e600) failed
[  252.486065] cma: dma_alloc_from_contiguous(): memory range at c0a62000 is busy, retrying
[  252.494741] alloc_contig_range test_pages_isolated(1c400, 1e700) failed
[  252.501368] cma: dma_alloc_from_contiguous(): memory range at c0a64000 is busy, retrying
[  252.510038] alloc_contig_range test_pages_isolated(1c800, 1e800) failed
[  252.516658] cma: dma_alloc_from_contiguous(): memory range at c0a66000 is busy, retrying
[  252.525320] alloc_contig_range test_pages_isolated(1c800, 1e900) failed
[  252.531939] cma: dma_alloc_from_contiguous(): memory range at c0a68000 is busy, retrying
[  252.540614] alloc_contig_range test_pages_isolated(1c800, 1ea00) failed
[  252.547233] cma: dma_alloc_from_contiguous(): memory range at c0a6a000 is busy, retrying
[  252.555894] alloc_contig_range test_pages_isolated(1c800, 1eb00) failed
[  252.562647] cma: dma_alloc_from_contiguous(): memory range at c0a6c000 is busy, retrying
[  252.571328] alloc_contig_range test_pages_isolated(1cc00, 1ec00) failed
[  252.577948] cma: dma_alloc_from_contiguous(): memory range at c0a6e000 is busy, retrying
[  252.586621] alloc_contig_range test_pages_isolated(1cc00, 1ed00) failed
[  252.593226] cma: dma_alloc_from_contiguous(): memory range at c0a70000 is busy, retrying
[  252.601900] alloc_contig_range test_pages_isolated(1cc00, 1ee00) failed
[  252.608518] cma: dma_alloc_from_contiguous(): memory range at c0a72000 is busy, retrying
[  252.617187] alloc_contig_range test_pages_isolated(1cc00, 1ef00) failed
[  252.623791] cma: dma_alloc_from_contiguous(): memory range at c0a74000 is busy, retrying
[  252.632465] alloc_contig_range test_pages_isolated(1d000, 1f000) failed
[  252.639081] cma: dma_alloc_from_contiguous(): memory range at c0a76000 is busy, retrying
[  252.647754] alloc_contig_range test_pages_isolated(1d000, 1f100) failed
[  252.654359] cma: dma_alloc_from_contiguous(): memory range at c0a78000 is busy, retrying
[  252.663109] alloc_contig_range test_pages_isolated(1d000, 1f200) failed
[  252.669727] cma: dma_alloc_from_contiguous(): memory range at c0a7a000 is busy, retrying
[  252.678398] alloc_contig_range test_pages_isolated(1d000, 1f300) failed
[  252.685003] cma: dma_alloc_from_contiguous(): memory range at c0a7c000 is busy, retrying
[  252.693677] alloc_contig_range test_pages_isolated(1d400, 1f400) failed
[  252.700300] cma: dma_alloc_from_contiguous(): memory range at c0a7e000 is busy, retrying
[  252.708970] alloc_contig_range test_pages_isolated(1d400, 1f500) failed
[  252.715574] cma: dma_alloc_from_contiguous(): memory range at c0a80000 is busy, retrying
[  252.724251] alloc_contig_range test_pages_isolated(1d400, 1f600) failed
[  252.730869] cma: dma_alloc_from_contiguous(): memory range at c0a82000 is busy, retrying
[  252.739541] alloc_contig_range test_pages_isolated(1d400, 1f700) failed
[  252.746146] cma: dma_alloc_from_contiguous(): memory range at c0a84000 is busy, retrying
[  252.754841] alloc_contig_range test_pages_isolated(1d800, 1f800) failed
[  252.761615] cma: dma_alloc_from_contiguous(): memory range at c0a86000 is busy, retrying
[  252.769707] cma: dma_alloc_from_contiguous(): returned   (null)
[  252.775612] failed to allocate 33554432 bytes
[  252.779970] cma: dma_alloc_from_contiguous(cma cf473fc0, count 16384, align 8)
[  252.789478] alloc_contig_range test_pages_isolated(fc00, 13c00) failed
[  252.796006] cma: dma_alloc_from_contiguous(): memory range at c08ce000 is busy, retrying
[  252.805578] alloc_contig_range test_pages_isolated(fc00, 13d00) failed
[  252.812122] cma: dma_alloc_from_contiguous(): memory range at c08d0000 is busy, retrying
[  252.821417] alloc_contig_range test_pages_isolated(fc00, 13e00) failed
[  252.827962] cma: dma_alloc_from_contiguous(): memory range at c08d2000 is busy, retrying
[  252.837204] alloc_contig_range test_pages_isolated(fc00, 13f00) failed
[  252.843729] cma: dma_alloc_from_contiguous(): memory range at c08d4000 is busy, retrying
[  252.852951] alloc_contig_range test_pages_isolated(10000, 14000) failed
[  252.859716] cma: dma_alloc_from_contiguous(): memory range at c08d6000 is busy, retrying
[  252.868973] alloc_contig_range test_pages_isolated(10000, 14100) failed
[  252.875585] cma: dma_alloc_from_contiguous(): memory range at c08d8000 is busy, retrying
[  252.884809] alloc_contig_range test_pages_isolated(10000, 14200) failed
[  252.891433] cma: dma_alloc_from_contiguous(): memory range at c08da000 is busy, retrying
[  252.900669] alloc_contig_range test_pages_isolated(10000, 14300) failed
[  252.907295] cma: dma_alloc_from_contiguous(): memory range at c08dc000 is busy, retrying
[  252.916511] alloc_contig_range test_pages_isolated(10400, 14400) failed
[  252.923121] cma: dma_alloc_from_contiguous(): memory range at c08de000 is busy, retrying
[  252.932325] alloc_contig_range test_pages_isolated(10400, 14500) failed
[  252.938948] cma: dma_alloc_from_contiguous(): memory range at c08e0000 is busy, retrying
[  252.948159] alloc_contig_range test_pages_isolated(10400, 14600) failed
[  252.954769] cma: dma_alloc_from_contiguous(): memory range at c08e2000 is busy, retrying
[  252.964071] alloc_contig_range test_pages_isolated(10400, 14700) failed
[  252.970695] cma: dma_alloc_from_contiguous(): memory range at c08e4000 is busy, retrying
[  252.979913] alloc_contig_range test_pages_isolated(10800, 14800) failed
[  252.986536] cma: dma_alloc_from_contiguous(): memory range at c08e6000 is busy, retrying
[  252.995730] alloc_contig_range test_pages_isolated(10800, 14900) failed
[  253.002356] cma: dma_alloc_from_contiguous(): memory range at c08e8000 is busy, retrying
[  253.011555] alloc_contig_range test_pages_isolated(10800, 14a00) failed
[  253.018198] cma: dma_alloc_from_contiguous(): memory range at c08ea000 is busy, retrying
[  253.027401] alloc_contig_range test_pages_isolated(10800, 14b00) failed
[  253.034011] cma: dma_alloc_from_contiguous(): memory range at c08ec000 is busy, retrying
[  253.043215] alloc_contig_range test_pages_isolated(10c00, 14c00) failed
[  253.049859] cma: dma_alloc_from_contiguous(): memory range at c08ee000 is busy, retrying
[  253.059207] alloc_contig_range test_pages_isolated(10c00, 14d00) failed
[  253.065818] cma: dma_alloc_from_contiguous(): memory range at c08f0000 is busy, retrying
[  253.075029] alloc_contig_range test_pages_isolated(10c00, 14e00) failed
[  253.081651] cma: dma_alloc_from_contiguous(): memory range at c08f2000 is busy, retrying
[  253.090863] alloc_contig_range test_pages_isolated(10c00, 14f00) failed
[  253.097496] cma: dma_alloc_from_contiguous(): memory range at c08f4000 is busy, retrying
[  253.106705] alloc_contig_range test_pages_isolated(11000, 15000) failed
[  253.113315] cma: dma_alloc_from_contiguous(): memory range at c08f6000 is busy, retrying
[  253.122528] alloc_contig_range test_pages_isolated(11000, 15100) failed
[  253.129151] cma: dma_alloc_from_contiguous(): memory range at c08f8000 is busy, retrying
[  253.138358] alloc_contig_range test_pages_isolated(11000, 15200) failed
[  253.144968] cma: dma_alloc_from_contiguous(): memory range at c08fa000 is busy, retrying
[  253.154177] alloc_contig_range test_pages_isolated(11000, 15300) failed
[  253.160997] cma: dma_alloc_from_contiguous(): memory range at c08fc000 is busy, retrying
[  253.170236] alloc_contig_range test_pages_isolated(11400, 15400) failed
[  253.176860] cma: dma_alloc_from_contiguous(): memory range at c08fe000 is busy, retrying
[  253.186073] alloc_contig_range test_pages_isolated(11400, 15500) failed
[  253.192699] cma: dma_alloc_from_contiguous(): memory range at c0900000 is busy, retrying
[  253.201911] alloc_contig_range test_pages_isolated(11400, 15600) failed
[  253.208537] cma: dma_alloc_from_contiguous(): memory range at c0902000 is busy, retrying
[  253.217745] alloc_contig_range test_pages_isolated(11400, 15700) failed
[  253.224355] cma: dma_alloc_from_contiguous(): memory range at c0904000 is busy, retrying
[  253.233560] alloc_contig_range test_pages_isolated(11800, 15800) failed
[  253.240184] cma: dma_alloc_from_contiguous(): memory range at c0906000 is busy, retrying
[  253.249390] alloc_contig_range test_pages_isolated(11800, 15900) failed
[  253.256001] cma: dma_alloc_from_contiguous(): memory range at c0908000 is busy, retrying
[  253.265358] alloc_contig_range test_pages_isolated(11800, 15a00) failed
[  253.271985] cma: dma_alloc_from_contiguous(): memory range at c090a000 is busy, retrying
[  253.281198] alloc_contig_range test_pages_isolated(11800, 15b00) failed
[  253.287823] cma: dma_alloc_from_contiguous(): memory range at c090c000 is busy, retrying
[  253.297039] alloc_contig_range test_pages_isolated(11c00, 15c00) failed
[  253.303649] cma: dma_alloc_from_contiguous(): memory range at c090e000 is busy, retrying
[  253.312858] alloc_contig_range test_pages_isolated(11c00, 15d00) failed
[  253.319482] cma: dma_alloc_from_contiguous(): memory range at c0910000 is busy, retrying
[  253.328691] alloc_contig_range test_pages_isolated(11c00, 15e00) failed
[  253.335301] cma: dma_alloc_from_contiguous(): memory range at c0912000 is busy, retrying
[  253.344513] alloc_contig_range test_pages_isolated(11c00, 15f00) failed
[  253.351158] cma: dma_alloc_from_contiguous(): memory range at c0914000 is busy, retrying
[  253.360595] alloc_contig_range test_pages_isolated(12000, 16000) failed
[  253.367224] cma: dma_alloc_from_contiguous(): memory range at c0916000 is busy, retrying
[  253.376535] alloc_contig_range test_pages_isolated(12000, 16100) failed
[  253.383147] cma: dma_alloc_from_contiguous(): memory range at c0918000 is busy, retrying
[  253.392397] alloc_contig_range test_pages_isolated(12000, 16200) failed
[  253.399026] cma: dma_alloc_from_contiguous(): memory range at c091a000 is busy, retrying
[  253.408272] alloc_contig_range test_pages_isolated(12000, 16300) failed
[  253.414883] cma: dma_alloc_from_contiguous(): memory range at c091c000 is busy, retrying
[  253.424106] alloc_contig_range test_pages_isolated(12400, 16400) failed
[  253.430732] cma: dma_alloc_from_contiguous(): memory range at c091e000 is busy, retrying
[  253.439943] alloc_contig_range test_pages_isolated(12400, 16500) failed
[  253.446566] cma: dma_alloc_from_contiguous(): memory range at c0920000 is busy, retrying
[  253.455764] alloc_contig_range test_pages_isolated(12400, 16600) failed
[  253.462530] cma: dma_alloc_from_contiguous(): memory range at c0922000 is busy, retrying
[  253.471767] alloc_contig_range test_pages_isolated(12400, 16700) failed
[  253.478394] cma: dma_alloc_from_contiguous(): memory range at c0924000 is busy, retrying
[  253.487608] alloc_contig_range test_pages_isolated(12800, 16800) failed
[  253.494219] cma: dma_alloc_from_contiguous(): memory range at c0926000 is busy, retrying
[  253.503444] alloc_contig_range test_pages_isolated(12800, 16900) failed
[  253.510068] cma: dma_alloc_from_contiguous(): memory range at c0928000 is busy, retrying
[  253.519280] alloc_contig_range test_pages_isolated(12800, 16a00) failed
[  253.525891] cma: dma_alloc_from_contiguous(): memory range at c092a000 is busy, retrying
[  253.535099] alloc_contig_range test_pages_isolated(12800, 16b00) failed
[  253.541721] cma: dma_alloc_from_contiguous(): memory range at c092c000 is busy, retrying
[  253.550924] alloc_contig_range test_pages_isolated(12c00, 16c00) failed
[  253.557638] cma: dma_alloc_from_contiguous(): memory range at c092e000 is busy, retrying
[  253.566876] alloc_contig_range test_pages_isolated(12c00, 16d00) failed
[  253.573487] cma: dma_alloc_from_contiguous(): memory range at c0930000 is busy, retrying
[  253.582707] alloc_contig_range test_pages_isolated(12c00, 16e00) failed
[  253.589331] cma: dma_alloc_from_contiguous(): memory range at c0932000 is busy, retrying
[  253.598540] alloc_contig_range test_pages_isolated(12c00, 16f00) failed
[  253.605151] cma: dma_alloc_from_contiguous(): memory range at c0934000 is busy, retrying
[  253.614366] alloc_contig_range test_pages_isolated(13000, 17000) failed
[  253.620989] cma: dma_alloc_from_contiguous(): memory range at c0936000 is busy, retrying
[  253.630195] alloc_contig_range test_pages_isolated(13000, 17100) failed
[  253.636818] cma: dma_alloc_from_contiguous(): memory range at c0938000 is busy, retrying
[  253.646015] alloc_contig_range test_pages_isolated(13000, 17200) failed
[  253.652662] cma: dma_alloc_from_contiguous(): memory range at c093a000 is busy, retrying
[  253.662013] alloc_contig_range test_pages_isolated(13000, 17300) failed
[  253.668645] cma: dma_alloc_from_contiguous(): memory range at c093c000 is busy, retrying
[  253.677869] alloc_contig_range test_pages_isolated(13400, 17400) failed
[  253.684478] cma: dma_alloc_from_contiguous(): memory range at c093e000 is busy, retrying
[  253.693689] alloc_contig_range test_pages_isolated(13400, 17500) failed
[  253.700327] cma: dma_alloc_from_contiguous(): memory range at c0940000 is busy, retrying
[  253.709545] alloc_contig_range test_pages_isolated(13400, 17600) failed
[  253.716156] cma: dma_alloc_from_contiguous(): memory range at c0942000 is busy, retrying
[  253.725374] alloc_contig_range test_pages_isolated(13400, 17700) failed
[  253.732002] cma: dma_alloc_from_contiguous(): memory range at c0944000 is busy, retrying
[  253.741215] alloc_contig_range test_pages_isolated(13800, 17800) failed
[  253.747839] cma: dma_alloc_from_contiguous(): memory range at c0946000 is busy, retrying
[  253.757190] alloc_contig_range test_pages_isolated(13800, 17900) failed
[  253.763800] cma: dma_alloc_from_contiguous(): memory range at c0948000 is busy, retrying
[  253.773028] alloc_contig_range test_pages_isolated(13800, 17a00) failed
[  253.779652] cma: dma_alloc_from_contiguous(): memory range at c094a000 is busy, retrying
[  253.788865] alloc_contig_range test_pages_isolated(13800, 17b00) failed
[  253.795477] cma: dma_alloc_from_contiguous(): memory range at c094c000 is busy, retrying
[  253.804685] alloc_contig_range test_pages_isolated(13c00, 17c00) failed
[  253.811307] cma: dma_alloc_from_contiguous(): memory range at c094e000 is busy, retrying
[  253.820507] alloc_contig_range test_pages_isolated(13c00, 17d00) failed
[  253.827130] cma: dma_alloc_from_contiguous(): memory range at c0950000 is busy, retrying
[  253.836327] alloc_contig_range test_pages_isolated(13c00, 17e00) failed
[  253.842953] cma: dma_alloc_from_contiguous(): memory range at c0952000 is busy, retrying
[  253.852157] alloc_contig_range test_pages_isolated(13c00, 17f00) failed
[  253.858898] cma: dma_alloc_from_contiguous(): memory range at c0954000 is busy, retrying
[  253.868148] alloc_contig_range test_pages_isolated(14000, 18000) failed
[  253.874758] cma: dma_alloc_from_contiguous(): memory range at c0956000 is busy, retrying
[  253.883983] alloc_contig_range test_pages_isolated(14000, 18100) failed
[  253.890608] cma: dma_alloc_from_contiguous(): memory range at c0958000 is busy, retrying
[  253.899834] alloc_contig_range test_pages_isolated(14000, 18200) failed
[  253.906459] cma: dma_alloc_from_contiguous(): memory range at c095a000 is busy, retrying
[  253.915656] alloc_contig_range test_pages_isolated(14000, 18300) failed
[  253.922282] cma: dma_alloc_from_contiguous(): memory range at c095c000 is busy, retrying
[  253.931492] alloc_contig_range test_pages_isolated(14400, 18400) failed
[  253.938117] cma: dma_alloc_from_contiguous(): memory range at c095e000 is busy, retrying
[  253.947361] alloc_contig_range test_pages_isolated(14400, 18500) failed
[  253.953972] cma: dma_alloc_from_contiguous(): memory range at c0960000 is busy, retrying
[  253.963366] alloc_contig_range test_pages_isolated(14400, 18600) failed
[  253.969992] cma: dma_alloc_from_contiguous(): memory range at c0962000 is busy, retrying
[  253.979207] alloc_contig_range test_pages_isolated(14400, 18700) failed
[  253.985818] cma: dma_alloc_from_contiguous(): memory range at c0964000 is busy, retrying
[  253.995032] alloc_contig_range test_pages_isolated(14800, 18800) failed
[  254.001655] cma: dma_alloc_from_contiguous(): memory range at c0966000 is busy, retrying
[  254.010862] alloc_contig_range test_pages_isolated(14800, 18900) failed
[  254.017961] cma: dma_alloc_from_contiguous(): memory range at c0968000 is busy, retrying
[  254.027298] alloc_contig_range test_pages_isolated(14800, 18a00) failed
[  254.033909] cma: dma_alloc_from_contiguous(): memory range at c096a000 is busy, retrying
[  254.043171] alloc_contig_range test_pages_isolated(14800, 18b00) failed
[  254.049796] cma: dma_alloc_from_contiguous(): memory range at c096c000 is busy, retrying
[  254.059195] alloc_contig_range test_pages_isolated(14c00, 18c00) failed
[  254.065805] cma: dma_alloc_from_contiguous(): memory range at c096e000 is busy, retrying
[  254.075030] alloc_contig_range test_pages_isolated(14c00, 18d00) failed
[  254.081654] cma: dma_alloc_from_contiguous(): memory range at c0970000 is busy, retrying
[  254.090871] alloc_contig_range test_pages_isolated(14c00, 18e00) failed
[  254.097503] cma: dma_alloc_from_contiguous(): memory range at c0972000 is busy, retrying
[  254.106721] alloc_contig_range test_pages_isolated(14c00, 18f00) failed
[  254.113334] cma: dma_alloc_from_contiguous(): memory range at c0974000 is busy, retrying
[  254.122563] alloc_contig_range test_pages_isolated(15000, 19000) failed
[  254.129186] cma: dma_alloc_from_contiguous(): memory range at c0976000 is busy, retrying
[  254.138396] alloc_contig_range test_pages_isolated(15000, 19100) failed
[  254.145006] cma: dma_alloc_from_contiguous(): memory range at c0978000 is busy, retrying
[  254.154215] alloc_contig_range test_pages_isolated(15000, 19200) failed
[  254.160911] cma: dma_alloc_from_contiguous(): memory range at c097a000 is busy, retrying
[  254.170135] alloc_contig_range test_pages_isolated(15000, 19300) failed
[  254.176759] cma: dma_alloc_from_contiguous(): memory range at c097c000 is busy, retrying
[  254.185956] alloc_contig_range test_pages_isolated(15400, 19400) failed
[  254.192579] cma: dma_alloc_from_contiguous(): memory range at c097e000 is busy, retrying
[  254.201791] alloc_contig_range test_pages_isolated(15400, 19500) failed
[  254.208417] cma: dma_alloc_from_contiguous(): memory range at c0980000 is busy, retrying
[  254.217621] alloc_contig_range test_pages_isolated(15400, 19600) failed
[  254.224233] cma: dma_alloc_from_contiguous(): memory range at c0982000 is busy, retrying
[  254.233439] alloc_contig_range test_pages_isolated(15400, 19700) failed
[  254.240062] cma: dma_alloc_from_contiguous(): memory range at c0984000 is busy, retrying
[  254.249288] alloc_contig_range test_pages_isolated(15800, 19800) failed
[  254.255898] cma: dma_alloc_from_contiguous(): memory range at c0986000 is busy, retrying
[  254.265220] alloc_contig_range test_pages_isolated(15800, 19900) failed
[  254.271845] cma: dma_alloc_from_contiguous(): memory range at c0988000 is busy, retrying
[  254.281059] alloc_contig_range test_pages_isolated(15800, 19a00) failed
[  254.287684] cma: dma_alloc_from_contiguous(): memory range at c098a000 is busy, retrying
[  254.296904] alloc_contig_range test_pages_isolated(15800, 19b00) failed
[  254.303514] cma: dma_alloc_from_contiguous(): memory range at c098c000 is busy, retrying
[  254.312722] alloc_contig_range test_pages_isolated(15c00, 19c00) failed
[  254.319345] cma: dma_alloc_from_contiguous(): memory range at c098e000 is busy, retrying
[  254.328553] alloc_contig_range test_pages_isolated(15c00, 19d00) failed
[  254.335163] cma: dma_alloc_from_contiguous(): memory range at c0990000 is busy, retrying
[  254.344370] alloc_contig_range test_pages_isolated(15c00, 19e00) failed
[  254.350993] cma: dma_alloc_from_contiguous(): memory range at c0992000 is busy, retrying
[  254.360353] alloc_contig_range test_pages_isolated(15c00, 19f00) failed
[  254.366983] cma: dma_alloc_from_contiguous(): memory range at c0994000 is busy, retrying
[  254.376199] alloc_contig_range test_pages_isolated(16000, 1a000) failed
[  254.382825] cma: dma_alloc_from_contiguous(): memory range at c0996000 is busy, retrying
[  254.392031] alloc_contig_range test_pages_isolated(16000, 1a100) failed
[  254.398664] cma: dma_alloc_from_contiguous(): memory range at c0998000 is busy, retrying
[  254.407943] alloc_contig_range test_pages_isolated(16000, 1a200) failed
[  254.414553] cma: dma_alloc_from_contiguous(): memory range at c099a000 is busy, retrying
[  254.423782] alloc_contig_range test_pages_isolated(16000, 1a300) failed
[  254.430409] cma: dma_alloc_from_contiguous(): memory range at c099c000 is busy, retrying
[  254.439632] alloc_contig_range test_pages_isolated(16400, 1a400) failed
[  254.446242] cma: dma_alloc_from_contiguous(): memory range at c099e000 is busy, retrying
[  254.455459] alloc_contig_range test_pages_isolated(16400, 1a500) failed
[  254.462153] cma: dma_alloc_from_contiguous(): memory range at c09a0000 is busy, retrying
[  254.471387] alloc_contig_range test_pages_isolated(16400, 1a600) failed
[  254.478013] cma: dma_alloc_from_contiguous(): memory range at c09a2000 is busy, retrying
[  254.487238] alloc_contig_range test_pages_isolated(16400, 1a700) failed
[  254.493849] cma: dma_alloc_from_contiguous(): memory range at c09a4000 is busy, retrying
[  254.503072] alloc_contig_range test_pages_isolated(16800, 1a800) failed
[  254.509694] cma: dma_alloc_from_contiguous(): memory range at c09a6000 is busy, retrying
[  254.518905] alloc_contig_range test_pages_isolated(16800, 1a900) failed
[  254.525515] cma: dma_alloc_from_contiguous(): memory range at c09a8000 is busy, retrying
[  254.534731] alloc_contig_range test_pages_isolated(16800, 1aa00) failed
[  254.541355] cma: dma_alloc_from_contiguous(): memory range at c09aa000 is busy, retrying
[  254.550587] alloc_contig_range test_pages_isolated(16800, 1ab00) failed
[  254.557356] cma: dma_alloc_from_contiguous(): memory range at c09ac000 is busy, retrying
[  254.566609] alloc_contig_range test_pages_isolated(16c00, 1ac00) failed
[  254.573219] cma: dma_alloc_from_contiguous(): memory range at c09ae000 is busy, retrying
[  254.582442] alloc_contig_range test_pages_isolated(16c00, 1ad00) failed
[  254.589066] cma: dma_alloc_from_contiguous(): memory range at c09b0000 is busy, retrying
[  254.598282] alloc_contig_range test_pages_isolated(16c00, 1ae00) failed
[  254.604892] cma: dma_alloc_from_contiguous(): memory range at c09b2000 is busy, retrying
[  254.614104] alloc_contig_range test_pages_isolated(16c00, 1af00) failed
[  254.620727] cma: dma_alloc_from_contiguous(): memory range at c09b4000 is busy, retrying
[  254.629933] alloc_contig_range test_pages_isolated(17000, 1b000) failed
[  254.636555] cma: dma_alloc_from_contiguous(): memory range at c09b6000 is busy, retrying
[  254.645746] alloc_contig_range test_pages_isolated(17000, 1b100) failed
[  254.652371] cma: dma_alloc_from_contiguous(): memory range at c09b8000 is busy, retrying
[  254.661715] alloc_contig_range test_pages_isolated(17000, 1b200) failed
[  254.668341] cma: dma_alloc_from_contiguous(): memory range at c09ba000 is busy, retrying
[  254.677548] alloc_contig_range test_pages_isolated(17000, 1b300) failed
[  254.684159] cma: dma_alloc_from_contiguous(): memory range at c09bc000 is busy, retrying
[  254.693365] alloc_contig_range test_pages_isolated(17400, 1b400) failed
[  254.699995] cma: dma_alloc_from_contiguous(): memory range at c09be000 is busy, retrying
[  254.709206] alloc_contig_range test_pages_isolated(17400, 1b500) failed
[  254.715816] cma: dma_alloc_from_contiguous(): memory range at c09c0000 is busy, retrying
[  254.725035] alloc_contig_range test_pages_isolated(17400, 1b600) failed
[  254.731658] cma: dma_alloc_from_contiguous(): memory range at c09c2000 is busy, retrying
[  254.740879] alloc_contig_range test_pages_isolated(17400, 1b700) failed
[  254.747502] cma: dma_alloc_from_contiguous(): memory range at c09c4000 is busy, retrying
[  254.756785] alloc_contig_range test_pages_isolated(17800, 1b800) failed
[  254.763395] cma: dma_alloc_from_contiguous(): memory range at c09c6000 is busy, retrying
[  254.772618] alloc_contig_range test_pages_isolated(17800, 1b900) failed
[  254.779243] cma: dma_alloc_from_contiguous(): memory range at c09c8000 is busy, retrying
[  254.788466] alloc_contig_range test_pages_isolated(17800, 1ba00) failed
[  254.795077] cma: dma_alloc_from_contiguous(): memory range at c09ca000 is busy, retrying
[  254.804294] alloc_contig_range test_pages_isolated(17800, 1bb00) failed
[  254.810918] cma: dma_alloc_from_contiguous(): memory range at c09cc000 is busy, retrying
[  254.820121] alloc_contig_range test_pages_isolated(17c00, 1bc00) failed
[  254.826743] cma: dma_alloc_from_contiguous(): memory range at c09ce000 is busy, retrying
[  254.835943] alloc_contig_range test_pages_isolated(17c00, 1bd00) failed
[  254.842569] cma: dma_alloc_from_contiguous(): memory range at c09d0000 is busy, retrying
[  254.851797] alloc_contig_range test_pages_isolated(17c00, 1be00) failed
[  254.858540] cma: dma_alloc_from_contiguous(): memory range at c09d2000 is busy, retrying
[  254.867784] alloc_contig_range test_pages_isolated(17c00, 1bf00) failed
[  254.874396] cma: dma_alloc_from_contiguous(): memory range at c09d4000 is busy, retrying
[  254.883621] alloc_contig_range test_pages_isolated(18000, 1c000) failed
[  254.890244] cma: dma_alloc_from_contiguous(): memory range at c09d6000 is busy, retrying
[  254.899461] alloc_contig_range test_pages_isolated(18000, 1c100) failed
[  254.906071] cma: dma_alloc_from_contiguous(): memory range at c09d8000 is busy, retrying
[  254.915278] alloc_contig_range test_pages_isolated(18000, 1c200) failed
[  254.921901] cma: dma_alloc_from_contiguous(): memory range at c09da000 is busy, retrying
[  254.931104] alloc_contig_range test_pages_isolated(18000, 1c300) failed
[  254.937729] cma: dma_alloc_from_contiguous(): memory range at c09dc000 is busy, retrying
[  254.946939] alloc_contig_range test_pages_isolated(18400, 1c400) failed
[  254.953548] cma: dma_alloc_from_contiguous(): memory range at c09de000 is busy, retrying
[  254.962976] alloc_contig_range test_pages_isolated(18400, 1c500) failed
[  254.969602] cma: dma_alloc_from_contiguous(): memory range at c09e0000 is busy, retrying
[  254.978819] alloc_contig_range test_pages_isolated(18400, 1c600) failed
[  254.985430] cma: dma_alloc_from_contiguous(): memory range at c09e2000 is busy, retrying
[  254.994643] alloc_contig_range test_pages_isolated(18400, 1c700) failed
[  255.001266] cma: dma_alloc_from_contiguous(): memory range at c09e4000 is busy, retrying
[  255.010485] alloc_contig_range test_pages_isolated(18800, 1c800) failed
[  255.017125] cma: dma_alloc_from_contiguous(): memory range at c09e6000 is busy, retrying
[  255.026319] alloc_contig_range test_pages_isolated(18800, 1c900) failed
[  255.032945] cma: dma_alloc_from_contiguous(): memory range at c09e8000 is busy, retrying
[  255.042149] alloc_contig_range test_pages_isolated(18800, 1ca00) failed
[  255.048774] cma: dma_alloc_from_contiguous(): memory range at c09ea000 is busy, retrying
[  255.058126] alloc_contig_range test_pages_isolated(18800, 1cb00) failed
[  255.064737] cma: dma_alloc_from_contiguous(): memory range at c09ec000 is busy, retrying
[  255.073973] alloc_contig_range test_pages_isolated(18c00, 1cc00) failed
[  255.080597] cma: dma_alloc_from_contiguous(): memory range at c09ee000 is busy, retrying
[  255.089808] alloc_contig_range test_pages_isolated(18c00, 1cd00) failed
[  255.096418] cma: dma_alloc_from_contiguous(): memory range at c09f0000 is busy, retrying
[  255.105656] alloc_contig_range test_pages_isolated(18c00, 1ce00) failed
[  255.112283] cma: dma_alloc_from_contiguous(): memory range at c09f2000 is busy, retrying
[  255.121496] alloc_contig_range test_pages_isolated(18c00, 1cf00) failed
[  255.128122] cma: dma_alloc_from_contiguous(): memory range at c09f4000 is busy, retrying
[  255.137341] alloc_contig_range test_pages_isolated(19000, 1d000) failed
[  255.143952] cma: dma_alloc_from_contiguous(): memory range at c09f6000 is busy, retrying
[  255.153179] alloc_contig_range test_pages_isolated(19000, 1d100) failed
[  255.160000] cma: dma_alloc_from_contiguous(): memory range at c09f8000 is busy, retrying
[  255.169257] alloc_contig_range test_pages_isolated(19000, 1d200) failed
[  255.175867] cma: dma_alloc_from_contiguous(): memory range at c09fa000 is busy, retrying
[  255.185086] alloc_contig_range test_pages_isolated(19000, 1d300) failed
[  255.191711] cma: dma_alloc_from_contiguous(): memory range at c09fc000 is busy, retrying
[  255.200934] alloc_contig_range test_pages_isolated(19400, 1d400) failed
[  255.207558] cma: dma_alloc_from_contiguous(): memory range at c09fe000 is busy, retrying
[  255.216785] alloc_contig_range test_pages_isolated(19400, 1d500) failed
[  255.223396] cma: dma_alloc_from_contiguous(): memory range at c0a00000 is busy, retrying
[  255.232621] alloc_contig_range test_pages_isolated(19400, 1d600) failed
[  255.239245] cma: dma_alloc_from_contiguous(): memory range at c0a02000 is busy, retrying
[  255.248459] alloc_contig_range test_pages_isolated(19400, 1d700) failed
[  255.255069] cma: dma_alloc_from_contiguous(): memory range at c0a04000 is busy, retrying
[  255.264435] alloc_contig_range test_pages_isolated(19800, 1d800) failed
[  255.271064] cma: dma_alloc_from_contiguous(): memory range at c0a06000 is busy, retrying
[  255.280280] alloc_contig_range test_pages_isolated(19800, 1d900) failed
[  255.286906] cma: dma_alloc_from_contiguous(): memory range at c0a08000 is busy, retrying
[  255.296104] alloc_contig_range test_pages_isolated(19800, 1da00) failed
[  255.302740] cma: dma_alloc_from_contiguous(): memory range at c0a0a000 is busy, retrying
[  255.311956] alloc_contig_range test_pages_isolated(19800, 1db00) failed
[  255.318582] cma: dma_alloc_from_contiguous(): memory range at c0a0c000 is busy, retrying
[  255.327791] alloc_contig_range test_pages_isolated(19c00, 1dc00) failed
[  255.334401] cma: dma_alloc_from_contiguous(): memory range at c0a0e000 is busy, retrying
[  255.343608] alloc_contig_range test_pages_isolated(19c00, 1dd00) failed
[  255.350232] cma: dma_alloc_from_contiguous(): memory range at c0a10000 is busy, retrying
[  255.359524] alloc_contig_range test_pages_isolated(19c00, 1de00) failed
[  255.366136] cma: dma_alloc_from_contiguous(): memory range at c0a12000 is busy, retrying
[  255.375362] alloc_contig_range test_pages_isolated(19c00, 1df00) failed
[  255.381987] cma: dma_alloc_from_contiguous(): memory range at c0a14000 is busy, retrying
[  255.391203] alloc_contig_range test_pages_isolated(1a000, 1e000) failed
[  255.397830] cma: dma_alloc_from_contiguous(): memory range at c0a16000 is busy, retrying
[  255.407049] alloc_contig_range test_pages_isolated(1a000, 1e100) failed
[  255.413659] cma: dma_alloc_from_contiguous(): memory range at c0a18000 is busy, retrying
[  255.422869] alloc_contig_range test_pages_isolated(1a000, 1e200) failed
[  255.429495] cma: dma_alloc_from_contiguous(): memory range at c0a1a000 is busy, retrying
[  255.438714] alloc_contig_range test_pages_isolated(1a000, 1e300) failed
[  255.445324] cma: dma_alloc_from_contiguous(): memory range at c0a1c000 is busy, retrying
[  255.454571] alloc_contig_range test_pages_isolated(1a400, 1e400) failed
[  255.461278] cma: dma_alloc_from_contiguous(): memory range at c0a1e000 is busy, retrying
[  255.470513] alloc_contig_range test_pages_isolated(1a400, 1e500) failed
[  255.477137] cma: dma_alloc_from_contiguous(): memory range at c0a20000 is busy, retrying
[  255.486350] alloc_contig_range test_pages_isolated(1a400, 1e600) failed
[  255.492976] cma: dma_alloc_from_contiguous(): memory range at c0a22000 is busy, retrying
[  255.502205] alloc_contig_range test_pages_isolated(1a400, 1e700) failed
[  255.508829] cma: dma_alloc_from_contiguous(): memory range at c0a24000 is busy, retrying
[  255.518039] alloc_contig_range test_pages_isolated(1a800, 1e800) failed
[  255.524649] cma: dma_alloc_from_contiguous(): memory range at c0a26000 is busy, retrying
[  255.533858] alloc_contig_range test_pages_isolated(1a800, 1e900) failed
[  255.540481] cma: dma_alloc_from_contiguous(): memory range at c0a28000 is busy, retrying
[  255.549681] alloc_contig_range test_pages_isolated(1a800, 1ea00) failed
[  255.556292] cma: dma_alloc_from_contiguous(): memory range at c0a2a000 is busy, retrying
[  255.565646] alloc_contig_range test_pages_isolated(1a800, 1eb00) failed
[  255.572271] cma: dma_alloc_from_contiguous(): memory range at c0a2c000 is busy, retrying
[  255.581483] alloc_contig_range test_pages_isolated(1ac00, 1ec00) failed
[  255.588106] cma: dma_alloc_from_contiguous(): memory range at c0a2e000 is busy, retrying
[  255.597322] alloc_contig_range test_pages_isolated(1ac00, 1ed00) failed
[  255.603932] cma: dma_alloc_from_contiguous(): memory range at c0a30000 is busy, retrying
[  255.613141] alloc_contig_range test_pages_isolated(1ac00, 1ee00) failed
[  255.619765] cma: dma_alloc_from_contiguous(): memory range at c0a32000 is busy, retrying
[  255.628984] alloc_contig_range test_pages_isolated(1ac00, 1ef00) failed
[  255.635593] cma: dma_alloc_from_contiguous(): memory range at c0a34000 is busy, retrying
[  255.644805] alloc_contig_range test_pages_isolated(1b000, 1f000) failed
[  255.651429] cma: dma_alloc_from_contiguous(): memory range at c0a36000 is busy, retrying
[  255.660759] alloc_contig_range test_pages_isolated(1b000, 1f100) failed
[  255.667390] cma: dma_alloc_from_contiguous(): memory range at c0a38000 is busy, retrying
[  255.676625] alloc_contig_range test_pages_isolated(1b000, 1f200) failed
[  255.683238] cma: dma_alloc_from_contiguous(): memory range at c0a3a000 is busy, retrying
[  255.692456] alloc_contig_range test_pages_isolated(1b000, 1f300) failed
[  255.699092] cma: dma_alloc_from_contiguous(): memory range at c0a3c000 is busy, retrying
[  255.708307] alloc_contig_range test_pages_isolated(1b400, 1f400) failed
[  255.714919] cma: dma_alloc_from_contiguous(): memory range at c0a3e000 is busy, retrying
[  255.724124] alloc_contig_range test_pages_isolated(1b400, 1f500) failed
[  255.730751] cma: dma_alloc_from_contiguous(): memory range at c0a40000 is busy, retrying
[  255.739962] alloc_contig_range test_pages_isolated(1b400, 1f600) failed
[  255.746605] cma: dma_alloc_from_contiguous(): memory range at c0a42000 is busy, retrying
[  255.755806] alloc_contig_range test_pages_isolated(1b400, 1f700) failed
[  255.762558] cma: dma_alloc_from_contiguous(): memory range at c0a44000 is busy, retrying
[  255.771813] alloc_contig_range test_pages_isolated(1b800, 1f800) failed
[  255.778438] cma: dma_alloc_from_contiguous(): memory range at c0a46000 is busy, retrying
[  255.786519] cma: dma_alloc_from_contiguous(): returned   (null)
[  255.792423] failed to allocate 67108864 bytes
[  255.796779] cma: dma_alloc_from_contiguous(cma cf473fc0, count 32768, align 8)
[  255.808519] alloc_contig_range test_pages_isolated(fc00, 17c00) failed
[  255.815061] cma: dma_alloc_from_contiguous(): memory range at c08ce000 is busy, retrying
[  255.826619] alloc_contig_range test_pages_isolated(fc00, 17d00) failed
[  255.833161] cma: dma_alloc_from_contiguous(): memory range at c08d0000 is busy, retrying
[  255.844357] alloc_contig_range test_pages_isolated(fc00, 17e00) failed
[  255.850916] cma: dma_alloc_from_contiguous(): memory range at c08d2000 is busy, retrying
[  255.862157] alloc_contig_range test_pages_isolated(fc00, 17f00) failed
[  255.868723] cma: dma_alloc_from_contiguous(): memory range at c08d4000 is busy, retrying
[  255.879687] alloc_contig_range test_pages_isolated(10000, 18000) failed
[  255.886311] cma: dma_alloc_from_contiguous(): memory range at c08d6000 is busy, retrying
[  255.897246] alloc_contig_range test_pages_isolated(10000, 18100) failed
[  255.903872] cma: dma_alloc_from_contiguous(): memory range at c08d8000 is busy, retrying
[  255.914803] alloc_contig_range test_pages_isolated(10000, 18200) failed
[  255.921450] cma: dma_alloc_from_contiguous(): memory range at c08da000 is busy, retrying
[  255.932297] alloc_contig_range test_pages_isolated(10000, 18300) failed
[  255.938942] cma: dma_alloc_from_contiguous(): memory range at c08dc000 is busy, retrying
[  255.949782] alloc_contig_range test_pages_isolated(10400, 18400) failed
[  255.956408] cma: dma_alloc_from_contiguous(): memory range at c08de000 is busy, retrying
[  255.967457] alloc_contig_range test_pages_isolated(10400, 18500) failed
[  255.974085] cma: dma_alloc_from_contiguous(): memory range at c08e0000 is busy, retrying
[  255.984967] alloc_contig_range test_pages_isolated(10400, 18600) failed
[  255.991612] cma: dma_alloc_from_contiguous(): memory range at c08e2000 is busy, retrying
[  256.002439] alloc_contig_range test_pages_isolated(10400, 18700) failed
[  256.009083] cma: dma_alloc_from_contiguous(): memory range at c08e4000 is busy, retrying
[  256.020029] alloc_contig_range test_pages_isolated(10800, 18800) failed
[  256.026672] cma: dma_alloc_from_contiguous(): memory range at c08e6000 is busy, retrying
[  256.037508] alloc_contig_range test_pages_isolated(10800, 18900) failed
[  256.044135] cma: dma_alloc_from_contiguous(): memory range at c08e8000 is busy, retrying
[  256.054986] alloc_contig_range test_pages_isolated(10800, 18a00) failed
[  256.061757] cma: dma_alloc_from_contiguous(): memory range at c08ea000 is busy, retrying
[  256.072717] alloc_contig_range test_pages_isolated(10800, 18b00) failed
[  256.079364] cma: dma_alloc_from_contiguous(): memory range at c08ec000 is busy, retrying
[  256.090243] alloc_contig_range test_pages_isolated(10c00, 18c00) failed
[  256.096898] cma: dma_alloc_from_contiguous(): memory range at c08ee000 is busy, retrying
[  256.107803] alloc_contig_range test_pages_isolated(10c00, 18d00) failed
[  256.114431] cma: dma_alloc_from_contiguous(): memory range at c08f0000 is busy, retrying
[  256.125298] alloc_contig_range test_pages_isolated(10c00, 18e00) failed
[  256.131947] cma: dma_alloc_from_contiguous(): memory range at c08f2000 is busy, retrying
[  256.142793] alloc_contig_range test_pages_isolated(10c00, 18f00) failed
[  256.149437] cma: dma_alloc_from_contiguous(): memory range at c08f4000 is busy, retrying
[  256.160528] alloc_contig_range test_pages_isolated(11000, 19000) failed
[  256.167174] cma: dma_alloc_from_contiguous(): memory range at c08f6000 is busy, retrying
[  256.178037] alloc_contig_range test_pages_isolated(11000, 19100) failed
[  256.184663] cma: dma_alloc_from_contiguous(): memory range at c08f8000 is busy, retrying
[  256.195490] alloc_contig_range test_pages_isolated(11000, 19200) failed
[  256.202133] cma: dma_alloc_from_contiguous(): memory range at c08fa000 is busy, retrying
[  256.212934] alloc_contig_range test_pages_isolated(11000, 19300) failed
[  256.219578] cma: dma_alloc_from_contiguous(): memory range at c08fc000 is busy, retrying
[  256.230361] alloc_contig_range test_pages_isolated(11400, 19400) failed
[  256.237005] cma: dma_alloc_from_contiguous(): memory range at c08fe000 is busy, retrying
[  256.247792] alloc_contig_range test_pages_isolated(11400, 19500) failed
[  256.254417] cma: dma_alloc_from_contiguous(): memory range at c0900000 is busy, retrying
[  256.265428] alloc_contig_range test_pages_isolated(11400, 19600) failed
[  256.272077] cma: dma_alloc_from_contiguous(): memory range at c0902000 is busy, retrying
[  256.282911] alloc_contig_range test_pages_isolated(11400, 19700) failed
[  256.289557] cma: dma_alloc_from_contiguous(): memory range at c0904000 is busy, retrying
[  256.300381] alloc_contig_range test_pages_isolated(11800, 19800) failed
[  256.307025] cma: dma_alloc_from_contiguous(): memory range at c0906000 is busy, retrying
[  256.317841] alloc_contig_range test_pages_isolated(11800, 19900) failed
[  256.324467] cma: dma_alloc_from_contiguous(): memory range at c0908000 is busy, retrying
[  256.335263] alloc_contig_range test_pages_isolated(11800, 19a00) failed
[  256.341905] cma: dma_alloc_from_contiguous(): memory range at c090a000 is busy, retrying
[  256.352722] alloc_contig_range test_pages_isolated(11800, 19b00) failed
[  256.359512] cma: dma_alloc_from_contiguous(): memory range at c090c000 is busy, retrying
[  256.370421] alloc_contig_range test_pages_isolated(11c00, 19c00) failed
[  256.377070] cma: dma_alloc_from_contiguous(): memory range at c090e000 is busy, retrying
[  256.388102] alloc_contig_range test_pages_isolated(11c00, 19d00) failed
[  256.394728] cma: dma_alloc_from_contiguous(): memory range at c0910000 is busy, retrying
[  256.405673] alloc_contig_range test_pages_isolated(11c00, 19e00) failed
[  256.412314] cma: dma_alloc_from_contiguous(): memory range at c0912000 is busy, retrying
[  256.423184] alloc_contig_range test_pages_isolated(11c00, 19f00) failed
[  256.429828] cma: dma_alloc_from_contiguous(): memory range at c0914000 is busy, retrying
[  256.440664] alloc_contig_range test_pages_isolated(12000, 1a000) failed
[  256.447306] cma: dma_alloc_from_contiguous(): memory range at c0916000 is busy, retrying
[  256.458373] alloc_contig_range test_pages_isolated(12000, 1a100) failed
[  256.465001] cma: dma_alloc_from_contiguous(): memory range at c0918000 is busy, retrying
[  256.475910] alloc_contig_range test_pages_isolated(12000, 1a200) failed
[  256.482556] cma: dma_alloc_from_contiguous(): memory range at c091a000 is busy, retrying
[  256.493403] alloc_contig_range test_pages_isolated(12000, 1a300) failed
[  256.500058] cma: dma_alloc_from_contiguous(): memory range at c091c000 is busy, retrying
[  256.510872] alloc_contig_range test_pages_isolated(12400, 1a400) failed
[  256.517517] cma: dma_alloc_from_contiguous(): memory range at c091e000 is busy, retrying
[  256.528343] alloc_contig_range test_pages_isolated(12400, 1a500) failed
[  256.534969] cma: dma_alloc_from_contiguous(): memory range at c0920000 is busy, retrying
[  256.545766] alloc_contig_range test_pages_isolated(12400, 1a600) failed
[  256.552410] cma: dma_alloc_from_contiguous(): memory range at c0922000 is busy, retrying
[  256.563458] alloc_contig_range test_pages_isolated(12400, 1a700) failed
[  256.570106] cma: dma_alloc_from_contiguous(): memory range at c0924000 is busy, retrying
[  256.580955] alloc_contig_range test_pages_isolated(12800, 1a800) failed
[  256.587598] cma: dma_alloc_from_contiguous(): memory range at c0926000 is busy, retrying
[  256.598426] alloc_contig_range test_pages_isolated(12800, 1a900) failed
[  256.605053] cma: dma_alloc_from_contiguous(): memory range at c0928000 is busy, retrying
[  256.615860] alloc_contig_range test_pages_isolated(12800, 1aa00) failed
[  256.622504] cma: dma_alloc_from_contiguous(): memory range at c092a000 is busy, retrying
[  256.633300] alloc_contig_range test_pages_isolated(12800, 1ab00) failed
[  256.639944] cma: dma_alloc_from_contiguous(): memory range at c092c000 is busy, retrying
[  256.650769] alloc_contig_range test_pages_isolated(12c00, 1ac00) failed
[  256.657545] cma: dma_alloc_from_contiguous(): memory range at c092e000 is busy, retrying
[  256.668464] alloc_contig_range test_pages_isolated(12c00, 1ad00) failed
[  256.675090] cma: dma_alloc_from_contiguous(): memory range at c0930000 is busy, retrying
[  256.685947] alloc_contig_range test_pages_isolated(12c00, 1ae00) failed
[  256.692590] cma: dma_alloc_from_contiguous(): memory range at c0932000 is busy, retrying
[  256.703420] alloc_contig_range test_pages_isolated(12c00, 1af00) failed
[  256.710064] cma: dma_alloc_from_contiguous(): memory range at c0934000 is busy, retrying
[  256.720874] alloc_contig_range test_pages_isolated(13000, 1b000) failed
[  256.727517] cma: dma_alloc_from_contiguous(): memory range at c0936000 is busy, retrying
[  256.738331] alloc_contig_range test_pages_isolated(13000, 1b100) failed
[  256.744957] cma: dma_alloc_from_contiguous(): memory range at c0938000 is busy, retrying
[  256.755739] alloc_contig_range test_pages_isolated(13000, 1b200) failed
[  256.762601] cma: dma_alloc_from_contiguous(): memory range at c093a000 is busy, retrying
[  256.773497] alloc_contig_range test_pages_isolated(13000, 1b300) failed
[  256.780143] cma: dma_alloc_from_contiguous(): memory range at c093c000 is busy, retrying
[  256.790994] alloc_contig_range test_pages_isolated(13400, 1b400) failed
[  256.797637] cma: dma_alloc_from_contiguous(): memory range at c093e000 is busy, retrying
[  256.808466] alloc_contig_range test_pages_isolated(13400, 1b500) failed
[  256.815092] cma: dma_alloc_from_contiguous(): memory range at c0940000 is busy, retrying
[  256.825900] alloc_contig_range test_pages_isolated(13400, 1b600) failed
[  256.832544] cma: dma_alloc_from_contiguous(): memory range at c0942000 is busy, retrying
[  256.843337] alloc_contig_range test_pages_isolated(13400, 1b700) failed
[  256.849982] cma: dma_alloc_from_contiguous(): memory range at c0944000 is busy, retrying
[  256.861014] alloc_contig_range test_pages_isolated(13800, 1b800) failed
[  256.867668] cma: dma_alloc_from_contiguous(): memory range at c0946000 is busy, retrying
[  256.878553] alloc_contig_range test_pages_isolated(13800, 1b900) failed
[  256.885180] cma: dma_alloc_from_contiguous(): memory range at c0948000 is busy, retrying
[  256.896026] alloc_contig_range test_pages_isolated(13800, 1ba00) failed
[  256.902685] cma: dma_alloc_from_contiguous(): memory range at c094a000 is busy, retrying
[  256.913554] alloc_contig_range test_pages_isolated(13800, 1bb00) failed
[  256.920202] cma: dma_alloc_from_contiguous(): memory range at c094c000 is busy, retrying
[  256.931077] alloc_contig_range test_pages_isolated(13c00, 1bc00) failed
[  256.937724] cma: dma_alloc_from_contiguous(): memory range at c094e000 is busy, retrying
[  256.948601] alloc_contig_range test_pages_isolated(13c00, 1bd00) failed
[  256.955230] cma: dma_alloc_from_contiguous(): memory range at c0950000 is busy, retrying
[  256.966242] alloc_contig_range test_pages_isolated(13c00, 1be00) failed
[  256.972888] cma: dma_alloc_from_contiguous(): memory range at c0952000 is busy, retrying
[  256.983728] alloc_contig_range test_pages_isolated(13c00, 1bf00) failed
[  256.990372] cma: dma_alloc_from_contiguous(): memory range at c0954000 is busy, retrying
[  257.001178] alloc_contig_range test_pages_isolated(14000, 1c000) failed
[  257.007820] cma: dma_alloc_from_contiguous(): memory range at c0956000 is busy, retrying
[  257.018659] alloc_contig_range test_pages_isolated(14000, 1c100) failed
[  257.025285] cma: dma_alloc_from_contiguous(): memory range at c0958000 is busy, retrying
[  257.036088] alloc_contig_range test_pages_isolated(14000, 1c200) failed
[  257.042732] cma: dma_alloc_from_contiguous(): memory range at c095a000 is busy, retrying
[  257.053510] alloc_contig_range test_pages_isolated(14000, 1c300) failed
[  257.060308] cma: dma_alloc_from_contiguous(): memory range at c095c000 is busy, retrying
[  257.071172] alloc_contig_range test_pages_isolated(14400, 1c400) failed
[  257.077816] cma: dma_alloc_from_contiguous(): memory range at c095e000 is busy, retrying
[  257.088656] alloc_contig_range test_pages_isolated(14400, 1c500) failed
[  257.095282] cma: dma_alloc_from_contiguous(): memory range at c0960000 is busy, retrying
[  257.106110] alloc_contig_range test_pages_isolated(14400, 1c600) failed
[  257.112753] cma: dma_alloc_from_contiguous(): memory range at c0962000 is busy, retrying
[  257.123569] alloc_contig_range test_pages_isolated(14400, 1c700) failed
[  257.130213] cma: dma_alloc_from_contiguous(): memory range at c0964000 is busy, retrying
[  257.141002] alloc_contig_range test_pages_isolated(14800, 1c800) failed
[  257.147645] cma: dma_alloc_from_contiguous(): memory range at c0966000 is busy, retrying
[  257.158586] alloc_contig_range test_pages_isolated(14800, 1c900) failed
[  257.165213] cma: dma_alloc_from_contiguous(): memory range at c0968000 is busy, retrying
[  257.176058] alloc_contig_range test_pages_isolated(14800, 1ca00) failed
[  257.182701] cma: dma_alloc_from_contiguous(): memory range at c096a000 is busy, retrying
[  257.193499] alloc_contig_range test_pages_isolated(14800, 1cb00) failed
[  257.200144] cma: dma_alloc_from_contiguous(): memory range at c096c000 is busy, retrying
[  257.210933] alloc_contig_range test_pages_isolated(14c00, 1cc00) failed
[  257.217576] cma: dma_alloc_from_contiguous(): memory range at c096e000 is busy, retrying
[  257.228377] alloc_contig_range test_pages_isolated(14c00, 1cd00) failed
[  257.235002] cma: dma_alloc_from_contiguous(): memory range at c0970000 is busy, retrying
[  257.245783] alloc_contig_range test_pages_isolated(14c00, 1ce00) failed
[  257.252450] cma: dma_alloc_from_contiguous(): memory range at c0972000 is busy, retrying
[  257.263459] alloc_contig_range test_pages_isolated(14c00, 1cf00) failed
[  257.270110] cma: dma_alloc_from_contiguous(): memory range at c0974000 is busy, retrying
[  257.280979] alloc_contig_range test_pages_isolated(15000, 1d000) failed
[  257.287622] cma: dma_alloc_from_contiguous(): memory range at c0976000 is busy, retrying
[  257.298550] alloc_contig_range test_pages_isolated(15000, 1d100) failed
[  257.305178] cma: dma_alloc_from_contiguous(): memory range at c0978000 is busy, retrying
[  257.316110] alloc_contig_range test_pages_isolated(15000, 1d200) failed
[  257.322753] cma: dma_alloc_from_contiguous(): memory range at c097a000 is busy, retrying
[  257.333620] alloc_contig_range test_pages_isolated(15000, 1d300) failed
[  257.340268] cma: dma_alloc_from_contiguous(): memory range at c097c000 is busy, retrying
[  257.351118] alloc_contig_range test_pages_isolated(15400, 1d400) failed
[  257.357915] cma: dma_alloc_from_contiguous(): memory range at c097e000 is busy, retrying
[  257.368840] alloc_contig_range test_pages_isolated(15400, 1d500) failed
[  257.375465] cma: dma_alloc_from_contiguous(): memory range at c0980000 is busy, retrying
[  257.386323] alloc_contig_range test_pages_isolated(15400, 1d600) failed
[  257.392966] cma: dma_alloc_from_contiguous(): memory range at c0982000 is busy, retrying
[  257.403791] alloc_contig_range test_pages_isolated(15400, 1d700) failed
[  257.410433] cma: dma_alloc_from_contiguous(): memory range at c0984000 is busy, retrying
[  257.421236] alloc_contig_range test_pages_isolated(15800, 1d800) failed
[  257.427878] cma: dma_alloc_from_contiguous(): memory range at c0986000 is busy, retrying
[  257.438677] alloc_contig_range test_pages_isolated(15800, 1d900) failed
[  257.445304] cma: dma_alloc_from_contiguous(): memory range at c0988000 is busy, retrying
[  257.456094] alloc_contig_range test_pages_isolated(15800, 1da00) failed
[  257.462841] cma: dma_alloc_from_contiguous(): memory range at c098a000 is busy, retrying
[  257.473733] alloc_contig_range test_pages_isolated(15800, 1db00) failed
[  257.480379] cma: dma_alloc_from_contiguous(): memory range at c098c000 is busy, retrying
[  257.491209] alloc_contig_range test_pages_isolated(15c00, 1dc00) failed
[  257.497863] cma: dma_alloc_from_contiguous(): memory range at c098e000 is busy, retrying
[  257.508695] alloc_contig_range test_pages_isolated(15c00, 1dd00) failed
[  257.515322] cma: dma_alloc_from_contiguous(): memory range at c0990000 is busy, retrying
[  257.526138] alloc_contig_range test_pages_isolated(15c00, 1de00) failed
[  257.532781] cma: dma_alloc_from_contiguous(): memory range at c0992000 is busy, retrying
[  257.543570] alloc_contig_range test_pages_isolated(15c00, 1df00) failed
[  257.550238] cma: dma_alloc_from_contiguous(): memory range at c0994000 is busy, retrying
[  257.561372] alloc_contig_range test_pages_isolated(16000, 1e000) failed
[  257.568024] cma: dma_alloc_from_contiguous(): memory range at c0996000 is busy, retrying
[  257.578941] alloc_contig_range test_pages_isolated(16000, 1e100) failed
[  257.585567] cma: dma_alloc_from_contiguous(): memory range at c0998000 is busy, retrying
[  257.596443] alloc_contig_range test_pages_isolated(16000, 1e200) failed
[  257.603070] cma: dma_alloc_from_contiguous(): memory range at c099a000 is busy, retrying
[  257.613941] alloc_contig_range test_pages_isolated(16000, 1e300) failed
[  257.620587] cma: dma_alloc_from_contiguous(): memory range at c099c000 is busy, retrying
[  257.631422] alloc_contig_range test_pages_isolated(16400, 1e400) failed
[  257.638069] cma: dma_alloc_from_contiguous(): memory range at c099e000 is busy, retrying
[  257.648908] alloc_contig_range test_pages_isolated(16400, 1e500) failed
[  257.655534] cma: dma_alloc_from_contiguous(): memory range at c09a0000 is busy, retrying
[  257.666662] alloc_contig_range test_pages_isolated(16400, 1e600) failed
[  257.673291] cma: dma_alloc_from_contiguous(): memory range at c09a2000 is busy, retrying
[  257.684179] alloc_contig_range test_pages_isolated(16400, 1e700) failed
[  257.690825] cma: dma_alloc_from_contiguous(): memory range at c09a4000 is busy, retrying
[  257.701700] alloc_contig_range test_pages_isolated(16800, 1e800) failed
[  257.708347] cma: dma_alloc_from_contiguous(): memory range at c09a6000 is busy, retrying
[  257.719168] alloc_contig_range test_pages_isolated(16800, 1e900) failed
[  257.725794] cma: dma_alloc_from_contiguous(): memory range at c09a8000 is busy, retrying
[  257.736644] alloc_contig_range test_pages_isolated(16800, 1ea00) failed
[  257.743270] cma: dma_alloc_from_contiguous(): memory range at c09aa000 is busy, retrying
[  257.754094] alloc_contig_range test_pages_isolated(16800, 1eb00) failed
[  257.760862] cma: dma_alloc_from_contiguous(): memory range at c09ac000 is busy, retrying
[  257.771810] alloc_contig_range test_pages_isolated(16c00, 1ec00) failed
[  257.778455] cma: dma_alloc_from_contiguous(): memory range at c09ae000 is busy, retrying
[  257.789335] alloc_contig_range test_pages_isolated(16c00, 1ed00) failed
[  257.795962] cma: dma_alloc_from_contiguous(): memory range at c09b0000 is busy, retrying
[  257.806855] alloc_contig_range test_pages_isolated(16c00, 1ee00) failed
[  257.813481] cma: dma_alloc_from_contiguous(): memory range at c09b2000 is busy, retrying
[  257.824313] alloc_contig_range test_pages_isolated(16c00, 1ef00) failed
[  257.830960] cma: dma_alloc_from_contiguous(): memory range at c09b4000 is busy, retrying
[  257.841789] alloc_contig_range test_pages_isolated(17000, 1f000) failed
[  257.848457] cma: dma_alloc_from_contiguous(): memory range at c09b6000 is busy, retrying
[  257.859636] alloc_contig_range test_pages_isolated(17000, 1f100) failed
[  257.866262] cma: dma_alloc_from_contiguous(): memory range at c09b8000 is busy, retrying
[  257.877207] alloc_contig_range test_pages_isolated(17000, 1f200) failed
[  257.883834] cma: dma_alloc_from_contiguous(): memory range at c09ba000 is busy, retrying
[  257.894696] alloc_contig_range test_pages_isolated(17000, 1f300) failed
[  257.901352] cma: dma_alloc_from_contiguous(): memory range at c09bc000 is busy, retrying
[  257.912215] alloc_contig_range test_pages_isolated(17400, 1f400) failed
[  257.918862] cma: dma_alloc_from_contiguous(): memory range at c09be000 is busy, retrying
[  257.929720] alloc_contig_range test_pages_isolated(17400, 1f500) failed
[  257.936347] cma: dma_alloc_from_contiguous(): memory range at c09c0000 is busy, retrying
[  257.947191] alloc_contig_range test_pages_isolated(17400, 1f600) failed
[  257.953819] cma: dma_alloc_from_contiguous(): memory range at c09c2000 is busy, retrying
[  257.964916] alloc_contig_range test_pages_isolated(17400, 1f700) failed
[  257.971563] cma: dma_alloc_from_contiguous(): memory range at c09c4000 is busy, retrying
[  257.982416] alloc_contig_range test_pages_isolated(17800, 1f800) failed
[  257.989058] cma: dma_alloc_from_contiguous(): memory range at c09c6000 is busy, retrying
[  257.997141] cma: dma_alloc_from_contiguous(): returned   (null)
[  258.003046] failed to allocate 134217728 bytes
[  258.007491] cma: dma_alloc_from_contiguous(cma cf473fc0, count 65536, align 8)
[  258.014695] cma: dma_alloc_from_contiguous(): returned   (null)
[  258.020903] failed to allocate 268435456 bytes
[  258.025801] modprobe: page allocation failure: order:0, mode:0x20
[  258.031908] [<c0013e5c>] (unwind_backtrace+0x0/0xf8) from [<c00908c8>] (warn_alloc_failed+0xc8/0x108)
[  258.041116] [<c00908c8>] (warn_alloc_failed+0xc8/0x108) from [<c0093824>] (__alloc_pages_nodemask+0x5ec/0x800)
[  258.051106] [<c0093824>] (__alloc_pages_nodemask+0x5ec/0x800) from [<c00be9b4>] (cache_alloc_refill+0x404/0x874)
[  258.061262] [<c00be9b4>] (cache_alloc_refill+0x404/0x874) from [<c00bf22c>] (kmem_cache_alloc+0xf0/0x12c)
[  258.070814] [<c00bf22c>] (kmem_cache_alloc+0xf0/0x12c) from [<c0031c3c>] (__sigqueue_alloc+0xc4/0x120)
[  258.080106] [<c0031c3c>] (__sigqueue_alloc+0xc4/0x120) from [<c0032c5c>] (__send_signal.constprop.23+0x8c/0x228)
[  258.090264] [<c0032c5c>] (__send_signal.constprop.23+0x8c/0x228) from [<c0033e88>] (do_notify_parent+0x184/0x1e8)
[  258.100511] [<c0033e88>] (do_notify_parent+0x184/0x1e8) from [<c0029bac>] (do_exit+0x4fc/0x78c)
[  258.109193] [<c0029bac>] (do_exit+0x4fc/0x78c) from [<c002a150>] (do_group_exit+0x3c/0xb0)
[  258.117441] [<c002a150>] (do_group_exit+0x3c/0xb0) from [<c002a1d4>] (__wake_up_parent+0x0/0x18)
[  258.126203] Mem-info:
[  258.128465] Normal per-cpu:
[  258.131249] CPU    0: hi:  186, btch:  31 usd:   0
[  258.136024] CPU    1: hi:  186, btch:  31 usd:  24
[  258.140808] active_anon:715 inactive_anon:3175 isolated_anon:0
[  258.140808]  active_file:953 inactive_file:3185 isolated_file:0
[  258.140808]  unevictable:0 dirty:0 writeback:0 unstable:0
[  258.140808]  free:0 slab_reclaimable:755 slab_unreclaimable:1223
[  258.140808]  mapped:1160 shmem:3196 pagetables:41 bounce:0
[  258.140808]  free_cma:0
[  258.171778] Normal free:0kB min:3500kB low:4372kB high:5248kB active_anon:2860kB inactive_anon:12700kB active_file:3812kB inactive_file:12740kB unevictable:0kB isolated(anon):0kB isolated(file):0kB present:767428kB mlocked:0kB dirty:0kB writeback:0kB mapped:4640kB shmem:12784kB slab_reclaimable:3020kB slab_unreclaimable:4892kB kernel_stack:440kB pagetables:164kB unstable:0kB bounce:0kB free_cma:0kB writeback_tmp:0kB pages_scanned:0 all_unreclaimable? no
[  258.211828] lowmem_reserve[]: 0 0 0
[  258.215324] Normal: 570*4kB 306*8kB 265*16kB 138*32kB 128*64kB 33*128kB 16*256kB 5*512kB 6*1024kB 1*2048kB 105*4096kB = 470728kB
[  258.226928] 7334 total pagecache pages
[  258.230663] 0 pages in swap cache
[  258.233966] Swap cache stats: add 0, delete 0, find 0/0
[  258.239174] Free swap  = 0kB
[  258.242041] Total swap = 0kB
[  258.260503] 131072 pages of RAM
[  258.263633] 117791 free pages
[  258.266587] 2995 reserved pages
[  258.269715] 1978 slab pages
[  258.272496] 3430 pages shared
[  258.275451] 0 pages swap cached
[  258.278582] SLAB: Unable to allocate memory on node 0 (gfp=0x20)
[  258.284573]   cache: sigqueue, object size: 168, order: 0
[  258.289955]   node 0: slabs: 0/0, objs: 0/0, free: 0
-sh-4.2# 
--tsOsTdHNUZQcU9Ye--

--FsscpQKzF/jJk6ya
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.19 (GNU/Linux)

iQIcBAEBAgAGBQJQaaecAAoJEN0jrNd/PrOhAi0P/iOADJUdmCjJLGkbZcuig6sG
0+ApVFREwGp4tzO+YK3WfpqV97fVdOugIcgyfvbYmunOVxSA7wiqoBXroDag2CJq
a+Xs1RVAwYjDzjsawedUMUJzrjtex47ruRAphTD7qXo6BGeBy0nG+XcVtVE3QQ9h
IonZY0L3ncjFUBemQsYr9UVs1xODHM30HfYiXA8LtT1Gyp/+ptKGauUYEu2MdR3T
1VSiFSGGyRh47AyoR2aXP9GwKhYJZarFkyH0hteDataat7P1vvbkwUDabSeZohQ2
fbeLJ8NWm7AVoLWoqQLfzNdVRvCYGwM74nc52YXnfWZ1J5GWj5Ak6gtMUgPpIRRi
btK/5ZgRhHSFPNwySPEXPeo4ZQyC8CcIPSxBdNMluI2/2vBzZnFa1ZhpJabznngZ
0/RGlaaiSEAYHm1dNYma5jJNqEBUgxVz5zquyA0GHMbhD9gSTzTnUE13RoBXZtSM
GFKeNEt9t/voYgsJEQCO68gX8fUINGrsPRgOFM35OnVjXqaJa9mALUwfIKnrn8Aq
0zrxptBbvGV9Suu6iuv2RpVJsUa4peJT/Cc1Dls0klU2cu8y2/r9veZ6WkCxYo7G
zb7O0sjWgf6OdMmVl6SRGvr5qWAVEezbPE3lzvMQNg3NEnRNdqEYksvFzgKmXtQa
biQzJvOtnaBsxldVRySg
=67pu
-----END PGP SIGNATURE-----

--FsscpQKzF/jJk6ya--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
