Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx143.postini.com [74.125.245.143])
	by kanga.kvack.org (Postfix) with SMTP id B464C6B00C5
	for <linux-mm@kvack.org>; Tue, 30 Apr 2013 05:18:43 -0400 (EDT)
From: Tang Chen <tangchen@cn.fujitsu.com>
Subject: [PATCH v2 09/13] x86, numa, memblock: Introduce MEMBLK_LOCAL_NODE to mark and reserve node-life-cycle data.
Date: Tue, 30 Apr 2013 17:21:19 +0800
Message-Id: <1367313683-10267-10-git-send-email-tangchen@cn.fujitsu.com>
In-Reply-To: <1367313683-10267-1-git-send-email-tangchen@cn.fujitsu.com>
References: <1367313683-10267-1-git-send-email-tangchen@cn.fujitsu.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: mingo@redhat.com, hpa@zytor.com, akpm@linux-foundation.org, yinghai@kernel.org, jiang.liu@huawei.com, wency@cn.fujitsu.com, isimatu.yasuaki@jp.fujitsu.com, tj@kernel.org, laijs@cn.fujitsu.com, davem@davemloft.net, mgorman@suse.de, minchan@kernel.org, mina86@mina86.com
Cc: x86@kernel.org, linux-doc@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org

node-life-cycle data (whose life cycle is the same as a node)
allocated by memblock should be marked so that when we free usable
memory to buddy system, we can skip them.

This patch introduces a flag MEMBLK_LOCAL_NODE for memblock to reserve
node-life-cycle data. For now, it is only kernel direct mapping pagetable
pages, based on Yinghai's patch.

Signed-off-by: Tang Chen <tangchen@cn.fujitsu.com>
---
 arch/x86/mm/init.c       |   16 ++++++++++++----
 include/linux/memblock.h |    2 ++
 mm/memblock.c            |    7 +++++++
 3 files changed, 21 insertions(+), 4 deletions(-)

diff --git a/arch/x86/mm/init.c b/arch/x86/mm/init.c
index 8d0007a..002d487 100644
--- a/arch/x86/mm/init.c
+++ b/arch/x86/mm/init.c
@@ -62,14 +62,22 @@ __ref void *alloc_low_pages(unsigned int num)
 					low_min_pfn_mapped << PAGE_SHIFT,
 					low_max_pfn_mapped << PAGE_SHIFT,
 					PAGE_SIZE * num , PAGE_SIZE);
-		} else
+			if (!ret)
+				panic("alloc_low_page: can not alloc memory");
+
+			memblock_reserve(ret, PAGE_SIZE * num);
+		} else {
 			ret = memblock_find_in_range(
 					local_min_pfn_mapped << PAGE_SHIFT,
 					local_max_pfn_mapped << PAGE_SHIFT,
 					PAGE_SIZE * num , PAGE_SIZE);
-		if (!ret)
-			panic("alloc_low_page: can not alloc memory");
-		memblock_reserve(ret, PAGE_SIZE * num);
+			if (!ret)
+				panic("alloc_low_page: can not alloc memory");
+
+			memblock_reserve_local_node(ret, PAGE_SIZE * num,
+					memory_add_physaddr_to_nid(ret));
+		}
+
 		pfn = ret >> PAGE_SHIFT;
 	} else {
 		pfn = pgt_buf_end;
diff --git a/include/linux/memblock.h b/include/linux/memblock.h
index 5064eed..3b2d1c4 100644
--- a/include/linux/memblock.h
+++ b/include/linux/memblock.h
@@ -23,6 +23,7 @@
 
 /* Definition of memblock flags. */
 enum memblock_flags {
+	MEMBLK_LOCAL_NODE,	/* node-life-cycle data */
 	__NR_MEMBLK_FLAGS,	/* number of flags */
 };
 
@@ -65,6 +66,7 @@ int memblock_add(phys_addr_t base, phys_addr_t size);
 int memblock_remove(phys_addr_t base, phys_addr_t size);
 int memblock_free(phys_addr_t base, phys_addr_t size);
 int memblock_reserve(phys_addr_t base, phys_addr_t size);
+int memblock_reserve_local_node(phys_addr_t base, phys_addr_t size, int nid);
 void memblock_trim_memory(phys_addr_t align);
 void memblock_mark_kernel_nodes(void);
 
diff --git a/mm/memblock.c b/mm/memblock.c
index 1b93a5d..edde4c2 100644
--- a/mm/memblock.c
+++ b/mm/memblock.c
@@ -589,6 +589,13 @@ int __init_memblock memblock_reserve(phys_addr_t base, phys_addr_t size)
 				       MEMBLK_FLAGS_DEFAULT);
 }
 
+int __init_memblock memblock_reserve_local_node(phys_addr_t base,
+					phys_addr_t size, int nid)
+{
+	unsigned long flags = 1 << MEMBLK_LOCAL_NODE;
+	return memblock_reserve_region(base, size, nid, flags);
+}
+
 /**
  * __next_free_mem_range - next function for for_each_free_mem_range()
  * @idx: pointer to u64 loop variable
-- 
1.7.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
