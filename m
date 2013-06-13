Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx106.postini.com [74.125.245.106])
	by kanga.kvack.org (Postfix) with SMTP id 541D2900010
	for <linux-mm@kvack.org>; Thu, 13 Jun 2013 09:28:07 -0400 (EDT)
From: Tang Chen <tangchen@cn.fujitsu.com>
Subject: [Part2 PATCH v4 06/15] memblock, numa: Introduce flag into memblock.
Date: Thu, 13 Jun 2013 21:03:30 +0800
Message-Id: <1371128619-8987-7-git-send-email-tangchen@cn.fujitsu.com>
In-Reply-To: <1371128619-8987-1-git-send-email-tangchen@cn.fujitsu.com>
References: <1371128619-8987-1-git-send-email-tangchen@cn.fujitsu.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: tglx@linutronix.de, mingo@elte.hu, hpa@zytor.com, akpm@linux-foundation.org, tj@kernel.org, trenn@suse.de, yinghai@kernel.org, jiang.liu@huawei.com, wency@cn.fujitsu.com, laijs@cn.fujitsu.com, isimatu.yasuaki@jp.fujitsu.com, mgorman@suse.de, minchan@kernel.org, mina86@mina86.com, gong.chen@linux.intel.com, vasilis.liaskovitis@profitbricks.com, lwoodman@redhat.com, riel@redhat.com, jweiner@redhat.com, prarit@redhat.com
Cc: x86@kernel.org, linux-doc@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org

There is no flag in memblock to describe what type the memory is.
Sometimes, we may use memblock to reserve some memory for special usage.
For example, as Yinghai did in his patch, allocate pagetables on local
node before all the memory on the node is mapped.
Please refer to Yinghai's patch:
v1: https://lkml.org/lkml/2013/3/7/642
v2: https://lkml.org/lkml/2013/3/10/47
v3: https://lkml.org/lkml/2013/4/4/639
v4: https://lkml.org/lkml/2013/4/11/829

In hotplug environment, there could be some problems when we hot-remove
memory if we do so. Pagetable pages are kernel memory, which we cannot
migrate. But we can put them in local node because their life-cycle is
the same as the node.  So we need to free them all before memory hot-removing.

Actually, data whose life cycle is the same as a node, such as pagetable
pages, vmemmap pages, page_cgroup pages, all could be put on local node.
They can be freed when we hot-removing a whole node.

In order to do so, we need to mark out these special pages in memblock.
In this patch, we introduce a new "flags" member into memblock_region:
   struct memblock_region {
           phys_addr_t base;
           phys_addr_t size;
           unsigned long flags;
   #ifdef CONFIG_HAVE_MEMBLOCK_NODE_MAP
           int nid;
   #endif
   };

This patch does the following things:
1) Add "flags" member to memblock_region, and MEMBLK_DEFAULT flag for common usage.
2) Modify the following APIs' prototype:
	memblock_add_region()
	memblock_insert_region()
3) Add memblock_reserve_region() to support reserve memory with flags, and keep
   memblock_reserve()'s prototype unmodified.
4) Modify other APIs to support flags, but keep their prototype unmodified.

The idea is from Wen Congyang <wency@cn.fujitsu.com> and Liu Jiang <jiang.liu@huawei.com>.

v3 -> v4: Define the flags with macro directly instead of bit shift.

Suggested-by: Wen Congyang <wency@cn.fujitsu.com>
Suggested-by: Liu Jiang <jiang.liu@huawei.com>
Signed-off-by: Tang Chen <tangchen@cn.fujitsu.com>
---
 include/linux/memblock.h |    4 +++
 mm/memblock.c            |   55 +++++++++++++++++++++++++++++++++------------
 2 files changed, 44 insertions(+), 15 deletions(-)

diff --git a/include/linux/memblock.h b/include/linux/memblock.h
index f388203..93f3453 100644
--- a/include/linux/memblock.h
+++ b/include/linux/memblock.h
@@ -19,9 +19,13 @@
 
 #define INIT_MEMBLOCK_REGIONS	128
 
