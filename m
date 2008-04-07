From: Yasunori Goto <y-goto@jp.fujitsu.com>
Subject: [Patch 003/005](memory hotplug) make alloc_bootmem_section()
Date: Mon, 07 Apr 2008 21:47:29 +0900
Message-ID: <20080407214639.8876.E1E9C6FF@jp.fujitsu.com>
References: <20080407213519.886E.E1E9C6FF@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1758111AbYDGMsg@vger.kernel.org>
In-Reply-To: <20080407213519.886E.E1E9C6FF@jp.fujitsu.com>
Sender: linux-kernel-owner@vger.kernel.org
To: Badari Pulavarty <pbadari@us.ibm.com>, Andrew Morton <akpm@linux-foundation.org>
Cc: Linux Kernel ML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Yinghai Lu <yhlu.kernel@gmail.com>
List-Id: linux-mm.kvack.org


alloc_bootmem_section() can allocate specified section's area.
This is used for usemap to keep same section with pgdat by later patch.

Signed-off-by: Yasunori Goto <y-goto@jp.fujitsu.com>

---
 include/linux/bootmem.h |    2 ++
 mm/bootmem.c            |   31 +++++++++++++++++++++++++++++++
 2 files changed, 33 insertions(+)

Index: current/include/linux/bootmem.h
===================================================================
--- current.orig/include/linux/bootmem.h	2008-04-07 19:18:44.000000000 +0900
+++ current/include/linux/bootmem.h	2008-04-07 19:30:08.000000000 +0900
@@ -101,6 +101,8 @@
 extern void free_bootmem_node(pg_data_t *pgdat,
 			      unsigned long addr,
 			      unsigned long size);
+extern void *alloc_bootmem_section(unsigned long size,
+				   unsigned long section_nr);
 
 #ifndef CONFIG_HAVE_ARCH_BOOTMEM_NODE
 #define alloc_bootmem_node(pgdat, x) \
Index: current/mm/bootmem.c
===================================================================
--- current.orig/mm/bootmem.c	2008-04-07 19:18:44.000000000 +0900
+++ current/mm/bootmem.c	2008-04-07 19:30:08.000000000 +0900
@@ -540,6 +540,37 @@
 	return __alloc_bootmem(size, align, goal);
 }
 
+#ifdef CONFIG_SPARSEMEM
+void * __init alloc_bootmem_section(unsigned long size,
+				    unsigned long section_nr)
+{
+	void *ptr;
+	unsigned long limit, goal, start_nr, end_nr, pfn;
+	struct pglist_data *pgdat;
+
+	pfn = section_nr_to_pfn(section_nr);
+	goal = PFN_PHYS(pfn);
+	limit = PFN_PHYS(section_nr_to_pfn(section_nr + 1)) - 1;
+	pgdat = NODE_DATA(early_pfn_to_nid(pfn));
+	ptr = __alloc_bootmem_core(pgdat->bdata, size, SMP_CACHE_BYTES, goal,
+				   limit);
+
+	if (!ptr)
+		return NULL;
+
+	start_nr = pfn_to_section_nr(PFN_DOWN(__pa(ptr)));
+	end_nr = pfn_to_section_nr(PFN_DOWN(__pa(ptr) + size));
+	if (start_nr != section_nr || end_nr != section_nr) {
+		printk(KERN_WARNING "alloc_bootmem failed on section %ld.\n",
+		       section_nr);
+		free_bootmem_core(pgdat->bdata, __pa(ptr), size);
+		ptr = NULL;
+	}
+
+	return ptr;
+}
+#endif
+
 #ifndef ARCH_LOW_ADDRESS_LIMIT
 #define ARCH_LOW_ADDRESS_LIMIT	0xffffffffUL
 #endif

-- 
Yasunori Goto 
