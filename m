Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ee0-f43.google.com (mail-ee0-f43.google.com [74.125.83.43])
	by kanga.kvack.org (Postfix) with ESMTP id 5FE3F6B0031
	for <linux-mm@kvack.org>; Tue, 14 Jan 2014 13:52:35 -0500 (EST)
Received: by mail-ee0-f43.google.com with SMTP id c41so415388eek.2
        for <linux-mm@kvack.org>; Tue, 14 Jan 2014 10:52:34 -0800 (PST)
Received: from e06smtp11.uk.ibm.com (e06smtp11.uk.ibm.com. [195.75.94.107])
        by mx.google.com with ESMTPS id p46si2865604eem.63.2014.01.14.10.52.34
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Tue, 14 Jan 2014 10:52:34 -0800 (PST)
Received: from /spool/local
	by e06smtp11.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <phacht@linux.vnet.ibm.com>;
	Tue, 14 Jan 2014 18:52:33 -0000
Received: from b06cxnps4076.portsmouth.uk.ibm.com (d06relay13.portsmouth.uk.ibm.com [9.149.109.198])
	by d06dlp01.portsmouth.uk.ibm.com (Postfix) with ESMTP id 26AD417D805C
	for <linux-mm@kvack.org>; Tue, 14 Jan 2014 18:52:42 +0000 (GMT)
Received: from d06av07.portsmouth.uk.ibm.com (d06av07.portsmouth.uk.ibm.com [9.149.37.248])
	by b06cxnps4076.portsmouth.uk.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id s0EIqH0F721266
	for <linux-mm@kvack.org>; Tue, 14 Jan 2014 18:52:17 GMT
Received: from d06av07.portsmouth.uk.ibm.com (localhost [127.0.0.1])
	by d06av07.portsmouth.uk.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id s0EIqS5b028992
	for <linux-mm@kvack.org>; Tue, 14 Jan 2014 13:52:29 -0500
Date: Tue, 14 Jan 2014 19:52:25 +0100
From: Philipp Hachtmann <phacht@linux.vnet.ibm.com>
Subject: Re: [PATCH V3 2/2] mm/memblock: Add support for excluded memory
 areas
Message-ID: <20140114195225.078f810a@lilie>
In-Reply-To: <52D538FD.8010907@ti.com>
References: <1389618217-48166-1-git-send-email-phacht@linux.vnet.ibm.com>
	<1389618217-48166-3-git-send-email-phacht@linux.vnet.ibm.com>
	<52D538FD.8010907@ti.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Grygorii Strashko <grygorii.strashko@ti.com>
Cc: akpm@linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, qiuxishi@huawei.com, dhowells@redhat.com, daeseok.youn@gmail.com, liuj97@gmail.com, yinghai@kernel.org, zhangyanfei@cn.fujitsu.com, santosh.shilimkar@ti.com, tangchen@cn.fujitsu.com

Hello Grygorii,

thank you for your comments.

To clarify we have the following requirements for memblock:

(1) Reserved areas can be declared before memory is added.
(2) The physical memory is detected once only.
(3) The free memory (i.e. not reserved) memory can be iterated to add
it to the buddy allocator.
(4) Memory designated to be mapped into the kernel address space can be
iterated.
(5) Kdump on s390 requires knowledge about the full system memory
layout.

The s390 kdump implementation works a bit different from the
implementation on other architectures: The layout is not taken from the
production system and saved for the kdump kernel. Instead the kdump
kernel needs to gather information about the whole memory without
respect to locked out areas (like mem=3D and OLDMEM etc.).

Without kdump's requirement it would of course be suitable and easy
just to remove memory from memblock.memory. But then this information
is lost for later use by kdump.

The patch does not change any behaviour of the current API - whether it
is enabled or not.

The current patch seems to be overly complicated.
The following patch contains only the nomap functionality without any
cleanup and refactoring. I will post a V4 patch set which will contain
this patch.

Kind regards

Philipp

=46rom eb1ad42c19c6f7bfdf3258a83dc54461c5f02d55 Mon Sep 17 00:00:00 2001
From: Philipp Hachtmann <phacht@linux.vnet.ibm.com>
Date: Tue, 14 Jan 2014 19:49:39 +0100
Subject: [PATCH] mm/memblock: Add support for excluded memory areas

Add a new memory state "nomap" to memblock. This can be used to truncate
the usable memory in the system without forgetting about what is really
installed.

Signed-off-by: Philipp Hachtmann <phacht@linux.vnet.ibm.com>
---
 include/linux/memblock.h |  25 +++++++
 mm/Kconfig               |   3 +
 mm/memblock.c            | 175 +++++++++++++++++++++++++++++++++++++++++++=
+++-
 mm/nobootmem.c           |   9 +++
 4 files changed, 211 insertions(+), 1 deletion(-)

