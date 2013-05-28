Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx160.postini.com [74.125.245.160])
	by kanga.kvack.org (Postfix) with SMTP id 941686B0089
	for <linux-mm@kvack.org>; Tue, 28 May 2013 19:23:57 -0400 (EDT)
From: "Rafael J. Wysocki" <rjw@sisk.pl>
Subject: [PATCH] Memory hotplug: Move alternative function definitions to header
Date: Wed, 29 May 2013 01:32:39 +0200
Message-ID: <3399422.RK6bMrAa5x@vostro.rjw.lan>
MIME-Version: 1.0
Content-Transfer-Encoding: 7Bit
Content-Type: text/plain; charset="utf-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: ACPI Devel Maling List <linux-acpi@vger.kernel.org>
Cc: LKML <linux-kernel@vger.kernel.org>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Toshi Kani <toshi.kani@hp.com>, Wen Congyang <wency@cn.fujitsu.com>, Tang Chen <tangchen@cn.fujitsu.com>, Yasuaki Ishimatsu <isimatu.yasuaki@jp.fujitsu.com>, Andrew Morton <akpm@linux-foundation.org>, Jiang Liu <liuj97@gmail.com>, Vasilis Liaskovitis <vasilis.liaskovitis@profitbricks.com>, linux-mm@kvack.org

From: Rafael J. Wysocki <rafael.j.wysocki@intel.com>

Move the definitions of offline_pages() and remove_memory()
for CONFIG_MEMORY_HOTREMOVE to memory_hotplug.h, where they belong,
and make them static inline.

Signed-off-by: Rafael J. Wysocki <rafael.j.wysocki@intel.com>
---

On top of the linux-next branch of the linux-pm.git tree.

Please let me know if there are any objections.

Thanks,
Rafael

---
 include/linux/memory_hotplug.h |    9 +++++++++
 mm/memory_hotplug.c            |    8 +-------
 2 files changed, 10 insertions(+), 7 deletions(-)

Index: linux-pm/include/linux/memory_hotplug.h
===================================================================
--- linux-pm.orig/include/linux/memory_hotplug.h
+++ linux-pm/include/linux/memory_hotplug.h
@@ -234,6 +234,8 @@ static inline void unlock_memory_hotplug
 
 extern int is_mem_section_removable(unsigned long pfn, unsigned long nr_pages);
 extern void try_offline_node(int nid);
+extern int offline_pages(unsigned long start_pfn, unsigned long nr_pages);
+extern void remove_memory(int nid, u64 start, u64 size);
 
 #else
 static inline int is_mem_section_removable(unsigned long pfn,
@@ -243,6 +245,13 @@ static inline int is_mem_section_removab
 }
 
 static inline void try_offline_node(int nid) {}
+
+static inline int offline_pages(unsigned long start_pfn, unsigned long nr_pages)
+{
+	return -EINVAL;
+}
+
+static inline void remove_memory(int nid, u64 start, u64 size) {}
 #endif /* CONFIG_MEMORY_HOTREMOVE */
 
 extern int walk_memory_range(unsigned long start_pfn, unsigned long end_pfn,
Index: linux-pm/mm/memory_hotplug.c
===================================================================
--- linux-pm.orig/mm/memory_hotplug.c
+++ linux-pm/mm/memory_hotplug.c
@@ -1825,11 +1825,5 @@ void __ref remove_memory(int nid, u64 st
 
 	unlock_memory_hotplug();
 }
-#else
-int offline_pages(unsigned long start_pfn, unsigned long nr_pages)
-{
-	return -EINVAL;
-}
-void remove_memory(int nid, u64 start, u64 size) {}
-#endif /* CONFIG_MEMORY_HOTREMOVE */
 EXPORT_SYMBOL_GPL(remove_memory);
+#endif /* CONFIG_MEMORY_HOTREMOVE */

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
