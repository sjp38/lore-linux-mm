Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f45.google.com (mail-wg0-f45.google.com [74.125.82.45])
	by kanga.kvack.org (Postfix) with ESMTP id D677B6B01F7
	for <linux-mm@kvack.org>; Thu, 20 Mar 2014 08:34:10 -0400 (EDT)
Received: by mail-wg0-f45.google.com with SMTP id l18so545440wgh.4
        for <linux-mm@kvack.org>; Thu, 20 Mar 2014 05:34:10 -0700 (PDT)
Received: from e06smtp12.uk.ibm.com (e06smtp12.uk.ibm.com. [195.75.94.108])
        by mx.google.com with ESMTPS id cl10si1248412wjb.76.2014.03.20.05.34.09
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Thu, 20 Mar 2014 05:34:09 -0700 (PDT)
Received: from /spool/local
	by e06smtp12.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <schwidefsky@de.ibm.com>;
	Thu, 20 Mar 2014 12:34:08 -0000
Received: from b06cxnps3075.portsmouth.uk.ibm.com (d06relay10.portsmouth.uk.ibm.com [9.149.109.195])
	by d06dlp01.portsmouth.uk.ibm.com (Postfix) with ESMTP id 4A7F417D806D
	for <linux-mm@kvack.org>; Thu, 20 Mar 2014 12:34:49 +0000 (GMT)
Received: from d06av02.portsmouth.uk.ibm.com (d06av02.portsmouth.uk.ibm.com [9.149.37.228])
	by b06cxnps3075.portsmouth.uk.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id s2KCXsNi29556778
	for <linux-mm@kvack.org>; Thu, 20 Mar 2014 12:33:54 GMT
Received: from d06av02.portsmouth.uk.ibm.com (localhost [127.0.0.1])
	by d06av02.portsmouth.uk.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id s2KCY4gS032037
	for <linux-mm@kvack.org>; Thu, 20 Mar 2014 06:34:05 -0600
From: Martin Schwidefsky <schwidefsky@de.ibm.com>
Subject: [PATCH 2/3] mm/memblock: add physical memory list
Date: Thu, 20 Mar 2014 13:33:49 +0100
Message-Id: <1395318830-7435-3-git-send-email-schwidefsky@de.ibm.com>
In-Reply-To: <1395318830-7435-1-git-send-email-schwidefsky@de.ibm.com>
References: <1395318830-7435-1-git-send-email-schwidefsky@de.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org, tangchen@cn.fujitsu.com, zhangyanfei@cn.fujitsu.com, phacht@linux.vnet.ibm.com, yinghai@kernel.org, grygorii.strashko@ti.com
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Martin Schwidefsky <schwidefsky@de.ibm.com>

From: Philipp Hachtmann <phacht@linux.vnet.ibm.com>

Add the physmem list to the memblock structure. This list only exists
if HAVE_MEMBLOCK_PHYS_MAP is selected and contains the unmodified
list of physically available memory. It differs from the memblock
memory list as it always contains all memory ranges even if the
memory has been restricted, e.g. by use of the mem= kernel parameter.

Signed-off-by: Philipp Hachtmann <phacht@linux.vnet.ibm.com>
Signed-off-by: Martin Schwidefsky <schwidefsky@de.ibm.com>
---
 include/linux/memblock.h |    4 ++++
 mm/Kconfig               |    3 +++
 mm/memblock.c            |   12 ++++++++++++
 3 files changed, 19 insertions(+)

diff --git a/include/linux/memblock.h b/include/linux/memblock.h
index 9ddd0ef..f3fa617 100644
--- a/include/linux/memblock.h
+++ b/include/linux/memblock.h
@@ -18,6 +18,7 @@
 #include <linux/mm.h>
 
 #define INIT_MEMBLOCK_REGIONS	128
+#define INIT_PHYSMEM_REGIONS	4
 
 /* Definition of memblock flags. */
 #define MEMBLOCK_HOTPLUG	0x1	/* hotpluggable region */
@@ -43,6 +44,9 @@ struct memblock {
 	phys_addr_t current_limit;
 	struct memblock_type memory;
 	struct memblock_type reserved;
+#ifdef CONFIG_HAVE_MEMBLOCK_PHYS_MAP
+	struct memblock_type physmem;
+#endif
 };
 
 extern struct memblock memblock;
diff --git a/mm/Kconfig b/mm/Kconfig
index 2888024..1b2b4e7 100644
--- a/mm/Kconfig
+++ b/mm/Kconfig
@@ -134,6 +134,9 @@ config HAVE_MEMBLOCK
 config HAVE_MEMBLOCK_NODE_MAP
 	boolean
 
+config HAVE_MEMBLOCK_PHYS_MAP
+	boolean
+
 config ARCH_DISCARD_MEMBLOCK
 	boolean
 
diff --git a/mm/memblock.c b/mm/memblock.c
index f2e9aa0..d73b06b 100644
--- a/mm/memblock.c
+++ b/mm/memblock.c
@@ -27,6 +27,9 @@
 
 static struct memblock_region memblock_memory_init_regions[INIT_MEMBLOCK_REGIONS] __initdata_memblock;
 static struct memblock_region memblock_reserved_init_regions[INIT_MEMBLOCK_REGIONS] __initdata_memblock;
+#ifdef CONFIG_HAVE_MEMBLOCK_PHYS_MAP
+static struct memblock_region memblock_physmem_init_regions[INIT_PHYSMEM_REGIONS] __initdata_memblock;
+#endif
 
 struct memblock memblock __initdata_memblock = {
 	.memory.regions		= memblock_memory_init_regions,
@@ -37,6 +40,12 @@ struct memblock memblock __initdata_memblock = {
 	.reserved.cnt		= 1,	/* empty dummy entry */
 	.reserved.max		= INIT_MEMBLOCK_REGIONS,
 
+#ifdef CONFIG_HAVE_MEMBLOCK_PHYS_MAP
+	.physmem.regions	= memblock_physmem_init_regions,
+	.physmem.cnt		= 1,	/* empty dummy entry */
+	.physmem.max		= INIT_PHYSMEM_REGIONS,
+#endif
+
 	.bottom_up		= false,
 	.current_limit		= MEMBLOCK_ALLOC_ANYWHERE,
 };
@@ -1550,6 +1559,9 @@ static int __init memblock_init_debugfs(void)
 		return -ENXIO;
 	debugfs_create_file("memory", S_IRUGO, root, &memblock.memory, &memblock_debug_fops);
 	debugfs_create_file("reserved", S_IRUGO, root, &memblock.reserved, &memblock_debug_fops);
+#ifdef CONFIG_HAVE_MEMBLOCK_PHYS_MAP
+	debugfs_create_file("physmem", S_IRUGO, root, &memblock.physmem, &memblock_debug_fops);
+#endif
 
 	return 0;
 }
-- 
1.7.9.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
