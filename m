Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id B43246B0078
	for <linux-mm@kvack.org>; Sun, 20 Dec 2009 23:19:15 -0500 (EST)
From: "Zheng, Shaohui" <shaohui.zheng@intel.com>
Date: Mon, 21 Dec 2009 12:18:57 +0800
Subject: [PATCH] Memory-Hotplug: Fix the bug on interface /dev/mem for
 64-bit kernel(v1)
Message-ID: <DA586906BA1FFC4384FCFD6429ECE86030203729@shzsmsx502.ccr.corp.intel.com>
Content-Language: en-US
Content-Type: multipart/mixed;
	boundary="_002_DA586906BA1FFC4384FCFD6429ECE86030203729shzsmsx502ccrco_"
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
To: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "ak@linux.intel.com" <ak@linux.intel.com>, "y-goto@jp.fujitsu.com" <y-goto@jp.fujitsu.com>
List-ID: <linux-mm.kvack.org>

--_002_DA586906BA1FFC4384FCFD6429ECE86030203729shzsmsx502ccrco_
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: quoted-printable

Memory-Hotplug: Fix the bug on interface /dev/mem for 64-bit kernel

The new added memory can not be access by interface /dev/mem, because we do=
 not
 update the variable high_memory. This patch add a new e820 entry in e820 t=
able,
 and update max_pfn, max_low_pfn and high_memory.

We add a function update_pfn in file arch/x86/mm/init.c to udpate these
 varibles. Memory hotplug does not make sense on 32-bit kernel, so we did n=
ot
 concern it in this function.

Signed-off-by: Shaohui Zheng <shaohui.zheng@intel.com>
---
diff --git a/arch/x86/kernel/e820.c b/arch/x86/kernel/e820.c
index f50447d..b986246 100644
--- a/arch/x86/kernel/e820.c
+++ b/arch/x86/kernel/e820.c
@@ -110,8 +110,8 @@ int __init e820_all_mapped(u64 start, u64 end, unsigned=
 type)
 /*
  * Add a memory region to the kernel e820 map.
  */
-static void __init __e820_add_region(struct e820map *e820x, u64 start, u64=
 size,
-					 int type)
+static void __meminit __e820_add_region(struct e820map *e820x, u64 start,
+					 u64 size, int type)
 {
 	int x =3D e820x->nr_map;
=20
@@ -126,7 +126,7 @@ static void __init __e820_add_region(struct e820map *e8=
20x, u64 start, u64 size,
 	e820x->nr_map++;
 }
=20
-void __init e820_add_region(u64 start, u64 size, int type)
+void __meminit e820_add_region(u64 start, u64 size, int type)
 {
 	__e820_add_region(&e820, start, size, type);
 }
diff --git a/arch/x86/mm/init.c b/arch/x86/mm/init.c
index d406c52..0474459 100644
--- a/arch/x86/mm/init.c
+++ b/arch/x86/mm/init.c
@@ -1,6 +1,7 @@
 #include <linux/initrd.h>
 #include <linux/ioport.h>
 #include <linux/swap.h>
+#include <linux/bootmem.h>
=20
 #include <asm/cacheflush.h>
 #include <asm/e820.h>
@@ -386,3 +387,30 @@ void free_initrd_mem(unsigned long start, unsigned lon=
g end)
 	free_init_pages("initrd memory", start, end);
 }
 #endif
+
+/**
+ * After memory hotplug, the variable max_pfn, max_low_pfn and high_memory=
 will
+ * be affected, it will be updated in this function. Memory hotplug does n=
ot
+ * make sense on 32-bit kernel, so we do did not concern it in this functi=
on.
+ */
+void __meminit __attribute__((weak)) update_pfn(u64 start, u64 size)
+{
+#ifdef CONFIG_X86_64
+	unsigned long limit_low_pfn =3D 1UL<<(32 - PAGE_SHIFT);
+	unsigned long start_pfn =3D start >> PAGE_SHIFT;
+	unsigned long end_pfn =3D (start + size) >> PAGE_SHIFT;
+
+	if (end_pfn > max_pfn) {
+		max_pfn =3D end_pfn;
+		high_memory =3D (void *)__va(max_pfn * PAGE_SIZE - 1) + 1;
+	}
+
+	/* if add to low memory, update max_low_pfn */
+	if (unlikely(start_pfn < limit_low_pfn)) {
+		if (end_pfn <=3D limit_low_pfn)
+			max_low_pfn =3D end_pfn;
+		else
+			max_low_pfn =3D limit_low_pfn;
+	}
+#endif /* CONFIG_X86_64 */
+}
diff --git a/include/linux/bootmem.h b/include/linux/bootmem.h
index b10ec49..6693414 100644
--- a/include/linux/bootmem.h
+++ b/include/linux/bootmem.h
@@ -13,6 +13,7 @@
=20
 extern unsigned long max_low_pfn;
 extern unsigned long min_low_pfn;
