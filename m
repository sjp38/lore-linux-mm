Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx134.postini.com [74.125.245.134])
	by kanga.kvack.org (Postfix) with SMTP id 4AD146B0093
	for <linux-mm@kvack.org>; Thu,  4 Oct 2012 22:30:15 -0400 (EDT)
Received: from m2.gw.fujitsu.co.jp (unknown [10.0.50.72])
	by fgwmail5.fujitsu.co.jp (Postfix) with ESMTP id 9D0183EE0C3
	for <linux-mm@kvack.org>; Fri,  5 Oct 2012 11:30:13 +0900 (JST)
Received: from smail (m2 [127.0.0.1])
	by outgoing.m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 80C2145DE59
	for <linux-mm@kvack.org>; Fri,  5 Oct 2012 11:30:13 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (s2.gw.fujitsu.co.jp [10.0.50.92])
	by m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 6201B45DE52
	for <linux-mm@kvack.org>; Fri,  5 Oct 2012 11:30:13 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 4B279E18008
	for <linux-mm@kvack.org>; Fri,  5 Oct 2012 11:30:13 +0900 (JST)
Received: from g01jpexchkw06.g01.fujitsu.local (g01jpexchkw06.g01.fujitsu.local [10.0.194.45])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 00F74E08002
	for <linux-mm@kvack.org>; Fri,  5 Oct 2012 11:30:12 +0900 (JST)
Message-ID: <506E4616.10904@jp.fujitsu.com>
Date: Fri, 5 Oct 2012 11:29:42 +0900
From: Yasuaki Ishimatsu <isimatu.yasuaki@jp.fujitsu.com>
MIME-Version: 1.0
Subject: [PATCH 3/10] memory-hotplug : introduce new function arch_remove_memory()
 for removing page table depends on architecture
References: <506E43E0.70507@jp.fujitsu.com>
In-Reply-To: <506E43E0.70507@jp.fujitsu.com>
Content-Type: text/plain; charset="ISO-2022-JP"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: x86@kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, linux-acpi@vger.kernel.org, linux-s390@vger.kernel.org, linux-sh@vger.kernel.org, linux-ia64@vger.kernel.org, cmetcalf@tilera.com, sparclinux@vger.kernel.org
Cc: Yasuaki Ishimatsu <isimatu.yasuaki@jp.fujitsu.com>, rientjes@google.com, liuj97@gmail.com, len.brown@intel.com, cl@linux.com, minchan.kim@gmail.com, akpm@linux-foundation.org, kosaki.motohiro@jp.fujitsu.com, wency@cn.fujitsu.com

From: Wen Congyang <wency@cn.fujitsu.com>

For removing memory, we need to remove page table. But it depends
on architecture. So the patch introduce arch_remove_memory() for
removing page table. Now it only calls __remove_pages().

