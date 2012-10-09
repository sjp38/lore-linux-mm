Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx206.postini.com [74.125.245.206])
	by kanga.kvack.org (Postfix) with SMTP id 063F46B002B
	for <linux-mm@kvack.org>; Tue,  9 Oct 2012 06:11:50 -0400 (EDT)
Date: Tue, 9 Oct 2012 11:11:43 +0100
From: Mel Gorman <mgorman@suse.de>
Subject: Re: CMA broken in next-20120926
Message-ID: <20121009101143.GQ29125@suse.de>
References: <20120928105113.GA18883@avionic-0098.mockup.avionic-design.de>
 <20121008080654.GD13817@bbox>
 <20121008084806.GH29125@suse.de>
 <201210091040.10811.b.zolnierkie@samsung.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <201210091040.10811.b.zolnierkie@samsung.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Bartlomiej Zolnierkiewicz <b.zolnierkie@samsung.com>
Cc: Minchan Kim <minchan@kernel.org>, Thierry Reding <thierry.reding@avionic-design.de>, Peter Ujfalusi <peter.ujfalusi@ti.com>, Andrew Morton <akpm@linux-foundation.org>, Marek Szyprowski <m.szyprowski@samsung.com>, Michal Nazarewicz <mina86@mina86.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Kyungmin Park <kyungmin.park@samsung.com>, Mark Brown <broonie@opensource.wolfsonmicro.com>

On Tue, Oct 09, 2012 at 10:40:10AM +0200, Bartlomiej Zolnierkiewicz wrote:
> I also need following patch to make CONFIG_CMA=y && CONFIG_COMPACTION=y case
> work:
> 
> From: Bartlomiej Zolnierkiewicz <b.zolnierkie@samsung.com>
> Subject: [PATCH] mm: compaction: cache if a pageblock was scanned and no pages were isolated - cma fix
> 
> Patch "mm: compaction: cache if a pageblock was scanned and no pages
> were isolated" needs a following fix to successfully boot next-20121002
> kernel (same with next-20121008) with CONFIG_CMA=y and CONFIG_COMPACTION=y
> (with applied -fix1, -fix2, -fix3 patches from Mel Gorman and also with
> cmatest module from Thierry Reding compiled in).
> 

Why is it needed to make it boot? CMA should not care about the
PG_migrate_skip hint being set because it should always ignore it in
alloc_contig_range() due to cc->ignore_skip_hint. It's not obvious to
me why this fixes a boot failure and I wonder if it's papering over some
underlying problem. Can you provide more details please?

> Signed-off-by: Bartlomiej Zolnierkiewicz <b.zolnierkie@samsung.com>
> Signed-off-by: Kyungmin Park <kyungmin.park@samsung.com>
> ---
>  mm/compaction.c |    3 ++-
>  1 file changed, 2 insertions(+), 1 deletion(-)
> 
> Index: b/mm/compaction.c
> ===================================================================
> --- a/mm/compaction.c	2012-10-08 18:10:53.491679716 +0200
> +++ b/mm/compaction.c	2012-10-08 18:11:33.615679713 +0200
> @@ -117,7 +117,8 @@ static void update_pageblock_skip(struct
>  			bool migrate_scanner)
>  {
>  	struct zone *zone = cc->zone;
> -	if (!page)
> +
> +	if (!page || cc->ignore_skip_hint)
>  		return;
>  
>  	if (!nr_isolated) {

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
