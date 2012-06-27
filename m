Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx138.postini.com [74.125.245.138])
	by kanga.kvack.org (Postfix) with SMTP id 28C696B005A
	for <linux-mm@kvack.org>; Wed, 27 Jun 2012 01:46:08 -0400 (EDT)
Received: from m1.gw.fujitsu.co.jp (unknown [10.0.50.71])
	by fgwmail5.fujitsu.co.jp (Postfix) with ESMTP id 6EFCE3EE0C5
	for <linux-mm@kvack.org>; Wed, 27 Jun 2012 14:46:06 +0900 (JST)
Received: from smail (m1 [127.0.0.1])
	by outgoing.m1.gw.fujitsu.co.jp (Postfix) with ESMTP id 4FFEF45DE58
	for <linux-mm@kvack.org>; Wed, 27 Jun 2012 14:46:06 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (s1.gw.fujitsu.co.jp [10.0.50.91])
	by m1.gw.fujitsu.co.jp (Postfix) with ESMTP id 279A445DE5A
	for <linux-mm@kvack.org>; Wed, 27 Jun 2012 14:46:06 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id 14A2F1DB804D
	for <linux-mm@kvack.org>; Wed, 27 Jun 2012 14:46:06 +0900 (JST)
Received: from g01jpexchkw01.g01.fujitsu.local (g01jpexchkw01.g01.fujitsu.local [10.0.194.40])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id A0F201DB8054
	for <linux-mm@kvack.org>; Wed, 27 Jun 2012 14:46:05 +0900 (JST)
Message-ID: <4FEA9E0A.1040202@jp.fujitsu.com>
Date: Wed, 27 Jun 2012 14:45:46 +0900
From: Yasuaki Ishimatsu <isimatu.yasuaki@jp.fujitsu.com>
MIME-Version: 1.0
Subject: [RFC PATCH 3/12] memory-hotplug : add physical memory hotplug code
 to acpi_memory_device_remove
References: <4FEA9C88.1070800@jp.fujitsu.com>
In-Reply-To: <4FEA9C88.1070800@jp.fujitsu.com>
Content-Type: text/plain; charset="ISO-2022-JP"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, linux-kernel@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, linux-acpi@vger.kernel.org
Cc: len.brown@intel.com, benh@kernel.crashing.org, paulus@samba.org, cl@linux.com, minchan.kim@gmail.com, akpm@linux-foundation.org, kosaki.motohiro@jp.fujitsu.com, wency@cn.fujitsu.com

acpi_memory_device_remove() has been prepared to remove physical memory.
But, the function only frees acpi_memory_device currentlry.

The patch adds following functions into acpi_memory_device_remove():
  - offline memory
  - remove physical memory (only return -EBUSY)
  - free acpi_memory_device

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
 drivers/acpi/acpi_memhotplug.c |   23 ++++++++++++++++++++++-
 include/linux/memory_hotplug.h |    1 +
 mm/memory_hotplug.c            |    8 ++++++++
 3 files changed, 31 insertions(+), 1 deletion(-)

Index: linux-3.5-rc4/drivers/acpi/acpi_memhotplug.c
===================================================================
--- linux-3.5-rc4.orig/drivers/acpi/acpi_memhotplug.c	2012-06-26 13:28:16.722211802 +0900
+++ linux-3.5-rc4/drivers/acpi/acpi_memhotplug.c	2012-06-26 13:38:01.085906251 +0900
@@ -452,12 +452,33 @@ static int acpi_memory_device_add(struct
 static int acpi_memory_device_remove(struct acpi_device *device, int type)
 {
 	struct acpi_memory_device *mem_device = NULL;
-
+	struct acpi_memory_info *info, *tmp;
+	int result;
+	int node;

 	if (!device || !acpi_driver_data(device))
 		return -EINVAL;

 	mem_device = acpi_driver_data(device);
+
+	node = acpi_get_node(mem_device->device->handle);
+
+	list_for_each_entry_safe(info, tmp, &mem_device->res_list, list) {
+		if (!info->enabled)
+			continue;
+
+		result = offline_memory(info->start_addr, info->length);
+		if (result)
+			return result;
+
+		result = remove_memory(node, info->start_addr, info->length);
+		if (result)
+			return result;
+
+		list_del(&info->list);
+		kfree(info);
+	}
+
 	kfree(mem_device);

 	return 0;
Index: linux-3.5-rc4/include/linux/memory_hotplug.h
===================================================================
--- linux-3.5-rc4.orig/include/linux/memory_hotplug.h	2012-06-26 13:28:16.773211163 +0900
+++ linux-3.5-rc4/include/linux/memory_hotplug.h	2012-06-26 13:37:30.545288962 +0900
@@ -233,6 +233,7 @@ static inline int is_mem_section_removab
 extern int mem_online_node(int nid);
 extern int add_memory(int nid, u64 start, u64 size);
 extern int arch_add_memory(int nid, u64 start, u64 size);
+extern int remove_memory(int nid, u64 start, u64 size);
 extern int offline_memory(u64 start, u64 size);
 extern int sparse_add_one_section(struct zone *zone, unsigned long start_pfn,
 								int nr_pages);
Index: linux-3.5-rc4/mm/memory_hotplug.c
===================================================================
--- linux-3.5-rc4.orig/mm/memory_hotplug.c	2012-06-26 13:34:22.425639879 +0900
+++ linux-3.5-rc4/mm/memory_hotplug.c	2012-06-26 13:48:30.096046767 +0900
@@ -659,6 +659,14 @@ out:
 }
 EXPORT_SYMBOL_GPL(add_memory);

+int remove_memory(int nid, u64 start, u64 size)
+{
+	return -EBUSY;
+
+}
+EXPORT_SYMBOL_GPL(remove_memory);
+
+
 #ifdef CONFIG_MEMORY_HOTREMOVE
 /*
  * A free page on the buddy free lists (not the per-cpu lists) has PageBuddy


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
