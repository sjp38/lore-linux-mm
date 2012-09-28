Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx193.postini.com [74.125.245.193])
	by kanga.kvack.org (Postfix) with SMTP id 44D036B0068
	for <linux-mm@kvack.org>; Fri, 28 Sep 2012 07:07:19 -0400 (EDT)
Date: Fri, 28 Sep 2012 12:07:12 +0100
From: Mel Gorman <mgorman@suse.de>
Subject: Re: CMA broken in next-20120926
Message-ID: <20120928110712.GB29125@suse.de>
References: <20120927112911.GA25959@avionic-0098.mockup.avionic-design.de>
 <20120927151159.4427fc8f.akpm@linux-foundation.org>
 <20120928054330.GA27594@bbox>
 <20120928083722.GM3429@suse.de>
 <50656459.70309@ti.com>
 <20120928102728.GN3429@suse.de>
 <20120928103207.GA22811@avionic-0098.mockup.avionic-design.de>
 <20120928103815.GA15219@avionic-0098.mockup.avionic-design.de>
 <20120928105113.GA18883@avionic-0098.mockup.avionic-design.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20120928105113.GA18883@avionic-0098.mockup.avionic-design.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Thierry Reding <thierry.reding@avionic-design.de>
Cc: Peter Ujfalusi <peter.ujfalusi@ti.com>, Minchan Kim <minchan@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Marek Szyprowski <m.szyprowski@samsung.com>, Michal Nazarewicz <mina86@mina86.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Bartlomiej Zolnierkiewicz <b.zolnierkie@samsung.com>, Kyungmin Park <kyungmin.park@samsung.com>, Mark Brown <broonie@opensource.wolfsonmicro.com>

On Fri, Sep 28, 2012 at 12:51:13PM +0200, Thierry Reding wrote:
> On Fri, Sep 28, 2012 at 12:38:15PM +0200, Thierry Reding wrote:
> > On Fri, Sep 28, 2012 at 12:32:07PM +0200, Thierry Reding wrote:
> > > On Fri, Sep 28, 2012 at 11:27:28AM +0100, Mel Gorman wrote:
> > > > On Fri, Sep 28, 2012 at 11:48:25AM +0300, Peter Ujfalusi wrote:
> > > > > Hi,
> > > > > 
> > > > > On 09/28/2012 11:37 AM, Mel Gorman wrote:
> > > > > >> I hope this patch fixes the bug. If this patch fixes the problem
> > > > > >> but has some problem about description or someone has better idea,
> > > > > >> feel free to modify and resend to akpm, Please.
> > > > > >>
> > > > > > 
> > > > > > A full revert is overkill. Can the following patch be tested as a
> > > > > > potential replacement please?
> > > > > > 
> > > > > > ---8<---
> > > > > > mm: compaction: Iron out isolate_freepages_block() and isolate_freepages_range() -fix1
> > > > > > 
> > > > > > CMA is reported to be broken in next-20120926. Minchan Kim pointed out
> > > > > > that this was due to nr_scanned != total_isolated in the case of CMA
> > > > > > because PageBuddy pages are one scan but many isolations in CMA. This
> > > > > > patch should address the problem.
> > > > > > 
> > > > > > This patch is a fix for
> > > > > > mm-compaction-acquire-the-zone-lock-as-late-as-possible-fix-2.patch
> > > > > > 
> > > > > > Signed-off-by: Mel Gorman <mgorman@suse.de>
> > > > > 
> > > > > linux-next + this patch alone also works for me.
> > > > > 
> > > > > Tested-by: Peter Ujfalusi <peter.ujfalusi@ti.com>
> > > > 
> > > > Thanks Peter. I expect it also works for Thierry as I expect you were
> > > > suffering the same problem but obviously confirmation of that would be nice.
> > > 
> > > I've been running a few tests and indeed this solves the obvious problem
> > > that the coherent pool cannot be created at boot (which in turn caused
> > > the ethernet adapter to fail on Tegra).
> > > 
> > > However I've been working on the Tegra DRM driver, which uses CMA to
> > > allocate large chunks of framebuffer memory and these are now failing.
> > > I'll need to check if Minchan's patch solves that problem as well.
> > 
> > Indeed, with Minchan's patch the DRM can allocate the framebuffer
> > without a problem. Something else must be wrong then.
> 
> However, depending on the size of the allocation it also happens with
> Minchan's patch. What I see is this:
> 
> [   60.736729] alloc_contig_range test_pages_isolated(1e900, 1f0e9) failed
> [   60.743572] alloc_contig_range test_pages_isolated(1ea00, 1f1e9) failed
> [   60.750424] alloc_contig_range test_pages_isolated(1ea00, 1f2e9) failed
> [   60.757239] alloc_contig_range test_pages_isolated(1ec00, 1f3e9) failed
> [   60.764066] alloc_contig_range test_pages_isolated(1ec00, 1f4e9) failed
> [   60.770893] alloc_contig_range test_pages_isolated(1ec00, 1f5e9) failed
> [   60.777698] alloc_contig_range test_pages_isolated(1ec00, 1f6e9) failed
> [   60.784526] alloc_contig_range test_pages_isolated(1f000, 1f7e9) failed
> [   60.791148] drm tegra: Failed to alloc buffer: 8294400
> 
> I'm pretty sure this did work before next-20120926.
> 

Can you double check this please?

This is a separate bug but may be related to the same series. However, CMA should
be ignoring the "skip" hints and because it's sync compaction it should
not be exiting due to lock contention. Maybe Marek will spot it.

Failing that, would you be in a position to bisect between v3.6-rc6 and
current next to try pin-point exactly which patch introduced this
problem please?

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
