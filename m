Message-Id: <20080430044321.245211049@sgi.com>
References: <20080430044251.266380837@sgi.com>
Date: Tue, 29 Apr 2008 21:43:01 -0700
From: Christoph Lameter <clameter@sgi.com>
Subject: [10/11] vcompound: Fallback for zone wait table
Content-Disposition: inline; filename=vcp_waittable_support
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: akpm@linux-foundation.org
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Currently vmalloc may be used for allocating zone wait table.
Use a virtualizable compound page request in order to be able to use
a physically contiguous page that can then use the large kernel TLBs.

Drawback: The zone wait table is rounded up to the next power of two which
may cost some memory.

Signed-off-by: Christoph Lameter <clameter@sgi.com>
---
 mm/page_alloc.c |    3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

Index: linux-2.6.25-rc8-mm2/mm/page_alloc.c
===================================================================
--- linux-2.6.25-rc8-mm2.orig/mm/page_alloc.c	2008-04-11 20:20:44.000000000 -0700
+++ linux-2.6.25-rc8-mm2/mm/page_alloc.c	2008-04-11 20:23:36.000000000 -0700
@@ -2884,7 +2884,8 @@ int zone_wait_table_init(struct zone *zo
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