+extern void update_pfn(u64 start, u64 size);
=20
 /*
  * highest page
diff --git a/mm/memory_hotplug.c b/mm/memory_hotplug.c
index 030ce8a..ee7b2d6 100644
--- a/mm/memory_hotplug.c
+++ b/mm/memory_hotplug.c
@@ -523,6 +523,14 @@ int __ref add_memory(int nid, u64 start, u64 size)
 		BUG_ON(ret);
 	}
=20
+	/* update e820 table */
+	printk(KERN_INFO "Adding memory region to e820 table (start:%016Lx, size:=
%016Lx).\n",
+			 (unsigned long long)start, (unsigned long long)size);
+	e820_add_region(start, size, E820_RAM);
+
+	/* update max_pfn, max_low_pfn and high_memory */
+	update_pfn(start, size);
+
 	goto out;
=20
 error:

Thanks & Regards,
Shaohui




--_002_DA586906BA1FFC4384FCFD6429ECE86030203729shzsmsx502ccrco_
Content-Type: application/octet-stream;
	name="memory-hotplug-Fix-the-bug-on-interface-dev-mem-v1.patch"
Content-Description: memory-hotplug-Fix-the-bug-on-interface-dev-mem-v1.patch
Content-Disposition: attachment;
	filename="memory-hotplug-Fix-the-bug-on-interface-dev-mem-v1.patch";
	size=3508; creation-date="Fri, 18 Dec 2009 17:36:26 GMT";
	modification-date="Sat, 19 Dec 2009 01:25:10 GMT"
Content-Transfer-Encoding: base64

