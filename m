Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx171.postini.com [74.125.245.171])
	by kanga.kvack.org (Postfix) with SMTP id 6D25F6B0074
	for <linux-mm@kvack.org>; Tue,  3 Jul 2012 01:58:43 -0400 (EDT)
Received: from m1.gw.fujitsu.co.jp (unknown [10.0.50.71])
	by fgwmail5.fujitsu.co.jp (Postfix) with ESMTP id F30CD3EE0C3
	for <linux-mm@kvack.org>; Tue,  3 Jul 2012 14:58:41 +0900 (JST)
Received: from smail (m1 [127.0.0.1])
	by outgoing.m1.gw.fujitsu.co.jp (Postfix) with ESMTP id D5AA745DE55
	for <linux-mm@kvack.org>; Tue,  3 Jul 2012 14:58:41 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (s1.gw.fujitsu.co.jp [10.0.50.91])
	by m1.gw.fujitsu.co.jp (Postfix) with ESMTP id A11E345DE58
	for <linux-mm@kvack.org>; Tue,  3 Jul 2012 14:58:41 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id 82DA61DB805A
	for <linux-mm@kvack.org>; Tue,  3 Jul 2012 14:58:41 +0900 (JST)
Received: from g01jpexchyt09.g01.fujitsu.local (g01jpexchyt09.g01.fujitsu.local [10.128.194.48])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id 0A0F91DB8054
	for <linux-mm@kvack.org>; Tue,  3 Jul 2012 14:58:41 +0900 (JST)
Message-ID: <4FF28A02.6060802@jp.fujitsu.com>
Date: Tue, 3 Jul 2012 14:58:26 +0900
From: Yasuaki Ishimatsu <isimatu.yasuaki@jp.fujitsu.com>
MIME-Version: 1.0
Subject: [RFC PATCH v2 5/13] memory-hotplug : does not release memory region
 in PAGES_PER_SECTION chunks
References: <4FF287C3.4030901@jp.fujitsu.com>
In-Reply-To: <4FF287C3.4030901@jp.fujitsu.com>
Content-Type: text/plain; charset="ISO-2022-JP"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, linux-kernel@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, linux-acpi@vger.kernel.org
Cc: rientjes@google.com, liuj97@gmail.com, len.brown@intel.com, benh@kernel.crashing.org, paulus@samba.org, cl@linux.com, minchan.kim@gmail.com, akpm@linux-foundation.org, kosaki.motohiro@jp.fujitsu.com

Since applying a patch(de7f0cba96786c), release_mem_region() has been changed
as called in PAGES_PER_SECTION chunks because register_memory_resource() is
called in PAGES_PER_SECTION chunks by add_memory(). But it seems firmware
dependency. If CRS are written in the PAGES_PER_SECTION chunks in ACPI DSDT
Table, register_memory_resource() is called in PAGES_PER_SECTION chunks.
But if CRS are written in the DIMM unit in ACPI DSDT Table,
register_memory_resource() is called in DIMM unit. So release_mem_region()
should not be called in PAGES_PER_SECTION chunks. The patch fixes it.

CC: David Rientjes <rientjes@google.com>
CC: Jiang Liu <liuj97@gmail.com>
CC: Len Brown <len.brown@intel.com>
CC: Benjamin Herrenschmidt <benh@kernel.crashing.org>
CC: Paul Mackerras <paulus@samba.org>
CC: Christoph Lameter <cl@linux.com>
Cc: Minchan Kim <minchan.kim@gmail.com>
CC: Andrew Morton <akpm@linux-foundation.org>
CC: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Signed-off-by: Yasuaki Ishimatsu <isimatu.yasuaki@jp.fujitsu.com>

---
 arch/powerpc/platforms/pseries/hotplug-memory.c |   13 +++++++++----
 mm/memory_hotplug.c                             |    4 ++--
 2 files changed, 11 insertions(+), 6 deletions(-)

Index: linux-3.5-rc4/mm/memory_hotplug.c
===================================================================
--- linux-3.5-rc4.orig/mm/memory_hotplug.c	2012-07-03 14:22:03.549198802 +0900
+++ linux-3.5-rc4/mm/memory_hotplug.c	2012-07-03 14:22:05.919169458 +0900
@@ -358,11 +358,11 @@ int __remove_pages(struct zone *zone, un
 	BUG_ON(phys_start_pfn & ~PAGE_SECTION_MASK);
 	BUG_ON(nr_pages % PAGES_PER_SECTION);

+	release_mem_region(phys_start_pfn << PAGE_SHIFT,  nr_pages * PAGE_SIZE);
+
 	sections_to_remove = nr_pages / PAGES_PER_SECTION;
 	for (i = 0; i < sections_to_remove; i++) {
 		unsigned long pfn = phys_start_pfn + i*PAGES_PER_SECTION;
-		release_mem_region(pfn << PAGE_SHIFT,
-				   PAGES_PER_SECTION << PAGE_SHIFT);
 		ret = __remove_section(zone, __pfn_to_section(pfn));
 		if (ret)
 			break;
Index: linux-3.5-rc4/arch/powerpc/platforms/pseries/hotplug-memory.c
===================================================================
--- linux-3.5-rc4.orig/arch/powerpc/platforms/pseries/hotplug-memory.c	2012-07-03 14:21:45.641422678
+0900
+++ linux-3.5-rc4/arch/powerpc/platforms/pseries/hotplug-memory.c	2012-07-03 14:22:05.920169437 +0900
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

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
