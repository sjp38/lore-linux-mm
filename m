Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f69.google.com (mail-it0-f69.google.com [209.85.214.69])
	by kanga.kvack.org (Postfix) with ESMTP id 70A536B000C
	for <linux-mm@kvack.org>; Wed,  1 Aug 2018 16:06:01 -0400 (EDT)
Received: by mail-it0-f69.google.com with SMTP id r10-v6so338765itc.2
        for <linux-mm@kvack.org>; Wed, 01 Aug 2018 13:06:01 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id 11-v6sor99197itl.137.2018.08.01.13.06.00
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 01 Aug 2018 13:06:00 -0700 (PDT)
MIME-Version: 1.0
References: <CAMi1Hd0fJuAgP09_KkbjyGwszOXmxcPybKyBxP3U1y5JUqxxSw@mail.gmail.com>
 <20180730130134.yvn5tcmoavuxtwt5@kshutemo-mobl1> <CA+55aFwxwCPZs=h5wy-5PELwfBVuTETm+wuZB5cM2SDoXJi68g@mail.gmail.com>
 <alpine.LSU.2.11.1807301410470.4805@eggly.anvils> <CA+55aFx3qR1FW0T3na25NrwLZAvpOdUEUJa879CnaJT2ZPfhkg@mail.gmail.com>
 <alpine.LSU.2.11.1807301940460.5904@eggly.anvils> <CALAqxLU3cmu4g+HaB6A7=VhY-hW=d9e68EZ=_4JiwX_BigzjPQ@mail.gmail.com>
 <CAMi1Hd0-2eDod4HiBifKCxY0cUUEW_A-yv7sZ7GRgL0whWQt+w@mail.gmail.com>
 <CA+55aFx=-tHXjv3gv4W=xYwM+VOHJQE5q5VyihkPK7s560x-vQ@mail.gmail.com>
 <20180731170328.ocb5oikwhwtkyzrj@kshutemo-mobl1> <20180731174349.GA12944@agluck-desk>
 <CA+55aFxJpJvcYKos-sVTsn9q4wK0-m4up1SXrcqfbXHKxaKxjg@mail.gmail.com>
In-Reply-To: <CA+55aFxJpJvcYKos-sVTsn9q4wK0-m4up1SXrcqfbXHKxaKxjg@mail.gmail.com>
From: Linus Torvalds <torvalds@linux-foundation.org>
Date: Wed, 1 Aug 2018 13:05:48 -0700
Message-ID: <CA+55aFz0eKks=v872LA-tDx4qcmBtxTYXbeztZcWbgx6SeQHNg@mail.gmail.com>
Subject: Re: Linux 4.18-rc7
Content-Type: multipart/mixed; boundary="0000000000002b2e110572653938"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tony Luck <tony.luck@intel.com>
Cc: "Kirill A. Shutemov" <kirill@shutemov.name>, Amit Pundir <amit.pundir@linaro.org>, John Stultz <john.stultz@linaro.org>, Hugh Dickins <hughd@google.com>, Matthew Wilcox <willy@infradead.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Andrew Morton <akpm@linux-foundation.org>, Dmitry Vyukov <dvyukov@google.com>, Oleg Nesterov <oleg@redhat.com>, Andrea Arcangeli <aarcange@redhat.com>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, linux-mm <linux-mm@kvack.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, youling 257 <youling257@gmail.com>, Joel Fernandes <joelaf@google.com>, Colin Cross <ccross@google.com>

--0000000000002b2e110572653938
Content-Type: text/plain; charset="UTF-8"

On Wed, Aug 1, 2018 at 10:15 AM Linus Torvalds
<torvalds@linux-foundation.org> wrote:
>
> I'm still unhappy about the vma_init() ones, and I have not decided
> how to go with those. Either the memset() in vma_init(), or just
> reverting the (imho unnecessary) commit 2c4541e24c55. Kirill, Andrew,
> comments?

Ugh. Adding a memset looks simple, but screws up some places that have
other initialization. It also requires adding a new include of
<linux/string.h>, or we'd need to uninline vma_init() and put it
somewhere else.

