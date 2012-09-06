Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx147.postini.com [74.125.245.147])
	by kanga.kvack.org (Postfix) with SMTP id B1ADC6B0062
	for <linux-mm@kvack.org>; Thu,  6 Sep 2012 06:44:36 -0400 (EDT)
Received: by dadi14 with SMTP id i14so1104955dad.14
        for <linux-mm@kvack.org>; Thu, 06 Sep 2012 03:44:36 -0700 (PDT)
Date: Thu, 6 Sep 2012 18:44:29 +0800
From: Shaohua Li <shli@kernel.org>
Subject: [patch 2/2]compaction: check lock contention first before taking lock
Message-ID: <20120906104429.GB12718@kernel.org>
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

Signed-off-by: Shaohua Li <shli@fusionio.com>
---
 mm/compaction.c |    7 ++++---
 1 file changed, 4 insertions(+), 3 deletions(-)

Index: linux/mm/compaction.c
===================================================================
--- linux.orig/mm/compaction.c	2012-09-06 14:46:13.923144263 +0800
+++ linux/mm/compaction.c	2012-09-06 14:46:58.118588574 +0800
@@ -295,9 +295,9 @@ isolate_migratepages_range(struct zone *
 	}
 
 	/* Time to isolate some pages for migration */
-	cond_resched();
-	spin_lock_irqsave(&zone->lru_lock, flags);
-	locked = true;
+	locked = compact_trylock_irqsave(&zone->lru_lock, &flags, cc);
+	if (!locked)
+		goto skip;
 	for (; low_pfn < end_pfn; low_pfn++) {
 		struct page *page;
 
@@ -400,6 +400,7 @@ isolate_migratepages_range(struct zone *
 	if (locked)
 		spin_unlock_irqrestore(&zone->lru_lock, flags);
 
+skip:
 	trace_mm_compaction_isolate_migratepages(nr_scanned, nr_isolated);
 
 	if (!nr_isolated)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
