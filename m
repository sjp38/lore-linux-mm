Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qa0-f48.google.com (mail-qa0-f48.google.com [209.85.216.48])
	by kanga.kvack.org (Postfix) with ESMTP id ECF066B0036
	for <linux-mm@kvack.org>; Thu, 19 Dec 2013 15:11:14 -0500 (EST)
Received: by mail-qa0-f48.google.com with SMTP id w5so1911649qac.14
        for <linux-mm@kvack.org>; Thu, 19 Dec 2013 12:11:14 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <CA+55aFy5zg_cJueMZFzuqr06rT-hwnHhvBpM6W9657sxnCzxKg@mail.gmail.com>
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
	<CA+55aFy5zg_cJueMZFzuqr06rT-hwnHhvBpM6W9657sxnCzxKg@mail.gmail.com>
Date: Fri, 20 Dec 2013 05:11:12 +0900
Message-ID: <CA+55aFwu_KN+1Ep5RmgFTvBdH3xRJDmCjZ9Fo_pH28hTdiHyiQ@mail.gmail.com>
Subject: Re: bad page state in 3.13-rc4
From: Linus Torvalds <torvalds@linux-foundation.org>
Content-Type: multipart/mixed; boundary=089e0122f65e5f518604ede8c3c4
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Benjamin LaHaise <bcrl@kvack.org>
Cc: Kent Overstreet <kmo@daterainc.com>, Dave Jones <davej@redhat.com>, Linux Kernel <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Christoph Lameter <cl@gentwo.org>, Al Viro <viro@zeniv.linux.org.uk>

--089e0122f65e5f518604ede8c3c4
Content-Type: text/plain; charset=UTF-8

On Fri, Dec 20, 2013 at 5:02 AM, Linus Torvalds
<torvalds@linux-foundation.org> wrote:
>
> Why not just get rid of the idiotic get_user_pages() crap then?
> Something like the attached patch?
>
> Totally untested, but at least it makes *some* amount of sense.

Ok, that can't work, since the ring_pages[] allocation happens later.
So that part needs to be moved up, and it needs to initialize
'nr_pages'.

So here's the same patch, but with stuff moved around a bit, and the
"oops, couldn't create page" part fixed.

Bit it's still totally and entirely untested.

                   Linus

--089e0122f65e5f518604ede8c3c4
Content-Type: text/plain; charset=US-ASCII; name="patch.diff"
Content-Disposition: attachment; filename="patch.diff"
Content-Transfer-Encoding: base64
X-Attachment-Id: f_hpeg2m4w1

