Date: Sat, 05 Oct 2002 00:18:23 -0700
From: "Martin J. Bligh" <mbligh@aracnet.com>
Reply-To: "Martin J. Bligh" <mbligh@aracnet.com>
Subject: Breakout struct page
Message-ID: <1165733025.1033777103@[10.10.2.3]>
MIME-Version: 1.0
Content-Type: multipart/mixed; boundary="==========1165749864=========="
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@digeo.com>
Cc: linux-mm mailing list <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

--==========1165749864==========
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

This very boring patch breaks out struct page into it's own header
file. This should allow you to do struct page arithmetic in other
header files using static inlines instead of horribly complex macros 
... by just including <linux/struct_page.h>, which avoids dependency
problems.

(inlined to read, attatched for lower probability of mangling)

Martin.

diff -purN -X /home/mbligh/.diff.exclude virgin/include/linux/mm.h struct_page/include/linux/mm.h
--- virgin/include/linux/mm.h	Fri Oct  4 12:15:24 2002
+++ struct_page/include/linux/mm.h	Fri Oct  4 23:10:08 2002
@@ -132,55 +132,7 @@ struct vm_operations_struct {
 	struct page * (*nopage)(struct vm_area_struct * area, unsigned long address, int unused);
 };
 
-/* forward declaration; pte_chain is meant to be internal to rmap.c */
-struct pte_chain;
-
-/*
- * Each physical page in the system has a struct page associated with
- * it to keep track of whatever it is we are using the page for at the
- * moment. Note that we have no way to track which tasks are using
- * a page.
- *
- * Try to keep the most commonly accessed fields in single cache lines
-
* here (16 bytes or greater).  This ordering should be particularly
- * beneficial on 32-bit processors.
- *
- * The first line is data used in page cache lookup, the second line
- * is used for linear searches (eg. clock algorithm scans). 
- *
- * TODO: make this structure smaller, it could be as small as 32 bytes.
- */
-struct page {
-	unsigned long flags;		/* atomic flags, some possibly
-					   updated asynchronously */
-	atomic_t count;			/* Usage count, see below. */
-	struct list_head list;		/* ->mapping has some page lists. */
-	struct address_space *mapping;	/* The inode (or ...) we belong to. */
-	unsigned long index;		/* Our offset within mapping. */
-	struct list_head lru;		/* Pageout list, eg. active_list;
-					   protected by
zone->lru_lock !! */
-	union {
-		struct pte_chain *chain;/* Reverse pte mapping pointer.
-					 * protected by PG_chainlock */
-		pte_addr_t direct;
-	} pte;
-	unsigned long private;		/* mapping-private opaque data */
-
-	/*
-	 * On machines where all RAM is mapped into kernel address space,
-	 * we can simply calculate the virtual address. On machines with
-	 * highmem some memory is mapped into kernel virtual memory
-	 * dynamically, so we need a place to store that address.
-	 * Note that this field could be 16 bits on x86 ... ;)
-	 *
-	 * Architectures with slow multiplication can define
-	 * WANT_PAGE_VIRTUAL in asm/page.h
-	 */
-#if defined(WANT_PAGE_VIRTUAL)
-	void *virtual;			/* Kernel virtual address (NULL if
-					   not kmapped, ie.
highmem) */
-#endif /* CONFIG_HIGMEM || WANT_PAGE_VIRTUAL */
-};
+#include <linux/struct_page.h>
 
 /*
  * FIXME: take this include out, include page-flags.h in
diff -purN -X /home/mbligh/.diff.exclude virgin/include/linux/struct_page.h struct_page/include/linux/struct_page.h
--- virgin/include/linux/struct_page.h	Wed Dec 31 16:00:00 1969
+++ struct_page/include/linux/struct_page.h	Fri Oct  4 23:09:15 2002
@@ -0,0 +1,54 @@
+#ifndef _LINUX_STRUCT_PAGE_H
+#define _LINUX_STRUCT_PAGE_H
+
+/* forward declaration; pte_chain is meant to be internal to rmap.c */
+struct pte_chain;
+
+/*
+ * Each physical page in the system has a struct page associated with
+ * it to keep track of whatever it is we are using the page for at the
+ * moment. Note that we have
no way to track which tasks are using
+ * a page.
+ *
+ * Try to keep the most commonly accessed fields in single cache lines
+ * here (16 bytes or greater).  This ordering should be particularly
+ * beneficial on 32-bit processors.
+ *
+ * The first line is data used in page cache lookup, the second line
+ * is used for linear searches (eg. clock algorithm scans). 
+ *
+ * TODO: make this structure smaller, it could be as small as 32 bytes.
+ */
+struct page {
+	unsigned long flags;		/* atomic flags, some possibly
+					   updated asynchronously */
+	atomic_t count;			/* Usage count, see below. */
+	struct list_head list;		/* ->mapping has some page lists. */
+	struct address_space *mapping;	/* The inode (or ...) we belong to. */
+	unsigned long
index;		/* Our offset within mapping. */
+	struct list_head lru;		/* Pageout list, eg. active_list;
+					   protected by zone->lru_lock !! */
+	union {
+		struct pte_chain *chain;/* Reverse pte mapping pointer.
+					 * protected by PG_chainlock */
+		pte_addr_t direct;
+	} pte;
+	unsigned long private;		/* mapping-private opaque data */
+
+	/*
+	 * On machines where all RAM is mapped into kernel address space,
+	 * we can simply calculate the virtual address. On machines with
+	 * highmem some memory is mapped into kernel virtual memory
+	 * dynamically, so we need a place to store that address.
+	 * Note that this field could be 16 bits on x86 ... ;)
+	 *
+	 * Architectures with slow multiplication can define
+	 * WANT_PAGE_VIRTUAL in asm/page.h

+	 */
+#if defined(WANT_PAGE_VIRTUAL)
+	void *virtual;			/* Kernel virtual address (NULL if
+					   not kmapped, ie. highmem) */
+#endif /* CONFIG_HIGMEM || WANT_PAGE_VIRTUAL */
+};
+
+#endif

