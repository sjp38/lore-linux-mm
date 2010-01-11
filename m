Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id 77B7D6B006A
	for <linux-mm@kvack.org>; Sun, 10 Jan 2010 21:00:54 -0500 (EST)
From: "Zheng, Shaohui" <shaohui.zheng@intel.com>
Date: Mon, 11 Jan 2010 10:00:11 +0800
Subject: [PATCH-RESEND v4] memory-hotplug: create /sys/firmware/memmap entry
 for new memory
Message-ID: <DA586906BA1FFC4384FCFD6429ECE86031560F92@shzsmsx502.ccr.corp.intel.com>
Content-Language: en-US
Content-Type: multipart/mixed;
	boundary="_002_DA586906BA1FFC4384FCFD6429ECE86031560F92shzsmsx502ccrco_"
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
To: "linux-mm@kvack.org" <linux-mm@kvack.org>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>
Cc: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "ak@linux.intel.com" <ak@linux.intel.com>, "y-goto@jp.fujitsu.com" <y-goto@jp.fujitsu.com>, Dave Hansen <haveblue@us.ibm.com>, "Wu, Fengguang" <fengguang.wu@intel.com>, "x86@kernel.org" <x86@kernel.org>
List-ID: <linux-mm.kvack.org>

--_002_DA586906BA1FFC4384FCFD6429ECE86031560F92shzsmsx502ccrco_
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: quoted-printable

Resend the memmap patch v4 to mailing-list after follow up fengguang's revi=
ew=20
comments.=20

memory-hotplug: create /sys/firmware/memmap entry for hot-added memory

Interface firmware_map_add was not called in explict, Remove it and add fun=
ction
firmware_map_add_hotplug as hotplug interface of memmap.

When we hot-add new memory, sysfs does not export memmap entry for it. we a=
dd
 a call in function add_memory to function firmware_map_add_hotplug.

Add a new function add_sysfs_fw_map_entry to create memmap entry, it can av=
oid=20
duplicated codes.

Thanks for the careful review from Fengguang Wu and Dave Hansen.

Signed-off-by: Shaohui Zheng <shaohui.zheng@intel.com>
Acked-by: Andi Kleen <ak@linux.intel.com>
Acked-by: Yasunori Goto <y-goto@jp.fujitsu.com>
Reviewed-by: Wu Fengguang <fengguang.wu@intel.com>
diff --git a/drivers/firmware/memmap.c b/drivers/firmware/memmap.c
index 56f9234..11baa6d 100644
--- a/drivers/firmware/memmap.c
+++ b/drivers/firmware/memmap.c
@@ -123,20 +123,40 @@ static int firmware_map_add_entry(u64 start, u64 end,
 }
=20
 /**
- * firmware_map_add() - Adds a firmware mapping entry.
+ * Add memmap entry on sysfs
+ */
+static int add_sysfs_fw_map_entry(struct firmware_map_entry *entry)
+{
+	static int map_entries_nr;
+	static struct kset *mmap_kset;
+
+	if (!mmap_kset) {
+		mmap_kset =3D kset_create_and_add("memmap", NULL, firmware_kobj);
+		if (!mmap_kset)
+			return -ENOMEM;
+	}
+
+	entry->kobj.kset =3D mmap_kset;
+	if (kobject_add(&entry->kobj, NULL, "%d", map_entries_nr++))
+		kobject_put(&entry->kobj);
+
+	return 0;
+}
+
+/**
+ * firmware_map_add_early() - Adds a firmware mapping entry.
  * @start: Start of the memory range.
  * @end:   End of the memory range (inclusive).
  * @type:  Type of the memory range.
  *
- * This function uses kmalloc() for memory
- * allocation. Use firmware_map_add_early() if you want to use the bootmem
- * allocator.
+ * Adds a firmware mapping entry. This function uses the bootmem allocator
+ * for memory allocation.
  *
  * That function must be called before late_initcall.
  *
  * Returns 0 on success, or -ENOMEM if no memory could be allocated.
  **/
