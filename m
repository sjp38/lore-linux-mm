Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f50.google.com (mail-pa0-f50.google.com [209.85.220.50])
	by kanga.kvack.org (Postfix) with ESMTP id F3BCD6B0038
	for <linux-mm@kvack.org>; Mon,  7 Sep 2015 01:35:31 -0400 (EDT)
Received: by padhk3 with SMTP id hk3so1042482pad.3
        for <linux-mm@kvack.org>; Sun, 06 Sep 2015 22:35:31 -0700 (PDT)
Received: from lgeamrelo01.lge.com (lgeamrelo01.lge.com. [156.147.1.125])
        by mx.google.com with ESMTP id g4si18175802pdh.107.2015.09.06.22.35.29
        for <linux-mm@kvack.org>;
        Sun, 06 Sep 2015 22:35:31 -0700 (PDT)
Date: Mon, 7 Sep 2015 14:35:28 +0900
From: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Subject: Re: [PATCH v2 1/9] mm/compaction: skip useless pfn when updating
 cached pfn
Message-ID: <20150907053528.GB21207@js1304-P5Q-DELUXE>
References: <1440382773-16070-1-git-send-email-iamjoonsoo.kim@lge.com>
 <1440382773-16070-2-git-send-email-iamjoonsoo.kim@lge.com>
 <55DADEC0.5030800@suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <55DADEC0.5030800@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, David Rientjes <rientjes@google.com>, Minchan Kim <minchan@kernel.org>

On Mon, Aug 24, 2015 at 11:07:12AM +0200, Vlastimil Babka wrote:
> On 08/24/2015 04:19 AM, Joonsoo Kim wrote:
> >Cached pfn is used to determine the start position of scanner
> >at next compaction run. Current cached pfn points the skipped pageblock
> >so we uselessly checks whether pageblock is valid for compaction and
> >skip-bit is set or not. If we set scanner's cached pfn to next pfn of
> >skipped pageblock, we don't need to do this check.
> >
> >Signed-off-by: Joonsoo Kim <iamjoonsoo.kim@lge.com>
> >---
> >  mm/compaction.c | 13 ++++++-------
> >  1 file changed, 6 insertions(+), 7 deletions(-)
> >
> >diff --git a/mm/compaction.c b/mm/compaction.c
> >index 6ef2fdf..c2d3d6a 100644
> >--- a/mm/compaction.c
> >+++ b/mm/compaction.c
> >@@ -261,10 +261,9 @@ void reset_isolation_suitable(pg_data_t *pgdat)
> >   */
> >  static void update_pageblock_skip(struct compact_control *cc,
> >  			struct page *page, unsigned long nr_isolated,
> >-			bool migrate_scanner)
> >+			unsigned long pfn, bool migrate_scanner)
> >  {
> >  	struct zone *zone = cc->zone;
> >-	unsigned long pfn;
> >
> >  	if (cc->ignore_skip_hint)
> >  		return;
> >@@ -277,8 +276,6 @@ static void update_pageblock_skip(struct compact_control *cc,
> >
> >  	set_pageblock_skip(page);
> >
> >-	pfn = page_to_pfn(page);
> >-
> >  	/* Update where async and sync compaction should restart */
> >  	if (migrate_scanner) {
> >  		if (pfn > zone->compact_cached_migrate_pfn[0])
> >@@ -300,7 +297,7 @@ static inline bool isolation_suitable(struct compact_control *cc,
> >
> >  static void update_pageblock_skip(struct compact_control *cc,
> >  			struct page *page, unsigned long nr_isolated,
> >-			bool migrate_scanner)
> >+			unsigned long pfn, bool migrate_scanner)
> >  {
> >  }
> >  #endif /* CONFIG_COMPACTION */
> >@@ -509,7 +506,8 @@ isolate_fail:
> >
> >  	/* Update the pageblock-skip if the whole pageblock was scanned */
> >  	if (blockpfn == end_pfn)
> >-		update_pageblock_skip(cc, valid_page, total_isolated, false);
> >+		update_pageblock_skip(cc, valid_page, total_isolated,
> >+					end_pfn, false);
> 
> In isolate_freepages_block() this means we actually go logically
> *back* one pageblock, as the direction is opposite? I know it's not
> an issue after the redesign patch so you wouldn't notice it when
> testing the whole series. But there's a non-zero chance that the
> smaller fixes are merged first and the redesign later...

Hello, Vlastimil.
Sorry for long delay. I was on vacation. :)
I will fix it next time.

Btw, if possible, could you review the patchset in detail? or do you
have another plan on compaction improvement? Please let me know your
position to determine future plan of this patchset.

Thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
