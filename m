Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id 8D6E86B0078
	for <linux-mm@kvack.org>; Mon, 11 Jan 2010 02:52:22 -0500 (EST)
From: "Zheng, Shaohui" <shaohui.zheng@intel.com>
Date: Mon, 11 Jan 2010 15:49:05 +0800
Subject: [RESEND PATCH v2] Memory-Hotplug: Fix the bug on interface /dev/mem
 for 64-bit kernel
Message-ID: <DA586906BA1FFC4384FCFD6429ECE860316BFBE2@shzsmsx502.ccr.corp.intel.com>
Content-Language: en-US
Content-Type: multipart/mixed;
	boundary="_002_DA586906BA1FFC4384FCFD6429ECE860316BFBE2shzsmsx502ccrco_"
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
To: "linux-mm@kvack.org" <linux-mm@kvack.org>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>
Cc: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "ak@linux.intel.com" <ak@linux.intel.com>, "y-goto@jp.fujitsu.com" <y-goto@jp.fujitsu.com>, Dave Hansen <haveblue@us.ibm.com>, "Wu, Fengguang" <fengguang.wu@intel.com>, "x86@kernel.org" <x86@kernel.org>, "Li, Haicheng" <haicheng.li@intel.com>
List-ID: <linux-mm.kvack.org>

--_002_DA586906BA1FFC4384FCFD6429ECE860316BFBE2shzsmsx502ccrco_
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: quoted-printable

After reviewed by Fengguang, resend the v2 patch to mailing-list.

Memory-Hotplug: Fix the bug on interface /dev/mem for 64-bit kernel

The new added memory can not be access by interface /dev/mem, because we do=
 not
 update the variable high_memory. This patch add a new e820 entry in e820 t=
able,
 and update max_pfn, max_low_pfn and high_memory.