IGZzL2Fpby5jIHwgNTQgKysrKysrKysrKysrKysrKysrKysrLS0tLS0tLS0tLS0tLS0tLS0tLS0t
LS0tLS0tLS0tLS0tCiAxIGZpbGUgY2hhbmdlZCwgMjEgaW5zZXJ0aW9ucygrKSwgMzMgZGVsZXRp
b25zKC0pCgpkaWZmIC0tZ2l0IGEvZnMvYWlvLmMgYi9mcy9haW8uYwppbmRleCA2ZWZiN2Y2Y2Iy
MmUuLjNlODU3ZTk4ZmI4NyAxMDA2NDQKLS0tIGEvZnMvYWlvLmMKKysrIGIvZnMvYWlvLmMKQEAg
LTM0Nyw2ICszNDcsMjAgQEAgc3RhdGljIGludCBhaW9fc2V0dXBfcmluZyhzdHJ1Y3Qga2lvY3R4
ICpjdHgpCiAJCXJldHVybiAtRUFHQUlOOwogCX0KIAorCWN0eC0+YWlvX3JpbmdfZmlsZSA9IGZp
bGU7CisJbnJfZXZlbnRzID0gKFBBR0VfU0laRSAqIG5yX3BhZ2VzIC0gc2l6ZW9mKHN0cnVjdCBh
aW9fcmluZykpCisJCQkvIHNpemVvZihzdHJ1Y3QgaW9fZXZlbnQpOworCisJY3R4LT5yaW5nX3Bh
Z2VzID0gY3R4LT5pbnRlcm5hbF9wYWdlczsKKwlpZiAobnJfcGFnZXMgPiBBSU9fUklOR19QQUdF
UykgeworCQljdHgtPnJpbmdfcGFnZXMgPSBrY2FsbG9jKG5yX3BhZ2VzLCBzaXplb2Yoc3RydWN0
IHBhZ2UgKiksCisJCQkJCSAgR0ZQX0tFUk5FTCk7CisJCWlmICghY3R4LT5yaW5nX3BhZ2VzKSB7
CisJCQlwdXRfYWlvX3JpbmdfZmlsZShjdHgpOworCQkJcmV0dXJuIC1FTk9NRU07CisJCX0KKwl9
CisKIAlmb3IgKGkgPSAwOyBpIDwgbnJfcGFnZXM7IGkrKykgewogCQlzdHJ1Y3QgcGFnZSAqcGFn
ZTsKIAkJcGFnZSA9IGZpbmRfb3JfY3JlYXRlX3BhZ2UoZmlsZS0+Zl9pbm9kZS0+aV9tYXBwaW5n
LApAQCAtMzU4LDE5ICszNzIsMTQgQEAgc3RhdGljIGludCBhaW9fc2V0dXBfcmluZyhzdHJ1Y3Qg
a2lvY3R4ICpjdHgpCiAJCVNldFBhZ2VVcHRvZGF0ZShwYWdlKTsKIAkJU2V0UGFnZURpcnR5KHBh
Z2UpOwogCQl1bmxvY2tfcGFnZShwYWdlKTsKKworCQljdHgtPnJpbmdfcGFnZXNbaV0gPSBwYWdl
OwogCX0KLQljdHgtPmFpb19yaW5nX2ZpbGUgPSBmaWxlOwotCW5yX2V2ZW50cyA9IChQQUdFX1NJ
WkUgKiBucl9wYWdlcyAtIHNpemVvZihzdHJ1Y3QgYWlvX3JpbmcpKQotCQkJLyBzaXplb2Yoc3Ry
dWN0IGlvX2V2ZW50KTsKKwljdHgtPm5yX3BhZ2VzID0gaTsKIAotCWN0eC0+cmluZ19wYWdlcyA9
IGN0eC0+aW50ZXJuYWxfcGFnZXM7Ci0JaWYgKG5yX3BhZ2VzID4gQUlPX1JJTkdfUEFHRVMpIHsK
LQkJY3R4LT5yaW5nX3BhZ2VzID0ga2NhbGxvYyhucl9wYWdlcywgc2l6ZW9mKHN0cnVjdCBwYWdl
ICopLAotCQkJCQkgIEdGUF9LRVJORUwpOwotCQlpZiAoIWN0eC0+cmluZ19wYWdlcykgewotCQkJ
cHV0X2Fpb19yaW5nX2ZpbGUoY3R4KTsKLQkJCXJldHVybiAtRU5PTUVNOwotCQl9CisJaWYgKHVu
bGlrZWx5KGkgIT0gbnJfcGFnZXMpKSB7CisJCWFpb19mcmVlX3JpbmcoY3R4KTsKKwkJcmV0dXJu
IC1FQUdBSU47CiAJfQogCiAJY3R4LT5tbWFwX3NpemUgPSBucl9wYWdlcyAqIFBBR0VfU0laRTsK
QEAgLTM4MCw4ICszODksOCBAQCBzdGF0aWMgaW50IGFpb19zZXR1cF9yaW5nKHN0cnVjdCBraW9j
dHggKmN0eCkKIAljdHgtPm1tYXBfYmFzZSA9IGRvX21tYXBfcGdvZmYoY3R4LT5haW9fcmluZ19m
aWxlLCAwLCBjdHgtPm1tYXBfc2l6ZSwKIAkJCQkgICAgICAgUFJPVF9SRUFEIHwgUFJPVF9XUklU
RSwKIAkJCQkgICAgICAgTUFQX1NIQVJFRCB8IE1BUF9QT1BVTEFURSwgMCwgJnBvcHVsYXRlKTsK
Kwl1cF93cml0ZSgmbW0tPm1tYXBfc2VtKTsKIAlpZiAoSVNfRVJSKCh2b2lkICopY3R4LT5tbWFw
X2Jhc2UpKSB7Ci0JCXVwX3dyaXRlKCZtbS0+bW1hcF9zZW0pOwogCQljdHgtPm1tYXBfc2l6ZSA9
IDA7CiAJCWFpb19mcmVlX3JpbmcoY3R4KTsKIAkJcmV0dXJuIC1FQUdBSU47CkBAIC0zODksMjcg
KzM5OCw2IEBAIHN0YXRpYyBpbnQgYWlvX3NldHVwX3Jpbmcoc3RydWN0IGtpb2N0eCAqY3R4KQog
CiAJcHJfZGVidWcoIm1tYXAgYWRkcmVzczogMHglMDhseFxuIiwgY3R4LT5tbWFwX2Jhc2UpOwog
Ci0JLyogV2UgbXVzdCBkbyB0aGlzIHdoaWxlIHN0aWxsIGhvbGRpbmcgbW1hcF9zZW0gZm9yIHdy
aXRlLCBhcyB3ZQotCSAqIG5lZWQgdG8gYmUgcHJvdGVjdGVkIGFnYWluc3QgdXNlcnNwYWNlIGF0
dGVtcHRpbmcgdG8gbXJlbWFwKCkKLQkgKiBvciBtdW5tYXAoKSB0aGUgcmluZyBidWZmZXIuCi0J
ICovCi0JY3R4LT5ucl9wYWdlcyA9IGdldF91c2VyX3BhZ2VzKGN1cnJlbnQsIG1tLCBjdHgtPm1t
YXBfYmFzZSwgbnJfcGFnZXMsCi0JCQkJICAgICAgIDEsIDAsIGN0eC0+cmluZ19wYWdlcywgTlVM
TCk7Ci0KLQkvKiBEcm9wcGluZyB0aGUgcmVmZXJlbmNlIGhlcmUgaXMgc2FmZSBhcyB0aGUgcGFn
ZSBjYWNoZSB3aWxsIGhvbGQKLQkgKiBvbnRvIHRoZSBwYWdlcyBmb3IgdXMuICBJdCBpcyBhbHNv
IHJlcXVpcmVkIHNvIHRoYXQgcGFnZSBtaWdyYXRpb24KLQkgKiBjYW4gdW5tYXAgdGhlIHBhZ2Vz
IGFuZCBnZXQgdGhlIHJpZ2h0IHJlZmVyZW5jZSBjb3VudC4KLQkgKi8KLQlmb3IgKGkgPSAwOyBp
IDwgY3R4LT5ucl9wYWdlczsgaSsrKQotCQlwdXRfcGFnZShjdHgtPnJpbmdfcGFnZXNbaV0pOwot
Ci0JdXBfd3JpdGUoJm1tLT5tbWFwX3NlbSk7Ci0KLQlpZiAodW5saWtlbHkoY3R4LT5ucl9wYWdl
cyAhPSBucl9wYWdlcykpIHsKLQkJYWlvX2ZyZWVfcmluZyhjdHgpOwotCQlyZXR1cm4gLUVBR0FJ
TjsKLQl9Ci0KIAljdHgtPnVzZXJfaWQgPSBjdHgtPm1tYXBfYmFzZTsKIAljdHgtPm5yX2V2ZW50
cyA9IG5yX2V2ZW50czsgLyogdHJ1c3RlZCBjb3B5ICovCiAK
--089e0122f65e5f518604ede8c3c4--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
