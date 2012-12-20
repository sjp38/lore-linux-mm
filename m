Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx126.postini.com [74.125.245.126])
	by kanga.kvack.org (Postfix) with SMTP id 043ED6B0069
	for <linux-mm@kvack.org>; Thu, 20 Dec 2012 05:47:12 -0500 (EST)
Date: Thu, 20 Dec 2012 10:47:07 +0000
From: Mel Gorman <mgorman@suse.de>
Subject: Re: [PATCH] compaction: fix build error in CMA && !COMPACTION
Message-ID: <20121220104707.GB10819@suse.de>
References: <1355981130-2382-1-git-send-email-minchan@kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <1355981130-2382-1-git-send-email-minchan@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Marek Szyprowski <m.szyprowski@samsung.com>

On Thu, Dec 20, 2012 at 02:25:30PM +0900, Minchan Kim wrote:
> isolate_freepages_block and isolate_migratepages_range is used for CMA
> as well as compaction so it breaks build for CONFIG_CMA &&
> !CONFIG_COMPACTION.
> 
> This patch fixes it.
> 
> Cc: Mel Gorman <mgorman@suse.de>
> Cc: Marek Szyprowski <m.szyprowski@samsung.com>
> Signed-off-by: Minchan Kim <minchan@kernel.org>
> ---
>  mm/compaction.c |   26 ++++++++++++++++++++------
>  1 file changed, 20 insertions(+), 6 deletions(-)
> 
> diff --git a/mm/compaction.c b/mm/compaction.c
> index 5ad7f4f..70f4443 100644
> --- a/mm/compaction.c
> +++ b/mm/compaction.c
> @@ -17,6 +17,21 @@
>  #include <linux/balloon_compaction.h>
>  #include "internal.h"
>  
> +#ifdef CONFIG_COMPACTION
> +static inline void count_compact_event(enum vm_event_item item)
> +{
> +	count_vm_event(item);
> +}
> +
> +static inline void count_compact_events(enum vm_event_item item, long delta)
> +{
> +	count_vm_events(item, delta);
> +}
> +#else
> +#define count_compact_event(item)
> +#define count_compact_events(item, delta)
> +#endif
> +

That should be

do {} while (0)

otherwise a block like this

if (foo)
	count_compact_event(COMPACTFREE_SCANNED)
bar;

will get parsed as

if (foo)
	bar;

which is wrong.

Now that I look at the do {} while (0) thing it is also strictly speaking
wrong for count_vm_numa_events() too because it would do the wrong thing for

count_compact_events(COMPACTFREE_SCANNED, foo++);

There happens to be no examples where we depend on such side-effects but
I've taken a TODO item to fix it up in the New Year.

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
