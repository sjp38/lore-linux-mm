Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f54.google.com (mail-pa0-f54.google.com [209.85.220.54])
	by kanga.kvack.org (Postfix) with ESMTP id E6369680DC6
	for <linux-mm@kvack.org>; Sat,  3 Oct 2015 16:02:10 -0400 (EDT)
Received: by pacex6 with SMTP id ex6so137230120pac.0
        for <linux-mm@kvack.org>; Sat, 03 Oct 2015 13:02:10 -0700 (PDT)
Received: from COL004-OMC1S5.hotmail.com (col004-omc1s5.hotmail.com. [65.55.34.15])
        by mx.google.com with ESMTPS id af8si26958484pbd.110.2015.10.03.13.02.10
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Sat, 03 Oct 2015 13:02:10 -0700 (PDT)
Message-ID: <COL130-W8024C103955022F6D16D3B94A0@phx.gbl>
Content-Type: multipart/mixed;
	boundary="_673bbf67-1069-439f-9647-c28a77af0b0c_"
From: Chen Gang <xili_gchen_5257@hotmail.com>
Subject: [PATCH] mm/mmap.c: Change static function __install_special_mapping
 args' order
Date: Sun, 4 Oct 2015 04:02:09 +0800
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, "kirill.shutemov@linux.intel.com" <kirill.shutemov@linux.intel.com>, "riel@redhat.com" <riel@redhat.com>, "oleg@redhat.com" <oleg@redhat.com>, Michal Hocko <mhocko@suse.cz>, "dave@stgolabs.net" <dave@stgolabs.net>, "pfeiner@google.com" <pfeiner@google.com>, "aarcange@redhat.com" <aarcange@redhat.com>, "vishnu.ps@samsung.com" <vishnu.ps@samsung.com>
Cc: Linux Memory <linux-mm@kvack.org>, kernel mailing list <linux-kernel@vger.kernel.org>

--_673bbf67-1069-439f-9647-c28a77af0b0c_
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable

