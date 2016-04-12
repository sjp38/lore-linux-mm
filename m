Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f46.google.com (mail-wm0-f46.google.com [74.125.82.46])
	by kanga.kvack.org (Postfix) with ESMTP id 9EB216B025F
	for <linux-mm@kvack.org>; Tue, 12 Apr 2016 08:43:47 -0400 (EDT)
Received: by mail-wm0-f46.google.com with SMTP id f198so185968887wme.0
        for <linux-mm@kvack.org>; Tue, 12 Apr 2016 05:43:47 -0700 (PDT)
Received: from mail-wm0-f68.google.com (mail-wm0-f68.google.com. [74.125.82.68])
        by mx.google.com with ESMTPS id yr7si22078050wjc.142.2016.04.12.05.43.46
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 12 Apr 2016 05:43:46 -0700 (PDT)
Received: by mail-wm0-f68.google.com with SMTP id l6so5020136wml.3
        for <linux-mm@kvack.org>; Tue, 12 Apr 2016 05:43:46 -0700 (PDT)
Date: Tue, 12 Apr 2016 14:43:44 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH 2/2] mm, oom, compaction: prevent from
 should_compact_retry looping for ever for costly orders
Message-ID: <20160412124344.GE10771@dhcp22.suse.cz>
References: <1460357151-25554-1-git-send-email-mhocko@kernel.org>
 <1460357151-25554-3-git-send-email-mhocko@kernel.org>
 <570CA287.3030604@suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <570CA287.3030604@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>

On Tue 12-04-16 09:23:51, Vlastimil Babka wrote:
[...]
> It's a bit complicated, but I agree that something like this is needed to
> prevent unexpected endless loops. Alternatively you could maybe just extend
> compact_result to distinguish between COMPACT_SKIPPED (but possible after
> reclaim) and COMPACT_IMPOSSIBLE (or some better name?). Then
> compaction_withdrawn() would obviously be false for IMPOSSIBLE, while
> compaction_failed() would be true? Then you shouldn't need
> compaction_zonelist_suitable().

I would rather not add more states. My head spins with the current state
already...

> >+bool compaction_zonelist_suitable(struct alloc_context *ac, int order,
> >+		int alloc_flags)
> >+{
> >+	struct zone *zone;
> >+	struct zoneref *z;
> >+
> >+	/*
> >+	 * Make sure at least one zone would pass __compaction_suitable if we continue
> >+	 * retrying the reclaim.
> >+	 */
> >+	for_each_zone_zonelist_nodemask(zone, z, ac->zonelist, ac->classzone_idx,
> 
> I think here you should s/classzone_idx/high_zoneidx/

true

> 
> >+					ac->nodemask) {
> >+		unsigned long available;
> >+		enum compact_result compact_result;
> >+
> >+		/*
> >+		 * Do not consider all the reclaimable memory because we do not
> >+		 * want to trash just for a single high order allocation which
> >+		 * is even not guaranteed to appear even if __compaction_suitable
> >+		 * is happy about the watermark check.
> >+		 */
> >+		available = zone_reclaimable_pages(zone) / order;
> >+		available += zone_page_state_snapshot(zone, NR_FREE_PAGES);
> >+		compact_result = __compaction_suitable(zone, order, alloc_flags,
> >+				ac->high_zoneidx, available);
> 
> And vice versa here.

will fix this. Thanks!

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
