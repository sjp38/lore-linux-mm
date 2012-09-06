Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx184.postini.com [74.125.245.184])
	by kanga.kvack.org (Postfix) with SMTP id 529596B005A
	for <linux-mm@kvack.org>; Thu,  6 Sep 2012 06:44:13 -0400 (EDT)
Received: by pbbro12 with SMTP id ro12so2565204pbb.14
        for <linux-mm@kvack.org>; Thu, 06 Sep 2012 03:44:12 -0700 (PDT)
Date: Thu, 6 Sep 2012 18:44:04 +0800
From: Shaohua Li <shli@kernel.org>
Subject: [patch 1/2]compaction: check migrated page number
Message-ID: <20120906104404.GA12718@kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: akpm@linux-foundation.org, mgorman@suse.de, aarcange@redhat.com


isolate_migratepages_range() might isolate none pages, for example, when
zone->lru_lock is contended and compaction is async. In this case, we should
abort compaction, otherwise, compact_zone will run a useless loop and make
zone->lru_lock is even contended.

Signed-off-by: Shaohua Li <shli@fusionio.com>
---
 mm/compaction.c |    2 ++
 1 file changed, 2 insertions(+)

Index: linux/mm/compaction.c
===================================================================
--- linux.orig/mm/compaction.c	2012-08-22 09:51:39.295322268 +0800
+++ linux/mm/compaction.c	2012-09-06 14:46:13.923144263 +0800
@@ -402,6 +402,8 @@ isolate_migratepages_range(struct zone *
 
 	trace_mm_compaction_isolate_migratepages(nr_scanned, nr_isolated);
 
+	if (!nr_isolated)
+		return 0;
 	return low_pfn;
 }
 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
