Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id 748606B003D
	for <linux-mm@kvack.org>; Thu,  7 Jan 2010 22:17:03 -0500 (EST)
From: "Zheng, Shaohui" <shaohui.zheng@intel.com>
Date: Fri, 8 Jan 2010 11:16:13 +0800
Subject: [PATCH - resend ] memory-hotplug: create /sys/firmware/memmap entry
 for new memory(v3)
Message-ID: <DA586906BA1FFC4384FCFD6429ECE86031560B8D@shzsmsx502.ccr.corp.intel.com>
Content-Language: en-US
Content-Type: multipart/mixed;
	boundary="_002_DA586906BA1FFC4384FCFD6429ECE86031560B8Dshzsmsx502ccrco_"
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
To: "linux-mm@kvack.org" <linux-mm@kvack.org>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>
Cc: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "ak@linux.intel.com" <ak@linux.intel.com>, "y-goto@jp.fujitsu.com" <y-goto@jp.fujitsu.com>, Dave Hansen <haveblue@us.ibm.com>, "Wu, Fengguang" <fengguang.wu@intel.com>, "x86@kernel.org" <x86@kernel.org>
List-ID: <linux-mm.kvack.org>

--_002_DA586906BA1FFC4384FCFD6429ECE86031560B8Dshzsmsx502ccrco_
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: quoted-printable

Resend the patch to the mailing-list, the original patch URL is at=20
http://patchwork.kernel.org/patch/69071/. It is already reviewed, but It is=
 still not=20
accepted and no comments, I guess that it should be ignored since we have s=
o many=20
patches each day, send it again. =20

memory-hotplug: create /sys/firmware/memmap entry for hot-added memory

Interface firmware_map_add was not called in explicit, Remove it and add fu=
nction
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
Acked-by: Dave Hansen <dave@linux.vnet.ibm.com>
Reviewed-by: Wu Fengguang <fengguang.wu@intel.com>
---
diff --git a/drivers/firmware/memmap.c b/drivers/firmware/memmap.c
index 56f9234..ec8c3d4 100644
--- a/drivers/firmware/memmap.c
+++ b/drivers/firmware/memmap.c
@@ -123,52 +123,75 @@ static int firmware_map_add_entry(u64 start, u64 end,
 }
