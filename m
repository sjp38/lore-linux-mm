Message-Id: <20071004040004.253793692@sgi.com>
References: <20071004035935.042951211@sgi.com>
Date: Wed, 03 Oct 2007 20:59:46 -0700
From: Christoph Lameter <clameter@sgi.com>
Subject: [11/18] Page allocator: Use a higher order allocation for the zone wait table.
Content-Disposition: inline; filename=vcompound_wait_table_no_vmalloc
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: akpm@linux-foundation.org
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

Currently vmalloc is used for the zone wait table. Therefore the vmalloc
page tables have to be consulted by the MMU to access the wait table.
We can now use GFP_VFALLBACK to attempt the use of a physically contiguous
page that can then use the large kernel TLBs.

Drawback: The zone wait table is rounded up to the next power of two which
may cost some memory.

Signed-off-by: Christoph Lameter <clameter@sgi.com>

---
 mm/page_alloc.c |    4 +++-
 1 file changed, 3 insertions(+), 1 deletion(-)

Index: linux-2.6/mm/page_alloc.c
===================================================================
--- linux-2.6.orig/mm/page_alloc.c	2007-10-03 18:07:16.000000000 -0700
+++ linux-2.6/mm/page_alloc.c	2007-10-03 18:07:20.000000000 -0700
@@ -2585,7 +2585,9 @@ int zone_wait_table_init(struct zone *zo
 		 * To use this new node's memory, further consideration will be
 		 * necessary.
 		 */
-		zone->wait_table = (wait_queue_head_t *)vmalloc(alloc_size);
+		zone->wait_table = (wait_queue_head_t *)
+			__get_free_pages(GFP_VFALLBACK,
+					get_order(alloc_size));
 	}
 	if (!zone->wait_table)
 		return -ENOMEM;

-- 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
