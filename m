Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f170.google.com (mail-pd0-f170.google.com [209.85.192.170])
	by kanga.kvack.org (Postfix) with ESMTP id 1739F6B0032
	for <linux-mm@kvack.org>; Tue,  1 Oct 2013 05:48:19 -0400 (EDT)
Received: by mail-pd0-f170.google.com with SMTP id x10so7007435pdj.29
        for <linux-mm@kvack.org>; Tue, 01 Oct 2013 02:48:18 -0700 (PDT)
Message-ID: <524A9A28.2070704@cn.fujitsu.com>
Date: Tue, 01 Oct 2013 17:47:20 +0800
From: Zhang Yanfei <zhangyanfei@cn.fujitsu.com>
MIME-Version: 1.0
Subject: [PATCH -mm 2/8] memblock, numa: Introduce flag into memblock
References: <524A991D.3050005@cn.fujitsu.com>
In-Reply-To: <524A991D.3050005@cn.fujitsu.com>
Content-Transfer-Encoding: 7bit
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: robert.moore@intel.com, lv.zheng@intel.com, "Rafael J . Wysocki" <rjw@sisk.pl>, Len Brown <lenb@kernel.org>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@elte.hu>, "H. Peter Anvin" <hpa@zytor.com>, Andrew Morton <akpm@linux-foundation.org>, Tejun Heo <tj@kernel.org>, Thomas Renninger <trenn@suse.de>, Yinghai Lu <yinghai@kernel.org>, Jiang Liu <jiang.liu@huawei.com>, Wen Congyang <wency@cn.fujitsu.com>, Lai Jiangshan <laijs@cn.fujitsu.com>, Yasuaki Ishimatsu <isimatu.yasuaki@jp.fujitsu.com>, Taku Izumi <izumi.taku@jp.fujitsu.com>, Mel Gorman <mgorman@suse.de>, Minchan Kim <minchan@kernel.org>, "mina86@mina86.com" <mina86@mina86.com>, gong.chen@linux.intel.com, vasilis.liaskovitis@profitbricks.com, Rik van Riel <riel@redhat.com>, prarit@redhat.com, Toshi Kani <toshi.kani@hp.com>
Cc: Zhang Yanfei <zhangyanfei@cn.fujitsu.com>, "x86@kernel.org" <x86@kernel.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Linux MM <linux-mm@kvack.org>, linux-acpi@vger.kernel.org, Tang Chen <tangchen@cn.fujitsu.com>, imtangchen@gmail.com, Zhang Yanfei <zhangyanfei.yes@gmail.com>

From: Tang Chen <tangchen@cn.fujitsu.com>

There is no flag in memblock to describe what type the memory is.
Sometimes, we may use memblock to reserve some memory for special usage.
And we want to know what kind of memory it is. So we need a way to
differentiate memory for different usage.

In hotplug environment, we want to reserve hotpluggable memory so the
kernel won't be able to use it. And when the system is up, we have to
free these hotpluggable memory to buddy. So we need to mark these memory
first.

In order to do so, we need to mark out these special memory in memblock.
In this patch, we introduce a new "flags" member into memblock_region:
   struct memblock_region {
           phys_addr_t base;
           phys_addr_t size;
           unsigned long flags;		/* This is new. */
   #ifdef CONFIG_HAVE_MEMBLOCK_NODE_MAP
           int nid;
   #endif
   };

This patch does the following things:
1) Add "flags" member to memblock_region.
2) Modify the following APIs' prototype:
	memblock_add_region()
	memblock_insert_region()
3) Add memblock_reserve_region() to support reserve memory with flags, and keep
   memblock_reserve()'s prototype unmodified.
4) Modify other APIs to support flags, but keep their prototype unmodified.

The idea is from Wen Congyang <wency@cn.fujitsu.com> and Liu Jiang <jiang.liu@huawei.com>.

v1 -> v2:
As tj suggested, a zero flag MEMBLK_DEFAULT will make users confused. If
we want to specify any other flag, such MEMBLK_HOTPLUG, users don't know
to use MEMBLK_DEFAULT | MEMBLK_HOTPLUG or just MEMBLK_HOTPLUG. So remove
MEMBLK_DEFAULT (which is 0), and just use 0 by default to avoid confusions
to users.

Suggested-by: Wen Congyang <wency@cn.fujitsu.com>
Suggested-by: Liu Jiang <jiang.liu@huawei.com>
Signed-off-by: Tang Chen <tangchen@cn.fujitsu.com>
Reviewed-by: Zhang Yanfei <zhangyanfei@cn.fujitsu.com>
---
 include/linux/memblock.h |    1 +
 mm/memblock.c            |   53 +++++++++++++++++++++++++++++++++-------------
 2 files changed, 39 insertions(+), 15 deletions(-)

diff --git a/include/linux/memblock.h b/include/linux/memblock.h
index c1e2633..894d59e 100644
--- a/include/linux/memblock.h
+++ b/include/linux/memblock.h
@@ -22,6 +22,7 @@
 struct memblock_region {
 	phys_addr_t base;
 	phys_addr_t size;
+	unsigned long flags;
 #ifdef CONFIG_HAVE_MEMBLOCK_NODE_MAP
 	int nid;
 #endif
diff --git a/mm/memblock.c b/mm/memblock.c
index a8e81c3..3ec8aef 100644
--- a/mm/memblock.c
+++ b/mm/memblock.c
@@ -255,6 +255,7 @@ static void __init_memblock memblock_remove_region(struct memblock_type *type, u
 		type->cnt = 1;
 		type->regions[0].base = 0;
 		type->regions[0].size = 0;
+		type->regions[0].flags = 0;
 		memblock_set_region_node(&type->regions[0], MAX_NUMNODES);
 	}
 }
