Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f180.google.com (mail-wi0-f180.google.com [209.85.212.180])
	by kanga.kvack.org (Postfix) with ESMTP id 94C196B0038
	for <linux-mm@kvack.org>; Mon, 24 Aug 2015 05:07:18 -0400 (EDT)
Received: by wijp15 with SMTP id p15so70880014wij.0
        for <linux-mm@kvack.org>; Mon, 24 Aug 2015 02:07:18 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id fw6si20317023wib.35.2015.08.24.02.07.16
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Mon, 24 Aug 2015 02:07:17 -0700 (PDT)
Subject: Re: [PATCH v2 1/9] mm/compaction: skip useless pfn when updating
 cached pfn
References: <1440382773-16070-1-git-send-email-iamjoonsoo.kim@lge.com>
 <1440382773-16070-2-git-send-email-iamjoonsoo.kim@lge.com>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <55DADEC0.5030800@suse.cz>
Date: Mon, 24 Aug 2015 11:07:12 +0200
MIME-Version: 1.0
In-Reply-To: <1440382773-16070-2-git-send-email-iamjoonsoo.kim@lge.com>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joonsoo Kim <js1304@gmail.com>, Andrew Morton <akpm@linux-foundation.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, David Rientjes <rientjes@google.com>, Minchan Kim <minchan@kernel.org>, Joonsoo Kim <iamjoonsoo.kim@lge.com>

On 08/24/2015 04:19 AM, Joonsoo Kim wrote:
> Cached pfn is used to determine the start position of scanner
> at next compaction run. Current cached pfn points the skipped pageblock
> so we uselessly checks whether pageblock is valid for compaction and
> skip-bit is set or not. If we set scanner's cached pfn to next pfn of
> skipped pageblock, we don't need to do this check.
>
> Signed-off-by: Joonsoo Kim <iamjoonsoo.kim@lge.com>
> ---
>   mm/compaction.c | 13 ++++++-------
>   1 file changed, 6 insertions(+), 7 deletions(-)
>
> diff --git a/mm/compaction.c b/mm/compaction.c
> index 6ef2fdf..c2d3d6a 100644
> --- a/mm/compaction.c
> +++ b/mm/compaction.c
> @@ -261,10 +261,9 @@ void reset_isolation_suitable(pg_data_t *pgdat)
>    */
>   static void update_pageblock_skip(struct compact_control *cc,
>   			struct page *page, unsigned long nr_isolated,
> -			bool migrate_scanner)
> +			unsigned long pfn, bool migrate_scanner)
>   {
>   	struct zone *zone = cc->zone;
> -	unsigned long pfn;
>
>   	if (cc->ignore_skip_hint)
>   		return;
> @@ -277,8 +276,6 @@ static void update_pageblock_skip(struct compact_control *cc,
>
>   	set_pageblock_skip(page);
>
> -	pfn = page_to_pfn(page);
> -
>   	/* Update where async and sync compaction should restart */
>   	if (migrate_scanner) {
>   		if (pfn > zone->compact_cached_migrate_pfn[0])
> @@ -300,7 +297,7 @@ static inline bool isolation_suitable(struct compact_control *cc,
>
>   static void update_pageblock_skip(struct compact_control *cc,
>   			struct page *page, unsigned long nr_isolated,
> -			bool migrate_scanner)
> +			unsigned long pfn, bool migrate_scanner)
>   {
>   }
>   #endif /* CONFIG_COMPACTION */
> @@ -509,7 +506,8 @@ isolate_fail:
>
>   	/* Update the pageblock-skip if the whole pageblock was scanned */
>   	if (blockpfn == end_pfn)
> -		update_pageblock_skip(cc, valid_page, total_isolated, false);
> +		update_pageblock_skip(cc, valid_page, total_isolated,
> +					end_pfn, false);

In isolate_freepages_block() this means we actually go logically *back* 
one pageblock, as the direction is opposite? I know it's not an issue 
after the redesign patch so you wouldn't notice it when testing the 
whole series. But there's a non-zero chance that the smaller fixes are 
merged first and the redesign later...

>
>   	count_compact_events(COMPACTFREE_SCANNED, nr_scanned);
>   	if (total_isolated)
> @@ -811,7 +809,8 @@ isolate_success:
>   	 * if the whole pageblock was scanned without isolating any page.
>   	 */
>   	if (low_pfn == end_pfn)
> -		update_pageblock_skip(cc, valid_page, nr_isolated, true);
> +		update_pageblock_skip(cc, valid_page, nr_isolated,
> +					end_pfn, true);
>
>   	trace_mm_compaction_isolate_migratepages(start_pfn, low_pfn,
>   						nr_scanned, nr_isolated);
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
