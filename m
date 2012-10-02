Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx185.postini.com [74.125.245.185])
	by kanga.kvack.org (Postfix) with SMTP id 52C986B00C0
	for <linux-mm@kvack.org>; Tue,  2 Oct 2012 04:29:25 -0400 (EDT)
Received: from m4.gw.fujitsu.co.jp (unknown [10.0.50.74])
	by fgwmail6.fujitsu.co.jp (Postfix) with ESMTP id D39683EE0C2
	for <linux-mm@kvack.org>; Tue,  2 Oct 2012 17:29:23 +0900 (JST)
Received: from smail (m4 [127.0.0.1])
	by outgoing.m4.gw.fujitsu.co.jp (Postfix) with ESMTP id A1F7845DE53
	for <linux-mm@kvack.org>; Tue,  2 Oct 2012 17:29:23 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (s4.gw.fujitsu.co.jp [10.0.50.94])
	by m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 884C145DE55
	for <linux-mm@kvack.org>; Tue,  2 Oct 2012 17:29:23 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id 764651DB803B
	for <linux-mm@kvack.org>; Tue,  2 Oct 2012 17:29:23 +0900 (JST)
Received: from G01JPEXCHKW08.g01.fujitsu.local (G01JPEXCHKW08.g01.fujitsu.local [10.0.194.47])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id 048BA1DB8049
	for <linux-mm@kvack.org>; Tue,  2 Oct 2012 17:29:23 +0900 (JST)
Message-ID: <506AA5CB.9090505@jp.fujitsu.com>
Date: Tue, 2 Oct 2012 17:28:59 +0900
From: Yasuaki Ishimatsu <isimatu.yasuaki@jp.fujitsu.com>
MIME-Version: 1.0
Subject: [Patch 2/2] memory-hotplug : update memory block's state and notfy
 theinformation to userspace
References: <506AA4E2.7070302@jp.fujitsu.com>
In-Reply-To: <506AA4E2.7070302@jp.fujitsu.com>
Content-Type: text/plain; charset="ISO-2022-JP"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: x86@kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, linux-acpi@vger.kernel.org
Cc: rientjes@google.com, liuj97@gmail.com, len.brown@intel.com, cl@linux.com, minchan.kim@gmail.com, akpm@linux-foundation.org, kosaki.motohiro@jp.fujitsu.com, wency@cn.fujitsu.com

From: Wen Congyang <wency@cn.fujitsu.com>

The function remove_memory() will be called when hot removing a
memory device. But even if offlining memory, we cannot notice it.
So the patch update memory block's state and notify to userspace.

Additionally, the memory device may contain more than one memory
block. If the memory block has been offlined, __offline_pages()
will fail. So we should try to offline one memory block at a
time.

Thus the function remove_memory() also check each memory block's
state. So there is no need to check the memory block's state
before calling remove_memory().

CC: David Rientjes <rientjes@google.com>
CC: Jiang Liu <liuj97@gmail.com>
CC: Len Brown <len.brown@intel.com>
CC: Christoph Lameter <cl@linux.com>
Cc: Minchan Kim <minchan.kim@gmail.com>
CC: Andrew Morton <akpm@linux-foundation.org>
CC: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com> 
Signed-off-by: Wen Congyang <wency@cn.fujitsu.com>
Signed-off-by: Yasuaki Ishimatsu <isimatu.yasuaki@jp.fujitsu.com>
---
 drivers/base/memory.c          |   31 +++++++++++++++++++++++++++----
 include/linux/memory_hotplug.h |    2 ++
 mm/memory_hotplug.c            |   33 ++++++++++++++++++++++++++++++++-
 3 files changed, 61 insertions(+), 5 deletions(-)

Index: linux-3.6/drivers/base/memory.c
===================================================================
--- linux-3.6.orig/drivers/base/memory.c	2012-10-02 16:03:43.000000000 +0900
+++ linux-3.6/drivers/base/memory.c	2012-10-02 16:06:27.786081495 +0900
@@ -275,13 +275,11 @@ memory_block_action(unsigned long phys_i
 	return ret;
 }
 
