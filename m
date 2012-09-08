Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx207.postini.com [74.125.245.207])
	by kanga.kvack.org (Postfix) with SMTP id BF54C6B009A
	for <linux-mm@kvack.org>; Sat,  8 Sep 2012 15:57:53 -0400 (EDT)
Received: by weys10 with SMTP id s10so503179wey.14
        for <linux-mm@kvack.org>; Sat, 08 Sep 2012 12:57:51 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <1347062045.26695.82.camel@sbsiddha-desk.sc.intel.com>
References: <1340959739.2936.28.camel@lappy> <CA+1xoqdgKV_sEWvUbuxagL9JEc39ZFa6X9-acP7j-M7wvW6qbQ@mail.gmail.com>
 <CA+55aFzJCLxVP+WYJM-gq=aXx5gmdgwC7=_Gr2Tooj8q+Dz4dw@mail.gmail.com>
 <1347057778.26695.68.camel@sbsiddha-desk.sc.intel.com> <CA+55aFwW9Q+DM2gZy7r3JQJbrbMNR6sN+jewc2CY0i1wD_X=Tw@mail.gmail.com>
 <1347062045.26695.82.camel@sbsiddha-desk.sc.intel.com>
From: Linus Torvalds <torvalds@linux-foundation.org>
Date: Sat, 8 Sep 2012 12:57:30 -0700
Message-ID: <CA+55aFzeKcV5hROLJE31dNi3SEs+s6o0LL=96Kh8QGHPx=aZnA@mail.gmail.com>
Subject: Re: mtd: kernel BUG at arch/x86/mm/pat.c:279!
Content-Type: multipart/mixed; boundary=20cf301e2d93bde88f04c936239f
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Suresh Siddha <suresh.b.siddha@intel.com>
Cc: Sasha Levin <levinsasha928@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, dwmw2@infradead.org, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, linux-mtd@lists.infradead.org, linux-mm <linux-mm@kvack.org>, Dave Jones <davej@redhat.com>

--20cf301e2d93bde88f04c936239f
Content-Type: text/plain; charset=ISO-8859-1

On Fri, Sep 7, 2012 at 4:54 PM, Suresh Siddha <suresh.b.siddha@intel.com> wrote:
>
> Essentially the user is trying to mmap at a very large offset (from the
> oops it appears "vma->vm_pgoff << PAGE_SHIFT + start" ends up to
> "0xfffffffffffff000").

Ok, Sasha confirmed that.

> So it appears that the condition "(vma->vm_end - vma->vm_start + off) >
> len" might be false because of the wraparound? and doesn't return
> -EINVAL.

Ack.

Anyway, that means that the BUG_ON() is likely bogus, but so is the
whole calling convention.

The 4kB range starting at 0xfffffffffffff000 sounds like a *valid*
range, but that requires that we fix the calling convention to not
have that "end" (exclusive) thing. It should either be "end"
(inclusive), or just "len".

So it should either be start=0xfffffffffffff000 end=0xffffffffffffffff
or it should be start=0xfffffffffffff000 len=0x1000.

Or we need to say that we must never accept things at the end of the
64-bit range.

Whatever. Something like this (TOTALLY UNTESTED) attached patch should
get the mtdchar overflows to go away, but it does *not* fix the fact
that the MTRR start/end model is broken. It really is technically
valid to have a resource_size_t range of 0xfffffffffffff000+0x1000,
and right now it causes a BUG_ON() in pat.c.

Suresh?

                    Linus

--20cf301e2d93bde88f04c936239f
Content-Type: application/octet-stream; name="patch.diff"
Content-Disposition: attachment; filename="patch.diff"
Content-Transfer-Encoding: base64
X-Attachment-Id: f_h6v4xtrj0

