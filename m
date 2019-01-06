Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf1-f70.google.com (mail-lf1-f70.google.com [209.85.167.70])
	by kanga.kvack.org (Postfix) with ESMTP id 766478E00F9
	for <linux-mm@kvack.org>; Sat,  5 Jan 2019 20:51:20 -0500 (EST)
Received: by mail-lf1-f70.google.com with SMTP id y24so3825802lfh.4
        for <linux-mm@kvack.org>; Sat, 05 Jan 2019 17:51:20 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id a12-v6sor34922828lji.34.2019.01.05.17.51.18
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Sat, 05 Jan 2019 17:51:18 -0800 (PST)
Received: from mail-lf1-f53.google.com (mail-lf1-f53.google.com. [209.85.167.53])
        by smtp.gmail.com with ESMTPSA id f8sm13250941lfe.72.2019.01.05.17.51.16
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 05 Jan 2019 17:51:16 -0800 (PST)
Received: by mail-lf1-f53.google.com with SMTP id c16so27835259lfj.8
        for <linux-mm@kvack.org>; Sat, 05 Jan 2019 17:51:16 -0800 (PST)
MIME-Version: 1.0
References: <nycvar.YFH.7.76.1901051817390.16954@cbobk.fhfr.pm>
 <CAG48ez2jAp9xkPXQmVXm0PqNrFGscg9BufQRem2UD8FGX-YzPw@mail.gmail.com>
 <CAHk-=whL4sZiM=JcdQAYQvHm7h7xEtVUh+gYGYhoSk4vi38tXg@mail.gmail.com>
 <CAHk-=wg5Kk+r36=jcGBaLUj+gjopjgiW5eyvkdMqvn0jFkD_iQ@mail.gmail.com>
 <CAHk-=wiMQeCEKESWTmm15x79NjEjNwFvjZ=9XenxY7yH8zqa7A@mail.gmail.com>
 <20190106001138.GW6310@bombadil.infradead.org> <CAHk-=wiT=ov+6zYcnw_64ihYf74Amzqs67iVGtJMQq65PxiVYw@mail.gmail.com>
In-Reply-To: <CAHk-=wiT=ov+6zYcnw_64ihYf74Amzqs67iVGtJMQq65PxiVYw@mail.gmail.com>
From: Linus Torvalds <torvalds@linux-foundation.org>
Date: Sat, 5 Jan 2019 17:50:59 -0800
Message-ID: <CAHk-=wg1A44Roa8C4dmfdXLRLmNysEW36=3R7f+tzZzbcJ2d2g@mail.gmail.com>
Subject: Re: [PATCH] mm/mincore: allow for making sys_mincore() privileged
Content-Type: multipart/mixed; boundary="000000000000ff4c37057ec05817"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Matthew Wilcox <willy@infradead.org>
Cc: Jann Horn <jannh@google.com>, Jiri Kosina <jikos@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Greg KH <gregkh@linuxfoundation.org>, Peter Zijlstra <peterz@infradead.org>, Michal Hocko <mhocko@suse.com>, Linux-MM <linux-mm@kvack.org>, kernel list <linux-kernel@vger.kernel.org>, Linux API <linux-api@vger.kernel.org>

--000000000000ff4c37057ec05817
Content-Type: text/plain; charset="UTF-8"

On Sat, Jan 5, 2019 at 4:22 PM Linus Torvalds
<torvalds@linux-foundation.org> wrote:
>
> But I think my patch to just rip out all that page lookup, and just
> base it on the page table state has the fundamental advantage that it
> gets rid of code. Maybe I should jst commit it, and see if anything
> breaks? We do have options in case things break, and then we'd at
> least know who cares (and perhaps a lot more information of _why_ they
> care).

Slightly updated patch in case somebody wants to try things out.

Also, any comments about the pmd_trans_unstable() case?

                    Linus

