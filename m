Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f70.google.com (mail-ed1-f70.google.com [209.85.208.70])
	by kanga.kvack.org (Postfix) with ESMTP id 53F7A6B000C
	for <linux-mm@kvack.org>; Wed, 31 Oct 2018 12:56:55 -0400 (EDT)
Received: by mail-ed1-f70.google.com with SMTP id k17-v6so11125131edr.18
        for <linux-mm@kvack.org>; Wed, 31 Oct 2018 09:56:55 -0700 (PDT)
Received: from outbound-smtp12.blacknight.com (outbound-smtp12.blacknight.com. [46.22.139.17])
        by mx.google.com with ESMTPS id y30-v6si4384830edb.128.2018.10.31.09.56.53
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 31 Oct 2018 09:56:54 -0700 (PDT)
Received: from mail.blacknight.com (pemlinmail03.blacknight.ie [81.17.254.16])
	by outbound-smtp12.blacknight.com (Postfix) with ESMTPS id B50581C1DC5
	for <linux-mm@kvack.org>; Wed, 31 Oct 2018 16:56:53 +0000 (GMT)
Date: Wed, 31 Oct 2018 16:56:52 +0000
From: Mel Gorman <mgorman@techsingularity.net>
Subject: Re: [PATCH 3/5] mm: Reclaim small amounts of memory when an external
 fragmentation event occurs
Message-ID: <20181031165651.GE23537@techsingularity.net>
References: <20181031160645.7633-1-mgorman@techsingularity.net>
 <20181031160645.7633-4-mgorman@techsingularity.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20181031160645.7633-4-mgorman@techsingularity.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linux-MM <linux-mm@kvack.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Vlastimil Babka <vbabka@suse.cz>, David Rientjes <rientjes@google.com>, Andrea Arcangeli <aarcange@redhat.com>, Zi Yan <zi.yan@cs.rutgers.edu>, LKML <linux-kernel@vger.kernel.org>

On Wed, Oct 31, 2018 at 04:06:43PM +0000, Mel Gorman wrote:
> An external fragmentation event was previously described as
> 
>     When the page allocator fragments memory, it records the event using
>     the mm_page_alloc_extfrag event. If the fallback_order is smaller
>     than a pageblock order (order-9 on 64-bit x86) then it's considered
>     an event that will cause external fragmentation issues in the future.
> 

This had a build error reported by the 0-day bot. It's trivially fixed
with

diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 77bcc35903e0..e36c279dfade 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -3317,8 +3317,8 @@ static bool zone_allows_reclaim(struct zone *local_zone, struct zone *zone)
  * probably too small. It only makes sense to spread allocations to avoid
  * fragmentation between the Normal and DMA32 zones.
  */
-static inline unsigned int alloc_flags_nofragment(struct zone *zone,
-							gfp_t gfp_mask)
+static inline unsigned int
+alloc_flags_nofragment(struct zone *zone, gfp_t gfp_mask)
 {
 	if (zone_idx(zone) != ZONE_NORMAL)
 		return 0;
@@ -3340,7 +3340,8 @@ static inline unsigned int alloc_flags_nofragment(struct zone *zone,
 	return ALLOC_NOFRAGMENT;
 }
 #else
-static inline unsigned int alloc_flags_nofragment(struct zone *zone)
+static inline unsigned int
+alloc_flags_nofragment(struct zone *zone, gfp_t gfp_mask)
 {
 	return 0;
 }

-- 
Mel Gorman
SUSE Labs
