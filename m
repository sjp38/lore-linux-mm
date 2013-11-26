Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-bk0-f47.google.com (mail-bk0-f47.google.com [209.85.214.47])
	by kanga.kvack.org (Postfix) with ESMTP id 7E90A6B0080
	for <linux-mm@kvack.org>; Tue, 26 Nov 2013 11:44:50 -0500 (EST)
Received: by mail-bk0-f47.google.com with SMTP id mx12so2721331bkb.34
        for <linux-mm@kvack.org>; Tue, 26 Nov 2013 08:44:49 -0800 (PST)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTP id db3si11053471bkc.39.2013.11.26.08.44.48
        for <linux-mm@kvack.org>;
        Tue, 26 Nov 2013 08:44:49 -0800 (PST)
Message-ID: <5294CFFD.70204@suse.cz>
Date: Tue, 26 Nov 2013 17:44:45 +0100
From: Vlastimil Babka <vbabka@suse.cz>
MIME-Version: 1.0
Subject: Re: [PATCH 3/5] mm: compaction: detect when scanners meet in isolate_freepages
References: <1385389570-11393-1-git-send-email-vbabka@suse.cz> <1385389570-11393-4-git-send-email-vbabka@suse.cz> <20131126104542.GH5285@suse.de>
In-Reply-To: <20131126104542.GH5285@suse.de>
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Rik van Riel <riel@redhat.com>

