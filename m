Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx160.postini.com [74.125.245.160])
	by kanga.kvack.org (Postfix) with SMTP id 176CB8D0001
	for <linux-mm@kvack.org>; Tue, 15 Jan 2013 05:55:42 -0500 (EST)
From: Tang Chen <tangchen@cn.fujitsu.com>
Subject: [BUG Fix Patch 6/6] Bug fix: Reuse the storage of /sys/firmware/memmap/X/ allocated by bootmem.
Date: Tue, 15 Jan 2013 18:54:27 +0800
Message-Id: <1358247267-18089-7-git-send-email-tangchen@cn.fujitsu.com>
In-Reply-To: <1358247267-18089-1-git-send-email-tangchen@cn.fujitsu.com>
References: <1358247267-18089-1-git-send-email-tangchen@cn.fujitsu.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org, rientjes@google.com, len.brown@intel.com, benh@kernel.crashing.org, paulus@samba.org, cl@linux.com, minchan.kim@gmail.com, kosaki.motohiro@jp.fujitsu.com, isimatu.yasuaki@jp.fujitsu.com, wujianguo@huawei.com, wency@cn.fujitsu.com, tangchen@cn.fujitsu.com, hpa@zytor.com, linfeng@cn.fujitsu.com, laijs@cn.fujitsu.com, mgorman@suse.de, yinghai@kernel.org, glommer@parallels.com, jiang.liu@huawei.com
Cc: x86@kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, linux-acpi@vger.kernel.org, linux-s390@vger.kernel.org, linux-sh@vger.kernel.org, linux-ia64@vger.kernel.org, cmetcalf@tilera.com, sparclinux@vger.kernel.org

Now we don't free firmware_map_entry which is allocated by bootmem because
there is no way to do so when the system is up. But we can at least remember
the address of that memory and reuse the storage when the memory is added
next time.

This patch introduces a new list map_entries_bootmem to link the map entries
allocated by bootmem when they are removed, and a lock to protect it.
And these entries will be reused when the memory is hot-added again.

The idea is suggestted by Andrew Morton <akpm@linux-foundation.org>

Signed-off-by: Tang Chen <tangchen@cn.fujitsu.com>
---
 drivers/firmware/memmap.c |  103 ++++++++++++++++++++++++++++++++++++++-------
 1 files changed, 88 insertions(+), 15 deletions(-)

diff --git a/drivers/firmware/memmap.c b/drivers/firmware/memmap.c
index ae823b4..0710179 100644
--- a/drivers/firmware/memmap.c
+++ b/drivers/firmware/memmap.c
@@ -53,6 +53,9 @@ static ssize_t start_show(struct firmware_map_entry *entry, char *buf);
 static ssize_t end_show(struct firmware_map_entry *entry, char *buf);
 static ssize_t type_show(struct firmware_map_entry *entry, char *buf);
 
+static struct firmware_map_entry * __meminit
+firmware_map_find_entry(u64 start, u64 end, const char *type);
+
 /*
  * Static data -----------------------------------------------------------------
  */
@@ -80,6 +83,19 @@ static const struct sysfs_ops memmap_attr_ops = {
 	.show = memmap_attr_show,
 };
 
+/* Firmware memory map entries. */
+static LIST_HEAD(map_entries);
+static DEFINE_SPINLOCK(map_entries_lock);
+
+/*
+ * For memory hotplug, there is no way to free memory map entries allocated
+ * by boot mem after the system is up. So when we hot-remove memory whose
+ * map entry is allocated by bootmem, we need to remember the storage and
+ * reuse it when the memory is hot-added again.
+ */
+static LIST_HEAD(map_entries_bootmem);
+static DEFINE_SPINLOCK(map_entries_bootmem_lock);
+
 
 static inline struct firmware_map_entry *
 to_memmap_entry(struct kobject *kobj)
@@ -91,9 +107,22 @@ static void release_firmware_map_entry(struct kobject *kobj)
 {
 	struct firmware_map_entry *entry = to_memmap_entry(kobj);
 
-	if (PageReserved(virt_to_page(entry)))
-		/* There is no way to free memory allocated from bootmem */
+	if (PageReserved(virt_to_page(entry))) {
+		/*
+		 * Remember the storage allocated by bootmem, and reuse it when
+		 * the memory is hot-added again. The entry will be added to
+		 * map_entries_bootmem here, and deleted from &map_entries in
+		 * firmware_map_remove_entry().
+		 */
+		if (firmware_map_find_entry(entry->start, entry->end,
+		    entry->type)) {
+			spin_lock(&map_entries_bootmem_lock);
+			list_add(&entry->list, &map_entries_bootmem);
+			spin_unlock(&map_entries_bootmem_lock);
+		}
+
 		return;
+	}
 
 	kfree(entry);
 }
