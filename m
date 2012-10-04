Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx127.postini.com [74.125.245.127])
	by kanga.kvack.org (Postfix) with SMTP id 91D4F6B00EF
	for <linux-mm@kvack.org>; Thu,  4 Oct 2012 01:31:43 -0400 (EDT)
Received: from m1.gw.fujitsu.co.jp (unknown [10.0.50.71])
	by fgwmail5.fujitsu.co.jp (Postfix) with ESMTP id 986003EE0C0
	for <linux-mm@kvack.org>; Thu,  4 Oct 2012 14:31:41 +0900 (JST)
Received: from smail (m1 [127.0.0.1])
	by outgoing.m1.gw.fujitsu.co.jp (Postfix) with ESMTP id 788D645DE5D
	for <linux-mm@kvack.org>; Thu,  4 Oct 2012 14:31:41 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (s1.gw.fujitsu.co.jp [10.0.50.91])
	by m1.gw.fujitsu.co.jp (Postfix) with ESMTP id 507C145DE63
	for <linux-mm@kvack.org>; Thu,  4 Oct 2012 14:31:41 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id 40A041DB804B
	for <linux-mm@kvack.org>; Thu,  4 Oct 2012 14:31:41 +0900 (JST)
Received: from G01JPEXCHKW23.g01.fujitsu.local (G01JPEXCHKW23.g01.fujitsu.local [10.0.193.106])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id EB007E08004
	for <linux-mm@kvack.org>; Thu,  4 Oct 2012 14:31:40 +0900 (JST)
Message-ID: <506D1F1D.9000301@jp.fujitsu.com>
Date: Thu, 4 Oct 2012 14:31:09 +0900
From: Yasuaki Ishimatsu <isimatu.yasuaki@jp.fujitsu.com>
MIME-Version: 1.0
Subject: memory-hotplug : suppres "Trying to free nonexistent resource <XXXXXXXXXXXXXXXX-YYYYYYYYYYYYYYYY>"
 warning
Content-Type: text/plain; charset="ISO-2022-JP"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: x86@kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, linux-acpi@vger.kernel.org
Cc: rientjes@google.com, liuj97@gmail.com, len.brown@intel.com, benh@kernel.crashing.org, paulus@samba.org, cl@linux.com, minchan.kim@gmail.com, akpm@linux-foundation.org, kosaki.motohiro@jp.fujitsu.com, wency@cn.fujitsu.com

When our x86 box calls __remove_pages(), release_mem_region() shows
many warnings. And x86 box cannot unregister iomem_resource.

"Trying to free nonexistent resource <XXXXXXXXXXXXXXXX-YYYYYYYYYYYYYYYY>"

release_mem_region() has been changed as called in each PAGES_PER_SECTION
chunk since applying a patch(de7f0cba96786c). Because powerpc registers
iomem_resource in each PAGES_PER_SECTION chunk. But when I hot add memory
on x86 box, iomem_resource is register in each _CRS not PAGES_PER_SECTION
chunk. So x86 box unregisters iomem_resource.

The patch fixes the problem.

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
 arch/powerpc/platforms/pseries/hotplug-memory.c |   13 +++++++++----
 mm/memory_hotplug.c                             |    4 ++--
 2 files changed, 11 insertions(+), 6 deletions(-)

Index: linux-3.6/arch/powerpc/platforms/pseries/hotplug-memory.c
===================================================================
--- linux-3.6.orig/arch/powerpc/platforms/pseries/hotplug-memory.c	2012-10-04 14:22:59.833520792 +0900
+++ linux-3.6/arch/powerpc/platforms/pseries/hotplug-memory.c	2012-10-04 14:23:05.150521411 +0900
@@ -77,7 +77,8 @@ static int pseries_remove_memblock(unsig
 {
 	unsigned long start, start_pfn;
 	struct zone *zone;
-	int ret;
+	int i, ret;
+	int sections_to_remove;
 
 	start_pfn = base >> PAGE_SHIFT;
 
@@ -97,9 +98,13 @@ static int pseries_remove_memblock(unsig
 	 * to sysfs "state" file and we can't remove sysfs entries
 	 * while writing to it. So we have to defer it to here.
 	 */
-	ret = __remove_pages(zone, start_pfn, memblock_size >> PAGE_SHIFT);
-	if (ret)
-		return ret;
+	sections_to_remove = (memblock_size >> PAGE_SHIFT) / PAGES_PER_SECTION;
+	for (i = 0; i < sections_to_remove; i++) {
+		unsigned long pfn = start_pfn + i * PAGES_PER_SECTION;
+		ret = __remove_pages(zone, start_pfn,  PAGES_PER_SECTION);
+		if (ret)
+			return ret;
+	}
 
 	/*
 	 * Update memory regions for memory remove
Index: linux-3.6/mm/memory_hotplug.c
===================================================================
--- linux-3.6.orig/mm/memory_hotplug.c	2012-10-04 14:22:59.829520788 +0900
+++ linux-3.6/mm/memory_hotplug.c	2012-10-04 14:23:25.860527278 +0900
@@ -362,11 +362,11 @@ int __remove_pages(struct zone *zone, un
 	BUG_ON(phys_start_pfn & ~PAGE_SECTION_MASK);
 	BUG_ON(nr_pages % PAGES_PER_SECTION);
 
+	release_mem_region(phys_start_pfn << PAGE_SHIFT, nr_pages * PAGE_SIZE);
+
 	sections_to_remove = nr_pages / PAGES_PER_SECTION;
 	for (i = 0; i < sections_to_remove; i++) {
 		unsigned long pfn = phys_start_pfn + i*PAGES_PER_SECTION;
-		release_mem_region(pfn << PAGE_SHIFT,
-				   PAGES_PER_SECTION << PAGE_SHIFT);
 		ret = __remove_section(zone, __pfn_to_section(pfn));
 		if (ret)
 			break;

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
