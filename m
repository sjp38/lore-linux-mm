Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with SMTP id 1FA8F6B0071
	for <linux-mm@kvack.org>; Tue, 12 Jan 2010 02:47:09 -0500 (EST)
From: "Zheng, Shaohui" <shaohui.zheng@intel.com>
Date: Tue, 12 Jan 2010 15:45:54 +0800
Subject: [ RESEND PATCH v3] Memory-Hotplug: Fix the bug on interface
 /dev/mem for 64-bit kernel
Message-ID: <DA586906BA1FFC4384FCFD6429ECE860316C0133@shzsmsx502.ccr.corp.intel.com>
Content-Language: en-US
Content-Type: multipart/mixed;
	boundary="_002_DA586906BA1FFC4384FCFD6429ECE860316C0133shzsmsx502ccrco_"
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
To: "linux-mm@kvack.org" <linux-mm@kvack.org>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>
Cc: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "ak@linux.intel.com" <ak@linux.intel.com>, "y-goto@jp.fujitsu.com" <y-goto@jp.fujitsu.com>, Dave Hansen <haveblue@us.ibm.com>, "x86@kernel.org" <x86@kernel.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
List-ID: <linux-mm.kvack.org>

--_002_DA586906BA1FFC4384FCFD6429ECE860316C0133shzsmsx502ccrco_
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: quoted-printable

Resend the v3 patch after reviewed by KAMEZAWA Hiroyuki. We still keep the=
=20
Old e820map, update variable max_pfn, max_low_pfn and high_memory only.=20
It is dependent on Fenguang's page_is_ram patch.

Memory-Hotplug: Fix the bug on interface /dev/mem for 64-bit kernel

The new added memory can not be access by interface /dev/mem, because we do=
 not
 update the variable high_memory, max_pfn and max_low_pfn.

Memory hotplug still has critical issues for 32-bit kernel, and it is more=
=20
important for 64-bit kernel, we fix it on 64-bit first. We add a function=20
update_end_of_memory_vars in file arch/x86/mm/init.c to update these variab=
les.

CC: Andi Kleen <ak@linux.intel.com>
CC: Li Haicheng <haicheng.li@intel.com>
Reviewed-by: Wu Fengguang <fengguang.wu@intel.com>
Reviewed-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Signed-off-by: Shaohui Zheng <shaohui.zheng@intel.com>
diff --git a/arch/x86/mm/init.c b/arch/x86/mm/init.c
index d406c52..b6a85cc 100644
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
@@ -386,3 +387,24 @@ void free_initrd_mem(unsigned long start, unsigned lon=
g end)
 	free_init_pages("initrd memory", start, end);
 }
 #endif
