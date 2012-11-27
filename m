Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx156.postini.com [74.125.245.156])
	by kanga.kvack.org (Postfix) with SMTP id 557706B007B
	for <linux-mm@kvack.org>; Tue, 27 Nov 2012 04:58:19 -0500 (EST)
From: Wen Congyang <wency@cn.fujitsu.com>
Subject: [Patch v4 04/12] memory-hotplug: remove /sys/firmware/memmap/X sysfs
Date: Tue, 27 Nov 2012 18:00:14 +0800
Message-Id: <1354010422-19648-5-git-send-email-wency@cn.fujitsu.com>
In-Reply-To: <1354010422-19648-1-git-send-email-wency@cn.fujitsu.com>
References: <1354010422-19648-1-git-send-email-wency@cn.fujitsu.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: x86@kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, linux-acpi@vger.kernel.org, linux-s390@vger.kernel.org, linux-sh@vger.kernel.org, linux-ia64@vger.kernel.org, cmetcalf@tilera.com, sparclinux@vger.kernel.org
Cc: David Rientjes <rientjes@google.com>, Jiang Liu <liuj97@gmail.com>, Len Brown <len.brown@intel.com>, benh@kernel.crashing.org, paulus@samba.org, Christoph Lameter <cl@linux.com>, Minchan Kim <minchan.kim@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Yasuaki Ishimatsu <isimatu.yasuaki@jp.fujitsu.com>, Jianguo Wu <wujianguo@huawei.com>, Wen Congyang <wency@cn.fujitsu.com>

From: Yasuaki Ishimatsu <isimatu.yasuaki@jp.fujitsu.com>

When (hot)adding memory into system, /sys/firmware/memmap/X/{end, start, type}
sysfs files are created. But there is no code to remove these files. The patch
implements the function to remove them.

Note: The code does not free firmware_map_entry which is allocated by bootmem.
      So the patch makes memory leak. But I think the memory leak size is
      very samll. And it does not affect the system.

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
 drivers/firmware/memmap.c    | 98 +++++++++++++++++++++++++++++++++++++++++++-
 include/linux/firmware-map.h |  6 +++
 mm/memory_hotplug.c          |  5 ++-
 3 files changed, 106 insertions(+), 3 deletions(-)

diff --git a/drivers/firmware/memmap.c b/drivers/firmware/memmap.c
index 90723e6..49be12a 100644
--- a/drivers/firmware/memmap.c
+++ b/drivers/firmware/memmap.c
@@ -21,6 +21,7 @@
 #include <linux/types.h>
 #include <linux/bootmem.h>
 #include <linux/slab.h>
+#include <linux/mm.h>
 
 /*
  * Data types ------------------------------------------------------------------
@@ -41,6 +42,7 @@ struct firmware_map_entry {
 	const char		*type;	/* type of the memory range */
 	struct list_head	list;	/* entry for the linked list */
 	struct kobject		kobj;   /* kobject for each entry */
+	unsigned int		bootmem:1; /* allocated from bootmem */
 };
 
 /*
@@ -79,7 +81,26 @@ static const struct sysfs_ops memmap_attr_ops = {
 	.show = memmap_attr_show,
 };
 
+
+static inline struct firmware_map_entry *
+to_memmap_entry(struct kobject *kobj)
+{
+	return container_of(kobj, struct firmware_map_entry, kobj);
+}
+
+static void release_firmware_map_entry(struct kobject *kobj)
+{
+	struct firmware_map_entry *entry = to_memmap_entry(kobj);
+
+	if (entry->bootmem)
+		/* There is no way to free memory allocated from bootmem */
+		return;
+
+	kfree(entry);
+}
+
 static struct kobj_type memmap_ktype = {
+	.release	= release_firmware_map_entry,
 	.sysfs_ops	= &memmap_attr_ops,
 	.default_attrs	= def_attrs,
 };
@@ -94,6 +115,7 @@ static struct kobj_type memmap_ktype = {
  * in firmware initialisation code in one single thread of execution.
  */
 static LIST_HEAD(map_entries);
+static DEFINE_SPINLOCK(map_entries_lock);
 
 /**
  * firmware_map_add_entry() - Does the real work to add a firmware memmap entry.
@@ -118,11 +140,25 @@ static int firmware_map_add_entry(u64 start, u64 end,
 	INIT_LIST_HEAD(&entry->list);
 	kobject_init(&entry->kobj, &memmap_ktype);
 
+	spin_lock(&map_entries_lock);
 	list_add_tail(&entry->list, &map_entries);
+	spin_unlock(&map_entries_lock);
 
 	return 0;
 }
 
+/**
+ * firmware_map_remove_entry() - Does the real work to remove a firmware
+ * memmap entry.
+ * @entry: removed entry.
+ **/
+static inline void firmware_map_remove_entry(struct firmware_map_entry *entry)
+{
+	spin_lock(&map_entries_lock);
+	list_del(&entry->list);
+	spin_unlock(&map_entries_lock);
+}
+
 /*
  * Add memmap entry on sysfs
  */
@@ -144,6 +180,35 @@ static int add_sysfs_fw_map_entry(struct firmware_map_entry *entry)
 	return 0;
 }
 