Note: __remove_pages() for some archtecuture is not implemented
      (I don't know how to implement it for s390).

CC: David Rientjes <rientjes@google.com>
CC: Jiang Liu <liuj97@gmail.com>
CC: Len Brown <len.brown@intel.com>
CC: Benjamin Herrenschmidt <benh@kernel.crashing.org>
CC: Paul Mackerras <paulus@samba.org>
CC: Christoph Lameter <cl@linux.com>
Cc: Minchan Kim <minchan.kim@gmail.com>
CC: Andrew Morton <akpm@linux-foundation.org>
CC: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
CC: Yasuaki Ishimatsu <isimatu.yasuaki@jp.fujitsu.com>
Signed-off-by: Wen Congyang <wency@cn.fujitsu.com>
---
 arch/ia64/mm/init.c            |   18 ++++++++++++++++++
 arch/powerpc/mm/mem.c          |   12 ++++++++++++
 arch/s390/mm/init.c            |   12 ++++++++++++
 arch/sh/mm/init.c              |   17 +++++++++++++++++
 arch/tile/mm/init.c            |    8 ++++++++
 arch/x86/mm/init_32.c          |   12 ++++++++++++
 arch/x86/mm/init_64.c          |   15 +++++++++++++++
 include/linux/memory_hotplug.h |    1 +
 mm/memory_hotplug.c            |    1 +
 9 files changed, 96 insertions(+)

Index: linux-3.6/arch/ia64/mm/init.c
===================================================================
--- linux-3.6.orig/arch/ia64/mm/init.c	2012-10-04 18:27:03.082498276 +0900
+++ linux-3.6/arch/ia64/mm/init.c	2012-10-04 18:28:50.087606867 +0900
@@ -688,6 +688,24 @@ int arch_add_memory(int nid, u64 start, 
 
 	return ret;
 }
+
+#ifdef CONFIG_MEMORY_HOTREMOVE
+int arch_remove_memory(u64 start, u64 size)
+{
+	unsigned long start_pfn = start >> PAGE_SHIFT;
+	unsigned long nr_pages = size >> PAGE_SHIFT;
+	struct zone *zone;
+	int ret;
+
+	zone = page_zone(pfn_to_page(start_pfn));
+	ret = __remove_pages(zone, start_pfn, nr_pages);
+	if (ret)
+		pr_warn("%s: Problem encountered in __remove_pages() as"
+			" ret=%d\n", __func__,  ret);
+
+	return ret;
+}
+#endif
 #endif
 
 /*
Index: linux-3.6/arch/powerpc/mm/mem.c
===================================================================
--- linux-3.6.orig/arch/powerpc/mm/mem.c	2012-10-04 18:27:03.084498278 +0900
+++ linux-3.6/arch/powerpc/mm/mem.c	2012-10-04 18:28:50.094606874 +0900
@@ -133,6 +133,18 @@ int arch_add_memory(int nid, u64 start, 
 
 	return __add_pages(nid, zone, start_pfn, nr_pages);
 }
+
+#ifdef CONFIG_MEMORY_HOTREMOVE
+int arch_remove_memory(u64 start, u64 size)
+{
+	unsigned long start_pfn = start >> PAGE_SHIFT;
+	unsigned long nr_pages = size >> PAGE_SHIFT;
+	struct zone *zone;
+
+	zone = page_zone(pfn_to_page(start_pfn));
+	return __remove_pages(zone, start_pfn, nr_pages);
+}
+#endif
 #endif /* CONFIG_MEMORY_HOTPLUG */
 
 /*
Index: linux-3.6/arch/s390/mm/init.c
===================================================================
--- linux-3.6.orig/arch/s390/mm/init.c	2012-10-04 18:27:03.080498274 +0900
+++ linux-3.6/arch/s390/mm/init.c	2012-10-04 18:28:50.104606884 +0900
@@ -257,4 +257,16 @@ int arch_add_memory(int nid, u64 start, 
 		vmem_remove_mapping(start, size);
 	return rc;
 }
+
+#ifdef CONFIG_MEMORY_HOTREMOVE
+int arch_remove_memory(u64 start, u64 size)
+{
+	/*
+	 * There is no hardware or firmware interface which could trigger a
+	 * hot memory remove on s390. So there is nothing that needs to be
+	 * implemented.
+	 */
+	return -EBUSY;
+}
+#endif
 #endif /* CONFIG_MEMORY_HOTPLUG */
Index: linux-3.6/arch/sh/mm/init.c
===================================================================
--- linux-3.6.orig/arch/sh/mm/init.c	2012-10-04 18:27:03.091498285 +0900
+++ linux-3.6/arch/sh/mm/init.c	2012-10-04 18:28:50.116606897 +0900
@@ -558,4 +558,21 @@ int memory_add_physaddr_to_nid(u64 addr)
 EXPORT_SYMBOL_GPL(memory_add_physaddr_to_nid);
 #endif
 
+#ifdef CONFIG_MEMORY_HOTREMOVE
+int arch_remove_memory(u64 start, u64 size)
+{
+	unsigned long start_pfn = start >> PAGE_SHIFT;
+	unsigned long nr_pages = size >> PAGE_SHIFT;
+	struct zone *zone;
+	int ret;
+
+	zone = page_zone(pfn_to_page(start_pfn));
+	ret = __remove_pages(zone, start_pfn, nr_pages);
+	if (unlikely(ret))
+		pr_warn("%s: Failed, __remove_pages() == %d\n", __func__,
+			ret);
+
+	return ret;
+}
+#endif
 #endif /* CONFIG_MEMORY_HOTPLUG */
