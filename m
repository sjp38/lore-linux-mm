Received: from d06nrmr1407.portsmouth.uk.ibm.com (d06nrmr1407.portsmouth.uk.ibm.com [9.149.38.185])
	by mtagate7.uk.ibm.com (8.13.8/8.13.8) with ESMTP id m4KAplvr106132
	for <linux-mm@kvack.org>; Tue, 20 May 2008 10:51:47 GMT
Received: from d06av01.portsmouth.uk.ibm.com (d06av01.portsmouth.uk.ibm.com [9.149.37.212])
	by d06nrmr1407.portsmouth.uk.ibm.com (8.13.8/8.13.8/NCO v8.7) with ESMTP id m4KAplkk2744456
	for <linux-mm@kvack.org>; Tue, 20 May 2008 11:51:47 +0100
Received: from d06av01.portsmouth.uk.ibm.com (loopback [127.0.0.1])
	by d06av01.portsmouth.uk.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id m4KApkrX027970
	for <linux-mm@kvack.org>; Tue, 20 May 2008 11:51:46 +0100
Date: Tue, 20 May 2008 12:51:45 +0200
From: Heiko Carstens <heiko.carstens@de.ibm.com>
Subject: [PATCH] memory hotplug: fix early allocation handling
Message-ID: <20080520105145.GA24526@osiris.boeblingen.de.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
From: Heiko Carstens <heiko.carstens@de.ibm.com>
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Andy Whitcroft <apw@shadowen.org>, Dave Hansen <haveblue@us.ibm.com>, Gerald Schaefer <gerald.schaefer@de.ibm.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Yasunori Goto <y-goto@jp.fujitsu.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

Trying to add memory via add_memory() from within an initcall function
results in

bootmem alloc of 163840 bytes failed!
Kernel panic - not syncing: Out of memory

This is caused by zone_wait_table_init() which uses system_state to
decide if it should use the bootmem allocator or not.
When initcalls are handled the system_state is still SYSTEM_BOOTING
but the bootmem allocator doesn't work anymore. So the allocation
will fail.

To fix this use slab_is_available() instead as indicator like we do
it everywhere else.

Cc: Andy Whitcroft <apw@shadowen.org>
Cc: Dave Hansen <haveblue@us.ibm.com>
Cc: Gerald Schaefer <gerald.schaefer@de.ibm.com>
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Yasunori Goto <y-goto@jp.fujitsu.com>
Signed-off-by: Heiko Carstens <heiko.carstens@de.ibm.com>
---
 mm/page_alloc.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

Index: linux-2.6/mm/page_alloc.c
===================================================================
--- linux-2.6.orig/mm/page_alloc.c
+++ linux-2.6/mm/page_alloc.c
@@ -2804,7 +2804,7 @@ int zone_wait_table_init(struct zone *zo
 	alloc_size = zone->wait_table_hash_nr_entries
 					* sizeof(wait_queue_head_t);
 
- 	if (system_state == SYSTEM_BOOTING) {
+ 	if (!slab_is_available()) {
 		zone->wait_table = (wait_queue_head_t *)
 			alloc_bootmem_node(pgdat, alloc_size);
 	} else {

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
