Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx143.postini.com [74.125.245.143])
	by kanga.kvack.org (Postfix) with SMTP id 750AF6B0088
	for <linux-mm@kvack.org>; Wed,  5 Sep 2012 05:20:31 -0400 (EDT)
From: wency@cn.fujitsu.com
Subject: [RFC v9 PATCH 08/21] memory-hotplug: remove /sys/firmware/memmap/X sysfs
Date: Wed, 5 Sep 2012 17:25:42 +0800
Message-Id: <1346837155-534-9-git-send-email-wency@cn.fujitsu.com>
In-Reply-To: <1346837155-534-1-git-send-email-wency@cn.fujitsu.com>
References: <1346837155-534-1-git-send-email-wency@cn.fujitsu.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: x86@kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, linux-acpi@vger.kernel.org, linux-s390@vger.kernel.org, linux-sh@vger.kernel.org, linux-ia64@vger.kernel.org, cmetcalf@tilera.com, sparclinux@vger.kernel.org
Cc: rientjes@google.com, liuj97@gmail.com, len.brown@intel.com, benh@kernel.crashing.org, paulus@samba.org, cl@linux.com, minchan.kim@gmail.com, akpm@linux-foundation.org, kosaki.motohiro@jp.fujitsu.com, isimatu.yasuaki@jp.fujitsu.com, Wen Congyang <wency@cn.fujitsu.com>

From: Yasuaki Ishimatsu <isimatu.yasuaki@jp.fujitsu.com>

When (hot)adding memory into system, /sys/firmware/memmap/X/{end, start, type}
sysfs files are created. But there is no code to remove these files. The patch
implements the function to remove them.

Note : The code does not free firmware_map_entry since there is no way to free
       memory which is allocated by bootmem.

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
Signed-off-by: Wen Congyang <wency@cn.fujitsu.com>
---
 drivers/firmware/memmap.c    |   98 +++++++++++++++++++++++++++++++++++++++++-
 include/linux/firmware-map.h |    6 +++
 mm/memory_hotplug.c          |    9 +++-
 3 files changed, 109 insertions(+), 4 deletions(-)

diff --git a/drivers/firmware/memmap.c b/drivers/firmware/memmap.c
index c1cdc92..6740d26 100644
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
index 43fe52f..71d4fa7 100644
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
index 299747d..e74a01d 100644
--- a/mm/memory_hotplug.c
+++ b/mm/memory_hotplug.c
@@ -1052,9 +1052,9 @@ int offline_memory(u64 start, u64 size)
 	return 0;
 }
 
-int remove_memory(int nid, u64 start, u64 size)
+int __ref remove_memory(int nid, u64 start, u64 size)
 {
-	int ret = -EBUSY;
+	int ret = 0;
 	lock_memory_hotplug();
 	/*
 	 * The memory might become online by other task, even if you offine it.
@@ -1065,8 +1065,13 @@ int remove_memory(int nid, u64 start, u64 size)
 			"because the memmory range is online\n",
 			start, start + size);
 		ret = -EAGAIN;
+		goto out;
 	}
 
+	/* remove memmap entry */
+	firmware_map_remove(start, start + size, "System RAM");
+
+out:
 	unlock_memory_hotplug();
 	return ret;
 
-- 
1.7.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
