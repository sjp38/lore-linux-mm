Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx121.postini.com [74.125.245.121])
	by kanga.kvack.org (Postfix) with SMTP id 19ADF6B0062
	for <linux-mm@kvack.org>; Fri, 27 Jul 2012 06:21:31 -0400 (EDT)
Message-ID: <50126CD7.2080207@cn.fujitsu.com>
Date: Fri, 27 Jul 2012 18:26:31 +0800
From: Wen Congyang <wency@cn.fujitsu.com>
MIME-Version: 1.0
Subject: [RFC PATCH v5 02/19] memory-hotplug: implement offline_memory()
References: <50126B83.3050201@cn.fujitsu.com>
In-Reply-To: <50126B83.3050201@cn.fujitsu.com>
Content-Transfer-Encoding: 7bit
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, linux-kernel@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, linux-acpi@vger.kernel.org, linux-s390@vger.kernel.org, linux-sh@vger.kernel.org, linux-ia64@vger.kernel.org, cmetcalf@tilera.com
Cc: rientjes@google.com, liuj97@gmail.com, len.brown@intel.com, benh@kernel.crashing.org, paulus@samba.org, cl@linux.com, minchan.kim@gmail.com, akpm@linux-foundation.org, kosaki.motohiro@jp.fujitsu.com, Yasuaki ISIMATU <isimatu.yasuaki@jp.fujitsu.com>

The function offline_memory() will be called when hot removing a
memory device. The memory device may contain more than one memory
block. If the memory block has been offlined, __offline_pages()
will fail. So we should try to offline one memory block at a
time.

If the memory block is offlined in offline_memory(), we also
update it's state, and notify the userspace that its state is
changed.

The function offline_memory() also check each memory block's
state. So there is no need to check the memory block's state
before calling offline_memory().

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
CC: Vasilis Liaskovitis <vasilis.liaskovitis@profitbricks.com>
Signed-off-by: Wen Congyang <wency@cn.fujitsu.com>
---
 drivers/base/memory.c          |   31 +++++++++++++++++++++++++++----
 include/linux/memory_hotplug.h |    2 ++
 mm/memory_hotplug.c            |   37 ++++++++++++++++++++++++++++++++++++-
 3 files changed, 65 insertions(+), 5 deletions(-)

diff --git a/drivers/base/memory.c b/drivers/base/memory.c
index 44e7de6..86c8821 100644
--- a/drivers/base/memory.c
+++ b/drivers/base/memory.c
@@ -275,13 +275,11 @@ memory_block_action(unsigned long phys_index, unsigned long action)
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
@@ -309,10 +307,20 @@ static int memory_block_change_state(struct memory_block *mem,
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
@@ -653,6 +661,21 @@ int unregister_memory_section(struct mem_section *section)
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
diff --git a/include/linux/memory_hotplug.h b/include/linux/memory_hotplug.h
index c183f39..0b040bb 100644
--- a/include/linux/memory_hotplug.h
+++ b/include/linux/memory_hotplug.h
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
 extern int offline_memory(u64 start, u64 size);
 extern int sparse_add_one_section(struct zone *zone, unsigned long start_pfn,
 								int nr_pages);
diff --git a/mm/memory_hotplug.c b/mm/memory_hotplug.c
index 7a6659f..992454a 100644
--- a/mm/memory_hotplug.c
+++ b/mm/memory_hotplug.c
@@ -997,7 +997,42 @@ int offline_pages(unsigned long start_pfn, unsigned long nr_pages)
 
 int offline_memory(u64 start, u64 size)
 {
-	return -EINVAL;
+	struct memory_block *mem = NULL;
+	struct mem_section *section;
+	unsigned long start_pfn, end_pfn;
+	unsigned long pfn, section_nr;
+	int ret;
+
+	start_pfn = PFN_DOWN(start);
+	end_pfn = start_pfn + PFN_DOWN(size);
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
 int offline_pages(u64 start, u64 size)
-- 
1.7.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
