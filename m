Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f72.google.com (mail-pg0-f72.google.com [74.125.83.72])
	by kanga.kvack.org (Postfix) with ESMTP id E075E6B0253
	for <linux-mm@kvack.org>; Fri, 20 Jan 2017 07:35:09 -0500 (EST)
Received: by mail-pg0-f72.google.com with SMTP id 14so93431223pgg.4
        for <linux-mm@kvack.org>; Fri, 20 Jan 2017 04:35:09 -0800 (PST)
Received: from mx0a-001b2d01.pphosted.com (mx0a-001b2d01.pphosted.com. [148.163.156.1])
        by mx.google.com with ESMTPS id b1si6741845pgn.86.2017.01.20.04.35.08
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 20 Jan 2017 04:35:08 -0800 (PST)
Received: from pps.filterd (m0098399.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.20/8.16.0.20) with SMTP id v0KCYRRJ078126
	for <linux-mm@kvack.org>; Fri, 20 Jan 2017 07:35:08 -0500
Received: from e06smtp07.uk.ibm.com (e06smtp07.uk.ibm.com [195.75.94.103])
	by mx0a-001b2d01.pphosted.com with ESMTP id 282y7bmp57-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Fri, 20 Jan 2017 07:35:08 -0500
Received: from localhost
	by e06smtp07.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <heiko.carstens@de.ibm.com>;
	Fri, 20 Jan 2017 12:35:04 -0000
From: Heiko Carstens <heiko.carstens@de.ibm.com>
Subject: [PATCH 3/3] memblock: embed memblock type name within struct memblock_type
Date: Fri, 20 Jan 2017 13:34:56 +0100
In-Reply-To: <20170120123456.46508-1-heiko.carstens@de.ibm.com>
References: <20170120123456.46508-1-heiko.carstens@de.ibm.com>
Message-Id: <20170120123456.46508-4-heiko.carstens@de.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org

Provide the name of each memblock type with struct memblock_type. This
allows to get rid of the function memblock_type_name() and duplicating
the type names in __memblock_dump_all().

The only memblock_type usage out of mm/memblock.c seems to be
arch/s390/kernel/crash_dump.c. While at it, give it a name.

Signed-off-by: Heiko Carstens <heiko.carstens@de.ibm.com>
---
 arch/s390/kernel/crash_dump.c |  1 +
 include/linux/memblock.h      |  1 +
 mm/memblock.c                 | 35 +++++++++++------------------------
 3 files changed, 13 insertions(+), 24 deletions(-)

