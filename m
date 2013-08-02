Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx157.postini.com [74.125.245.157])
	by kanga.kvack.org (Postfix) with SMTP id 7D9766B0039
	for <linux-mm@kvack.org>; Fri,  2 Aug 2013 12:06:45 -0400 (EDT)
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: [PATCH 6/9] mm: zone_reclaim: compaction: increase the high order pages in the watermarks
Date: Fri,  2 Aug 2013 18:06:33 +0200
Message-Id: <1375459596-30061-7-git-send-email-aarcange@redhat.com>
In-Reply-To: <1375459596-30061-1-git-send-email-aarcange@redhat.com>
References: <1375459596-30061-1-git-send-email-aarcange@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: Johannes Weiner <jweiner@redhat.com>, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, Hugh Dickins <hughd@google.com>, Richard Davies <richard@arachsys.com>, Shaohua Li <shli@kernel.org>, Rafael Aquini <aquini@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Hush Bensen <hush.bensen@gmail.com>

Prevent the scaling down to reduce the watermarks too much.

Signed-off-by: Andrea Arcangeli <aarcange@redhat.com>
---
 mm/page_alloc.c | 3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 4401983..b32ecde 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -1665,7 +1665,8 @@ static bool __zone_watermark_ok(struct zone *z, int order, unsigned long mark,
 		free_pages -= z->free_area[o].nr_free << o;
 
 		/* Require fewer higher order pages to be free */
-		min >>= 1;
+		if (o < (pageblock_order >> 2))
+			min >>= 1;
 
 		if (free_pages <= min)
 			return false;

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
