Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f70.google.com (mail-it0-f70.google.com [209.85.214.70])
	by kanga.kvack.org (Postfix) with ESMTP id 4BFE06B0069
	for <linux-mm@kvack.org>; Tue, 27 Dec 2016 14:40:40 -0500 (EST)
Received: by mail-it0-f70.google.com with SMTP id q186so284186058itb.0
        for <linux-mm@kvack.org>; Tue, 27 Dec 2016 11:40:40 -0800 (PST)
Received: from mail-io0-x244.google.com (mail-io0-x244.google.com. [2607:f8b0:4001:c06::244])
        by mx.google.com with ESMTPS id v128si29373791ita.25.2016.12.27.11.40.39
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 27 Dec 2016 11:40:39 -0800 (PST)
Received: by mail-io0-x244.google.com with SMTP id f73so41523382ioe.2
        for <linux-mm@kvack.org>; Tue, 27 Dec 2016 11:40:39 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <CA+55aFzNU53+9PT_xzrPRYdbUYP6V4Y52wCo8V_tANB0tLStnw@mail.gmail.com>
References: <20161225030030.23219-1-npiggin@gmail.com> <20161225030030.23219-3-npiggin@gmail.com>
 <CA+55aFzqgtz-782MmLOjQ2A2nB5YVyLAvveo6G_c85jqqGDA0Q@mail.gmail.com>
 <20161226111654.76ab0957@roar.ozlabs.ibm.com> <CA+55aFz1n_JSTc_u=t9Qgafk2JaffrhPAwMLn_Dr-L9UKxqHMg@mail.gmail.com>
 <20161227211946.3770b6ce@roar.ozlabs.ibm.com> <CA+55aFw22e6njM9L4sareRRJw3RjW9XwGH3B7p-ND86EtTWWDQ@mail.gmail.com>
 <CA+55aFzKuiLS0CvTTqo5=8eyoksC1==30+XMiXZhQqzXr9JM3A@mail.gmail.com> <CA+55aFzNU53+9PT_xzrPRYdbUYP6V4Y52wCo8V_tANB0tLStnw@mail.gmail.com>
From: Linus Torvalds <torvalds@linux-foundation.org>
Date: Tue, 27 Dec 2016 11:40:38 -0800
Message-ID: <CA+55aFyXXKdjbidzVC=waiaAaUJpwqZQZv-kKoZfaiWtYy3z=A@mail.gmail.com>
Subject: Re: [PATCH 2/2] mm: add PageWaiters indicating tasks are waiting for
 a page bit
Content-Type: multipart/mixed; boundary=94eb2c077580e74a760544a90632
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Nicholas Piggin <npiggin@gmail.com>
Cc: Dave Hansen <dave.hansen@linux.intel.com>, Bob Peterson <rpeterso@redhat.com>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Steven Whitehouse <swhiteho@redhat.com>, Andrew Lutomirski <luto@kernel.org>, Andreas Gruenbacher <agruenba@redhat.com>, Peter Zijlstra <peterz@infradead.org>, linux-mm <linux-mm@kvack.org>, Mel Gorman <mgorman@techsingularity.net>

--94eb2c077580e74a760544a90632
Content-Type: text/plain; charset=UTF-8

On Tue, Dec 27, 2016 at 11:24 AM, Linus Torvalds
<torvalds@linux-foundation.org> wrote:
>
> Oops. I should include the actual patch I was talking about too, shouldn't I?

And that patch was completely buggy. The mask for the "and" was computed as

+               : "Ir" (1 << nr) : "memory");

but that clears every bit *except* for the one we actually want to
clear. I even posted the code it generates:

        lock; andb $1,(%rdi)    #, MEM[(volatile long int *)_7]
        js      .L114   #,

which is obviously crap.

The mask needs to be inverted, of course, and the constraint should be
"ir" (not "Ir" - the "I" is for shift constants) so it should be

+               : "ir" ((char) ~(1 << nr)) : "memory");

new patch attached (but still entirely untested, so caveat emptor).

This patch at least might have a chance in hell of working. Let's see..

              Linus

--94eb2c077580e74a760544a90632
Content-Type: text/plain; charset=US-ASCII; name="patch.diff"
Content-Disposition: attachment; filename="patch.diff"
Content-Transfer-Encoding: base64
X-Attachment-Id: f_ix7x3qlx1