diff --git a/arch/s390/kernel/crash_dump.c b/arch/s390/kernel/crash_dump.c
index f9293bfefb7f..9c9440dc253a 100644
--- a/arch/s390/kernel/crash_dump.c
+++ b/arch/s390/kernel/crash_dump.c
@@ -31,6 +31,7 @@ static struct memblock_type oldmem_type = {
 	.max = 1,
 	.total_size = 0,
 	.regions = &oldmem_region,
+	.name = "oldmem",
 };
 
 struct save_area {
diff --git a/include/linux/memblock.h b/include/linux/memblock.h
index 5b759c9acf97..8dee5ec80adf 100644
--- a/include/linux/memblock.h
+++ b/include/linux/memblock.h
@@ -42,6 +42,7 @@ struct memblock_type {
 	unsigned long max;	/* size of the allocated array */
 	phys_addr_t total_size;	/* size of all regions */
 	struct memblock_region *regions;
+	char *name;
 };
 
 struct memblock {
diff --git a/mm/memblock.c b/mm/memblock.c
index fbaaf713827c..82d21e598e8c 100644
--- a/mm/memblock.c
+++ b/mm/memblock.c
@@ -35,15 +35,18 @@ struct memblock memblock __initdata_memblock = {
 	.memory.regions		= memblock_memory_init_regions,
 	.memory.cnt		= 1,	/* empty dummy entry */
 	.memory.max		= INIT_MEMBLOCK_REGIONS,
+	.memory.name		= "memory",
 
 	.reserved.regions	= memblock_reserved_init_regions,
 	.reserved.cnt		= 1,	/* empty dummy entry */
 	.reserved.max		= INIT_MEMBLOCK_REGIONS,
+	.reserved.name		= "reserved",
 
 #ifdef CONFIG_HAVE_MEMBLOCK_PHYS_MAP
 	.physmem.regions	= memblock_physmem_init_regions,
 	.physmem.cnt		= 1,	/* empty dummy entry */
 	.physmem.max		= INIT_PHYSMEM_REGIONS,
+	.physmem.name		= "physmem",
 #endif
 
 	.bottom_up		= false,
@@ -64,22 +67,6 @@ ulong __init_memblock choose_memblock_flags(void)
 	return system_has_some_mirror ? MEMBLOCK_MIRROR : MEMBLOCK_NONE;
 }
 
-/* inline so we don't get a warning when pr_debug is compiled out */
-static __init_memblock const char *
-memblock_type_name(struct memblock_type *type)
-{
-	if (type == &memblock.memory)
-		return "memory";
-	else if (type == &memblock.reserved)
-		return "reserved";
-#ifdef CONFIG_HAVE_MEMBLOCK_PHYS_MAP
-	else if (type == &memblock.physmem)
-		return "physmem";
-#endif
-	else
-		return "unknown";
-}
-
 /* adjust *@size so that (@base + *@size) doesn't overflow, return new size */
 static inline phys_addr_t memblock_cap_size(phys_addr_t base, phys_addr_t *size)
 {
@@ -406,12 +393,12 @@ static int __init_memblock memblock_double_array(struct memblock_type *type,
 	}
 	if (!addr) {
 		pr_err("memblock: Failed to double %s array from %ld to %ld entries !\n",
-		       memblock_type_name(type), type->max, type->max * 2);
+		       type->name, type->max, type->max * 2);
 		return -1;
 	}
 
 	memblock_dbg("memblock: %s is doubled to %ld at [%#010llx-%#010llx]",
-			memblock_type_name(type), type->max * 2, (u64)addr,
+			type->name, type->max * 2, (u64)addr,
 			(u64)addr + new_size - 1);
 
 	/*
@@ -1675,14 +1662,14 @@ phys_addr_t __init_memblock memblock_get_current_limit(void)
 	return memblock.current_limit;
 }
 
-static void __init_memblock memblock_dump(struct memblock_type *type, char *name)
+static void __init_memblock memblock_dump(struct memblock_type *type)
 {
 	unsigned long long base, size;
 	unsigned long flags;
 	int idx;
 	struct memblock_region *rgn;
 
-	pr_info(" %s.cnt  = 0x%lx\n", name, type->cnt);
+	pr_info(" %s.cnt  = 0x%lx\n", type->name, type->cnt);
 
 	for_each_memblock_type(type, rgn) {
 		char nid_buf[32] = "";
@@ -1696,7 +1683,7 @@ static void __init_memblock memblock_dump(struct memblock_type *type, char *name
 				 memblock_get_region_node(rgn));
 #endif
 		pr_info(" %s[%#x]\t[%#016llx-%#016llx], %#llx bytes%s flags: %#lx\n",
-			name, idx, base, base + size - 1, size, nid_buf, flags);
+			type->name, idx, base, base + size - 1, size, nid_buf, flags);
 	}
 }
 
@@ -1707,10 +1694,10 @@ void __init_memblock __memblock_dump_all(void)
 		(unsigned long long)memblock.memory.total_size,
 		(unsigned long long)memblock.reserved.total_size);
 
-	memblock_dump(&memblock.memory, "memory");
-	memblock_dump(&memblock.reserved, "reserved");
+	memblock_dump(&memblock.memory);
+	memblock_dump(&memblock.reserved);
 #ifdef CONFIG_HAVE_MEMBLOCK_PHYS_MAP
-	memblock_dump(&memblock.physmem, "physmem");
+	memblock_dump(&memblock.physmem);
 #endif
 }
 
-- 
2.8.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
