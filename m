Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx110.postini.com [74.125.245.110])
	by kanga.kvack.org (Postfix) with SMTP id 3E15C6B0031
	for <linux-mm@kvack.org>; Wed,  4 Sep 2013 19:26:02 -0400 (EDT)
Received: by mail-pa0-f51.google.com with SMTP id lf1so1103600pab.10
        for <linux-mm@kvack.org>; Wed, 04 Sep 2013 16:26:01 -0700 (PDT)
Date: Wed, 4 Sep 2013 16:25:59 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: [patch] mm, compaction: periodically schedule when freeing pages
Message-ID: <alpine.DEB.2.02.1309041625060.29607@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, Minchan Kim <minchan@kernel.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

We've been getting warnings about an excessive amount of time spent
allocating pages for migration during memory compaction without
scheduling.  isolate_freepages_block() already periodically checks for
contended locks or the need to schedule, but isolate_freepages() never
does.

When a zone is massively long and no suitable targets can be found, this
iteration can be quite expensive without ever doing cond_resched().

Check periodically for the need to reschedule while the compaction free
scanner iterates.

Signed-off-by: David Rientjes <rientjes@google.com>
---
 mm/compaction.c | 7 +++++++
 1 file changed, 7 insertions(+)

diff --git a/mm/compaction.c b/mm/compaction.c
--- a/mm/compaction.c
+++ b/mm/compaction.c
@@ -677,6 +677,13 @@ static void isolate_freepages(struct zone *zone,
 					pfn -= pageblock_nr_pages) {
 		unsigned long isolated;
 
+		/*
+		 * This can iterate a massively long zone without finding any
+		 * suitable migration targets, so periodically check if we need
+		 * to schedule.
+		 */
+		cond_resched();
+
 		if (!pfn_valid(pfn))
 			continue;
 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
