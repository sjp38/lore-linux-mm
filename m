Date: Sat, 21 Sep 2002 14:44:49 -0700
From: "Martin J. Bligh" <fletch@aracnet.com>
Subject: [PATCH] Ensure contig page data is not define for discontigmem
Message-ID: <8179511.1032619489@[10.10.2.3]>
MIME-Version: 1.0
Content-Type: multipart/mixed; boundary="==========08196350=========="
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@digeo.com>
Cc: linux-mm mailing list <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

--==========08196350==========
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

This patch fixes a nasty bug that wli found in buffer.c which
cause an oops - we were using contig_page_data on a discontigmem
machine. It's a slightly modified version of the fix wli suggested, 
tested on NUMA-Q. 

I've also added code to not define contig_page_data for discontigmem
systems, to stop this from happening again. I wrapped a couple of 
bootmem functions that were using it in #ifndef CONFIG_DISCONTIGMEM.
I suppose it's possible (though unlikely) that some other discontig 
arch might need to wrap a couple of functions in their tree similarly, 
but any borkage will just give a simple clear compiler error telling 
them exactly where the problem is.

Inlined for easy reading, attatched as well in case life mangles
things.

diff -urN -X /home/mbligh/.diff.exclude numafixes/fs/buffer.c numafixes2/fs/buffer.c
--- numafixes/fs/buffer.c	Wed Sep 18 20:41:12 2002
+++ numafixes2/fs/buffer.c	Wed Sep 18 21:41:05 2002
@@ -468,12 +468,17 @@
 static void free_more_memory(void)
 {
 	struct zone *zone;
+	pg_data_t *pgdat;
 
-	zone = contig_page_data.node_zonelists[GFP_NOFS&GFP_ZONEMASK].zones[0];
 	wakeup_bdflush(1024);
 	blk_run_queues();
 	yield();
-	try_to_free_pages(zone, GFP_NOFS, 0);
+
+	for_each_pgdat(pgdat) {
+		zone = pgdat->node_zonelists[GFP_NOFS&GFP_ZONEMASK].zones[0];
+		if (zone)
+			try_to_free_pages(zone, GFP_NOFS, 0);
+	}
 }
 
 /*
diff -urN -X /home/mbligh/.diff.exclude numafixes/mm/bootmem.c numafixes2/mm/bootmem.c
--- numafixes/mm/bootmem.c	Tue Sep 17 17:58:50
2002
+++ numafixes2/mm/bootmem.c	Wed Sep 18 21:44:16 2002
@@ -311,6 +311,7 @@
 	return(free_all_bootmem_core(pgdat));
 }
 
+#ifndef CONFIG_DISCONTIGMEM
 unsigned long __init init_bootmem (unsigned long start, unsigned long pages)
 {
 	max_low_pfn = pages;
@@ -334,6 +335,7 @@
 {
 	return(free_all_bootmem_core(&contig_page_data));
 }
+#endif /* !CONFIG_DISCONTIGMEM */
 
 void * __init __alloc_bootmem (unsigned long size, unsigned long align, unsigned long goal)
 {
diff -urN -X /home/mbligh/.diff.exclude numafixes/mm/numa.c numafixes2/mm/numa.c
--- numafixes/mm/numa.c	Wed Sep 18 20:41:12 2002
+++ numafixes2/mm/numa.c	Wed Sep 18 21:41:05 2002
@@ -11,10 +11,10 @@
 
 int numnodes = 1;	/* Initialized for UMA platforms */
 
+#ifndef CONFIG_DISCONTIGMEM
+

static bootmem_data_t contig_bootmem_data;
 pg_data_t contig_page_data = { .bdata = &contig_bootmem_data };
-
-#ifndef CONFIG_DISCONTIGMEM
 
 /*
  * This is meant to be invoked by platforms whose physical memory starts

--==========08196350==========
Content-Type: application/octet-stream; name=numafixes2
Content-Transfer-Encoding: base64
Content-Disposition: attachment; filename=numafixes2; size=1733

ZGlmZiAtdXJOIC1YIC9ob21lL21ibGlnaC8uZGlmZi5leGNsdWRlIG51bWFmaXhlcy9mcy9idWZm
ZXIuYyBudW1hZml4ZXMyL2ZzL2J1ZmZlci5jCi0tLSBudW1hZml4ZXMvZnMvYnVmZmVyLmMJV2Vk
IFNlcCAxOCAyMDo0MToxMiAyMDAyCisrKyBudW1hZml4ZXMyL2ZzL2J1ZmZlci5jCVdlZCBTZXAg
MTggMjE6NDE6MDUgMjAwMgpAQCAtNDY4LDEyICs0NjgsMTcgQEAKIHN0YXRpYyB2b2lkIGZyZWVf
bW9yZV9tZW1vcnkodm9pZCkKIHsKIAlzdHJ1Y3Qgem9uZSAqem9uZTsKKwlwZ19kYXRhX3QgKnBn
ZGF0OwogCi0Jem9uZSA9IGNvbnRpZ19wYWdlX2RhdGEubm9kZV96b25lbGlzdHNbR0ZQX05PRlMm
R0ZQX1pPTkVNQVNLXS56b25lc1swXTsKIAl3YWtldXBfYmRmbHVzaCgxMDI0KTsKIAlibGtfcnVu
X3F1ZXVlcygpOwogCXlpZWxkKCk7Ci0JdHJ5X3RvX2ZyZWVfcGFnZXMoem9uZSwgR0ZQX05PRlMs
IDApOworCisJZm9yX2VhY2hfcGdkYXQocGdkYXQpIHsKKwkJem9uZSA9IHBnZGF0LT5ub2RlX3pv
bmVsaXN0c1tHRlBfTk9GUyZHRlBfWk9ORU1BU0tdLnpvbmVzWzBdOworCQlpZiAoem9uZSkKKwkJ
CXRyeV90b19mcmVlX3BhZ2VzKHpvbmUsIEdGUF9OT0ZTLCAwKTsKKwl9CiB9CiAKIC8qCmRpZmYg
LXVyTiAtWCAvaG9tZS9tYmxpZ2gvLmRpZmYuZXhjbHVkZSBudW1hZml4ZXMvbW0vYm9vdG1lbS5j
IG51bWFmaXhlczIvbW0vYm9vdG1lbS5jCi0tLSBudW1hZml4ZXMvbW0vYm9vdG1lbS5jCVR1ZSBT
ZXAgMTcgMTc6NTg6NTAgMjAwMgorKysgbnVtYWZpeGVzMi9tbS9ib290bWVtLmMJV2VkIFNlcCAx
OCAyMTo0NDoxNiAyMDAyCkBAIC0zMTEsNiArMzExLDcgQEAKIAlyZXR1cm4oZnJlZV9hbGxfYm9v
dG1lbV9jb3JlKHBnZGF0KSk7CiB9CiAKKyNpZm5kZWYgQ09ORklHX0RJU0NPTlRJR01FTQogdW5z
aWduZWQgbG9uZyBfX2luaXQgaW5pdF9ib290bWVtICh1bnNpZ25lZCBsb25nIHN0YXJ0LCB1bnNp
Z25lZCBsb25nIHBhZ2VzKQogewogCW1heF9sb3dfcGZuID0gcGFnZXM7CkBAIC0zMzQsNiArMzM1
LDcgQEAKIHsKIAlyZXR1cm4oZnJlZV9hbGxfYm9vdG1lbV9jb3JlKCZjb250aWdfcGFnZV9kYXRh
KSk7CiB9CisjZW5kaWYgLyogIUNPTkZJR19ESVNDT05USUdNRU0gKi8KIAogdm9pZCAqIF9faW5p
dCBfX2FsbG9jX2Jvb3RtZW0gKHVuc2lnbmVkIGxvbmcgc2l6ZSwgdW5zaWduZWQgbG9uZyBhbGln
biwgdW5zaWduZWQgbG9uZyBnb2FsKQogewpkaWZmIC11ck4gLVggL2hvbWUvbWJsaWdoLy5kaWZm
LmV4Y2x1ZGUgbnVtYWZpeGVzL21tL251bWEuYyBudW1hZml4ZXMyL21tL251bWEuYwotLS0gbnVt
YWZpeGVzL21tL251bWEuYwlXZWQgU2VwIDE4IDIwOjQxOjEyIDIwMDIKKysrIG51bWFmaXhlczIv
bW0vbnVtYS5jCVdlZCBTZXAgMTggMjE6NDE6MDUgMjAwMgpAQCAtMTEsMTAgKzExLDEwIEBACiAK
IGludCBudW1ub2RlcyA9IDE7CS8qIEluaXRpYWxpemVkIGZvciBVTUEgcGxhdGZvcm1zICovCiAK
KyNpZm5kZWYgQ09ORklHX0RJU0NPTlRJR01FTQorCiBzdGF0aWMgYm9vdG1lbV9kYXRhX3QgY29u
dGlnX2Jvb3RtZW1fZGF0YTsKIHBnX2RhdGFfdCBjb250aWdfcGFnZV9kYXRhID0geyAuYmRhdGEg
PSAmY29udGlnX2Jvb3RtZW1fZGF0YSB9OwotCi0jaWZuZGVmIENPTkZJR19ESVNDT05USUdNRU0K
IAogLyoKICAqIFRoaXMgaXMgbWVhbnQgdG8gYmUgaW52b2tlZCBieSBwbGF0Zm9ybXMgd2hvc2Ug
cGh5c2ljYWwgbWVtb3J5IHN0YXJ0cwo=

--==========08196350==========--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
