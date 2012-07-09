Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx172.postini.com [74.125.245.172])
	by kanga.kvack.org (Postfix) with SMTP id BB1F06B0078
	for <linux-mm@kvack.org>; Mon,  9 Jul 2012 06:29:02 -0400 (EDT)
Received: from m3.gw.fujitsu.co.jp (unknown [10.0.50.73])
	by fgwmail5.fujitsu.co.jp (Postfix) with ESMTP id 5E4743EE0C1
	for <linux-mm@kvack.org>; Mon,  9 Jul 2012 19:29:01 +0900 (JST)
Received: from smail (m3 [127.0.0.1])
	by outgoing.m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 4334B45DE9E
	for <linux-mm@kvack.org>; Mon,  9 Jul 2012 19:29:01 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (s3.gw.fujitsu.co.jp [10.0.50.93])
	by m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 0827645DEB2
	for <linux-mm@kvack.org>; Mon,  9 Jul 2012 19:29:01 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id EA32C1DB8041
	for <linux-mm@kvack.org>; Mon,  9 Jul 2012 19:29:00 +0900 (JST)
Received: from g01jpexchyt10.g01.fujitsu.local (g01jpexchyt10.g01.fujitsu.local [10.128.194.49])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 95E4D1DB803E
	for <linux-mm@kvack.org>; Mon,  9 Jul 2012 19:29:00 +0900 (JST)
Message-ID: <4FFAB25B.6040101@jp.fujitsu.com>
Date: Mon, 9 Jul 2012 19:28:43 +0900
From: Yasuaki Ishimatsu <isimatu.yasuaki@jp.fujitsu.com>
MIME-Version: 1.0
Subject: [RFC PATCH v3 7/13] memory-hotplug : remove_memory calls __remove_pages
References: <4FFAB0A2.8070304@jp.fujitsu.com>
In-Reply-To: <4FFAB0A2.8070304@jp.fujitsu.com>
Content-Type: text/plain; charset="ISO-2022-JP"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, linux-kernel@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, linux-acpi@vger.kernel.org
Cc: rientjes@google.com, liuj97@gmail.com, len.brown@intel.com, benh@kernel.crashing.org, paulus@samba.org, cl@linux.com, minchan.kim@gmail.com, akpm@linux-foundation.org, kosaki.motohiro@jp.fujitsu.com, wency@cn.fujitsu.com

The patch adds __remove_pages() to remove_memory(). Then the range of
phys_start_pfn argument and nr_pages argument in __remove_pagse() may
have different zone. So zone argument is removed from __remove_pages()
and __remove_pages() caluculates zone in each section.

When CONFIG_SPARSEMEM_VMEMMAP is defined, there is no way to remove a memmap.
So __remove_section only calls unregister_memory_section().

CC: David Rientjes <rientjes@google.com>
CC: Jiang Liu <liuj97@gmail.com>
CC: Len Brown <len.brown@intel.com>
CC: Benjamin Herrenschmidt <benh@kernel.crashing.org>
CC: Paul Mackerras <paulus@samba.org>
CC: Christoph Lameter <cl@linux.com>
Cc: Minchan Kim <minchan.kim@gmail.com>
CC: Andrew Morton <akpm@linux-foundation.org>
CC: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
CC: Wen Congyang <wency@cn.fujitsu.com>
Signed-off-by: Yasuaki Ishimatsu <isimatu.yasuaki@jp.fujitsu.com>

---
 arch/powerpc/platforms/pseries/hotplug-memory.c |    5 +----
 include/linux/memory_hotplug.h                  |    3 +--
 mm/memory_hotplug.c                             |   20 +++++++++++++-------
 3 files changed, 15 insertions(+), 13 deletions(-)