diff --git a/include/linux/memblock.h b/include/linux/memblock.h
index 1ef6636..be1c819 100644
--- a/include/linux/memblock.h
+++ b/include/linux/memblock.h
@@ -18,6 +18,7 @@
 #include <linux/mm.h>
=20
 #define INIT_MEMBLOCK_REGIONS	128
+#define INIT_MEMBLOCK_NOMAP_REGIONS 4
=20
 /* Definition of memblock flags. */
 #define MEMBLOCK_HOTPLUG	0x1	/* hotpluggable region */
@@ -43,6 +44,9 @@ struct memblock {
 	phys_addr_t current_limit;
 	struct memblock_type memory;
 	struct memblock_type reserved;
+#ifdef CONFIG_ARCH_MEMBLOCK_NOMAP
+	struct memblock_type nomap;
+#endif
 };
=20
 extern struct memblock memblock;
@@ -68,6 +72,10 @@ int memblock_add(phys_addr_t base, phys_addr_t size);
 int memblock_remove(phys_addr_t base, phys_addr_t size);
 int memblock_free(phys_addr_t base, phys_addr_t size);
 int memblock_reserve(phys_addr_t base, phys_addr_t size);
+#ifdef CONFIG_ARCH_MEMBLOCK_NOMAP
+int memblock_nomap(phys_addr_t base, phys_addr_t size);
+int memblock_remap(phys_addr_t base, phys_addr_t size);
+#endif
 void memblock_trim_memory(phys_addr_t align);
 int memblock_mark_hotplug(phys_addr_t base, phys_addr_t size);
 int memblock_clear_hotplug(phys_addr_t base, phys_addr_t size);
@@ -133,6 +141,23 @@ void __next_free_mem_range(u64 *idx, int nid, phys_add=
r_t *out_start,
 	     i !=3D (u64)ULLONG_MAX;					\
 	     __next_free_mem_range(&i, nid, p_start, p_end, p_nid))
=20
+
+#ifdef CONFIG_ARCH_MEMBLOCK_NOMAP
+#define for_each_mapped_mem_range(i, nid, p_start, p_end, p_nid)	\
+	for (i =3D 0,							\
+		     __next_mapped_mem_range(&i, nid, &memblock.memory,	\
+				      &memblock.nomap, p_start,		\
+				      p_end, p_nid);			\
+	     i !=3D (u64)ULLONG_MAX;					\
+	     __next_mapped_mem_range(&i, nid, &memblock.memory,		\
+				     &memblock.nomap,			\
+				     p_start, p_end, p_nid))
+
+void __next_mapped_mem_range(u64 *idx, int nid, phys_addr_t *out_start,
+			     phys_addr_t *out_end, int *out_nid);
+
+#endif
+
 void __next_free_mem_range_rev(u64 *idx, int nid, phys_addr_t *out_start,
 			       phys_addr_t *out_end, int *out_nid);
=20
diff --git a/mm/Kconfig b/mm/Kconfig
index 2d9f150..6907654 100644
--- a/mm/Kconfig
+++ b/mm/Kconfig
@@ -137,6 +137,9 @@ config HAVE_MEMBLOCK_NODE_MAP
 config ARCH_DISCARD_MEMBLOCK
 	boolean
=20
+config ARCH_MEMBLOCK_NOMAP
+	boolean
+
 config NO_BOOTMEM
 	boolean
=20
diff --git a/mm/memblock.c b/mm/memblock.c
index 9c0aeef..b36f5d3 100644
--- a/mm/memblock.c
+++ b/mm/memblock.c
@@ -28,6 +28,11 @@
 static struct memblock_region memblock_memory_init_regions[INIT_MEMBLOCK_R=
EGIONS] __initdata_memblock;
 static struct memblock_region memblock_reserved_init_regions[INIT_MEMBLOCK=
_REGIONS] __initdata_memblock;
=20
+#ifdef CONFIG_ARCH_MEMBLOCK_NOMAP
+static struct memblock_region
+memblock_nomap_init_regions[INIT_MEMBLOCK_NOMAP_REGIONS] __initdata_memblo=
ck;
+#endif
+
 struct memblock memblock __initdata_memblock =3D {
 	.memory.regions		=3D memblock_memory_init_regions,
 	.memory.cnt		=3D 1,	/* empty dummy entry */
@@ -37,6 +42,11 @@ struct memblock memblock __initdata_memblock =3D {
 	.reserved.cnt		=3D 1,	/* empty dummy entry */
 	.reserved.max		=3D INIT_MEMBLOCK_REGIONS,
=20
+#ifdef CONFIG_ARCH_MEMBLOCK_NOMAP
+	.nomap.regions       =3D memblock_nomap_init_regions,
+	.nomap.cnt           =3D 1,	/* empty dummy entry */
+	.nomap.max           =3D INIT_MEMBLOCK_NOMAP_REGIONS,
+#endif
 	.bottom_up		=3D false,
 	.current_limit		=3D MEMBLOCK_ALLOC_ANYWHERE,
 };
@@ -292,6 +302,20 @@ phys_addr_t __init_memblock get_allocated_memblock_mem=
ory_regions_info(
 			  memblock.memory.max);
 }