Index: linux-3.6/arch/tile/mm/init.c
===================================================================
--- linux-3.6.orig/arch/tile/mm/init.c	2012-10-04 18:27:03.078498272 +0900
+++ linux-3.6/arch/tile/mm/init.c	2012-10-04 18:28:50.122606903 +0900
@@ -935,6 +935,14 @@ int remove_memory(u64 start, u64 size)
 {
 	return -EINVAL;
 }
+
+#ifdef CONFIG_MEMORY_HOTREMOVE
+int arch_remove_memory(u64 start, u64 size)
+{
+	/* TODO */
+	return -EBUSY;
+}
+#endif
 #endif
 
 struct kmem_cache *pgd_cache;
Index: linux-3.6/arch/x86/mm/init_32.c
===================================================================
--- linux-3.6.orig/arch/x86/mm/init_32.c	2012-10-04 18:27:03.089498283 +0900
+++ linux-3.6/arch/x86/mm/init_32.c	2012-10-04 18:28:50.128606909 +0900
@@ -842,6 +842,18 @@ int arch_add_memory(int nid, u64 start, 
 
 	return __add_pages(nid, zone, start_pfn, nr_pages);
 }
+
+#ifdef CONFIG_MEMORY_HOTREMOVE
+int arch_remove_memory(u64 start, u64 size)
+{
+	unsigned long start_pfn = start >> PAGE_SHIFT;
+	unsigned long nr_pages = size >> PAGE_SHIFT;
+	struct zone *zone;
+
+	zone = page_zone(pfn_to_page(start_pfn));
+	return __remove_pages(zone, start_pfn, nr_pages);
+}
+#endif
 #endif
 
 /*
Index: linux-3.6/arch/x86/mm/init_64.c
===================================================================
--- linux-3.6.orig/arch/x86/mm/init_64.c	2012-10-04 18:27:03.086498280 +0900
+++ linux-3.6/arch/x86/mm/init_64.c	2012-10-04 18:28:50.132606913 +0900
@@ -675,6 +675,21 @@ int arch_add_memory(int nid, u64 start, 
 }
 EXPORT_SYMBOL_GPL(arch_add_memory);
 
+#ifdef CONFIG_MEMORY_HOTREMOVE
+int __ref arch_remove_memory(u64 start, u64 size)
+{
+	unsigned long start_pfn = start >> PAGE_SHIFT;
+	unsigned long nr_pages = size >> PAGE_SHIFT;
+	struct zone *zone;
+	int ret;
+
+	zone = page_zone(pfn_to_page(start_pfn));
+	ret = __remove_pages(zone, start_pfn, nr_pages);
+	WARN_ON_ONCE(ret);
+
+	return ret;
+}
+#endif
 #endif /* CONFIG_MEMORY_HOTPLUG */
 
 static struct kcore_list kcore_vsyscall;
Index: linux-3.6/include/linux/memory_hotplug.h
===================================================================
--- linux-3.6.orig/include/linux/memory_hotplug.h	2012-10-04 18:27:03.094498288 +0900
+++ linux-3.6/include/linux/memory_hotplug.h	2012-10-04 18:28:50.137606918 +0900
@@ -85,6 +85,7 @@ extern void __online_page_free(struct pa
 
 #ifdef CONFIG_MEMORY_HOTREMOVE
 extern bool is_pageblock_removable_nolock(struct page *page);
+extern int arch_remove_memory(u64 start, u64 size);
 #endif /* CONFIG_MEMORY_HOTREMOVE */
 
 /* reasonably generic interface to expand the physical pages in a zone  */
Index: linux-3.6/mm/memory_hotplug.c
===================================================================
--- linux-3.6.orig/mm/memory_hotplug.c	2012-10-04 18:28:42.851599524 +0900
+++ linux-3.6/mm/memory_hotplug.c	2012-10-04 18:29:50.577668254 +0900
@@ -1062,6 +1062,7 @@ int __ref remove_memory(int nid, u64 sta
 	/* remove memmap entry */
 	firmware_map_remove(start, start + size, "System RAM");
 
+	arch_remove_memory(start, size);
 out:
 	unlock_memory_hotplug();
 	return ret;

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