-int firmware_map_add(u64 start, u64 end, const char *type)
+int __init firmware_map_add_early(u64 start, u64 end, const char *type)
 {
 	struct firmware_map_entry *entry;
=20
@@ -148,27 +168,31 @@ int firmware_map_add(u64 start, u64 end, const char *=
type)
 }
=20
 /**
- * firmware_map_add_early() - Adds a firmware mapping entry.
+ * firmware_map_add_hotplug() - Adds a firmware mapping entry when we do
+ * memory hotplug.
  * @start: Start of the memory range.
  * @end:   End of the memory range (inclusive).
  * @type:  Type of the memory range.
  *
- * Adds a firmware mapping entry. This function uses the bootmem allocator
- * for memory allocation. Use firmware_map_add() if you want to use kmallo=
c().
- *
- * That function must be called before late_initcall.
+ * Adds a firmware mapping entry. This function is for memory hotplug, it =
is
+ * simiar with function firmware_map_add_early. the only difference is tha=
t
+ * it will create the syfs entry dynamically.
  *
  * Returns 0 on success, or -ENOMEM if no memory could be allocated.
  **/
-int __init firmware_map_add_early(u64 start, u64 end, const char *type)
+int __meminit firmware_map_add_hotplug(u64 start, u64 end, const char *typ=
e)
 {
 	struct firmware_map_entry *entry;
=20
-	entry =3D alloc_bootmem(sizeof(struct firmware_map_entry));
-	if (WARN_ON(!entry))
+	entry =3D kzalloc(sizeof(struct firmware_map_entry), GFP_ATOMIC);
+	if (!entry)
 		return -ENOMEM;
=20
-	return firmware_map_add_entry(start, end, type, entry);
+	firmware_map_add_entry(start, end, type, entry);
+	/* create the memmap entry */
+	add_sysfs_fw_map_entry(entry);
+
+	return 0;
 }
=20
 /*
@@ -214,18 +238,10 @@ static ssize_t memmap_attr_show(struct kobject *kobj,
  */
 static int __init memmap_init(void)
 {
-	int i =3D 0;
 	struct firmware_map_entry *entry;
-	struct kset *memmap_kset;
-
-	memmap_kset =3D kset_create_and_add("memmap", NULL, firmware_kobj);
-	if (WARN_ON(!memmap_kset))
-		return -ENOMEM;
=20
 	list_for_each_entry(entry, &map_entries, list) {
-		entry->kobj.kset =3D memmap_kset;
-		if (kobject_add(&entry->kobj, NULL, "%d", i++))
-			kobject_put(&entry->kobj);
+		add_sysfs_fw_map_entry(entry);
 	}
=20
 	return 0;
diff --git a/include/linux/firmware-map.h b/include/linux/firmware-map.h
index 875451f..c6dcc1d 100644
--- a/include/linux/firmware-map.h
+++ b/include/linux/firmware-map.h
@@ -24,17 +24,17 @@
  */
 #ifdef CONFIG_FIRMWARE_MEMMAP
=20
-int firmware_map_add(u64 start, u64 end, const char *type);
 int firmware_map_add_early(u64 start, u64 end, const char *type);
+int firmware_map_add_hotplug(u64 start, u64 end, const char *type);
=20
 #else /* CONFIG_FIRMWARE_MEMMAP */
=20
-static inline int firmware_map_add(u64 start, u64 end, const char *type)
+static inline int firmware_map_add_early(u64 start, u64 end, const char *t=
ype)
 {
 	return 0;
 }
=20
-static inline int firmware_map_add_early(u64 start, u64 end, const char *t=
ype)
+static inline int firmware_map_add_hotplug(u64 start, u64 end, const char =
*type)
 {
 	return 0;
 }
diff --git a/mm/memory_hotplug.c b/mm/memory_hotplug.c
index 030ce8a..78e34e6 100644
--- a/mm/memory_hotplug.c
+++ b/mm/memory_hotplug.c
@@ -28,6 +28,7 @@
 #include <linux/pfn.h>
 #include <linux/suspend.h>
 #include <linux/mm_inline.h>
+#include <linux/firmware-map.h>
=20
 #include <asm/tlbflush.h>
=20
@@ -523,6 +524,9 @@ int __ref add_memory(int nid, u64 start, u64 size)
 		BUG_ON(ret);
 	}