+/* Definition of memblock flags. */
+#define MEMBLK_FLAGS_DEFAULT	0x0	/* default flag */
+
 struct memblock_region {
 	phys_addr_t base;
 	phys_addr_t size;
+	unsigned long flags;
 #ifdef CONFIG_HAVE_MEMBLOCK_NODE_MAP
 	int nid;
 #endif
diff --git a/mm/memblock.c b/mm/memblock.c
index c5fad93..9e871e9 100644
--- a/mm/memblock.c
+++ b/mm/memblock.c
@@ -157,6 +157,7 @@ static void __init_memblock memblock_remove_region(struct memblock_type *type, u
 		type->cnt = 1;
 		type->regions[0].base = 0;
 		type->regions[0].size = 0;
+		type->regions[0].flags = 0;
 		memblock_set_region_node(&type->regions[0], MAX_NUMNODES);
 	}
 }
@@ -307,7 +308,8 @@ static void __init_memblock memblock_merge_regions(struct memblock_type *type)
 
 		if (this->base + this->size != next->base ||
 		    memblock_get_region_node(this) !=
-		    memblock_get_region_node(next)) {
+		    memblock_get_region_node(next) ||
+		    this->flags != next->flags) {
 			BUG_ON(this->base + this->size > next->base);
 			i++;
 			continue;
@@ -327,13 +329,15 @@ static void __init_memblock memblock_merge_regions(struct memblock_type *type)
  * @base:	base address of the new region
  * @size:	size of the new region
  * @nid:	node id of the new region
+ * @flags:	flags of the new region
  *
  * Insert new memblock region [@base,@base+@size) into @type at @idx.
  * @type must already have extra room to accomodate the new region.
  */
 static void __init_memblock memblock_insert_region(struct memblock_type *type,
 						   int idx, phys_addr_t base,
-						   phys_addr_t size, int nid)
+						   phys_addr_t size,
+						   int nid, unsigned long flags)
 {
 	struct memblock_region *rgn = &type->regions[idx];
 
@@ -341,6 +345,7 @@ static void __init_memblock memblock_insert_region(struct memblock_type *type,
 	memmove(rgn + 1, rgn, (type->cnt - idx) * sizeof(*rgn));
 	rgn->base = base;
 	rgn->size = size;
+	rgn->flags = flags;
 	memblock_set_region_node(rgn, nid);
 	type->cnt++;
 	type->total_size += size;
@@ -352,6 +357,7 @@ static void __init_memblock memblock_insert_region(struct memblock_type *type,
  * @base: base address of the new region
  * @size: size of the new region
  * @nid: nid of the new region
+ * @flags: flags of the new region
  *
  * Add new memblock region [@base,@base+@size) into @type.  The new region
  * is allowed to overlap with existing ones - overlaps don't affect already
@@ -362,7 +368,8 @@ static void __init_memblock memblock_insert_region(struct memblock_type *type,
  * 0 on success, -errno on failure.
  */
 static int __init_memblock memblock_add_region(struct memblock_type *type,
-				phys_addr_t base, phys_addr_t size, int nid)
+				phys_addr_t base, phys_addr_t size,
+				int nid, unsigned long flags)
 {
 	bool insert = false;
 	phys_addr_t obase = base;
@@ -377,6 +384,7 @@ static int __init_memblock memblock_add_region(struct memblock_type *type,
 		WARN_ON(type->cnt != 1 || type->total_size);
 		type->regions[0].base = base;
 		type->regions[0].size = size;
+		type->regions[0].flags = flags;
 		memblock_set_region_node(&type->regions[0], nid);
 		type->total_size = size;
 		return 0;
@@ -407,7 +415,8 @@ repeat:
 			nr_new++;
 			if (insert)
 				memblock_insert_region(type, i++, base,
-						       rbase - base, nid);
+						       rbase - base, nid,
+						       flags);
 		}
 		/* area below @rend is dealt with, forget about it */
 		base = min(rend, end);
@@ -417,7 +426,8 @@ repeat:
 	if (base < end) {
 		nr_new++;
 		if (insert)
-			memblock_insert_region(type, i, base, end - base, nid);
+			memblock_insert_region(type, i, base, end - base,
+					       nid, flags);
 	}
 
 	/*
@@ -439,12 +449,14 @@ repeat:
 int __init_memblock memblock_add_node(phys_addr_t base, phys_addr_t size,
 				       int nid)
 {
-	return memblock_add_region(&memblock.memory, base, size, nid);
+	return memblock_add_region(&memblock.memory, base, size,
+				   nid, MEMBLK_FLAGS_DEFAULT);
 }
 
 int __init_memblock memblock_add(phys_addr_t base, phys_addr_t size)
 {
-	return memblock_add_region(&memblock.memory, base, size, MAX_NUMNODES);
+	return memblock_add_region(&memblock.memory, base, size,
+				   MAX_NUMNODES, MEMBLK_FLAGS_DEFAULT);
 }
 
 /**
@@ -499,7 +511,8 @@ static int __init_memblock memblock_isolate_range(struct memblock_type *type,
 			rgn->size -= base - rbase;
 			type->total_size -= base - rbase;
 			memblock_insert_region(type, i, rbase, base - rbase,
-					       memblock_get_region_node(rgn));
+					       memblock_get_region_node(rgn),
+					       rgn->flags);
 		} else if (rend > end) {
 			/*
 			 * @rgn intersects from above.  Split and redo the
@@ -509,7 +522,8 @@ static int __init_memblock memblock_isolate_range(struct memblock_type *type,
 			rgn->size -= end - rbase;
 			type->total_size -= end - rbase;
 			memblock_insert_region(type, i--, rbase, end - rbase,
-					       memblock_get_region_node(rgn));
+					       memblock_get_region_node(rgn),
+					       rgn->flags);
 		} else {
 			/* @rgn is fully contained, record it */
 			if (!*end_rgn)
@@ -551,16 +565,25 @@ int __init_memblock memblock_free(phys_addr_t base, phys_addr_t size)
 	return __memblock_remove(&memblock.reserved, base, size);
 }
 
-int __init_memblock memblock_reserve(phys_addr_t base, phys_addr_t size)
+static int __init_memblock memblock_reserve_region(phys_addr_t base,
+						   phys_addr_t size,
+						   int nid,
+						   unsigned long flags)
 {
 	struct memblock_type *_rgn = &memblock.reserved;
 
-	memblock_dbg("memblock_reserve: [%#016llx-%#016llx] %pF\n",
+	memblock_dbg("memblock_reserve: [%#016llx-%#016llx] with flags %#016lx %pF\n",
 		     (unsigned long long)base,
 		     (unsigned long long)base + size,
-		     (void *)_RET_IP_);
+		     flags, (void *)_RET_IP_);
+
+	return memblock_add_region(_rgn, base, size, nid, flags);
+}
 
-	return memblock_add_region(_rgn, base, size, MAX_NUMNODES);
+int __init_memblock memblock_reserve(phys_addr_t base, phys_addr_t size)
+{
+	return memblock_reserve_region(base, size, MAX_NUMNODES,
+				       MEMBLK_FLAGS_DEFAULT);
 }
 
 /**
@@ -985,6 +1008,7 @@ void __init_memblock memblock_set_current_limit(phys_addr_t limit)
 static void __init_memblock memblock_dump(struct memblock_type *type, char *name)
 {
 	unsigned long long base, size;
+	unsigned long flags;
 	int i;
 
 	pr_info(" %s.cnt  = 0x%lx\n", name, type->cnt);
@@ -995,13 +1019,14 @@ static void __init_memblock memblock_dump(struct memblock_type *type, char *name
 
 		base = rgn->base;
 		size = rgn->size;
+		flags = rgn->flags;
 #ifdef CONFIG_HAVE_MEMBLOCK_NODE_MAP
 		if (memblock_get_region_node(rgn) != MAX_NUMNODES)
 			snprintf(nid_buf, sizeof(nid_buf), " on node %d",
 				 memblock_get_region_node(rgn));
 #endif
-		pr_info(" %s[%#x]\t[%#016llx-%#016llx], %#llx bytes%s\n",
-			name, i, base, base + size - 1, size, nid_buf);
+		pr_info(" %s[%#x]\t[%#016llx-%#016llx], %#llx bytes%s flags: %#lx\n",
+			name, i, base, base + size - 1, size, nid_buf, flags);
 	}
 }
 
-- 
1.7.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
