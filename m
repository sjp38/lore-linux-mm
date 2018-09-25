Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk1-f198.google.com (mail-qk1-f198.google.com [209.85.222.198])
	by kanga.kvack.org (Postfix) with ESMTP id 44D638E0072
	for <linux-mm@kvack.org>; Tue, 25 Sep 2018 05:15:22 -0400 (EDT)
Received: by mail-qk1-f198.google.com with SMTP id c22-v6so24939566qkb.18
        for <linux-mm@kvack.org>; Tue, 25 Sep 2018 02:15:22 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id f96-v6si1326631qtb.199.2018.09.25.02.15.21
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 25 Sep 2018 02:15:21 -0700 (PDT)
From: David Hildenbrand <david@redhat.com>
Subject: [PATCH v2 1/6] mm/memory_hotplug: make remove_memory() take the device_hotplug_lock
Date: Tue, 25 Sep 2018 11:14:52 +0200
Message-Id: <20180925091457.28651-2-david@redhat.com>
In-Reply-To: <20180925091457.28651-1-david@redhat.com>
References: <20180925091457.28651-1-david@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org, linux-doc@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, linux-acpi@vger.kernel.org, xen-devel@lists.xenproject.org, devel@linuxdriverproject.org, David Hildenbrand <david@redhat.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Paul Mackerras <paulus@samba.org>, Michael Ellerman <mpe@ellerman.id.au>, "Rafael J. Wysocki" <rjw@rjwysocki.net>, Len Brown <lenb@kernel.org>, Rashmica Gupta <rashmica.g@gmail.com>, Michael Neuling <mikey@neuling.org>, Balbir Singh <bsingharora@gmail.com>, Nathan Fontenot <nfont@linux.vnet.ibm.com>, John Allen <jallen@linux.vnet.ibm.com>, Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.com>, Dan Williams <dan.j.williams@intel.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Vlastimil Babka <vbabka@suse.cz>, Pavel Tatashin <pasha.tatashin@oracle.com>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Oscar Salvador <osalvador@suse.de>, YASUAKI ISHIMATSU <yasu.isimatu@gmail.com>, Mathieu Malaterre <malat@debian.org>

remove_memory() is exported right now but requires the
device_hotplug_lock, which is not exported. So let's provide a variant
that takes the lock and only export that one.

The lock is already held in
	arch/powerpc/platforms/pseries/hotplug-memory.c
	drivers/acpi/acpi_memhotplug.c
	arch/powerpc/platforms/powernv/memtrace.c

Apart from that, there are not other users in the tree.

Cc: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Cc: Paul Mackerras <paulus@samba.org>
Cc: Michael Ellerman <mpe@ellerman.id.au>
Cc: "Rafael J. Wysocki" <rjw@rjwysocki.net>
Cc: Len Brown <lenb@kernel.org>
Cc: Rashmica Gupta <rashmica.g@gmail.com>
Cc: Michael Neuling <mikey@neuling.org>
Cc: Balbir Singh <bsingharora@gmail.com>
Cc: Nathan Fontenot <nfont@linux.vnet.ibm.com>
Cc: John Allen <jallen@linux.vnet.ibm.com>
Cc: Andrew Morton <akpm@linux-foundation.org>
Cc: Michal Hocko <mhocko@suse.com>
Cc: Dan Williams <dan.j.williams@intel.com>
Cc: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Cc: Vlastimil Babka <vbabka@suse.cz>
Cc: Pavel Tatashin <pasha.tatashin@oracle.com>
Cc: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Cc: Oscar Salvador <osalvador@suse.de>
Cc: YASUAKI ISHIMATSU <yasu.isimatu@gmail.com>
Cc: Mathieu Malaterre <malat@debian.org>
Reviewed-by: Pavel Tatashin <pavel.tatashin@microsoft.com>
Reviewed-by: Rafael J. Wysocki <rafael.j.wysocki@intel.com>
Reviewed-by: Rashmica Gupta <rashmica.g@gmail.com>
Signed-off-by: David Hildenbrand <david@redhat.com>
---
 arch/powerpc/platforms/powernv/memtrace.c       | 2 +-
 arch/powerpc/platforms/pseries/hotplug-memory.c | 6 +++---
 drivers/acpi/acpi_memhotplug.c                  | 2 +-
 include/linux/memory_hotplug.h                  | 3 ++-
 mm/memory_hotplug.c                             | 9 ++++++++-
 5 files changed, 15 insertions(+), 7 deletions(-)

diff --git a/arch/powerpc/platforms/powernv/memtrace.c b/arch/powerpc/platforms/powernv/memtrace.c
index a29fdf8a2e56..773623f6bfb1 100644
--- a/arch/powerpc/platforms/powernv/memtrace.c
+++ b/arch/powerpc/platforms/powernv/memtrace.c
@@ -121,7 +121,7 @@ static u64 memtrace_alloc_node(u32 nid, u64 size)
 			lock_device_hotplug();
 			end_pfn = base_pfn + nr_pages;
 			for (pfn = base_pfn; pfn < end_pfn; pfn += bytes>> PAGE_SHIFT) {
-				remove_memory(nid, pfn << PAGE_SHIFT, bytes);
+				__remove_memory(nid, pfn << PAGE_SHIFT, bytes);
 			}
 			unlock_device_hotplug();
 			return base_pfn << PAGE_SHIFT;
