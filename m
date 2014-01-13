Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ea0-f174.google.com (mail-ea0-f174.google.com [209.85.215.174])
	by kanga.kvack.org (Postfix) with ESMTP id 2486D6B0036
	for <linux-mm@kvack.org>; Mon, 13 Jan 2014 07:49:10 -0500 (EST)
Received: by mail-ea0-f174.google.com with SMTP id b10so3290384eae.33
        for <linux-mm@kvack.org>; Mon, 13 Jan 2014 04:49:09 -0800 (PST)
Received: from e06smtp14.uk.ibm.com (e06smtp14.uk.ibm.com. [195.75.94.110])
        by mx.google.com with ESMTPS id p9si28540179eew.97.2014.01.13.04.49.09
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Mon, 13 Jan 2014 04:49:09 -0800 (PST)
Received: from /spool/local
	by e06smtp14.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <phacht@linux.vnet.ibm.com>;
	Mon, 13 Jan 2014 12:49:08 -0000
Received: from b06cxnps4075.portsmouth.uk.ibm.com (d06relay12.portsmouth.uk.ibm.com [9.149.109.197])
	by d06dlp03.portsmouth.uk.ibm.com (Postfix) with ESMTP id 069211B0806B
	for <linux-mm@kvack.org>; Mon, 13 Jan 2014 12:48:27 +0000 (GMT)
Received: from d06av06.portsmouth.uk.ibm.com (d06av06.portsmouth.uk.ibm.com [9.149.37.217])
	by b06cxnps4075.portsmouth.uk.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id s0DCmrva66715756
	for <linux-mm@kvack.org>; Mon, 13 Jan 2014 12:48:53 GMT
Received: from d06av06.portsmouth.uk.ibm.com (localhost [127.0.0.1])
	by d06av06.portsmouth.uk.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id s0DCn4t6015426
	for <linux-mm@kvack.org>; Mon, 13 Jan 2014 05:49:05 -0700
From: Philipp Hachtmann <phacht@linux.vnet.ibm.com>
Subject: [PATCH V2 1/2] mm/nobootmem: free_all_bootmem again
Date: Mon, 13 Jan 2014 13:49:00 +0100
Message-Id: <1389617341-568-2-git-send-email-phacht@linux.vnet.ibm.com>
In-Reply-To: <1389617341-568-1-git-send-email-phacht@linux.vnet.ibm.com>
References: <1389617341-568-1-git-send-email-phacht@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org, linux-kernel@vger.kernel.org
Cc: linux-mm@kvack.org, qiuxishi@huawei.com, dhowells@redhat.com, daeseok.youn@gmail.com, liuj97@gmail.com, yinghai@kernel.org, phacht@linux.vnet.ibm.com, zhangyanfei@cn.fujitsu.com, santosh.shilimkar@ti.com, grygorii.strashko@ti.com, tangchen@cn.fujitsu.com

get_allocated_memblock_reserved_regions_info() should work if it is
compiled in. Extended the ifdef around
get_allocated_memblock_memory_regions_info() to include
get_allocated_memblock_reserved_regions_info() as well.
Similar changes in nobootmem.c/free_low_memory_core_early() where
the two functions are called.

Signed-off-by: Philipp Hachtmann <phacht@linux.vnet.ibm.com>
---
 mm/memblock.c  | 17 ++---------------
 mm/nobootmem.c |  4 ++--
 2 files changed, 4 insertions(+), 17 deletions(-)

diff --git a/mm/memblock.c b/mm/memblock.c
index 64ed243..9c0aeef 100644
--- a/mm/memblock.c
+++ b/mm/memblock.c
@@ -266,33 +266,20 @@ static void __init_memblock memblock_remove_region(struct memblock_type *type, u
 	}
 }
 
+#ifdef CONFIG_ARCH_DISCARD_MEMBLOCK
+
 phys_addr_t __init_memblock get_allocated_memblock_reserved_regions_info(
 					phys_addr_t *addr)
 {
 	if (memblock.reserved.regions == memblock_reserved_init_regions)
 		return 0;
 
-	/*
-	 * Don't allow nobootmem allocator to free reserved memory regions
-	 * array if
-	 *  - CONFIG_DEBUG_FS is enabled;
-	 *  - CONFIG_ARCH_DISCARD_MEMBLOCK is not enabled;
-	 *  - reserved memory regions array have been resized during boot.
-	 * Otherwise debug_fs entry "sys/kernel/debug/memblock/reserved"
-	 * will show garbage instead of state of memory reservations.
-	 */
-	if (IS_ENABLED(CONFIG_DEBUG_FS) &&
-	    !IS_ENABLED(CONFIG_ARCH_DISCARD_MEMBLOCK))
-		return 0;
-
 	*addr = __pa(memblock.reserved.regions);
 
 	return PAGE_ALIGN(sizeof(struct memblock_region) *
 			  memblock.reserved.max);
 }
 
-#ifdef CONFIG_ARCH_DISCARD_MEMBLOCK
-
 phys_addr_t __init_memblock get_allocated_memblock_memory_regions_info(
 					phys_addr_t *addr)
 {
diff --git a/mm/nobootmem.c b/mm/nobootmem.c
index 17c8902..e2906a5 100644
--- a/mm/nobootmem.c
+++ b/mm/nobootmem.c
@@ -122,13 +122,13 @@ static unsigned long __init free_low_memory_core_early(void)
 	for_each_free_mem_range(i, NUMA_NO_NODE, &start, &end, NULL)
 		count += __free_memory_core(start, end);
 
+#ifdef CONFIG_ARCH_DISCARD_MEMBLOCK
+
 	/* Free memblock.reserved array if it was allocated */
 	size = get_allocated_memblock_reserved_regions_info(&start);
 	if (size)
 		count += __free_memory_core(start, start + size);
 
-#ifdef CONFIG_ARCH_DISCARD_MEMBLOCK
-
 	/* Free memblock.memory array if it was allocated */
 	size = get_allocated_memblock_memory_regions_info(&start);
 	if (size)
-- 
1.8.4.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
