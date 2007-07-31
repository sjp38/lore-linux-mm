Date: Tue, 31 Jul 2007 08:55:20 +0100 (BST)
From: Mark Fortescue <mark@mtfhpc.demon.co.uk>
Subject: [PATCH] Re: [SPARC32] NULL pointer derefference
In-Reply-To: <20070730.234252.74747206.davem@davemloft.net>
Message-ID: <Pine.LNX.4.61.0707310831080.4116@mtfhpc.demon.co.uk>
References: <Pine.LNX.4.61.0707300301340.32210@mtfhpc.demon.co.uk>
 <20070729.211929.78713482.davem@davemloft.net> <Pine.LNX.4.61.0707310557470.3926@mtfhpc.demon.co.uk>
 <20070730.234252.74747206.davem@davemloft.net>
MIME-Version: 1.0
Content-Type: MULTIPART/MIXED; BOUNDARY="1750305931-1514056767-1185868520=:4116"
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: David Miller <davem@davemloft.net>
Cc: aaw@google.com, akpm@linux-foundation.org, linux-arch@vger.kernel.org, sparclinux@vger.kernel.org, wli@holomorphy.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

--1750305931-1514056767-1185868520=:4116
Content-Type: TEXT/PLAIN; charset=US-ASCII; format=flowed

Hi David,

I have formulated a patch that prevents the update_mmu_cache from doing 
enything if there is no context available. This apears to have no 
immediate, undesirable side effects.

This worked better than the alternative of setting up a context to work with.

Can you for see any issues in doing this?

If not, can you check+apply the attached (un-mangled) patch.

diff -ruNpd linux-2.6/arch/sparc/mm/sun4c.c linux-test/arch/sparc/mm/sun4c.c
--- linux-2.6/arch/sparc/mm/sun4c.c	2007-07-30 03:19:15.000000000 +0100
+++ linux-test/arch/sparc/mm/sun4c.c	2007-07-31 08:28:13.000000000 +0100
@@ -1999,6 +2029,9 @@ void sun4c_update_mmu_cache(struct vm_ar
  	unsigned long flags;
  	int pseg;

+	if (vma->vm_mm->context == NO_CONTEXT)
+		return;
+
  	local_irq_save(flags);
  	address &= PAGE_MASK;
  	if ((pseg = sun4c_get_segmap(address)) == invalid_segment) {

Regards
 	Mark Fortescue.
--1750305931-1514056767-1185868520=:4116
Content-Type: TEXT/PLAIN; charset=US-ASCII; name="mmu-cache-fix.patch"
Content-Transfer-Encoding: BASE64
Content-ID: <Pine.LNX.4.61.0707310855190.4116@mtfhpc.demon.co.uk>
Content-Description: 
Content-Disposition: attachment; filename="mmu-cache-fix.patch"

RnJvbTogTWFyayBGb3J0ZXNjdWUgPG1hcmtAbXRmaHBjLmRlbW9uLmNvLnVr
Pg0KDQpUaGlzIGRlYWxzIHdpdGggYSBzdW40YyBpc3N1ZSBjYXVzZWQgYnkg
Y29tbWl0IGI2YTJmZWEzOTMxOGU0M2ZlZTg0ZmE3YjBiOTBkNjhiZWQ5MmQy
YmE6DQptbTogdmFyaWFibGUgbGVuZ3RoIGFyZ3VtZW50IHN1cHBvcnQuDQpU
aGUgbmV3IHdheSB0aGUgY29kZSB3b3JrcyBtZWFucyB0aGF0IHN1bjRjX3Vw
ZGF0ZV9tbXVfY2FjaGUgZ2V0cyBjYWxsZWQgYmVmb3JlIGEgY29udGV4dA0K
aGFzIGJlZW4gc2VsZWN0ZWQsIHdoaWNoIHJlc3VsdHMgaW4gaW52YWxpZCBv
cGVyYXRpb24gb2YgdGhlIHVuZGVybGluZyBtbSBjb2RlLg0KDQpTaW1wbHkg
aWdub3JpbmcgdXBkYXRlIHJlcXVlc3RzIHdoZW4gdGhlcmUgaXMgbm8gdmFs
aWQgY29udGV4dCBzb2x2ZXMgdGhlIHByb2JsZW0uDQoNClNpZ25lZC1vZmYt
YnkgTWFyayBGb3J0ZXNjdWUgPG1hcmtAbXRmaHBjLmRlbW9uLmNvLnVrPg0K
LS0tDQpUaGlzIHdvcmtlZCBiZXR0ZXIgdGhhbiB0aGUgYWx0ZXJuYXRpdmUg
b2Ygc2V0dGluZyB1cCBhIGNvbnRleHQgdG8gd29yayB3aXRoLg0KSSBkZWZp
bmF0bHkgbmVlZCB0byBzcGVuZCBzb21lIHRpbWUgd3JpdHRpbmcgdXAgdGhl
IHN1bjRjIE1NVSBhbmQgaG93IExpbnV4IGNvZGUgdXNlcyBpdC4NCmRpZmYg
LXJ1TnBkIC14ICcuW2Etel0qJyBsaW51eC0yLjYvYXJjaC9zcGFyYy9tbS9z
dW40Yy5jIGxpbnV4LXRlc3QvYXJjaC9zcGFyYy9tbS9zdW40Yy5jDQotLS0g
bGludXgtMi42L2FyY2gvc3BhcmMvbW0vc3VuNGMuYwkyMDA3LTA3LTMwIDAz
OjE5OjE1LjAwMDAwMDAwMCArMDEwMA0KKysrIGxpbnV4LXRlc3QvYXJjaC9z
cGFyYy9tbS9zdW40Yy5jCTIwMDctMDctMzEgMDg6Mjg6MTMuMDAwMDAwMDAw
ICswMTAwDQpAQCAtMTk5OSw2ICsyMDI5LDkgQEAgdm9pZCBzdW40Y191cGRh
dGVfbW11X2NhY2hlKHN0cnVjdCB2bV9hcg0KIAl1bnNpZ25lZCBsb25nIGZs
YWdzOw0KIAlpbnQgcHNlZzsNCiANCisJaWYgKHZtYS0+dm1fbW0tPmNvbnRl
eHQgPT0gTk9fQ09OVEVYVCkNCisJCXJldHVybjsNCisNCiAJbG9jYWxfaXJx
X3NhdmUoZmxhZ3MpOw0KIAlhZGRyZXNzICY9IFBBR0VfTUFTSzsNCiAJaWYg
KChwc2VnID0gc3VuNGNfZ2V0X3NlZ21hcChhZGRyZXNzKSkgPT0gaW52YWxp
ZF9zZWdtZW50KSB7DQo=

--1750305931-1514056767-1185868520=:4116--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
