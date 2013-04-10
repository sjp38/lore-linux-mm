Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx206.postini.com [74.125.245.206])
	by kanga.kvack.org (Postfix) with SMTP id 3B8066B0005
	for <linux-mm@kvack.org>; Wed, 10 Apr 2013 02:07:38 -0400 (EDT)
Received: by mail-da0-f49.google.com with SMTP id t11so64257daj.8
        for <linux-mm@kvack.org>; Tue, 09 Apr 2013 23:07:37 -0700 (PDT)
Date: Tue, 9 Apr 2013 23:07:34 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: [patch] mm, hotplug: avoid compiling memory hotremove functions when
 disabled
In-Reply-To: <alpine.DEB.2.02.1304092155220.25293@chino.kir.corp.google.com>
Message-ID: <alpine.DEB.2.02.1304092302540.3916@chino.kir.corp.google.com>
References: <1365440996-30981-1-git-send-email-toshi.kani@hp.com> <20130408134438.2a4388a07163e10a37158eed@linux-foundation.org> <1365454703.32127.8.camel@misato.fc.hp.com> <alpine.DEB.2.02.1304092155220.25293@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Toshi Kani <toshi.kani@hp.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Paul Mackerras <paulus@samba.org>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Wen Congyang <wency@cn.fujitsu.com>, Tang Chen <tangchen@cn.fujitsu.com>, Yasuaki Ishimatsu <isimatu.yasuaki@jp.fujitsu.com>, linux-kernel@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, linux-mm@kvack.org

__remove_pages() is only necessary for CONFIG_MEMORY_HOTREMOVE.  PowerPC
pseries will return -EOPNOTSUPP if unsupported.

Adding an #ifdef causes several other functions it depends on to also
become unnecessary, which saves in .text when disabled (it's disabled in
most defconfigs besides powerpc, including x86).  remove_memory_block()
becomes static since it is not referenced outside of
drivers/base/memory.c.

Build tested on x86 and powerpc with CONFIG_MEMORY_HOTREMOVE both enabled
and disabled.

Signed-off-by: David Rientjes <rientjes@google.com>
---
 arch/powerpc/platforms/pseries/hotplug-memory.c | 12 +++++
 drivers/base/memory.c                           | 44 +++++++--------
 include/linux/memory.h                          |  3 +-
 include/linux/memory_hotplug.h                  |  4 +-
 mm/memory_hotplug.c                             | 68 +++++++++++------------
 mm/sparse.c                                     | 72 +++++++++++++------------
 6 files changed, 113 insertions(+), 90 deletions(-)

diff --git a/arch/powerpc/platforms/pseries/hotplug-memory.c b/arch/powerpc/platforms/pseries/hotplug-memory.c
--- a/arch/powerpc/platforms/pseries/hotplug-memory.c
+++ b/arch/powerpc/platforms/pseries/hotplug-memory.c
@@ -72,6 +72,7 @@ unsigned long memory_block_size_bytes(void)
 	return get_memblock_size();
 }
 
+#ifdef CONFIG_MEMORY_HOTREMOVE
 static int pseries_remove_memblock(unsigned long base, unsigned int memblock_size)
 {
 	unsigned long start, start_pfn;
@@ -153,6 +154,17 @@ static int pseries_remove_memory(struct device_node *np)
 	ret = pseries_remove_memblock(base, lmb_size);
 	return ret;
 }
+#else
+static inline int pseries_remove_memblock(unsigned long base,
+					  unsigned int memblock_size)
+{
+	return -EOPNOTSUPP;
+}
+static inline int pseries_remove_memory(struct device_node *np)
+{
+	return -EOPNOTSUPP;
+}
+#endif /* CONFIG_MEMORY_HOTREMOVE */
 
 static int pseries_add_memory(struct device_node *np)
 {
diff --git a/drivers/base/memory.c b/drivers/base/memory.c
--- a/drivers/base/memory.c
+++ b/drivers/base/memory.c
@@ -93,16 +93,6 @@ int register_memory(struct memory_block *memory)
 	return error;
 }
 