IGFyY2gveDg2L2luY2x1ZGUvYXNtL2JpdG9wcy5oIHwgMTMgKysrKysrKysrKysrKwogaW5jbHVk
ZS9saW51eC9wYWdlLWZsYWdzLmggICAgfCAgMiArLQogbW0vZmlsZW1hcC5jICAgICAgICAgICAg
ICAgICAgfCAyNCArKysrKysrKysrKysrKysrKysrKystLS0KIDMgZmlsZXMgY2hhbmdlZCwgMzUg
aW5zZXJ0aW9ucygrKSwgNCBkZWxldGlvbnMoLSkKCmRpZmYgLS1naXQgYS9hcmNoL3g4Ni9pbmNs
dWRlL2FzbS9iaXRvcHMuaCBiL2FyY2gveDg2L2luY2x1ZGUvYXNtL2JpdG9wcy5oCmluZGV4IDY4
NTU3ZjUyYjk2MS4uODU0MDIyNzcyYzViIDEwMDY0NAotLS0gYS9hcmNoL3g4Ni9pbmNsdWRlL2Fz
bS9iaXRvcHMuaAorKysgYi9hcmNoL3g4Ni9pbmNsdWRlL2FzbS9iaXRvcHMuaApAQCAtMTM5LDYg
KzEzOSwxOSBAQCBzdGF0aWMgX19hbHdheXNfaW5saW5lIHZvaWQgX19jbGVhcl9iaXQobG9uZyBu
ciwgdm9sYXRpbGUgdW5zaWduZWQgbG9uZyAqYWRkcikKIAlhc20gdm9sYXRpbGUoImJ0ciAlMSwl
MCIgOiBBRERSIDogIklyIiAobnIpKTsKIH0KIAorc3RhdGljIF9fYWx3YXlzX2lubGluZSBib29s
IGNsZWFyX2JpdF91bmxvY2tfaXNfbmVnYXRpdmVfYnl0ZShsb25nIG5yLCB2b2xhdGlsZSB1bnNp
Z25lZCBsb25nICphZGRyKQoreworCWJvb2wgbmVnYXRpdmU7CisJYXNtIHZvbGF0aWxlKExPQ0tf
UFJFRklYICJhbmRiICUyLCUxXG5cdCIKKwkJQ0NfU0VUKHMpCisJCTogQ0NfT1VUKHMpIChuZWdh
dGl2ZSksIEFERFIKKwkJOiAiaXIiICgoY2hhcikgfigxIDw8IG5yKSkgOiAibWVtb3J5Iik7CisJ
cmV0dXJuIG5lZ2F0aXZlOworfQorCisvLyBMZXQgZXZlcnlib2R5IGtub3cgd2UgaGF2ZSBpdAor
I2RlZmluZSBjbGVhcl9iaXRfdW5sb2NrX2lzX25lZ2F0aXZlX2J5dGUgY2xlYXJfYml0X3VubG9j
a19pc19uZWdhdGl2ZV9ieXRlCisKIC8qCiAgKiBfX2NsZWFyX2JpdF91bmxvY2sgLSBDbGVhcnMg
YSBiaXQgaW4gbWVtb3J5CiAgKiBAbnI6IEJpdCB0byBjbGVhcgpkaWZmIC0tZ2l0IGEvaW5jbHVk
ZS9saW51eC9wYWdlLWZsYWdzLmggYi9pbmNsdWRlL2xpbnV4L3BhZ2UtZmxhZ3MuaAppbmRleCBj
NTZiMzk4OTBhNDEuLjZiNTgxOGQ2ZGUzMiAxMDA2NDQKLS0tIGEvaW5jbHVkZS9saW51eC9wYWdl
LWZsYWdzLmgKKysrIGIvaW5jbHVkZS9saW51eC9wYWdlLWZsYWdzLmgKQEAgLTczLDEzICs3Mywx
MyBAQAogICovCiBlbnVtIHBhZ2VmbGFncyB7CiAJUEdfbG9ja2VkLAkJLyogUGFnZSBpcyBsb2Nr
ZWQuIERvbid0IHRvdWNoLiAqLwotCVBHX3dhaXRlcnMsCQkvKiBQYWdlIGhhcyB3YWl0ZXJzLCBj
aGVjayBpdHMgd2FpdHF1ZXVlICovCiAJUEdfZXJyb3IsCiAJUEdfcmVmZXJlbmNlZCwKIAlQR191
cHRvZGF0ZSwKIAlQR19kaXJ0eSwKIAlQR19scnUsCiAJUEdfYWN0aXZlLAorCVBHX3dhaXRlcnMs
CQkvKiBQYWdlIGhhcyB3YWl0ZXJzLCBjaGVjayBpdHMgd2FpdHF1ZXVlLiBNdXN0IGJlIGJpdCAj
NyBhbmQgaW4gdGhlIHNhbWUgYnl0ZSBhcyAiUEdfbG9ja2VkIiAqLwogCVBHX3NsYWIsCiAJUEdf
b3duZXJfcHJpdl8xLAkvKiBPd25lciB1c2UuIElmIHBhZ2VjYWNoZSwgZnMgbWF5IHVzZSovCiAJ
UEdfYXJjaF8xLApkaWZmIC0tZ2l0IGEvbW0vZmlsZW1hcC5jIGIvbW0vZmlsZW1hcC5jCmluZGV4
IDgyZjI2Y2RlODMwYy4uMDFhMmQ0YTY1NzFjIDEwMDY0NAotLS0gYS9tbS9maWxlbWFwLmMKKysr
IGIvbW0vZmlsZW1hcC5jCkBAIC05MTIsNiArOTEyLDI1IEBAIHZvaWQgYWRkX3BhZ2Vfd2FpdF9x
dWV1ZShzdHJ1Y3QgcGFnZSAqcGFnZSwgd2FpdF9xdWV1ZV90ICp3YWl0ZXIpCiB9CiBFWFBPUlRf
U1lNQk9MX0dQTChhZGRfcGFnZV93YWl0X3F1ZXVlKTsKIAorI2lmbmRlZiBjbGVhcl9iaXRfdW5s
b2NrX2lzX25lZ2F0aXZlX2J5dGUKKworLyoKKyAqIFBHX3dhaXRlcnMgaXMgdGhlIGhpZ2ggYml0
IGluIHRoZSBzYW1lIGJ5dGUgYXMgUEdfbG9jay4KKyAqCisgKiBPbiB4ODYgKGFuZCBvbiBtYW55
IG90aGVyIGFyY2hpdGVjdHVyZXMpLCB3ZSBjYW4gY2xlYXIgUEdfbG9jayBhbmQKKyAqIHRlc3Qg
dGhlIHNpZ24gYml0IGF0IHRoZSBzYW1lIHRpbWUuIEJ1dCBpZiB0aGUgYXJjaGl0ZWN0dXJlIGRv
ZXMKKyAqIG5vdCBzdXBwb3J0IHRoYXQgc3BlY2lhbCBvcGVyYXRpb24sIHdlIGp1c3QgZG8gdGhp
cyBhbGwgYnkgaGFuZAorICogaW5zdGVhZC4KKyAqLworc3RhdGljIGlubGluZSBib29sIGNsZWFy
X2JpdF91bmxvY2tfaXNfbmVnYXRpdmVfYnl0ZShsb25nIG5yLCB2b2xhdGlsZSB2b2lkICptZW0p
Cit7CisJY2xlYXJfYml0X3VubG9jayhQR19sb2NrZWQsIG1lbSk7CisJc21wX21iX19hZnRlcl9h
dG9taWMoKTsKKwlyZXR1cm4gdGVzdF9iaXQoUEdfd2FpdGVycyk7Cit9CisKKyNlbmRpZgorCiAv
KioKICAqIHVubG9ja19wYWdlIC0gdW5sb2NrIGEgbG9ja2VkIHBhZ2UKICAqIEBwYWdlOiB0aGUg
cGFnZQpAQCAtOTI4LDkgKzk0Nyw4IEBAIHZvaWQgdW5sb2NrX3BhZ2Uoc3RydWN0IHBhZ2UgKnBh
Z2UpCiB7CiAJcGFnZSA9IGNvbXBvdW5kX2hlYWQocGFnZSk7CiAJVk1fQlVHX09OX1BBR0UoIVBh
Z2VMb2NrZWQocGFnZSksIHBhZ2UpOwotCWNsZWFyX2JpdF91bmxvY2soUEdfbG9ja2VkLCAmcGFn
ZS0+ZmxhZ3MpOwotCXNtcF9tYl9fYWZ0ZXJfYXRvbWljKCk7Ci0Jd2FrZV91cF9wYWdlKHBhZ2Us
IFBHX2xvY2tlZCk7CisJaWYgKGNsZWFyX2JpdF91bmxvY2tfaXNfbmVnYXRpdmVfYnl0ZShQR19s
b2NrZWQsICZwYWdlLT5mbGFncykpCisJCXdha2VfdXBfcGFnZV9iaXQocGFnZSwgUEdfbG9ja2Vk
KTsKIH0KIEVYUE9SVF9TWU1CT0wodW5sb2NrX3BhZ2UpOwogCg==
--94eb2c077580e74a760544a90632--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
