Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx149.postini.com [74.125.245.149])
	by kanga.kvack.org (Postfix) with SMTP id 380D16B0062
	for <linux-mm@kvack.org>; Sun,  9 Sep 2012 21:18:56 -0400 (EDT)
Received: by mail-pz0-f41.google.com with SMTP id i14so1166465dad.14
        for <linux-mm@kvack.org>; Sun, 09 Sep 2012 18:18:55 -0700 (PDT)
Date: Mon, 10 Sep 2012 09:18:50 +0800
From: Shaohua Li <shli@kernel.org>
Subject: [patch 2/2 v2]compaction: check lock contention first before taking
 lock
Message-ID: <20120910011850.GD3715@kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: akpm@linux-foundation.org, mgorman@suse.de, aarcange@redhat.com

isolate_migratepages_range will take zone->lru_lock first and check if the lock
is contented, if yes, it will release the lock. This isn't efficient. If the
lock is truly contented, a lock/unlock pair will increase the lock contention.
We'd better check if the lock is contended first. compact_trylock_irqsave
perfectly meets the requirement.

V2:
leave cond_resched() pointed out by Mel.

Signed-off-by: Shaohua Li <shli@fusionio.com>
---
 mm/compaction.c |    5 +++--
 1 file changed, 3 insertions(+), 2 deletions(-)

Index: linux/mm/compaction.c
===================================================================
--- linux.orig/mm/compaction.c	2012-09-10 08:49:40.377869710 +0800
+++ linux/mm/compaction.c	2012-09-10 08:53:10.295230575 +0800
@@ -295,8 +295,9 @@ isolate_migratepages_range(struct zone *
 
 	/* Time to isolate some pages for migration */
 	cond_resched();
-	spin_lock_irqsave(&zone->lru_lock, flags);
-	locked = true;
+	locked = compact_trylock_irqsave(&zone->lru_lock, &flags, cc);
+	if (!locked)
+		return 0;
 	for (; low_pfn < end_pfn; low_pfn++) {
 		struct page *page;
 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
