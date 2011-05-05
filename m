Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with ESMTP id 2DA556B0011
	for <linux-mm@kvack.org>; Wed,  4 May 2011 20:39:41 -0400 (EDT)
Received: from mail-ew0-f41.google.com (mail-ew0-f41.google.com [209.85.215.41])
	(authenticated bits=0)
	by smtp1.linux-foundation.org (8.14.2/8.13.5/Debian-3ubuntu1.1) with ESMTP id p450d1kH016095
	(version=TLSv1/SSLv3 cipher=RC4-SHA bits=128 verify=FAIL)
	for <linux-mm@kvack.org>; Wed, 4 May 2011 17:39:02 -0700
Received: by ewy9 with SMTP id 9so723872ewy.14
        for <linux-mm@kvack.org>; Wed, 04 May 2011 17:39:00 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <BANLkTi=D+oe_zyxA1Oj5S36F6Tk0J+26iQ@mail.gmail.com>
References: <alpine.LSU.2.00.1102232136020.2239@sister.anvils>
 <AANLkTi==MQV=_qq1HaCxGLRu8DdT6FYddqzBkzp1TQs7@mail.gmail.com>
 <AANLkTimv66fV1+JDqSAxRwddvy_kggCuhoJLMTpMTtJM@mail.gmail.com>
 <alpine.LSU.2.00.1103182158200.18771@sister.anvils> <BANLkTinoNMudwkcOOgU5d+imPUfZhDbWWQ@mail.gmail.com>
 <AANLkTimfArmB7judMW7Qd4ATtVaR=yTf_-0DBRAfCJ7w@mail.gmail.com>
 <BANLkTi=Limr3NUaG7RLoQLv5TuEDmm7Rqg@mail.gmail.com> <BANLkTi=UZcocVk_16MbbV432g9a3nDFauA@mail.gmail.com>
 <BANLkTi=KTdLRC_hRvxfpFoMSbz=vOjpObw@mail.gmail.com> <BANLkTindeX9-ECPjgd_V62ZbXCd7iEG9_w@mail.gmail.com>
 <BANLkTikcZK+AQvwe2ED=b0dLZ0hqg0B95w@mail.gmail.com> <BANLkTimV1f1YDTWZUU9uvAtCO_fp6EKH9Q@mail.gmail.com>
 <BANLkTi=tavhpytcSV+nKaXJzw19Bo3W9XQ@mail.gmail.com> <alpine.LSU.2.00.1104060837590.4909@sister.anvils>
 <BANLkTi=-Zb+vrQuY6J+dAMsmz+cQDD-KUw@mail.gmail.com> <BANLkTim0MZfa8vFgHB3W6NsoPHp2jfirrA@mail.gmail.com>
 <BANLkTim-hyXpLj537asC__8exMo3o-WCLA@mail.gmail.com> <alpine.LSU.2.00.1104070718120.28555@sister.anvils>
 <BANLkTik_9YW5+64FHrzNy7kPz1FUWrw-rw@mail.gmail.com> <BANLkTiniyAN40p0q+2wxWsRZ5PJFn9zE0Q@mail.gmail.com>
 <BANLkTik6U21r91DYiUsz9A0P--=5QcsBrA@mail.gmail.com> <BANLkTim6ATGxTiMcfK5-03azgcWuT4wtJA@mail.gmail.com>
 <BANLkTiktvcBWsLKEk5iBYVEbPJS3i+U+hA@mail.gmail.com> <BANLkTikdM2kF=qOy4d4bZ_wfb5ykEdkZPQ@mail.gmail.com>
 <BANLkTikZ1szdH5HZdjKEEzG2+1VPusWEeg@mail.gmail.com> <BANLkTingV3eiHEco+36YyM4YTDHFHc9_jA@mail.gmail.com>
 <BANLkTi=D+oe_zyxA1Oj5S36F6Tk0J+26iQ@mail.gmail.com>
From: Linus Torvalds <torvalds@linux-foundation.org>
Date: Wed, 4 May 2011 17:38:40 -0700
Message-ID: <BANLkTim_QtaQLa9GV5hMZyCmW_WAz_Ucvg@mail.gmail.com>
Subject: Re: [PATCH] mm: fix possible cause of a page_mapped BUG
Content-Type: multipart/mixed; boundary=0016e65b54cc6a992604a27c99d1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michel Lespinasse <walken@google.com>
Cc: =?UTF-8?B?Um9iZXJ0IMWad2nEmWNraQ==?= <robert@swiecki.net>, Hugh Dickins <hughd@google.com>, Andrew Morton <akpm@linux-foundation.org>, Miklos Szeredi <miklos@szeredi.hu>, "Eric W. Biederman" <ebiederm@xmission.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Peter Zijlstra <a.p.zijlstra@chello.nl>, Rik van Riel <riel@redhat.com>

--0016e65b54cc6a992604a27c99d1
Content-Type: text/plain; charset=ISO-8859-1

On Wed, May 4, 2011 at 5:09 PM, Michel Lespinasse <walken@google.com> wrote:
>
> FYI, the attached code causes an infinite loop in kernels that have
> the 95042f9eb7 commit:

Mmm.

Yes. The atomic fault will never work, and the get_user_pages() thing
won't either, so things will just loop forever.

> Linus, I am not sure as to what would be the preferred way to fix
> this. One option could be to modify fault_in_user_writeable so that it
> passes a non-NULL page pointer, and just does a put_page on it
> afterwards. While this would work, this is kinda ugly and would slow
> down futex operations somewhat.

No, that's just ugly as hell.

> A more conservative alternative could
> be to enable the guard page special case under an new GUP flag, but
> this loses much of the elegance of your original proposal...

How about only doing that only for FOLL_MLOCK?

