Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f178.google.com (mail-wi0-f178.google.com [209.85.212.178])
	by kanga.kvack.org (Postfix) with ESMTP id 9AF256B0035
	for <linux-mm@kvack.org>; Wed, 13 Aug 2014 08:26:11 -0400 (EDT)
Received: by mail-wi0-f178.google.com with SMTP id hi2so703328wib.5
        for <linux-mm@kvack.org>; Wed, 13 Aug 2014 05:26:11 -0700 (PDT)
Received: from mail-we0-f169.google.com (mail-we0-f169.google.com [74.125.82.169])
        by mx.google.com with ESMTPS id ga3si25903099wib.18.2014.08.13.05.26.09
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Wed, 13 Aug 2014 05:26:10 -0700 (PDT)
Received: by mail-we0-f169.google.com with SMTP id u56so11234253wes.28
        for <linux-mm@kvack.org>; Wed, 13 Aug 2014 05:26:09 -0700 (PDT)
Message-ID: <53EB5960.50200@plexistor.com>
Date: Wed, 13 Aug 2014 15:26:08 +0300
From: Boaz Harrosh <boaz@plexistor.com>
MIME-Version: 1.0
Subject: [RFC 9/9] prd: Add support for page struct mapping
References: <53EB5536.8020702@gmail.com>
In-Reply-To: <53EB5536.8020702@gmail.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ross Zwisler <ross.zwisler@linux.intel.com>, linux-fsdevel <linux-fsdevel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, Matthew Wilcox <willy@linux.intel.com>, Sagi Manole <sagi@plexistor.com>, Yigal Korman <yigal@plexistor.com>

From: Yigal Korman <yigal@plexistor.com>

One of the current short comings of the NVDIMM/PMEM
support is that this memory does not have a page-struct(s)
associated with its memory and therefor cannot be passed
to a block-device or network or DMAed in any way through
another device in the system.

This simple patch fixes all this. After this patch an FS
can do:
	bdev_direct_access(,&pfn,);
	page = pfn_to_page(pfn);
And use that page for a lock_page(), set_page_dirty(), and/or
anything else one might do with a page *.
(Note that with brd one can already do this)

[pmem-pages-ref-count]
pmem will serve it's pages with ref==0. Once an FS does
an blkdev_get_XXX(,FMODE_EXCL,), that memory is own by the FS.
The FS needs to manage its allocation, just as it already does
for its disk blocks. The fs should set page->count = 2, before
submission to any Kernel subsystem so when it returns it will
never be released to the Kernel's page-allocators. (page_freeze)

All is actually needed for this is to allocate page-sections
and map them into kernel virtual memory. Note that these sections
are not associated with any zone, because that would add them to
the page_allocators.

In order to reuse existing code, prd now depends on memory hotplug
and sparse memory configuration options.

If system has enabled MEMORY_HOTPLUG_SPARSE then a new config option
BLK_DEV_PMEM_USE_PAGES is enabled (Yes by default)

We will also need MEMORY_HOTREMOVE so if BLK_DEV_PMEM_USE_PAGES
is on we will "select" MEMORY_HOTREMOVE. Most distro's have
MEMORY_HOTPLUG_SPARSE on but not MEMORY_HOTREMOVE. For us here
we must have both.

Signed-off-by: Yigal Korman <yigal@plexistor.com>
Signed-off-by: Boaz Harrosh <boaz@plexistor.com>
---
 drivers/block/Kconfig |  13 +++++
 drivers/block/prd.c   | 137 ++++++++++++++++++++++++++++++++++++++++++++++++--
 2 files changed, 145 insertions(+), 5 deletions(-)

diff --git a/drivers/block/Kconfig b/drivers/block/Kconfig
index 8f0c225..8aca1b7 100644
--- a/drivers/block/Kconfig
+++ b/drivers/block/Kconfig
@@ -416,6 +416,19 @@ config BLK_DEV_PMEM
 	  Most normal users won't need this functionality, and can thus say N
 	  here.
 
+config BLK_DEV_PMEM_USE_PAGES
+	bool "Enable use of page struct pages with pmem"
+	depends on BLK_DEV_PMEM
+	depends on MEMORY_HOTPLUG_SPARSE
+	select MEMORY_HOTREMOVE
+	default y
+	help
+	  If a user of PMEM device needs "struct page" associated
+	  with its memory, so this memory can be sent to other
+	  block devices, or sent on the network, or be DMA transferred
+	  to other devices in the system, then you must say "Yes" here.
+	  If unsure leave as Yes.
+
 config CDROM_PKTCDVD
 	tristate "Packet writing on CD/DVD media"
 	depends on !UML
