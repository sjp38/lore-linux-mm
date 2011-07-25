Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id 888AD6B0169
	for <linux-mm@kvack.org>; Mon, 25 Jul 2011 16:20:11 -0400 (EDT)
From: Johannes Weiner <jweiner@redhat.com>
Subject: [patch 1/5] mm: page_alloc: increase __GFP_BITS_SHIFT to include __GFP_OTHER_NODE
Date: Mon, 25 Jul 2011 22:19:15 +0200
Message-Id: <1311625159-13771-2-git-send-email-jweiner@redhat.com>
In-Reply-To: <1311625159-13771-1-git-send-email-jweiner@redhat.com>
References: <1311625159-13771-1-git-send-email-jweiner@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: Dave Chinner <david@fromorbit.com>, Christoph Hellwig <hch@infradead.org>, Mel Gorman <mgorman@suse.de>, Andrew Morton <akpm@linux-foundation.org>, Wu Fengguang <fengguang.wu@intel.com>, Rik van Riel <riel@redhat.com>, Minchan Kim <minchan.kim@gmail.com>, Jan Kara <jack@suse.cz>, Andi Kleen <ak@linux.intel.com>, linux-kernel@vger.kernel.org

From: Johannes Weiner <hannes@cmpxchg.org>

__GFP_OTHER_NODE is used for NUMA allocations on behalf of other
nodes.  It's supposed to be passed through from the page allocator to
zone_statistics(), but it never gets there as gfp_allowed_mask is not
wide enough and masks out the flag early in the allocation path.

The result is an accounting glitch where successful NUMA allocations
by-agent are not properly attributed as local.

Increase __GFP_BITS_SHIFT so that it includes __GFP_OTHER_NODE.

Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>
---
 include/linux/gfp.h |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/include/linux/gfp.h b/include/linux/gfp.h
index cb40892..3a76faf 100644
--- a/include/linux/gfp.h
+++ b/include/linux/gfp.h
@@ -92,7 +92,7 @@ struct vm_area_struct;
  */
 #define __GFP_NOTRACK_FALSE_POSITIVE (__GFP_NOTRACK)
 
-#define __GFP_BITS_SHIFT 23	/* Room for 23 __GFP_FOO bits */
+#define __GFP_BITS_SHIFT 24	/* Room for N __GFP_FOO bits */
 #define __GFP_BITS_MASK ((__force gfp_t)((1 << __GFP_BITS_SHIFT) - 1))
 
 /* This equals 0, but use constants in case they ever change */
-- 
1.7.6

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
