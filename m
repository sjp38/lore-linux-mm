Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f173.google.com (mail-pf0-f173.google.com [209.85.192.173])
	by kanga.kvack.org (Postfix) with ESMTP id 16A216B0007
	for <linux-mm@kvack.org>; Mon, 21 Dec 2015 00:45:12 -0500 (EST)
Received: by mail-pf0-f173.google.com with SMTP id 78so9764171pfw.2
        for <linux-mm@kvack.org>; Sun, 20 Dec 2015 21:45:12 -0800 (PST)
Received: from mga04.intel.com (mga04.intel.com. [192.55.52.120])
        by mx.google.com with ESMTP id 86si2179290pfh.158.2015.12.20.21.45.10
        for <linux-mm@kvack.org>;
        Sun, 20 Dec 2015 21:45:10 -0800 (PST)
Subject: [-mm PATCH v4 03/18] mm: skip memory block registration for
 ZONE_DEVICE
From: Dan Williams <dan.j.williams@intel.com>
Date: Sun, 20 Dec 2015 21:44:23 -0800
Message-ID: <20151221054423.34542.13407.stgit@dwillia2-desk3.jf.intel.com>
In-Reply-To: <20151221054406.34542.64393.stgit@dwillia2-desk3.jf.intel.com>
References: <20151221054406.34542.64393.stgit@dwillia2-desk3.jf.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org
Cc: linux-mm@kvack.org, linux-nvdimm@lists.01.org

Prevent userspace from trying and failing to online ZONE_DEVICE pages
which are meant to never be onlined.

For example on platforms with a udev rule like the following:

  SUBSYSTEM=="memory", ACTION=="add", ATTR{state}=="offline", ATTR{state}="online"

...will generate futile attempts to online the ZONE_DEVICE sections.
Example kernel messages:

    Built 1 zonelists in Node order, mobility grouping on.  Total pages: 1004747
    Policy zone: Normal
    online_pages [mem 0x248000000-0x24fffffff] failed

Signed-off-by: Dan Williams <dan.j.williams@intel.com>
---
 drivers/base/memory.c |   13 +++++++++++++
 include/linux/mm.h    |   12 ++++++++++++
 2 files changed, 25 insertions(+)

diff --git a/drivers/base/memory.c b/drivers/base/memory.c
index 6d7b14c2798e..3e96083c1a9d 100644
--- a/drivers/base/memory.c
+++ b/drivers/base/memory.c
@@ -651,6 +651,13 @@ static int add_memory_block(int base_section_nr)
 	return 0;
 }
 
+static bool is_zone_device_section(struct mem_section *ms)
+{
+	struct page *page;
+
+	page = sparse_decode_mem_map(ms->section_mem_map, __section_nr(ms));
+	return is_zone_device_page(page);
+}
 
 /*
  * need an interface for the VM to add new memory regions,
@@ -661,6 +668,9 @@ int register_new_memory(int nid, struct mem_section *section)
 	int ret = 0;
 	struct memory_block *mem;
 
+	if (is_zone_device_section(section))
+		return 0;
+
 	mutex_lock(&mem_sysfs_mutex);
 
 	mem = find_memory_block(section);
@@ -697,6 +707,9 @@ static int remove_memory_section(unsigned long node_id,
 {
 	struct memory_block *mem;
 
+	if (is_zone_device_section(section))
+		return 0;
+
 	mutex_lock(&mem_sysfs_mutex);
 	mem = find_memory_block(section);
 	unregister_mem_sect_under_nodes(mem, __section_nr(section));
diff --git a/include/linux/mm.h b/include/linux/mm.h
index a8ae5f7e9e22..57e9546d40dc 100644
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -686,6 +686,18 @@ static inline enum zone_type page_zonenum(const struct page *page)
 	return (page->flags >> ZONES_PGSHIFT) & ZONES_MASK;
 }
 
+#ifdef CONFIG_ZONE_DEVICE
+static inline bool is_zone_device_page(const struct page *page)
+{
+	return page_zonenum(page) == ZONE_DEVICE;
+}
+#else
+static inline bool is_zone_device_page(const struct page *page)
+{
+	return false;
+}
+#endif
+
 #if defined(CONFIG_SPARSEMEM) && !defined(CONFIG_SPARSEMEM_VMEMMAP)
 #define SECTION_IN_PAGE_FLAGS
 #endif

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
