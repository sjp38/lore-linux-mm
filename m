Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx181.postini.com [74.125.245.181])
	by kanga.kvack.org (Postfix) with SMTP id 171186B004D
	for <linux-mm@kvack.org>; Thu, 12 Jan 2012 03:03:23 -0500 (EST)
Received: by vbnl22 with SMTP id l22so174810vbn.14
        for <linux-mm@kvack.org>; Thu, 12 Jan 2012 00:03:22 -0800 (PST)
Date: Thu, 12 Jan 2012 17:03:11 +0900
From: Minchan Kim <minchan@kernel.org>
Subject: Re: [PATCH v2] mm/compaction : do optimazition when the migration
 scanner gets no page
Message-ID: <20120112080311.GA30634@barrios-desktop.redhat.com>
References: <1326347222-9980-1-git-send-email-b32955@freescale.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1326347222-9980-1-git-send-email-b32955@freescale.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Huang Shijie <b32955@freescale.com>
Cc: akpm@linux-foundation.org, mgorman@suse.de, linux-mm@kvack.org

On Thu, Jan 12, 2012 at 01:47:02PM +0800, Huang Shijie wrote:
> In the real tests, there are maybe many times the cc->nr_migratepages is zero,
> but isolate_migratepages() returns ISOLATE_SUCCESS.
> 
> Memory in our mx6q board:
> 	2G memory, 8192 pages per page block
> 
> We use the following command to test in two types system loads:
> 	#echo 1 > /proc/sys/vm/compact_memory
> 
> Test Result:
> 	[1] little load(login in the ubuntu):
> 		all the scanned pageblocks	: 79
> 		pageblocks which get no pages	: 46
> 
> 		The ratio of `get no pages` pageblock is 58.2%.
> 
> 	[2] heavy load(start thunderbird, firefox, ..etc):
> 		all the scanned pageblocks	: 89
> 		pageblocks which get no pages	: 36
> 
> 		The ratio of `get no pages` pageblock is 40.4%.
> 
> In order to get better performance, we should check the number of the
> really isolated pages. And do the optimazition for this case.
> 
> Also fix the confused comments(from Mel Gorman).
> 
> Tested this patch in MX6Q board.
> 
> Signed-off-by: Huang Shijie <b32955@freescale.com>
> Acked-by: Mel Gorman <mgorman@suse.de>
> ---
>  mm/compaction.c |   28 ++++++++++++++++------------
>  1 files changed, 16 insertions(+), 12 deletions(-)
> 
> diff --git a/mm/compaction.c b/mm/compaction.c
> index f4f514d..41d1b72a 100644
> --- a/mm/compaction.c
> +++ b/mm/compaction.c
> @@ -246,8 +246,8 @@ static bool too_many_isolated(struct zone *zone)
>  /* possible outcome of isolate_migratepages */
>  typedef enum {
>  	ISOLATE_ABORT,		/* Abort compaction now */
> -	ISOLATE_NONE,		/* No pages isolated, continue scanning */
> -	ISOLATE_SUCCESS,	/* Pages isolated, migrate */
> +	ISOLATE_NONE,		/* No pages scanned, consider next pageblock*/
> +	ISOLATE_SUCCESS,	/* Pages scanned and maybe isolated, migrate */
>  } isolate_migrate_t;
>  

Hmm, I don't like this change.
ISOLATE_NONE mean "we don't isolate any page at all"
ISOLATE_SUCCESS mean "We isolaetssome pages"
It's very clear but you are changing semantic slighly.

How about this?

--- a/mm/compaction.c
+++ b/mm/compaction.c
@@ -376,7 +376,7 @@ static isolate_migrate_t isolate_migratepages(struct zone *zone,
 
        trace_mm_compaction_isolate_migratepages(nr_scanned, nr_isolated);
 
-       return ISOLATE_SUCCESS;
+       return cc->nr_migratepages ? ISOLATE_SUCCESS : ISOLATE_NONE;
 }
 
 /*
@@ -542,6 +542,8 @@ static int compact_zone(struct zone *zone, struct compact_control *cc)
                unsigned long nr_migrate, nr_remaining;
                int err;
 
+               count_vm_event(COMPACTBLOCKS);
+
                switch (isolate_migratepages(zone, cc)) {
                case ISOLATE_ABORT:
                        ret = COMPACT_PARTIAL;
@@ -559,7 +561,6 @@ static int compact_zone(struct zone *zone, struct compact_control *cc)
                update_nr_listpages(cc);
                nr_remaining = cc->nr_migratepages;
 
-               count_vm_event(COMPACTBLOCKS);
                count_vm_events(COMPACTPAGES, nr_migrate - nr_remaining);
                if (nr_remaining)
                        count_vm_events(COMPACTPAGEFAILED, nr_remaining);

This patch's side effect is that it accounts COMPACTBLOCK although isolation is cancel by signal
but I think it's very rare and doesn't give big effect for statistics of compaciton.


>  /*
> @@ -542,7 +542,7 @@ static int compact_zone(struct zone *zone, struct compact_control *cc)
>  
>  	while ((ret = compact_finished(zone, cc)) == COMPACT_CONTINUE) {
>  		unsigned long nr_migrate, nr_remaining;
> -		int err;
> +		int err = 0;
>  
>  		switch (isolate_migratepages(zone, cc)) {
>  		case ISOLATE_ABORT:
> @@ -554,17 +554,21 @@ static int compact_zone(struct zone *zone, struct compact_control *cc)
>  			;
>  		}
>  
> -		nr_migrate = cc->nr_migratepages;
> -		err = migrate_pages(&cc->migratepages, compaction_alloc,
> -				(unsigned long)cc, false,
> -				cc->sync);
> -		update_nr_listpages(cc);
> -		nr_remaining = cc->nr_migratepages;
> +		nr_migrate = nr_remaining = cc->nr_migratepages;
> +		if (nr_migrate) {
> +			err = migrate_pages(&cc->migratepages, compaction_alloc,
> +					(unsigned long)cc, false,
> +					cc->sync);
> +			update_nr_listpages(cc);
> +			nr_remaining = cc->nr_migratepages;
> +			count_vm_events(COMPACTPAGES,
> +					nr_migrate - nr_remaining);
> +			if (nr_remaining)
> +				count_vm_events(COMPACTPAGEFAILED,
> +						nr_remaining);
> +		}
>  
>  		count_vm_event(COMPACTBLOCKS);
> -		count_vm_events(COMPACTPAGES, nr_migrate - nr_remaining);
> -		if (nr_remaining)
> -			count_vm_events(COMPACTPAGEFAILED, nr_remaining);
>  		trace_mm_compaction_migratepages(nr_migrate - nr_remaining,
>  						nr_remaining);
>  
> -- 
> 1.7.3.2
> 
> 
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