=20
+	/* create new memmap entry */
+	firmware_map_add_hotplug(start, start + size, "System RAM");
+
 	goto out;
=20
 error:

Thanks & Regards,
Shaohui




--_002_DA586906BA1FFC4384FCFD6429ECE86031560F92shzsmsx502ccrco_
Content-Type: application/octet-stream; name=
	"memory-hotplug-create-sys-firmware-memmap-entry-for-new-memory-v4.patch"
Content-Description: memory-hotplug-create-sys-firmware-memmap-entry-for-new-memory-v4.patch
Content-Disposition: attachment; filename=
	"memory-hotplug-create-sys-firmware-memmap-entry-for-new-memory-v4.patch";
	size=5538; creation-date="Mon, 11 Jan 2010 09:59:28 GMT";
	modification-date="Mon, 11 Jan 2010 17:49:36 GMT"
Content-Transfer-Encoding: base64

bWVtb3J5LWhvdHBsdWc6IGNyZWF0ZSAvc3lzL2Zpcm13YXJlL21lbW1hcCBlbnRyeSBmb3IgaG90
LWFkZGVkIG1lbW9yeQoKSW50ZXJmYWNlIGZpcm13YXJlX21hcF9hZGQgd2FzIG5vdCBjYWxsZWQg
aW4gZXhwbGljdCwgUmVtb3ZlIGl0IGFuZCBhZGQgZnVuY3Rpb24KZmlybXdhcmVfbWFwX2FkZF9o
b3RwbHVnIGFzIGhvdHBsdWcgaW50ZXJmYWNlIG9mIG1lbW1hcC4KCldoZW4gd2UgaG90LWFkZCBu
ZXcgbWVtb3J5LCBzeXNmcyBkb2VzIG5vdCBleHBvcnQgbWVtbWFwIGVudHJ5IGZvciBpdC4gd2Ug
YWRkCiBhIGNhbGwgaW4gZnVuY3Rpb24gYWRkX21lbW9yeSB0byBmdW5jdGlvbiBmaXJtd2FyZV9t
YXBfYWRkX2hvdHBsdWcuCgpBZGQgYSBuZXcgZnVuY3Rpb24gYWRkX3N5c2ZzX2Z3X21hcF9lbnRy
eSB0byBjcmVhdGUgbWVtbWFwIGVudHJ5LCBpdCBjYW4gYXZvaWQgCmR1cGxpY2F0ZWQgY29kZXMu
CgpUaGFua3MgZm9yIHRoZSBjYXJlZnVsIHJldmlldyBmcm9tIEZlbmdndWFuZyBXdSBhbmQgRGF2
ZSBIYW5zZW4uCgpTaWduZWQtb2ZmLWJ5OiBTaGFvaHVpIFpoZW5nIDxzaGFvaHVpLnpoZW5nQGlu
dGVsLmNvbT4KQWNrZWQtYnk6IEFuZGkgS2xlZW4gPGFrQGxpbnV4LmludGVsLmNvbT4KQWNrZWQt
Ynk6IFlhc3Vub3JpIEdvdG8gPHktZ290b0BqcC5mdWppdHN1LmNvbT4KUmV2aWV3ZWQtYnk6IFd1
IEZlbmdndWFuZyA8ZmVuZ2d1YW5nLnd1QGludGVsLmNvbT4KZGlmZiAtLWdpdCBhL2RyaXZlcnMv
ZmlybXdhcmUvbWVtbWFwLmMgYi9kcml2ZXJzL2Zpcm13YXJlL21lbW1hcC5jCmluZGV4IDU2Zjky
MzQuLjExYmFhNmQgMTAwNjQ0Ci0tLSBhL2RyaXZlcnMvZmlybXdhcmUvbWVtbWFwLmMKKysrIGIv
ZHJpdmVycy9maXJtd2FyZS9tZW1tYXAuYwpAQCAtMTIzLDIwICsxMjMsNDAgQEAgc3RhdGljIGlu
dCBmaXJtd2FyZV9tYXBfYWRkX2VudHJ5KHU2NCBzdGFydCwgdTY0IGVuZCwKIH0KIAogLyoqCi0g
KiBmaXJtd2FyZV9tYXBfYWRkKCkgLSBBZGRzIGEgZmlybXdhcmUgbWFwcGluZyBlbnRyeS4KKyAq
IEFkZCBtZW1tYXAgZW50cnkgb24gc3lzZnMKKyAqLworc3RhdGljIGludCBhZGRfc3lzZnNfZndf
bWFwX2VudHJ5KHN0cnVjdCBmaXJtd2FyZV9tYXBfZW50cnkgKmVudHJ5KQoreworCXN0YXRpYyBp
bnQgbWFwX2VudHJpZXNfbnI7CisJc3RhdGljIHN0cnVjdCBrc2V0ICptbWFwX2tzZXQ7CisKKwlp
ZiAoIW1tYXBfa3NldCkgeworCQltbWFwX2tzZXQgPSBrc2V0X2NyZWF0ZV9hbmRfYWRkKCJtZW1t
YXAiLCBOVUxMLCBmaXJtd2FyZV9rb2JqKTsKKwkJaWYgKCFtbWFwX2tzZXQpCisJCQlyZXR1cm4g
LUVOT01FTTsKKwl9CisKKwllbnRyeS0+a29iai5rc2V0ID0gbW1hcF9rc2V0OworCWlmIChrb2Jq
ZWN0X2FkZCgmZW50cnktPmtvYmosIE5VTEwsICIlZCIsIG1hcF9lbnRyaWVzX25yKyspKQorCQlr
b2JqZWN0X3B1dCgmZW50cnktPmtvYmopOworCisJcmV0dXJuIDA7Cit9CisKKy8qKgorICogZmly
bXdhcmVfbWFwX2FkZF9lYXJseSgpIC0gQWRkcyBhIGZpcm13YXJlIG1hcHBpbmcgZW50cnkuCiAg
KiBAc3RhcnQ6IFN0YXJ0IG9mIHRoZSBtZW1vcnkgcmFuZ2UuCiAgKiBAZW5kOiAgIEVuZCBvZiB0
aGUgbWVtb3J5IHJhbmdlIChpbmNsdXNpdmUpLgogICogQHR5cGU6ICBUeXBlIG9mIHRoZSBtZW1v
cnkgcmFuZ2UuCiAgKgotICogVGhpcyBmdW5jdGlvbiB1c2VzIGttYWxsb2MoKSBmb3IgbWVtb3J5
Ci0gKiBhbGxvY2F0aW9uLiBVc2UgZmlybXdhcmVfbWFwX2FkZF9lYXJseSgpIGlmIHlvdSB3YW50
IHRvIHVzZSB0aGUgYm9vdG1lbQotICogYWxsb2NhdG9yLgorICogQWRkcyBhIGZpcm13YXJlIG1h
cHBpbmcgZW50cnkuIFRoaXMgZnVuY3Rpb24gdXNlcyB0aGUgYm9vdG1lbSBhbGxvY2F0b3IKKyAq
IGZvciBtZW1vcnkgYWxsb2NhdGlvbi4KICAqCiAgKiBUaGF0IGZ1bmN0aW9uIG11c3QgYmUgY2Fs
bGVkIGJlZm9yZSBsYXRlX2luaXRjYWxsLgogICoKICAqIFJldHVybnMgMCBvbiBzdWNjZXNzLCBv
ciAtRU5PTUVNIGlmIG5vIG1lbW9yeSBjb3VsZCBiZSBhbGxvY2F0ZWQuCiAgKiovCi1pbnQgZmly
bXdhcmVfbWFwX2FkZCh1NjQgc3RhcnQsIHU2NCBlbmQsIGNvbnN0IGNoYXIgKnR5cGUpCitpbnQg
X19pbml0IGZpcm13YXJlX21hcF9hZGRfZWFybHkodTY0IHN0YXJ0LCB1NjQgZW5kLCBjb25zdCBj
aGFyICp0eXBlKQogewogCXN0cnVjdCBmaXJtd2FyZV9tYXBfZW50cnkgKmVudHJ5OwogCkBAIC0x
NDgsMjcgKzE2OCwzMSBAQCBpbnQgZmlybXdhcmVfbWFwX2FkZCh1NjQgc3RhcnQsIHU2NCBlbmQs
IGNvbnN0IGNoYXIgKnR5cGUpCiB9CiAKIC8qKgotICogZmlybXdhcmVfbWFwX2FkZF9lYXJseSgp
IC0gQWRkcyBhIGZpcm13YXJlIG1hcHBpbmcgZW50cnkuCisgKiBmaXJtd2FyZV9tYXBfYWRkX2hv
dHBsdWcoKSAtIEFkZHMgYSBmaXJtd2FyZSBtYXBwaW5nIGVudHJ5IHdoZW4gd2UgZG8KKyAqIG1l
bW9yeSBob3RwbHVnLgogICogQHN0YXJ0OiBTdGFydCBvZiB0aGUgbWVtb3J5IHJhbmdlLgogICog
QGVuZDogICBFbmQgb2YgdGhlIG1lbW9yeSByYW5nZSAoaW5jbHVzaXZlKS4KICAqIEB0eXBlOiAg
VHlwZSBvZiB0aGUgbWVtb3J5IHJhbmdlLgogICoKLSAqIEFkZHMgYSBmaXJtd2FyZSBtYXBwaW5n
IGVudHJ5LiBUaGlzIGZ1bmN0aW9uIHVzZXMgdGhlIGJvb3RtZW0gYWxsb2NhdG9yCi0gKiBmb3Ig
bWVtb3J5IGFsbG9jYXRpb24uIFVzZSBmaXJtd2FyZV9tYXBfYWRkKCkgaWYgeW91IHdhbnQgdG8g
dXNlIGttYWxsb2MoKS4KLSAqCi0gKiBUaGF0IGZ1bmN0aW9uIG11c3QgYmUgY2FsbGVkIGJlZm9y
ZSBsYXRlX2luaXRjYWxsLgorICogQWRkcyBhIGZpcm13YXJlIG1hcHBpbmcgZW50cnkuIFRoaXMg
ZnVuY3Rpb24gaXMgZm9yIG1lbW9yeSBob3RwbHVnLCBpdCBpcworICogc2ltaWFyIHdpdGggZnVu
Y3Rpb24gZmlybXdhcmVfbWFwX2FkZF9lYXJseS4gdGhlIG9ubHkgZGlmZmVyZW5jZSBpcyB0aGF0
CisgKiBpdCB3aWxsIGNyZWF0ZSB0aGUgc3lmcyBlbnRyeSBkeW5hbWljYWxseS4KICAqCiAgKiBS
ZXR1cm5zIDAgb24gc3VjY2Vzcywgb3IgLUVOT01FTSBpZiBubyBtZW1vcnkgY291bGQgYmUgYWxs
b2NhdGVkLgogICoqLwotaW50IF9faW5pdCBmaXJtd2FyZV9tYXBfYWRkX2Vhcmx5KHU2NCBzdGFy
dCwgdTY0IGVuZCwgY29uc3QgY2hhciAqdHlwZSkKK2ludCBfX21lbWluaXQgZmlybXdhcmVfbWFw
X2FkZF9ob3RwbHVnKHU2NCBzdGFydCwgdTY0IGVuZCwgY29uc3QgY2hhciAqdHlwZSkKIHsKIAlz
dHJ1Y3QgZmlybXdhcmVfbWFwX2VudHJ5ICplbnRyeTsKIAotCWVudHJ5ID0gYWxsb2NfYm9vdG1l
bShzaXplb2Yoc3RydWN0IGZpcm13YXJlX21hcF9lbnRyeSkpOwotCWlmIChXQVJOX09OKCFlbnRy
eSkpCisJZW50cnkgPSBremFsbG9jKHNpemVvZihzdHJ1Y3QgZmlybXdhcmVfbWFwX2VudHJ5KSwg
R0ZQX0FUT01JQyk7CisJaWYgKCFlbnRyeSkKIAkJcmV0dXJuIC1FTk9NRU07CiAKLQlyZXR1cm4g
ZmlybXdhcmVfbWFwX2FkZF9lbnRyeShzdGFydCwgZW5kLCB0eXBlLCBlbnRyeSk7CisJZmlybXdh
cmVfbWFwX2FkZF9lbnRyeShzdGFydCwgZW5kLCB0eXBlLCBlbnRyeSk7CisJLyogY3JlYXRlIHRo
ZSBtZW1tYXAgZW50cnkgKi8KKwlhZGRfc3lzZnNfZndfbWFwX2VudHJ5KGVudHJ5KTsKKworCXJl
dHVybiAwOwogfQogCiAvKgpAQCAtMjE0LDE4ICsyMzgsMTAgQEAgc3RhdGljIHNzaXplX3QgbWVt
bWFwX2F0dHJfc2hvdyhzdHJ1Y3Qga29iamVjdCAqa29iaiwKICAqLwogc3RhdGljIGludCBfX2lu
aXQgbWVtbWFwX2luaXQodm9pZCkKIHsKLQlpbnQgaSA9IDA7CiAJc3RydWN0IGZpcm13YXJlX21h
cF9lbnRyeSAqZW50cnk7Ci0Jc3RydWN0IGtzZXQgKm1lbW1hcF9rc2V0OwotCi0JbWVtbWFwX2tz
ZXQgPSBrc2V0X2NyZWF0ZV9hbmRfYWRkKCJtZW1tYXAiLCBOVUxMLCBmaXJtd2FyZV9rb2JqKTsK
LQlpZiAoV0FSTl9PTighbWVtbWFwX2tzZXQpKQotCQlyZXR1cm4gLUVOT01FTTsKIAogCWxpc3Rf
Zm9yX2VhY2hfZW50cnkoZW50cnksICZtYXBfZW50cmllcywgbGlzdCkgewotCQllbnRyeS0+a29i
ai5rc2V0ID0gbWVtbWFwX2tzZXQ7Ci0JCWlmIChrb2JqZWN0X2FkZCgmZW50cnktPmtvYmosIE5V
TEwsICIlZCIsIGkrKykpCi0JCQlrb2JqZWN0X3B1dCgmZW50cnktPmtvYmopOworCQlhZGRfc3lz
ZnNfZndfbWFwX2VudHJ5KGVudHJ5KTsKIAl9CiAKIAlyZXR1cm4gMDsKZGlmZiAtLWdpdCBhL2lu
Y2x1ZGUvbGludXgvZmlybXdhcmUtbWFwLmggYi9pbmNsdWRlL2xpbnV4L2Zpcm13YXJlLW1hcC5o
CmluZGV4IDg3NTQ1MWYuLmM2ZGNjMWQgMTAwNjQ0Ci0tLSBhL2luY2x1ZGUvbGludXgvZmlybXdh
cmUtbWFwLmgKKysrIGIvaW5jbHVkZS9saW51eC9maXJtd2FyZS1tYXAuaApAQCAtMjQsMTcgKzI0
LDE3IEBACiAgKi8KICNpZmRlZiBDT05GSUdfRklSTVdBUkVfTUVNTUFQCiAKLWludCBmaXJtd2Fy
ZV9tYXBfYWRkKHU2NCBzdGFydCwgdTY0IGVuZCwgY29uc3QgY2hhciAqdHlwZSk7CiBpbnQgZmly
bXdhcmVfbWFwX2FkZF9lYXJseSh1NjQgc3RhcnQsIHU2NCBlbmQsIGNvbnN0IGNoYXIgKnR5cGUp
OworaW50IGZpcm13YXJlX21hcF9hZGRfaG90cGx1Zyh1NjQgc3RhcnQsIHU2NCBlbmQsIGNvbnN0
IGNoYXIgKnR5cGUpOwogCiAjZWxzZSAvKiBDT05GSUdfRklSTVdBUkVfTUVNTUFQICovCiAKLXN0
YXRpYyBpbmxpbmUgaW50IGZpcm13YXJlX21hcF9hZGQodTY0IHN0YXJ0LCB1NjQgZW5kLCBjb25z
dCBjaGFyICp0eXBlKQorc3RhdGljIGlubGluZSBpbnQgZmlybXdhcmVfbWFwX2FkZF9lYXJseSh1
NjQgc3RhcnQsIHU2NCBlbmQsIGNvbnN0IGNoYXIgKnR5cGUpCiB7CiAJcmV0dXJuIDA7CiB9CiAK
LXN0YXRpYyBpbmxpbmUgaW50IGZpcm13YXJlX21hcF9hZGRfZWFybHkodTY0IHN0YXJ0LCB1NjQg
ZW5kLCBjb25zdCBjaGFyICp0eXBlKQorc3RhdGljIGlubGluZSBpbnQgZmlybXdhcmVfbWFwX2Fk
ZF9ob3RwbHVnKHU2NCBzdGFydCwgdTY0IGVuZCwgY29uc3QgY2hhciAqdHlwZSkKIHsKIAlyZXR1
cm4gMDsKIH0KZGlmZiAtLWdpdCBhL21tL21lbW9yeV9ob3RwbHVnLmMgYi9tbS9tZW1vcnlfaG90
cGx1Zy5jCmluZGV4IDAzMGNlOGEuLjc4ZTM0ZTYgMTAwNjQ0Ci0tLSBhL21tL21lbW9yeV9ob3Rw
bHVnLmMKKysrIGIvbW0vbWVtb3J5X2hvdHBsdWcuYwpAQCAtMjgsNiArMjgsNyBAQAogI2luY2x1
ZGUgPGxpbnV4L3Bmbi5oPgogI2luY2x1ZGUgPGxpbnV4L3N1c3BlbmQuaD4KICNpbmNsdWRlIDxs
aW51eC9tbV9pbmxpbmUuaD4KKyNpbmNsdWRlIDxsaW51eC9maXJtd2FyZS1tYXAuaD4KIAogI2lu
Y2x1ZGUgPGFzbS90bGJmbHVzaC5oPgogCkBAIC01MjMsNiArNTI0LDkgQEAgaW50IF9fcmVmIGFk
ZF9tZW1vcnkoaW50IG5pZCwgdTY0IHN0YXJ0LCB1NjQgc2l6ZSkKIAkJQlVHX09OKHJldCk7CiAJ
fQogCisJLyogY3JlYXRlIG5ldyBtZW1tYXAgZW50cnkgKi8KKwlmaXJtd2FyZV9tYXBfYWRkX2hv
dHBsdWcoc3RhcnQsIHN0YXJ0ICsgc2l6ZSwgIlN5c3RlbSBSQU0iKTsKKwogCWdvdG8gb3V0Owog
CiBlcnJvcjoK

--_002_DA586906BA1FFC4384FCFD6429ECE86031560F92shzsmsx502ccrco_--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
