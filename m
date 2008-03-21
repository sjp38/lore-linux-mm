Message-Id: <20080321061726.035952517@sgi.com>
References: <20080321061703.921169367@sgi.com>
Date: Thu, 20 Mar 2008 23:17:11 -0700
From: Christoph Lameter <clameter@sgi.com>
Subject: [08/14] vcompound: Fallback for zone wait table
Content-Disposition: inline; filename=0010-vcompound-Fallback-for-wait-table.patch
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

Currently vmalloc may be used for allocating zone wait table.
Use virtual compound page in order to be able to use a physically contiguous
page that can then use the large kernel TLBs.

Drawback: The zone wait table is rounded up to the next power of two which
may cost some memory.

Signed-off-by: Christoph Lameter <clameter@sgi.com>
---
 mm/page_alloc.c |    3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

Index: linux-2.6.25-rc5-mm1/mm/page_alloc.c
===================================================================
--- linux-2.6.25-rc5-mm1.orig/mm/page_alloc.c	2008-03-20 20:03:50.885900600 -0700
+++ linux-2.6.25-rc5-mm1/mm/page_alloc.c	2008-03-20 20:04:43.282104684 -0700
@@ -2866,7 +2866,8 @@ int zone_wait_table_init(struct zone *zo
 		 * To use this new node's memory, further consideration will be
 		 * necessary.
 		 */
-		zone->wait_table = vmalloc(alloc_size);
+		zone->wait_table = __alloc_vcompound(GFP_KERNEL,
+						get_order(alloc_size));
 	}
 	if (!zone->wait_table)
 		return -ENOMEM;

-- 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
