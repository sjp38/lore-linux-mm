Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id 3451D6B0038
	for <linux-mm@kvack.org>; Tue, 18 Oct 2016 07:34:53 -0400 (EDT)
Received: by mail-pf0-f198.google.com with SMTP id i85so223240849pfa.5
        for <linux-mm@kvack.org>; Tue, 18 Oct 2016 04:34:53 -0700 (PDT)
Received: from foss.arm.com (foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id y6si13839971pff.4.2016.10.18.04.34.52
        for <linux-mm@kvack.org>;
        Tue, 18 Oct 2016 04:34:52 -0700 (PDT)
From: Mark Rutland <mark.rutland@arm.com>
Subject: [PATCH] mm: pagealloc: fix continued prints in show_free_areas
Date: Tue, 18 Oct 2016 12:34:17 +0100
Message-Id: <1476790457-7776-1-git-send-email-mark.rutland@arm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: Mark Rutland <mark.rutland@arm.com>, Andrew Morton <akpm@linux-foundation.org>, Vlastimil Babka <vbabka@suse.cz>, Mel Gorman <mgorman@techsingularity.net>, linux-mm@kvack.org

Recently, printk was reworked in commit:

  4bcc595ccd80decb ("printk: reinstate KERN_CONT for printing continuation
  lines")

As of this commit, printk calls missing KERN_CONT will have a linebreak
inserted implicitly.

In show_free_areas, we miss KERN_CONT in a few cases, and as a result
prints are unexpectedly split over a number of lines, making them
difficult to read (in v4.9-rc1).

This patch uses pr_cont (with uits implicit KERN_CONT) to mark all
continued prints that occur withing a show_free_areas() call. Note that
show_migration_types() is only called by show_free_areas().
Depending on CONFIG_NUMA a printk after show_node() may or may not be a
continuation, but follows an explicit newline if not (and thus marking
it as a continuation should not be harmful).

Signed-off-by: Mark Rutland <mark.rutland@arm.com>
Cc: Andrew Morton <akpm@linux-foundation.org>
Cc: Vlastimil Babka <vbabka@suse.cz>
Cc: Mel Gorman <mgorman@techsingularity.net>
Cc: linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org
---
 mm/page_alloc.c | 14 +++++++-------
 1 file changed, 7 insertions(+), 7 deletions(-)

diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 2b3bf67..833f271 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -4224,7 +4224,7 @@ static void show_migration_types(unsigned char type)
 	}
 
 	*p = '\0';
-	printk("(%s) ", tmp);
+	pr_cont("(%s) ", tmp);
 }
 
 /*
@@ -4335,7 +4335,7 @@ void show_free_areas(unsigned int filter)
 			free_pcp += per_cpu_ptr(zone->pageset, cpu)->pcp.count;
 
 		show_node(zone);
-		printk("%s"
+		pr_cont("%s"
 			" free:%lukB"
 			" min:%lukB"
 			" low:%lukB"
@@ -4382,8 +4382,8 @@ void show_free_areas(unsigned int filter)
 			K(zone_page_state(zone, NR_FREE_CMA_PAGES)));
 		printk("lowmem_reserve[]:");
 		for (i = 0; i < MAX_NR_ZONES; i++)
-			printk(" %ld", zone->lowmem_reserve[i]);
-		printk("\n");
+			pr_cont(" %ld", zone->lowmem_reserve[i]);
+		pr_cont("\n");
 	}
 
 	for_each_populated_zone(zone) {
@@ -4394,7 +4394,7 @@ void show_free_areas(unsigned int filter)
 		if (skip_free_areas_node(filter, zone_to_nid(zone)))
 			continue;
 		show_node(zone);
-		printk("%s: ", zone->name);
+		pr_cont("%s: ", zone->name);
 
 		spin_lock_irqsave(&zone->lock, flags);
 		for (order = 0; order < MAX_ORDER; order++) {
@@ -4412,11 +4412,11 @@ void show_free_areas(unsigned int filter)
 		}
 		spin_unlock_irqrestore(&zone->lock, flags);
 		for (order = 0; order < MAX_ORDER; order++) {
-			printk("%lu*%lukB ", nr[order], K(1UL) << order);
+			pr_cont("%lu*%lukB ", nr[order], K(1UL) << order);
 			if (nr[order])
 				show_migration_types(types[order]);
 		}
-		printk("= %lukB\n", K(total));
+		pr_cont("= %lukB\n", K(total));
 	}
 
 	hugetlb_show_meminfo();
-- 
1.9.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
