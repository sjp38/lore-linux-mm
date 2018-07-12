Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f199.google.com (mail-qt0-f199.google.com [209.85.216.199])
	by kanga.kvack.org (Postfix) with ESMTP id 9F0DB6B000E
	for <linux-mm@kvack.org>; Thu, 12 Jul 2018 16:38:02 -0400 (EDT)
Received: by mail-qt0-f199.google.com with SMTP id e4-v6so15126812qtj.5
        for <linux-mm@kvack.org>; Thu, 12 Jul 2018 13:38:02 -0700 (PDT)
Received: from aserp2130.oracle.com (aserp2130.oracle.com. [141.146.126.79])
        by mx.google.com with ESMTPS id r5-v6si3663803qkh.10.2018.07.12.13.38.01
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 12 Jul 2018 13:38:01 -0700 (PDT)
From: Pavel Tatashin <pasha.tatashin@oracle.com>
Subject: [PATCH v5 4/5] mm/sparse: add new sparse_init_nid() and sparse_init()
Date: Thu, 12 Jul 2018 16:37:29 -0400
Message-Id: <20180712203730.8703-5-pasha.tatashin@oracle.com>
In-Reply-To: <20180712203730.8703-1-pasha.tatashin@oracle.com>
References: <20180712203730.8703-1-pasha.tatashin@oracle.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: steven.sistare@oracle.com, daniel.m.jordan@oracle.com, linux-kernel@vger.kernel.org, akpm@linux-foundation.org, kirill.shutemov@linux.intel.com, mhocko@suse.com, linux-mm@kvack.org, dan.j.williams@intel.com, jack@suse.cz, jglisse@redhat.com, jrdr.linux@gmail.com, bhe@redhat.com, gregkh@linuxfoundation.org, vbabka@suse.cz, richard.weiyang@gmail.com, dave.hansen@intel.com, rientjes@google.com, mingo@kernel.org, osalvador@techadventures.net, pasha.tatashin@oracle.com, abdhalee@linux.vnet.ibm.com, mpe@ellerman.id.au

sparse_init() requires to temporary allocate two large buffers:
usemap_map and map_map. Baoquan He has identified that these buffers are so
large that Linux is not bootable on small memory machines, such as a kdump
boot. The buffers are especially large when CONFIG_X86_5LEVEL is set, as
they are scaled to the maximum physical memory size.

Baoquan provided a fix, which reduces these sizes of these buffers, but it
is much better to get rid of them entirely.

Add a new way to initialize sparse memory: sparse_init_nid(), which only
operates within one memory node, and thus allocates memory either in large
contiguous block or allocates section by section. This eliminates the need
for use of temporary buffers.

For simplified bisecting and review temporarly call sparse_init()
new_sparse_init(), the new interface is going to be enabled as well as old
code removed in the next patch.

Signed-off-by: Pavel Tatashin <pasha.tatashin@oracle.com>
---
 mm/sparse.c | 85 +++++++++++++++++++++++++++++++++++++++++++++++++++++
 1 file changed, 85 insertions(+)

diff --git a/mm/sparse.c b/mm/sparse.c
index 01c616342909..4087b94afddf 100644
--- a/mm/sparse.c
+++ b/mm/sparse.c
@@ -200,6 +200,11 @@ static inline int next_present_section_nr(int section_nr)
 	      (section_nr <= __highest_present_section_nr));	\
 	     section_nr = next_present_section_nr(section_nr))
 
+static inline unsigned long first_present_section_nr(void)
+{
+	return next_present_section_nr(-1);
+}
+
 /*
  * Record how many memory sections are marked as present
  * during system bootup.
@@ -668,6 +673,86 @@ void __init sparse_init(void)
 	memblock_free_early(__pa(usemap_map), size);
 }
 
+/*
+ * Initialize sparse on a specific node. The node spans [pnum_begin, pnum_end)
+ * And number of present sections in this node is map_count.
+ */
+static void __init sparse_init_nid(int nid, unsigned long pnum_begin,
+				   unsigned long pnum_end,
+				   unsigned long map_count)
+{
+	unsigned long pnum, usemap_longs, *usemap;
+	struct page *map;
+
+	usemap_longs = BITS_TO_LONGS(SECTION_BLOCKFLAGS_BITS);
+	usemap = sparse_early_usemaps_alloc_pgdat_section(NODE_DATA(nid),
+							  usemap_size() *
+							  map_count);
+	if (!usemap) {
+		pr_err("%s: node[%d] usemap allocation failed", __func__, nid);
+		goto failed;
+	}
+	sparse_buffer_init(map_count * section_map_size(), nid);
+	for_each_present_section_nr(pnum_begin, pnum) {
+		if (pnum >= pnum_end)
+			break;
+
+		map = sparse_mem_map_populate(pnum, nid, NULL);
+		if (!map) {
+			pr_err("%s: node[%d] memory map backing failed. Some memory will not be available.",
+			       __func__, nid);
+			pnum_begin = pnum;
+			goto failed;
+		}
+		check_usemap_section_nr(nid, usemap);
+		sparse_init_one_section(__nr_to_section(pnum), pnum, map, usemap);
+		usemap += usemap_longs;
+	}
+	sparse_buffer_fini();
+	return;
+failed:
+	/* We failed to allocate, mark all the following pnums as not present */
+	for_each_present_section_nr(pnum_begin, pnum) {
+		struct mem_section *ms;
+
+		if (pnum >= pnum_end)
+			break;
+		ms = __nr_to_section(pnum);
+		ms->section_mem_map = 0;
+	}
+}
+
+/*
+ * Allocate the accumulated non-linear sections, allocate a mem_map
+ * for each and record the physical to section mapping.
+ */
+void __init new_sparse_init(void)
+{
+	unsigned long pnum_begin = first_present_section_nr();
+	int nid_begin = sparse_early_nid(__nr_to_section(pnum_begin));
+	unsigned long pnum_end, map_count = 1;
+
+	/* Setup pageblock_order for HUGETLB_PAGE_SIZE_VARIABLE */
+	set_pageblock_order();
+
+	for_each_present_section_nr(pnum_begin + 1, pnum_end) {
+		int nid = sparse_early_nid(__nr_to_section(pnum_end));
+
+		if (nid == nid_begin) {
+			map_count++;
+			continue;
+		}
+		/* Init node with sections in range [pnum_begin, pnum_end) */
+		sparse_init_nid(nid_begin, pnum_begin, pnum_end, map_count);
+		nid_begin = nid;
+		pnum_begin = pnum_end;
+		map_count = 1;
+	}
+	/* cover the last node */
+	sparse_init_nid(nid_begin, pnum_begin, pnum_end, map_count);
+	vmemmap_populate_print_last();
+}
+
 #ifdef CONFIG_MEMORY_HOTPLUG
 
 /* Mark all memory sections within the pfn range as online */
-- 
2.18.0
