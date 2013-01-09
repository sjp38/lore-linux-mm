Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx150.postini.com [74.125.245.150])
	by kanga.kvack.org (Postfix) with SMTP id 59D4F6B0074
	for <linux-mm@kvack.org>; Wed,  9 Jan 2013 04:33:35 -0500 (EST)
From: Tang Chen <tangchen@cn.fujitsu.com>
Subject: [PATCH v6 03/15] memory-hotplug: remove redundant codes
Date: Wed, 9 Jan 2013 17:32:27 +0800
Message-Id: <1357723959-5416-4-git-send-email-tangchen@cn.fujitsu.com>
In-Reply-To: <1357723959-5416-1-git-send-email-tangchen@cn.fujitsu.com>
References: <1357723959-5416-1-git-send-email-tangchen@cn.fujitsu.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org, rientjes@google.com, len.brown@intel.com, benh@kernel.crashing.org, paulus@samba.org, cl@linux.com, minchan.kim@gmail.com, kosaki.motohiro@jp.fujitsu.com, isimatu.yasuaki@jp.fujitsu.com, wujianguo@huawei.com, wency@cn.fujitsu.com, tangchen@cn.fujitsu.com, hpa@zytor.com, linfeng@cn.fujitsu.com, laijs@cn.fujitsu.com, mgorman@suse.de, yinghai@kernel.org, glommer@parallels.com
Cc: x86@kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, linux-acpi@vger.kernel.org, linux-s390@vger.kernel.org, linux-sh@vger.kernel.org, linux-ia64@vger.kernel.org, cmetcalf@tilera.com, sparclinux@vger.kernel.org

From: Wen Congyang <wency@cn.fujitsu.com>

offlining memory blocks and checking whether memory blocks are offlined
are very similar. This patch introduces a new function to remove
redundant codes.

Signed-off-by: Wen Congyang <wency@cn.fujitsu.com>
Signed-off-by: Tang Chen <tangchen@cn.fujitsu.com>
Reviewed-by: Kamezawa Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
---
 mm/memory_hotplug.c |  129 ++++++++++++++++++++++++++++++++------------------
 1 files changed, 82 insertions(+), 47 deletions(-)

diff --git a/mm/memory_hotplug.c b/mm/memory_hotplug.c
index 5808045..69d62eb 100644
--- a/mm/memory_hotplug.c
+++ b/mm/memory_hotplug.c
@@ -1381,20 +1381,26 @@ int offline_pages(unsigned long start_pfn, unsigned long nr_pages)
 	return __offline_pages(start_pfn, start_pfn + nr_pages, 120 * HZ);
 }
 