-static void
-unregister_memory(struct memory_block *memory)
-{
-	BUG_ON(memory->dev.bus != &memory_subsys);
-
-	/* drop the ref. we got in remove_memory_block() */
-	kobject_put(&memory->dev.kobj);
-	device_unregister(&memory->dev);
-}
-
 unsigned long __weak memory_block_size_bytes(void)
 {
 	return MIN_MEMORY_BLOCK_SIZE;
@@ -637,8 +627,28 @@ static int add_memory_section(int nid, struct mem_section *section,
 	return ret;
 }
 
-int remove_memory_block(unsigned long node_id, struct mem_section *section,
-		int phys_device)
+/*
+ * need an interface for the VM to add new memory regions,
+ * but without onlining it.
+ */
+int register_new_memory(int nid, struct mem_section *section)
+{
+	return add_memory_section(nid, section, NULL, MEM_OFFLINE, HOTPLUG);
+}
+
+#ifdef CONFIG_MEMORY_HOTREMOVE
+static void
+unregister_memory(struct memory_block *memory)
+{
+	BUG_ON(memory->dev.bus != &memory_subsys);
+
+	/* drop the ref. we got in remove_memory_block() */
+	kobject_put(&memory->dev.kobj);
+	device_unregister(&memory->dev);
+}
+
+static int remove_memory_block(unsigned long node_id,
+			       struct mem_section *section, int phys_device)
 {
 	struct memory_block *mem;
 
@@ -661,15 +671,6 @@ int remove_memory_block(unsigned long node_id, struct mem_section *section,
 	return 0;
 }
 
-/*
- * need an interface for the VM to add new memory regions,
- * but without onlining it.
- */
-int register_new_memory(int nid, struct mem_section *section)
-{
-	return add_memory_section(nid, section, NULL, MEM_OFFLINE, HOTPLUG);
-}
-
 int unregister_memory_section(struct mem_section *section)
 {
 	if (!present_section(section))
@@ -677,6 +678,7 @@ int unregister_memory_section(struct mem_section *section)
 
 	return remove_memory_block(0, section, 0);
 }
+#endif /* CONFIG_MEMORY_HOTREMOVE */
 
 /*
  * offline one memory block. If the memory block has been offlined, do nothing.
diff --git a/include/linux/memory.h b/include/linux/memory.h
--- a/include/linux/memory.h
+++ b/include/linux/memory.h
@@ -114,9 +114,10 @@ extern void unregister_memory_notifier(struct notifier_block *nb);
 extern int register_memory_isolate_notifier(struct notifier_block *nb);
 extern void unregister_memory_isolate_notifier(struct notifier_block *nb);
 extern int register_new_memory(int, struct mem_section *);
+#ifdef CONFIG_MEMORY_HOTREMOVE
 extern int unregister_memory_section(struct mem_section *);
+#endif
 extern int memory_dev_init(void);
-extern int remove_memory_block(unsigned long, struct mem_section *, int);
 extern int memory_notify(unsigned long val, void *v);
 extern int memory_isolate_notify(unsigned long val, void *v);
 extern struct memory_block *find_memory_block_hinted(struct mem_section *,
diff --git a/include/linux/memory_hotplug.h b/include/linux/memory_hotplug.h
--- a/include/linux/memory_hotplug.h
+++ b/include/linux/memory_hotplug.h
@@ -97,13 +97,13 @@ extern void __online_page_free(struct page *page);
 #ifdef CONFIG_MEMORY_HOTREMOVE
 extern bool is_pageblock_removable_nolock(struct page *page);
 extern int arch_remove_memory(u64 start, u64 size);
+extern int __remove_pages(struct zone *zone, unsigned long start_pfn,
+	unsigned long nr_pages);
 #endif /* CONFIG_MEMORY_HOTREMOVE */
 
 /* reasonably generic interface to expand the physical pages in a zone  */
 extern int __add_pages(int nid, struct zone *zone, unsigned long start_pfn,
 	unsigned long nr_pages);
-extern int __remove_pages(struct zone *zone, unsigned long start_pfn,
-	unsigned long nr_pages);
 
 #ifdef CONFIG_NUMA
 extern int memory_add_physaddr_to_nid(u64 start);
diff --git a/mm/memory_hotplug.c b/mm/memory_hotplug.c
--- a/mm/memory_hotplug.c
+++ b/mm/memory_hotplug.c
@@ -436,6 +436,40 @@ static int __meminit __add_section(int nid, struct zone *zone,
 	return register_new_memory(nid, __pfn_to_section(phys_start_pfn));
 }
 
+/*
+ * Reasonably generic function for adding memory.  It is
+ * expected that archs that support memory hotplug will
+ * call this function after deciding the zone to which to
+ * add the new pages.
+ */
+int __ref __add_pages(int nid, struct zone *zone, unsigned long phys_start_pfn,
+			unsigned long nr_pages)
+{
+	unsigned long i;
+	int err = 0;
+	int start_sec, end_sec;
+	/* during initialize mem_map, align hot-added range to section */
+	start_sec = pfn_to_section_nr(phys_start_pfn);
+	end_sec = pfn_to_section_nr(phys_start_pfn + nr_pages - 1);
+
+	for (i = start_sec; i <= end_sec; i++) {
+		err = __add_section(nid, zone, i << PFN_SECTION_SHIFT);
+
+		/*
+		 * EEXIST is finally dealt with by ioresource collision
+		 * check. see add_memory() => register_memory_resource()
+		 * Warning will be printed if there is collision.
+		 */
+		if (err && (err != -EEXIST))
+			break;
+		err = 0;
+	}
+
+	return err;
+}
+EXPORT_SYMBOL_GPL(__add_pages);
+
+#ifdef CONFIG_MEMORY_HOTREMOVE
 /* find the smallest valid pfn in the range [start_pfn, end_pfn) */
 static int find_smallest_section_pfn(int nid, struct zone *zone,
 				     unsigned long start_pfn,
@@ -658,39 +692,6 @@ static int __remove_section(struct zone *zone, struct mem_section *ms)
 	return 0;
 }
 
-/*
- * Reasonably generic function for adding memory.  It is
- * expected that archs that support memory hotplug will
- * call this function after deciding the zone to which to
- * add the new pages.
- */
-int __ref __add_pages(int nid, struct zone *zone, unsigned long phys_start_pfn,
-			unsigned long nr_pages)
-{
-	unsigned long i;
-	int err = 0;
-	int start_sec, end_sec;
-	/* during initialize mem_map, align hot-added range to section */
-	start_sec = pfn_to_section_nr(phys_start_pfn);
-	end_sec = pfn_to_section_nr(phys_start_pfn + nr_pages - 1);
-
-	for (i = start_sec; i <= end_sec; i++) {
-		err = __add_section(nid, zone, i << PFN_SECTION_SHIFT);
-
-		/*
-		 * EEXIST is finally dealt with by ioresource collision
-		 * check. see add_memory() => register_memory_resource()
-		 * Warning will be printed if there is collision.
-		 */
-		if (err && (err != -EEXIST))
-			break;
-		err = 0;
-	}
-
-	return err;
-}
-EXPORT_SYMBOL_GPL(__add_pages);
-
 /**
  * __remove_pages() - remove sections of pages from a zone
  * @zone: zone from which pages need to be removed
@@ -726,6 +727,7 @@ int __remove_pages(struct zone *zone, unsigned long phys_start_pfn,
 	return ret;
 }
 EXPORT_SYMBOL_GPL(__remove_pages);
+#endif /* CONFIG_MEMORY_HOTREMOVE */
 
 int set_online_page_callback(online_page_callback_t callback)
 {
diff --git a/mm/sparse.c b/mm/sparse.c
--- a/mm/sparse.c
+++ b/mm/sparse.c
@@ -620,6 +620,7 @@ static void __kfree_section_memmap(struct page *memmap, unsigned long nr_pages)
 
 	vmemmap_free(start, end);
 }
+#ifdef CONFIG_MEMORY_HOTREMOVE
 static void free_map_bootmem(struct page *memmap, unsigned long nr_pages)
 {
 	unsigned long start = (unsigned long)memmap;
@@ -627,6 +628,7 @@ static void free_map_bootmem(struct page *memmap, unsigned long nr_pages)
 
 	vmemmap_free(start, end);
 }
+#endif /* CONFIG_MEMORY_HOTREMOVE */
 #else
 static struct page *__kmalloc_section_memmap(unsigned long nr_pages)
 {
@@ -664,6 +666,7 @@ static void __kfree_section_memmap(struct page *memmap, unsigned long nr_pages)
 			   get_order(sizeof(struct page) * nr_pages));
 }
 
+#ifdef CONFIG_MEMORY_HOTREMOVE
 static void free_map_bootmem(struct page *memmap, unsigned long nr_pages)
 {
 	unsigned long maps_section_nr, removing_section_nr, i;
@@ -690,40 +693,9 @@ static void free_map_bootmem(struct page *memmap, unsigned long nr_pages)
 			put_page_bootmem(page);
 	}
 }