@@ -405,7 +406,8 @@ static void __init_memblock memblock_merge_regions(struct memblock_type *type)
 
 		if (this->base + this->size != next->base ||
 		    memblock_get_region_node(this) !=
-		    memblock_get_region_node(next)) {
+		    memblock_get_region_node(next) ||
+		    this->flags != next->flags) {
 			BUG_ON(this->base + this->size > next->base);
 			i++;
 			continue;
@@ -425,13 +427,15 @@ static void __init_memblock memblock_merge_regions(struct memblock_type *type)
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
 
@@ -439,6 +443,7 @@ static void __init_memblock memblock_insert_region(struct memblock_type *type,
 	memmove(rgn + 1, rgn, (type->cnt - idx) * sizeof(*rgn));
 	rgn->base = base;
 	rgn->size = size;
+	rgn->flags = flags;
 	memblock_set_region_node(rgn, nid);
 	type->cnt++;
 	type->total_size += size;
@@ -450,6 +455,7 @@ static void __init_memblock memblock_insert_region(struct memblock_type *type,
  * @base: base address of the new region
  * @size: size of the new region
  * @nid: nid of the new region
+ * @flags: flags of the new region
  *
  * Add new memblock region [@base,@base+@size) into @type.  The new region
  * is allowed to overlap with existing ones - overlaps don't affect already
@@ -460,7 +466,8 @@ static void __init_memblock memblock_insert_region(struct memblock_type *type,
  * 0 on success, -errno on failure.
  */
 static int __init_memblock memblock_add_region(struct memblock_type *type,
-				phys_addr_t base, phys_addr_t size, int nid)
+				phys_addr_t base, phys_addr_t size,
+				int nid, unsigned long flags)
 {
 	bool insert = false;
 	phys_addr_t obase = base;
@@ -475,6 +482,7 @@ static int __init_memblock memblock_add_region(struct memblock_type *type,
 		WARN_ON(type->cnt != 1 || type->total_size);
 		type->regions[0].base = base;
 		type->regions[0].size = size;
+		type->regions[0].flags = flags;
 		memblock_set_region_node(&type->regions[0], nid);
 		type->total_size = size;
 		return 0;
@@ -505,7 +513,8 @@ repeat:
 			nr_new++;
 			if (insert)
 				memblock_insert_region(type, i++, base,
-						       rbase - base, nid);
+						       rbase - base, nid,
+						       flags);
 		}
 		/* area below @rend is dealt with, forget about it */
 		base = min(rend, end);
@@ -515,7 +524,8 @@ repeat:
 	if (base < end) {
 		nr_new++;
 		if (insert)
-			memblock_insert_region(type, i, base, end - base, nid);
+			memblock_insert_region(type, i, base, end - base,
+					       nid, flags);
 	}
 
 	/*
@@ -537,12 +547,13 @@ repeat:
 int __init_memblock memblock_add_node(phys_addr_t base, phys_addr_t size,
 				       int nid)
 {
-	return memblock_add_region(&memblock.memory, base, size, nid);
+	return memblock_add_region(&memblock.memory, base, size, nid, 0);
 }
 
 int __init_memblock memblock_add(phys_addr_t base, phys_addr_t size)
 {
-	return memblock_add_region(&memblock.memory, base, size, MAX_NUMNODES);
+	return memblock_add_region(&memblock.memory, base, size,
+				   MAX_NUMNODES, 0);
 }
 
 /**
@@ -597,7 +608,8 @@ static int __init_memblock memblock_isolate_range(struct memblock_type *type,
 			rgn->size -= base - rbase;
 			type->total_size -= base - rbase;
 			memblock_insert_region(type, i, rbase, base - rbase,
-					       memblock_get_region_node(rgn));
+					       memblock_get_region_node(rgn),
+					       rgn->flags);
 		} else if (rend > end) {
 			/*
 			 * @rgn intersects from above.  Split and redo the
@@ -607,7 +619,8 @@ static int __init_memblock memblock_isolate_range(struct memblock_type *type,
 			rgn->size -= end - rbase;
 			type->total_size -= end - rbase;
 			memblock_insert_region(type, i--, rbase, end - rbase,
-					       memblock_get_region_node(rgn));
+					       memblock_get_region_node(rgn),
+					       rgn->flags);
 		} else {
 			/* @rgn is fully contained, record it */
 			if (!*end_rgn)
@@ -649,16 +662,24 @@ int __init_memblock memblock_free(phys_addr_t base, phys_addr_t size)
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
+	memblock_dbg("memblock_reserve: [%#016llx-%#016llx] flags %#02lx %pF\n",
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
+	return memblock_reserve_region(base, size, MAX_NUMNODES, 0);
 }
 
 /**
@@ -1101,6 +1122,7 @@ void __init_memblock memblock_set_current_limit(phys_addr_t limit)
 static void __init_memblock memblock_dump(struct memblock_type *type, char *name)
 {
 	unsigned long long base, size;
+	unsigned long flags;
 	int i;
 
 	pr_info(" %s.cnt  = 0x%lx\n", name, type->cnt);
@@ -1111,13 +1133,14 @@ static void __init_memblock memblock_dump(struct memblock_type *type, char *name
 
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
