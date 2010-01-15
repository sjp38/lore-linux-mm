Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id 1F81F6B0047
	for <linux-mm@kvack.org>; Fri, 15 Jan 2010 09:34:08 -0500 (EST)
From: "Zheng, Shaohui" <shaohui.zheng@intel.com>
Date: Fri, 15 Jan 2010 22:33:54 +0800
Subject: [PATCH-RESEND v5] memory-hotplug: create /sys/firmware/memmap entry
 for new memory
Message-ID: <DA586906BA1FFC4384FCFD6429ECE86034FF85C5@shzsmsx502.ccr.corp.intel.com>
References: <DA586906BA1FFC4384FCFD6429ECE86031560F92@shzsmsx502.ccr.corp.intel.com>
 <20100113142827.26b2269e.akpm@linux-foundation.org>
In-Reply-To: <20100113142827.26b2269e.akpm@linux-foundation.org>
Content-Language: en-US
Content-Type: multipart/mixed;
	boundary="_002_DA586906BA1FFC4384FCFD6429ECE86034FF85C5shzsmsx502ccrco_"
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "ak@linux.intel.com" <ak@linux.intel.com>, "y-goto@jp.fujitsu.com" <y-goto@jp.fujitsu.com>, Dave Hansen <haveblue@us.ibm.com>, "Wu, Fengguang" <fengguang.wu@intel.com>, "x86@kernel.org" <x86@kernel.org>
List-ID: <linux-mm.kvack.org>

--_002_DA586906BA1FFC4384FCFD6429ECE86034FF85C5shzsmsx502ccrco_
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: quoted-printable

memory-hotplug: create /sys/firmware/memmap entry for new memory

A memmap is a directory in sysfys which includes 3 text files: start, end a=
nd
 type. For example:
start: 	0x100000
end:	0x7e7b1cff
type:	System RAM

Each memory entry has a memmap in sysfs, When we hot-add new memory, sysfs =
does
not export memmap entry for it. We add a call in function add_memory to fun=
ction
 firmware_map_add_hotplug.

Interface firmware_map_add was not called explictly. Remove it and add func=
tion
 firmware_map_add_hotplug as hotplug interface of memmap. =20

Add a new function add_sysfs_fw_map_entry() to create memmap entry, it will=
 be
called when initialize memmap and hot-add memory.