=20
+#ifdef CONFIG_ARCH_MEMBLOCK_NOMAP
+phys_addr_t __init_memblock get_allocated_memblock_nomap_regions_info(
+					phys_addr_t *addr)
+{
+	if (memblock.memory.regions =3D=3D memblock_memory_init_regions)
+		return 0;
+
+	*addr =3D __pa(memblock.memory.regions);
+
+	return PAGE_ALIGN(sizeof(struct memblock_region) *
+			  memblock.memory.max);
+}
+
+#endif /* CONFIG_ARCH_MEMBLOCK_NOMAP */
 #endif
=20
 /**
@@ -757,6 +781,60 @@ int __init_memblock memblock_clear_hotplug(phys_addr_t=
 base, phys_addr_t size)
 	return 0;
 }
=20
+#ifdef CONFIG_ARCH_MEMBLOCK_NOMAP
+/*
+ * memblock_nomap() - mark a memory range as completely unusable
+ *
+ * This can be used to exclude memory regions from every further treatment
+ * in the running system. Ranges which are added to the nomap list will
+ * also be marked as reserved. So they won't either be allocated by memblo=
ck
+ * nor freed to the page allocator.
+ *
+ * The usable (i.e. not in nomap list) memory can be iterated
+ * via for_each_mapped_mem_range().
+ *
+ * memblock_start_of_DRAM() and memblock_end_of_DRAM() still refer to the
+ * whole system memory.
+ */
+int __init_memblock memblock_nomap(phys_addr_t base, phys_addr_t size)
+{
+	int ret;
+	memblock_dbg("memblock_nomap: [%#016llx-%#016llx] %pF\n",
+		     (unsigned long long)base,
+		     (unsigned long long)base + size,
+		     (void *)_RET_IP_);
+
+	ret =3D memblock_add_region(&memblock.reserved, base,
+				  size, MAX_NUMNODES, 0);
+	if (ret)
+		return ret;
+
+	return memblock_add_region(&memblock.nomap, base,
+				   size, MAX_NUMNODES, 0);
+}
+
+/*
+ * memblock_remap() - remove a memory range from the nomap list
+ *
+ * This is the inverse function to memblock_nomap().
+ */
+int __init_memblock memblock_remap(phys_addr_t base, phys_addr_t size)
+{
+	int ret;
+	memblock_dbg("memblock_remap: [%#016llx-%#016llx] %pF\n",
+		     (unsigned long long)base,
+		     (unsigned long long)base + size,
+		     (void *)_RET_IP_);
+
+	ret =3D __memblock_remove(&memblock.reserved, base, size);
+	if (ret)
+		return ret;
+
+	return __memblock_remove(&memblock.nomap, base, size);
+}
+
+#endif
+
 /**
  * __next_free_mem_range - next function for for_each_free_mem_range()
  * @idx: pointer to u64 loop variable
@@ -836,6 +914,88 @@ void __init_memblock __next_free_mem_range(u64 *idx, i=
nt nid,
 	*idx =3D ULLONG_MAX;
 }
=20
+#ifdef ARCH_MEMBLOCK_NOMAP
+/**
+ * __next_mapped_mem_range - next function for for_each_free_mem_range()
+ * @idx: pointer to u64 loop variable
+ * @nid: node selector, %NUMA_NO_NODE for all nodes
+ * @out_start: ptr to phys_addr_t for start address of the range, can be %=
NULL
+ * @out_end: ptr to phys_addr_t for end address of the range, can be %NULL
+ * @out_nid: ptr to int for nid of the range, can be %NULL
+ *
+ * Find the first free area from *@idx which matches @nid, fill the out
+ * parameters, and update *@idx for the next iteration.  The lower 32bit of
+ * *@idx contains index into memory region and the upper 32bit indexes the
+ * areas before each reserved region.  For example, if reserved regions
+ * look like the following,
+ *
+ *	0:[0-16), 1:[32-48), 2:[128-130)
+ *
+ * The upper 32bit indexes the following regions.
+ *
+ *	0:[0-0), 1:[16-32), 2:[48-128), 3:[130-MAX)
+ *
+ * As both region arrays are sorted, the function advances the two indices
+ * in lockstep and returns each intersection.
+ */
+void __init_memblock __next_mapped_mem_range(u64 *idx, int nid,
+					   phys_addr_t *out_start,
+					   phys_addr_t *out_end, int *out_nid)
+{
+	struct memblock_type *mem =3D &memblock.memory;
+	struct memblock_type *rsv =3D &memblock.nomap;
+	int mi =3D *idx & 0xffffffff;
+	int ri =3D *idx >> 32;
+
+	if (WARN_ONCE(nid =3D=3D MAX_NUMNODES, "Usage of MAX_NUMNODES is deprecat=
ed. Use NUMA_NO_NODE instead\n"))
+		nid =3D NUMA_NO_NODE;
+
+	for (; mi < mem->cnt; mi++) {
+		struct memblock_region *m =3D &mem->regions[mi];
+		phys_addr_t m_start =3D m->base;
+		phys_addr_t m_end =3D m->base + m->size;
+
+		/* only memory regions are associated with nodes, check it */
+		if (nid !=3D NUMA_NO_NODE && nid !=3D memblock_get_region_node(m))
+			continue;
+
+		/* scan areas before each reservation for intersection */
+		for (; ri < rsv->cnt + 1; ri++) {
+			struct memblock_region *r =3D &rsv->regions[ri];
+			phys_addr_t r_start =3D ri ? r[-1].base + r[-1].size : 0;
+			phys_addr_t r_end =3D ri < rsv->cnt ?
+				r->base : ULLONG_MAX;
+
+			/* if ri advanced past mi, break out to advance mi */
+			if (r_start >=3D m_end)
+				break;
+			/* if the two regions intersect, we're done */
+			if (m_start < r_end) {
+				if (out_start)
+					*out_start =3D max(m_start, r_start);
+				if (out_end)
+					*out_end =3D min(m_end, r_end);
+				if (out_nid)
+					*out_nid =3D memblock_get_region_node(m);
+				/*
+				 * The region which ends first is advanced
+				 * for the next iteration.
+				 */
+				if (m_end <=3D r_end)
+					mi++;
+				else
+					ri++;
+				*idx =3D (u32)mi | (u64)ri << 32;
+				return;
+			}
+		}
+	}
+
+	/* signal end of iteration */
+	*idx =3D ULLONG_MAX;
+}
+#endif
+
 /**
  * __next_free_mem_range_rev - next function for for_each_free_mem_range_r=
everse()
  * @idx: pointer to u64 loop variable
@@ -1438,12 +1598,21 @@ static void __init_memblock memblock_dump(struct me=
mblock_type *type, char *name
 void __init_memblock __memblock_dump_all(void)
 {
 	pr_info("MEMBLOCK configuration:\n");
+#ifndef CONFIG_ARCH_MEMBLOCK_NOMAP
 	pr_info(" memory size =3D %#llx reserved size =3D %#llx\n",
 		(unsigned long long)memblock.memory.total_size,
 		(unsigned long long)memblock.reserved.total_size);
-
+#else
+	pr_info(" memory size =3D %#llx reserved size =3D %#llx nomap size =3D %#=
llx\n",
+		(unsigned long long)memblock.memory.total_size,
+		(unsigned long long)memblock.reserved.total_size,
+		(unsigned long long)memblock.nomap.total_size);
+#endif
 	memblock_dump(&memblock.memory, "memory");
 	memblock_dump(&memblock.reserved, "reserved");
+#ifdef CONFIG_ARCH_MEMBLOCK_NOMAP
+	memblock_dump(&memblock.nomap, "nomap");
+#endif
 }
=20
 void __init memblock_allow_resize(void)
@@ -1502,6 +1671,10 @@ static int __init memblock_init_debugfs(void)
 		return -ENXIO;
 	debugfs_create_file("memory", S_IRUGO, root, &memblock.memory, &memblock_=
debug_fops);
 	debugfs_create_file("reserved", S_IRUGO, root, &memblock.reserved, &membl=
ock_debug_fops);
+#ifdef CONFIG_ARCH_MEMBLOCK_NOMAP
+	debugfs_create_file("nomap", S_IRUGO, root,
+			    &memblock.nomap, &memblock_debug_fops);
+#endif
=20
 	return 0;
 }
diff --git a/mm/nobootmem.c b/mm/nobootmem.c
index e2906a5..c57d5e3 100644
--- a/mm/nobootmem.c
+++ b/mm/nobootmem.c
@@ -133,6 +133,15 @@ static unsigned long __init free_low_memory_core_early=
(void)
 	size =3D get_allocated_memblock_memory_regions_info(&start);
 	if (size)
 		count +=3D __free_memory_core(start, start + size);
+
+#ifdef CONFIG_ARCH_MEMBLOCK_NOMAP
+
+	/* Free memblock.nomap array if it was allocated */
+	size =3D get_allocated_memblock_memory_regions_info(&start);
+	if (size)
+		count +=3D __free_memory_core(start, start + size);
+
+#endif
 #endif
=20
 	return count;
--=20
1.8.4.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