+/*
+ * Remove memmap entry on sysfs
+ */
+static inline void remove_sysfs_fw_map_entry(struct firmware_map_entry *entry)
+{
+	kobject_put(&entry->kobj);
+}
+
+/*
+ * Search memmap entry
+ */
+
+static struct firmware_map_entry * __meminit
+firmware_map_find_entry(u64 start, u64 end, const char *type)
+{
+	struct firmware_map_entry *entry;
+
+	spin_lock(&map_entries_lock);
+	list_for_each_entry(entry, &map_entries, list)
+		if ((entry->start == start) && (entry->end == end) &&
+		    (!strcmp(entry->type, type))) {
+			spin_unlock(&map_entries_lock);
+			return entry;
+		}
+
+	spin_unlock(&map_entries_lock);
+	return NULL;
+}
+
 /**
  * firmware_map_add_hotplug() - Adds a firmware mapping entry when we do
  * memory hotplug.
@@ -193,9 +258,36 @@ int __init firmware_map_add_early(u64 start, u64 end, const char *type)
 	if (WARN_ON(!entry))
 		return -ENOMEM;
 
+	entry->bootmem = 1;
 	return firmware_map_add_entry(start, end, type, entry);
 }
 
+/**
+ * firmware_map_remove() - remove a firmware mapping entry
+ * @start: Start of the memory range.
+ * @end:   End of the memory range.
+ * @type:  Type of the memory range.
+ *
+ * removes a firmware mapping entry.
+ *
+ * Returns 0 on success, or -EINVAL if no entry.
+ **/
+int __meminit firmware_map_remove(u64 start, u64 end, const char *type)
+{
+	struct firmware_map_entry *entry;
+
+	entry = firmware_map_find_entry(start, end - 1, type);
+	if (!entry)
+		return -EINVAL;
+
+	firmware_map_remove_entry(entry);
+
+	/* remove the memmap entry */
+	remove_sysfs_fw_map_entry(entry);
+
+	return 0;
+}
+
 /*
  * Sysfs functions -------------------------------------------------------------
  */
@@ -217,8 +309,10 @@ static ssize_t type_show(struct firmware_map_entry *entry, char *buf)
 	return snprintf(buf, PAGE_SIZE, "%s\n", entry->type);
 }
 
-#define to_memmap_attr(_attr) container_of(_attr, struct memmap_attribute, attr)
-#define to_memmap_entry(obj) container_of(obj, struct firmware_map_entry, kobj)
+static inline struct memmap_attribute *to_memmap_attr(struct attribute *attr)
+{
+	return container_of(attr, struct memmap_attribute, attr);
+}
 
 static ssize_t memmap_attr_show(struct kobject *kobj,
 				struct attribute *attr, char *buf)
diff --git a/include/linux/firmware-map.h b/include/linux/firmware-map.h
index 43fe52fc..71d4fa7 100644
--- a/include/linux/firmware-map.h
+++ b/include/linux/firmware-map.h
@@ -25,6 +25,7 @@
 
 int firmware_map_add_early(u64 start, u64 end, const char *type);
 int firmware_map_add_hotplug(u64 start, u64 end, const char *type);
+int firmware_map_remove(u64 start, u64 end, const char *type);
 
 #else /* CONFIG_FIRMWARE_MEMMAP */
 
@@ -38,6 +39,11 @@ static inline int firmware_map_add_hotplug(u64 start, u64 end, const char *type)
 	return 0;
 }
 
+static inline int firmware_map_remove(u64 start, u64 end, const char *type)
+{
+	return 0;
+}
+
 #endif /* CONFIG_FIRMWARE_MEMMAP */
 
 #endif /* _LINUX_FIRMWARE_MAP_H */
diff --git a/mm/memory_hotplug.c b/mm/memory_hotplug.c
index 6d06488..63d5388 100644
--- a/mm/memory_hotplug.c
+++ b/mm/memory_hotplug.c
@@ -1066,7 +1066,7 @@ static int is_memblock_offlined_cb(struct memory_block *mem, void *arg)
 	return ret;
 }
 
-int remove_memory(u64 start, u64 size)
+int __ref remove_memory(u64 start, u64 size)
 {
 	unsigned long start_pfn, end_pfn;
 	int ret = 0;
@@ -1108,6 +1108,9 @@ repeat:
 		return ret;
 	}
 
+	/* remove memmap entry */
+	firmware_map_remove(start, start + size, "System RAM");
+
 	unlock_memory_hotplug();
 
 	return 0;
-- 
1.8.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
