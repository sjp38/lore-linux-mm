Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx195.postini.com [74.125.245.195])
	by kanga.kvack.org (Postfix) with SMTP id 317516B006E
	for <linux-mm@kvack.org>; Wed, 16 Jan 2013 03:15:30 -0500 (EST)
From: Lin Feng <linfeng@cn.fujitsu.com>
Subject: [PATCH v3 1/2] memory-hotplug: introduce CONFIG_HAVE_BOOTMEM_INFO_NODE and revert register_page_bootmem_info_node() when platform not support
Date: Wed, 16 Jan 2013 16:14:18 +0800
Message-Id: <1358324059-9608-2-git-send-email-linfeng@cn.fujitsu.com>
In-Reply-To: <1358324059-9608-1-git-send-email-linfeng@cn.fujitsu.com>
References: <1358324059-9608-1-git-send-email-linfeng@cn.fujitsu.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org, mhocko@suse.cz, linux-mm@kvack.org, tglx@linutronix.de, mingo@redhat.com, hpa@zytor.com, jbeulich@suse.com, dhowells@redhat.com, wency@cn.fujitsu.com, isimatu.yasuaki@jp.fujitsu.com, paul.gortmaker@windriver.com, laijs@cn.fujitsu.com, kamezawa.hiroyu@jp.fujitsu.com, mel@csn.ul.ie, minchan@kernel.org, aquini@redhat.com, jiang.liu@huawei.com, tony.luck@intel.com, fenghua.yu@intel.com, benh@kernel.crashing.org, paulus@samba.org, schwidefsky@de.ibm.com, heiko.carstens@de.ibm.com, davem@davemloft.net, michael@ellerman.id.au, gerald.schaefer@de.ibm.com, gregkh@linuxfoundation.org
Cc: x86@kernel.org, linux390@de.ibm.com, linux-ia64@vger.kernel.org, linux-s390@vger.kernel.org, sparclinux@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, linux-kernel@vger.kernel.org, linfeng@cn.fujitsu.com, tangchen@cn.fujitsu.com

It's implemented by adding a new Kconfig option named
CONFIG_HAVE_BOOTMEM_INFO_NODE, which will be automatically selected by
memory-hotplug feature fully supported archs(currently only on x86_64).

Reported-by: Michal Hocko <mhocko@suse.cz>
Signed-off-by: Lin Feng <linfeng@cn.fujitsu.com>
---
ChangeLog v2->v3:
- Rename the patch title to conform it's content.
- Update memory_hotplug.h and remove the misleading TODO pointed out by Michal.

ChangeLog v1->v2:
- Add a Kconfig option named HAVE_BOOTMEM_INFO_NODE suggested by Michal, which
  will be automatically selected by supported archs(currently only on x86_64).
---
 arch/x86/mm/init_64.c          |    2 +-
 include/linux/memory_hotplug.h |    6 ++++++
 mm/Kconfig                     |    8 ++++++++
 mm/memory_hotplug.c            |    2 ++
 4 files changed, 17 insertions(+), 1 deletions(-)

diff --git a/arch/x86/mm/init_64.c b/arch/x86/mm/init_64.c
index 07d6966..b539015 100644
--- a/arch/x86/mm/init_64.c
+++ b/arch/x86/mm/init_64.c
@@ -1317,7 +1317,7 @@ vmemmap_populate(struct page *start_page, unsigned long size, int node)
 	return 0;
 }
 
-#ifdef CONFIG_MEMORY_HOTPLUG_SPARSE
+#if defined(CONFIG_MEMORY_HOTPLUG_SPARSE) && defined(CONFIG_HAVE_BOOTMEM_INFO_NODE)
 void register_page_bootmem_memmap(unsigned long section_nr,
 				  struct page *start_page, unsigned long size)
 {
diff --git a/include/linux/memory_hotplug.h b/include/linux/memory_hotplug.h
index f60e728..69903cc 100644
--- a/include/linux/memory_hotplug.h
+++ b/include/linux/memory_hotplug.h
@@ -174,7 +174,13 @@ static inline void arch_refresh_nodedata(int nid, pg_data_t *pgdat)
 #endif /* CONFIG_NUMA */
 #endif /* CONFIG_HAVE_ARCH_NODEDATA_EXTENSION */
 
+#ifdef CONFIG_HAVE_BOOTMEM_INFO_NODE
 extern void register_page_bootmem_info_node(struct pglist_data *pgdat);
+#else
+static inline void register_page_bootmem_info_node(struct pglist_data *pgdat)
+{
+}
+#endif
 extern void put_page_bootmem(struct page *page);
 extern void get_page_bootmem(unsigned long ingo, struct page *page,
 			     unsigned long type);
diff --git a/mm/Kconfig b/mm/Kconfig
index 278e3ab..f8c5799 100644
--- a/mm/Kconfig
+++ b/mm/Kconfig
@@ -162,10 +162,18 @@ config MOVABLE_NODE
 	  Say Y here if you want to hotplug a whole node.
 	  Say N here if you want kernel to use memory on all nodes evenly.
 
+#
+# Only be set on architectures that have completely implemented memory hotplug
+# feature. If you are not sure, don't touch it.
+#
+config HAVE_BOOTMEM_INFO_NODE
+	def_bool n
+
 # eventually, we can have this option just 'select SPARSEMEM'
 config MEMORY_HOTPLUG
 	bool "Allow for memory hot-add"
 	select MEMORY_ISOLATION
+	select HAVE_BOOTMEM_INFO_NODE if X86_64
 	depends on SPARSEMEM || X86_64_ACPI_NUMA
 	depends on HOTPLUG && ARCH_ENABLE_MEMORY_HOTPLUG
 	depends on (IA64 || X86 || PPC_BOOK3S_64 || SUPERH || S390)
diff --git a/mm/memory_hotplug.c b/mm/memory_hotplug.c
index 8aa2b56..daf111f 100644
--- a/mm/memory_hotplug.c
+++ b/mm/memory_hotplug.c
@@ -189,6 +189,7 @@ static void register_page_bootmem_info_section(unsigned long start_pfn)
 }
 #endif
 
+#ifdef CONFIG_HAVE_BOOTMEM_INFO_NODE
 void register_page_bootmem_info_node(struct pglist_data *pgdat)
 {
 	unsigned long i, pfn, end_pfn, nr_pages;
@@ -230,6 +231,7 @@ void register_page_bootmem_info_node(struct pglist_data *pgdat)
 			register_page_bootmem_info_section(pfn);
 	}
 }
+#endif
 
 static void grow_zone_span(struct zone *zone, unsigned long start_pfn,
 			   unsigned long end_pfn)
-- 
1.7.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
