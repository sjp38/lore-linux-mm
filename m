Date: Thu, 18 May 2006 15:21:04 +0100
Subject: [PATCH 1/2] zone init check and report unaligned zone boundaries fix
Message-ID: <20060518142104.GA9407@shadowen.org>
References: <exportbomb.1147962048@pinky>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
From: Andy Whitcroft <apw@shadowen.org>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@osdl.org>
Cc: Andy Whitcroft <apw@shadowen.org>, nickpiggin@yahoo.com.au, haveblue@us.ibm.com, bob.picco@hp.com, mingo@elte.hu, mbligh@mbligh.org, ak@suse.de, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

zone init check and report unaligned zone boundaries fix

We are reporting bad boundaries for the first zone which is allowed
to be missaligned because nodes are not allowed to be missaligned,
and zones which have zero size.  Cull them.

Signed-off-by: Andy Whitcroft <apw@shadowen.org>
---
 page_alloc.c |    3 ++-
 1 files changed, 2 insertions(+), 1 deletion(-)
diff -upN reference/mm/page_alloc.c current/mm/page_alloc.c
--- reference/mm/page_alloc.c
+++ current/mm/page_alloc.c
@@ -2223,7 +2223,8 @@ static void __meminit free_area_init_cor
 		struct zone *zone = pgdat->node_zones + j;
 		unsigned long size, realsize;
 
-		if (zone_boundary_align_pfn(zone_start_pfn) != zone_start_pfn)
+		if (zone_boundary_align_pfn(zone_start_pfn) !=
+					zone_start_pfn && j != 0 && size != 0)
 			printk(KERN_CRIT "node %d zone %s missaligned "
 					"start pfn\n", nid, zone_names[j]);
 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
