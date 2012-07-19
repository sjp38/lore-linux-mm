Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx172.postini.com [74.125.245.172])
	by kanga.kvack.org (Postfix) with SMTP id B08FA6B0044
	for <linux-mm@kvack.org>; Thu, 19 Jul 2012 10:36:52 -0400 (EDT)
From: Mel Gorman <mgorman@suse.de>
Subject: [PATCH 08/34] vmscan: reduce wind up shrinker->nr when shrinker can't do work
Date: Thu, 19 Jul 2012 15:36:18 +0100
Message-Id: <1342708604-26540-9-git-send-email-mgorman@suse.de>
In-Reply-To: <1342708604-26540-1-git-send-email-mgorman@suse.de>
References: <1342708604-26540-1-git-send-email-mgorman@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Stable <stable@vger.kernel.org>
Cc: "Linux-MM <linux-mm"@kvack.org, LKML <linux-kernel@vger.kernel.org>, Mel Gorman <mgorman@suse.de>

From: Dave Chinner <dchinner@redhat.com>

commit 3567b59aa80ac4417002bf58e35dce5c777d4164 upstream.

Stable note: Not tracked in Bugzilla. This patch reduces excessive
	reclaim of slab objects reducing the amount of information that
	has to be brought back in from disk. The third and fourth paragram
	in the series describes the impact.

When a shrinker returns -1 to shrink_slab() to indicate it cannot do
any work given the current memory reclaim requirements, it adds the
entire total_scan count to shrinker->nr. The idea behind this is that
when the shrinker is next called and can do work, it will do the work
of the previously aborted shrinker call as well.

However, if a filesystem is doing lots of allocation with GFP_NOFS
set, then we get many, many more aborts from the shrinkers than we
do successful calls. The result is that shrinker->nr winds up to
it's maximum permissible value (twice the current cache size) and
then when the next shrinker call that can do work is issued, it
has enough scan count built up to free the entire cache twice over.

This manifests itself in the cache going from full to empty in a
matter of seconds, even when only a small part of the cache is
needed to be emptied to free sufficient memory.

Under metadata intensive workloads on ext4 and XFS, I'm seeing the
VFS caches increase memory consumption up to 75% of memory (no page
cache pressure) over a period of 30-60s, and then the shrinker
empties them down to zero in the space of 2-3s. This cycle repeats
over and over again, with the shrinker completely trashing the inode
and dentry caches every minute or so the workload continues.

This behaviour was made obvious by the shrink_slab tracepoints added
earlier in the series, and made worse by the patch that corrected
the concurrent accounting of shrinker->nr.

To avoid this problem, stop repeated small increments of the total
scan value from winding shrinker->nr up to a value that can cause
the entire cache to be freed. We still need to allow it to wind up,
so use the delta as the "large scan" threshold check - if the delta
is more than a quarter of the entire cache size, then it is a large
scan and allowed to cause lots of windup because we are clearly
needing to free lots of memory.

If it isn't a large scan then limit the total scan to half the size
of the cache so that windup never increases to consume the whole
cache. Reducing the total scan limit further does not allow enough
wind-up to maintain the current levels of performance, whilst a
higher threshold does not prevent the windup from freeing the entire
cache under sustained workloads.

Signed-off-by: Dave Chinner <dchinner@redhat.com>
Signed-off-by: Al Viro <viro@zeniv.linux.org.uk>
Signed-off-by: Mel Gorman <mgorman@suse.de>
---
 mm/vmscan.c |   15 +++++++++++++++
 1 file changed, 15 insertions(+)

diff --git a/mm/vmscan.c b/mm/vmscan.c
index 31b551e..8ca1cd5 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -277,6 +277,21 @@ unsigned long shrink_slab(struct shrink_control *shrink,
 		}
 
 		/*
+		 * We need to avoid excessive windup on filesystem shrinkers
+		 * due to large numbers of GFP_NOFS allocations causing the
+		 * shrinkers to return -1 all the time. This results in a large
+		 * nr being built up so when a shrink that can do some work
+		 * comes along it empties the entire cache due to nr >>>
+		 * max_pass.  This is bad for sustaining a working set in
+		 * memory.
+		 *
+		 * Hence only allow the shrinker to scan the entire cache when
+		 * a large delta change is calculated directly.
+		 */
+		if (delta < max_pass / 4)
+			total_scan = min(total_scan, max_pass / 2);
+
+		/*
 		 * Avoid risking looping forever due to too large nr value:
 		 * never try to free more than twice the estimate number of
 		 * freeable entries.
-- 
1.7.9.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