Memory hotplug still has critical issues for 32-bit kernel, and it is more=
=20
important for 64-bit kernel, we fix it on 64-bit first. We add a function=20
update_end_of_memory_vars in file arch/x86/mm/init.c to update these variab=
les.
Signed-off-by: Shaohui Zheng <shaohui.zheng@intel.com>
CC: Andi Kleen <ak@linux.intel.com>
CC: Li Haicheng <haicheng.li@intel.com>
Reviewed-by: Wu Fengguang <fengguang.wu@intel.com>
diff --git a/arch/x86/kernel/e820.c b/arch/x86/kernel/e820.c
index a1a7876..a9b6bae 100644
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
index d406c52..51ff734 100644
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
@@ -386,3 +387,31 @@ void free_initrd_mem(unsigned long start, unsigned lon=
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
+void __meminit __attribute__((weak)) update_end_of_memory_vars(u64 start,
+		u64 size)
+{
+#ifdef CONFIG_X86_64
+	unsigned long limit_low_pfn =3D 1UL<<(32 - PAGE_SHIFT);
+	unsigned long start_pfn =3D start >> PAGE_SHIFT;
+	unsigned long end_pfn =3D PFN_UP(start + size);
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
index b10ec49..84533a5 100644
--- a/include/linux/bootmem.h
+++ b/include/linux/bootmem.h
@@ -13,6 +13,7 @@
=20
 extern unsigned long max_low_pfn;
 extern unsigned long min_low_pfn;
+extern void update_end_of_memory_vars(u64 start, u64 size);
=20
 /*
  * highest page
diff --git a/mm/memory_hotplug.c b/mm/memory_hotplug.c
index 030ce8a..cd54ad1 100644
--- a/mm/memory_hotplug.c
+++ b/mm/memory_hotplug.c
@@ -523,6 +523,13 @@ int __ref add_memory(int nid, u64 start, u64 size)
 		BUG_ON(ret);
 	}
=20
+	printk(KERN_INFO "Adding memory region to e820 table (start:%016Lx, size:=
%016Lx).\n",
+			 (unsigned long long)start, (unsigned long long)size);
+	e820_add_region(start, size, E820_RAM);
+
+	/* update max_pfn, max_low_pfn and high_memory */
+	update_end_of_memory_vars(start, size);
+
 	goto out;
=20
 error:

Thanks & Regards,
Shaohui



--_002_DA586906BA1FFC4384FCFD6429ECE860316BFBE2shzsmsx502ccrco_
Content-Type: application/octet-stream;
	name="memory-hotplug-fix-the-bug-on-interface-dev-mem-v2.patch"
Content-Description: memory-hotplug-fix-the-bug-on-interface-dev-mem-v2.patch
Content-Disposition: attachment;
	filename="memory-hotplug-fix-the-bug-on-interface-dev-mem-v2.patch";
	size=3695; creation-date="Mon, 11 Jan 2010 15:46:27 GMT";
	modification-date="Mon, 11 Jan 2010 23:36:52 GMT"
Content-Transfer-Encoding: base64

TWVtb3J5LUhvdHBsdWc6IEZpeCB0aGUgYnVnIG9uIGludGVyZmFjZSAvZGV2L21lbSBmb3IgNjQt
Yml0IGtlcm5lbAoKVGhlIG5ldyBhZGRlZCBtZW1vcnkgY2FuIG5vdCBiZSBhY2Nlc3MgYnkgaW50
ZXJmYWNlIC9kZXYvbWVtLCBiZWNhdXNlIHdlIGRvIG5vdAogdXBkYXRlIHRoZSB2YXJpYWJsZSBo
aWdoX21lbW9yeS4gVGhpcyBwYXRjaCBhZGQgYSBuZXcgZTgyMCBlbnRyeSBpbiBlODIwIHRhYmxl
LAogYW5kIHVwZGF0ZSBtYXhfcGZuLCBtYXhfbG93X3BmbiBhbmQgaGlnaF9tZW1vcnkuCgpNZW1v
cnkgaG90cGx1ZyBzdGlsbCBoYXMgY3JpdGljYWwgaXNzdWVzIGZvciAzMi1iaXQga2VybmVsLCBh
bmQgaXQgaXMgbW9yZSAKaW1wb3J0YW50IGZvciA2NC1iaXQga2VybmVsLCB3ZSBmaXggaXQgb24g
NjQtYml0IGZpcnN0LiBXZSBhZGQgYSBmdW5jdGlvbiAKdXBkYXRlX2VuZF9vZl9tZW1vcnlfdmFy
cyBpbiBmaWxlIGFyY2gveDg2L21tL2luaXQuYyB0byB1cGRhdGUgdGhlc2UgdmFyaWFibGVzLgpT
aWduZWQtb2ZmLWJ5OiBTaGFvaHVpIFpoZW5nIDxzaGFvaHVpLnpoZW5nQGludGVsLmNvbT4KQ0M6
IEFuZGkgS2xlZW4gPGFrQGxpbnV4LmludGVsLmNvbT4KQ0M6IExpIEhhaWNoZW5nIDxoYWljaGVu
Zy5saUBpbnRlbC5jb20+ClJldmlld2VkLWJ5OiBXdSBGZW5nZ3VhbmcgPGZlbmdndWFuZy53dUBp
bnRlbC5jb20+CmRpZmYgLS1naXQgYS9hcmNoL3g4Ni9rZXJuZWwvZTgyMC5jIGIvYXJjaC94ODYv
a2VybmVsL2U4MjAuYwppbmRleCBhMWE3ODc2Li5hOWI2YmFlIDEwMDY0NAotLS0gYS9hcmNoL3g4
Ni9rZXJuZWwvZTgyMC5jCisrKyBiL2FyY2gveDg2L2tlcm5lbC9lODIwLmMKQEAgLTExMCw4ICsx
MTAsOCBAQCBpbnQgX19pbml0IGU4MjBfYWxsX21hcHBlZCh1NjQgc3RhcnQsIHU2NCBlbmQsIHVu
c2lnbmVkIHR5cGUpCiAvKgogICogQWRkIGEgbWVtb3J5IHJlZ2lvbiB0byB0aGUga2VybmVsIGU4
MjAgbWFwLgogICovCi1zdGF0aWMgdm9pZCBfX2luaXQgX19lODIwX2FkZF9yZWdpb24oc3RydWN0
IGU4MjBtYXAgKmU4MjB4LCB1NjQgc3RhcnQsIHU2NCBzaXplLAotCQkJCQkgaW50IHR5cGUpCitz
dGF0aWMgdm9pZCBfX21lbWluaXQgX19lODIwX2FkZF9yZWdpb24oc3RydWN0IGU4MjBtYXAgKmU4
MjB4LCB1NjQgc3RhcnQsCisJCQkJCSB1NjQgc2l6ZSwgaW50IHR5cGUpCiB7CiAJaW50IHggPSBl
ODIweC0+bnJfbWFwOwogCkBAIC0xMjYsNyArMTI2LDcgQEAgc3RhdGljIHZvaWQgX19pbml0IF9f
ZTgyMF9hZGRfcmVnaW9uKHN0cnVjdCBlODIwbWFwICplODIweCwgdTY0IHN0YXJ0LCB1NjQgc2l6
ZSwKIAllODIweC0+bnJfbWFwKys7CiB9CiAKLXZvaWQgX19pbml0IGU4MjBfYWRkX3JlZ2lvbih1
NjQgc3RhcnQsIHU2NCBzaXplLCBpbnQgdHlwZSkKK3ZvaWQgX19tZW1pbml0IGU4MjBfYWRkX3Jl
Z2lvbih1NjQgc3RhcnQsIHU2NCBzaXplLCBpbnQgdHlwZSkKIHsKIAlfX2U4MjBfYWRkX3JlZ2lv
bigmZTgyMCwgc3RhcnQsIHNpemUsIHR5cGUpOwogfQpkaWZmIC0tZ2l0IGEvYXJjaC94ODYvbW0v
aW5pdC5jIGIvYXJjaC94ODYvbW0vaW5pdC5jCmluZGV4IGQ0MDZjNTIuLjUxZmY3MzQgMTAwNjQ0
Ci0tLSBhL2FyY2gveDg2L21tL2luaXQuYworKysgYi9hcmNoL3g4Ni9tbS9pbml0LmMKQEAgLTEs
NiArMSw3IEBACiAjaW5jbHVkZSA8bGludXgvaW5pdHJkLmg+CiAjaW5jbHVkZSA8bGludXgvaW9w
b3J0Lmg+CiAjaW5jbHVkZSA8bGludXgvc3dhcC5oPgorI2luY2x1ZGUgPGxpbnV4L2Jvb3RtZW0u
aD4KIAogI2luY2x1ZGUgPGFzbS9jYWNoZWZsdXNoLmg+CiAjaW5jbHVkZSA8YXNtL2U4MjAuaD4K
QEAgLTM4NiwzICszODcsMzEgQEAgdm9pZCBmcmVlX2luaXRyZF9tZW0odW5zaWduZWQgbG9uZyBz
dGFydCwgdW5zaWduZWQgbG9uZyBlbmQpCiAJZnJlZV9pbml0X3BhZ2VzKCJpbml0cmQgbWVtb3J5
Iiwgc3RhcnQsIGVuZCk7CiB9CiAjZW5kaWYKKworLyoqCisgKiBBZnRlciBtZW1vcnkgaG90cGx1
ZywgdGhlIHZhcmlhYmxlIG1heF9wZm4sIG1heF9sb3dfcGZuIGFuZCBoaWdoX21lbW9yeSB3aWxs
CisgKiBiZSBhZmZlY3RlZCwgaXQgd2lsbCBiZSB1cGRhdGVkIGluIHRoaXMgZnVuY3Rpb24uIE1l
bW9yeSBob3RwbHVnIGRvZXMgbm90CisgKiBtYWtlIHNlbnNlIG9uIDMyLWJpdCBrZXJuZWwsIHNv
IHdlIGRvIGRpZCBub3QgY29uY2VybiBpdCBpbiB0aGlzIGZ1bmN0aW9uLgorICovCit2b2lkIF9f
bWVtaW5pdCBfX2F0dHJpYnV0ZV9fKCh3ZWFrKSkgdXBkYXRlX2VuZF9vZl9tZW1vcnlfdmFycyh1
NjQgc3RhcnQsCisJCXU2NCBzaXplKQoreworI2lmZGVmIENPTkZJR19YODZfNjQKKwl1bnNpZ25l
ZCBsb25nIGxpbWl0X2xvd19wZm4gPSAxVUw8PCgzMiAtIFBBR0VfU0hJRlQpOworCXVuc2lnbmVk
IGxvbmcgc3RhcnRfcGZuID0gc3RhcnQgPj4gUEFHRV9TSElGVDsKKwl1bnNpZ25lZCBsb25nIGVu
ZF9wZm4gPSBQRk5fVVAoc3RhcnQgKyBzaXplKTsKKworCWlmIChlbmRfcGZuID4gbWF4X3Bmbikg
eworCQltYXhfcGZuID0gZW5kX3BmbjsKKwkJaGlnaF9tZW1vcnkgPSAodm9pZCAqKV9fdmEobWF4
X3BmbiAqIFBBR0VfU0laRSAtIDEpICsgMTsKKwl9CisKKwkvKiBpZiBhZGQgdG8gbG93IG1lbW9y
eSwgdXBkYXRlIG1heF9sb3dfcGZuICovCisJaWYgKHVubGlrZWx5KHN0YXJ0X3BmbiA8IGxpbWl0
X2xvd19wZm4pKSB7CisJCWlmIChlbmRfcGZuIDw9IGxpbWl0X2xvd19wZm4pCisJCQltYXhfbG93
X3BmbiA9IGVuZF9wZm47CisJCWVsc2UKKwkJCW1heF9sb3dfcGZuID0gbGltaXRfbG93X3BmbjsK
Kwl9CisjZW5kaWYgLyogQ09ORklHX1g4Nl82NCAqLworfQpkaWZmIC0tZ2l0IGEvaW5jbHVkZS9s
aW51eC9ib290bWVtLmggYi9pbmNsdWRlL2xpbnV4L2Jvb3RtZW0uaAppbmRleCBiMTBlYzQ5Li44
NDUzM2E1IDEwMDY0NAotLS0gYS9pbmNsdWRlL2xpbnV4L2Jvb3RtZW0uaAorKysgYi9pbmNsdWRl
L2xpbnV4L2Jvb3RtZW0uaApAQCAtMTMsNiArMTMsNyBAQAogCiBleHRlcm4gdW5zaWduZWQgbG9u
ZyBtYXhfbG93X3BmbjsKIGV4dGVybiB1bnNpZ25lZCBsb25nIG1pbl9sb3dfcGZuOworZXh0ZXJu
IHZvaWQgdXBkYXRlX2VuZF9vZl9tZW1vcnlfdmFycyh1NjQgc3RhcnQsIHU2NCBzaXplKTsKIAog
LyoKICAqIGhpZ2hlc3QgcGFnZQpkaWZmIC0tZ2l0IGEvbW0vbWVtb3J5X2hvdHBsdWcuYyBiL21t
L21lbW9yeV9ob3RwbHVnLmMKaW5kZXggMDMwY2U4YS4uY2Q1NGFkMSAxMDA2NDQKLS0tIGEvbW0v
bWVtb3J5X2hvdHBsdWcuYworKysgYi9tbS9tZW1vcnlfaG90cGx1Zy5jCkBAIC01MjMsNiArNTIz
LDEzIEBAIGludCBfX3JlZiBhZGRfbWVtb3J5KGludCBuaWQsIHU2NCBzdGFydCwgdTY0IHNpemUp
CiAJCUJVR19PTihyZXQpOwogCX0KIAorCXByaW50ayhLRVJOX0lORk8gIkFkZGluZyBtZW1vcnkg
cmVnaW9uIHRvIGU4MjAgdGFibGUgKHN0YXJ0OiUwMTZMeCwgc2l6ZTolMDE2THgpLlxuIiwKKwkJ
CSAodW5zaWduZWQgbG9uZyBsb25nKXN0YXJ0LCAodW5zaWduZWQgbG9uZyBsb25nKXNpemUpOwor
CWU4MjBfYWRkX3JlZ2lvbihzdGFydCwgc2l6ZSwgRTgyMF9SQU0pOworCisJLyogdXBkYXRlIG1h
eF9wZm4sIG1heF9sb3dfcGZuIGFuZCBoaWdoX21lbW9yeSAqLworCXVwZGF0ZV9lbmRfb2ZfbWVt
b3J5X3ZhcnMoc3RhcnQsIHNpemUpOworCiAJZ290byBvdXQ7CiAKIGVycm9yOgo=

--_002_DA586906BA1FFC4384FCFD6429ECE860316BFBE2shzsmsx502ccrco_--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