+#endif /* CONFIG_MEMORY_HOTREMOVE */
 #endif /* CONFIG_SPARSEMEM_VMEMMAP */
 
-static void free_section_usemap(struct page *memmap, unsigned long *usemap)
-{
-	struct page *usemap_page;
-	unsigned long nr_pages;
-
-	if (!usemap)
-		return;
-
-	usemap_page = virt_to_page(usemap);
-	/*
-	 * Check to see if allocation came from hot-plug-add
-	 */
-	if (PageSlab(usemap_page) || PageCompound(usemap_page)) {
-		kfree(usemap);
-		if (memmap)
-			__kfree_section_memmap(memmap, PAGES_PER_SECTION);
-		return;
-	}
-
-	/*
-	 * The usemap came from bootmem. This is packed with other usemaps
-	 * on the section which has pgdat at boot time. Just keep it as is now.
-	 */
-
-	if (memmap) {
-		nr_pages = PAGE_ALIGN(PAGES_PER_SECTION * sizeof(struct page))
-			>> PAGE_SHIFT;
-
-		free_map_bootmem(memmap, nr_pages);
-	}
-}
-
 /*
  * returns the number of sections whose mem_maps were properly
  * set.  If this is <=0, then that means that the passed-in
@@ -800,6 +772,39 @@ static inline void clear_hwpoisoned_pages(struct page *memmap, int nr_pages)
 }
 #endif
 
+#ifdef CONFIG_MEMORY_HOTREMOVE
+static void free_section_usemap(struct page *memmap, unsigned long *usemap)
+{
+	struct page *usemap_page;
+	unsigned long nr_pages;
+
+	if (!usemap)
+		return;
+
+	usemap_page = virt_to_page(usemap);
+	/*
+	 * Check to see if allocation came from hot-plug-add
+	 */
+	if (PageSlab(usemap_page) || PageCompound(usemap_page)) {
+		kfree(usemap);
+		if (memmap)
+			__kfree_section_memmap(memmap, PAGES_PER_SECTION);
+		return;
+	}
+
+	/*
+	 * The usemap came from bootmem. This is packed with other usemaps
+	 * on the section which has pgdat at boot time. Just keep it as is now.
+	 */
+
+	if (memmap) {
+		nr_pages = PAGE_ALIGN(PAGES_PER_SECTION * sizeof(struct page))
+			>> PAGE_SHIFT;
+
+		free_map_bootmem(memmap, nr_pages);
+	}
+}
+
 void sparse_remove_one_section(struct zone *zone, struct mem_section *ms)
 {
 	struct page *memmap = NULL;
@@ -819,4 +824,5 @@ void sparse_remove_one_section(struct zone *zone, struct mem_section *ms)
 	clear_hwpoisoned_pages(memmap, PAGES_PER_SECTION);
 	free_section_usemap(memmap, usemap);
 }
-#endif
+#endif /* CONFIG_MEMORY_HOTREMOVE */
+#endif /* CONFIG_MEMORY_HOTPLUG */

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