Also, looking at mm/mlock.c, why _do_ we call get_user_pages() even if
the vma isn't mlocked? That looks bogus. Since we have dropped the
mm_semaphore, an unlock may have happened, and afaik we should *not*
try to bring those pages back in at all. There's this whole comment
about that in the caller ("__mlock_vma_pages_range() double checks the
vma flags, so that it won't mlock pages if the vma was already
munlocked."), but despite that it would actually call
__get_user_pages() even if the VM_LOCKED bit had been cleared (it just
wouldn't call it with the FOLL_MLOCK flag).

So maybe something like the attached?

UNTESTED! And maybe there was some really subtle reason to still call
__get_user_pages() without that FOLL_MLOCK thing that I'm missing.

                           Linus

--0016e65b54cc6a992604a27c99d1
Content-Type: text/x-patch; charset=US-ASCII; name="patch.diff"
Content-Disposition: attachment; filename="patch.diff"
Content-Transfer-Encoding: base64
X-Attachment-Id: f_gnayw6oc0

IG1tL21lbW9yeS5jIHwgICAgMiArLQogbW0vbWxvY2suYyAgfCAgICA4ICsrKystLS0tCiAyIGZp
bGVzIGNoYW5nZWQsIDUgaW5zZXJ0aW9ucygrKSwgNSBkZWxldGlvbnMoLSkKCmRpZmYgLS1naXQg
YS9tbS9tZW1vcnkuYyBiL21tL21lbW9yeS5jCmluZGV4IDYwNzA5OGQ0N2U3NC4uZjdhNDg3Yzkw
OGE1IDEwMDY0NAotLS0gYS9tbS9tZW1vcnkuYworKysgYi9tbS9tZW1vcnkuYwpAQCAtMTU1NSw3
ICsxNTU1LDcgQEAgaW50IF9fZ2V0X3VzZXJfcGFnZXMoc3RydWN0IHRhc2tfc3RydWN0ICp0c2ss
IHN0cnVjdCBtbV9zdHJ1Y3QgKm1tLAogCQkgKiBJZiB3ZSBkb24ndCBhY3R1YWxseSB3YW50IHRo
ZSBwYWdlIGl0c2VsZiwKIAkJICogYW5kIGl0J3MgdGhlIHN0YWNrIGd1YXJkIHBhZ2UsIGp1c3Qg
c2tpcCBpdC4KIAkJICovCi0JCWlmICghcGFnZXMgJiYgc3RhY2tfZ3VhcmRfcGFnZSh2bWEsIHN0
YXJ0KSkKKwkJaWYgKCFwYWdlcyAmJiAoZ3VwX2ZsYWdzICYgRk9MTF9NTE9DSykgJiYgc3RhY2tf
Z3VhcmRfcGFnZSh2bWEsIHN0YXJ0KSkKIAkJCWdvdG8gbmV4dF9wYWdlOwogCiAJCWRvIHsKZGlm
ZiAtLWdpdCBhL21tL21sb2NrLmMgYi9tbS9tbG9jay5jCmluZGV4IDZiNTVlM2VmZTBkZi4uOGVk
N2ZkMDlmODFjIDEwMDY0NAotLS0gYS9tbS9tbG9jay5jCisrKyBiL21tL21sb2NrLmMKQEAgLTE2
Miw3ICsxNjIsMTAgQEAgc3RhdGljIGxvbmcgX19tbG9ja192bWFfcGFnZXNfcmFuZ2Uoc3RydWN0
IHZtX2FyZWFfc3RydWN0ICp2bWEsCiAJVk1fQlVHX09OKGVuZCAgID4gdm1hLT52bV9lbmQpOwog
CVZNX0JVR19PTighcndzZW1faXNfbG9ja2VkKCZtbS0+bW1hcF9zZW0pKTsKIAotCWd1cF9mbGFn
cyA9IEZPTExfVE9VQ0g7CisJaWYgKCEodm1hLT52bV9mbGFncyAmIFZNX0xPQ0tFRCkpCisJCXJl
dHVybiBucl9wYWdlczsKKworCWd1cF9mbGFncyA9IEZPTExfVE9VQ0ggfCBGT0xMX01MT0NLOwog
CS8qCiAJICogV2Ugd2FudCB0byB0b3VjaCB3cml0YWJsZSBtYXBwaW5ncyB3aXRoIGEgd3JpdGUg
ZmF1bHQgaW4gb3JkZXIKIAkgKiB0byBicmVhayBDT1csIGV4Y2VwdCBmb3Igc2hhcmVkIG1hcHBp
bmdzIGJlY2F1c2UgdGhlc2UgZG9uJ3QgQ09XCkBAIC0xNzgsOSArMTgxLDYgQEAgc3RhdGljIGxv
bmcgX19tbG9ja192bWFfcGFnZXNfcmFuZ2Uoc3RydWN0IHZtX2FyZWFfc3RydWN0ICp2bWEsCiAJ
aWYgKHZtYS0+dm1fZmxhZ3MgJiAoVk1fUkVBRCB8IFZNX1dSSVRFIHwgVk1fRVhFQykpCiAJCWd1
cF9mbGFncyB8PSBGT0xMX0ZPUkNFOwogCi0JaWYgKHZtYS0+dm1fZmxhZ3MgJiBWTV9MT0NLRUQp
Ci0JCWd1cF9mbGFncyB8PSBGT0xMX01MT0NLOwotCiAJcmV0dXJuIF9fZ2V0X3VzZXJfcGFnZXMo
Y3VycmVudCwgbW0sIGFkZHIsIG5yX3BhZ2VzLCBndXBfZmxhZ3MsCiAJCQkJTlVMTCwgTlVMTCwg
bm9uYmxvY2tpbmcpOwogfQo=
--0016e65b54cc6a992604a27c99d1--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