=20
 /**
- * firmware_map_add() - Adds a firmware mapping entry.
+ * Add memmap entry on sysfs
+ */
+static int add_sysfs_fw_map_entry(struct firmware_map_entry *entry) {
+	static int map_entries_nr;
+	static struct kset *mmap_kset;
+
+	if (!mmap_kset) {
+		mmap_kset =3D kset_create_and_add("memmap", NULL, firmware_kobj);
+		if (WARN_ON(!mmap_kset))
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
-	entry =3D kmalloc(sizeof(struct firmware_map_entry), GFP_ATOMIC);
-	if (!entry)
+	entry =3D alloc_bootmem(sizeof(struct firmware_map_entry));
+	if (WARN_ON(!entry))
 		return -ENOMEM;
=20
 	return firmware_map_add_entry(start, end, type, entry);
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
+	entry =3D kzalloc(sizeof(struct firmware_map_entry), GFP_ATOMIC);
 	if (WARN_ON(!entry))
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
@@ -214,18 +237,10 @@ static ssize_t memmap_attr_show(struct kobject *kobj,
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



--_002_DA586906BA1FFC4384FCFD6429ECE86031560B8Dshzsmsx502ccrco_
Content-Type: application/octet-stream; name=
	"memory-hotplug-create-sys-firmware-memmap-entry-for-new-memory-v3.patch"
Content-Description: memory-hotplug-create-sys-firmware-memmap-entry-for-new-memory-v3.patch
Content-Disposition: attachment; filename=
	"memory-hotplug-create-sys-firmware-memmap-entry-for-new-memory-v3.patch";
	size=5746; creation-date="Fri, 18 Dec 2009 16:26:02 GMT";
	modification-date="Mon, 21 Dec 2009 09:38:34 GMT"
Content-Transfer-Encoding: base64

bWVtb3J5LWhvdHBsdWc6IGNyZWF0ZSAvc3lzL2Zpcm13YXJlL21lbW1hcCBlbnRyeSBmb3IgaG90
LWFkZGVkIG1lbW9yeQoKSW50ZXJmYWNlIGZpcm13YXJlX21hcF9hZGQgd2FzIG5vdCBjYWxsZWQg
aW4gZXhwbGljaXQsIFJlbW92ZSBpdCBhbmQgYWRkIGZ1bmN0aW9uCmZpcm13YXJlX21hcF9hZGRf
aG90cGx1ZyBhcyBob3RwbHVnIGludGVyZmFjZSBvZiBtZW1tYXAuCgpXaGVuIHdlIGhvdC1hZGQg
bmV3IG1lbW9yeSwgc3lzZnMgZG9lcyBub3QgZXhwb3J0IG1lbW1hcCBlbnRyeSBmb3IgaXQuIHdl
IGFkZAogYSBjYWxsIGluIGZ1bmN0aW9uIGFkZF9tZW1vcnkgdG8gZnVuY3Rpb24gZmlybXdhcmVf
bWFwX2FkZF9ob3RwbHVnLgoKQWRkIGEgbmV3IGZ1bmN0aW9uIGFkZF9zeXNmc19md19tYXBfZW50
cnkgdG8gY3JlYXRlIG1lbW1hcCBlbnRyeSwgaXQgY2FuIGF2b2lkIApkdXBsaWNhdGVkIGNvZGVz
LgoKVGhhbmtzIGZvciB0aGUgY2FyZWZ1bCByZXZpZXcgZnJvbSBGZW5nZ3VhbmcgV3UgYW5kIERh
dmUgSGFuc2VuLgoKU2lnbmVkLW9mZi1ieTogU2hhb2h1aSBaaGVuZyA8c2hhb2h1aS56aGVuZ0Bp
bnRlbC5jb20+CkFja2VkLWJ5OiBBbmRpIEtsZWVuIDxha0BsaW51eC5pbnRlbC5jb20+CkFja2Vk
LWJ5OiBZYXN1bm9yaSBHb3RvIDx5LWdvdG9AanAuZnVqaXRzdS5jb20+CkFja2VkLWJ5OiBEYXZl
IEhhbnNlbiA8ZGF2ZUBsaW51eC52bmV0LmlibS5jb20+ClJldmlld2VkLWJ5OiBXdSBGZW5nZ3Vh
bmcgPGZlbmdndWFuZy53dUBpbnRlbC5jb20+Ci0tLQpkaWZmIC0tZ2l0IGEvZHJpdmVycy9maXJt
d2FyZS9tZW1tYXAuYyBiL2RyaXZlcnMvZmlybXdhcmUvbWVtbWFwLmMKaW5kZXggNTZmOTIzNC4u
ZWM4YzNkNCAxMDA2NDQKLS0tIGEvZHJpdmVycy9maXJtd2FyZS9tZW1tYXAuYworKysgYi9kcml2
ZXJzL2Zpcm13YXJlL21lbW1hcC5jCkBAIC0xMjMsNTIgKzEyMyw3NSBAQCBzdGF0aWMgaW50IGZp
cm13YXJlX21hcF9hZGRfZW50cnkodTY0IHN0YXJ0LCB1NjQgZW5kLAogfQogCiAvKioKLSAqIGZp
cm13YXJlX21hcF9hZGQoKSAtIEFkZHMgYSBmaXJtd2FyZSBtYXBwaW5nIGVudHJ5LgorICogQWRk
IG1lbW1hcCBlbnRyeSBvbiBzeXNmcworICovCitzdGF0aWMgaW50IGFkZF9zeXNmc19md19tYXBf
ZW50cnkoc3RydWN0IGZpcm13YXJlX21hcF9lbnRyeSAqZW50cnkpIHsKKwlzdGF0aWMgaW50IG1h
cF9lbnRyaWVzX25yOworCXN0YXRpYyBzdHJ1Y3Qga3NldCAqbW1hcF9rc2V0OworCisJaWYgKCFt
bWFwX2tzZXQpIHsKKwkJbW1hcF9rc2V0ID0ga3NldF9jcmVhdGVfYW5kX2FkZCgibWVtbWFwIiwg
TlVMTCwgZmlybXdhcmVfa29iaik7CisJCWlmIChXQVJOX09OKCFtbWFwX2tzZXQpKQorCQkJcmV0
dXJuIC1FTk9NRU07CisJfQorCisJZW50cnktPmtvYmoua3NldCA9IG1tYXBfa3NldDsKKwlpZiAo
a29iamVjdF9hZGQoJmVudHJ5LT5rb2JqLCBOVUxMLCAiJWQiLCBtYXBfZW50cmllc19ucisrKSkK
KwkJa29iamVjdF9wdXQoJmVudHJ5LT5rb2JqKTsKKworCXJldHVybiAwOworfQorCisvKioKKyAq
IGZpcm13YXJlX21hcF9hZGRfZWFybHkoKSAtIEFkZHMgYSBmaXJtd2FyZSBtYXBwaW5nIGVudHJ5
LgogICogQHN0YXJ0OiBTdGFydCBvZiB0aGUgbWVtb3J5IHJhbmdlLgogICogQGVuZDogICBFbmQg
b2YgdGhlIG1lbW9yeSByYW5nZSAoaW5jbHVzaXZlKS4KICAqIEB0eXBlOiAgVHlwZSBvZiB0aGUg
bWVtb3J5IHJhbmdlLgogICoKLSAqIFRoaXMgZnVuY3Rpb24gdXNlcyBrbWFsbG9jKCkgZm9yIG1l
bW9yeQotICogYWxsb2NhdGlvbi4gVXNlIGZpcm13YXJlX21hcF9hZGRfZWFybHkoKSBpZiB5b3Ug
d2FudCB0byB1c2UgdGhlIGJvb3RtZW0KLSAqIGFsbG9jYXRvci4KKyAqIEFkZHMgYSBmaXJtd2Fy
ZSBtYXBwaW5nIGVudHJ5LiBUaGlzIGZ1bmN0aW9uIHVzZXMgdGhlIGJvb3RtZW0gYWxsb2NhdG9y
CisgKiBmb3IgbWVtb3J5IGFsbG9jYXRpb24uCiAgKgogICogVGhhdCBmdW5jdGlvbiBtdXN0IGJl
IGNhbGxlZCBiZWZvcmUgbGF0ZV9pbml0Y2FsbC4KICAqCiAgKiBSZXR1cm5zIDAgb24gc3VjY2Vz
cywgb3IgLUVOT01FTSBpZiBubyBtZW1vcnkgY291bGQgYmUgYWxsb2NhdGVkLgogICoqLwotaW50
IGZpcm13YXJlX21hcF9hZGQodTY0IHN0YXJ0LCB1NjQgZW5kLCBjb25zdCBjaGFyICp0eXBlKQor
aW50IF9faW5pdCBmaXJtd2FyZV9tYXBfYWRkX2Vhcmx5KHU2NCBzdGFydCwgdTY0IGVuZCwgY29u
c3QgY2hhciAqdHlwZSkKIHsKIAlzdHJ1Y3QgZmlybXdhcmVfbWFwX2VudHJ5ICplbnRyeTsKIAot
CWVudHJ5ID0ga21hbGxvYyhzaXplb2Yoc3RydWN0IGZpcm13YXJlX21hcF9lbnRyeSksIEdGUF9B
VE9NSUMpOwotCWlmICghZW50cnkpCisJZW50cnkgPSBhbGxvY19ib290bWVtKHNpemVvZihzdHJ1
Y3QgZmlybXdhcmVfbWFwX2VudHJ5KSk7CisJaWYgKFdBUk5fT04oIWVudHJ5KSkKIAkJcmV0dXJu
IC1FTk9NRU07CiAKIAlyZXR1cm4gZmlybXdhcmVfbWFwX2FkZF9lbnRyeShzdGFydCwgZW5kLCB0
eXBlLCBlbnRyeSk7CiB9CiAKIC8qKgotICogZmlybXdhcmVfbWFwX2FkZF9lYXJseSgpIC0gQWRk
cyBhIGZpcm13YXJlIG1hcHBpbmcgZW50cnkuCisgKiBmaXJtd2FyZV9tYXBfYWRkX2hvdHBsdWco
KSAtIEFkZHMgYSBmaXJtd2FyZSBtYXBwaW5nIGVudHJ5IHdoZW4gd2UgZG8KKyAqIG1lbW9yeSBo
b3RwbHVnLgogICogQHN0YXJ0OiBTdGFydCBvZiB0aGUgbWVtb3J5IHJhbmdlLgogICogQGVuZDog
ICBFbmQgb2YgdGhlIG1lbW9yeSByYW5nZSAoaW5jbHVzaXZlKS4KICAqIEB0eXBlOiAgVHlwZSBv
ZiB0aGUgbWVtb3J5IHJhbmdlLgogICoKLSAqIEFkZHMgYSBmaXJtd2FyZSBtYXBwaW5nIGVudHJ5
LiBUaGlzIGZ1bmN0aW9uIHVzZXMgdGhlIGJvb3RtZW0gYWxsb2NhdG9yCi0gKiBmb3IgbWVtb3J5
IGFsbG9jYXRpb24uIFVzZSBmaXJtd2FyZV9tYXBfYWRkKCkgaWYgeW91IHdhbnQgdG8gdXNlIGtt
YWxsb2MoKS4KLSAqCi0gKiBUaGF0IGZ1bmN0aW9uIG11c3QgYmUgY2FsbGVkIGJlZm9yZSBsYXRl
X2luaXRjYWxsLgorICogQWRkcyBhIGZpcm13YXJlIG1hcHBpbmcgZW50cnkuIFRoaXMgZnVuY3Rp
b24gaXMgZm9yIG1lbW9yeSBob3RwbHVnLCBpdCBpcworICogc2ltaWFyIHdpdGggZnVuY3Rpb24g
ZmlybXdhcmVfbWFwX2FkZF9lYXJseS4gdGhlIG9ubHkgZGlmZmVyZW5jZSBpcyB0aGF0CisgKiBp
dCB3aWxsIGNyZWF0ZSB0aGUgc3lmcyBlbnRyeSBkeW5hbWljYWxseS4KICAqCiAgKiBSZXR1cm5z
IDAgb24gc3VjY2Vzcywgb3IgLUVOT01FTSBpZiBubyBtZW1vcnkgY291bGQgYmUgYWxsb2NhdGVk
LgogICoqLwotaW50IF9faW5pdCBmaXJtd2FyZV9tYXBfYWRkX2Vhcmx5KHU2NCBzdGFydCwgdTY0
IGVuZCwgY29uc3QgY2hhciAqdHlwZSkKK2ludCBfX21lbWluaXQgZmlybXdhcmVfbWFwX2FkZF9o
b3RwbHVnKHU2NCBzdGFydCwgdTY0IGVuZCwgY29uc3QgY2hhciAqdHlwZSkKIHsKIAlzdHJ1Y3Qg
ZmlybXdhcmVfbWFwX2VudHJ5ICplbnRyeTsKIAotCWVudHJ5ID0gYWxsb2NfYm9vdG1lbShzaXpl
b2Yoc3RydWN0IGZpcm13YXJlX21hcF9lbnRyeSkpOworCWVudHJ5ID0ga3phbGxvYyhzaXplb2Yo
c3RydWN0IGZpcm13YXJlX21hcF9lbnRyeSksIEdGUF9BVE9NSUMpOwogCWlmIChXQVJOX09OKCFl
bnRyeSkpCiAJCXJldHVybiAtRU5PTUVNOwogCi0JcmV0dXJuIGZpcm13YXJlX21hcF9hZGRfZW50
cnkoc3RhcnQsIGVuZCwgdHlwZSwgZW50cnkpOworCWZpcm13YXJlX21hcF9hZGRfZW50cnkoc3Rh
cnQsIGVuZCwgdHlwZSwgZW50cnkpOworCS8qIGNyZWF0ZSB0aGUgbWVtbWFwIGVudHJ5ICovCisJ
YWRkX3N5c2ZzX2Z3X21hcF9lbnRyeShlbnRyeSk7CisKKwlyZXR1cm4gMDsKIH0KIAogLyoKQEAg
LTIxNCwxOCArMjM3LDEwIEBAIHN0YXRpYyBzc2l6ZV90IG1lbW1hcF9hdHRyX3Nob3coc3RydWN0
IGtvYmplY3QgKmtvYmosCiAgKi8KIHN0YXRpYyBpbnQgX19pbml0IG1lbW1hcF9pbml0KHZvaWQp
CiB7Ci0JaW50IGkgPSAwOwogCXN0cnVjdCBmaXJtd2FyZV9tYXBfZW50cnkgKmVudHJ5OwotCXN0
cnVjdCBrc2V0ICptZW1tYXBfa3NldDsKLQotCW1lbW1hcF9rc2V0ID0ga3NldF9jcmVhdGVfYW5k
X2FkZCgibWVtbWFwIiwgTlVMTCwgZmlybXdhcmVfa29iaik7Ci0JaWYgKFdBUk5fT04oIW1lbW1h
cF9rc2V0KSkKLQkJcmV0dXJuIC1FTk9NRU07CiAKIAlsaXN0X2Zvcl9lYWNoX2VudHJ5KGVudHJ5
LCAmbWFwX2VudHJpZXMsIGxpc3QpIHsKLQkJZW50cnktPmtvYmoua3NldCA9IG1lbW1hcF9rc2V0
OwotCQlpZiAoa29iamVjdF9hZGQoJmVudHJ5LT5rb2JqLCBOVUxMLCAiJWQiLCBpKyspKQotCQkJ
a29iamVjdF9wdXQoJmVudHJ5LT5rb2JqKTsKKwkJYWRkX3N5c2ZzX2Z3X21hcF9lbnRyeShlbnRy
eSk7CiAJfQogCiAJcmV0dXJuIDA7CmRpZmYgLS1naXQgYS9pbmNsdWRlL2xpbnV4L2Zpcm13YXJl
LW1hcC5oIGIvaW5jbHVkZS9saW51eC9maXJtd2FyZS1tYXAuaAppbmRleCA4NzU0NTFmLi5jNmRj
YzFkIDEwMDY0NAotLS0gYS9pbmNsdWRlL2xpbnV4L2Zpcm13YXJlLW1hcC5oCisrKyBiL2luY2x1
ZGUvbGludXgvZmlybXdhcmUtbWFwLmgKQEAgLTI0LDE3ICsyNCwxNyBAQAogICovCiAjaWZkZWYg
Q09ORklHX0ZJUk1XQVJFX01FTU1BUAogCi1pbnQgZmlybXdhcmVfbWFwX2FkZCh1NjQgc3RhcnQs
IHU2NCBlbmQsIGNvbnN0IGNoYXIgKnR5cGUpOwogaW50IGZpcm13YXJlX21hcF9hZGRfZWFybHko
dTY0IHN0YXJ0LCB1NjQgZW5kLCBjb25zdCBjaGFyICp0eXBlKTsKK2ludCBmaXJtd2FyZV9tYXBf
YWRkX2hvdHBsdWcodTY0IHN0YXJ0LCB1NjQgZW5kLCBjb25zdCBjaGFyICp0eXBlKTsKIAogI2Vs
c2UgLyogQ09ORklHX0ZJUk1XQVJFX01FTU1BUCAqLwogCi1zdGF0aWMgaW5saW5lIGludCBmaXJt
d2FyZV9tYXBfYWRkKHU2NCBzdGFydCwgdTY0IGVuZCwgY29uc3QgY2hhciAqdHlwZSkKK3N0YXRp
YyBpbmxpbmUgaW50IGZpcm13YXJlX21hcF9hZGRfZWFybHkodTY0IHN0YXJ0LCB1NjQgZW5kLCBj
b25zdCBjaGFyICp0eXBlKQogewogCXJldHVybiAwOwogfQogCi1zdGF0aWMgaW5saW5lIGludCBm
aXJtd2FyZV9tYXBfYWRkX2Vhcmx5KHU2NCBzdGFydCwgdTY0IGVuZCwgY29uc3QgY2hhciAqdHlw
ZSkKK3N0YXRpYyBpbmxpbmUgaW50IGZpcm13YXJlX21hcF9hZGRfaG90cGx1Zyh1NjQgc3RhcnQs
IHU2NCBlbmQsIGNvbnN0IGNoYXIgKnR5cGUpCiB7CiAJcmV0dXJuIDA7CiB9CmRpZmYgLS1naXQg
YS9tbS9tZW1vcnlfaG90cGx1Zy5jIGIvbW0vbWVtb3J5X2hvdHBsdWcuYwppbmRleCAwMzBjZThh
Li43OGUzNGU2IDEwMDY0NAotLS0gYS9tbS9tZW1vcnlfaG90cGx1Zy5jCisrKyBiL21tL21lbW9y
eV9ob3RwbHVnLmMKQEAgLTI4LDYgKzI4LDcgQEAKICNpbmNsdWRlIDxsaW51eC9wZm4uaD4KICNp
bmNsdWRlIDxsaW51eC9zdXNwZW5kLmg+CiAjaW5jbHVkZSA8bGludXgvbW1faW5saW5lLmg+Cisj
aW5jbHVkZSA8bGludXgvZmlybXdhcmUtbWFwLmg+CiAKICNpbmNsdWRlIDxhc20vdGxiZmx1c2gu
aD4KIApAQCAtNTIzLDYgKzUyNCw5IEBAIGludCBfX3JlZiBhZGRfbWVtb3J5KGludCBuaWQsIHU2
NCBzdGFydCwgdTY0IHNpemUpCiAJCUJVR19PTihyZXQpOwogCX0KIAorCS8qIGNyZWF0ZSBuZXcg
bWVtbWFwIGVudHJ5ICovCisJZmlybXdhcmVfbWFwX2FkZF9ob3RwbHVnKHN0YXJ0LCBzdGFydCAr
IHNpemUsICJTeXN0ZW0gUkFNIik7CisKIAlnb3RvIG91dDsKIAogZXJyb3I6Cg==

--_002_DA586906BA1FFC4384FCFD6429ECE86031560B8Dshzsmsx502ccrco_--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
