Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx146.postini.com [74.125.245.146])
	by kanga.kvack.org (Postfix) with SMTP id 65C0A6B0033
	for <linux-mm@kvack.org>; Wed,  3 Jul 2013 19:30:50 -0400 (EDT)
From: Toshi Kani <toshi.kani@hp.com>
Subject: [PATCH] mm/memory_hotplug.c: Fix return value of online_pages()
Date: Wed,  3 Jul 2013 17:29:59 -0600
Message-Id: <1372894199-19623-1-git-send-email-toshi.kani@hp.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, isimatu.yasuaki@jp.fujitsu.com, tangchen@cn.fujitsu.com, Toshi Kani <toshi.kani@hp.com>

online_pages() is called from memory_block_action() when a user
requests to online a memory block via sysfs.  This function needs
to return a proper error value in case of error.

Signed-off-by: Toshi Kani <toshi.kani@hp.com>
---
 mm/memory_hotplug.c |    6 +++---
 1 file changed, 3 insertions(+), 3 deletions(-)

diff --git a/mm/memory_hotplug.c b/mm/memory_hotplug.c
index cd2990f..ca1dd3a 100644
--- a/mm/memory_hotplug.c
+++ b/mm/memory_hotplug.c
@@ -914,19 +914,19 @@ int __ref online_pages(unsigned long pfn, unsigned long nr_pages, int online_typ
 	if ((zone_idx(zone) > ZONE_NORMAL || online_type == ONLINE_MOVABLE) &&
 	    !can_online_high_movable(zone)) {
 		unlock_memory_hotplug();
-		return -1;
+		return -EINVAL;
 	}
 
 	if (online_type == ONLINE_KERNEL && zone_idx(zone) == ZONE_MOVABLE) {
 		if (move_pfn_range_left(zone - 1, zone, pfn, pfn + nr_pages)) {
 			unlock_memory_hotplug();
-			return -1;
+			return -EINVAL;
 		}
 	}
 	if (online_type == ONLINE_MOVABLE && zone_idx(zone) == ZONE_MOVABLE - 1) {
 		if (move_pfn_range_right(zone, zone + 1, pfn, pfn + nr_pages)) {
 			unlock_memory_hotplug();
-			return -1;
+			return -EINVAL;
 		}
 	}
 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
