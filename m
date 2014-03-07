Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f182.google.com (mail-pd0-f182.google.com [209.85.192.182])
	by kanga.kvack.org (Postfix) with ESMTP id 4C67A6B0031
	for <linux-mm@kvack.org>; Thu,  6 Mar 2014 19:33:52 -0500 (EST)
Received: by mail-pd0-f182.google.com with SMTP id g10so3307032pdj.27
        for <linux-mm@kvack.org>; Thu, 06 Mar 2014 16:33:52 -0800 (PST)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTP id gn5si6500915pbc.56.2014.03.06.16.33.51
        for <linux-mm@kvack.org>;
        Thu, 06 Mar 2014 16:33:51 -0800 (PST)
Date: Thu, 6 Mar 2014 16:33:49 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCHv2] mm/compaction: Break out of loop on !PageBuddy in
 isolate_freepages_block
Message-Id: <20140306163349.d1f25dac8bc97f0cf89a82b5@linux-foundation.org>
In-Reply-To: <1394130092-25440-1-git-send-email-lauraa@codeaurora.org>
References: <1394130092-25440-1-git-send-email-lauraa@codeaurora.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Laura Abbott <lauraa@codeaurora.org>
Cc: Mel Gorman <mgorman@suse.de>, Vlastimil Babka <vbabka@suse.cz>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Joonsoo Kim <iamjoonsoo.kim@lge.com>

On Thu,  6 Mar 2014 10:21:32 -0800 Laura Abbott <lauraa@codeaurora.org> wrote:

> We received several reports of bad page state when freeing CMA pages
> previously allocated with alloc_contig_range:
> 
> <1>[ 1258.084111] BUG: Bad page state in process Binder_A  pfn:63202
> <1>[ 1258.089763] page:d21130b0 count:0 mapcount:1 mapping:  (null) index:0x7dfbf
> <1>[ 1258.096109] page flags: 0x40080068(uptodate|lru|active|swapbacked)
> 
> Based on the page state, it looks like the page was still in use. The page
> flags do not make sense for the use case though. Further debugging showed
> that despite alloc_contig_range returning success, at least one page in the
> range still remained in the buddy allocator.
> 
> There is an issue with isolate_freepages_block. In strict mode (which CMA
> uses), if any pages in the range cannot be isolated,
> isolate_freepages_block should return failure 0. The current check keeps
> track of the total number of isolated pages and compares against the size
> of the range:
> 
>         if (strict && nr_strict_required > total_isolated)
>                 total_isolated = 0;
> 
> After taking the zone lock, if one of the pages in the range is not
> in the buddy allocator, we continue through the loop and do not
> increment total_isolated. If in the last iteration of the loop we isolate
> more than one page (e.g. last page needed is a higher order page), the
> check for total_isolated may pass and we fail to detect that a page was
> skipped. The fix is to bail out if the loop immediately if we are in
> strict mode. There's no benfit to continuing anyway since we need all
> pages to be isolated. Additionally, drop the error checking based on
> nr_strict_required and just check the pfn ranges. This matches with
> what isolate_freepages_range does.
> 
> --- a/mm/compaction.c
> +++ b/mm/compaction.c
> @@ -242,7 +242,6 @@ static unsigned long isolate_freepages_block(struct compact_control *cc,
>  {
>  	int nr_scanned = 0, total_isolated = 0;
>  	struct page *cursor, *valid_page = NULL;
> -	unsigned long nr_strict_required = end_pfn - blockpfn;
>  	unsigned long flags;
>  	bool locked = false;
>  	bool checked_pageblock = false;
> @@ -256,11 +255,12 @@ static unsigned long isolate_freepages_block(struct compact_control *cc,
>  
>  		nr_scanned++;
>  		if (!pfn_valid_within(blockpfn))
> -			continue;
> +			goto isolate_fail;
> +
>  		if (!valid_page)
>  			valid_page = page;
>  		if (!PageBuddy(page))
> -			continue;
> +			goto isolate_fail;
>  
>  		/*
>  		 * The zone lock must be held to isolate freepages.
> @@ -289,12 +289,10 @@ static unsigned long isolate_freepages_block(struct compact_control *cc,
>  
>  		/* Recheck this is a buddy page under lock */
>  		if (!PageBuddy(page))
> -			continue;
> +			goto isolate_fail;
>  
>  		/* Found a free page, break it into order-0 pages */
>  		isolated = split_free_page(page);
> -		if (!isolated && strict)
> -			break;
>  		total_isolated += isolated;
>  		for (i = 0; i < isolated; i++) {
>  			list_add(&page->lru, freelist);
> @@ -305,7 +303,15 @@ static unsigned long isolate_freepages_block(struct compact_control *cc,
>  		if (isolated) {
>  			blockpfn += isolated - 1;
>  			cursor += isolated - 1;
> +			continue;
>  		}

We can make the code a little more efficient and (I think) clearer by
moving that `if (isolated)' test.

> +
> +isolate_fail:
> +		if (strict)
> +			break;
> +		else
> +			continue;
> +

And I don't think this `continue' has any benefit.


--- a/mm/compaction.c~mm-compaction-break-out-of-loop-on-pagebuddy-in-isolate_freepages_block-fix
+++ a/mm/compaction.c
@@ -293,14 +293,14 @@ static unsigned long isolate_freepages_b
 
 		/* Found a free page, break it into order-0 pages */
 		isolated = split_free_page(page);
-		total_isolated += isolated;
-		for (i = 0; i < isolated; i++) {
-			list_add(&page->lru, freelist);
-			page++;
-		}
-
-		/* If a page was split, advance to the end of it */
 		if (isolated) {
+			total_isolated += isolated;
+			for (i = 0; i < isolated; i++) {
+				list_add(&page->lru, freelist);
+				page++;
+			}
+
+			/* If a page was split, advance to the end of it */
 			blockpfn += isolated - 1;
 			cursor += isolated - 1;
 			continue;
@@ -309,9 +309,6 @@ static unsigned long isolate_freepages_b
 isolate_fail:
 		if (strict)
 			break;
-		else
-			continue;
-
 	}
 
 	trace_mm_compaction_isolate_freepages(nr_scanned, total_isolated);


Problem is, I can't be bothered testing this.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