TWVtb3J5LUhvdHBsdWc6IEZpeCB0aGUgYnVnIG9uIGludGVyZmFjZSAvZGV2L21lbSBmb3IgNjQt
Yml0IGtlcm5lbAoKVGhlIG5ldyBhZGRlZCBtZW1vcnkgY2FuIG5vdCBiZSBhY2Nlc3MgYnkgaW50
ZXJmYWNlIC9kZXYvbWVtLCBiZWNhdXNlIHdlIGRvIG5vdAogdXBkYXRlIHRoZSB2YXJpYWJsZSBo
aWdoX21lbW9yeS4gVGhpcyBwYXRjaCBhZGQgYSBuZXcgZTgyMCBlbnRyeSBpbiBlODIwIHRhYmxl
LAogYW5kIHVwZGF0ZSBtYXhfcGZuLCBtYXhfbG93X3BmbiBhbmQgaGlnaF9tZW1vcnkuCgpXZSBh
ZGQgYSBmdW5jdGlvbiB1cGRhdGVfcGZuIGluIGZpbGUgYXJjaC94ODYvbW0vaW5pdC5jIHRvIHVk
cGF0ZSB0aGVzZQogdmFyaWJsZXMuIE1lbW9yeSBob3RwbHVnIGRvZXMgbm90IG1ha2Ugc2Vuc2Ug
b24gMzItYml0IGtlcm5lbCwgc28gd2UgZGlkIG5vdAogY29uY2VybiBpdCBpbiB0aGlzIGZ1bmN0
aW9uLgoKU2lnbmVkLW9mZi1ieTogU2hhb2h1aSBaaGVuZyA8c2hhb2h1aS56aGVuZ0BpbnRlbC5j
b20+Ci0tLQpkaWZmIC0tZ2l0IGEvYXJjaC94ODYva2VybmVsL2U4MjAuYyBiL2FyY2gveDg2L2tl
cm5lbC9lODIwLmMKaW5kZXggZjUwNDQ3ZC4uYjk4NjI0NiAxMDA2NDQKLS0tIGEvYXJjaC94ODYv
a2VybmVsL2U4MjAuYworKysgYi9hcmNoL3g4Ni9rZXJuZWwvZTgyMC5jCkBAIC0xMTAsOCArMTEw
LDggQEAgaW50IF9faW5pdCBlODIwX2FsbF9tYXBwZWQodTY0IHN0YXJ0LCB1NjQgZW5kLCB1bnNp
Z25lZCB0eXBlKQogLyoKICAqIEFkZCBhIG1lbW9yeSByZWdpb24gdG8gdGhlIGtlcm5lbCBlODIw
IG1hcC4KICAqLwotc3RhdGljIHZvaWQgX19pbml0IF9fZTgyMF9hZGRfcmVnaW9uKHN0cnVjdCBl
ODIwbWFwICplODIweCwgdTY0IHN0YXJ0LCB1NjQgc2l6ZSwKLQkJCQkJIGludCB0eXBlKQorc3Rh
dGljIHZvaWQgX19tZW1pbml0IF9fZTgyMF9hZGRfcmVnaW9uKHN0cnVjdCBlODIwbWFwICplODIw
eCwgdTY0IHN0YXJ0LAorCQkJCQkgdTY0IHNpemUsIGludCB0eXBlKQogewogCWludCB4ID0gZTgy
MHgtPm5yX21hcDsKIApAQCAtMTI2LDcgKzEyNiw3IEBAIHN0YXRpYyB2b2lkIF9faW5pdCBfX2U4
MjBfYWRkX3JlZ2lvbihzdHJ1Y3QgZTgyMG1hcCAqZTgyMHgsIHU2NCBzdGFydCwgdTY0IHNpemUs
CiAJZTgyMHgtPm5yX21hcCsrOwogfQogCi12b2lkIF9faW5pdCBlODIwX2FkZF9yZWdpb24odTY0
IHN0YXJ0LCB1NjQgc2l6ZSwgaW50IHR5cGUpCit2b2lkIF9fbWVtaW5pdCBlODIwX2FkZF9yZWdp
b24odTY0IHN0YXJ0LCB1NjQgc2l6ZSwgaW50IHR5cGUpCiB7CiAJX19lODIwX2FkZF9yZWdpb24o
JmU4MjAsIHN0YXJ0LCBzaXplLCB0eXBlKTsKIH0KZGlmZiAtLWdpdCBhL2FyY2gveDg2L21tL2lu
aXQuYyBiL2FyY2gveDg2L21tL2luaXQuYwppbmRleCBkNDA2YzUyLi4wNDc0NDU5IDEwMDY0NAot
LS0gYS9hcmNoL3g4Ni9tbS9pbml0LmMKKysrIGIvYXJjaC94ODYvbW0vaW5pdC5jCkBAIC0xLDYg
KzEsNyBAQAogI2luY2x1ZGUgPGxpbnV4L2luaXRyZC5oPgogI2luY2x1ZGUgPGxpbnV4L2lvcG9y
dC5oPgogI2luY2x1ZGUgPGxpbnV4L3N3YXAuaD4KKyNpbmNsdWRlIDxsaW51eC9ib290bWVtLmg+
CiAKICNpbmNsdWRlIDxhc20vY2FjaGVmbHVzaC5oPgogI2luY2x1ZGUgPGFzbS9lODIwLmg+CkBA
IC0zODYsMyArMzg3LDMwIEBAIHZvaWQgZnJlZV9pbml0cmRfbWVtKHVuc2lnbmVkIGxvbmcgc3Rh
cnQsIHVuc2lnbmVkIGxvbmcgZW5kKQogCWZyZWVfaW5pdF9wYWdlcygiaW5pdHJkIG1lbW9yeSIs
IHN0YXJ0LCBlbmQpOwogfQogI2VuZGlmCisKKy8qKgorICogQWZ0ZXIgbWVtb3J5IGhvdHBsdWcs
IHRoZSB2YXJpYWJsZSBtYXhfcGZuLCBtYXhfbG93X3BmbiBhbmQgaGlnaF9tZW1vcnkgd2lsbAor
ICogYmUgYWZmZWN0ZWQsIGl0IHdpbGwgYmUgdXBkYXRlZCBpbiB0aGlzIGZ1bmN0aW9uLiBNZW1v
cnkgaG90cGx1ZyBkb2VzIG5vdAorICogbWFrZSBzZW5zZSBvbiAzMi1iaXQga2VybmVsLCBzbyB3
ZSBkbyBkaWQgbm90IGNvbmNlcm4gaXQgaW4gdGhpcyBmdW5jdGlvbi4KKyAqLwordm9pZCBfX21l
bWluaXQgX19hdHRyaWJ1dGVfXygod2VhaykpIHVwZGF0ZV9wZm4odTY0IHN0YXJ0LCB1NjQgc2l6
ZSkKK3sKKyNpZmRlZiBDT05GSUdfWDg2XzY0CisJdW5zaWduZWQgbG9uZyBsaW1pdF9sb3dfcGZu
ID0gMVVMPDwoMzIgLSBQQUdFX1NISUZUKTsKKwl1bnNpZ25lZCBsb25nIHN0YXJ0X3BmbiA9IHN0
YXJ0ID4+IFBBR0VfU0hJRlQ7CisJdW5zaWduZWQgbG9uZyBlbmRfcGZuID0gKHN0YXJ0ICsgc2l6
ZSkgPj4gUEFHRV9TSElGVDsKKworCWlmIChlbmRfcGZuID4gbWF4X3BmbikgeworCQltYXhfcGZu
ID0gZW5kX3BmbjsKKwkJaGlnaF9tZW1vcnkgPSAodm9pZCAqKV9fdmEobWF4X3BmbiAqIFBBR0Vf
U0laRSAtIDEpICsgMTsKKwl9CisKKwkvKiBpZiBhZGQgdG8gbG93IG1lbW9yeSwgdXBkYXRlIG1h
eF9sb3dfcGZuICovCisJaWYgKHVubGlrZWx5KHN0YXJ0X3BmbiA8IGxpbWl0X2xvd19wZm4pKSB7
CisJCWlmIChlbmRfcGZuIDw9IGxpbWl0X2xvd19wZm4pCisJCQltYXhfbG93X3BmbiA9IGVuZF9w
Zm47CisJCWVsc2UKKwkJCW1heF9sb3dfcGZuID0gbGltaXRfbG93X3BmbjsKKwl9CisjZW5kaWYg
LyogQ09ORklHX1g4Nl82NCAqLworfQpkaWZmIC0tZ2l0IGEvaW5jbHVkZS9saW51eC9ib290bWVt
LmggYi9pbmNsdWRlL2xpbnV4L2Jvb3RtZW0uaAppbmRleCBiMTBlYzQ5Li42NjkzNDE0IDEwMDY0
NAotLS0gYS9pbmNsdWRlL2xpbnV4L2Jvb3RtZW0uaAorKysgYi9pbmNsdWRlL2xpbnV4L2Jvb3Rt
ZW0uaApAQCAtMTMsNiArMTMsNyBAQAogCiBleHRlcm4gdW5zaWduZWQgbG9uZyBtYXhfbG93X3Bm
bjsKIGV4dGVybiB1bnNpZ25lZCBsb25nIG1pbl9sb3dfcGZuOworZXh0ZXJuIHZvaWQgdXBkYXRl
X3Bmbih1NjQgc3RhcnQsIHU2NCBzaXplKTsKIAogLyoKICAqIGhpZ2hlc3QgcGFnZQpkaWZmIC0t
Z2l0IGEvbW0vbWVtb3J5X2hvdHBsdWcuYyBiL21tL21lbW9yeV9ob3RwbHVnLmMKaW5kZXggMDMw
Y2U4YS4uZWU3YjJkNiAxMDA2NDQKLS0tIGEvbW0vbWVtb3J5X2hvdHBsdWcuYworKysgYi9tbS9t
ZW1vcnlfaG90cGx1Zy5jCkBAIC01MjMsNiArNTIzLDE0IEBAIGludCBfX3JlZiBhZGRfbWVtb3J5
KGludCBuaWQsIHU2NCBzdGFydCwgdTY0IHNpemUpCiAJCUJVR19PTihyZXQpOwogCX0KIAorCS8q
IHVwZGF0ZSBlODIwIHRhYmxlICovCisJcHJpbnRrKEtFUk5fSU5GTyAiQWRkaW5nIG1lbW9yeSBy
ZWdpb24gdG8gZTgyMCB0YWJsZSAoc3RhcnQ6JTAxNkx4LCBzaXplOiUwMTZMeCkuXG4iLAorCQkJ
ICh1bnNpZ25lZCBsb25nIGxvbmcpc3RhcnQsICh1bnNpZ25lZCBsb25nIGxvbmcpc2l6ZSk7CisJ
ZTgyMF9hZGRfcmVnaW9uKHN0YXJ0LCBzaXplLCBFODIwX1JBTSk7CisKKwkvKiB1cGRhdGUgbWF4
X3BmbiwgbWF4X2xvd19wZm4gYW5kIGhpZ2hfbWVtb3J5ICovCisJdXBkYXRlX3BmbihzdGFydCwg
c2l6ZSk7CisKIAlnb3RvIG91dDsKIAogZXJyb3I6Cg==

--_002_DA586906BA1FFC4384FCFD6429ECE86030203729shzsmsx502ccrco_--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
