Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx133.postini.com [74.125.245.133])
	by kanga.kvack.org (Postfix) with SMTP id 303656B0070
	for <linux-mm@kvack.org>; Wed,  3 Oct 2012 06:03:12 -0400 (EDT)
Received: from m1.gw.fujitsu.co.jp (unknown [10.0.50.71])
	by fgwmail5.fujitsu.co.jp (Postfix) with ESMTP id 3DDC03EE081
	for <linux-mm@kvack.org>; Wed,  3 Oct 2012 19:03:10 +0900 (JST)
Received: from smail (m1 [127.0.0.1])
	by outgoing.m1.gw.fujitsu.co.jp (Postfix) with ESMTP id 2204C45DE56
	for <linux-mm@kvack.org>; Wed,  3 Oct 2012 19:03:10 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (s1.gw.fujitsu.co.jp [10.0.50.91])
	by m1.gw.fujitsu.co.jp (Postfix) with ESMTP id 03ACB45DE55
	for <linux-mm@kvack.org>; Wed,  3 Oct 2012 19:03:10 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id E9AC6E08002
	for <linux-mm@kvack.org>; Wed,  3 Oct 2012 19:03:09 +0900 (JST)
Received: from g01jpexchkw11.g01.fujitsu.local (g01jpexchkw11.g01.fujitsu.local [10.0.194.50])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id A17111DB8040
	for <linux-mm@kvack.org>; Wed,  3 Oct 2012 19:03:09 +0900 (JST)
Message-ID: <506C0D45.3050909@jp.fujitsu.com>
Date: Wed, 3 Oct 2012 19:02:45 +0900
From: Yasuaki Ishimatsu <isimatu.yasuaki@jp.fujitsu.com>
MIME-Version: 1.0
Subject: [PATCH 2/4] acpi,memory-hotplug : rename remove_memory() to offline_memory()
References: <506C0AE8.40702@jp.fujitsu.com>
In-Reply-To: <506C0AE8.40702@jp.fujitsu.com>
Content-Type: text/plain; charset="ISO-2022-JP"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: x86@kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, linux-acpi@vger.kernel.org
Cc: rientjes@google.com, liuj97@gmail.com, len.brown@intel.com, cl@linux.com, minchan.kim@gmail.com, akpm@linux-foundation.org, kosaki.motohiro@jp.fujitsu.com, wency@cn.fujitsu.com

From: Yasuaki Ishimatsu <isimatu.yasuaki@jp.fujitsu.com>

add_memory() hot adds a physical memory. But remove_memory does not
hot remove a phsical memory. It only offlines memory. The name
confuse us.

So the patch renames remove_memory() to offline_memory(). We will
use rename_memory() for hot removing memory.

CC: David Rientjes <rientjes@google.com>
CC: Jiang Liu <liuj97@gmail.com>
CC: Len Brown <len.brown@intel.com>
CC: Christoph Lameter <cl@linux.com>
Cc: Minchan Kim <minchan.kim@gmail.com>
CC: Andrew Morton <akpm@linux-foundation.org>
CC: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com> 
Signed-off-by: Yasuaki Ishimatsu <isimatu.yasuaki@jp.fujitsu.com>
Signed-off-by: Wen Congyang <wency@cn.fujitsu.com>
---
 drivers/acpi/acpi_memhotplug.c |    2 +-
 include/linux/memory_hotplug.h |    2 +-
 mm/memory_hotplug.c            |    6 +++---
 3 files changed, 5 insertions(+), 5 deletions(-)

Index: linux-3.6/drivers/acpi/acpi_memhotplug.c
===================================================================
--- linux-3.6.orig/drivers/acpi/acpi_memhotplug.c	2012-10-03 18:17:29.291244669 +0900
+++ linux-3.6/drivers/acpi/acpi_memhotplug.c	2012-10-03 18:17:41.494247869 +0900
@@ -316,7 +316,7 @@ acpi_memory_remove_memory(struct acpi_me
 		if (!info->enabled)
 			return -EBUSY;
 
-		result = remove_memory(info->start_addr, info->length);
+		result = offline_memory(info->start_addr, info->length);
 		if (result)
 			return result;
 
Index: linux-3.6/include/linux/memory_hotplug.h
===================================================================
--- linux-3.6.orig/include/linux/memory_hotplug.h	2012-10-03 18:17:01.863247694 +0900
+++ linux-3.6/include/linux/memory_hotplug.h	2012-10-03 18:17:41.496247872 +0900
@@ -236,7 +236,7 @@ extern int add_memory(int nid, u64 start
 extern int arch_add_memory(int nid, u64 start, u64 size);
 extern int offline_pages(unsigned long start_pfn, unsigned long nr_pages);
 extern int offline_memory_block(struct memory_block *mem);
-extern int remove_memory(u64 start, u64 size);
+extern int offline_memory(u64 start, u64 size);
 extern int sparse_add_one_section(struct zone *zone, unsigned long start_pfn,
 								int nr_pages);
 extern void sparse_remove_one_section(struct zone *zone, struct mem_section *ms);
Index: linux-3.6/mm/memory_hotplug.c
===================================================================
--- linux-3.6.orig/mm/memory_hotplug.c	2012-10-03 18:17:01.861247692 +0900
+++ linux-3.6/mm/memory_hotplug.c	2012-10-03 18:17:41.503247876 +0900
@@ -1003,7 +1003,7 @@ int offline_pages(unsigned long start_pf
 	return __offline_pages(start_pfn, start_pfn + nr_pages, 120 * HZ);
 }
 
-int remove_memory(u64 start, u64 size)
+int offline_memory(u64 start, u64 size)
 {
 	struct memory_block *mem = NULL;
 	struct mem_section *section;
@@ -1047,9 +1047,9 @@ int offline_pages(unsigned long start_pf
 {
 	return -EINVAL;
 }
-int remove_memory(u64 start, u64 size)
+int offline_memory(u64 start, u64 size)
 {
 	return -EINVAL;
 }
 #endif /* CONFIG_MEMORY_HOTREMOVE */
-EXPORT_SYMBOL_GPL(remove_memory);
+EXPORT_SYMBOL_GPL(offline_memory);

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
