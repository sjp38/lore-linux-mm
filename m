Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx189.postini.com [74.125.245.189])
	by kanga.kvack.org (Postfix) with SMTP id 986766B007D
	for <linux-mm@kvack.org>; Tue, 27 Nov 2012 04:58:19 -0500 (EST)
From: Wen Congyang <wency@cn.fujitsu.com>
Subject: [Patch v4 03/12] memory-hotplug: remove redundant codes
Date: Tue, 27 Nov 2012 18:00:13 +0800
Message-Id: <1354010422-19648-4-git-send-email-wency@cn.fujitsu.com>
In-Reply-To: <1354010422-19648-1-git-send-email-wency@cn.fujitsu.com>
References: <1354010422-19648-1-git-send-email-wency@cn.fujitsu.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: x86@kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, linux-acpi@vger.kernel.org, linux-s390@vger.kernel.org, linux-sh@vger.kernel.org, linux-ia64@vger.kernel.org, cmetcalf@tilera.com, sparclinux@vger.kernel.org
Cc: David Rientjes <rientjes@google.com>, Jiang Liu <liuj97@gmail.com>, Len Brown <len.brown@intel.com>, benh@kernel.crashing.org, paulus@samba.org, Christoph Lameter <cl@linux.com>, Minchan Kim <minchan.kim@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Yasuaki Ishimatsu <isimatu.yasuaki@jp.fujitsu.com>, Jianguo Wu <wujianguo@huawei.com>, Wen Congyang <wency@cn.fujitsu.com>

offlining memory blocks and checking whether memory blocks are offlined
are very similar. This patch introduces a new function to remove
redundant codes.

CC: David Rientjes <rientjes@google.com>
CC: Jiang Liu <liuj97@gmail.com>
CC: Len Brown <len.brown@intel.com>
CC: Christoph Lameter <cl@linux.com>
Cc: Minchan Kim <minchan.kim@gmail.com>
CC: Andrew Morton <akpm@linux-foundation.org>
CC: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
CC: Yasuaki Ishimatsu <isimatu.yasuaki@jp.fujitsu.com>
Signed-off-by: Wen Congyang <wency@cn.fujitsu.com>
---
 mm/memory_hotplug.c | 101 ++++++++++++++++++++++++++++------------------------
 1 file changed, 55 insertions(+), 46 deletions(-)

diff --git a/mm/memory_hotplug.c b/mm/memory_hotplug.c
index b6d1101..6d06488 100644
--- a/mm/memory_hotplug.c
+++ b/mm/memory_hotplug.c
@@ -1005,20 +1005,14 @@ int offline_pages(unsigned long start_pfn, unsigned long nr_pages)
 	return __offline_pages(start_pfn, start_pfn + nr_pages, 120 * HZ);
 }
 
-int remove_memory(u64 start, u64 size)
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
@@ -1035,22 +1029,61 @@ repeat:
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
 
@@ -1068,37 +1101,13 @@ repeat:
 	 * memory blocks are offlined.
 	 */
 
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
1.8.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
