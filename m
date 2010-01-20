Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id 15DCB6B0078
	for <linux-mm@kvack.org>; Wed, 20 Jan 2010 00:48:55 -0500 (EST)
From: "Zheng, Shaohui" <shaohui.zheng@intel.com>
Date: Wed, 20 Jan 2010 13:47:20 +0800
Subject: RE: [PATCH-RESEND v4] memory-hotplug: create /sys/firmware/memmap
 entry for new memory
Message-ID: <DA586906BA1FFC4384FCFD6429ECE8603521C733@shzsmsx502.ccr.corp.intel.com>
References: <DA586906BA1FFC4384FCFD6429ECE86031560F92@shzsmsx502.ccr.corp.intel.com>
 <20100113142827.26b2269e.akpm@linux-foundation.org>
In-Reply-To: <20100113142827.26b2269e.akpm@linux-foundation.org>
Content-Language: en-US
Content-Type: multipart/mixed;
	boundary="_002_DA586906BA1FFC4384FCFD6429ECE8603521C733shzsmsx502ccrco_"
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "ak@linux.intel.com" <ak@linux.intel.com>, "y-goto@jp.fujitsu.com" <y-goto@jp.fujitsu.com>, Dave Hansen <haveblue@us.ibm.com>, "Wu, Fengguang" <fengguang.wu@intel.com>, "x86@kernel.org" <x86@kernel.org>
List-ID: <linux-mm.kvack.org>

--_002_DA586906BA1FFC4384FCFD6429ECE8603521C733shzsmsx502ccrco_
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: quoted-printable

Resend the v6 memmap patch after resolve the early exception. This patch wa=
s tested=20
on DELL Studio XPS(Core i7), I will always be careful to valid each patch b=
efore=20
sending it out.


memory-hotplug: create /sys/firmware/memmap entry for new memory

A memmap is a directory in sysfs which includes 3 text files: start, end an=
d
 type. For example:
start: 	0x100000
end:	0x7e7b1cff
type:	System RAM

Interface firmware_map_add was not called explicitly. Remove it and add fun=
ction
 firmware_map_add_hotplug as hotplug interface of memmap. =20

