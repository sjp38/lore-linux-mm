Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f70.google.com (mail-lf0-f70.google.com [209.85.215.70])
	by kanga.kvack.org (Postfix) with ESMTP id 00B8E6B0005
	for <linux-mm@kvack.org>; Wed,  4 May 2016 10:36:32 -0400 (EDT)
Received: by mail-lf0-f70.google.com with SMTP id 68so43206135lfq.2
        for <linux-mm@kvack.org>; Wed, 04 May 2016 07:36:31 -0700 (PDT)
Received: from outbound-smtp07.blacknight.com (outbound-smtp07.blacknight.com. [46.22.139.12])
        by mx.google.com with ESMTPS id b186si5501963wmb.97.2016.05.04.07.36.30
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 04 May 2016 07:36:30 -0700 (PDT)
Received: from mail.blacknight.com (pemlinmail03.blacknight.ie [81.17.254.16])
	by outbound-smtp07.blacknight.com (Postfix) with ESMTPS id 4367A1C1141
	for <linux-mm@kvack.org>; Wed,  4 May 2016 15:36:30 +0100 (IST)
Date: Wed, 4 May 2016 15:36:28 +0100
From: Mel Gorman <mgorman@techsingularity.net>
Subject: [PATCH] mm, page_alloc: Restore the original nodemask if the fast
 path allocation failed
Message-ID: <20160504143628.GU2858@techsingularity.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Vlastimil Babka <vbabka@suse.cz>, Jesper Dangaard Brouer <brouer@redhat.com>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

(Andrew, this is on top of the pagealloc optimisation series in mmotm. It
 could be classed as a fix-up but it's subtle enough that it deserves its
 own changelog. "Clever" fixes had other consequences.)

The page allocator fast path uses either the requested nodemask or
cpuset_current_mems_allowed if cpusets are enabled. If the allocation
context allows watermarks to be ignored then it can also ignore memory
policies. However, on entering the allocator slowpath the nodemask may
still be cpuset_current_mems_allowed and the policies are enforced.
This patch resets the nodemask appropriately before entering the slowpath.

Signed-off-by: Vlastimil Babka <vbabka@suse.cz>
Signed-off-by: Mel Gorman <mgorman@techsingularity.net>

diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 79100583b9de..ec5155ab1482 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -3637,6 +3637,12 @@ __alloc_pages_nodemask(gfp_t gfp_mask, unsigned int order,
 	alloc_mask = memalloc_noio_flags(gfp_mask);
 	ac.spread_dirty_pages = false;
 
+	/*
+	 * Restore the original nodemask if it was potentially replaced with
+	 * &cpuset_current_mems_allowed to optimize the fast-path attempt.
+	 */
+	if (cpusets_enabled())
+		ac.nodemask = nodemask;
 	page = __alloc_pages_slowpath(alloc_mask, order, &ac);
 
 no_zone:

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
