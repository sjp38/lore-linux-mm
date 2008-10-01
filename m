Received: from d06nrmr1407.portsmouth.uk.ibm.com (d06nrmr1407.portsmouth.uk.ibm.com [9.149.38.185])
	by mtagate6.uk.ibm.com (8.13.8/8.13.8) with ESMTP id m91HdxJa362366
	for <linux-mm@kvack.org>; Wed, 1 Oct 2008 17:39:59 GMT
Received: from d06av02.portsmouth.uk.ibm.com (d06av02.portsmouth.uk.ibm.com [9.149.37.228])
	by d06nrmr1407.portsmouth.uk.ibm.com (8.13.8/8.13.8/NCO v9.1) with ESMTP id m91Hdx7m3317994
	for <linux-mm@kvack.org>; Wed, 1 Oct 2008 18:39:59 +0100
Received: from d06av02.portsmouth.uk.ibm.com (loopback [127.0.0.1])
	by d06av02.portsmouth.uk.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id m91Hdw5t010182
	for <linux-mm@kvack.org>; Wed, 1 Oct 2008 18:39:59 +0100
Subject: [PATCH] setup_per_zone_pages_min(): take zone->lock instead of
	zone->lru_lock
From: Gerald Schaefer <gerald.schaefer@de.ibm.com>
In-Reply-To: <20080930103748.44A3.E1E9C6FF@jp.fujitsu.com>
References: <1222723206.6791.2.camel@ubuntu>
	 <20080930094017.5ed2938a.kamezawa.hiroyu@jp.fujitsu.com>
	 <20080930103748.44A3.E1E9C6FF@jp.fujitsu.com>
Content-Type: text/plain
Date: Wed, 01 Oct 2008 19:39:32 +0200
Message-Id: <1222882772.4846.40.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
From: Gerald Schaefer <gerald.schaefer@de.ibm.com>
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Yasunori Goto <y-goto@jp.fujitsu.com>, Andy Whitcroft <apw@shadowen.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, schwidefsky@de.ibm.com, heiko.carstens@de.ibm.com, Mel Gorman <mel@csn.ul.ie>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
List-ID: <linux-mm.kvack.org>

This replaces zone->lru_lock in setup_per_zone_pages_min() with zone->lock.
There seems to be no need for the lru_lock anymore, but there is a need for
zone->lock instead, because that function may call move_freepages() via
setup_zone_migrate_reserve().

Signed-off-by: Gerald Schaefer <gerald.schaefer@de.ibm.com>

---
 mm/page_alloc.c |    4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

Index: linux-2.6/mm/page_alloc.c
===================================================================
--- linux-2.6.orig/mm/page_alloc.c
+++ linux-2.6/mm/page_alloc.c
@@ -4207,7 +4207,7 @@ void setup_per_zone_pages_min(void)
 	for_each_zone(zone) {
 		u64 tmp;
 
-		spin_lock_irqsave(&zone->lru_lock, flags);
+		spin_lock_irqsave(&zone->lock, flags);
 		tmp = (u64)pages_min * zone->present_pages;
 		do_div(tmp, lowmem_pages);
 		if (is_highmem(zone)) {
@@ -4239,7 +4239,7 @@ void setup_per_zone_pages_min(void)
 		zone->pages_low   = zone->pages_min + (tmp >> 2);
 		zone->pages_high  = zone->pages_min + (tmp >> 1);
 		setup_zone_migrate_reserve(zone);
-		spin_unlock_irqrestore(&zone->lru_lock, flags);
+		spin_unlock_irqrestore(&zone->lock, flags);
 	}
 
 	/* update totalreserve_pages */


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
