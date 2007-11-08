Received: from d03relay03.boulder.ibm.com (d03relay03.boulder.ibm.com [9.17.195.228])
	by e31.co.us.ibm.com (8.13.8/8.13.8) with ESMTP id lA8Jm3RN019834
	for <linux-mm@kvack.org>; Thu, 8 Nov 2007 14:48:03 -0500
Received: from d03av02.boulder.ibm.com (d03av02.boulder.ibm.com [9.17.195.168])
	by d03relay03.boulder.ibm.com (8.13.8/8.13.8/NCO v8.5) with ESMTP id lA8JltEK236920
	for <linux-mm@kvack.org>; Thu, 8 Nov 2007 12:47:59 -0700
Received: from d03av02.boulder.ibm.com (loopback [127.0.0.1])
	by d03av02.boulder.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id lA8JltRX010229
	for <linux-mm@kvack.org>; Thu, 8 Nov 2007 12:47:55 -0700
Date: Thu, 8 Nov 2007 12:47:54 -0700
From: Dave Kleikamp <shaggy@linux.vnet.ibm.com>
Message-Id: <20071108194753.17862.60164.sendpatchset@norville.austin.ibm.com>
In-Reply-To: <20071108194709.17862.16713.sendpatchset@norville.austin.ibm.com>
References: <20071108194709.17862.16713.sendpatchset@norville.austin.ibm.com>
Subject: [RFC:PATCH 07/09] shrink_active_list: pack file tails rather than move to inactive list
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-fsdevel <linux-fsdevel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

The big question is how aggressively we pack the tails.  This looked like
an easy place to start.  If a page is being moved from the active list to
the inactive list, and the tail can be safely packed, that is not mapped,
not dirty, etc., the tail is packed and the page removed from the page
cache.

Right now, pages that never get off the inactive list will not be packed.

I will be soliciting ideas for other places in the code where tails can
be packed.  One of my goals is not to be too aggressive, where tails are
packed and unpacked repeatedly.  I also don't want to add too much overhead,
such as an extra scan of the inactive list.

Signed-off-by: Dave Kleikamp <shaggy@linux.vnet.ibm.com>
---

 mm/vmscan.c |    6 ++++++
 1 file changed, 6 insertions(+)

diff -Nurp linux006/mm/vmscan.c linux007/mm/vmscan.c
--- linux006/mm/vmscan.c	2007-11-07 08:14:01.000000000 -0600
+++ linux007/mm/vmscan.c	2007-11-08 10:49:46.000000000 -0600
@@ -19,6 +19,7 @@
 #include <linux/pagemap.h>
 #include <linux/init.h>
 #include <linux/highmem.h>
+#include <linux/vm_file_tail.h>
 #include <linux/vmstat.h>
 #include <linux/file.h>
 #include <linux/writeback.h>
@@ -1035,7 +1036,12 @@ force_reclaim_mapped:
 				list_add(&page->lru, &l_active);
 				continue;
 			}
+		} else if (vm_file_tail_pack(page)) {
+			ClearPageActive(page);
+			page_cache_release(page);
+			continue;
 		}
+
 		list_add(&page->lru, &l_inactive);
 	}
 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
