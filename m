Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx164.postini.com [74.125.245.164])
	by kanga.kvack.org (Postfix) with SMTP id CC45A8D0003
	for <linux-mm@kvack.org>; Mon, 24 Dec 2012 07:10:27 -0500 (EST)
From: Tang Chen <tangchen@cn.fujitsu.com>
Subject: [PATCH v5 05/14] memory-hotplug: introduce new function arch_remove_memory() for removing page table depends on architecture
Date: Mon, 24 Dec 2012 20:09:15 +0800
Message-Id: <1356350964-13437-6-git-send-email-tangchen@cn.fujitsu.com>
In-Reply-To: <1356350964-13437-1-git-send-email-tangchen@cn.fujitsu.com>
References: <1356350964-13437-1-git-send-email-tangchen@cn.fujitsu.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org, rientjes@google.com, liuj97@gmail.com, len.brown@intel.com, benh@kernel.crashing.org, paulus@samba.org, cl@linux.com, minchan.kim@gmail.com, kosaki.motohiro@jp.fujitsu.com, isimatu.yasuaki@jp.fujitsu.com, wujianguo@huawei.com, wency@cn.fujitsu.com, tangchen@cn.fujitsu.com, hpa@zytor.com, linfeng@cn.fujitsu.com, laijs@cn.fujitsu.com, mgorman@suse.de, yinghai@kernel.org
Cc: x86@kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, linux-acpi@vger.kernel.org, linux-s390@vger.kernel.org, linux-sh@vger.kernel.org, linux-ia64@vger.kernel.org, cmetcalf@tilera.com, sparclinux@vger.kernel.org

From: Wen Congyang <wency@cn.fujitsu.com>

For removing memory, we need to remove page table. But it depends
on architecture. So the patch introduce arch_remove_memory() for
removing page table. Now it only calls __remove_pages().

Note: __remove_pages() for some archtecuture is not implemented
      (I don't know how to implement it for s390).

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
 mm/memory_hotplug.c            |    2 ++
 9 files changed, 97 insertions(+), 0 deletions(-)

diff --git a/arch/ia64/mm/init.c b/arch/ia64/mm/init.c
index 082e383..e333822 100644
--- a/arch/ia64/mm/init.c
+++ b/arch/ia64/mm/init.c
@@ -689,6 +689,24 @@ int arch_add_memory(int nid, u64 start, u64 size)
 
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
diff --git a/arch/powerpc/mm/mem.c b/arch/powerpc/mm/mem.c
index 0dba506..09c6451 100644
--- a/arch/powerpc/mm/mem.c
+++ b/arch/powerpc/mm/mem.c
@@ -133,6 +133,18 @@ int arch_add_memory(int nid, u64 start, u64 size)
 
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
diff --git a/arch/s390/mm/init.c b/arch/s390/mm/init.c
index ae672f4..49ce6bb 100644
--- a/arch/s390/mm/init.c
+++ b/arch/s390/mm/init.c
@@ -228,4 +228,16 @@ int arch_add_memory(int nid, u64 start, u64 size)
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
diff --git a/arch/sh/mm/init.c b/arch/sh/mm/init.c
index 82cc576..1057940 100644
--- a/arch/sh/mm/init.c
+++ b/arch/sh/mm/init.c
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
diff --git a/arch/tile/mm/init.c b/arch/tile/mm/init.c
index ef29d6c..2749515 100644
--- a/arch/tile/mm/init.c
+++ b/arch/tile/mm/init.c
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
diff --git a/arch/x86/mm/init_32.c b/arch/x86/mm/init_32.c
index 745d66b..3166e78 100644
--- a/arch/x86/mm/init_32.c
+++ b/arch/x86/mm/init_32.c
@@ -836,6 +836,18 @@ int arch_add_memory(int nid, u64 start, u64 size)
 
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
diff --git a/arch/x86/mm/init_64.c b/arch/x86/mm/init_64.c
index e779e0b..f78509c 100644
--- a/arch/x86/mm/init_64.c
+++ b/arch/x86/mm/init_64.c
@@ -682,6 +682,21 @@ int arch_add_memory(int nid, u64 start, u64 size)
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
diff --git a/include/linux/memory_hotplug.h b/include/linux/memory_hotplug.h
index 8dd0950..31a563b 100644
--- a/include/linux/memory_hotplug.h
+++ b/include/linux/memory_hotplug.h
@@ -96,6 +96,7 @@ extern void __online_page_free(struct page *page);
 
 #ifdef CONFIG_MEMORY_HOTREMOVE
 extern bool is_pageblock_removable_nolock(struct page *page);
+extern int arch_remove_memory(u64 start, u64 size);
 #endif /* CONFIG_MEMORY_HOTREMOVE */
 
 /* reasonably generic interface to expand the physical pages in a zone  */
diff --git a/mm/memory_hotplug.c b/mm/memory_hotplug.c
index 1f5b5bb..2c5d734 100644
--- a/mm/memory_hotplug.c
+++ b/mm/memory_hotplug.c
@@ -1487,6 +1487,8 @@ repeat:
 	/* remove memmap entry */
 	firmware_map_remove(start, start + size, "System RAM");
 
+	arch_remove_memory(start, size);
+
 	unlock_memory_hotplug();
 
 	return 0;
-- 
1.7.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
