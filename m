Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx157.postini.com [74.125.245.157])
	by kanga.kvack.org (Postfix) with SMTP id 9F5C46B0068
	for <linux-mm@kvack.org>; Fri, 28 Sep 2012 04:47:13 -0400 (EDT)
Received: by obcva7 with SMTP id va7so3387489obc.14
        for <linux-mm@kvack.org>; Fri, 28 Sep 2012 01:47:12 -0700 (PDT)
Message-ID: <50656459.70309@ti.com>
Date: Fri, 28 Sep 2012 11:48:25 +0300
From: Peter Ujfalusi <peter.ujfalusi@ti.com>
MIME-Version: 1.0
Subject: Re: CMA broken in next-20120926
References: <20120927112911.GA25959@avionic-0098.mockup.avionic-design.de> <20120927151159.4427fc8f.akpm@linux-foundation.org> <20120928054330.GA27594@bbox> <20120928083722.GM3429@suse.de>
In-Reply-To: <20120928083722.GM3429@suse.de>
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: Minchan Kim <minchan@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Thierry Reding <thierry.reding@avionic-design.de>, Marek Szyprowski <m.szyprowski@samsung.com>, Michal Nazarewicz <mina86@mina86.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Bartlomiej Zolnierkiewicz <b.zolnierkie@samsung.com>, Kyungmin Park <kyungmin.park@samsung.com>, Mark Brown <broonie@opensource.wolfsonmicro.com>

Hi,

On 09/28/2012 11:37 AM, Mel Gorman wrote:
>> I hope this patch fixes the bug. If this patch fixes the problem
>> but has some problem about description or someone has better idea,
>> feel free to modify and resend to akpm, Please.
>>
> 
> A full revert is overkill. Can the following patch be tested as a
> potential replacement please?
> 
> ---8<---
> mm: compaction: Iron out isolate_freepages_block() and isolate_freepages_range() -fix1
> 
> CMA is reported to be broken in next-20120926. Minchan Kim pointed out
> that this was due to nr_scanned != total_isolated in the case of CMA
> because PageBuddy pages are one scan but many isolations in CMA. This
> patch should address the problem.
> 
> This patch is a fix for
> mm-compaction-acquire-the-zone-lock-as-late-as-possible-fix-2.patch
> 
> Signed-off-by: Mel Gorman <mgorman@suse.de>

linux-next + this patch alone also works for me.

Tested-by: Peter Ujfalusi <peter.ujfalusi@ti.com>

> ---
>  mm/compaction.c |    5 +++--
>  1 file changed, 3 insertions(+), 2 deletions(-)
> 
> diff --git a/mm/compaction.c b/mm/compaction.c
> index 8250b69..d6e260a 100644
> --- a/mm/compaction.c
> +++ b/mm/compaction.c
> @@ -282,6 +282,7 @@ static unsigned long isolate_freepages_block(struct compact_control *cc,
>  {
>  	int nr_scanned = 0, total_isolated = 0;
>  	struct page *cursor, *valid_page = NULL;
> +	unsigned long nr_strict_required = end_pfn - blockpfn;
>  	unsigned long flags;
>  	bool locked = false;
>  
> @@ -343,10 +344,10 @@ static unsigned long isolate_freepages_block(struct compact_control *cc,
>  
>  	/*
>  	 * If strict isolation is requested by CMA then check that all the
> -	 * pages scanned were isolated. If there were any failures, 0 is
> +	 * pages requested were isolated. If there were any failures, 0 is
>  	 * returned and CMA will fail.
>  	 */
> -	if (strict && nr_scanned != total_isolated)
> +	if (strict && nr_strict_required != total_isolated)
>  		total_isolated = 0;
>  
>  	if (locked)
> 


-- 
Peter

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