But just reverting commit 2c4541e24c55 ("mm: use vma_init() to
initialize VMAs on stack and data segments") entirely isn't good
either, because some of the cases aren't about the TLB flush
interface, and call down to "real" VM functions. The 'pseudo_vma' use
of remove_inode_hugepages() and hugetlbfs_fallocate() in particular is
odd, but using vma_init() looks good there. And those places had the
memset() already.

So I'm inclined to simply mark the TLB-related vma_init() cases
special, and use something like this:

  #define TLB_FLUSH_VMA(mm,flags) { .vm_mm = (mm), .vm_flags = (flags) }

to make it very obvious when we're doing that vma initialization for
flush_tlb_range(). It's done as an initializer, exactly so that the
only valid syntax is to do somethin glike this:

        struct vm_area_struct vma = TLB_FLUSH_VMA(mm, VM_EXEC);

That leaves vma_init() users to be just the actual real allocation
path, and a few very specific specual vmas (the hugetlbfs and
mempolicy pseudo-vma, and a couple of "gate" vmas).

Suggested patch attached. Comments?

                 Linus

--0000000000002b2e110572653938
Content-Type: text/x-patch; charset="US-ASCII"; name="patch.diff"
Content-Disposition: attachment; filename="patch.diff"
Content-Transfer-Encoding: base64
Content-ID: <f_jkbk9vui0>
X-Attachment-Id: f_jkbk9vui0

IGFyY2gvYXJtL21hY2gtcnBjL2VjYXJkLmMgICAgfCAgNSArLS0tLQogYXJjaC9hcm02NC9pbmNs
dWRlL2FzbS90bGIuaCB8ICA0ICstLS0KIGFyY2gvYXJtNjQvbW0vaHVnZXRsYnBhZ2UuYyAgfCAx
MCArKysrLS0tLS0tCiBhcmNoL2lhNjQvaW5jbHVkZS9hc20vdGxiLmggIHwgIDcgKysrLS0tLQog
aW5jbHVkZS9saW51eC9tbS5oICAgICAgICAgICB8ICAzICsrKwogNSBmaWxlcyBjaGFuZ2VkLCAx
MiBpbnNlcnRpb25zKCspLCAxNyBkZWxldGlvbnMoLSkKCmRpZmYgLS1naXQgYS9hcmNoL2FybS9t
YWNoLXJwYy9lY2FyZC5jIGIvYXJjaC9hcm0vbWFjaC1ycGMvZWNhcmQuYwppbmRleCA4ZGI2MmNj
NTRhNmEuLjA0YjJmMjJjMjczOSAxMDA2NDQKLS0tIGEvYXJjaC9hcm0vbWFjaC1ycGMvZWNhcmQu
YworKysgYi9hcmNoL2FybS9tYWNoLXJwYy9lY2FyZC5jCkBAIC0yMTIsNyArMjEyLDcgQEAgc3Rh
dGljIERFRklORV9NVVRFWChlY2FyZF9tdXRleCk7CiAgKi8KIHN0YXRpYyB2b2lkIGVjYXJkX2lu
aXRfcGd0YWJsZXMoc3RydWN0IG1tX3N0cnVjdCAqbW0pCiB7Ci0Jc3RydWN0IHZtX2FyZWFfc3Ry
dWN0IHZtYTsKKwlzdHJ1Y3Qgdm1fYXJlYV9zdHJ1Y3Qgdm1hID0gVExCX0ZMVVNIX1ZNQShtbSwg
Vk1fRVhFQyk7CiAKIAkvKiBXZSB3YW50IHRvIHNldCB1cCB0aGUgcGFnZSB0YWJsZXMgZm9yIHRo
ZSBmb2xsb3dpbmcgbWFwcGluZzoKIAkgKiAgVmlydHVhbAlQaHlzaWNhbApAQCAtMjM3LDkgKzIz
Nyw2IEBAIHN0YXRpYyB2b2lkIGVjYXJkX2luaXRfcGd0YWJsZXMoc3RydWN0IG1tX3N0cnVjdCAq
bW0pCiAKIAltZW1jcHkoZHN0X3BnZCwgc3JjX3BnZCwgc2l6ZW9mKHBnZF90KSAqIChFQVNJX1NJ
WkUgLyBQR0RJUl9TSVpFKSk7CiAKLQl2bWFfaW5pdCgmdm1hLCBtbSk7Ci0Jdm1hLnZtX2ZsYWdz
ID0gVk1fRVhFQzsKLQogCWZsdXNoX3RsYl9yYW5nZSgmdm1hLCBJT19TVEFSVCwgSU9fU1RBUlQg
KyBJT19TSVpFKTsKIAlmbHVzaF90bGJfcmFuZ2UoJnZtYSwgRUFTSV9TVEFSVCwgRUFTSV9TVEFS
VCArIEVBU0lfU0laRSk7CiB9CmRpZmYgLS1naXQgYS9hcmNoL2FybTY0L2luY2x1ZGUvYXNtL3Rs
Yi5oIGIvYXJjaC9hcm02NC9pbmNsdWRlL2FzbS90bGIuaAppbmRleCBkODdmMmQ2NDZjYWEuLjBh
ZDFjZjIzMzQ3MCAxMDA2NDQKLS0tIGEvYXJjaC9hcm02NC9pbmNsdWRlL2FzbS90bGIuaAorKysg
Yi9hcmNoL2FybTY0L2luY2x1ZGUvYXNtL3RsYi5oCkBAIC0zNyw5ICszNyw3IEBAIHN0YXRpYyBp
bmxpbmUgdm9pZCBfX3RsYl9yZW1vdmVfdGFibGUodm9pZCAqX3RhYmxlKQogCiBzdGF0aWMgaW5s
aW5lIHZvaWQgdGxiX2ZsdXNoKHN0cnVjdCBtbXVfZ2F0aGVyICp0bGIpCiB7Ci0Jc3RydWN0IHZt
X2FyZWFfc3RydWN0IHZtYTsKLQotCXZtYV9pbml0KCZ2bWEsIHRsYi0+bW0pOworCXN0cnVjdCB2
bV9hcmVhX3N0cnVjdCB2bWEgPSBUTEJfRkxVU0hfVk1BKHRsYi0+bW0sIDApOwogCiAJLyoKIAkg
KiBUaGUgQVNJRCBhbGxvY2F0b3Igd2lsbCBlaXRoZXIgaW52YWxpZGF0ZSB0aGUgQVNJRCBvciBt
YXJrCmRpZmYgLS1naXQgYS9hcmNoL2FybTY0L21tL2h1Z2V0bGJwYWdlLmMgYi9hcmNoL2FybTY0
L21tL2h1Z2V0bGJwYWdlLmMKaW5kZXggMTg1NGU0OWFhMThhLi4xOTJiM2JhMDcwNzUgMTAwNjQ0
Ci0tLSBhL2FyY2gvYXJtNjQvbW0vaHVnZXRsYnBhZ2UuYworKysgYi9hcmNoL2FybTY0L21tL2h1
Z2V0bGJwYWdlLmMKQEAgLTEwOCwxMyArMTA4LDEwIEBAIHN0YXRpYyBwdGVfdCBnZXRfY2xlYXJf
Zmx1c2goc3RydWN0IG1tX3N0cnVjdCAqbW0sCiAJCQkgICAgIHVuc2lnbmVkIGxvbmcgcGdzaXpl
LAogCQkJICAgICB1bnNpZ25lZCBsb25nIG5jb250aWcpCiB7Ci0Jc3RydWN0IHZtX2FyZWFfc3Ry
dWN0IHZtYTsKIAlwdGVfdCBvcmlnX3B0ZSA9IGh1Z2VfcHRlcF9nZXQocHRlcCk7CiAJYm9vbCB2
YWxpZCA9IHB0ZV92YWxpZChvcmlnX3B0ZSk7CiAJdW5zaWduZWQgbG9uZyBpLCBzYWRkciA9IGFk
ZHI7CiAKLQl2bWFfaW5pdCgmdm1hLCBtbSk7Ci0KIAlmb3IgKGkgPSAwOyBpIDwgbmNvbnRpZzsg
aSsrLCBhZGRyICs9IHBnc2l6ZSwgcHRlcCsrKSB7CiAJCXB0ZV90IHB0ZSA9IHB0ZXBfZ2V0X2Fu
ZF9jbGVhcihtbSwgYWRkciwgcHRlcCk7CiAKQEAgLTEyNyw4ICsxMjQsMTAgQEAgc3RhdGljIHB0
ZV90IGdldF9jbGVhcl9mbHVzaChzdHJ1Y3QgbW1fc3RydWN0ICptbSwKIAkJCW9yaWdfcHRlID0g
cHRlX21rZGlydHkob3JpZ19wdGUpOwogCX0KIAotCWlmICh2YWxpZCkKKwlpZiAodmFsaWQpIHsK
KwkJc3RydWN0IHZtX2FyZWFfc3RydWN0IHZtYSA9IFRMQl9GTFVTSF9WTUEobW0sIDApOwogCQlm
bHVzaF90bGJfcmFuZ2UoJnZtYSwgc2FkZHIsIGFkZHIpOworCX0KIAlyZXR1cm4gb3JpZ19wdGU7
CiB9CiAKQEAgLTE0NywxMCArMTQ2LDkgQEAgc3RhdGljIHZvaWQgY2xlYXJfZmx1c2goc3RydWN0
IG1tX3N0cnVjdCAqbW0sCiAJCQkgICAgIHVuc2lnbmVkIGxvbmcgcGdzaXplLAogCQkJICAgICB1
bnNpZ25lZCBsb25nIG5jb250aWcpCiB7Ci0Jc3RydWN0IHZtX2FyZWFfc3RydWN0IHZtYTsKKwlz
dHJ1Y3Qgdm1fYXJlYV9zdHJ1Y3Qgdm1hID0gVExCX0ZMVVNIX1ZNQShtbSwgMCk7CiAJdW5zaWdu
ZWQgbG9uZyBpLCBzYWRkciA9IGFkZHI7CiAKLQl2bWFfaW5pdCgmdm1hLCBtbSk7CiAJZm9yIChp
ID0gMDsgaSA8IG5jb250aWc7IGkrKywgYWRkciArPSBwZ3NpemUsIHB0ZXArKykKIAkJcHRlX2Ns
ZWFyKG1tLCBhZGRyLCBwdGVwKTsKIApkaWZmIC0tZ2l0IGEvYXJjaC9pYTY0L2luY2x1ZGUvYXNt
L3RsYi5oIGIvYXJjaC9pYTY0L2luY2x1ZGUvYXNtL3RsYi5oCmluZGV4IGRiODllNzMwNjA4MS4u
NTE2MzU1YTc3NGJmIDEwMDY0NAotLS0gYS9hcmNoL2lhNjQvaW5jbHVkZS9hc20vdGxiLmgKKysr
IGIvYXJjaC9pYTY0L2luY2x1ZGUvYXNtL3RsYi5oCkBAIC0xMTUsMTIgKzExNSwxMSBAQCBpYTY0
X3RsYl9mbHVzaF9tbXVfdGxib25seShzdHJ1Y3QgbW11X2dhdGhlciAqdGxiLCB1bnNpZ25lZCBs
b25nIHN0YXJ0LCB1bnNpZ25lZAogCQlmbHVzaF90bGJfYWxsKCk7CiAJfSBlbHNlIHsKIAkJLyoK
LQkJICogWFhYIGZpeCBtZTogZmx1c2hfdGxiX3JhbmdlKCkgc2hvdWxkIHRha2UgYW4gbW0gcG9p
bnRlciBpbnN0ZWFkIG9mIGEKLQkJICogdm1hIHBvaW50ZXIuCisJCSAqIGZsdXNoX3RsYl9yYW5n
ZSgpIHRha2VzIGEgdm1hIGluc3RlYWQgb2YgYSBtbSBwb2ludGVyIGJlY2F1c2UKKwkJICogc29t
ZSBhcmNoaXRlY3R1cmVzIHdhbnQgdGhlIHZtX2ZsYWdzIGZvciBJVExCL0RUTEIgZmx1c2guCiAJ
CSAqLwotCQlzdHJ1Y3Qgdm1fYXJlYV9zdHJ1Y3Qgdm1hOworCQlzdHJ1Y3Qgdm1fYXJlYV9zdHJ1
Y3Qgdm1hID0gVExCX0ZMVVNIX1ZNQSh0bGItPm1tLCAwKTsKIAotCQl2bWFfaW5pdCgmdm1hLCB0
bGItPm1tKTsKIAkJLyogZmx1c2ggdGhlIGFkZHJlc3MgcmFuZ2UgZnJvbSB0aGUgdGxiOiAqLwog
CQlmbHVzaF90bGJfcmFuZ2UoJnZtYSwgc3RhcnQsIGVuZCk7CiAJCS8qIG5vdyBmbHVzaCB0aGUg
dmlydC4gcGFnZS10YWJsZSBhcmVhIG1hcHBpbmcgdGhlIGFkZHJlc3MgcmFuZ2U6ICovCmRpZmYg
LS1naXQgYS9pbmNsdWRlL2xpbnV4L21tLmggYi9pbmNsdWRlL2xpbnV4L21tLmgKaW5kZXggN2Jh
NmQzNTZkMThmLi42OGE1MTIxNjk0ZWYgMTAwNjQ0Ci0tLSBhL2luY2x1ZGUvbGludXgvbW0uaAor
KysgYi9pbmNsdWRlL2xpbnV4L21tLmgKQEAgLTQ2Niw2ICs0NjYsOSBAQCBzdGF0aWMgaW5saW5l
IHZvaWQgdm1hX3NldF9hbm9ueW1vdXMoc3RydWN0IHZtX2FyZWFfc3RydWN0ICp2bWEpCiAJdm1h
LT52bV9vcHMgPSBOVUxMOwogfQogCisvKiBmbHVzaF90bGJfcmFuZ2UoKSB0YWtlcyBhIHZtYSwg
bm90IGEgbW0sIGFuZCBjYW4gY2FyZSBhYm91dCBmbGFncyAqLworI2RlZmluZSBUTEJfRkxVU0hf
Vk1BKG1tLGZsYWdzKSB7IC52bV9tbSA9IChtbSksIC52bV9mbGFncyA9IChmbGFncykgfQorCiBz
dHJ1Y3QgbW11X2dhdGhlcjsKIHN0cnVjdCBpbm9kZTsKIAo=
--0000000000002b2e110572653938--