IGRyaXZlcnMvbXRkL210ZGNoYXIuYyB8IDQ4ICsrKysrKysrKysrKysrKysrKysrKysrKysrKysr
KysrKysrKysrKysrKy0tLS0tLQogMSBmaWxlIGNoYW5nZWQsIDQyIGluc2VydGlvbnMoKyksIDYg
ZGVsZXRpb25zKC0pCgpkaWZmIC0tZ2l0IGEvZHJpdmVycy9tdGQvbXRkY2hhci5jIGIvZHJpdmVy
cy9tdGQvbXRkY2hhci5jCmluZGV4IGYyZjQ4MmJlYzU3My4uODNkZDY4YjgwZThlIDEwMDY0NAot
LS0gYS9kcml2ZXJzL210ZC9tdGRjaGFyLmMKKysrIGIvZHJpdmVycy9tdGQvbXRkY2hhci5jCkBA
IC0xMTIzLDYgKzExMjMsMzMgQEAgc3RhdGljIHVuc2lnbmVkIGxvbmcgbXRkY2hhcl9nZXRfdW5t
YXBwZWRfYXJlYShzdHJ1Y3QgZmlsZSAqZmlsZSwKIH0KICNlbmRpZgogCitzdGF0aWMgaW5saW5l
IHVuc2lnbmVkIGxvbmcgZ2V0X3ZtX3NpemUoc3RydWN0IHZtX2FyZWFfc3RydWN0ICp2bWEpCit7
CisJcmV0dXJuIHZtYS0+dm1fZW5kIC0gdm1hLT52bV9zdGFydDsKK30KKworc3RhdGljIGlubGlu
ZSByZXNvdXJjZV9zaXplX3QgZ2V0X3ZtX29mZnNldChzdHJ1Y3Qgdm1fYXJlYV9zdHJ1Y3QgKnZt
YSkKK3sKKwlyZXR1cm4gKHJlc291cmNlX3NpemVfdCkgdm1hLT52bV9wZ29mZiA8PCBQQUdFX1NI
SUZUOworfQorCisvKgorICogU2V0IGEgbmV3IHZtIG9mZnNldC4KKyAqCisgKiBWZXJpZnkgdGhh
dCB0aGUgaW5jb21pbmcgb2Zmc2V0IHJlYWxseSB3b3JrcyBhcyBhIHBhZ2Ugb2Zmc2V0LAorICog
YW5kIHRoYXQgdGhlIG9mZnNldCBhbmQgc2l6ZSBmaXQgaW4gYSByZXNvdXJjZV9zaXplX3QuCisg
Ki8KK3N0YXRpYyBpbmxpbnQgaW50IHNldF92bV9vZmZzZXQoc3RydWN0IHZtX2FyZWFfc3RydWN0
ICp2bWEsIHJlc291cmNlX3NpemVfdCBvZmYpCit7CisJcGdvZmZfdCBwZ29mZiA9IG9mZiA+PiBQ
QUdFX1NISUZUOworCWlmIChvZmYgIT0gKHJlc291cmNlX3NpemVfdCkgcGdvZmYgPDwgUEFHRV9T
SElGVCkKKwkJcmV0dXJuIC1FSU5WQUw7CisJaWYgKG9mZiArIGdldF92bV9zaXplKHZtYSkgLSAx
IDwgb2ZmKQorCQlyZXR1cm4gLUVJTlZBTDsKKwl2bWEtPnZtX3Bnb2ZmID0gcGdvZmY7CisJcmV0
dXJuIDA7Cit9CisKIC8qCiAgKiBzZXQgdXAgYSBtYXBwaW5nIGZvciBzaGFyZWQgbWVtb3J5IHNl
Z21lbnRzCiAgKi8KQEAgLTExMzIsMjAgKzExNTksMjkgQEAgc3RhdGljIGludCBtdGRjaGFyX21t
YXAoc3RydWN0IGZpbGUgKmZpbGUsIHN0cnVjdCB2bV9hcmVhX3N0cnVjdCAqdm1hKQogCXN0cnVj
dCBtdGRfZmlsZV9pbmZvICptZmkgPSBmaWxlLT5wcml2YXRlX2RhdGE7CiAJc3RydWN0IG10ZF9p
bmZvICptdGQgPSBtZmktPm10ZDsKIAlzdHJ1Y3QgbWFwX2luZm8gKm1hcCA9IG10ZC0+cHJpdjsK
LQl1bnNpZ25lZCBsb25nIHN0YXJ0OwotCXVuc2lnbmVkIGxvbmcgb2ZmOwotCXUzMiBsZW47CisJ
cmVzb3VyY2Vfc2l6ZV90IHN0YXJ0LCBvZmY7CisJdW5zaWduZWQgbG9uZyBsZW4sIHZtYV9sZW47
CiAKIAlpZiAobXRkLT50eXBlID09IE1URF9SQU0gfHwgbXRkLT50eXBlID09IE1URF9ST00pIHsK
LQkJb2ZmID0gdm1hLT52bV9wZ29mZiA8PCBQQUdFX1NISUZUOworCQlvZmYgPSBnZXRfdm1fb2Zm
c2V0KHZtYSk7CiAJCXN0YXJ0ID0gbWFwLT5waHlzOwogCQlsZW4gPSBQQUdFX0FMSUdOKChzdGFy
dCAmIH5QQUdFX01BU0spICsgbWFwLT5zaXplKTsKIAkJc3RhcnQgJj0gUEFHRV9NQVNLOwotCQlp
ZiAoKHZtYS0+dm1fZW5kIC0gdm1hLT52bV9zdGFydCArIG9mZikgPiBsZW4pCisJCXZtYV9sZW4g
PSBnZXRfdm1fc2l6ZSh2bWEpOworCisJCS8qIE92ZXJmbG93IGluIG9mZitsZW4/ICovCisJCWlm
ICh2bWFfbGVuICsgb2ZmIDwgb2ZmKQorCQkJcmV0dXJuIC1FSU5WQUw7CisJCS8qIERvZXMgaXQg
Zml0IGluIHRoZSBtYXBwaW5nPyAqLworCQlpZiAodm1hX2xlbiArIG9mZiA+IGxlbikKIAkJCXJl
dHVybiAtRUlOVkFMOwogCiAJCW9mZiArPSBzdGFydDsKLQkJdm1hLT52bV9wZ29mZiA9IG9mZiA+
PiBQQUdFX1NISUZUOworCQkvKiBEaWQgdGhhdCBvdmVyZmxvdz8gKi8KKwkJaWYgKG9mZiA8IHN0
YXJ0KQorCQkJcmV0dXJuIC1FSU5WQUw7CisJCWlmIChzZXRfdm1fb2Zmc2V0KHZtYSwgb2ZmKSA8
IDApCisJCQlyZXR1cm4gLUVJTlZBTDsKIAkJdm1hLT52bV9mbGFncyB8PSBWTV9JTyB8IFZNX1JF
U0VSVkVEOwogCiAjaWZkZWYgcGdwcm90X25vbmNhY2hlZAo=
--20cf301e2d93bde88f04c936239f--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
