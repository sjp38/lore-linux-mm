Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f71.google.com (mail-wm0-f71.google.com [74.125.82.71])
	by kanga.kvack.org (Postfix) with ESMTP id A53066B0005
	for <linux-mm@kvack.org>; Wed, 13 Jul 2016 04:47:45 -0400 (EDT)
Received: by mail-wm0-f71.google.com with SMTP id o80so30415741wme.1
        for <linux-mm@kvack.org>; Wed, 13 Jul 2016 01:47:45 -0700 (PDT)
Received: from outbound-smtp06.blacknight.com (outbound-smtp06.blacknight.com. [81.17.249.39])
        by mx.google.com with ESMTPS id x17si355032wmd.115.2016.07.13.01.47.44
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 13 Jul 2016 01:47:44 -0700 (PDT)
Received: from mail.blacknight.com (pemlinmail06.blacknight.ie [81.17.255.152])
	by outbound-smtp06.blacknight.com (Postfix) with ESMTPS id 0BCB3C171
	for <linux-mm@kvack.org>; Wed, 13 Jul 2016 08:47:44 +0000 (UTC)
Date: Wed, 13 Jul 2016 09:47:42 +0100
From: Mel Gorman <mgorman@techsingularity.net>
Subject: Re: [PATCH 12/34] mm: vmscan: do not reclaim from kswapd if there is
 any eligible zone
Message-ID: <20160713084742.GG9806@techsingularity.net>
References: <1467970510-21195-1-git-send-email-mgorman@techsingularity.net>
 <1467970510-21195-13-git-send-email-mgorman@techsingularity.net>
 <20160712142909.GF5881@cmpxchg.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20160712142909.GF5881@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Linux-MM <linux-mm@kvack.org>, Rik van Riel <riel@surriel.com>, Vlastimil Babka <vbabka@suse.cz>, Minchan Kim <minchan@kernel.org>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, LKML <linux-kernel@vger.kernel.org>

On Tue, Jul 12, 2016 at 10:29:09AM -0400, Johannes Weiner wrote:
> > +		/*
> > +		 * If the number of buffer_heads in the machine exceeds the
> > +		 * maximum allowed level then reclaim from all zones. This is
> > +		 * not specific to highmem as highmem may not exist but it is
> > +		 * it is expected that buffer_heads are stripped in writeback.
> 
> The mention of highmem in this comment make only sense within the
> context of this diff; it'll be pretty confusing in the standalone
> code.
> 
> Also, double "it is" :)

Is this any better?

Note that it's marked as a fix to a later patch to reduce collisions in
mmotm. It's not a bisection risk so I saw little need to cause
unnecessary conflicts for Andrew.

---8<---
mm, vmscan: Have kswapd reclaim from all zones if reclaiming and buffer_heads_over_limit -fix

Johannes reported that the comment about buffer_heads_over_limit in
balance_pgdat only made sense in the context of the patch. This
patch clarifies the reasoning and how it applies to 32 and 64 bit
systems.

This is a fix to the mmotm patch
mm-vmscan-have-kswapd-reclaim-from-all-zones-if-reclaiming-and-buffer_heads_over_limit.patch

Suggested-by: Johannes Weiner <hannes@cmpxchg.org>
Signed-off-by: Mel Gorman <mgorman@techsingularity.net>

diff --git a/mm/vmscan.c b/mm/vmscan.c
index d079210d46ee..21eae17ee730 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -3131,12 +3131,13 @@ static int balance_pgdat(pg_data_t *pgdat, int order, int classzone_idx)
 
 		/*
 		 * If the number of buffer_heads exceeds the maximum allowed
-		 * then consider reclaiming from all zones. This is not
-		 * specific to highmem which may not exist but it is it is
-		 * expected that buffer_heads are stripped in writeback.
-		 * Reclaim may still not go ahead if all eligible zones
-		 * for the original allocation request are balanced to
-		 * avoid excessive reclaim from kswapd.
+		 * then consider reclaiming from all zones. This has a dual
+		 * purpose -- on 64-bit systems it is expected that
+		 * buffer_heads are stripped during active rotation. On 32-bit
+		 * systems, highmem pages can pin lowmem memory and shrinking
+		 * buffers can relieve lowmem pressure. Reclaim may still not
+		 * go ahead if all eligible zones for the original allocation
+		 * request are balanced to avoid excessive reclaim from kswapd.
 		 */
 		if (buffer_heads_over_limit) {
 			for (i = MAX_NR_ZONES - 1; i >= 0; i--) {

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
