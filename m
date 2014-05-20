Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ee0-f44.google.com (mail-ee0-f44.google.com [74.125.83.44])
	by kanga.kvack.org (Postfix) with ESMTP id C7E746B0038
	for <linux-mm@kvack.org>; Tue, 20 May 2014 08:43:09 -0400 (EDT)
Received: by mail-ee0-f44.google.com with SMTP id c41so540290eek.31
        for <linux-mm@kvack.org>; Tue, 20 May 2014 05:43:08 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id cj13si2538672eeb.69.2014.05.20.05.43.06
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Tue, 20 May 2014 05:43:07 -0700 (PDT)
Date: Tue, 20 May 2014 13:43:03 +0100
From: Mel Gorman <mgorman@suse.de>
Subject: [PATCH] mm: page_alloc: Calculate classzone_idx once from the
 zonelist ref
Message-ID: <20140520124302.GN23991@suse.de>
References: <20140520111753.GA22262@mwanda>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20140520111753.GA22262@mwanda>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, Dan Carpenter <dan.carpenter@oracle.com>

Dan Carpenter reported the following bug

	The patch a486e00b8283: "mm: page_alloc: calculate classzone_idx
	once from the zonelist ref" from May 17, 2014, leads to the
	following static checker warning:

        mm/page_alloc.c:2543 __alloc_pages_slowpath()
        warn: we tested 'nodemask' before and it was 'false'

mm/page_alloc.c
  2537           * Find the true preferred zone if the allocation is unconstrained by
  2538           * cpusets.
  2539           */
  2540          if (!(alloc_flags & ALLOC_CPUSET) && !nodemask) {
                                                     ^^^^^^^^^
Patch introduces this test.

  2541                  struct zoneref *preferred_zoneref;
  2542                  preferred_zoneref = first_zones_zonelist(zonelist, high_zoneidx,
  2543                                  nodemask ? : &cpuset_current_mems_allowed,
                                        ^^^^^^^^
Patch introduces this test as well.

  2544                                  &preferred_zone);
  2545                  classzone_idx = zonelist_zone_idx(preferred_zoneref);
  2546          }

This patch should resolve it and is a fix to the mmotm patch
mm-page_alloc-calculate-classzone_idx-once-from-the-zonelist-ref

Signed-off-by: Mel Gorman <mgorman@suse.de>
---
 mm/page_alloc.c | 3 +--
 1 file changed, 1 insertion(+), 2 deletions(-)

diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 0959b09..ebb947d 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -2590,8 +2590,7 @@ restart:
 	if (!(alloc_flags & ALLOC_CPUSET) && !nodemask) {
 		struct zoneref *preferred_zoneref;
 		preferred_zoneref = first_zones_zonelist(zonelist, high_zoneidx,
-				nodemask ? : &cpuset_current_mems_allowed,
-				&preferred_zone);
+				NULL, &preferred_zone);
 		classzone_idx = zonelist_zone_idx(preferred_zoneref);
 	}
 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
