Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx127.postini.com [74.125.245.127])
	by kanga.kvack.org (Postfix) with SMTP id 658A66B002B
	for <linux-mm@kvack.org>; Tue,  9 Oct 2012 04:41:35 -0400 (EDT)
Received: from epcpsbgm1.samsung.com (epcpsbgm1 [203.254.230.26])
 by mailout3.samsung.com
 (Oracle Communications Messaging Server 7u4-24.01(7.0.4.24.0) 64bit (built Nov
 17 2011)) with ESMTP id <0MBM003WJASE5VV0@mailout3.samsung.com> for
 linux-mm@kvack.org; Tue, 09 Oct 2012 17:41:33 +0900 (KST)
Received: from amdc1032.localnet ([106.116.147.136])
 by mmp2.samsung.com (Oracle Communications Messaging Server 7u4-24.01
 (7.0.4.24.0) 64bit (built Nov 17 2011))
 with ESMTPA id <0MBM007INAT7I040@mmp2.samsung.com> for linux-mm@kvack.org;
 Tue, 09 Oct 2012 17:41:33 +0900 (KST)
From: Bartlomiej Zolnierkiewicz <b.zolnierkie@samsung.com>
Subject: Re: CMA broken in next-20120926
Date: Tue, 09 Oct 2012 10:40:10 +0200
References: <20120928105113.GA18883@avionic-0098.mockup.avionic-design.de>
 <20121008080654.GD13817@bbox> <20121008084806.GH29125@suse.de>
In-reply-to: <20121008084806.GH29125@suse.de>
MIME-version: 1.0
Content-type: Text/Plain; charset=us-ascii
Content-transfer-encoding: 7bit
Message-id: <201210091040.10811.b.zolnierkie@samsung.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: Minchan Kim <minchan@kernel.org>, Thierry Reding <thierry.reding@avionic-design.de>, Peter Ujfalusi <peter.ujfalusi@ti.com>, Andrew Morton <akpm@linux-foundation.org>, Marek Szyprowski <m.szyprowski@samsung.com>, Michal Nazarewicz <mina86@mina86.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Kyungmin Park <kyungmin.park@samsung.com>, Mark Brown <broonie@opensource.wolfsonmicro.com>


Hi,

On Monday 08 October 2012 10:48:07 Mel Gorman wrote:
> On Mon, Oct 08, 2012 at 05:06:54PM +0900, Minchan Kim wrote:
> > Hi Mel,
> > 
> > On Tue, Oct 02, 2012 at 04:12:17PM +0100, Mel Gorman wrote:
> > > On Tue, Oct 02, 2012 at 05:03:07PM +0200, Thierry Reding wrote:
> > > > On Tue, Oct 02, 2012 at 03:41:35PM +0100, Mel Gorman wrote:
> > > > > On Tue, Oct 02, 2012 at 02:48:14PM +0200, Thierry Reding wrote:
> > > > > > > So this really isn't all that new, but I just wanted to confirm my
> > > > > > > results from last week. We'll see if bisection shows up something
> > > > > > > interesting.
> > > > > > 
> > > > > > I just finished bisecting this and git reports:
> > > > > > 
> > > > > > 	3750280f8bd0ed01753a72542756a8c82ab27933 is the first bad commit
> > > > > > 
> > > > > > I'm attaching the complete bisection log and a diff of all the changes
> > > > > > applied on top of the bad commit to make it compile and run on my board.
> > > > > > Most of the patch is probably not important, though. There are two hunks
> > > > > > which have the pageblock changes I already posted an two other hunks
> > > > > > with the patch you posted earlier.
> > > > > > 
> > > > > > I hope this helps. If you want me to run any other tests, please let me
> > > > > > know.
> > > > > > 
> > > > > 
> > > > > Can you test with this on top please?
> > > > 
> > > > That doesn't build on top of the bad commit. Or is it supposed to go on
> > > > top of next-20120926?
> > > > 
> > > 
> > > It doesn't build or do you mean it doesn't apply? Assuming the problem
> > > was that it didn't apply then try this one. It applies on top of
> > > next-20120928 which is the closest tag I have to next-20120926.
> > > 
> > > ---8<---
> > > mm: compaction: Cache if a pageblock was scanned and no pages were isolated -fix3
> > > 
> > > CMA requires that the PG_migrate_skip hint be skipped but it was only
> > > skipping it when isolating pages for migration, not for free. Ensure
> > > cc->isolate_skip_hint gets passed in both cases.
> > > 
> > > This is a fix for
> > > mm-compaction-cache-if-a-pageblock-was-scanned-and-no-pages-were-isolated-fix.patch
> > > 
> > > Signed-off-by: Mel Gorman <mgorman@suse.de>
> > Acked-by: Minchan Kim <minchan@kernel.org>
> > 
> > But please resend below compile error fixing.
> > 
> 
> Thanks Minchan. I did resent this patch to Andrew with the subject "[PATCH]
> mm: compaction: Cache if a pageblock was scanned and no pages were isolated
> -fix3". It should have had the build errors fixed but has not been
> picked up yet.

I also need following patch to make CONFIG_CMA=y && CONFIG_COMPACTION=y case
work:

From: Bartlomiej Zolnierkiewicz <b.zolnierkie@samsung.com>
Subject: [PATCH] mm: compaction: cache if a pageblock was scanned and no pages were isolated - cma fix

Patch "mm: compaction: cache if a pageblock was scanned and no pages
were isolated" needs a following fix to successfully boot next-20121002
kernel (same with next-20121008) with CONFIG_CMA=y and CONFIG_COMPACTION=y
(with applied -fix1, -fix2, -fix3 patches from Mel Gorman and also with
cmatest module from Thierry Reding compiled in).

Signed-off-by: Bartlomiej Zolnierkiewicz <b.zolnierkie@samsung.com>
Signed-off-by: Kyungmin Park <kyungmin.park@samsung.com>
---
 mm/compaction.c |    3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

Index: b/mm/compaction.c
===================================================================
--- a/mm/compaction.c	2012-10-08 18:10:53.491679716 +0200
+++ b/mm/compaction.c	2012-10-08 18:11:33.615679713 +0200
@@ -117,7 +117,8 @@ static void update_pageblock_skip(struct
 			bool migrate_scanner)
 {
 	struct zone *zone = cc->zone;
-	if (!page)
+
+	if (!page || cc->ignore_skip_hint)
 		return;
 
 	if (!nr_isolated) {

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
