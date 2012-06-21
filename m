Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx123.postini.com [74.125.245.123])
	by kanga.kvack.org (Postfix) with SMTP id BC2CF6B0074
	for <linux-mm@kvack.org>; Thu, 21 Jun 2012 02:52:39 -0400 (EDT)
Received: by dakp5 with SMTP id p5so550355dak.14
        for <linux-mm@kvack.org>; Wed, 20 Jun 2012 23:52:38 -0700 (PDT)
Date: Wed, 20 Jun 2012 23:52:35 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: [patch] mm, thp: abort compaction if migration page cannot be charged
 to memcg
Message-ID: <alpine.DEB.2.00.1206202351030.28770@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Mel Gorman <mgorman@suse.de>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Rik van Riel <riel@redhat.com>, Minchan Kim <minchan@kernel.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

If page migration cannot charge the new page to the memcg,
migrate_pages() will return -ENOMEM.  This isn't considered in memory
compaction however, and the loop continues to iterate over all pageblocks
trying in a futile attempt to continue migrations which are only bound to
fail.

This will short circuit and fail memory compaction if migrate_pages()
returns -ENOMEM.  COMPACT_PARTIAL is returned in case some migrations
were successful so that the page allocator will retry.

Signed-off-by: David Rientjes <rientjes@google.com>
---
 mm/compaction.c |    5 ++++-
 1 file changed, 4 insertions(+), 1 deletion(-)

diff --git a/mm/compaction.c b/mm/compaction.c
--- a/mm/compaction.c
+++ b/mm/compaction.c
@@ -701,8 +701,11 @@ static int compact_zone(struct zone *zone, struct compact_control *cc)
 		if (err) {
 			putback_lru_pages(&cc->migratepages);
 			cc->nr_migratepages = 0;
+			if (err == -ENOMEM) {
+				ret = COMPACT_PARTIAL;
+				goto out;
+			}
 		}
-
 	}
 
 out:

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