diff --git a/drivers/block/prd.c b/drivers/block/prd.c
index 36b8fe4..6115553 100644
--- a/drivers/block/prd.c
+++ b/drivers/block/prd.c
@@ -241,6 +241,134 @@ MODULE_PARM_DESC(map,
 static LIST_HEAD(prd_devices);
 static DEFINE_MUTEX(prd_devices_mutex);
 
+#ifdef CONFIG_BLK_DEV_PMEM_USE_PAGES
+static int prd_add_page_mapping(phys_addr_t phys_addr, size_t total_size,
+				void **o_virt_addr)
+{
+	int nid = memory_add_physaddr_to_nid(phys_addr);
+	unsigned long start_pfn = phys_addr >> PAGE_SHIFT;
+	unsigned long nr_pages = total_size >> PAGE_SHIFT;
+	unsigned int start_sec = pfn_to_section_nr(start_pfn);
+	unsigned int end_sec = pfn_to_section_nr(start_pfn + nr_pages - 1);
+	unsigned long phys_start_pfn;
+	struct page **page_array, **mapped_page_array;
+	unsigned long i;
+	struct vm_struct *vm_area;
+	void *virt_addr;
+	int ret = 0;
+
+	for (i = start_sec; i <= end_sec; i++) {
+		phys_start_pfn = i << PFN_SECTION_SHIFT;
+
+		if (pfn_valid(phys_start_pfn)) {
+			pr_warn("prd: memory section %lu already exists.\n", i);
+			continue;
+		}
+
+		ret = sparse_add_one_section(nid, phys_start_pfn);
+		if (unlikely(ret < 0)) {
+			if (ret == -EEXIST) {
+				ret = 0;
+				continue;
+			} else {
+				pr_warn("prd: sparse_add_one_section => %d\n",
+					ret);
+				return ret;
+			}
+		}
+	}
+
+	virt_addr = page_address(pfn_to_page(phys_addr >> PAGE_SHIFT));
+
+	page_array = vmalloc(sizeof(struct page *) * nr_pages);
+	if (unlikely(!page_array)) {
+		pr_warn("prd: failed to allocate nr_pages=0x%lx\n", nr_pages);
+		return -ENOMEM;
+	}
+
+	for (i = 0; i <  nr_pages; i++)
+		page_array[i] = pfn_to_page(start_pfn + i);
+
+	/* __get_vm_area requires a range of addresses from which to allocate
+	 * the vm_area. This range will include more pages that we need because
+	 * it allocates one guard page in the end. Usually you give it a wide
+	 * range from which to choose from, but we want exact addresses, so add
+	 * the size of the guard page to the end of the range (otherwise, this
+	 * will always fail)
+	 */
+	/* TODO this guard page may confuse users when asking for several pmem
+	 * devices in adjacent areas (the start of the next pmem will be
+	 * occupied by the guard page of the previous pmem)
+	 */
+	vm_area = __get_vm_area(total_size, VM_USERMAP, (ulong)virt_addr,
+				(ulong)virt_addr + total_size + PAGE_SIZE);
+	if (unlikely(!vm_area)) {
+		pr_err("prd: failed to __get_vm_area.\n");
+		ret = -ENOMEM;
+		goto free_array;
+	}
+
+	mapped_page_array = page_array;
+	ret = map_vm_area(vm_area, PAGE_KERNEL, &mapped_page_array);
+	if (unlikely(ret || mapped_page_array < (page_array + nr_pages))) {
+		pr_err("prd: failed to map_vm_area => %d\n", ret);
+		if (!ret) {
+			free_vm_area(vm_area);
+			ret = -ENOMEM;
+		}
+	}
+	*o_virt_addr = virt_addr;
+
+free_array:
+	vfree(page_array);
+	return ret;
+}
+
+static void prd_remove_page_mapping(phys_addr_t phys_addr, size_t total_size,
+				    void *virt_addr)
+{
+	unsigned long start_pfn = phys_addr >> PAGE_SHIFT;
+	unsigned long nr_pages = total_size >> PAGE_SHIFT;
+	unsigned int start_sec = pfn_to_section_nr(start_pfn);
+	unsigned int end_sec = pfn_to_section_nr(start_pfn + nr_pages - 1);
+	unsigned int i;
+
+	for (i = start_sec; i <= end_sec; i++) {
+		struct mem_section *ms = __nr_to_section(i);
+		int nid = pfn_to_nid(i << PFN_SECTION_SHIFT);
+
+		if (!valid_section(ms)) {
+			pr_warn("prd: memory section %d is missing.\n", i);
+			continue;
+		}
+
+		sparse_remove_one_section(nid, ms);
+	}
+	vunmap(virt_addr);
+}
+
+#else /* !CONFIG_BLK_DEV_PMEM_USE_PAGES */
+static int prd_add_page_mapping(phys_addr_t phys_addr, size_t total_size,
+				void **o_virt_addr)
+{
+	void *virt_addr = ioremap_cache(phys_addr, total_size);
+
+	if (unlikely(!virt_addr))
+		return -ENXIO;
+
+	*o_virt_addr = virt_addr;
+	return 0;
+}
+
+static void prd_remove_page_mapping(phys_addr_t phys_addr, size_t total_size,
+				    void *virt_addr)
+{
+	iounmap(virt_addr);
+}
+#endif /* CONFIG_BLK_DEV_PMEM_USE_PAGES */
+
+
+
 /* prd->phys_addr and prd->size need to be set.
  * Will then set virt_addr if successful.
  */
@@ -257,11 +385,10 @@ int prd_mem_map(struct prd_device *prd)
 		return -EINVAL;
 	}
 
-	prd->virt_addr = ioremap_cache(prd->phys_addr, prd->size);
-	if (unlikely(!prd->virt_addr)) {
-		err = -ENOMEM;
+	err = prd_add_page_mapping(prd->phys_addr, prd->size, &prd->virt_addr);
+	if (unlikely(err))
 		goto out_release;
-	}
+
 	return 0;
 
 out_release:
@@ -274,7 +401,7 @@ void prd_mem_unmap(struct prd_device *prd)
 	if (unlikely(!prd->virt_addr))
 		return;
 
-	iounmap(prd->virt_addr);
+	prd_remove_page_mapping(prd->phys_addr, prd->size, prd->virt_addr);
 	release_mem_region(prd->phys_addr, prd->size);
 	prd->virt_addr = NULL;
 }
-- 
1.9.3


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
