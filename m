Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ea0-f169.google.com (mail-ea0-f169.google.com [209.85.215.169])
	by kanga.kvack.org (Postfix) with ESMTP id DB6A76B003D
	for <linux-mm@kvack.org>; Tue,  7 Jan 2014 10:17:06 -0500 (EST)
Received: by mail-ea0-f169.google.com with SMTP id l9so229188eaj.28
        for <linux-mm@kvack.org>; Tue, 07 Jan 2014 07:17:06 -0800 (PST)
Received: from e06smtp12.uk.ibm.com (e06smtp12.uk.ibm.com. [195.75.94.108])
        by mx.google.com with ESMTPS id i1si89270578eev.68.2014.01.07.07.17.05
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Tue, 07 Jan 2014 07:17:06 -0800 (PST)
Received: from /spool/local
	by e06smtp12.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <phacht@linux.vnet.ibm.com>;
	Tue, 7 Jan 2014 15:17:05 -0000
Received: from b06cxnps3075.portsmouth.uk.ibm.com (d06relay10.portsmouth.uk.ibm.com [9.149.109.195])
	by d06dlp01.portsmouth.uk.ibm.com (Postfix) with ESMTP id 41B9817D8059
	for <linux-mm@kvack.org>; Tue,  7 Jan 2014 15:17:11 +0000 (GMT)
Received: from d06av09.portsmouth.uk.ibm.com (d06av09.portsmouth.uk.ibm.com [9.149.37.250])
	by b06cxnps3075.portsmouth.uk.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id s07FGoje65536142
	for <linux-mm@kvack.org>; Tue, 7 Jan 2014 15:16:50 GMT
Received: from d06av09.portsmouth.uk.ibm.com (localhost [127.0.0.1])
	by d06av09.portsmouth.uk.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id s07FH1o3020248
	for <linux-mm@kvack.org>; Tue, 7 Jan 2014 08:17:02 -0700
From: Philipp Hachtmann <phacht@linux.vnet.ibm.com>
Subject: [PATCH 2/2] mm: free memblock.memory in free_all_bootmem
Date: Tue,  7 Jan 2014 16:16:14 +0100
Message-Id: <1389107774-54978-3-git-send-email-phacht@linux.vnet.ibm.com>
In-Reply-To: <1389107774-54978-1-git-send-email-phacht@linux.vnet.ibm.com>
References: <1389107774-54978-1-git-send-email-phacht@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org, jiang.liu@huawei.com
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, iamjoonsoo.kim@lge.com, hannes@cmpxchg.org, tangchen@cn.fujitsu.com, tj@kernel.org, toshi.kani@hp.com, Philipp Hachtmann <phacht@linux.vnet.ibm.com>

When calling free_all_bootmem() the free areas under memblock's
control are released to the buddy allocator. Additionally the
reserved list is freed if it was reallocated by memblock.
The same should apply for the memory list.

Signed-off-by: Philipp Hachtmann <phacht@linux.vnet.ibm.com>
---
 include/linux/memblock.h |  1 +
 mm/memblock.c            | 12 ++++++++++++
 mm/nobootmem.c           |  7 ++++++-
 3 files changed, 19 insertions(+), 1 deletion(-)

diff --git a/include/linux/memblock.h b/include/linux/memblock.h
index 77c60e5..d174922 100644
--- a/include/linux/memblock.h
+++ b/include/linux/memblock.h
@@ -52,6 +52,7 @@ phys_addr_t memblock_find_in_range_node(phys_addr_t start, phys_addr_t end,
 phys_addr_t memblock_find_in_range(phys_addr_t start, phys_addr_t end,
 				   phys_addr_t size, phys_addr_t align);
 phys_addr_t get_allocated_memblock_reserved_regions_info(phys_addr_t *addr);
+phys_addr_t get_allocated_memblock_memory_regions_info(phys_addr_t *addr);
 void memblock_allow_resize(void);
 int memblock_add_node(phys_addr_t base, phys_addr_t size, int nid);
 int memblock_add(phys_addr_t base, phys_addr_t size);
diff --git a/mm/memblock.c b/mm/memblock.c
index 53e477b..1a11d04 100644
--- a/mm/memblock.c
+++ b/mm/memblock.c
@@ -271,6 +271,18 @@ phys_addr_t __init_memblock get_allocated_memblock_reserved_regions_info(
 			  memblock.reserved.max);
 }
 
+phys_addr_t __init_memblock get_allocated_memblock_memory_regions_info(
+					phys_addr_t *addr)
+{
+	if (memblock.memory.regions == memblock_memory_init_regions)
+		return 0;
+
+	*addr = __pa(memblock.memory.regions);
+
+	return PAGE_ALIGN(sizeof(struct memblock_region) *
+			  memblock.memory.max);
+}
+
 /**
  * memblock_double_array - double the size of the memblock regions array
  * @type: memblock type of the regions array being doubled
diff --git a/mm/nobootmem.c b/mm/nobootmem.c
index 3a7e14d..83f36d3 100644
--- a/mm/nobootmem.c
+++ b/mm/nobootmem.c
@@ -122,11 +122,16 @@ static unsigned long __init free_low_memory_core_early(void)
 	for_each_free_mem_range(i, MAX_NUMNODES, &start, &end, NULL)
 		count += __free_memory_core(start, end);
 
-	/* free range that is used for reserved array if we allocate it */
+	/* Free memblock.reserved array if it was allocated */
 	size = get_allocated_memblock_reserved_regions_info(&start);
 	if (size)
 		count += __free_memory_core(start, start + size);
 
+	/* Free memblock.memory array if it was allocated */
+	size = get_allocated_memblock_memory_regions_info(&start);
+	if (size)
+		count += __free_memory_core(start, start + size);
+
 	return count;
 }
 
-- 
1.8.4.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