--==========1165749864==========
Content-Type: application/octet-stream; name=struct_page
Content-Transfer-Encoding: base64
Content-Disposition: attachment; filename=struct_page; size=4734

ZGlmZiAtcHVyTiAtWCAvaG9tZS9tYmxpZ2gvLmRpZmYuZXhjbHVkZSB2aXJnaW4vaW5jbHVkZS9s
aW51eC9tbS5oIHN0cnVjdF9wYWdlL2luY2x1ZGUvbGludXgvbW0uaAotLS0gdmlyZ2luL2luY2x1
ZGUvbGludXgvbW0uaAlGcmkgT2N0ICA0IDEyOjE1OjI0IDIwMDIKKysrIHN0cnVjdF9wYWdlL2lu
Y2x1ZGUvbGludXgvbW0uaAlGcmkgT2N0ICA0IDIzOjEwOjA4IDIwMDIKQEAgLTEzMiw1NSArMTMy
LDcgQEAgc3RydWN0IHZtX29wZXJhdGlvbnNfc3RydWN0IHsKIAlzdHJ1Y3QgcGFnZSAqICgqbm9w
YWdlKShzdHJ1Y3Qgdm1fYXJlYV9zdHJ1Y3QgKiBhcmVhLCB1bnNpZ25lZCBsb25nIGFkZHJlc3Ms
IGludCB1bnVzZWQpOwogfTsKIAotLyogZm9yd2FyZCBkZWNsYXJhdGlvbjsgcHRlX2NoYWluIGlz
IG1lYW50IHRvIGJlIGludGVybmFsIHRvIHJtYXAuYyAqLwotc3RydWN0IHB0ZV9jaGFpbjsKLQot
LyoKLSAqIEVhY2ggcGh5c2ljYWwgcGFnZSBpbiB0aGUgc3lzdGVtIGhhcyBhIHN0cnVjdCBwYWdl
IGFzc29jaWF0ZWQgd2l0aAotICogaXQgdG8ga2VlcCB0cmFjayBvZiB3aGF0ZXZlciBpdCBpcyB3
ZSBhcmUgdXNpbmcgdGhlIHBhZ2UgZm9yIGF0IHRoZQotICogbW9tZW50LiBOb3RlIHRoYXQgd2Ug
aGF2ZSBubyB3YXkgdG8gdHJhY2sgd2hpY2ggdGFza3MgYXJlIHVzaW5nCi0gKiBhIHBhZ2UuCi0g
KgotICogVHJ5IHRvIGtlZXAgdGhlIG1vc3QgY29tbW9ubHkgYWNjZXNzZWQgZmllbGRzIGluIHNp
bmdsZSBjYWNoZSBsaW5lcwotICogaGVyZSAoMTYgYnl0ZXMgb3IgZ3JlYXRlcikuICBUaGlzIG9y
ZGVyaW5nIHNob3VsZCBiZSBwYXJ0aWN1bGFybHkKLSAqIGJlbmVmaWNpYWwgb24gMzItYml0IHBy
b2Nlc3NvcnMuCi0gKgotICogVGhlIGZpcnN0IGxpbmUgaXMgZGF0YSB1c2VkIGluIHBhZ2UgY2Fj
aGUgbG9va3VwLCB0aGUgc2Vjb25kIGxpbmUKLSAqIGlzIHVzZWQgZm9yIGxpbmVhciBzZWFyY2hl
cyAoZWcuIGNsb2NrIGFsZ29yaXRobSBzY2FucykuIAotICoKLSAqIFRPRE86IG1ha2UgdGhpcyBz
dHJ1Y3R1cmUgc21hbGxlciwgaXQgY291bGQgYmUgYXMgc21hbGwgYXMgMzIgYnl0ZXMuCi0gKi8K
LXN0cnVjdCBwYWdlIHsKLQl1bnNpZ25lZCBsb25nIGZsYWdzOwkJLyogYXRvbWljIGZsYWdzLCBz
b21lIHBvc3NpYmx5Ci0JCQkJCSAgIHVwZGF0ZWQgYXN5bmNocm9ub3VzbHkgKi8KLQlhdG9taWNf
dCBjb3VudDsJCQkvKiBVc2FnZSBjb3VudCwgc2VlIGJlbG93LiAqLwotCXN0cnVjdCBsaXN0X2hl
YWQgbGlzdDsJCS8qIC0+bWFwcGluZyBoYXMgc29tZSBwYWdlIGxpc3RzLiAqLwotCXN0cnVjdCBh
ZGRyZXNzX3NwYWNlICptYXBwaW5nOwkvKiBUaGUgaW5vZGUgKG9yIC4uLikgd2UgYmVsb25nIHRv
LiAqLwotCXVuc2lnbmVkIGxvbmcgaW5kZXg7CQkvKiBPdXIgb2Zmc2V0IHdpdGhpbiBtYXBwaW5n
LiAqLwotCXN0cnVjdCBsaXN0X2hlYWQgbHJ1OwkJLyogUGFnZW91dCBsaXN0LCBlZy4gYWN0aXZl
X2xpc3Q7Ci0JCQkJCSAgIHByb3RlY3RlZCBieSB6b25lLT5scnVfbG9jayAhISAqLwotCXVuaW9u
IHsKLQkJc3RydWN0IHB0ZV9jaGFpbiAqY2hhaW47LyogUmV2ZXJzZSBwdGUgbWFwcGluZyBwb2lu
dGVyLgotCQkJCQkgKiBwcm90ZWN0ZWQgYnkgUEdfY2hhaW5sb2NrICovCi0JCXB0ZV9hZGRyX3Qg
ZGlyZWN0OwotCX0gcHRlOwotCXVuc2lnbmVkIGxvbmcgcHJpdmF0ZTsJCS8qIG1hcHBpbmctcHJp
dmF0ZSBvcGFxdWUgZGF0YSAqLwotCi0JLyoKLQkgKiBPbiBtYWNoaW5lcyB3aGVyZSBhbGwgUkFN
IGlzIG1hcHBlZCBpbnRvIGtlcm5lbCBhZGRyZXNzIHNwYWNlLAotCSAqIHdlIGNhbiBzaW1wbHkg
Y2FsY3VsYXRlIHRoZSB2aXJ0dWFsIGFkZHJlc3MuIE9uIG1hY2hpbmVzIHdpdGgKLQkgKiBoaWdo
bWVtIHNvbWUgbWVtb3J5IGlzIG1hcHBlZCBpbnRvIGtlcm5lbCB2aXJ0dWFsIG1lbW9yeQotCSAq
IGR5bmFtaWNhbGx5LCBzbyB3ZSBuZWVkIGEgcGxhY2UgdG8gc3RvcmUgdGhhdCBhZGRyZXNzLgot
CSAqIE5vdGUgdGhhdCB0aGlzIGZpZWxkIGNvdWxkIGJlIDE2IGJpdHMgb24geDg2IC4uLiA7KQot
CSAqCi0JICogQXJjaGl0ZWN0dXJlcyB3aXRoIHNsb3cgbXVsdGlwbGljYXRpb24gY2FuIGRlZmlu
ZQotCSAqIFdBTlRfUEFHRV9WSVJUVUFMIGluIGFzbS9wYWdlLmgKLQkgKi8KLSNpZiBkZWZpbmVk
KFdBTlRfUEFHRV9WSVJUVUFMKQotCXZvaWQgKnZpcnR1YWw7CQkJLyogS2VybmVsIHZpcnR1YWwg
YWRkcmVzcyAoTlVMTCBpZgotCQkJCQkgICBub3Qga21hcHBlZCwgaWUuIGhpZ2htZW0pICovCi0j
ZW5kaWYgLyogQ09ORklHX0hJR01FTSB8fCBXQU5UX1BBR0VfVklSVFVBTCAqLwotfTsKKyNpbmNs
dWRlIDxsaW51eC9zdHJ1Y3RfcGFnZS5oPgogCiAvKgogICogRklYTUU6IHRha2UgdGhpcyBpbmNs
dWRlIG91dCwgaW5jbHVkZSBwYWdlLWZsYWdzLmggaW4KZGlmZiAtcHVyTiAtWCAvaG9tZS9tYmxp
Z2gvLmRpZmYuZXhjbHVkZSB2aXJnaW4vaW5jbHVkZS9saW51eC9zdHJ1Y3RfcGFnZS5oIHN0cnVj
dF9wYWdlL2luY2x1ZGUvbGludXgvc3RydWN0X3BhZ2UuaAotLS0gdmlyZ2luL2luY2x1ZGUvbGlu
dXgvc3RydWN0X3BhZ2UuaAlXZWQgRGVjIDMxIDE2OjAwOjAwIDE5NjkKKysrIHN0cnVjdF9wYWdl
L2luY2x1ZGUvbGludXgvc3RydWN0X3BhZ2UuaAlGcmkgT2N0ICA0IDIzOjA5OjE1IDIwMDIKQEAg
LTAsMCArMSw1NCBAQAorI2lmbmRlZiBfTElOVVhfU1RSVUNUX1BBR0VfSAorI2RlZmluZSBfTElO
VVhfU1RSVUNUX1BBR0VfSAorCisvKiBmb3J3YXJkIGRlY2xhcmF0aW9uOyBwdGVfY2hhaW4gaXMg
bWVhbnQgdG8gYmUgaW50ZXJuYWwgdG8gcm1hcC5jICovCitzdHJ1Y3QgcHRlX2NoYWluOworCisv
KgorICogRWFjaCBwaHlzaWNhbCBwYWdlIGluIHRoZSBzeXN0ZW0gaGFzIGEgc3RydWN0IHBhZ2Ug
YXNzb2NpYXRlZCB3aXRoCisgKiBpdCB0byBrZWVwIHRyYWNrIG9mIHdoYXRldmVyIGl0IGlzIHdl
IGFyZSB1c2luZyB0aGUgcGFnZSBmb3IgYXQgdGhlCisgKiBtb21lbnQuIE5vdGUgdGhhdCB3ZSBo
YXZlIG5vIHdheSB0byB0cmFjayB3aGljaCB0YXNrcyBhcmUgdXNpbmcKKyAqIGEgcGFnZS4KKyAq
CisgKiBUcnkgdG8ga2VlcCB0aGUgbW9zdCBjb21tb25seSBhY2Nlc3NlZCBmaWVsZHMgaW4gc2lu
Z2xlIGNhY2hlIGxpbmVzCisgKiBoZXJlICgxNiBieXRlcyBvciBncmVhdGVyKS4gIFRoaXMgb3Jk
ZXJpbmcgc2hvdWxkIGJlIHBhcnRpY3VsYXJseQorICogYmVuZWZpY2lhbCBvbiAzMi1iaXQgcHJv
Y2Vzc29ycy4KKyAqCisgKiBUaGUgZmlyc3QgbGluZSBpcyBkYXRhIHVzZWQgaW4gcGFnZSBjYWNo
ZSBsb29rdXAsIHRoZSBzZWNvbmQgbGluZQorICogaXMgdXNlZCBmb3IgbGluZWFyIHNlYXJjaGVz
IChlZy4gY2xvY2sgYWxnb3JpdGhtIHNjYW5zKS4gCisgKgorICogVE9ETzogbWFrZSB0aGlzIHN0
cnVjdHVyZSBzbWFsbGVyLCBpdCBjb3VsZCBiZSBhcyBzbWFsbCBhcyAzMiBieXRlcy4KKyAqLwor
c3RydWN0IHBhZ2UgeworCXVuc2lnbmVkIGxvbmcgZmxhZ3M7CQkvKiBhdG9taWMgZmxhZ3MsIHNv
bWUgcG9zc2libHkKKwkJCQkJICAgdXBkYXRlZCBhc3luY2hyb25vdXNseSAqLworCWF0b21pY190
IGNvdW50OwkJCS8qIFVzYWdlIGNvdW50LCBzZWUgYmVsb3cuICovCisJc3RydWN0IGxpc3RfaGVh
ZCBsaXN0OwkJLyogLT5tYXBwaW5nIGhhcyBzb21lIHBhZ2UgbGlzdHMuICovCisJc3RydWN0IGFk
ZHJlc3Nfc3BhY2UgKm1hcHBpbmc7CS8qIFRoZSBpbm9kZSAob3IgLi4uKSB3ZSBiZWxvbmcgdG8u
ICovCisJdW5zaWduZWQgbG9uZyBpbmRleDsJCS8qIE91ciBvZmZzZXQgd2l0aGluIG1hcHBpbmcu
ICovCisJc3RydWN0IGxpc3RfaGVhZCBscnU7CQkvKiBQYWdlb3V0IGxpc3QsIGVnLiBhY3RpdmVf
bGlzdDsKKwkJCQkJICAgcHJvdGVjdGVkIGJ5IHpvbmUtPmxydV9sb2NrICEhICovCisJdW5pb24g
eworCQlzdHJ1Y3QgcHRlX2NoYWluICpjaGFpbjsvKiBSZXZlcnNlIHB0ZSBtYXBwaW5nIHBvaW50
ZXIuCisJCQkJCSAqIHByb3RlY3RlZCBieSBQR19jaGFpbmxvY2sgKi8KKwkJcHRlX2FkZHJfdCBk
aXJlY3Q7CisJfSBwdGU7CisJdW5zaWduZWQgbG9uZyBwcml2YXRlOwkJLyogbWFwcGluZy1wcml2
YXRlIG9wYXF1ZSBkYXRhICovCisKKwkvKgorCSAqIE9uIG1hY2hpbmVzIHdoZXJlIGFsbCBSQU0g
aXMgbWFwcGVkIGludG8ga2VybmVsIGFkZHJlc3Mgc3BhY2UsCisJICogd2UgY2FuIHNpbXBseSBj
YWxjdWxhdGUgdGhlIHZpcnR1YWwgYWRkcmVzcy4gT24gbWFjaGluZXMgd2l0aAorCSAqIGhpZ2ht
ZW0gc29tZSBtZW1vcnkgaXMgbWFwcGVkIGludG8ga2VybmVsIHZpcnR1YWwgbWVtb3J5CisJICog
ZHluYW1pY2FsbHksIHNvIHdlIG5lZWQgYSBwbGFjZSB0byBzdG9yZSB0aGF0IGFkZHJlc3MuCisJ
ICogTm90ZSB0aGF0IHRoaXMgZmllbGQgY291bGQgYmUgMTYgYml0cyBvbiB4ODYgLi4uIDspCisJ
ICoKKwkgKiBBcmNoaXRlY3R1cmVzIHdpdGggc2xvdyBtdWx0aXBsaWNhdGlvbiBjYW4gZGVmaW5l
CisJICogV0FOVF9QQUdFX1ZJUlRVQUwgaW4gYXNtL3BhZ2UuaAorCSAqLworI2lmIGRlZmluZWQo
V0FOVF9QQUdFX1ZJUlRVQUwpCisJdm9pZCAqdmlydHVhbDsJCQkvKiBLZXJuZWwgdmlydHVhbCBh
ZGRyZXNzIChOVUxMIGlmCisJCQkJCSAgIG5vdCBrbWFwcGVkLCBpZS4gaGlnaG1lbSkgKi8KKyNl
bmRpZiAvKiBDT05GSUdfSElHTUVNIHx8IFdBTlRfUEFHRV9WSVJUVUFMICovCit9OworCisjZW5k
aWYK

--==========1165749864==========--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
