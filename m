From: Andy Whitcroft <apw@shadowen.org>
Subject: [PATCH] zonelists: handle a node zonelist with no applicable entries
Date: Tue, 20 May 2008 11:23:49 +0100
Message-Id: <1211279029.0@pinky>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Andy Whitcroft <apw@shadowen.org>, Mel Gorman <mel@csn.ul.ie>, Christoph Lameter <clameter@sgi.com>, Lee Schermerhorn <lee.schermerhorn@hp.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

When booting 2.6.26-rc3 on a multi-node x86_32 numa system we are seeing
panics when trying node local allocations:

 BUG: unable to handle kernel NULL pointer dereference at 0000034c
 IP: [<c1042507>] get_page_from_freelist+0x4a/0x18e
 *pdpt = 00000000013a7001 *pde = 0000000000000000
 Oops: 0000 [#1] SMP
 Modules linked in:

 Pid: 0, comm: swapper Not tainted (2.6.26-rc3-00003-g5abc28d #82)
 EIP: 0060:[<c1042507>] EFLAGS: 00010282 CPU: 0
 EIP is at get_page_from_freelist+0x4a/0x18e
 EAX: c1371ed8 EBX: 00000000 ECX: 00000000 EDX: 00000000
 ESI: f7801180 EDI: 00000000 EBP: 00000000 ESP: c1371ec0
  DS: 007b ES: 007b FS: 00d8 GS: 0000 SS: 0068
 Process swapper (pid: 0, ti=c1370000 task=c12f5b40 task.ti=c1370000)
 Stack: 00000000 00000000 00000000 00000000 000612d0 000412d0 00000000 000412d0
        f7801180 f7c0101c f7c01018 c10426e4 f7c01018 00000001 00000044 00000000
        00000001 c12f5b40 00000001 00000010 00000000 000412d0 00000286 000412d0
 Call Trace:
  [<c10426e4>] __alloc_pages_internal+0x99/0x378
  [<c10429ca>] __alloc_pages+0x7/0x9
  [<c105e0e8>] kmem_getpages+0x66/0xef
  [<c105ec55>] cache_grow+0x8f/0x123
  [<c105f117>] ____cache_alloc_node+0xb9/0xe4
  [<c105f427>] kmem_cache_alloc_node+0x92/0xd2
  [<c122118c>] setup_cpu_cache+0xaf/0x177
  [<c105e6ca>] kmem_cache_create+0x2c8/0x353
  [<c13853af>] kmem_cache_init+0x1ce/0x3ad
  [<c13755c5>] start_kernel+0x178/0x1ee

This occurs when we are scanning the zonelists looking for a ZONE_NORMAL
page.  In this system there is only ZONE_DMA and ZONE_NORMAL memory on
node 0, all other nodes are mapped above 4GB physical.  Here is a dump
of the zonelists from this system:

    zonelists pgdat=c1400000
     0: c14006c0:2 f7c006c0:2 f7e006c0:2 c1400360:1 c1400000:0
     1: c14006c0:2 c1400360:1 c1400000:0
    zonelists pgdat=f7c00000
     0: f7c006c0:2 f7e006c0:2 c14006c0:2 c1400360:1 c1400000:0
     1: f7c006c0:2
    zonelists pgdat=f7e00000
     0: f7e006c0:2 c14006c0:2 f7c006c0:2 c1400360:1 c1400000:0
     1: f7e006c0:2

When performing a node local allocation we call get_page_from_freelist()
looking for a page.  It in turn calls first_zones_zonelist() which returns
a preferred_zone.  Where there are no applicable zones this will be NULL.
However we use this unconditionally, leading to this panic.

Where there are no applicable zones there is no possibility of a successful
allocation, so simply fail the allocation.

Signed-off-by: Andy Whitcroft <apw@shadowen.org>
Acked-by: Mel Gorman <mel@csn.ul.ie>
---
 mm/page_alloc.c |    3 +++
 1 files changed, 3 insertions(+), 0 deletions(-)
diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 6383557..30484bb 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -1396,6 +1396,9 @@ get_page_from_freelist(gfp_t gfp_mask, nodemask_t *nodemask, unsigned int order,
 
 	(void)first_zones_zonelist(zonelist, high_zoneidx, nodemask,
 							&preferred_zone);
+	if (!preferred_zone)
+		return NULL;
+
 	classzone_idx = zone_idx(preferred_zone);
 
 zonelist_scan:

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