Each memory entry has a memmap in sysfs, When we hot-add new memory, sysfs =
does
not export memmap entry for it. We add a call in function add_memory to fun=
ction
 firmware_map_add_hotplug.

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
index 56f9234..821db6f 100644
--- a/drivers/firmware/memmap.c
+++ b/drivers/firmware/memmap.c
@@ -123,28 +123,52 @@ static int firmware_map_add_entry(u64 start, u64 end,
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
+ * firmware_map_add_hotplug() - Adds a firmware mapping entry when we do
+ * memory hotplug.
  * @start: Start of the memory range.
  * @end:   End of the memory range (inclusive).
  * @type:  Type of the memory range.
  *
- * This function uses kmalloc() for memory
- * allocation. Use firmware_map_add_early() if you want to use the bootmem
- * allocator.
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
-int firmware_map_add(u64 start, u64 end, const char *type)
+int __meminit firmware_map_add_hotplug(u64 start, u64 end, const char *typ=
e)
 {
 	struct firmware_map_entry *entry;
=20
-	entry =3D kmalloc(sizeof(struct firmware_map_entry), GFP_ATOMIC);
+	entry =3D kzalloc(sizeof(struct firmware_map_entry), GFP_ATOMIC);
 	if (!entry)
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
 /**
@@ -154,7 +178,7 @@ int firmware_map_add(u64 start, u64 end, const char *ty=
pe)
  * @type:  Type of the memory range.
  *
  * Adds a firmware mapping entry. This function uses the bootmem allocator
- * for memory allocation. Use firmware_map_add() if you want to use kmallo=
c().
+ * for memory allocation.
  *
  * That function must be called before late_initcall.
  *
@@ -214,19 +238,10 @@ static ssize_t memmap_attr_show(struct kobject *kobj,
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


--_002_DA586906BA1FFC4384FCFD6429ECE8603521C733shzsmsx502ccrco_
Content-Type: application/octet-stream; name=
	"memory-hotplug-create-sys-firmware-memmap-entry-for-new-memory-v6.patch"
Content-Description: memory-hotplug-create-sys-firmware-memmap-entry-for-new-memory-v6.patch
Content-Disposition: attachment; filename=
	"memory-hotplug-create-sys-firmware-memmap-entry-for-new-memory-v6.patch";
	size=5258; creation-date="Wed, 20 Jan 2010 13:39:46 GMT";
	modification-date="Wed, 20 Jan 2010 21:32:22 GMT"
Content-Transfer-Encoding: base64

bWVtb3J5LWhvdHBsdWc6IGNyZWF0ZSAvc3lzL2Zpcm13YXJlL21lbW1hcCBlbnRyeSBmb3IgbmV3
IG1lbW9yeQoKQSBtZW1tYXAgaXMgYSBkaXJlY3RvcnkgaW4gc3lzZnMgd2hpY2ggaW5jbHVkZXMg
MyB0ZXh0IGZpbGVzOiBzdGFydCwgZW5kIGFuZAogdHlwZS4gRm9yIGV4YW1wbGU6CnN0YXJ0OiAJ
MHgxMDAwMDAKZW5kOgkweDdlN2IxY2ZmCnR5cGU6CVN5c3RlbSBSQU0KCkludGVyZmFjZSBmaXJt
d2FyZV9tYXBfYWRkIHdhcyBub3QgY2FsbGVkIGV4cGxpY2l0bHkuIFJlbW92ZSBpdCBhbmQgYWRk
IGZ1bmN0aW9uCiBmaXJtd2FyZV9tYXBfYWRkX2hvdHBsdWcgYXMgaG90cGx1ZyBpbnRlcmZhY2Ug
b2YgbWVtbWFwLiAgCgpFYWNoIG1lbW9yeSBlbnRyeSBoYXMgYSBtZW1tYXAgaW4gc3lzZnMsIFdo
ZW4gd2UgaG90LWFkZCBuZXcgbWVtb3J5LCBzeXNmcyBkb2VzCm5vdCBleHBvcnQgbWVtbWFwIGVu
dHJ5IGZvciBpdC4gV2UgYWRkIGEgY2FsbCBpbiBmdW5jdGlvbiBhZGRfbWVtb3J5IHRvIGZ1bmN0
aW9uCiBmaXJtd2FyZV9tYXBfYWRkX2hvdHBsdWcuCgpBZGQgYSBuZXcgZnVuY3Rpb24gYWRkX3N5
c2ZzX2Z3X21hcF9lbnRyeSgpIHRvIGNyZWF0ZSBtZW1tYXAgZW50cnksIGl0IHdpbGwgYmUKY2Fs
bGVkIHdoZW4gaW5pdGlhbGl6ZSBtZW1tYXAgYW5kIGhvdC1hZGQgbWVtb3J5LgoKU2lnbmVkLW9m
Zi1ieTogU2hhb2h1aSBaaGVuZyA8c2hhb2h1aS56aGVuZ0BpbnRlbC5jb20+CkFja2VkLWJ5OiBB
bmRpIEtsZWVuIDxha0BsaW51eC5pbnRlbC5jb20+CkFja2VkLWJ5OiBZYXN1bm9yaSBHb3RvIDx5
LWdvdG9AanAuZnVqaXRzdS5jb20+ClJldmlld2VkLWJ5OiBXdSBGZW5nZ3VhbmcgPGZlbmdndWFu
Zy53dUBpbnRlbC5jb20+CkNjOiBEYXZlIEhhbnNlbiA8aGF2ZWJsdWVAdXMuaWJtLmNvbT4KU2ln
bmVkLW9mZi1ieTogQW5kcmV3IE1vcnRvbiA8YWtwbUBsaW51eC1mb3VuZGF0aW9uLm9yZz4KZGlm
ZiAtLWdpdCBhL2RyaXZlcnMvZmlybXdhcmUvbWVtbWFwLmMgYi9kcml2ZXJzL2Zpcm13YXJlL21l
bW1hcC5jCmluZGV4IDU2ZjkyMzQuLjgyMWRiNmYgMTAwNjQ0Ci0tLSBhL2RyaXZlcnMvZmlybXdh
cmUvbWVtbWFwLmMKKysrIGIvZHJpdmVycy9maXJtd2FyZS9tZW1tYXAuYwpAQCAtMTIzLDI4ICsx
MjMsNTIgQEAgc3RhdGljIGludCBmaXJtd2FyZV9tYXBfYWRkX2VudHJ5KHU2NCBzdGFydCwgdTY0
IGVuZCwKIH0KIAogLyoqCi0gKiBmaXJtd2FyZV9tYXBfYWRkKCkgLSBBZGRzIGEgZmlybXdhcmUg
bWFwcGluZyBlbnRyeS4KKyAqIEFkZCBtZW1tYXAgZW50cnkgb24gc3lzZnMKKyAqLworc3RhdGlj
IGludCBhZGRfc3lzZnNfZndfbWFwX2VudHJ5KHN0cnVjdCBmaXJtd2FyZV9tYXBfZW50cnkgKmVu
dHJ5KQoreworCXN0YXRpYyBpbnQgbWFwX2VudHJpZXNfbnI7CisJc3RhdGljIHN0cnVjdCBrc2V0
ICptbWFwX2tzZXQ7CisKKwlpZiAoIW1tYXBfa3NldCkgeworCQltbWFwX2tzZXQgPSBrc2V0X2Ny
ZWF0ZV9hbmRfYWRkKCJtZW1tYXAiLCBOVUxMLCBmaXJtd2FyZV9rb2JqKTsKKwkJaWYgKCFtbWFw
X2tzZXQpCisJCQlyZXR1cm4gLUVOT01FTTsKKwl9CisKKwllbnRyeS0+a29iai5rc2V0ID0gbW1h
cF9rc2V0OworCWlmIChrb2JqZWN0X2FkZCgmZW50cnktPmtvYmosIE5VTEwsICIlZCIsIG1hcF9l
bnRyaWVzX25yKyspKQorCQlrb2JqZWN0X3B1dCgmZW50cnktPmtvYmopOworCisJcmV0dXJuIDA7
Cit9CisKKy8qKgorICogZmlybXdhcmVfbWFwX2FkZF9ob3RwbHVnKCkgLSBBZGRzIGEgZmlybXdh
cmUgbWFwcGluZyBlbnRyeSB3aGVuIHdlIGRvCisgKiBtZW1vcnkgaG90cGx1Zy4KICAqIEBzdGFy
dDogU3RhcnQgb2YgdGhlIG1lbW9yeSByYW5nZS4KICAqIEBlbmQ6ICAgRW5kIG9mIHRoZSBtZW1v
cnkgcmFuZ2UgKGluY2x1c2l2ZSkuCiAgKiBAdHlwZTogIFR5cGUgb2YgdGhlIG1lbW9yeSByYW5n
ZS4KICAqCi0gKiBUaGlzIGZ1bmN0aW9uIHVzZXMga21hbGxvYygpIGZvciBtZW1vcnkKLSAqIGFs
bG9jYXRpb24uIFVzZSBmaXJtd2FyZV9tYXBfYWRkX2Vhcmx5KCkgaWYgeW91IHdhbnQgdG8gdXNl
IHRoZSBib290bWVtCi0gKiBhbGxvY2F0b3IuCi0gKgotICogVGhhdCBmdW5jdGlvbiBtdXN0IGJl
IGNhbGxlZCBiZWZvcmUgbGF0ZV9pbml0Y2FsbC4KKyAqIEFkZHMgYSBmaXJtd2FyZSBtYXBwaW5n
IGVudHJ5LiBUaGlzIGZ1bmN0aW9uIGlzIGZvciBtZW1vcnkgaG90cGx1ZywgaXQgaXMKKyAqIHNp
bWlsYXIgdG8gZnVuY3Rpb24gZmlybXdhcmVfbWFwX2FkZF9lYXJseSgpLiBUaGUgb25seSBkaWZm
ZXJlbmNlIGlzIHRoYXQKKyAqIGl0IHdpbGwgY3JlYXRlIHRoZSBzeWZzIGVudHJ5IGR5bmFtaWNh
bGx5LgogICoKICAqIFJldHVybnMgMCBvbiBzdWNjZXNzLCBvciAtRU5PTUVNIGlmIG5vIG1lbW9y
eSBjb3VsZCBiZSBhbGxvY2F0ZWQuCiAgKiovCi1pbnQgZmlybXdhcmVfbWFwX2FkZCh1NjQgc3Rh
cnQsIHU2NCBlbmQsIGNvbnN0IGNoYXIgKnR5cGUpCitpbnQgX19tZW1pbml0IGZpcm13YXJlX21h
cF9hZGRfaG90cGx1Zyh1NjQgc3RhcnQsIHU2NCBlbmQsIGNvbnN0IGNoYXIgKnR5cGUpCiB7CiAJ
c3RydWN0IGZpcm13YXJlX21hcF9lbnRyeSAqZW50cnk7CiAKLQllbnRyeSA9IGttYWxsb2Moc2l6
ZW9mKHN0cnVjdCBmaXJtd2FyZV9tYXBfZW50cnkpLCBHRlBfQVRPTUlDKTsKKwllbnRyeSA9IGt6
YWxsb2Moc2l6ZW9mKHN0cnVjdCBmaXJtd2FyZV9tYXBfZW50cnkpLCBHRlBfQVRPTUlDKTsKIAlp
ZiAoIWVudHJ5KQogCQlyZXR1cm4gLUVOT01FTTsKIAotCXJldHVybiBmaXJtd2FyZV9tYXBfYWRk
X2VudHJ5KHN0YXJ0LCBlbmQsIHR5cGUsIGVudHJ5KTsKKwlmaXJtd2FyZV9tYXBfYWRkX2VudHJ5
KHN0YXJ0LCBlbmQsIHR5cGUsIGVudHJ5KTsKKwkvKiBjcmVhdGUgdGhlIG1lbW1hcCBlbnRyeSAq
LworCWFkZF9zeXNmc19md19tYXBfZW50cnkoZW50cnkpOworCisJcmV0dXJuIDA7CiB9CiAKIC8q
KgpAQCAtMTU0LDcgKzE3OCw3IEBAIGludCBmaXJtd2FyZV9tYXBfYWRkKHU2NCBzdGFydCwgdTY0
IGVuZCwgY29uc3QgY2hhciAqdHlwZSkKICAqIEB0eXBlOiAgVHlwZSBvZiB0aGUgbWVtb3J5IHJh
bmdlLgogICoKICAqIEFkZHMgYSBmaXJtd2FyZSBtYXBwaW5nIGVudHJ5LiBUaGlzIGZ1bmN0aW9u
IHVzZXMgdGhlIGJvb3RtZW0gYWxsb2NhdG9yCi0gKiBmb3IgbWVtb3J5IGFsbG9jYXRpb24uIFVz
ZSBmaXJtd2FyZV9tYXBfYWRkKCkgaWYgeW91IHdhbnQgdG8gdXNlIGttYWxsb2MoKS4KKyAqIGZv
ciBtZW1vcnkgYWxsb2NhdGlvbi4KICAqCiAgKiBUaGF0IGZ1bmN0aW9uIG11c3QgYmUgY2FsbGVk
IGJlZm9yZSBsYXRlX2luaXRjYWxsLgogICoKQEAgLTIxNCwxOSArMjM4LDEwIEBAIHN0YXRpYyBz
c2l6ZV90IG1lbW1hcF9hdHRyX3Nob3coc3RydWN0IGtvYmplY3QgKmtvYmosCiAgKi8KIHN0YXRp
YyBpbnQgX19pbml0IG1lbW1hcF9pbml0KHZvaWQpCiB7Ci0JaW50IGkgPSAwOwogCXN0cnVjdCBm
aXJtd2FyZV9tYXBfZW50cnkgKmVudHJ5OwotCXN0cnVjdCBrc2V0ICptZW1tYXBfa3NldDsKLQot
CW1lbW1hcF9rc2V0ID0ga3NldF9jcmVhdGVfYW5kX2FkZCgibWVtbWFwIiwgTlVMTCwgZmlybXdh
cmVfa29iaik7Ci0JaWYgKFdBUk5fT04oIW1lbW1hcF9rc2V0KSkKLQkJcmV0dXJuIC1FTk9NRU07
CiAKLQlsaXN0X2Zvcl9lYWNoX2VudHJ5KGVudHJ5LCAmbWFwX2VudHJpZXMsIGxpc3QpIHsKLQkJ
ZW50cnktPmtvYmoua3NldCA9IG1lbW1hcF9rc2V0OwotCQlpZiAoa29iamVjdF9hZGQoJmVudHJ5
LT5rb2JqLCBOVUxMLCAiJWQiLCBpKyspKQotCQkJa29iamVjdF9wdXQoJmVudHJ5LT5rb2JqKTsK
LQl9CisJbGlzdF9mb3JfZWFjaF9lbnRyeShlbnRyeSwgJm1hcF9lbnRyaWVzLCBsaXN0KQorCQlh
ZGRfc3lzZnNfZndfbWFwX2VudHJ5KGVudHJ5KTsKIAogCXJldHVybiAwOwogfQpkaWZmIC0tZ2l0
IGEvaW5jbHVkZS9saW51eC9maXJtd2FyZS1tYXAuaCBiL2luY2x1ZGUvbGludXgvZmlybXdhcmUt
bWFwLmgKaW5kZXggODc1NDUxZi4uYzZkY2MxZCAxMDA2NDQKLS0tIGEvaW5jbHVkZS9saW51eC9m
aXJtd2FyZS1tYXAuaAorKysgYi9pbmNsdWRlL2xpbnV4L2Zpcm13YXJlLW1hcC5oCkBAIC0yNCwx
NyArMjQsMTcgQEAKICAqLwogI2lmZGVmIENPTkZJR19GSVJNV0FSRV9NRU1NQVAKIAotaW50IGZp
cm13YXJlX21hcF9hZGQodTY0IHN0YXJ0LCB1NjQgZW5kLCBjb25zdCBjaGFyICp0eXBlKTsKIGlu
dCBmaXJtd2FyZV9tYXBfYWRkX2Vhcmx5KHU2NCBzdGFydCwgdTY0IGVuZCwgY29uc3QgY2hhciAq
dHlwZSk7CitpbnQgZmlybXdhcmVfbWFwX2FkZF9ob3RwbHVnKHU2NCBzdGFydCwgdTY0IGVuZCwg
Y29uc3QgY2hhciAqdHlwZSk7CiAKICNlbHNlIC8qIENPTkZJR19GSVJNV0FSRV9NRU1NQVAgKi8K
IAotc3RhdGljIGlubGluZSBpbnQgZmlybXdhcmVfbWFwX2FkZCh1NjQgc3RhcnQsIHU2NCBlbmQs
IGNvbnN0IGNoYXIgKnR5cGUpCitzdGF0aWMgaW5saW5lIGludCBmaXJtd2FyZV9tYXBfYWRkX2Vh
cmx5KHU2NCBzdGFydCwgdTY0IGVuZCwgY29uc3QgY2hhciAqdHlwZSkKIHsKIAlyZXR1cm4gMDsK
IH0KIAotc3RhdGljIGlubGluZSBpbnQgZmlybXdhcmVfbWFwX2FkZF9lYXJseSh1NjQgc3RhcnQs
IHU2NCBlbmQsIGNvbnN0IGNoYXIgKnR5cGUpCitzdGF0aWMgaW5saW5lIGludCBmaXJtd2FyZV9t
YXBfYWRkX2hvdHBsdWcodTY0IHN0YXJ0LCB1NjQgZW5kLCBjb25zdCBjaGFyICp0eXBlKQogewog
CXJldHVybiAwOwogfQpkaWZmIC0tZ2l0IGEvbW0vbWVtb3J5X2hvdHBsdWcuYyBiL21tL21lbW9y
eV9ob3RwbHVnLmMKaW5kZXggMDMwY2U4YS4uNzhlMzRlNiAxMDA2NDQKLS0tIGEvbW0vbWVtb3J5
X2hvdHBsdWcuYworKysgYi9tbS9tZW1vcnlfaG90cGx1Zy5jCkBAIC0yOCw2ICsyOCw3IEBACiAj
aW5jbHVkZSA8bGludXgvcGZuLmg+CiAjaW5jbHVkZSA8bGludXgvc3VzcGVuZC5oPgogI2luY2x1
ZGUgPGxpbnV4L21tX2lubGluZS5oPgorI2luY2x1ZGUgPGxpbnV4L2Zpcm13YXJlLW1hcC5oPgog
CiAjaW5jbHVkZSA8YXNtL3RsYmZsdXNoLmg+CiAKQEAgLTUyMyw2ICs1MjQsOSBAQCBpbnQgX19y
ZWYgYWRkX21lbW9yeShpbnQgbmlkLCB1NjQgc3RhcnQsIHU2NCBzaXplKQogCQlCVUdfT04ocmV0
KTsKIAl9CiAKKwkvKiBjcmVhdGUgbmV3IG1lbW1hcCBlbnRyeSAqLworCWZpcm13YXJlX21hcF9h
ZGRfaG90cGx1ZyhzdGFydCwgc3RhcnQgKyBzaXplLCAiU3lzdGVtIFJBTSIpOworCiAJZ290byBv
dXQ7CiAKIGVycm9yOgo=

--_002_DA586906BA1FFC4384FCFD6429ECE8603521C733shzsmsx502ccrco_--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