+
+/**
+ * After memory hotplug, the variable max_pfn, max_low_pfn and high_memory=
 will
+ * be affected, it will be updated in this function. Memory hotplug still =
has
+ * critical issues on 32-bit kennel, it was more important on 64-bit kerne=
l,
+ * so we update the variables for 64-bit kernel first, fix me in future fo=
r
+ * 32-bit kenrel.
+ */
+void __meminit __attribute__((weak)) update_end_of_memory_vars(u64 start,
+		u64 size)
+{
+#ifdef CONFIG_X86_64
+	unsigned long start_pfn =3D start >> PAGE_SHIFT;
+	unsigned long end_pfn =3D PFN_UP(start + size);
+
+	if (end_pfn > max_pfn) {
+		max_low_pfn =3D max_pfn =3D end_pfn;
+		high_memory =3D (void *)__va(max_pfn * PAGE_SIZE - 1) + 1;
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
index 030ce8a..3e94b23 100644
--- a/mm/memory_hotplug.c
+++ b/mm/memory_hotplug.c
@@ -523,6 +523,9 @@ int __ref add_memory(int nid, u64 start, u64 size)
 		BUG_ON(ret);
 	}
=20
+	/* update max_pfn, max_low_pfn and high_memory */
+	update_end_of_memory_vars(start, size);
+
 	goto out;
=20
 error:

Thanks & Regards,
Shaohui




--_002_DA586906BA1FFC4384FCFD6429ECE860316C0133shzsmsx502ccrco_
Content-Type: application/octet-stream;
	name="memory-hotplug-fix-the-bug-on-interface-dev-mem-v3.patch"
Content-Description: memory-hotplug-fix-the-bug-on-interface-dev-mem-v3.patch
Content-Disposition: attachment;
	filename="memory-hotplug-fix-the-bug-on-interface-dev-mem-v3.patch";
	size=2529; creation-date="Tue, 12 Jan 2010 15:40:51 GMT";
	modification-date="Tue, 12 Jan 2010 23:21:09 GMT"
Content-Transfer-Encoding: base64

TWVtb3J5LUhvdHBsdWc6IEZpeCB0aGUgYnVnIG9uIGludGVyZmFjZSAvZGV2L21lbSBmb3IgNjQt
Yml0IGtlcm5lbAoKVGhlIG5ldyBhZGRlZCBtZW1vcnkgY2FuIG5vdCBiZSBhY2Nlc3MgYnkgaW50
ZXJmYWNlIC9kZXYvbWVtLCBiZWNhdXNlIHdlIGRvIG5vdAogdXBkYXRlIHRoZSB2YXJpYWJsZSBo
aWdoX21lbW9yeSwgbWF4X3BmbiBhbmQgbWF4X2xvd19wZm4uCgpNZW1vcnkgaG90cGx1ZyBzdGls
bCBoYXMgY3JpdGljYWwgaXNzdWVzIGZvciAzMi1iaXQga2VybmVsLCBhbmQgaXQgaXMgbW9yZSAK
aW1wb3J0YW50IGZvciA2NC1iaXQga2VybmVsLCB3ZSBmaXggaXQgb24gNjQtYml0IGZpcnN0LiBX
ZSBhZGQgYSBmdW5jdGlvbiAKdXBkYXRlX2VuZF9vZl9tZW1vcnlfdmFycyBpbiBmaWxlIGFyY2gv
eDg2L21tL2luaXQuYyB0byB1cGRhdGUgdGhlc2UgdmFyaWFibGVzLgoKU2lnbmVkLW9mZi1ieTog
U2hhb2h1aSBaaGVuZyA8c2hhb2h1aS56aGVuZ0BpbnRlbC5jb20+CkNDOiBBbmRpIEtsZWVuIDxh
a0BsaW51eC5pbnRlbC5jb20+CkNDOiBMaSBIYWljaGVuZyA8aGFpY2hlbmcubGlAaW50ZWwuY29t
PgpSZXZpZXdlZC1ieTogV3UgRmVuZ2d1YW5nIDxmZW5nZ3Vhbmcud3VAaW50ZWwuY29tPgpSZXZp
ZXdlZC1ieTogS0FNRVpBV0EgSGlyb3l1a2kgPGthbWV6YXdhLmhpcm95dUBqcC5mdWppdHN1LmNv
bT4KZGlmZiAtLWdpdCBhL2FyY2gveDg2L21tL2luaXQuYyBiL2FyY2gveDg2L21tL2luaXQuYwpp
bmRleCBkNDA2YzUyLi5iNmE4NWNjIDEwMDY0NAotLS0gYS9hcmNoL3g4Ni9tbS9pbml0LmMKKysr
IGIvYXJjaC94ODYvbW0vaW5pdC5jCkBAIC0xLDYgKzEsNyBAQAogI2luY2x1ZGUgPGxpbnV4L2lu
aXRyZC5oPgogI2luY2x1ZGUgPGxpbnV4L2lvcG9ydC5oPgogI2luY2x1ZGUgPGxpbnV4L3N3YXAu
aD4KKyNpbmNsdWRlIDxsaW51eC9ib290bWVtLmg+CiAKICNpbmNsdWRlIDxhc20vY2FjaGVmbHVz
aC5oPgogI2luY2x1ZGUgPGFzbS9lODIwLmg+CkBAIC0zODYsMyArMzg3LDI0IEBAIHZvaWQgZnJl
ZV9pbml0cmRfbWVtKHVuc2lnbmVkIGxvbmcgc3RhcnQsIHVuc2lnbmVkIGxvbmcgZW5kKQogCWZy
ZWVfaW5pdF9wYWdlcygiaW5pdHJkIG1lbW9yeSIsIHN0YXJ0LCBlbmQpOwogfQogI2VuZGlmCisK
Ky8qKgorICogQWZ0ZXIgbWVtb3J5IGhvdHBsdWcsIHRoZSB2YXJpYWJsZSBtYXhfcGZuLCBtYXhf
bG93X3BmbiBhbmQgaGlnaF9tZW1vcnkgd2lsbAorICogYmUgYWZmZWN0ZWQsIGl0IHdpbGwgYmUg
dXBkYXRlZCBpbiB0aGlzIGZ1bmN0aW9uLiBNZW1vcnkgaG90cGx1ZyBzdGlsbCBoYXMKKyAqIGNy
aXRpY2FsIGlzc3VlcyBvbiAzMi1iaXQga2VubmVsLCBpdCB3YXMgbW9yZSBpbXBvcnRhbnQgb24g
NjQtYml0IGtlcm5lbCwKKyAqIHNvIHdlIHVwZGF0ZSB0aGUgdmFyaWFibGVzIGZvciA2NC1iaXQg
a2VybmVsIGZpcnN0LCBmaXggbWUgaW4gZnV0dXJlIGZvcgorICogMzItYml0IGtlbnJlbC4KKyAq
Lwordm9pZCBfX21lbWluaXQgX19hdHRyaWJ1dGVfXygod2VhaykpIHVwZGF0ZV9lbmRfb2ZfbWVt
b3J5X3ZhcnModTY0IHN0YXJ0LAorCQl1NjQgc2l6ZSkKK3sKKyNpZmRlZiBDT05GSUdfWDg2XzY0
CisJdW5zaWduZWQgbG9uZyBzdGFydF9wZm4gPSBzdGFydCA+PiBQQUdFX1NISUZUOworCXVuc2ln
bmVkIGxvbmcgZW5kX3BmbiA9IFBGTl9VUChzdGFydCArIHNpemUpOworCisJaWYgKGVuZF9wZm4g
PiBtYXhfcGZuKSB7CisJCW1heF9sb3dfcGZuID0gbWF4X3BmbiA9IGVuZF9wZm47CisJCWhpZ2hf
bWVtb3J5ID0gKHZvaWQgKilfX3ZhKG1heF9wZm4gKiBQQUdFX1NJWkUgLSAxKSArIDE7CisJfQor
I2VuZGlmIC8qIENPTkZJR19YODZfNjQgKi8KK30KZGlmZiAtLWdpdCBhL2luY2x1ZGUvbGludXgv
Ym9vdG1lbS5oIGIvaW5jbHVkZS9saW51eC9ib290bWVtLmgKaW5kZXggYjEwZWM0OS4uODQ1MzNh
NSAxMDA2NDQKLS0tIGEvaW5jbHVkZS9saW51eC9ib290bWVtLmgKKysrIGIvaW5jbHVkZS9saW51
eC9ib290bWVtLmgKQEAgLTEzLDYgKzEzLDcgQEAKIAogZXh0ZXJuIHVuc2lnbmVkIGxvbmcgbWF4
X2xvd19wZm47CiBleHRlcm4gdW5zaWduZWQgbG9uZyBtaW5fbG93X3BmbjsKK2V4dGVybiB2b2lk
IHVwZGF0ZV9lbmRfb2ZfbWVtb3J5X3ZhcnModTY0IHN0YXJ0LCB1NjQgc2l6ZSk7CiAKIC8qCiAg
KiBoaWdoZXN0IHBhZ2UKZGlmZiAtLWdpdCBhL21tL21lbW9yeV9ob3RwbHVnLmMgYi9tbS9tZW1v
cnlfaG90cGx1Zy5jCmluZGV4IDAzMGNlOGEuLjNlOTRiMjMgMTAwNjQ0Ci0tLSBhL21tL21lbW9y
eV9ob3RwbHVnLmMKKysrIGIvbW0vbWVtb3J5X2hvdHBsdWcuYwpAQCAtNTIzLDYgKzUyMyw5IEBA
IGludCBfX3JlZiBhZGRfbWVtb3J5KGludCBuaWQsIHU2NCBzdGFydCwgdTY0IHNpemUpCiAJCUJV
R19PTihyZXQpOwogCX0KIAorCS8qIHVwZGF0ZSBtYXhfcGZuLCBtYXhfbG93X3BmbiBhbmQgaGln
aF9tZW1vcnkgKi8KKwl1cGRhdGVfZW5kX29mX21lbW9yeV92YXJzKHN0YXJ0LCBzaXplKTsKKwog
CWdvdG8gb3V0OwogCiBlcnJvcjoK

--_002_DA586906BA1FFC4384FCFD6429ECE860316C0133shzsmsx502ccrco_--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
