Received: from d06nrmr1407.portsmouth.uk.ibm.com (d06nrmr1407.portsmouth.uk.ibm.com [9.149.38.185])
	by mtagate3.uk.ibm.com (8.13.8/8.13.8) with ESMTP id kAFIZQAO159236
	for <linux-mm@kvack.org>; Wed, 15 Nov 2006 18:35:26 GMT
Received: from d06av01.portsmouth.uk.ibm.com (d06av01.portsmouth.uk.ibm.com [9.149.37.212])
	by d06nrmr1407.portsmouth.uk.ibm.com (8.13.6/8.13.6/NCO v8.1.1) with ESMTP id kAFIcD9C2519042
	for <linux-mm@kvack.org>; Wed, 15 Nov 2006 18:38:13 GMT
Received: from d06av01.portsmouth.uk.ibm.com (loopback [127.0.0.1])
	by d06av01.portsmouth.uk.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id kAFIZQOV016606
	for <linux-mm@kvack.org>; Wed, 15 Nov 2006 18:35:26 GMT
Date: Wed, 15 Nov 2006 19:32:38 +0100
From: Christian Krafft <krafft@de.ibm.com>
Subject: [patch 1/2] fix call to alloc_bootmem after bootmem has been freed
Message-ID: <20061115193238.4d23900c@localhost>
In-Reply-To: <20061115193049.3457b44c@localhost>
References: <20061115193049.3457b44c@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christian Krafft <krafft@de.ibm.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

In some cases it might happen, that alloc_bootmem is beeing called
after bootmem pages have been freed. This is, because the condition
SYSTEM_BOOTING is still true after bootmem has been freed.

Signed-off-by: Christian Krafft <krafft@de.ibm.com>

Index: linux/mm/page_alloc.c
===================================================================
--- linux.orig/mm/page_alloc.c
+++ linux/mm/page_alloc.c
@@ -1931,7 +1931,7 @@ int zone_wait_table_init(struct zone *zo
 	alloc_size = zone->wait_table_hash_nr_entries
 					* sizeof(wait_queue_head_t);
 
- 	if (system_state == SYSTEM_BOOTING) {
+	if (!slab_is_available()) {
 		zone->wait_table = (wait_queue_head_t *)
 			alloc_bootmem_node(pgdat, alloc_size);
 	} else {

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