On 11/26/2013 11:45 AM, Mel Gorman wrote:
> On Mon, Nov 25, 2013 at 03:26:08PM +0100, Vlastimil Babka wrote:
>> Compaction of a zone is finished when the migrate scanner (which begins at the
>> zone's lowest pfn) meets the free page scanner (which begins at the zone's
>> highest pfn). This is detected in compact_zone() and in the case of direct
>> compaction, the compact_blockskip_flush flag is set so that kswapd later resets
>> the cached scanner pfn's, and a new compaction may again start at the zone's
>> borders.
>>
>> The meeting of the scanners can happen during either scanner's activity.
>> However, it may currently fail to be detected when it occurs in the free page
>> scanner, due to two problems. First, isolate_freepages() keeps free_pfn at the
>> highest block where it isolated pages from, for the purposes of not missing the
>> pages that are returned back to allocator when migration fails. Second, failing
>> to isolate enough free pages due to scanners meeting results in -ENOMEM being
>> returned by migrate_pages(), which makes compact_zone() bail out immediately
>> without calling compact_finished() that would detect scanners meeting.
>>
>> This failure to detect scanners meeting might result in repeated attempts at
>> compaction of a zone that keep starting from the cached pfn's close to the
>> meeting point, and quickly failing through the -ENOMEM path, without the cached
>> pfns being reset, over and over. This has been observed (through additional
>> tracepoints) in the third phase of the mmtests stress-highalloc benchmark, where
>> the allocator runs on an otherwise idle system. The problem was observed in the
>> DMA32 zone, which was used as a fallback to the preferred Normal zone, but on
>> the 4GB system it was actually the largest zone. The problem is even amplified
>> for such fallback zone - the deferred compaction logic, which could (after
>> being fixed by a previous patch) reset the cached scanner pfn's, is only
>> applied to the preferred zone and not for the fallbacks.
>>
>> The problem in the third phase of the benchmark was further amplified by commit
>> 81c0a2bb ("mm: page_alloc: fair zone allocator policy") which resulted in a
>> non-deterministic regression of the allocation success rate from ~85% to ~65%.
>> This occurs in about half of benchmark runs, making bisection problematic.
>> It is unlikely that the commit itself is buggy, but it should put more pressure
>> on the DMA32 zone during phases 1 and 2, which may leave it more fragmented in
>> phase 3 and expose the bugs that this patch fixes.
>>
>> The fix is to make scanners meeting in isolate_freepage() stay that way, and
>> to check in compact_zone() for scanners meeting when migrate_pages() returns
>> -ENOMEM. The result is that compact_finished() also detects scanners meeting
>> and sets the compact_blockskip_flush flag to make kswapd reset the scanner
>> pfn's.
>>
>> The results in stress-highalloc benchmark show that the "regression" by commit
>> 81c0a2bb in phase 3 no longer occurs, and phase 1 and 2 allocation success rates
>> are significantly improved.
>>
>> Cc: Mel Gorman <mgorman@suse.de>
>> Cc: Rik van Riel <riel@redhat.com>
>> Signed-off-by: Vlastimil Babka <vbabka@suse.cz>
>> ---
>>  mm/compaction.c | 19 +++++++++++++++----
>>  1 file changed, 15 insertions(+), 4 deletions(-)
>>
>> diff --git a/mm/compaction.c b/mm/compaction.c
>> index 6a2f0c2..0702bdf 100644
>> --- a/mm/compaction.c
>> +++ b/mm/compaction.c
>> @@ -656,7 +656,7 @@ static void isolate_freepages(struct zone *zone,
>>  	 * is the end of the pageblock the migration scanner is using.
>>  	 */
>>  	pfn = cc->free_pfn;
>> -	low_pfn = cc->migrate_pfn + pageblock_nr_pages;
>> +	low_pfn = ALIGN(cc->migrate_pfn + 1, pageblock_nr_pages);
>>  
>>  	/*
>>  	 * Take care that if the migration scanner is at the end of the zone
>> @@ -672,7 +672,7 @@ static void isolate_freepages(struct zone *zone,
>>  	 * pages on cc->migratepages. We stop searching if the migrate
>>  	 * and free page scanners meet or enough free pages are isolated.
>>  	 */
>> -	for (; pfn > low_pfn && cc->nr_migratepages > nr_freepages;
>> +	for (; pfn >= low_pfn && cc->nr_migratepages > nr_freepages;
>>  					pfn -= pageblock_nr_pages) {
>>  		unsigned long isolated;
>>  
>> @@ -734,7 +734,14 @@ static void isolate_freepages(struct zone *zone,
>>  	/* split_free_page does not map the pages */
>>  	map_pages(freelist);
>>  
>> -	cc->free_pfn = high_pfn;
>> +        /*
>> +         * If we crossed the migrate scanner, we want to keep it that way
>> +	 * so that compact_finished() may detect this
>> +	 */
> 
> Whitespace damage.

Thanks, will fix.

>> +	if (pfn < low_pfn)
>> +		cc->free_pfn = max(pfn, zone->zone_start_pfn);
> 
> Is it even possible for this condition to occur? low_pfn bound is
> cc->migrate_pfn and the free scanner should only start after some pages
> have already been isolated for migration.

If a zone starts in a middle of a pageblock and migrate scanner isolates
enough pages early to stay within that pageblock, low_pfn will be at the
end of that pageblock and after the for cycle in this function ends, pfn
might be at the beginning of that pageblock. It might not be an actual
problem (this compaction will finish at this point, and if someone else
is racing, he will probably check the boundaries himself), but I played
it safe.

>> +	else
>> +		cc->free_pfn = high_pfn;
>>  	cc->nr_freepages = nr_freepages;
>>  }
>>  
>> @@ -999,7 +1006,11 @@ static int compact_zone(struct zone *zone, struct compact_control *cc)
>>  		if (err) {
>>  			putback_movable_pages(&cc->migratepages);
>>  			cc->nr_migratepages = 0;
>> -			if (err == -ENOMEM) {
>> +			/*
>> +			 * migrate_pages() may return -ENOMEM when scanners meet
>> +			 * and we want compact_finished() to detect it
>> +			 */
>> +			if (err == -ENOMEM && cc->free_pfn > cc->migrate_pfn) {
>>  				ret = COMPACT_PARTIAL;
>>  				goto out;
>>  			}
>> -- 
>> 1.8.1.4
>>
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