>From 5a6ffe3515c21d1152586e484c29fed91d2b0b6f Mon Sep 17 00:00:00 2001=0A=
From: Chen Gang <gang.chen.5i5j@gmail.com>=0A=
Date: Sun=2C 4 Oct 2015 03:47:24 +0800=0A=
Subject: [PATCH] mm/mmap.c: Change static function __install_special_mappin=
g args' order=0A=
=0A=
Let __install_special_mapping() args order match the caller=2C so the=0A=
caller can pass their register args directly to callee with no touch.=0A=
=0A=
For most of architectures=2C args (at least the first 5th args) are in=0A=
registers=2C so this change will have effect on most of architectures.=0A=
=0A=
For -O2=2C __install_special_mapping() may be inlined under most of=0A=
architectures=2C but for -Os=2C it should not. So this change can get a=0A=
little better performance for -Os=2C at least.=0A=
=0A=
Signed-off-by: Chen Gang <gang.chen.5i5j@gmail.com>=0A=
---=0A=
=A0mm/mmap.c | 12 ++++++------=0A=
=A01 file changed=2C 6 insertions(+)=2C 6 deletions(-)=0A=
=0A=
diff --git a/mm/mmap.c b/mm/mmap.c=0A=
index f7c1631..98ff62d 100644=0A=
--- a/mm/mmap.c=0A=
+++ b/mm/mmap.c=0A=
@@ -3048=2C8 +3048=2C8 @@ static int special_mapping_fault(struct vm_area_s=
truct *vma=2C=0A=
=A0static struct vm_area_struct *__install_special_mapping(=0A=
=A0	struct mm_struct *mm=2C=0A=
=A0	unsigned long addr=2C unsigned long len=2C=0A=
-	unsigned long vm_flags=2C const struct vm_operations_struct *ops=2C=0A=
-	void *priv)=0A=
+	unsigned long vm_flags=2C void *priv=2C=0A=
+	const struct vm_operations_struct *ops)=0A=
=A0{=0A=
=A0	int ret=3B=0A=
=A0	struct vm_area_struct *vma=3B=0A=
@@ -3098=2C8 +3098=2C8 @@ struct vm_area_struct *_install_special_mapping(=
=0A=
=A0	unsigned long addr=2C unsigned long len=2C=0A=
=A0	unsigned long vm_flags=2C const struct vm_special_mapping *spec)=0A=
=A0{=0A=
-	return __install_special_mapping(mm=2C addr=2C len=2C vm_flags=2C=0A=
-					 &special_mapping_vmops=2C (void *)spec)=3B=0A=
+	return __install_special_mapping(mm=2C addr=2C len=2C vm_flags=2C (void *=
)spec=2C=0A=
+					&special_mapping_vmops)=3B=0A=
=A0}=0A=
=A0=0A=
=A0int install_special_mapping(struct mm_struct *mm=2C=0A=
@@ -3107=2C8 +3107=2C8 @@ int install_special_mapping(struct mm_struct *mm=
=2C=0A=
=A0			 =A0 =A0unsigned long vm_flags=2C struct page **pages)=0A=
=A0{=0A=
=A0	struct vm_area_struct *vma =3D __install_special_mapping(=0A=
-		mm=2C addr=2C len=2C vm_flags=2C &legacy_special_mapping_vmops=2C=0A=
-		(void *)pages)=3B=0A=
+		mm=2C addr=2C len=2C vm_flags=2C (void *)pages=2C=0A=
+		&legacy_special_mapping_vmops)=3B=0A=
=A0=0A=
=A0	return PTR_ERR_OR_ZERO(vma)=3B=0A=
=A0}=0A=
--=A0=0A=
1.9.3 		 	   		  =

--_673bbf67-1069-439f-9647-c28a77af0b0c_
Content-Type: application/octet-stream
Content-Transfer-Encoding: base64
Content-Disposition: attachment;
	filename="0001-mm-mmap.c-Change-static-function-__install_special_m.patch"

RnJvbSA1YTZmZmUzNTE1YzIxZDExNTI1ODZlNDg0YzI5ZmVkOTFkMmIwYjZmIE1vbiBTZXAgMTcg
MDA6MDA6MDAgMjAwMQpGcm9tOiBDaGVuIEdhbmcgPGdhbmcuY2hlbi41aTVqQGdtYWlsLmNvbT4K
RGF0ZTogU3VuLCA0IE9jdCAyMDE1IDAzOjQ3OjI0ICswODAwClN1YmplY3Q6IFtQQVRDSF0gbW0v
bW1hcC5jOiBDaGFuZ2Ugc3RhdGljIGZ1bmN0aW9uIF9faW5zdGFsbF9zcGVjaWFsX21hcHBpbmcg
YXJncycgb3JkZXIKCkxldCBfX2luc3RhbGxfc3BlY2lhbF9tYXBwaW5nKCkgYXJncyBvcmRlciBt
YXRjaCB0aGUgY2FsbGVyLCBzbyB0aGUKY2FsbGVyIGNhbiBwYXNzIHRoZWlyIHJlZ2lzdGVyIGFy
Z3MgZGlyZWN0bHkgdG8gY2FsbGVlIHdpdGggbm8gdG91Y2guCgpGb3IgbW9zdCBvZiBhcmNoaXRl
Y3R1cmVzLCBhcmdzIChhdCBsZWFzdCB0aGUgZmlyc3QgNXRoIGFyZ3MpIGFyZSBpbgpyZWdpc3Rl
cnMsIHNvIHRoaXMgY2hhbmdlIHdpbGwgaGF2ZSBlZmZlY3Qgb24gbW9zdCBvZiBhcmNoaXRlY3R1
cmVzLgoKRm9yIC1PMiwgX19pbnN0YWxsX3NwZWNpYWxfbWFwcGluZygpIG1heSBiZSBpbmxpbmVk
IHVuZGVyIG1vc3Qgb2YKYXJjaGl0ZWN0dXJlcywgYnV0IGZvciAtT3MsIGl0IHNob3VsZCBub3Qu
IFNvIHRoaXMgY2hhbmdlIGNhbiBnZXQgYQpsaXR0bGUgYmV0dGVyIHBlcmZvcm1hbmNlIGZvciAt
T3MsIGF0IGxlYXN0LgoKU2lnbmVkLW9mZi1ieTogQ2hlbiBHYW5nIDxnYW5nLmNoZW4uNWk1akBn
bWFpbC5jb20+Ci0tLQogbW0vbW1hcC5jIHwgMTIgKysrKysrLS0tLS0tCiAxIGZpbGUgY2hhbmdl
ZCwgNiBpbnNlcnRpb25zKCspLCA2IGRlbGV0aW9ucygtKQoKZGlmZiAtLWdpdCBhL21tL21tYXAu
YyBiL21tL21tYXAuYwppbmRleCBmN2MxNjMxLi45OGZmNjJkIDEwMDY0NAotLS0gYS9tbS9tbWFw
LmMKKysrIGIvbW0vbW1hcC5jCkBAIC0zMDQ4LDggKzMwNDgsOCBAQCBzdGF0aWMgaW50IHNwZWNp
YWxfbWFwcGluZ19mYXVsdChzdHJ1Y3Qgdm1fYXJlYV9zdHJ1Y3QgKnZtYSwKIHN0YXRpYyBzdHJ1
Y3Qgdm1fYXJlYV9zdHJ1Y3QgKl9faW5zdGFsbF9zcGVjaWFsX21hcHBpbmcoCiAJc3RydWN0IG1t
X3N0cnVjdCAqbW0sCiAJdW5zaWduZWQgbG9uZyBhZGRyLCB1bnNpZ25lZCBsb25nIGxlbiwKLQl1
bnNpZ25lZCBsb25nIHZtX2ZsYWdzLCBjb25zdCBzdHJ1Y3Qgdm1fb3BlcmF0aW9uc19zdHJ1Y3Qg
Km9wcywKLQl2b2lkICpwcml2KQorCXVuc2lnbmVkIGxvbmcgdm1fZmxhZ3MsIHZvaWQgKnByaXYs
CisJY29uc3Qgc3RydWN0IHZtX29wZXJhdGlvbnNfc3RydWN0ICpvcHMpCiB7CiAJaW50IHJldDsK
IAlzdHJ1Y3Qgdm1fYXJlYV9zdHJ1Y3QgKnZtYTsKQEAgLTMwOTgsOCArMzA5OCw4IEBAIHN0cnVj
dCB2bV9hcmVhX3N0cnVjdCAqX2luc3RhbGxfc3BlY2lhbF9tYXBwaW5nKAogCXVuc2lnbmVkIGxv
bmcgYWRkciwgdW5zaWduZWQgbG9uZyBsZW4sCiAJdW5zaWduZWQgbG9uZyB2bV9mbGFncywgY29u
c3Qgc3RydWN0IHZtX3NwZWNpYWxfbWFwcGluZyAqc3BlYykKIHsKLQlyZXR1cm4gX19pbnN0YWxs
X3NwZWNpYWxfbWFwcGluZyhtbSwgYWRkciwgbGVuLCB2bV9mbGFncywKLQkJCQkJICZzcGVjaWFs
X21hcHBpbmdfdm1vcHMsICh2b2lkICopc3BlYyk7CisJcmV0dXJuIF9faW5zdGFsbF9zcGVjaWFs
X21hcHBpbmcobW0sIGFkZHIsIGxlbiwgdm1fZmxhZ3MsICh2b2lkICopc3BlYywKKwkJCQkJJnNw
ZWNpYWxfbWFwcGluZ192bW9wcyk7CiB9CiAKIGludCBpbnN0YWxsX3NwZWNpYWxfbWFwcGluZyhz
dHJ1Y3QgbW1fc3RydWN0ICptbSwKQEAgLTMxMDcsOCArMzEwNyw4IEBAIGludCBpbnN0YWxsX3Nw
ZWNpYWxfbWFwcGluZyhzdHJ1Y3QgbW1fc3RydWN0ICptbSwKIAkJCSAgICB1bnNpZ25lZCBsb25n
IHZtX2ZsYWdzLCBzdHJ1Y3QgcGFnZSAqKnBhZ2VzKQogewogCXN0cnVjdCB2bV9hcmVhX3N0cnVj
dCAqdm1hID0gX19pbnN0YWxsX3NwZWNpYWxfbWFwcGluZygKLQkJbW0sIGFkZHIsIGxlbiwgdm1f
ZmxhZ3MsICZsZWdhY3lfc3BlY2lhbF9tYXBwaW5nX3Ztb3BzLAotCQkodm9pZCAqKXBhZ2VzKTsK
KwkJbW0sIGFkZHIsIGxlbiwgdm1fZmxhZ3MsICh2b2lkICopcGFnZXMsCisJCSZsZWdhY3lfc3Bl
Y2lhbF9tYXBwaW5nX3Ztb3BzKTsKIAogCXJldHVybiBQVFJfRVJSX09SX1pFUk8odm1hKTsKIH0K
LS0gCjEuOS4zCgo=

--_673bbf67-1069-439f-9647-c28a77af0b0c_--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
