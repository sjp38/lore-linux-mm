Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx146.postini.com [74.125.245.146])
	by kanga.kvack.org (Postfix) with SMTP id 824036B005D
	for <linux-mm@kvack.org>; Mon, 23 Jul 2012 21:10:21 -0400 (EDT)
From: Minchan Kim <minchan@kernel.org>
Subject: [PATCH 2/3] mm: Warn if pg_data_t isn't initialized with zero
Date: Tue, 24 Jul 2012 10:10:34 +0900
Message-Id: <1343092235-13399-2-git-send-email-minchan@kernel.org>
In-Reply-To: <1343092235-13399-1-git-send-email-minchan@kernel.org>
References: <1343092235-13399-1-git-send-email-minchan@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Tejun Heo <tj@kernel.org>, Yinghai Lu <yinghai@kernel.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Minchan Kim <minchan@kernel.org>, linux-arch <linux-arch@vger.kernel.org>

This patch warns if memory-hotplug/boot code doesn't initialize
pg_data_t with zero when it's allocated. As I looked arch code and
memory hotplug, they already seem to initiailize pg_data_t.
So this warning should be never happen. It needs double check and
let's add checking garbage with warn. I select fields randomly
nearyby begin/middle/end of pg_data_t for checking garbage.
If we are very unlucky, those garbage might be zero but it's very unlikely,
I hope.

This patch isn't for performance but removing initialization code
which is necessary to add whenever we adds new field to pg_data_t or zone.
It's rather bothersome and error-prone about compile at least as I had
experienced.

Firstly, Andrew suggested clearing out of pg_data_t in MM core part but
Tejun doesn't like it because in the future, some archs can initialize
some fields in arch code and pass them into general MM part so blindly clearing
it out in mm core part would be very annoying.

Cc: Tejun Heo <tj@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-arch <linux-arch@vger.kernel.org>
Signed-off-by: Minchan Kim <minchan@kernel.org>
---
 mm/page_alloc.c |    3 +++
 1 file changed, 3 insertions(+)

diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index b65c362..2037eeb 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -4517,6 +4517,9 @@ void __paginginit free_area_init_node(int nid, unsigned long *zones_size,
 {
 	pg_data_t *pgdat = NODE_DATA(nid);
 
+	/* pg_data_t should be reset to zero when it's allocated */
+	WARN_ON(pgdat->nr_zones || pgdat->node_start_pfn || pgdat->classzone_idx);
+
 	pgdat->node_id = nid;
 	pgdat->node_start_pfn = node_start_pfn;
 	calculate_node_totalpages(pgdat, zones_size, zholes_size);
-- 
1.7.9.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
