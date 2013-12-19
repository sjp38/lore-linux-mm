Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qa0-f53.google.com (mail-qa0-f53.google.com [209.85.216.53])
	by kanga.kvack.org (Postfix) with ESMTP id CE5F56B0036
	for <linux-mm@kvack.org>; Thu, 19 Dec 2013 15:02:21 -0500 (EST)
Received: by mail-qa0-f53.google.com with SMTP id j5so1899676qaq.19
        for <linux-mm@kvack.org>; Thu, 19 Dec 2013 12:02:21 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20131219195352.GB9228@kvack.org>
References: <20131219040738.GA10316@redhat.com>
	<CA+55aFwweoGs3eGWXFULcqnbRbpDhpj2qrefXB5OpQOiWW8wYA@mail.gmail.com>
	<20131219155313.GA25771@redhat.com>
	<CA+55aFyoXCDNfHb+r5b=CgKQLPA1wrU_Tmh4ROZNEt5TPjpODA@mail.gmail.com>
	<20131219181134.GC25385@kmo-pixel>
	<20131219182920.GG30640@kvack.org>
	<CA+55aFzCo_r7ZGHk+zqUjmCW2w7-7z9oxEJjhR66tZ4qZPxnvw@mail.gmail.com>
	<20131219192621.GA9228@kvack.org>
	<CA+55aFz=tEkVAx9VndtCXApDxcw+5T-BxMsVuXp+vMSb05f8Aw@mail.gmail.com>
	<20131219195352.GB9228@kvack.org>
Date: Fri, 20 Dec 2013 05:02:20 +0900
Message-ID: <CA+55aFy5zg_cJueMZFzuqr06rT-hwnHhvBpM6W9657sxnCzxKg@mail.gmail.com>
Subject: Re: bad page state in 3.13-rc4
From: Linus Torvalds <torvalds@linux-foundation.org>
Content-Type: multipart/mixed; boundary=047d7b33da70a0fc8f04ede8a36f
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Benjamin LaHaise <bcrl@kvack.org>
Cc: Kent Overstreet <kmo@daterainc.com>, Dave Jones <davej@redhat.com>, Linux Kernel <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Christoph Lameter <cl@gentwo.org>, Al Viro <viro@zeniv.linux.org.uk>

--047d7b33da70a0fc8f04ede8a36f
Content-Type: text/plain; charset=UTF-8

On Fri, Dec 20, 2013 at 4:53 AM, Benjamin LaHaise <bcrl@kvack.org> wrote:
>
> Yes, that's what I found when I started looking into this in detail again.
> I think the page reference counting is actually correct.  There are 2
> references on each page: the first is from the find_or_create_page() call,
> and the second is from the get_user_pages() (which also makes sure the page
> is populated into the page tables).

Ok, I'm sorry, but that's just pure bullshit then.

So it has the page array in the page cache, then mmap's it in, and
uses get_user_pages() to get the pages back that it *just* created.

This code is pure and utter garbage. It's beyond the pale how crazy it is.

Why not just get rid of the idiotic get_user_pages() crap then?
Something like the attached patch?

Totally untested, but at least it makes *some* amount of sense.

                Linus

--047d7b33da70a0fc8f04ede8a36f
Content-Type: text/plain; charset=US-ASCII; name="patch.diff"
Content-Disposition: attachment; filename="patch.diff"
Content-Transfer-Encoding: base64
X-Attachment-Id: f_hpefqf8j0

