Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx147.postini.com [74.125.245.147])
	by kanga.kvack.org (Postfix) with SMTP id E6BA96B0068
	for <linux-mm@kvack.org>; Mon, 24 Dec 2012 07:10:26 -0500 (EST)
From: Tang Chen <tangchen@cn.fujitsu.com>
Subject: [PATCH v5 02/14] memory-hotplug: check whether all memory blocks are offlined or not when removing memory
Date: Mon, 24 Dec 2012 20:09:12 +0800
Message-Id: <1356350964-13437-3-git-send-email-tangchen@cn.fujitsu.com>
In-Reply-To: <1356350964-13437-1-git-send-email-tangchen@cn.fujitsu.com>
References: <1356350964-13437-1-git-send-email-tangchen@cn.fujitsu.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org, rientjes@google.com, liuj97@gmail.com, len.brown@intel.com, benh@kernel.crashing.org, paulus@samba.org, cl@linux.com, minchan.kim@gmail.com, kosaki.motohiro@jp.fujitsu.com, isimatu.yasuaki@jp.fujitsu.com, wujianguo@huawei.com, wency@cn.fujitsu.com, tangchen@cn.fujitsu.com, hpa@zytor.com, linfeng@cn.fujitsu.com, laijs@cn.fujitsu.com, mgorman@suse.de, yinghai@kernel.org
Cc: x86@kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, linux-acpi@vger.kernel.org, linux-s390@vger.kernel.org, linux-sh@vger.kernel.org, linux-ia64@vger.kernel.org, cmetcalf@tilera.com, sparclinux@vger.kernel.org

From: Yasuaki Ishimatsu <isimatu.yasuaki@jp.fujitsu.com>

We remove the memory like this:
1. lock memory hotplug
2. offline a memory block
3. unlock memory hotplug
4. repeat 1-3 to offline all memory blocks
5. lock memory hotplug
6. remove memory(TODO)
7. unlock memory hotplug

All memory blocks must be offlined before removing memory. But we don't hold
the lock in the whole operation. So we should check whether all memory blocks
are offlined before step6. Otherwise, kernel maybe panicked.

Signed-off-by: Wen Congyang <wency@cn.fujitsu.com>
Signed-off-by: Yasuaki Ishimatsu <isimatu.yasuaki@jp.fujitsu.com>
---
 drivers/base/memory.c          |    6 +++++
 include/linux/memory_hotplug.h |    1 +
 mm/memory_hotplug.c            |   47 ++++++++++++++++++++++++++++++++++++++++
 3 files changed, 54 insertions(+), 0 deletions(-)

diff --git a/drivers/base/memory.c b/drivers/base/memory.c
index 987604d..8300a18 100644
--- a/drivers/base/memory.c
+++ b/drivers/base/memory.c
@@ -693,6 +693,12 @@ int offline_memory_block(struct memory_block *mem)
 	return ret;
 }
 
+/* return true if the memory block is offlined, otherwise, return false */
+bool is_memblock_offlined(struct memory_block *mem)
+{
+	return mem->state == MEM_OFFLINE;
+}
+
 /*
  * Initialize the sysfs support for memory devices...
  */
diff --git a/include/linux/memory_hotplug.h b/include/linux/memory_hotplug.h
index 4a45c4e..8dd0950 100644
--- a/include/linux/memory_hotplug.h
+++ b/include/linux/memory_hotplug.h
@@ -247,6 +247,7 @@ extern int add_memory(int nid, u64 start, u64 size);
 extern int arch_add_memory(int nid, u64 start, u64 size);
 extern int offline_pages(unsigned long start_pfn, unsigned long nr_pages);
 extern int offline_memory_block(struct memory_block *mem);
+extern bool is_memblock_offlined(struct memory_block *mem);
 extern int remove_memory(u64 start, u64 size);
 extern int sparse_add_one_section(struct zone *zone, unsigned long start_pfn,
 								int nr_pages);
diff --git a/mm/memory_hotplug.c b/mm/memory_hotplug.c
index 62e04c9..d43d97b 100644
--- a/mm/memory_hotplug.c
+++ b/mm/memory_hotplug.c
@@ -1430,6 +1430,53 @@ repeat:
 		goto repeat;
 	}
 
+	lock_memory_hotplug();
+
+	/*
+	 * we have offlined all memory blocks like this:
+	 *   1. lock memory hotplug
+	 *   2. offline a memory block
+	 *   3. unlock memory hotplug
+	 *
+	 * repeat step1-3 to offline the memory block. All memory blocks
+	 * must be offlined before removing memory. But we don't hold the
+	 * lock in the whole operation. So we should check whether all
+	 * memory blocks are offlined.
+	 */
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
+		ret = is_memblock_offlined(mem);
+		if (!ret) {
+			pr_warn("removing memory fails, because memory "
+				"[%#010llx-%#010llx] is onlined\n",
+				PFN_PHYS(section_nr_to_pfn(mem->start_section_nr)),
+				PFN_PHYS(section_nr_to_pfn(mem->end_section_nr + 1)) - 1);
+
+			kobject_put(&mem->dev.kobj);
+			unlock_memory_hotplug();
+			return ret;
+		}
+	}
+
+	if (mem)
+		kobject_put(&mem->dev.kobj);
+	unlock_memory_hotplug();
+
 	return 0;
 }
 #else
-- 
1.7.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
