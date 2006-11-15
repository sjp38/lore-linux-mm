Received: from d06nrmr1407.portsmouth.uk.ibm.com (d06nrmr1407.portsmouth.uk.ibm.com [9.149.38.185])
	by mtagate4.uk.ibm.com (8.13.8/8.13.8) with ESMTP id kAFIbQQw090150
	for <linux-mm@kvack.org>; Wed, 15 Nov 2006 18:37:26 GMT
Received: from d06av04.portsmouth.uk.ibm.com (d06av04.portsmouth.uk.ibm.com [9.149.37.216])
	by d06nrmr1407.portsmouth.uk.ibm.com (8.13.6/8.13.6/NCO v8.1.1) with ESMTP id kAFIeDee1888294
	for <linux-mm@kvack.org>; Wed, 15 Nov 2006 18:40:13 GMT
Received: from d06av04.portsmouth.uk.ibm.com (loopback [127.0.0.1])
	by d06av04.portsmouth.uk.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id kAFIbPZl022942
	for <linux-mm@kvack.org>; Wed, 15 Nov 2006 18:37:25 GMT
Date: Wed, 15 Nov 2006 19:34:37 +0100
From: Christian Krafft <krafft@de.ibm.com>
Subject: [patch 2/2] enables booting a NUMA system where some nodes have no
 memory
Message-ID: <20061115193437.25cdc371@localhost>
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

When booting a NUMA system with nodes that have no memory (eg by limiting memory),
bootmem_alloc_core tried to find pages in an uninitialized bootmem_map.
This caused a null pointer access.
This fix adds a check, so that NULL is returned.
That will enable the caller (bootmem_alloc_nopanic)
to alloc memory on other without a panic.

Signed-off-by: Christian Krafft <krafft@de.ibm.com>

Index: linux/mm/bootmem.c
===================================================================
--- linux.orig/mm/bootmem.c
+++ linux/mm/bootmem.c
@@ -196,6 +196,10 @@ __alloc_bootmem_core(struct bootmem_data
 	if (limit && bdata->node_boot_start >= limit)
 		return NULL;
 
+	/* on nodes without memory - bootmem_map is NULL */
+	if(!bdata->node_bootmem_map)
+		return NULL;
+
 	end_pfn = bdata->node_low_pfn;
 	limit = PFN_DOWN(limit);
 	if (limit && end_pfn > limit)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