Index: linux-3.5-rc4/mm/memory_hotplug.c
===================================================================
--- linux-3.5-rc4.orig/mm/memory_hotplug.c	2012-07-03 14:22:05.919169458 +0900
+++ linux-3.5-rc4/mm/memory_hotplug.c	2012-07-03 14:22:10.170116406 +0900
@@ -275,11 +275,14 @@ static int __meminit __add_section(int n
 #ifdef CONFIG_SPARSEMEM_VMEMMAP
 static int __remove_section(struct zone *zone, struct mem_section *ms)
 {
-	/*
-	 * XXX: Freeing memmap with vmemmap is not implement yet.
-	 *      This should be removed later.
-	 */
-	return -EBUSY;
+	int ret;
+
+	if (!valid_section(ms))
+		return ret;
+
+	ret = unregister_memory_section(ms);
+
+	return ret;
 }
 #else
 static int __remove_section(struct zone *zone, struct mem_section *ms)
@@ -346,11 +349,11 @@ EXPORT_SYMBOL_GPL(__add_pages);
  * sure that pages are marked reserved and zones are adjust properly by
  * calling offline_pages().
  */
-int __remove_pages(struct zone *zone, unsigned long phys_start_pfn,
-		 unsigned long nr_pages)
+int __remove_pages(unsigned long phys_start_pfn, unsigned long nr_pages)
 {
 	unsigned long i, ret = 0;
 	int sections_to_remove;
+	struct zone *zone;

 	/*
 	 * We can only remove entire sections
@@ -363,6 +366,7 @@ int __remove_pages(struct zone *zone, un
 	sections_to_remove = nr_pages / PAGES_PER_SECTION;
 	for (i = 0; i < sections_to_remove; i++) {
 		unsigned long pfn = phys_start_pfn + i*PAGES_PER_SECTION;
+		zone = page_zone(pfn_to_page(pfn));
 		ret = __remove_section(zone, __pfn_to_section(pfn));
 		if (ret)
 			break;
@@ -664,6 +668,8 @@ int remove_memory(int nid, u64 start, u6
 	lock_memory_hotplug();
 	/* remove memmap entry */
 	firmware_map_remove(start, start + size - 1, "System RAM");
+
+	__remove_pages(start >> PAGE_SHIFT, size >> PAGE_SHIFT);
 	unlock_memory_hotplug();
 	return 0;

Index: linux-3.5-rc4/include/linux/memory_hotplug.h
===================================================================
--- linux-3.5-rc4.orig/include/linux/memory_hotplug.h	2012-07-03 14:21:58.330264047 +0900
+++ linux-3.5-rc4/include/linux/memory_hotplug.h	2012-07-03 14:22:10.170116406 +0900
@@ -89,8 +89,7 @@ extern bool is_pageblock_removable_noloc
 /* reasonably generic interface to expand the physical pages in a zone  */
 extern int __add_pages(int nid, struct zone *zone, unsigned long start_pfn,
 	unsigned long nr_pages);
-extern int __remove_pages(struct zone *zone, unsigned long start_pfn,
-	unsigned long nr_pages);
+extern int __remove_pages(unsigned long start_pfn, unsigned long nr_pages);

 #ifdef CONFIG_NUMA
 extern int memory_add_physaddr_to_nid(u64 start);
Index: linux-3.5-rc4/arch/powerpc/platforms/pseries/hotplug-memory.c
===================================================================
--- linux-3.5-rc4.orig/arch/powerpc/platforms/pseries/hotplug-memory.c	2012-07-03 14:22:05.920169437
+0900
+++ linux-3.5-rc4/arch/powerpc/platforms/pseries/hotplug-memory.c	2012-07-03 14:22:10.172116353 +0900
@@ -76,7 +76,6 @@ unsigned long memory_block_size_bytes(vo
 static int pseries_remove_memblock(unsigned long base, unsigned int memblock_size)
 {
 	unsigned long start, start_pfn;
-	struct zone *zone;
 	int i, ret;
 	int sections_to_remove;

@@ -87,8 +86,6 @@ static int pseries_remove_memblock(unsig
 		return 0;
 	}

-	zone = page_zone(pfn_to_page(start_pfn));
-
 	/*
 	 * Remove section mappings and sysfs entries for the
 	 * section of the memory we are removing.
@@ -101,7 +98,7 @@ static int pseries_remove_memblock(unsig
 	sections_to_remove = (memblock_size >> PAGE_SHIFT) / PAGES_PER_SECTION;
 	for (i = 0; i < sections_to_remove; i++) {
 		unsigned long pfn = start_pfn + i * PAGES_PER_SECTION;
-		ret = __remove_pages(zone, start_pfn,  PAGES_PER_SECTION);
+		ret = __remove_pages(start_pfn,  PAGES_PER_SECTION);
 		if (ret)
 			return ret;
 	}

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