-static int memory_block_change_state(struct memory_block *mem,
+static int __memory_block_change_state(struct memory_block *mem,
 		unsigned long to_state, unsigned long from_state_req)
 {
 	int ret = 0;
 
-	mutex_lock(&mem->state_mutex);
-
 	if (mem->state != from_state_req) {
 		ret = -EINVAL;
 		goto out;
@@ -309,10 +307,20 @@ static int memory_block_change_state(str
 		break;
 	}
 out:
-	mutex_unlock(&mem->state_mutex);
 	return ret;
 }
 
+static int memory_block_change_state(struct memory_block *mem,
+		unsigned long to_state, unsigned long from_state_req)
+{
+	int ret;
+
+	mutex_lock(&mem->state_mutex);
+	ret = __memory_block_change_state(mem, to_state, from_state_req);
+	mutex_unlock(&mem->state_mutex);
+
+	return ret;
+}
 static ssize_t
 store_mem_state(struct device *dev,
 		struct device_attribute *attr, const char *buf, size_t count)
@@ -653,6 +661,21 @@ int unregister_memory_section(struct mem
 }
 
 /*
+ * offline one memory block. If the memory block has been offlined, do nothing.
+ */
+int offline_memory_block(struct memory_block *mem)
+{
+	int ret = 0;
+
+	mutex_lock(&mem->state_mutex);
+	if (mem->state != MEM_OFFLINE)
+		ret = __memory_block_change_state(mem, MEM_OFFLINE, MEM_ONLINE);
+	mutex_unlock(&mem->state_mutex);
+
+	return ret;
+}
+
+/*
  * Initialize the sysfs support for memory devices...
  */
 int __init memory_dev_init(void)
Index: linux-3.6/include/linux/memory_hotplug.h
===================================================================
--- linux-3.6.orig/include/linux/memory_hotplug.h	2012-10-02 16:04:19.000000000 +0900
+++ linux-3.6/include/linux/memory_hotplug.h	2012-10-02 16:07:02.118080769 +0900
@@ -10,6 +10,7 @@ struct page;
 struct zone;
 struct pglist_data;
 struct mem_section;
+struct memory_block;
 
 #ifdef CONFIG_MEMORY_HOTPLUG
 
@@ -234,6 +235,7 @@ extern int mem_online_node(int nid);
 extern int add_memory(int nid, u64 start, u64 size);
 extern int arch_add_memory(int nid, u64 start, u64 size);
 extern int offline_pages(unsigned long start_pfn, unsigned long nr_pages);
+extern int offline_memory_block(struct memory_block *mem);
 extern int remove_memory(u64 start, u64 size);
 extern int sparse_add_one_section(struct zone *zone, unsigned long start_pfn,
 								int nr_pages);
Index: linux-3.6/mm/memory_hotplug.c
===================================================================
--- linux-3.6.orig/mm/memory_hotplug.c	2012-10-02 16:05:13.000000000 +0900
+++ linux-3.6/mm/memory_hotplug.c	2012-10-02 16:06:27.794081501 +0900
@@ -1005,11 +1005,42 @@ int offline_pages(unsigned long start_pf
 
 int remove_memory(u64 start, u64 size)
 {
+	struct memory_block *mem = NULL;
+	struct mem_section *section;
 	unsigned long start_pfn, end_pfn;
+	unsigned long pfn, section_nr;
+	int ret;
 
 	start_pfn = PFN_DOWN(start);
 	end_pfn = start_pfn + PFN_DOWN(size);
-	return __offline_pages(start_pfn, end_pfn, 120 * HZ);
+
+	for (pfn = start_pfn; pfn < end_pfn; pfn += PAGES_PER_SECTION) {
+		section_nr = pfn_to_section_nr(pfn);
+		if (!present_section_nr(section_nr))
+			continue;
+
+		section = __nr_to_section(section_nr);
+		/* same memblock? */
+		if (mem)
+			if ((section_nr >= mem->start_section_nr) &&
+			    (section_nr <= mem->end_section_nr))
+				continue;
+
+		mem = find_memory_block_hinted(section, mem);
+		if (!mem)
+			continue;
+
+		ret = offline_memory_block(mem);
+		if (ret) {
+			kobject_put(&mem->dev.kobj);
+			return ret;
+		}
+	}
+
+	if (mem)
+		kobject_put(&mem->dev.kobj);
+
+	return 0;
 }
 #else
 int offline_pages(unsigned long start_pfn, unsigned long nr_pages)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
