Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx188.postini.com [74.125.245.188])
	by kanga.kvack.org (Postfix) with SMTP id B83726B0032
	for <linux-mm@kvack.org>; Tue, 16 Jul 2013 09:42:03 -0400 (EDT)
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: [PATCH 02/10] mm: zone_reclaim: compaction: scan all memory with /proc/sys/vm/compact_memory
Date: Tue, 16 Jul 2013 15:41:46 +0200
Message-Id: <1373982114-19774-3-git-send-email-aarcange@redhat.com>
In-Reply-To: <1373982114-19774-1-git-send-email-aarcange@redhat.com>
References: <1373982114-19774-1-git-send-email-aarcange@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, Hugh Dickins <hughd@google.com>, Richard Davies <richard@arachsys.com>, Shaohua Li <shli@kernel.org>, Rafael Aquini <aquini@redhat.com>, Hush Bensen <hush.bensen@gmail.com>

Reset the stats so /proc/sys/vm/compact_memory will scan all memory.

Signed-off-by: Andrea Arcangeli <aarcange@redhat.com>
Reviewed-by: Rik van Riel <riel@redhat.com>
Acked-by: Rafael Aquini <aquini@redhat.com>
Acked-by: Mel Gorman <mgorman@suse.de>
---
 mm/compaction.c | 4 +++-
 1 file changed, 3 insertions(+), 1 deletion(-)

diff --git a/mm/compaction.c b/mm/compaction.c
index 05ccb4c..cac9594 100644
--- a/mm/compaction.c
+++ b/mm/compaction.c
@@ -1136,12 +1136,14 @@ void compact_pgdat(pg_data_t *pgdat, int order)
 
 static void compact_node(int nid)
 {
+	pg_data_t *pgdat = NODE_DATA(nid);
 	struct compact_control cc = {
 		.order = -1,
 		.sync = true,
 	};
 
-	__compact_pgdat(NODE_DATA(nid), &cc);
+	reset_isolation_suitable(pgdat);
+	__compact_pgdat(pgdat, &cc);
 }
 
 /* Compact all nodes in the system */

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
