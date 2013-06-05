Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx112.postini.com [74.125.245.112])
	by kanga.kvack.org (Postfix) with SMTP id 41E966B0036
	for <linux-mm@kvack.org>; Wed,  5 Jun 2013 11:10:46 -0400 (EDT)
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: [PATCH 5/7] mm: compaction: increase the high order pages in the watermarks
Date: Wed,  5 Jun 2013 17:10:35 +0200
Message-Id: <1370445037-24144-6-git-send-email-aarcange@redhat.com>
In-Reply-To: <1370445037-24144-1-git-send-email-aarcange@redhat.com>
References: <1370445037-24144-1-git-send-email-aarcange@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, Hugh Dickins <hughd@google.com>, Richard Davies <richard@arachsys.com>, Shaohua Li <shli@kernel.org>, Rafael Aquini <aquini@redhat.com>

Require more high order pages in the watermarks, to give more margin
for concurrent allocations. If there are too few pages, they can
disappear too soon.

Signed-off-by: Andrea Arcangeli <aarcange@redhat.com>
---
 mm/page_alloc.c | 3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 3931d16..c13e062 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -1646,7 +1646,8 @@ static bool __zone_watermark_ok(struct zone *z, int order, unsigned long mark,
 		free_pages -= z->free_area[o].nr_free << o;
 
 		/* Require fewer higher order pages to be free */
-		min >>= 1;
+		if (o >= pageblock_order-1)
+			min >>= 1;
 
 		if (free_pages <= min)
 			return false;

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