@@ -108,10 +137,6 @@ static struct kobj_type memmap_ktype = {
  * Registration functions ------------------------------------------------------
  */
 
-/* Firmware memory map entries. */
-static LIST_HEAD(map_entries);
-static DEFINE_SPINLOCK(map_entries_lock);
-
 /**
  * firmware_map_add_entry() - Does the real work to add a firmware memmap entry.
  * @start: Start of the memory range.
@@ -184,23 +209,25 @@ static inline void remove_sysfs_fw_map_entry(struct firmware_map_entry *entry)
 }
 
 /*
- * firmware_map_find_entry: Search memmap entry.
+ * firmware_map_find_entry_in_list: Search memmap entry in a given list.
  * @start: Start of the memory range.
  * @end:   End of the memory range (exclusive).
  * @type:  Type of the memory range.
+ * @list:  In which to find the entry.
  *
- * This function is to find the memmap entey of a given memory range.
- * The caller must hold map_entries_lock, and must not release the lock
- * until the processing of the returned entry has completed.
+ * This function is to find the memmap entey of a given memory range in a
+ * given list. The caller must hold map_entries_lock, and must not release
+ * the lock until the processing of the returned entry has completed.
  *
  * Return pointer to the entry to be found on success, or NULL on failure.
  */
 static struct firmware_map_entry * __meminit
-firmware_map_find_entry(u64 start, u64 end, const char *type)
+firmware_map_find_entry_in_list(u64 start, u64 end, const char *type,
+				struct list_head *list)
 {
 	struct firmware_map_entry *entry;
 
-	list_for_each_entry(entry, &map_entries, list)
+	list_for_each_entry(entry, list, list)
 		if ((entry->start == start) && (entry->end == end) &&
 		    (!strcmp(entry->type, type))) {
 			return entry;
@@ -209,6 +236,42 @@ firmware_map_find_entry(u64 start, u64 end, const char *type)
 	return NULL;
 }
 
+/*
+ * firmware_map_find_entry: Search memmap entry in map_entries.
+ * @start: Start of the memory range.
+ * @end:   End of the memory range (exclusive).
+ * @type:  Type of the memory range.
+ *
+ * This function is to find the memmap entey of a given memory range.
+ * The caller must hold map_entries_lock, and must not release the lock
+ * until the processing of the returned entry has completed.
+ *
+ * Return pointer to the entry to be found on success, or NULL on failure.
+ */
+static struct firmware_map_entry * __meminit
+firmware_map_find_entry(u64 start, u64 end, const char *type)
+{
+	return firmware_map_find_entry_in_list(start, end, type, &map_entries);
+}
+
+/*
+ * firmware_map_find_entry_bootmem: Search memmap entry in map_entries_bootmem.
+ * @start: Start of the memory range.
+ * @end:   End of the memory range (exclusive).
+ * @type:  Type of the memory range.
+ *
+ * This function is similar to firmware_map_find_entry except that it find the
+ * given entry in map_entries_bootmem.
+ *
+ * Return pointer to the entry to be found on success, or NULL on failure.
+ */
+static struct firmware_map_entry * __meminit
+firmware_map_find_entry_bootmem(u64 start, u64 end, const char *type)
+{
+	return firmware_map_find_entry_in_list(start, end, type,
+					       &map_entries_bootmem);
+}
+
 /**
  * firmware_map_add_hotplug() - Adds a firmware mapping entry when we do
  * memory hotplug.
@@ -226,9 +289,19 @@ int __meminit firmware_map_add_hotplug(u64 start, u64 end, const char *type)
 {
 	struct firmware_map_entry *entry;
 
-	entry = kzalloc(sizeof(struct firmware_map_entry), GFP_ATOMIC);
-	if (!entry)
-		return -ENOMEM;
+	entry = firmware_map_find_entry_bootmem(start, end, type);
+	if (!entry) {
+		entry = kzalloc(sizeof(struct firmware_map_entry), GFP_ATOMIC);
+		if (!entry)
+			return -ENOMEM;
+	} else {
+		/* Reuse storage allocated by bootmem. */
+		spin_lock(&map_entries_bootmem_lock);
+		list_del(&entry->list);
+		spin_unlock(&map_entries_bootmem_lock);
+
+		memset(entry, 0, sizeof(*entry));
+	}
 
 	firmware_map_add_entry(start, end, type, entry);
 	/* create the memmap entry */
-- 
1.7.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