Signed-off-by: Shaohui Zheng <shaohui.zheng@intel.com>
Acked-by: Andi Kleen <ak@linux.intel.com>
Acked-by: Yasunori Goto <y-goto@jp.fujitsu.com>
Reviewed-by: Wu Fengguang <fengguang.wu@intel.com>
Cc: Dave Hansen <haveblue@us.ibm.com>
Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
diff --git a/drivers/firmware/memmap.c b/drivers/firmware/memmap.c
index 56f9234..2d1812f 100644
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
+ * similar to function firmware_map_add_early(). The only difference is th=
at
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
@@ -214,19 +238,10 @@ static ssize_t memmap_attr_show(struct kobject *kobj,
  */
 static int __init memmap_init(void)
 {
-	int i =3D 0;
 	struct firmware_map_entry *entry;
-	struct kset *memmap_kset;
=20
-	memmap_kset =3D kset_create_and_add("memmap", NULL, firmware_kobj);
-	if (WARN_ON(!memmap_kset))
-		return -ENOMEM;
-
-	list_for_each_entry(entry, &map_entries, list) {
-		entry->kobj.kset =3D memmap_kset;
-		if (kobject_add(&entry->kobj, NULL, "%d", i++))
-			kobject_put(&entry->kobj);
-	}
+	list_for_each_entry(entry, &map_entries, list)
+		add_sysfs_fw_map_entry(entry);
=20
 	return 0;
 }
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


--_002_DA586906BA1FFC4384FCFD6429ECE86034FF85C5shzsmsx502ccrco_
Content-Type: application/octet-stream; name=
	"memory-hotplug-create-sys-firmware-memmap-entry-for-new-memory-v5.patch"
Content-Description: memory-hotplug-create-sys-firmware-memmap-entry-for-new-memory-v5.patch
Content-Disposition: attachment; filename=
	"memory-hotplug-create-sys-firmware-memmap-entry-for-new-memory-v5.patch";
	size=5837; creation-date="Fri, 15 Jan 2010 22:32:47 GMT";
	modification-date="Sat, 16 Jan 2010 06:19:01 GMT"
Content-Transfer-Encoding: base64

bWVtb3J5LWhvdHBsdWc6IGNyZWF0ZSAvc3lzL2Zpcm13YXJlL21lbW1hcCBlbnRyeSBmb3IgbmV3
IG1lbW9yeQoKQSBtZW1tYXAgaXMgYSBkaXJlY3RvcnkgaW4gc3lzZnlzIHdoaWNoIGluY2x1ZGVz
IDMgdGV4dCBmaWxlczogc3RhcnQsIGVuZCBhbmQKIHR5cGUuIEZvciBleGFtcGxlOgpzdGFydDog
CTB4MTAwMDAwCmVuZDoJMHg3ZTdiMWNmZgp0eXBlOglTeXN0ZW0gUkFNCgpFYWNoIG1lbW9yeSBl
bnRyeSBoYXMgYSBtZW1tYXAgaW4gc3lzZnMsIFdoZW4gd2UgaG90LWFkZCBuZXcgbWVtb3J5LCBz
eXNmcyBkb2VzCm5vdCBleHBvcnQgbWVtbWFwIGVudHJ5IGZvciBpdC4gV2UgYWRkIGEgY2FsbCBp
biBmdW5jdGlvbiBhZGRfbWVtb3J5IHRvIGZ1bmN0aW9uCiBmaXJtd2FyZV9tYXBfYWRkX2hvdHBs
dWcuCgpJbnRlcmZhY2UgZmlybXdhcmVfbWFwX2FkZCB3YXMgbm90IGNhbGxlZCBleHBsaWN0bHku
IFJlbW92ZSBpdCBhbmQgYWRkIGZ1bmN0aW9uCiBmaXJtd2FyZV9tYXBfYWRkX2hvdHBsdWcgYXMg
aG90cGx1ZyBpbnRlcmZhY2Ugb2YgbWVtbWFwLiAgCgpBZGQgYSBuZXcgZnVuY3Rpb24gYWRkX3N5
c2ZzX2Z3X21hcF9lbnRyeSgpIHRvIGNyZWF0ZSBtZW1tYXAgZW50cnksIGl0IHdpbGwgYmUKY2Fs
bGVkIHdoZW4gaW5pdGlhbGl6ZSBtZW1tYXAgYW5kIGhvdC1hZGQgbWVtb3J5LgoKU2lnbmVkLW9m
Zi1ieTogU2hhb2h1aSBaaGVuZyA8c2hhb2h1aS56aGVuZ0BpbnRlbC5jb20+CkFja2VkLWJ5OiBB
bmRpIEtsZWVuIDxha0BsaW51eC5pbnRlbC5jb20+CkFja2VkLWJ5OiBZYXN1bm9yaSBHb3RvIDx5
LWdvdG9AanAuZnVqaXRzdS5jb20+ClJldmlld2VkLWJ5OiBXdSBGZW5nZ3VhbmcgPGZlbmdndWFu
Zy53dUBpbnRlbC5jb20+CkNjOiBEYXZlIEhhbnNlbiA8aGF2ZWJsdWVAdXMuaWJtLmNvbT4KU2ln
bmVkLW9mZi1ieTogQW5kcmV3IE1vcnRvbiA8YWtwbUBsaW51eC1mb3VuZGF0aW9uLm9yZz4KZGlm
ZiAtLWdpdCBhL2RyaXZlcnMvZmlybXdhcmUvbWVtbWFwLmMgYi9kcml2ZXJzL2Zpcm13YXJlL21l
bW1hcC5jCmluZGV4IDU2ZjkyMzQuLjJkMTgxMmYgMTAwNjQ0Ci0tLSBhL2RyaXZlcnMvZmlybXdh
cmUvbWVtbWFwLmMKKysrIGIvZHJpdmVycy9maXJtd2FyZS9tZW1tYXAuYwpAQCAtMTIzLDIwICsx
MjMsNDAgQEAgc3RhdGljIGludCBmaXJtd2FyZV9tYXBfYWRkX2VudHJ5KHU2NCBzdGFydCwgdTY0
IGVuZCwKIH0KIAogLyoqCi0gKiBmaXJtd2FyZV9tYXBfYWRkKCkgLSBBZGRzIGEgZmlybXdhcmUg
bWFwcGluZyBlbnRyeS4KKyAqIEFkZCBtZW1tYXAgZW50cnkgb24gc3lzZnMKKyAqLworc3RhdGlj
IGludCBhZGRfc3lzZnNfZndfbWFwX2VudHJ5KHN0cnVjdCBmaXJtd2FyZV9tYXBfZW50cnkgKmVu
dHJ5KQoreworCXN0YXRpYyBpbnQgbWFwX2VudHJpZXNfbnI7CisJc3RhdGljIHN0cnVjdCBrc2V0
ICptbWFwX2tzZXQ7CisKKwlpZiAoIW1tYXBfa3NldCkgeworCQltbWFwX2tzZXQgPSBrc2V0X2Ny
ZWF0ZV9hbmRfYWRkKCJtZW1tYXAiLCBOVUxMLCBmaXJtd2FyZV9rb2JqKTsKKwkJaWYgKCFtbWFw
X2tzZXQpCisJCQlyZXR1cm4gLUVOT01FTTsKKwl9CisKKwllbnRyeS0+a29iai5rc2V0ID0gbW1h
cF9rc2V0OworCWlmIChrb2JqZWN0X2FkZCgmZW50cnktPmtvYmosIE5VTEwsICIlZCIsIG1hcF9l
bnRyaWVzX25yKyspKQorCQlrb2JqZWN0X3B1dCgmZW50cnktPmtvYmopOworCisJcmV0dXJuIDA7
Cit9CisKKy8qKgorICogZmlybXdhcmVfbWFwX2FkZF9lYXJseSgpIC0gQWRkcyBhIGZpcm13YXJl
IG1hcHBpbmcgZW50cnkuCiAgKiBAc3RhcnQ6IFN0YXJ0IG9mIHRoZSBtZW1vcnkgcmFuZ2UuCiAg
KiBAZW5kOiAgIEVuZCBvZiB0aGUgbWVtb3J5IHJhbmdlIChpbmNsdXNpdmUpLgogICogQHR5cGU6
ICBUeXBlIG9mIHRoZSBtZW1vcnkgcmFuZ2UuCiAgKgotICogVGhpcyBmdW5jdGlvbiB1c2VzIGtt
YWxsb2MoKSBmb3IgbWVtb3J5Ci0gKiBhbGxvY2F0aW9uLiBVc2UgZmlybXdhcmVfbWFwX2FkZF9l
YXJseSgpIGlmIHlvdSB3YW50IHRvIHVzZSB0aGUgYm9vdG1lbQotICogYWxsb2NhdG9yLgorICog
QWRkcyBhIGZpcm13YXJlIG1hcHBpbmcgZW50cnkuIFRoaXMgZnVuY3Rpb24gdXNlcyB0aGUgYm9v
dG1lbSBhbGxvY2F0b3IKKyAqIGZvciBtZW1vcnkgYWxsb2NhdGlvbi4KICAqCiAgKiBUaGF0IGZ1
bmN0aW9uIG11c3QgYmUgY2FsbGVkIGJlZm9yZSBsYXRlX2luaXRjYWxsLgogICoKICAqIFJldHVy
bnMgMCBvbiBzdWNjZXNzLCBvciAtRU5PTUVNIGlmIG5vIG1lbW9yeSBjb3VsZCBiZSBhbGxvY2F0
ZWQuCiAgKiovCi1pbnQgZmlybXdhcmVfbWFwX2FkZCh1NjQgc3RhcnQsIHU2NCBlbmQsIGNvbnN0
IGNoYXIgKnR5cGUpCitpbnQgX19pbml0IGZpcm13YXJlX21hcF9hZGRfZWFybHkodTY0IHN0YXJ0
LCB1NjQgZW5kLCBjb25zdCBjaGFyICp0eXBlKQogewogCXN0cnVjdCBmaXJtd2FyZV9tYXBfZW50
cnkgKmVudHJ5OwogCkBAIC0xNDgsMjcgKzE2OCwzMSBAQCBpbnQgZmlybXdhcmVfbWFwX2FkZCh1
NjQgc3RhcnQsIHU2NCBlbmQsIGNvbnN0IGNoYXIgKnR5cGUpCiB9CiAKIC8qKgotICogZmlybXdh
cmVfbWFwX2FkZF9lYXJseSgpIC0gQWRkcyBhIGZpcm13YXJlIG1hcHBpbmcgZW50cnkuCisgKiBm
aXJtd2FyZV9tYXBfYWRkX2hvdHBsdWcoKSAtIEFkZHMgYSBmaXJtd2FyZSBtYXBwaW5nIGVudHJ5
IHdoZW4gd2UgZG8KKyAqIG1lbW9yeSBob3RwbHVnLgogICogQHN0YXJ0OiBTdGFydCBvZiB0aGUg
bWVtb3J5IHJhbmdlLgogICogQGVuZDogICBFbmQgb2YgdGhlIG1lbW9yeSByYW5nZSAoaW5jbHVz
aXZlKS4KICAqIEB0eXBlOiAgVHlwZSBvZiB0aGUgbWVtb3J5IHJhbmdlLgogICoKLSAqIEFkZHMg
YSBmaXJtd2FyZSBtYXBwaW5nIGVudHJ5LiBUaGlzIGZ1bmN0aW9uIHVzZXMgdGhlIGJvb3RtZW0g
YWxsb2NhdG9yCi0gKiBmb3IgbWVtb3J5IGFsbG9jYXRpb24uIFVzZSBmaXJtd2FyZV9tYXBfYWRk
KCkgaWYgeW91IHdhbnQgdG8gdXNlIGttYWxsb2MoKS4KLSAqCi0gKiBUaGF0IGZ1bmN0aW9uIG11
c3QgYmUgY2FsbGVkIGJlZm9yZSBsYXRlX2luaXRjYWxsLgorICogQWRkcyBhIGZpcm13YXJlIG1h
cHBpbmcgZW50cnkuIFRoaXMgZnVuY3Rpb24gaXMgZm9yIG1lbW9yeSBob3RwbHVnLCBpdCBpcwor
ICogc2ltaWxhciB0byBmdW5jdGlvbiBmaXJtd2FyZV9tYXBfYWRkX2Vhcmx5KCkuIFRoZSBvbmx5
IGRpZmZlcmVuY2UgaXMgdGhhdAorICogaXQgd2lsbCBjcmVhdGUgdGhlIHN5ZnMgZW50cnkgZHlu
YW1pY2FsbHkuCiAgKgogICogUmV0dXJucyAwIG9uIHN1Y2Nlc3MsIG9yIC1FTk9NRU0gaWYgbm8g
bWVtb3J5IGNvdWxkIGJlIGFsbG9jYXRlZC4KICAqKi8KLWludCBfX2luaXQgZmlybXdhcmVfbWFw
X2FkZF9lYXJseSh1NjQgc3RhcnQsIHU2NCBlbmQsIGNvbnN0IGNoYXIgKnR5cGUpCitpbnQgX19t
ZW1pbml0IGZpcm13YXJlX21hcF9hZGRfaG90cGx1Zyh1NjQgc3RhcnQsIHU2NCBlbmQsIGNvbnN0
IGNoYXIgKnR5cGUpCiB7CiAJc3RydWN0IGZpcm13YXJlX21hcF9lbnRyeSAqZW50cnk7CiAKLQll
bnRyeSA9IGFsbG9jX2Jvb3RtZW0oc2l6ZW9mKHN0cnVjdCBmaXJtd2FyZV9tYXBfZW50cnkpKTsK
LQlpZiAoV0FSTl9PTighZW50cnkpKQorCWVudHJ5ID0ga3phbGxvYyhzaXplb2Yoc3RydWN0IGZp
cm13YXJlX21hcF9lbnRyeSksIEdGUF9BVE9NSUMpOworCWlmICghZW50cnkpCiAJCXJldHVybiAt
RU5PTUVNOwogCi0JcmV0dXJuIGZpcm13YXJlX21hcF9hZGRfZW50cnkoc3RhcnQsIGVuZCwgdHlw
ZSwgZW50cnkpOworCWZpcm13YXJlX21hcF9hZGRfZW50cnkoc3RhcnQsIGVuZCwgdHlwZSwgZW50
cnkpOworCS8qIGNyZWF0ZSB0aGUgbWVtbWFwIGVudHJ5ICovCisJYWRkX3N5c2ZzX2Z3X21hcF9l
bnRyeShlbnRyeSk7CisKKwlyZXR1cm4gMDsKIH0KIAogLyoKQEAgLTIxNCwxOSArMjM4LDEwIEBA
IHN0YXRpYyBzc2l6ZV90IG1lbW1hcF9hdHRyX3Nob3coc3RydWN0IGtvYmplY3QgKmtvYmosCiAg
Ki8KIHN0YXRpYyBpbnQgX19pbml0IG1lbW1hcF9pbml0KHZvaWQpCiB7Ci0JaW50IGkgPSAwOwog
CXN0cnVjdCBmaXJtd2FyZV9tYXBfZW50cnkgKmVudHJ5OwotCXN0cnVjdCBrc2V0ICptZW1tYXBf
a3NldDsKIAotCW1lbW1hcF9rc2V0ID0ga3NldF9jcmVhdGVfYW5kX2FkZCgibWVtbWFwIiwgTlVM
TCwgZmlybXdhcmVfa29iaik7Ci0JaWYgKFdBUk5fT04oIW1lbW1hcF9rc2V0KSkKLQkJcmV0dXJu
IC1FTk9NRU07Ci0KLQlsaXN0X2Zvcl9lYWNoX2VudHJ5KGVudHJ5LCAmbWFwX2VudHJpZXMsIGxp
c3QpIHsKLQkJZW50cnktPmtvYmoua3NldCA9IG1lbW1hcF9rc2V0OwotCQlpZiAoa29iamVjdF9h
ZGQoJmVudHJ5LT5rb2JqLCBOVUxMLCAiJWQiLCBpKyspKQotCQkJa29iamVjdF9wdXQoJmVudHJ5
LT5rb2JqKTsKLQl9CisJbGlzdF9mb3JfZWFjaF9lbnRyeShlbnRyeSwgJm1hcF9lbnRyaWVzLCBs
aXN0KQorCQlhZGRfc3lzZnNfZndfbWFwX2VudHJ5KGVudHJ5KTsKIAogCXJldHVybiAwOwogfQpk
aWZmIC0tZ2l0IGEvaW5jbHVkZS9saW51eC9maXJtd2FyZS1tYXAuaCBiL2luY2x1ZGUvbGludXgv
ZmlybXdhcmUtbWFwLmgKaW5kZXggODc1NDUxZi4uYzZkY2MxZCAxMDA2NDQKLS0tIGEvaW5jbHVk
ZS9saW51eC9maXJtd2FyZS1tYXAuaAorKysgYi9pbmNsdWRlL2xpbnV4L2Zpcm13YXJlLW1hcC5o
CkBAIC0yNCwxNyArMjQsMTcgQEAKICAqLwogI2lmZGVmIENPTkZJR19GSVJNV0FSRV9NRU1NQVAK
IAotaW50IGZpcm13YXJlX21hcF9hZGQodTY0IHN0YXJ0LCB1NjQgZW5kLCBjb25zdCBjaGFyICp0
eXBlKTsKIGludCBmaXJtd2FyZV9tYXBfYWRkX2Vhcmx5KHU2NCBzdGFydCwgdTY0IGVuZCwgY29u
c3QgY2hhciAqdHlwZSk7CitpbnQgZmlybXdhcmVfbWFwX2FkZF9ob3RwbHVnKHU2NCBzdGFydCwg
dTY0IGVuZCwgY29uc3QgY2hhciAqdHlwZSk7CiAKICNlbHNlIC8qIENPTkZJR19GSVJNV0FSRV9N
RU1NQVAgKi8KIAotc3RhdGljIGlubGluZSBpbnQgZmlybXdhcmVfbWFwX2FkZCh1NjQgc3RhcnQs
IHU2NCBlbmQsIGNvbnN0IGNoYXIgKnR5cGUpCitzdGF0aWMgaW5saW5lIGludCBmaXJtd2FyZV9t
YXBfYWRkX2Vhcmx5KHU2NCBzdGFydCwgdTY0IGVuZCwgY29uc3QgY2hhciAqdHlwZSkKIHsKIAly
ZXR1cm4gMDsKIH0KIAotc3RhdGljIGlubGluZSBpbnQgZmlybXdhcmVfbWFwX2FkZF9lYXJseSh1
NjQgc3RhcnQsIHU2NCBlbmQsIGNvbnN0IGNoYXIgKnR5cGUpCitzdGF0aWMgaW5saW5lIGludCBm
aXJtd2FyZV9tYXBfYWRkX2hvdHBsdWcodTY0IHN0YXJ0LCB1NjQgZW5kLCBjb25zdCBjaGFyICp0
eXBlKQogewogCXJldHVybiAwOwogfQpkaWZmIC0tZ2l0IGEvbW0vbWVtb3J5X2hvdHBsdWcuYyBi
L21tL21lbW9yeV9ob3RwbHVnLmMKaW5kZXggMDMwY2U4YS4uNzhlMzRlNiAxMDA2NDQKLS0tIGEv
bW0vbWVtb3J5X2hvdHBsdWcuYworKysgYi9tbS9tZW1vcnlfaG90cGx1Zy5jCkBAIC0yOCw2ICsy
OCw3IEBACiAjaW5jbHVkZSA8bGludXgvcGZuLmg+CiAjaW5jbHVkZSA8bGludXgvc3VzcGVuZC5o
PgogI2luY2x1ZGUgPGxpbnV4L21tX2lubGluZS5oPgorI2luY2x1ZGUgPGxpbnV4L2Zpcm13YXJl
LW1hcC5oPgogCiAjaW5jbHVkZSA8YXNtL3RsYmZsdXNoLmg+CiAKQEAgLTUyMyw2ICs1MjQsOSBA
QCBpbnQgX19yZWYgYWRkX21lbW9yeShpbnQgbmlkLCB1NjQgc3RhcnQsIHU2NCBzaXplKQogCQlC
VUdfT04ocmV0KTsKIAl9CiAKKwkvKiBjcmVhdGUgbmV3IG1lbW1hcCBlbnRyeSAqLworCWZpcm13
YXJlX21hcF9hZGRfaG90cGx1ZyhzdGFydCwgc3RhcnQgKyBzaXplLCAiU3lzdGVtIFJBTSIpOwor
CiAJZ290byBvdXQ7CiAKIGVycm9yOgo=

--_002_DA586906BA1FFC4384FCFD6429ECE86034FF85C5shzsmsx502ccrco_--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
