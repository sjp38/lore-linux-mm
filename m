Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f72.google.com (mail-lf0-f72.google.com [209.85.215.72])
	by kanga.kvack.org (Postfix) with ESMTP id 60E496B0005
	for <linux-mm@kvack.org>; Fri, 15 Jul 2016 03:49:04 -0400 (EDT)
Received: by mail-lf0-f72.google.com with SMTP id 33so66557710lfw.1
        for <linux-mm@kvack.org>; Fri, 15 Jul 2016 00:49:04 -0700 (PDT)
Received: from outbound-smtp03.blacknight.com (outbound-smtp03.blacknight.com. [81.17.249.16])
        by mx.google.com with ESMTPS id i11si3800497wmh.67.2016.07.15.00.49.02
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Fri, 15 Jul 2016 00:49:02 -0700 (PDT)
Received: from mail.blacknight.com (pemlinmail01.blacknight.ie [81.17.254.10])
	by outbound-smtp03.blacknight.com (Postfix) with ESMTPS id 250BC98D83
	for <linux-mm@kvack.org>; Fri, 15 Jul 2016 07:49:01 +0000 (UTC)
Date: Fri, 15 Jul 2016 08:48:59 +0100
From: Mel Gorman <mgorman@techsingularity.net>
Subject: Re: [PATCH 34/34] mm, vmstat: remove zone and node double accounting
 by approximating retries
Message-ID: <20160715074859.GM9806@techsingularity.net>
References: <1467970510-21195-1-git-send-email-mgorman@techsingularity.net>
 <1467970510-21195-35-git-send-email-mgorman@techsingularity.net>
 <bd515668-2d1f-e70e-f419-7a55189757f7@suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <bd515668-2d1f-e70e-f419-7a55189757f7@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: Andrew Morton <akpm@linux-foundation.org>, Linux-MM <linux-mm@kvack.org>, Rik van Riel <riel@surriel.com>, Johannes Weiner <hannes@cmpxchg.org>, Minchan Kim <minchan@kernel.org>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, LKML <linux-kernel@vger.kernel.org>

On Thu, Jul 14, 2016 at 03:40:11PM +0200, Vlastimil Babka wrote:
> >@@ -4,6 +4,26 @@
> > #include <linux/huge_mm.h>
> > #include <linux/swap.h>
> >
> >+#ifdef CONFIG_HIGHMEM
> >+extern atomic_t highmem_file_pages;
> >+
> >+static inline void acct_highmem_file_pages(int zid, enum lru_list lru,
> >+							int nr_pages)
> >+{
> >+	if (is_highmem_idx(zid) && is_file_lru(lru)) {
> >+		if (nr_pages > 0)
> 
> This seems like a unnecessary branch, atomic_add should handle negative
> nr_pages just fine?
> 

On x86 it would but the interface makes no guarantees it'll handle
signed types properly on all architectures.

> >@@ -1456,14 +1461,27 @@ bool compaction_zonelist_suitable(struct alloc_context *ac, int order,
> > 		unsigned long available;
> > 		enum compact_result compact_result;
> >
> >+		if (last_pgdat == zone->zone_pgdat)
> >+			continue;
> >+
> >+		/*
> >+		 * This over-estimates the number of pages available for
> >+		 * reclaim/compaction but walking the LRU would take too
> >+		 * long. The consequences are that compaction may retry
> >+		 * longer than it should for a zone-constrained allocation
> >+		 * request.
> 
> The comment above says that we don't retry zone-constrained at all. Is this
> an obsolete comment, or does it refer to the ZONE_NORMAL constraint? (as
> opposed to HIGHMEM, MOVABLE etc?).
> 

It can still over-estimate the amount of memory available if
ZONE_MOVABLE exists even if the request is not zone-constrained.

> >@@ -3454,6 +3455,15 @@ should_reclaim_retry(gfp_t gfp_mask, unsigned order,
> > 		return false;
> >
> > 	/*
> >+	 * Blindly retry lowmem allocation requests that are often ignored by
> >+	 * the OOM killer up to MAX_RECLAIM_RETRIES as we not have a reliable
> >+	 * and fast means of calculating reclaimable, dirty and writeback pages
> >+	 * in eligible zones.
> >+	 */
> >+	if (ac->high_zoneidx < ZONE_NORMAL)
> >+		goto out;
> 
> A goto inside two nested for cycles? Is there no hope for sanity? :(
> 

None, hand it in at the door.

It can be pulled out and put past the "return false" at the end. It's
just not necessarily any better.

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