diff --git a/arch/powerpc/platforms/pseries/hotplug-memory.c b/arch/powerpc/platforms/pseries/hotplug-memory.c
index 9a15d39995e5..dd0264c43f3e 100644
--- a/arch/powerpc/platforms/pseries/hotplug-memory.c
+++ b/arch/powerpc/platforms/pseries/hotplug-memory.c
@@ -305,7 +305,7 @@ static int pseries_remove_memblock(unsigned long base, unsigned int memblock_siz
 	nid = memory_add_physaddr_to_nid(base);
 
 	for (i = 0; i < sections_per_block; i++) {
-		remove_memory(nid, base, MIN_MEMORY_BLOCK_SIZE);
+		__remove_memory(nid, base, MIN_MEMORY_BLOCK_SIZE);
 		base += MIN_MEMORY_BLOCK_SIZE;
 	}
 
@@ -394,7 +394,7 @@ static int dlpar_remove_lmb(struct drmem_lmb *lmb)
 	block_sz = pseries_memory_block_size();
 	nid = memory_add_physaddr_to_nid(lmb->base_addr);
 
-	remove_memory(nid, lmb->base_addr, block_sz);
+	__remove_memory(nid, lmb->base_addr, block_sz);
 
 	/* Update memory regions for memory remove */
 	memblock_remove(lmb->base_addr, block_sz);
@@ -681,7 +681,7 @@ static int dlpar_add_lmb(struct drmem_lmb *lmb)
 
 	rc = dlpar_online_lmb(lmb);
 	if (rc) {
-		remove_memory(nid, lmb->base_addr, block_sz);
+		__remove_memory(nid, lmb->base_addr, block_sz);
 		invalidate_lmb_associativity_index(lmb);
 	} else {
 		lmb->flags |= DRCONF_MEM_ASSIGNED;
diff --git a/drivers/acpi/acpi_memhotplug.c b/drivers/acpi/acpi_memhotplug.c
index 6b0d3ef7309c..811148415993 100644
--- a/drivers/acpi/acpi_memhotplug.c
+++ b/drivers/acpi/acpi_memhotplug.c
@@ -282,7 +282,7 @@ static void acpi_memory_remove_memory(struct acpi_memory_device *mem_device)
 			nid = memory_add_physaddr_to_nid(info->start_addr);
 
 		acpi_unbind_memory_blocks(info);
-		remove_memory(nid, info->start_addr, info->length);
+		__remove_memory(nid, info->start_addr, info->length);
 		list_del(&info->list);
 		kfree(info);
 	}
diff --git a/include/linux/memory_hotplug.h b/include/linux/memory_hotplug.h
index 34a28227068d..1f096852f479 100644
--- a/include/linux/memory_hotplug.h
+++ b/include/linux/memory_hotplug.h
@@ -301,6 +301,7 @@ extern bool is_mem_section_removable(unsigned long pfn, unsigned long nr_pages);
 extern void try_offline_node(int nid);
 extern int offline_pages(unsigned long start_pfn, unsigned long nr_pages);
 extern void remove_memory(int nid, u64 start, u64 size);
+extern void __remove_memory(int nid, u64 start, u64 size);
 
 #else
 static inline bool is_mem_section_removable(unsigned long pfn,
@@ -317,6 +318,7 @@ static inline int offline_pages(unsigned long start_pfn, unsigned long nr_pages)
 }
 
 static inline void remove_memory(int nid, u64 start, u64 size) {}
+static inline void __remove_memory(int nid, u64 start, u64 size) {}
 #endif /* CONFIG_MEMORY_HOTREMOVE */
 
 extern void __ref free_area_init_core_hotplug(int nid);
@@ -330,7 +332,6 @@ extern void move_pfn_range_to_zone(struct zone *zone, unsigned long start_pfn,
 		unsigned long nr_pages, struct vmem_altmap *altmap);
 extern int offline_pages(unsigned long start_pfn, unsigned long nr_pages);
 extern bool is_memblock_offlined(struct memory_block *mem);
-extern void remove_memory(int nid, u64 start, u64 size);
 extern int sparse_add_one_section(struct pglist_data *pgdat,
 		unsigned long start_pfn, struct vmem_altmap *altmap);
 extern void sparse_remove_one_section(struct zone *zone, struct mem_section *ms,
diff --git a/mm/memory_hotplug.c b/mm/memory_hotplug.c
index 2698664bfd54..f6dbd5d8fffd 100644
--- a/mm/memory_hotplug.c
+++ b/mm/memory_hotplug.c
@@ -1839,7 +1839,7 @@ EXPORT_SYMBOL(try_offline_node);
  * and online/offline operations before this call, as required by
  * try_offline_node().
  */
-void __ref remove_memory(int nid, u64 start, u64 size)
+void __ref __remove_memory(int nid, u64 start, u64 size)
 {
 	int ret;
 
@@ -1868,5 +1868,12 @@ void __ref remove_memory(int nid, u64 start, u64 size)
 
 	mem_hotplug_done();
 }
+
+void remove_memory(int nid, u64 start, u64 size)
+{
+	lock_device_hotplug();
+	__remove_memory(nid, start, size);
+	unlock_device_hotplug();
+}
 EXPORT_SYMBOL_GPL(remove_memory);
 #endif /* CONFIG_MEMORY_HOTREMOVE */
-- 
2.17.1
