Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ea0-f169.google.com (mail-ea0-f169.google.com [209.85.215.169])
	by kanga.kvack.org (Postfix) with ESMTP id D29A46B0037
	for <linux-mm@kvack.org>; Mon, 20 Jan 2014 06:33:05 -0500 (EST)
Received: by mail-ea0-f169.google.com with SMTP id l9so2655754eaj.0
        for <linux-mm@kvack.org>; Mon, 20 Jan 2014 03:33:05 -0800 (PST)
Received: from e06smtp12.uk.ibm.com (e06smtp12.uk.ibm.com. [195.75.94.108])
        by mx.google.com with ESMTPS id g47si1833741eet.45.2014.01.20.03.33.04
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Mon, 20 Jan 2014 03:33:05 -0800 (PST)
Received: from /spool/local
	by e06smtp12.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <phacht@linux.vnet.ibm.com>;
	Mon, 20 Jan 2014 11:33:03 -0000
Received: from b06cxnps4074.portsmouth.uk.ibm.com (d06relay11.portsmouth.uk.ibm.com [9.149.109.196])
	by d06dlp01.portsmouth.uk.ibm.com (Postfix) with ESMTP id 3A69717D8062
	for <linux-mm@kvack.org>; Mon, 20 Jan 2014 11:33:16 +0000 (GMT)
Received: from d06av03.portsmouth.uk.ibm.com (d06av03.portsmouth.uk.ibm.com [9.149.37.213])
	by b06cxnps4074.portsmouth.uk.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id s0KBWmVF54984748
	for <linux-mm@kvack.org>; Mon, 20 Jan 2014 11:32:48 GMT
Received: from d06av03.portsmouth.uk.ibm.com (localhost [127.0.0.1])
	by d06av03.portsmouth.uk.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id s0KBWtDq018436
	for <linux-mm@kvack.org>; Mon, 20 Jan 2014 04:33:00 -0700
From: Philipp Hachtmann <phacht@linux.vnet.ibm.com>
Subject: [PATCH V5 1/3] mm/nobootmem: Fix unused variable
Date: Mon, 20 Jan 2014 12:32:37 +0100
Message-Id: <1390217559-14691-2-git-send-email-phacht@linux.vnet.ibm.com>
In-Reply-To: <1390217559-14691-1-git-send-email-phacht@linux.vnet.ibm.com>
References: <1390217559-14691-1-git-send-email-phacht@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org
Cc: hannes@cmpxchg.org, liuj97@gmail.com, santosh.shilimkar@ti.com, grygorii.strashko@ti.com, iamjoonsoo.kim@lge.com, robin.m.holt@gmail.com, tangchen@cn.fujitsu.com, yinghai@kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Philipp Hachtmann <phacht@linux.vnet.ibm.com>

This fixes an unused variable warning in nobootmem.c

Signed-off-by: Philipp Hachtmann <phacht@linux.vnet.ibm.com>
---
 mm/nobootmem.c | 28 +++++++++++++++++-----------
 1 file changed, 17 insertions(+), 11 deletions(-)

diff --git a/mm/nobootmem.c b/mm/nobootmem.c
index e2906a5..0215c77 100644
--- a/mm/nobootmem.c
+++ b/mm/nobootmem.c
@@ -116,23 +116,29 @@ static unsigned long __init __free_memory_core(phys_addr_t start,
 static unsigned long __init free_low_memory_core_early(void)
 {
 	unsigned long count = 0;
-	phys_addr_t start, end, size;
+	phys_addr_t start, end;
 	u64 i;
 
+#ifdef CONFIG_ARCH_DISCARD_MEMBLOCK
+	phys_addr_t size;
+#endif
+
 	for_each_free_mem_range(i, NUMA_NO_NODE, &start, &end, NULL)
 		count += __free_memory_core(start, end);
 
 #ifdef CONFIG_ARCH_DISCARD_MEMBLOCK
-
-	/* Free memblock.reserved array if it was allocated */
-	size = get_allocated_memblock_reserved_regions_info(&start);
-	if (size)
-		count += __free_memory_core(start, start + size);
-
-	/* Free memblock.memory array if it was allocated */
-	size = get_allocated_memblock_memory_regions_info(&start);
-	if (size)
-		count += __free_memory_core(start, start + size);
+	{
+		phys_addr_t size;
+		/* Free memblock.reserved array if it was allocated */
+		size = get_allocated_memblock_reserved_regions_info(&start);
+		if (size)
+			count += __free_memory_core(start, start + size);
+		
+		/* Free memblock.memory array if it was allocated */
+		size = get_allocated_memblock_memory_regions_info(&start);
+		if (size)
+			count += __free_memory_core(start, start + size);
+	}
 #endif
 
 	return count;
-- 
1.8.4.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
