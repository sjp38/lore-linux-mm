Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id E84B46B0087
	for <linux-mm@kvack.org>; Tue,  4 Jan 2011 02:42:49 -0500 (EST)
Received: from mail06.corp.redhat.com (zmail06.collab.prod.int.phx2.redhat.com [10.5.5.45])
	by mx3-phx2.redhat.com (8.13.8/8.13.8) with ESMTP id p047giYQ022376
	for <linux-mm@kvack.org>; Tue, 4 Jan 2011 02:42:44 -0500
Date: Tue, 4 Jan 2011 02:42:44 -0500 (EST)
From: CAI Qian <caiqian@redhat.com>
Message-ID: <519552481.119951.1294126964024.JavaMail.root@zmail06.collab.prod.int.phx2.redhat.com>
In-Reply-To: <2026935485.119940.1294126785849.JavaMail.root@zmail06.collab.prod.int.phx2.redhat.com>
Subject: [PATCH] hugetlb: remove overcommit sysfs for 1GB pages
MIME-Version: 1.0
Content-Type: multipart/mixed;
	boundary="----=_Part_119950_1703886118.1294126964023"
Sender: owner-linux-mm@kvack.org
To: linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

------=_Part_119950_1703886118.1294126964023
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit

1GB pages cannot be over-commited, attempting to do so results in corruption,
so remove those files for simplicity.

Symptoms:
1) setup 1gb hugepages.

cat /proc/cmdline
...default_hugepagesz=1g hugepagesz=1g hugepages=1...

cat /proc/meminfo
...
HugePages_Total:       1
HugePages_Free:        1
HugePages_Rsvd:        0
HugePages_Surp:        0
Hugepagesize:    1048576 kB
...

2) set nr_overcommit_hugepages

echo 1 >/sys/kernel/mm/hugepages/hugepages-1048576kB/nr_overcommit_hugepages
cat /sys/kernel/mm/hugepages/hugepages-1048576kB/nr_overcommit_hugepages
1

3) overcommit 2gb hugepages.

mmap(NULL, 18446744071562067968, PROT_READ|PROT_WRITE, MAP_SHARED, 3,
	   0) = -1 ENOMEM (Cannot allocate memory)

cat /sys/kernel/mm/hugepages/hugepages-1048576kB/nr_overcommit_hugepages
18446744071589420672

Signed-off-by: CAI Qian <caiqian@redhat.com>
---
 mm/hugetlb.c |   23 +++++++++++++++++++++--
 1 files changed, 21 insertions(+), 2 deletions(-)

diff --git a/mm/hugetlb.c b/mm/hugetlb.c
index c4a3558..adc9a9f 100644
--- a/mm/hugetlb.c
+++ b/mm/hugetlb.c
@@ -1587,6 +1587,20 @@ static struct attribute_group hstate_attr_group = {
 	.attrs = hstate_attrs,
 };
 
+static struct attribute *hstate_1gb_attrs[] = {
+	&nr_hugepages_attr.attr,
+	&free_hugepages_attr.attr,
+	&resv_hugepages_attr.attr,
+#ifdef CONFIG_NUMA
+	&nr_hugepages_mempolicy_attr.attr,
+#endif
+	NULL,
+};
+
+static struct attribute_group hstate_1gb_attr_group = {
+	.attrs = hstate_1gb_attrs,
+};
+
 static int hugetlb_sysfs_add_hstate(struct hstate *h, struct kobject *parent,
 				    struct kobject **hstate_kobjs,
 				    struct attribute_group *hstate_attr_group)
