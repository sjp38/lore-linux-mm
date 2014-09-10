Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qg0-f47.google.com (mail-qg0-f47.google.com [209.85.192.47])
	by kanga.kvack.org (Postfix) with ESMTP id BCDFF6B0036
	for <linux-mm@kvack.org>; Wed, 10 Sep 2014 02:12:29 -0400 (EDT)
Received: by mail-qg0-f47.google.com with SMTP id i50so4115960qgf.20
        for <linux-mm@kvack.org>; Tue, 09 Sep 2014 23:12:29 -0700 (PDT)
Received: from na01-bl2-obe.outbound.protection.outlook.com (mail-bl2on0117.outbound.protection.outlook.com. [65.55.169.117])
        by mx.google.com with ESMTPS id d11si2286250qgf.39.2014.09.09.23.12.28
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Tue, 09 Sep 2014 23:12:28 -0700 (PDT)
From: Xiubo Li <Li.Xiubo@freescale.com>
Subject: [PATCH] mm/compaction: Fix warning of 'flags' may be used uninitialized
Date: Wed, 10 Sep 2014 14:12:20 +0800
Message-ID: <1410329540-40708-1-git-send-email-Li.Xiubo@freescale.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org, vbabka@suse.cz, mgorman@suse.de, rientjes@google.com, minchan@kernel.org, linux-mm@kvack.org
Cc: Xiubo Li <Li.Xiubo@freescale.com>

C      mm/compaction.o
mm/compaction.c: In function isolate_freepages_block:
mm/compaction.c:364:37: warning: flags may be used uninitialized in
this function [-Wmaybe-uninitialized]
       && compact_unlock_should_abort(&cc->zone->lock, flags,
                                     ^
In file included from include/linux/irqflags.h:15:0,
                 from ./arch/arm/include/asm/bitops.h:27,
                 from include/linux/bitops.h:33,
                 from include/linux/kernel.h:10,
                 from include/linux/list.h:8,
                 from include/linux/preempt.h:10,
                 from include/linux/spinlock.h:50,
                 from include/linux/swap.h:4,
                 from mm/compaction.c:10:
mm/compaction.c: In function isolate_migratepages_block:
./arch/arm/include/asm/irqflags.h:152:2: warning: flags may be used
uninitialized in this function [-Wmaybe-uninitialized]
  asm volatile(
  ^
mm/compaction.c:576:16: note: flags as declared here
  unsigned long flags;
                ^

Signed-off-by: Xiubo Li <Li.Xiubo@freescale.com>
---
 mm/compaction.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/mm/compaction.c b/mm/compaction.c
index 7d9d92e..fb28d85 100644
--- a/mm/compaction.c
+++ b/mm/compaction.c
@@ -344,7 +344,7 @@ static unsigned long isolate_freepages_block(struct compact_control *cc,
 {
 	int nr_scanned = 0, total_isolated = 0;
 	struct page *cursor, *valid_page = NULL;
-	unsigned long flags;
+	unsigned long flags = 0;
 	bool locked = false;
 	unsigned long blockpfn = *start_pfn;
 
@@ -573,7 +573,7 @@ isolate_migratepages_block(struct compact_control *cc, unsigned long low_pfn,
 	unsigned long nr_scanned = 0, nr_isolated = 0;
 	struct list_head *migratelist = &cc->migratepages;
 	struct lruvec *lruvec;
-	unsigned long flags;
+	unsigned long flags = 0;
 	bool locked = false;
 	struct page *page = NULL, *valid_page = NULL;
 
-- 
2.1.0.27.g96db324

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
