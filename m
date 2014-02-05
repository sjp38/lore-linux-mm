Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f173.google.com (mail-pd0-f173.google.com [209.85.192.173])
	by kanga.kvack.org (Postfix) with ESMTP id 9ABC16B0031
	for <linux-mm@kvack.org>; Tue,  4 Feb 2014 21:45:01 -0500 (EST)
Received: by mail-pd0-f173.google.com with SMTP id y10so8992310pdj.18
        for <linux-mm@kvack.org>; Tue, 04 Feb 2014 18:45:01 -0800 (PST)
Received: from mail-pb0-x235.google.com (mail-pb0-x235.google.com [2607:f8b0:400e:c01::235])
        by mx.google.com with ESMTPS id eb3si26988889pbc.206.2014.02.04.18.45.00
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Tue, 04 Feb 2014 18:45:00 -0800 (PST)
Received: by mail-pb0-f53.google.com with SMTP id md12so9272733pbc.12
        for <linux-mm@kvack.org>; Tue, 04 Feb 2014 18:45:00 -0800 (PST)
Date: Tue, 4 Feb 2014 18:44:58 -0800 (PST)
From: David Rientjes <rientjes@google.com>
Subject: [patch v2] mm, compaction: avoid isolating pinned pages
In-Reply-To: <alpine.DEB.2.02.1402031848290.15032@chino.kir.corp.google.com>
Message-ID: <alpine.DEB.2.02.1402041842100.14045@chino.kir.corp.google.com>
References: <alpine.DEB.2.02.1402012145510.2593@chino.kir.corp.google.com> <20140203095329.GH6732@suse.de> <alpine.DEB.2.02.1402030231590.31061@chino.kir.corp.google.com> <20140204000237.GA17331@lge.com> <alpine.DEB.2.02.1402031610090.10778@chino.kir.corp.google.com>
 <20140204015332.GA14779@lge.com> <alpine.DEB.2.02.1402031755440.26347@chino.kir.corp.google.com> <20140204021533.GA14924@lge.com> <alpine.DEB.2.02.1402031848290.15032@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Joonsoo Kim <iamjoonsoo.kim@lge.com>, Hugh Dickins <hughd@google.com>, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

Page migration will fail for memory that is pinned in memory with, for
example, get_user_pages().  In this case, it is unnecessary to take
zone->lru_lock or isolating the page and passing it to page migration
which will ultimately fail.

This is a racy check, the page can still change from under us, but in
that case we'll just fail later when attempting to move the page.

This avoids very expensive memory compaction when faulting transparent
hugepages after pinning a lot of memory with a Mellanox driver.

On a 128GB machine and pinning ~120GB of memory, before this patch we
see the enormous disparity in the number of page migration failures
because of the pinning (from /proc/vmstat):

	compact_pages_moved 8450
	compact_pagemigrate_failed 15614415

0.05% of pages isolated are successfully migrated and explicitly 
triggering memory compaction takes 102 seconds.  After the patch:

	compact_pages_moved 9197
	compact_pagemigrate_failed 7

99.9% of pages isolated are now successfully migrated in this 
configuration and memory compaction takes less than one second.

Signed-off-by: David Rientjes <rientjes@google.com>
---
 v2: address page count issue per Joonsoo

 mm/compaction.c | 9 +++++++++
 1 file changed, 9 insertions(+)

diff --git a/mm/compaction.c b/mm/compaction.c
--- a/mm/compaction.c
+++ b/mm/compaction.c
@@ -578,6 +578,15 @@ isolate_migratepages_range(struct zone *zone, struct compact_control *cc,
 			continue;
 		}
 
+		/*
+		 * Migration will fail if an anonymous page is pinned in memory,
+		 * so avoid taking lru_lock and isolating it unnecessarily in an
+		 * admittedly racy check.
+		 */
+		if (!page_mapping(page) &&
+		    page_count(page) > page_mapcount(page))
+			continue;
+
 		/* Check if it is ok to still hold the lock */
 		locked = compact_checklock_irqsave(&zone->lru_lock, &flags,
 								locked, cc);

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
