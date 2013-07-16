Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx130.postini.com [74.125.245.130])
	by kanga.kvack.org (Postfix) with SMTP id 023E96B0034
	for <linux-mm@kvack.org>; Tue, 16 Jul 2013 09:42:02 -0400 (EDT)
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: [PATCH 06/10] mm: zone_reclaim: compaction: increase the high order pages in the watermarks
Date: Tue, 16 Jul 2013 15:41:50 +0200
Message-Id: <1373982114-19774-7-git-send-email-aarcange@redhat.com>
In-Reply-To: <1373982114-19774-1-git-send-email-aarcange@redhat.com>
References: <1373982114-19774-1-git-send-email-aarcange@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, Hugh Dickins <hughd@google.com>, Richard Davies <richard@arachsys.com>, Shaohua Li <shli@kernel.org>, Rafael Aquini <aquini@redhat.com>, Hush Bensen <hush.bensen@gmail.com>

Prevent the scaling down to reduce the watermarks too much.

Signed-off-by: Andrea Arcangeli <aarcange@redhat.com>
---
 mm/page_alloc.c | 3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index d94503d..f5ea1147 100644
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
