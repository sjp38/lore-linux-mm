Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id 9187E6B0253
	for <linux-mm@kvack.org>; Thu, 19 May 2016 18:11:26 -0400 (EDT)
Received: by mail-pf0-f199.google.com with SMTP id 129so13953091pfx.0
        for <linux-mm@kvack.org>; Thu, 19 May 2016 15:11:26 -0700 (PDT)
Received: from mail-pa0-x235.google.com (mail-pa0-x235.google.com. [2607:f8b0:400e:c03::235])
        by mx.google.com with ESMTPS id sj6si5498384pac.205.2016.05.19.15.11.25
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 19 May 2016 15:11:25 -0700 (PDT)
Received: by mail-pa0-x235.google.com with SMTP id tb2so15622022pac.2
        for <linux-mm@kvack.org>; Thu, 19 May 2016 15:11:25 -0700 (PDT)
Date: Thu, 19 May 2016 15:11:23 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: [patch] mm, migrate: increment fail count on ENOMEM
Message-ID: <alpine.DEB.2.10.1605191510230.32658@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Vlastimil Babka <vbabka@suse.cz>, Mel Gorman <mgorman@techsingularity.net>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

If page migration fails due to -ENOMEM, nr_failed should still be
incremented for proper statistics.

This was encountered recently when all page migration vmstats showed 0,
and inferred that migrate_pages() was never called, although in reality
the first page migration failed because compaction_alloc() failed to find
a migration target.

This patch increments nr_failed so the vmstat is properly accounted on
ENOMEM.

Signed-off-by: David Rientjes <rientjes@google.com>
---
 mm/migrate.c | 1 +
 1 file changed, 1 insertion(+)

diff --git a/mm/migrate.c b/mm/migrate.c
--- a/mm/migrate.c
+++ b/mm/migrate.c
@@ -1171,6 +1171,7 @@ int migrate_pages(struct list_head *from, new_page_t get_new_page,
 
 			switch(rc) {
 			case -ENOMEM:
+				nr_failed++;
 				goto out;
 			case -EAGAIN:
 				retry++;

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
