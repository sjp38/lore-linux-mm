Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx193.postini.com [74.125.245.193])
	by kanga.kvack.org (Postfix) with SMTP id 2A21F6B005A
	for <linux-mm@kvack.org>; Wed, 27 Jun 2012 01:43:14 -0400 (EDT)
Received: from m2.gw.fujitsu.co.jp (unknown [10.0.50.72])
	by fgwmail6.fujitsu.co.jp (Postfix) with ESMTP id F29A53EE0B6
	for <linux-mm@kvack.org>; Wed, 27 Jun 2012 14:43:11 +0900 (JST)
Received: from smail (m2 [127.0.0.1])
	by outgoing.m2.gw.fujitsu.co.jp (Postfix) with ESMTP id CD88D45DE54
	for <linux-mm@kvack.org>; Wed, 27 Jun 2012 14:43:11 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (s2.gw.fujitsu.co.jp [10.0.50.92])
	by m2.gw.fujitsu.co.jp (Postfix) with ESMTP id A261845DE4D
	for <linux-mm@kvack.org>; Wed, 27 Jun 2012 14:43:11 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 91F31E18005
	for <linux-mm@kvack.org>; Wed, 27 Jun 2012 14:43:11 +0900 (JST)
Received: from g01jpexchkw01.g01.fujitsu.local (g01jpexchkw01.g01.fujitsu.local [10.0.194.40])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 4C8381DB803A
	for <linux-mm@kvack.org>; Wed, 27 Jun 2012 14:43:11 +0900 (JST)
Message-ID: <4FEA9D5C.1080508@jp.fujitsu.com>
Date: Wed, 27 Jun 2012 14:42:52 +0900
From: Yasuaki Ishimatsu <isimatu.yasuaki@jp.fujitsu.com>
MIME-Version: 1.0
Subject: [RFC PATCH 1/12] memory-hotplug : rename remove_memory to offline_memory
References: <4FEA9C88.1070800@jp.fujitsu.com>
In-Reply-To: <4FEA9C88.1070800@jp.fujitsu.com>
Content-Type: text/plain; charset="ISO-2022-JP"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, linux-kernel@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, linux-acpi@vger.kernel.org
Cc: len.brown@intel.com, benh@kernel.crashing.org, paulus@samba.org, cl@linux.com, minchan.kim@gmail.com, akpm@linux-foundation.org, kosaki.motohiro@jp.fujitsu.com, wency@cn.fujitsu.com

remove_memory() does not remove memory but just offlines memory. The patch
changes name of it to offline_memory().

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
 drivers/acpi/acpi_memhotplug.c |    2 +-
 drivers/base/memory.c          |    4 ++--
 include/linux/memory_hotplug.h |    2 +-
 mm/memory_hotplug.c            |    6 +++---
 4 files changed, 7 insertions(+), 7 deletions(-)

Index: linux-3.5-rc4/drivers/acpi/acpi_memhotplug.c
===================================================================
--- linux-3.5-rc4.orig/drivers/acpi/acpi_memhotplug.c	2012-06-25 04:53:04.000000000 +0900
+++ linux-3.5-rc4/drivers/acpi/acpi_memhotplug.c	2012-06-26 13:48:38.263940481 +0900
@@ -318,7 +318,7 @@ static int acpi_memory_disable_device(st
 	 */
 	list_for_each_entry_safe(info, n, &mem_device->res_list, list) {
 		if (info->enabled) {
-			result = remove_memory(info->start_addr, info->length);
+			result = offline_memory(info->start_addr, info->length);
 			if (result)
 				return result;
 		}
Index: linux-3.5-rc4/drivers/base/memory.c
===================================================================
--- linux-3.5-rc4.orig/drivers/base/memory.c	2012-06-25 04:53:04.000000000 +0900
+++ linux-3.5-rc4/drivers/base/memory.c	2012-06-26 13:48:46.072842803 +0900
@@ -266,8 +266,8 @@ memory_block_action(unsigned long phys_i
 			break;
 		case MEM_OFFLINE:
 			start_paddr = page_to_pfn(first_page) << PAGE_SHIFT;
-			ret = remove_memory(start_paddr,
-					    nr_pages << PAGE_SHIFT);
+			ret = offline_memory(start_paddr,
+					     nr_pages << PAGE_SHIFT);
 			break;
 		default:
 			WARN(1, KERN_WARNING "%s(%ld, %ld) unknown action: "
Index: linux-3.5-rc4/mm/memory_hotplug.c
===================================================================
--- linux-3.5-rc4.orig/mm/memory_hotplug.c	2012-06-25 04:53:04.000000000 +0900
+++ linux-3.5-rc4/mm/memory_hotplug.c	2012-06-26 13:48:46.072842803 +0900
@@ -990,7 +990,7 @@ out:
 	return ret;
 }

-int remove_memory(u64 start, u64 size)
+int offline_memory(u64 start, u64 size)
 {
 	unsigned long start_pfn, end_pfn;

@@ -999,9 +999,9 @@ int remove_memory(u64 start, u64 size)
 	return offline_pages(start_pfn, end_pfn, 120 * HZ);
 }
 #else
-int remove_memory(u64 start, u64 size)
+int offline_memory(u64 start, u64 size)
 {
 	return -EINVAL;
 }
 #endif /* CONFIG_MEMORY_HOTREMOVE */
-EXPORT_SYMBOL_GPL(remove_memory);
+EXPORT_SYMBOL_GPL(offline_memory);
Index: linux-3.5-rc4/include/linux/memory_hotplug.h
===================================================================
--- linux-3.5-rc4.orig/include/linux/memory_hotplug.h	2012-06-25 04:53:04.000000000 +0900
+++ linux-3.5-rc4/include/linux/memory_hotplug.h	2012-06-26 13:48:38.264940468 +0900
@@ -233,7 +233,7 @@ static inline int is_mem_section_removab
 extern int mem_online_node(int nid);
 extern int add_memory(int nid, u64 start, u64 size);
 extern int arch_add_memory(int nid, u64 start, u64 size);
-extern int remove_memory(u64 start, u64 size);
+extern int offline_memory(u64 start, u64 size);
 extern int sparse_add_one_section(struct zone *zone, unsigned long start_pfn,
 								int nr_pages);
 extern void sparse_remove_one_section(struct zone *zone, struct mem_section *ms);



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