-int remove_memory(u64 start, u64 size)
+/**
+ * walk_memory_range - walks through all mem sections in [start_pfn, end_pfn)
+ * @start_pfn: start pfn of the memory range
+ * @end_pfn: end pft of the memory range
+ * @arg: argument passed to func
+ * @func: callback for each memory section walked
+ *
+ * This function walks through all present mem sections in range
+ * [start_pfn, end_pfn) and call func on each mem section.
+ *
+ * Returns the return value of func.
+ */
+static int walk_memory_range(unsigned long start_pfn, unsigned long end_pfn,
+		void *arg, int (*func)(struct memory_block *, void *))
 {
 	struct memory_block *mem = NULL;
 	struct mem_section *section;
-	unsigned long start_pfn, end_pfn;
 	unsigned long pfn, section_nr;
 	int ret;
-	int return_on_error = 0;
-	int retry = 0;
-
-	start_pfn = PFN_DOWN(start);
-	end_pfn = start_pfn + PFN_DOWN(size);
 
-repeat:
 	for (pfn = start_pfn; pfn < end_pfn; pfn += PAGES_PER_SECTION) {
 		section_nr = pfn_to_section_nr(pfn);
 		if (!present_section_nr(section_nr))
@@ -1411,22 +1417,76 @@ repeat:
 		if (!mem)
 			continue;
 
-		ret = offline_memory_block(mem);
+		ret = func(mem, arg);
 		if (ret) {
-			if (return_on_error) {
-				kobject_put(&mem->dev.kobj);
-				return ret;
-			} else {
-				retry = 1;
-			}
+			kobject_put(&mem->dev.kobj);
+			return ret;
 		}
 	}
 
 	if (mem)
 		kobject_put(&mem->dev.kobj);
 
-	if (retry) {
-		return_on_error = 1;
+	return 0;
+}
+
+/**
+ * offline_memory_block_cb - callback function for offlining memory block
+ * @mem: the memory block to be offlined
+ * @arg: buffer to hold error msg
+ *
+ * Always return 0, and put the error msg in arg if any.
+ */
+static int offline_memory_block_cb(struct memory_block *mem, void *arg)
+{
+	int *ret = arg;
+	int error = offline_memory_block(mem);
+
+	if (error != 0 && *ret == 0)
+		*ret = error;
+
+	return 0;
+}
+
+static int is_memblock_offlined_cb(struct memory_block *mem, void *arg)
+{
+	int ret = !is_memblock_offlined(mem);
+
+	if (unlikely(ret))
+		pr_warn("removing memory fails, because memory "
+			"[%#010llx-%#010llx] is onlined\n",
+			PFN_PHYS(section_nr_to_pfn(mem->start_section_nr)),
+			PFN_PHYS(section_nr_to_pfn(mem->end_section_nr + 1))-1);
+
+	return ret;
+}
+
+int remove_memory(u64 start, u64 size)
+{
+	unsigned long start_pfn, end_pfn;
+	int ret = 0;
+	int retry = 1;
+
+	start_pfn = PFN_DOWN(start);
+	end_pfn = start_pfn + PFN_DOWN(size);
+
+	/*
+	 * When CONFIG_MEMCG is on, one memory block may be used by other
+	 * blocks to store page cgroup when onlining pages. But we don't know
+	 * in what order pages are onlined. So we iterate twice to offline
+	 * memory:
+	 * 1st iterate: offline every non primary memory block.
+	 * 2nd iterate: offline primary (i.e. first added) memory block.
+	 */
+repeat:
+	walk_memory_range(start_pfn, end_pfn, &ret,
+			  offline_memory_block_cb);
+	if (ret) {
+		if (!retry)
+			return ret;
+
+		retry = 0;
+		ret = 0;
 		goto repeat;
 	}
 
@@ -1444,38 +1504,13 @@ repeat:
 	 * memory blocks are offlined.
 	 */
 
-	mem = NULL;
-	for (pfn = start_pfn; pfn < end_pfn; pfn += PAGES_PER_SECTION) {
-		section_nr = pfn_to_section_nr(pfn);
-		if (!present_section_nr(section_nr))
-			continue;
-
-		section = __nr_to_section(section_nr);
-		/* same memblock? */
-		if (mem)
-			if ((section_nr >= mem->start_section_nr) &&
-			    (section_nr <= mem->end_section_nr))
-				continue;
-
-		mem = find_memory_block_hinted(section, mem);
-		if (!mem)
-			continue;
-
-		ret = is_memblock_offlined(mem);
-		if (!ret) {
-			pr_warn("removing memory fails, because memory "
-				"[%#010llx-%#010llx] is onlined\n",
-				PFN_PHYS(section_nr_to_pfn(mem->start_section_nr)),
-				PFN_PHYS(section_nr_to_pfn(mem->end_section_nr + 1)) - 1);
-
-			kobject_put(&mem->dev.kobj);
-			unlock_memory_hotplug();
-			return ret;
-		}
+	ret = walk_memory_range(start_pfn, end_pfn, NULL,
+				is_memblock_offlined_cb);
+	if (ret) {
+		unlock_memory_hotplug();
+		return ret;
 	}
 
-	if (mem)
-		kobject_put(&mem->dev.kobj);
 	unlock_memory_hotplug();
 
 	return 0;
-- 
1.7.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
