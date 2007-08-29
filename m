Received: from d01relay04.pok.ibm.com (d01relay04.pok.ibm.com [9.56.227.236])
	by e6.ny.us.ibm.com (8.13.8/8.13.8) with ESMTP id l7TKtTke000497
	for <linux-mm@kvack.org>; Wed, 29 Aug 2007 16:55:29 -0400
Received: from d01av04.pok.ibm.com (d01av04.pok.ibm.com [9.56.224.64])
	by d01relay04.pok.ibm.com (8.13.8/8.13.8/NCO v8.5) with ESMTP id l7TKs66r463904
	for <linux-mm@kvack.org>; Wed, 29 Aug 2007 16:54:06 -0400
Received: from d01av04.pok.ibm.com (loopback [127.0.0.1])
	by d01av04.pok.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id l7TKs5ER013495
	for <linux-mm@kvack.org>; Wed, 29 Aug 2007 16:54:05 -0400
Date: Wed, 29 Aug 2007 16:54:05 -0400
From: Dave Kleikamp <shaggy@linux.vnet.ibm.com>
Message-Id: <20070829205405.28328.32771.sendpatchset@norville.austin.ibm.com>
In-Reply-To: <20070829205325.28328.67953.sendpatchset@norville.austin.ibm.com>
References: <20070829205325.28328.67953.sendpatchset@norville.austin.ibm.com>
Subject: [RFC:PATCH 07/07] shrink_active_list: pack file tails rather than move to inactive list
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm <linux-mm@kvack.org>
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
--- linux006/mm/vmscan.c	2007-08-28 09:57:20.000000000 -0500
+++ linux007/mm/vmscan.c	2007-08-29 13:27:46.000000000 -0500
@@ -19,6 +19,7 @@
 #include <linux/pagemap.h>
 #include <linux/init.h>
 #include <linux/highmem.h>
+#include <linux/vm_file_tail.h>
 #include <linux/vmstat.h>
 #include <linux/file.h>
 #include <linux/writeback.h>
@@ -994,7 +995,12 @@ force_reclaim_mapped:
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
