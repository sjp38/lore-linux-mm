Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with ESMTP id EB8C76B0011
	for <linux-mm@kvack.org>; Wed,  4 May 2011 23:38:38 -0400 (EDT)
Received: from mail-ey0-f169.google.com (mail-ey0-f169.google.com [209.85.215.169])
	(authenticated bits=0)
	by smtp1.linux-foundation.org (8.14.2/8.13.5/Debian-3ubuntu1.1) with ESMTP id p453cVPI026943
	(version=TLSv1/SSLv3 cipher=RC4-SHA bits=128 verify=FAIL)
	for <linux-mm@kvack.org>; Wed, 4 May 2011 20:38:32 -0700
Received: by eyd9 with SMTP id 9so760239eyd.14
        for <linux-mm@kvack.org>; Wed, 04 May 2011 20:38:30 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <BANLkTi=gtiZU3W+UfkgaygURtVWNE6qyEw@mail.gmail.com>
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
 <BANLkTi=D+oe_zyxA1Oj5S36F6Tk0J+26iQ@mail.gmail.com> <BANLkTim_QtaQLa9GV5hMZyCmW_WAz_Ucvg@mail.gmail.com>
 <BANLkTik-s3Gr6GDMN4L24wX2BK9n3okzQA@mail.gmail.com> <BANLkTi=gtiZU3W+UfkgaygURtVWNE6qyEw@mail.gmail.com>
From: Linus Torvalds <torvalds@linux-foundation.org>
Date: Wed, 4 May 2011 20:37:52 -0700
Message-ID: <BANLkTi=0NMdnaxBigtcW3vx1VpRQQrYcpA@mail.gmail.com>
Subject: Re: [PATCH] mm: fix possible cause of a page_mapped BUG
Content-Type: multipart/mixed; boundary=0015175cffba56b08904a27f1bab
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michel Lespinasse <walken@google.com>
Cc: =?UTF-8?B?Um9iZXJ0IMWad2nEmWNraQ==?= <robert@swiecki.net>, Hugh Dickins <hughd@google.com>, Andrew Morton <akpm@linux-foundation.org>, Miklos Szeredi <miklos@szeredi.hu>, "Eric W. Biederman" <ebiederm@xmission.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Peter Zijlstra <a.p.zijlstra@chello.nl>, Rik van Riel <riel@redhat.com>

--0015175cffba56b08904a27f1bab
Content-Type: text/plain; charset=ISO-8859-1

Ok, so here's a slightly different approach.

It still makes the FOLL_MLOCK be unconditional in the mlock path, but
it really just pushes down the

-       gup_flags = FOLL_TOUCH;
+       gup_flags = FOLL_TOUCH | FOLL_MLOCK;
        ...
-       if (vma->vm_flags & VM_LOCKED)
-               gup_flags |= FOLL_MLOCK;

from __mlock_vma_pages_range(), and moves the conditional into
'follow_page()' (which is the only _user_ of that flag) instead:

-       if (flags & FOLL_MLOCK) {
+       if ((flags & FOLL_MLOCK) && (vma->vm_flags & VM_LOCKED)) {

so semantically this changes nothing at all.

But now, because __get_user_pages() can look at FOLL_MLOCK to see that
it's a mlock access, we can do that whole "skip stack guard page"
based on that flag:

-               if (!pages && stack_guard_page(vma, start))
+               if ((gup_flags & FOLL_MLOCK) && stack_guard_page(vma, start))

which means that other uses will try to page in the stack guard page.

I seriously considered making that "skip stack guard page" and the
"mlock lookup" be two separate bits, because conceptually they are
really pretty independent, but right now the only _users_ seem to be
tied together, so I kept it as one single bit (FOLL_MLOCK).

But as far as I can tell, the attached patch is 100% equivalent to
what we do now, except for that "skip stack guard pages only for
mlock" change.

Comments? I like this patch because it seems to make the logic more
straightforward.

But somebody else should double-check my logic.

                         Linus

--0015175cffba56b08904a27f1bab
Content-Type: text/x-patch; charset=US-ASCII; name="patch.diff"
Content-Disposition: attachment; filename="patch.diff"
Content-Transfer-Encoding: base64
X-Attachment-Id: f_gnb5ab270

IG1tL21lbW9yeS5jIHwgICAgNyArKystLS0tCiBtbS9tbG9jay5jICB8ICAgIDUgKy0tLS0KIDIg
ZmlsZXMgY2hhbmdlZCwgNCBpbnNlcnRpb25zKCspLCA4IGRlbGV0aW9ucygtKQoKZGlmZiAtLWdp
dCBhL21tL21lbW9yeS5jIGIvbW0vbWVtb3J5LmMKaW5kZXggNjA3MDk4ZDQ3ZTc0Li4yN2Y0MjUz
NzgxMTIgMTAwNjQ0Ci0tLSBhL21tL21lbW9yeS5jCisrKyBiL21tL21lbW9yeS5jCkBAIC0xMzU5
LDcgKzEzNTksNyBAQCBzcGxpdF9mYWxsdGhyb3VnaDoKIAkJICovCiAJCW1hcmtfcGFnZV9hY2Nl
c3NlZChwYWdlKTsKIAl9Ci0JaWYgKGZsYWdzICYgRk9MTF9NTE9DSykgeworCWlmICgoZmxhZ3Mg
JiBGT0xMX01MT0NLKSAmJiAodm1hLT52bV9mbGFncyAmIFZNX0xPQ0tFRCkpIHsKIAkJLyoKIAkJ
ICogVGhlIHByZWxpbWluYXJ5IG1hcHBpbmcgY2hlY2sgaXMgbWFpbmx5IHRvIGF2b2lkIHRoZQog
CQkgKiBwb2ludGxlc3Mgb3ZlcmhlYWQgb2YgbG9ja19wYWdlIG9uIHRoZSBaRVJPX1BBR0UKQEAg
LTE1NTIsMTAgKzE1NTIsOSBAQCBpbnQgX19nZXRfdXNlcl9wYWdlcyhzdHJ1Y3QgdGFza19zdHJ1
Y3QgKnRzaywgc3RydWN0IG1tX3N0cnVjdCAqbW0sCiAJCX0KIAogCQkvKgotCQkgKiBJZiB3ZSBk
b24ndCBhY3R1YWxseSB3YW50IHRoZSBwYWdlIGl0c2VsZiwKLQkJICogYW5kIGl0J3MgdGhlIHN0
YWNrIGd1YXJkIHBhZ2UsIGp1c3Qgc2tpcCBpdC4KKwkJICogRm9yIG1sb2NrLCBqdXN0IHNraXAg
dGhlIHN0YWNrIGd1YXJkIHBhZ2UuCiAJCSAqLwotCQlpZiAoIXBhZ2VzICYmIHN0YWNrX2d1YXJk
X3BhZ2Uodm1hLCBzdGFydCkpCisJCWlmICgoZ3VwX2ZsYWdzICYgRk9MTF9NTE9DSykgJiYgc3Rh
Y2tfZ3VhcmRfcGFnZSh2bWEsIHN0YXJ0KSkKIAkJCWdvdG8gbmV4dF9wYWdlOwogCiAJCWRvIHsK
ZGlmZiAtLWdpdCBhL21tL21sb2NrLmMgYi9tbS9tbG9jay5jCmluZGV4IDZiNTVlM2VmZTBkZi4u
NTE2YjJjMmRkZDVhIDEwMDY0NAotLS0gYS9tbS9tbG9jay5jCisrKyBiL21tL21sb2NrLmMKQEAg
LTE2Miw3ICsxNjIsNyBAQCBzdGF0aWMgbG9uZyBfX21sb2NrX3ZtYV9wYWdlc19yYW5nZShzdHJ1
Y3Qgdm1fYXJlYV9zdHJ1Y3QgKnZtYSwKIAlWTV9CVUdfT04oZW5kICAgPiB2bWEtPnZtX2VuZCk7
CiAJVk1fQlVHX09OKCFyd3NlbV9pc19sb2NrZWQoJm1tLT5tbWFwX3NlbSkpOwogCi0JZ3VwX2Zs
YWdzID0gRk9MTF9UT1VDSDsKKwlndXBfZmxhZ3MgPSBGT0xMX1RPVUNIIHwgRk9MTF9NTE9DSzsK
IAkvKgogCSAqIFdlIHdhbnQgdG8gdG91Y2ggd3JpdGFibGUgbWFwcGluZ3Mgd2l0aCBhIHdyaXRl
IGZhdWx0IGluIG9yZGVyCiAJICogdG8gYnJlYWsgQ09XLCBleGNlcHQgZm9yIHNoYXJlZCBtYXBw
aW5ncyBiZWNhdXNlIHRoZXNlIGRvbid0IENPVwpAQCAtMTc4LDkgKzE3OCw2IEBAIHN0YXRpYyBs
b25nIF9fbWxvY2tfdm1hX3BhZ2VzX3JhbmdlKHN0cnVjdCB2bV9hcmVhX3N0cnVjdCAqdm1hLAog
CWlmICh2bWEtPnZtX2ZsYWdzICYgKFZNX1JFQUQgfCBWTV9XUklURSB8IFZNX0VYRUMpKQogCQln
dXBfZmxhZ3MgfD0gRk9MTF9GT1JDRTsKIAotCWlmICh2bWEtPnZtX2ZsYWdzICYgVk1fTE9DS0VE
KQotCQlndXBfZmxhZ3MgfD0gRk9MTF9NTE9DSzsKLQogCXJldHVybiBfX2dldF91c2VyX3BhZ2Vz
KGN1cnJlbnQsIG1tLCBhZGRyLCBucl9wYWdlcywgZ3VwX2ZsYWdzLAogCQkJCU5VTEwsIE5VTEws
IG5vbmJsb2NraW5nKTsKIH0K
--0015175cffba56b08904a27f1bab--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