@@ -1615,8 +1629,13 @@ static void __init hugetlb_sysfs_init(void)
 		return;
 
 	for_each_hstate(h) {
-		err = hugetlb_sysfs_add_hstate(h, hugepages_kobj,
-					 hstate_kobjs, &hstate_attr_group);
+		/* 1GB pages can not be over-committed, so don't need those files. */
+		if (huge_page_size(h) == 1UL << 30)
+			err = hugetlb_sysfs_add_hstate(h, hugepages_kobj,
+						hstate_kobjs, &hstate_1gb_attr_group);
+		else
+			err = hugetlb_sysfs_add_hstate(h, hugepages_kobj,
+						hstate_kobjs, &hstate_attr_group);
 		if (err)
 			printk(KERN_ERR "Hugetlb: Unable to add hstate %s",
 								h->name);
-- 
1.7.3.2
------=_Part_119950_1703886118.1294126964023
Content-Type: text/x-patch;
	name=0001-hugetlb-remove-overcommit-sysfs-for-1GB-pages.patch
Content-Transfer-Encoding: base64
Content-Disposition: attachment;
	filename=0001-hugetlb-remove-overcommit-sysfs-for-1GB-pages.patch

RnJvbSBjODgyMDlmN2EyMWVkMGMyNTdjYzIxNWE3ODc0ZGY1MGQ1ZTUyNWQ1IE1vbiBTZXAgMTcg
MDA6MDA6MDAgMjAwMQpGcm9tOiBDQUkgUWlhbiA8Y2FpcWlhbkByZWRoYXQuY29tPgpEYXRlOiBU
dWUsIDQgSmFuIDIwMTEgMTU6MzA6MDAgKzA4MDAKU3ViamVjdDogW1BBVENIXSBodWdldGxiOiBy
ZW1vdmUgb3ZlcmNvbW1pdCBzeXNmcyBmb3IgMUdCIHBhZ2VzCgoxR0IgcGFnZXMgY2Fubm90IGJl
IG92ZXItY29tbWl0ZWQsIGF0dGVtcHRpbmcgdG8gZG8gc28gcmVzdWx0cyBpbiBjb3JydXB0aW9u
LApzbyByZW1vdmUgdGhvc2UgZmlsZXMgZm9yIHNpbXBsaWNpdHkuCgpTeW1wdG9tczoKMSkgc2V0
dXAgMWdiIGh1Z2VwYWdlcy4KCmNhdCAvcHJvYy9jbWRsaW5lCi4uLmRlZmF1bHRfaHVnZXBhZ2Vz
ej0xZyBodWdlcGFnZXN6PTFnIGh1Z2VwYWdlcz0xLi4uCgpjYXQgL3Byb2MvbWVtaW5mbwouLi4K
SHVnZVBhZ2VzX1RvdGFsOiAgICAgICAxCkh1Z2VQYWdlc19GcmVlOiAgICAgICAgMQpIdWdlUGFn
ZXNfUnN2ZDogICAgICAgIDAKSHVnZVBhZ2VzX1N1cnA6ICAgICAgICAwCkh1Z2VwYWdlc2l6ZTog
ICAgMTA0ODU3NiBrQgouLi4KCjIpIHNldCBucl9vdmVyY29tbWl0X2h1Z2VwYWdlcwoKZWNobyAx
ID4vc3lzL2tlcm5lbC9tbS9odWdlcGFnZXMvaHVnZXBhZ2VzLTEwNDg1NzZrQi9ucl9vdmVyY29t
bWl0X2h1Z2VwYWdlcwpjYXQgL3N5cy9rZXJuZWwvbW0vaHVnZXBhZ2VzL2h1Z2VwYWdlcy0xMDQ4
NTc2a0IvbnJfb3ZlcmNvbW1pdF9odWdlcGFnZXMKMQoKMykgb3ZlcmNvbW1pdCAyZ2IgaHVnZXBh
Z2VzLgoKbW1hcChOVUxMLCAxODQ0Njc0NDA3MTU2MjA2Nzk2OCwgUFJPVF9SRUFEfFBST1RfV1JJ
VEUsIE1BUF9TSEFSRUQsIDMsCgkgICAwKSA9IC0xIEVOT01FTSAoQ2Fubm90IGFsbG9jYXRlIG1l
bW9yeSkKCmNhdCAvc3lzL2tlcm5lbC9tbS9odWdlcGFnZXMvaHVnZXBhZ2VzLTEwNDg1NzZrQi9u
cl9vdmVyY29tbWl0X2h1Z2VwYWdlcwoxODQ0Njc0NDA3MTU4OTQyMDY3MgoKU2lnbmVkLW9mZi1i
eTogQ0FJIFFpYW4gPGNhaXFpYW5AcmVkaGF0LmNvbT4KLS0tCiBtbS9odWdldGxiLmMgfCAgIDIz
ICsrKysrKysrKysrKysrKysrKysrKy0tCiAxIGZpbGVzIGNoYW5nZWQsIDIxIGluc2VydGlvbnMo
KyksIDIgZGVsZXRpb25zKC0pCgpkaWZmIC0tZ2l0IGEvbW0vaHVnZXRsYi5jIGIvbW0vaHVnZXRs
Yi5jCmluZGV4IGM0YTM1NTguLmFkYzlhOWYgMTAwNjQ0Ci0tLSBhL21tL2h1Z2V0bGIuYworKysg
Yi9tbS9odWdldGxiLmMKQEAgLTE1ODcsNiArMTU4NywyMCBAQCBzdGF0aWMgc3RydWN0IGF0dHJp
YnV0ZV9ncm91cCBoc3RhdGVfYXR0cl9ncm91cCA9IHsKIAkuYXR0cnMgPSBoc3RhdGVfYXR0cnMs
CiB9OwogCitzdGF0aWMgc3RydWN0IGF0dHJpYnV0ZSAqaHN0YXRlXzFnYl9hdHRyc1tdID0gewor
CSZucl9odWdlcGFnZXNfYXR0ci5hdHRyLAorCSZmcmVlX2h1Z2VwYWdlc19hdHRyLmF0dHIsCisJ
JnJlc3ZfaHVnZXBhZ2VzX2F0dHIuYXR0ciwKKyNpZmRlZiBDT05GSUdfTlVNQQorCSZucl9odWdl
cGFnZXNfbWVtcG9saWN5X2F0dHIuYXR0ciwKKyNlbmRpZgorCU5VTEwsCit9OworCitzdGF0aWMg
c3RydWN0IGF0dHJpYnV0ZV9ncm91cCBoc3RhdGVfMWdiX2F0dHJfZ3JvdXAgPSB7CisJLmF0dHJz
ID0gaHN0YXRlXzFnYl9hdHRycywKK307CisKIHN0YXRpYyBpbnQgaHVnZXRsYl9zeXNmc19hZGRf
aHN0YXRlKHN0cnVjdCBoc3RhdGUgKmgsIHN0cnVjdCBrb2JqZWN0ICpwYXJlbnQsCiAJCQkJICAg
IHN0cnVjdCBrb2JqZWN0ICoqaHN0YXRlX2tvYmpzLAogCQkJCSAgICBzdHJ1Y3QgYXR0cmlidXRl
X2dyb3VwICpoc3RhdGVfYXR0cl9ncm91cCkKQEAgLTE2MTUsOCArMTYyOSwxMyBAQCBzdGF0aWMg
dm9pZCBfX2luaXQgaHVnZXRsYl9zeXNmc19pbml0KHZvaWQpCiAJCXJldHVybjsKIAogCWZvcl9l
YWNoX2hzdGF0ZShoKSB7Ci0JCWVyciA9IGh1Z2V0bGJfc3lzZnNfYWRkX2hzdGF0ZShoLCBodWdl
cGFnZXNfa29iaiwKLQkJCQkJIGhzdGF0ZV9rb2JqcywgJmhzdGF0ZV9hdHRyX2dyb3VwKTsKKwkJ
LyogMUdCIHBhZ2VzIGNhbiBub3QgYmUgb3Zlci1jb21taXR0ZWQsIHNvIGRvbid0IG5lZWQgdGhv
c2UgZmlsZXMuICovCisJCWlmIChodWdlX3BhZ2Vfc2l6ZShoKSA9PSAxVUwgPDwgMzApCisJCQll
cnIgPSBodWdldGxiX3N5c2ZzX2FkZF9oc3RhdGUoaCwgaHVnZXBhZ2VzX2tvYmosCisJCQkJCQlo
c3RhdGVfa29ianMsICZoc3RhdGVfMWdiX2F0dHJfZ3JvdXApOworCQllbHNlCisJCQllcnIgPSBo
dWdldGxiX3N5c2ZzX2FkZF9oc3RhdGUoaCwgaHVnZXBhZ2VzX2tvYmosCisJCQkJCQloc3RhdGVf
a29ianMsICZoc3RhdGVfYXR0cl9ncm91cCk7CiAJCWlmIChlcnIpCiAJCQlwcmludGsoS0VSTl9F
UlIgIkh1Z2V0bGI6IFVuYWJsZSB0byBhZGQgaHN0YXRlICVzIiwKIAkJCQkJCQkJaC0+bmFtZSk7
Ci0tIAoxLjcuMy4yCgo=
------=_Part_119950_1703886118.1294126964023--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