--000000000000ff4c37057ec05817
Content-Type: text/x-patch; charset="US-ASCII"; name="patch.diff"
Content-Disposition: attachment; filename="patch.diff"
Content-Transfer-Encoding: base64
Content-ID: <f_jqk8qbng0>
X-Attachment-Id: f_jqk8qbng0

IG1tL21pbmNvcmUuYyB8IDk0ICsrKysrKysrKy0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0t
LS0tLS0tLS0tLS0tLS0tLS0tLS0tLQogMSBmaWxlIGNoYW5nZWQsIDEzIGluc2VydGlvbnMoKyks
IDgxIGRlbGV0aW9ucygtKQoKZGlmZiAtLWdpdCBhL21tL21pbmNvcmUuYyBiL21tL21pbmNvcmUu
YwppbmRleCAyMTgwOTliNWVkMzEuLmYwZjkxNDYxYTlmNCAxMDA2NDQKLS0tIGEvbW0vbWluY29y
ZS5jCisrKyBiL21tL21pbmNvcmUuYwpAQCAtNDIsNzIgKzQyLDE0IEBAIHN0YXRpYyBpbnQgbWlu
Y29yZV9odWdldGxiKHB0ZV90ICpwdGUsIHVuc2lnbmVkIGxvbmcgaG1hc2ssIHVuc2lnbmVkIGxv
bmcgYWRkciwKIAlyZXR1cm4gMDsKIH0KIAotLyoKLSAqIExhdGVyIHdlIGNhbiBnZXQgbW9yZSBw
aWNreSBhYm91dCB3aGF0ICJpbiBjb3JlIiBtZWFucyBwcmVjaXNlbHkuCi0gKiBGb3Igbm93LCBz
aW1wbHkgY2hlY2sgdG8gc2VlIGlmIHRoZSBwYWdlIGlzIGluIHRoZSBwYWdlIGNhY2hlLAotICog
YW5kIGlzIHVwIHRvIGRhdGU7IGkuZS4gdGhhdCBubyBwYWdlLWluIG9wZXJhdGlvbiB3b3VsZCBi
ZSByZXF1aXJlZAotICogYXQgdGhpcyB0aW1lIGlmIGFuIGFwcGxpY2F0aW9uIHdlcmUgdG8gbWFw
IGFuZCBhY2Nlc3MgdGhpcyBwYWdlLgotICovCi1zdGF0aWMgdW5zaWduZWQgY2hhciBtaW5jb3Jl
X3BhZ2Uoc3RydWN0IGFkZHJlc3Nfc3BhY2UgKm1hcHBpbmcsIHBnb2ZmX3QgcGdvZmYpCi17Ci0J
dW5zaWduZWQgY2hhciBwcmVzZW50ID0gMDsKLQlzdHJ1Y3QgcGFnZSAqcGFnZTsKLQotCS8qCi0J
ICogV2hlbiB0bXBmcyBzd2FwcyBvdXQgYSBwYWdlIGZyb20gYSBmaWxlLCBhbnkgcHJvY2VzcyBt
YXBwaW5nIHRoYXQKLQkgKiBmaWxlIHdpbGwgbm90IGdldCBhIHN3cF9lbnRyeV90IGluIGl0cyBw
dGUsIGJ1dCByYXRoZXIgaXQgaXMgbGlrZQotCSAqIGFueSBvdGhlciBmaWxlIG1hcHBpbmcgKGll
LiBtYXJrZWQgIXByZXNlbnQgYW5kIGZhdWx0ZWQgaW4gd2l0aAotCSAqIHRtcGZzJ3MgLmZhdWx0
KS4gU28gc3dhcHBlZCBvdXQgdG1wZnMgbWFwcGluZ3MgYXJlIHRlc3RlZCBoZXJlLgotCSAqLwot
I2lmZGVmIENPTkZJR19TV0FQCi0JaWYgKHNobWVtX21hcHBpbmcobWFwcGluZykpIHsKLQkJcGFn
ZSA9IGZpbmRfZ2V0X2VudHJ5KG1hcHBpbmcsIHBnb2ZmKTsKLQkJLyoKLQkJICogc2htZW0vdG1w
ZnMgbWF5IHJldHVybiBzd2FwOiBhY2NvdW50IGZvciBzd2FwY2FjaGUKLQkJICogcGFnZSB0b28u
Ci0JCSAqLwotCQlpZiAoeGFfaXNfdmFsdWUocGFnZSkpIHsKLQkJCXN3cF9lbnRyeV90IHN3cCA9
IHJhZGl4X3RvX3N3cF9lbnRyeShwYWdlKTsKLQkJCXBhZ2UgPSBmaW5kX2dldF9wYWdlKHN3YXBf
YWRkcmVzc19zcGFjZShzd3ApLAotCQkJCQkgICAgIHN3cF9vZmZzZXQoc3dwKSk7Ci0JCX0KLQl9
IGVsc2UKLQkJcGFnZSA9IGZpbmRfZ2V0X3BhZ2UobWFwcGluZywgcGdvZmYpOwotI2Vsc2UKLQlw
YWdlID0gZmluZF9nZXRfcGFnZShtYXBwaW5nLCBwZ29mZik7Ci0jZW5kaWYKLQlpZiAocGFnZSkg
ewotCQlwcmVzZW50ID0gUGFnZVVwdG9kYXRlKHBhZ2UpOwotCQlwdXRfcGFnZShwYWdlKTsKLQl9
Ci0KLQlyZXR1cm4gcHJlc2VudDsKLX0KLQotc3RhdGljIGludCBfX21pbmNvcmVfdW5tYXBwZWRf
cmFuZ2UodW5zaWduZWQgbG9uZyBhZGRyLCB1bnNpZ25lZCBsb25nIGVuZCwKLQkJCQlzdHJ1Y3Qg
dm1fYXJlYV9zdHJ1Y3QgKnZtYSwgdW5zaWduZWQgY2hhciAqdmVjKQotewotCXVuc2lnbmVkIGxv
bmcgbnIgPSAoZW5kIC0gYWRkcikgPj4gUEFHRV9TSElGVDsKLQlpbnQgaTsKLQotCWlmICh2bWEt
PnZtX2ZpbGUpIHsKLQkJcGdvZmZfdCBwZ29mZjsKLQotCQlwZ29mZiA9IGxpbmVhcl9wYWdlX2lu
ZGV4KHZtYSwgYWRkcik7Ci0JCWZvciAoaSA9IDA7IGkgPCBucjsgaSsrLCBwZ29mZisrKQotCQkJ
dmVjW2ldID0gbWluY29yZV9wYWdlKHZtYS0+dm1fZmlsZS0+Zl9tYXBwaW5nLCBwZ29mZik7Ci0J
fSBlbHNlIHsKLQkJZm9yIChpID0gMDsgaSA8IG5yOyBpKyspCi0JCQl2ZWNbaV0gPSAwOwotCX0K
LQlyZXR1cm4gbnI7Ci19Ci0KIHN0YXRpYyBpbnQgbWluY29yZV91bm1hcHBlZF9yYW5nZSh1bnNp
Z25lZCBsb25nIGFkZHIsIHVuc2lnbmVkIGxvbmcgZW5kLAogCQkJCSAgIHN0cnVjdCBtbV93YWxr
ICp3YWxrKQogewotCXdhbGstPnByaXZhdGUgKz0gX19taW5jb3JlX3VubWFwcGVkX3JhbmdlKGFk
ZHIsIGVuZCwKLQkJCQkJCSAgd2Fsay0+dm1hLCB3YWxrLT5wcml2YXRlKTsKKwl1bnNpZ25lZCBj
aGFyICp2ZWMgPSB3YWxrLT5wcml2YXRlOworCXVuc2lnbmVkIGxvbmcgbnIgPSAoZW5kIC0gYWRk
cikgPj4gUEFHRV9TSElGVDsKKworCW1lbXNldCh2ZWMsIDAsIG5yKTsKKwl3YWxrLT5wcml2YXRl
ICs9IG5yOwogCXJldHVybiAwOwogfQogCkBAIC0xMjcsOCArNjksOSBAQCBzdGF0aWMgaW50IG1p
bmNvcmVfcHRlX3JhbmdlKHBtZF90ICpwbWQsIHVuc2lnbmVkIGxvbmcgYWRkciwgdW5zaWduZWQg
bG9uZyBlbmQsCiAJCWdvdG8gb3V0OwogCX0KIAorCS8qIFdlJ2xsIGNvbnNpZGVyIGEgVEhQIHBh
Z2UgdW5kZXIgY29uc3RydWN0aW9uIHRvIGJlIHRoZXJlICovCiAJaWYgKHBtZF90cmFuc191bnN0
YWJsZShwbWQpKSB7Ci0JCV9fbWluY29yZV91bm1hcHBlZF9yYW5nZShhZGRyLCBlbmQsIHZtYSwg
dmVjKTsKKwkJbWVtc2V0KHZlYywgMSwgbnIpOwogCQlnb3RvIG91dDsKIAl9CiAKQEAgLTEzNywy
OCArODAsMTcgQEAgc3RhdGljIGludCBtaW5jb3JlX3B0ZV9yYW5nZShwbWRfdCAqcG1kLCB1bnNp
Z25lZCBsb25nIGFkZHIsIHVuc2lnbmVkIGxvbmcgZW5kLAogCQlwdGVfdCBwdGUgPSAqcHRlcDsK
IAogCQlpZiAocHRlX25vbmUocHRlKSkKLQkJCV9fbWluY29yZV91bm1hcHBlZF9yYW5nZShhZGRy
LCBhZGRyICsgUEFHRV9TSVpFLAotCQkJCQkJIHZtYSwgdmVjKTsKKwkJCSp2ZWMgPSAwOwogCQll
bHNlIGlmIChwdGVfcHJlc2VudChwdGUpKQogCQkJKnZlYyA9IDE7CiAJCWVsc2UgeyAvKiBwdGUg
aXMgYSBzd2FwIGVudHJ5ICovCiAJCQlzd3BfZW50cnlfdCBlbnRyeSA9IHB0ZV90b19zd3BfZW50
cnkocHRlKTsKIAotCQkJaWYgKG5vbl9zd2FwX2VudHJ5KGVudHJ5KSkgewotCQkJCS8qCi0JCQkJ
ICogbWlncmF0aW9uIG9yIGh3cG9pc29uIGVudHJpZXMgYXJlIGFsd2F5cwotCQkJCSAqIHVwdG9k
YXRlCi0JCQkJICovCi0JCQkJKnZlYyA9IDE7Ci0JCQl9IGVsc2UgewotI2lmZGVmIENPTkZJR19T
V0FQCi0JCQkJKnZlYyA9IG1pbmNvcmVfcGFnZShzd2FwX2FkZHJlc3Nfc3BhY2UoZW50cnkpLAot
CQkJCQkJICAgIHN3cF9vZmZzZXQoZW50cnkpKTsKLSNlbHNlCi0JCQkJV0FSTl9PTigxKTsKLQkJ
CQkqdmVjID0gMTsKLSNlbmRpZgotCQkJfQorCQkJLyoKKwkJCSAqIG1pZ3JhdGlvbiBvciBod3Bv
aXNvbiBlbnRyaWVzIGFyZSBhbHdheXMKKwkJCSAqIHVwdG9kYXRlCisJCQkgKi8KKwkJCSp2ZWMg
PSAhIW5vbl9zd2FwX2VudHJ5KGVudHJ5KTsKIAkJfQogCQl2ZWMrKzsKIAl9Cg==
--000000000000ff4c37057ec05817--