IGZzL2Fpby5jIHwgMjAgKysrLS0tLS0tLS0tLS0tLS0tLS0KIDEgZmlsZSBjaGFuZ2VkLCAzIGlu
c2VydGlvbnMoKyksIDE3IGRlbGV0aW9ucygtKQoKZGlmZiAtLWdpdCBhL2ZzL2Fpby5jIGIvZnMv
YWlvLmMKaW5kZXggNmVmYjdmNmNiMjJlLi5lMWIwMmRkMWJlOWUgMTAwNjQ0Ci0tLSBhL2ZzL2Fp
by5jCisrKyBiL2ZzL2Fpby5jCkBAIC0zNTgsNiArMzU4LDggQEAgc3RhdGljIGludCBhaW9fc2V0
dXBfcmluZyhzdHJ1Y3Qga2lvY3R4ICpjdHgpCiAJCVNldFBhZ2VVcHRvZGF0ZShwYWdlKTsKIAkJ
U2V0UGFnZURpcnR5KHBhZ2UpOwogCQl1bmxvY2tfcGFnZShwYWdlKTsKKworCQljdHgtPnJpbmdf
cGFnZXNbaV0gPSBwYWdlOwogCX0KIAljdHgtPmFpb19yaW5nX2ZpbGUgPSBmaWxlOwogCW5yX2V2
ZW50cyA9IChQQUdFX1NJWkUgKiBucl9wYWdlcyAtIHNpemVvZihzdHJ1Y3QgYWlvX3JpbmcpKQpA
QCAtMzgwLDggKzM4Miw4IEBAIHN0YXRpYyBpbnQgYWlvX3NldHVwX3Jpbmcoc3RydWN0IGtpb2N0
eCAqY3R4KQogCWN0eC0+bW1hcF9iYXNlID0gZG9fbW1hcF9wZ29mZihjdHgtPmFpb19yaW5nX2Zp
bGUsIDAsIGN0eC0+bW1hcF9zaXplLAogCQkJCSAgICAgICBQUk9UX1JFQUQgfCBQUk9UX1dSSVRF
LAogCQkJCSAgICAgICBNQVBfU0hBUkVEIHwgTUFQX1BPUFVMQVRFLCAwLCAmcG9wdWxhdGUpOwor
CXVwX3dyaXRlKCZtbS0+bW1hcF9zZW0pOwogCWlmIChJU19FUlIoKHZvaWQgKiljdHgtPm1tYXBf
YmFzZSkpIHsKLQkJdXBfd3JpdGUoJm1tLT5tbWFwX3NlbSk7CiAJCWN0eC0+bW1hcF9zaXplID0g
MDsKIAkJYWlvX2ZyZWVfcmluZyhjdHgpOwogCQlyZXR1cm4gLUVBR0FJTjsKQEAgLTM4OSwyMiAr
MzkxLDYgQEAgc3RhdGljIGludCBhaW9fc2V0dXBfcmluZyhzdHJ1Y3Qga2lvY3R4ICpjdHgpCiAK
IAlwcl9kZWJ1ZygibW1hcCBhZGRyZXNzOiAweCUwOGx4XG4iLCBjdHgtPm1tYXBfYmFzZSk7CiAK
LQkvKiBXZSBtdXN0IGRvIHRoaXMgd2hpbGUgc3RpbGwgaG9sZGluZyBtbWFwX3NlbSBmb3Igd3Jp
dGUsIGFzIHdlCi0JICogbmVlZCB0byBiZSBwcm90ZWN0ZWQgYWdhaW5zdCB1c2Vyc3BhY2UgYXR0
ZW1wdGluZyB0byBtcmVtYXAoKQotCSAqIG9yIG11bm1hcCgpIHRoZSByaW5nIGJ1ZmZlci4KLQkg
Ki8KLQljdHgtPm5yX3BhZ2VzID0gZ2V0X3VzZXJfcGFnZXMoY3VycmVudCwgbW0sIGN0eC0+bW1h
cF9iYXNlLCBucl9wYWdlcywKLQkJCQkgICAgICAgMSwgMCwgY3R4LT5yaW5nX3BhZ2VzLCBOVUxM
KTsKLQotCS8qIERyb3BwaW5nIHRoZSByZWZlcmVuY2UgaGVyZSBpcyBzYWZlIGFzIHRoZSBwYWdl
IGNhY2hlIHdpbGwgaG9sZAotCSAqIG9udG8gdGhlIHBhZ2VzIGZvciB1cy4gIEl0IGlzIGFsc28g
cmVxdWlyZWQgc28gdGhhdCBwYWdlIG1pZ3JhdGlvbgotCSAqIGNhbiB1bm1hcCB0aGUgcGFnZXMg
YW5kIGdldCB0aGUgcmlnaHQgcmVmZXJlbmNlIGNvdW50LgotCSAqLwotCWZvciAoaSA9IDA7IGkg
PCBjdHgtPm5yX3BhZ2VzOyBpKyspCi0JCXB1dF9wYWdlKGN0eC0+cmluZ19wYWdlc1tpXSk7Ci0K
LQl1cF93cml0ZSgmbW0tPm1tYXBfc2VtKTsKLQogCWlmICh1bmxpa2VseShjdHgtPm5yX3BhZ2Vz
ICE9IG5yX3BhZ2VzKSkgewogCQlhaW9fZnJlZV9yaW5nKGN0eCk7CiAJCXJldHVybiAtRUFHQUlO
Owo=
--047d7b33da70a0fc8f04ede8a36f--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
