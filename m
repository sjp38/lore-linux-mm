Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with ESMTP id 6B3B98D003B
	for <linux-mm@kvack.org>; Wed,  6 Apr 2011 11:33:04 -0400 (EDT)
Received: from mail-iw0-f169.google.com (mail-iw0-f169.google.com [209.85.214.169])
	(authenticated bits=0)
	by smtp1.linux-foundation.org (8.14.2/8.13.5/Debian-3ubuntu1.1) with ESMTP id p36FWYu1009774
	(version=TLSv1/SSLv3 cipher=RC4-SHA bits=128 verify=FAIL)
	for <linux-mm@kvack.org>; Wed, 6 Apr 2011 08:32:34 -0700
Received: by iwg8 with SMTP id 8so2154288iwg.14
        for <linux-mm@kvack.org>; Wed, 06 Apr 2011 08:32:33 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <BANLkTimV1f1YDTWZUU9uvAtCO_fp6EKH9Q@mail.gmail.com>
References: <alpine.LSU.2.00.1102232136020.2239@sister.anvils>
 <AANLkTi==MQV=_qq1HaCxGLRu8DdT6FYddqzBkzp1TQs7@mail.gmail.com>
 <AANLkTimv66fV1+JDqSAxRwddvy_kggCuhoJLMTpMTtJM@mail.gmail.com>
 <alpine.LSU.2.00.1103182158200.18771@sister.anvils> <BANLkTinoNMudwkcOOgU5d+imPUfZhDbWWQ@mail.gmail.com>
 <AANLkTimfArmB7judMW7Qd4ATtVaR=yTf_-0DBRAfCJ7w@mail.gmail.com>
 <BANLkTi=Limr3NUaG7RLoQLv5TuEDmm7Rqg@mail.gmail.com> <BANLkTi=UZcocVk_16MbbV432g9a3nDFauA@mail.gmail.com>
 <BANLkTi=KTdLRC_hRvxfpFoMSbz=vOjpObw@mail.gmail.com> <BANLkTindeX9-ECPjgd_V62ZbXCd7iEG9_w@mail.gmail.com>
 <BANLkTikcZK+AQvwe2ED=b0dLZ0hqg0B95w@mail.gmail.com> <BANLkTimV1f1YDTWZUU9uvAtCO_fp6EKH9Q@mail.gmail.com>
From: Linus Torvalds <torvalds@linux-foundation.org>
Date: Wed, 6 Apr 2011 08:32:13 -0700
Message-ID: <BANLkTi=tavhpytcSV+nKaXJzw19Bo3W9XQ@mail.gmail.com>
Subject: Re: [PATCH] mm: fix possible cause of a page_mapped BUG
Content-Type: multipart/mixed; boundary=90e6ba6e8ff4965d4204a041b318
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hugh Dickins <hughd@google.com>
Cc: =?UTF-8?B?Um9iZXJ0IMWad2nEmWNraQ==?= <robert@swiecki.net>, Andrew Morton <akpm@linux-foundation.org>, Miklos Szeredi <miklos@szeredi.hu>, Michel Lespinasse <walken@google.com>, "Eric W. Biederman" <ebiederm@xmission.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Peter Zijlstra <a.p.zijlstra@chello.nl>, Rik van Riel <riel@redhat.com>

--90e6ba6e8ff4965d4204a041b318
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable

On Wed, Apr 6, 2011 at 7:47 AM, Hugh Dickins <hughd@google.com> wrote:
>>
>> I dunno. But that odd negative pg_off thing makes me think there is
>> some overflow issue (ie HEAP_INDEX being pg_off + size ends up
>> fluctuating between really big and really small). So I'd suspect THAT
>> as the main reason.
>
> Yes, one of the vmas is such that the end offset (pgoff of next page
> after) would be 0, and for the other it would be 16. =A0There's sure to
> be places, inside the prio_tree code and outside it, where we rely
> upon pgoff not wrapping around - wrap should be prevented by original
> validation of arguments.

Well, we _do_ validate them in do_mmap_pgoff(), which is the main
routine for all the mmap() system calls, and the main way to get a new
mapping.

There are other ways, like do_brk(), but afaik that always sets
vm_pgoff to the virtual address (shifted), so again the new mapping
should be fine.

So when a new mapping is created, it should all be ok.

But I think mremap() may end up expanding it without doing the same
overflow check.

Do you see any other way to get this situation? Does the vma dump give
you any hint about where it came from?

Robert - here's a (UNTESTED!) patch to make mremap() be a bit more
careful about vm_pgoff when growing a mapping. Does it make any
difference?

                            Linus

--90e6ba6e8ff4965d4204a041b318
Content-Type: text/x-patch; charset=US-ASCII; name="patch.diff"
Content-Disposition: attachment; filename="patch.diff"
Content-Transfer-Encoding: base64
X-Attachment-Id: f_gm6f1dde0

IG1tL21yZW1hcC5jIHwgICAxMSArKysrKysrKystLQogMSBmaWxlcyBjaGFuZ2VkLCA5IGluc2Vy
dGlvbnMoKyksIDIgZGVsZXRpb25zKC0pCgpkaWZmIC0tZ2l0IGEvbW0vbXJlbWFwLmMgYi9tbS9t
cmVtYXAuYwppbmRleCAxZGU5OGQ0OTJkZGMuLmE3YzFmOWY5Yjk0MSAxMDA2NDQKLS0tIGEvbW0v
bXJlbWFwLmMKKysrIGIvbW0vbXJlbWFwLmMKQEAgLTI3Nyw5ICsyNzcsMTYgQEAgc3RhdGljIHN0
cnVjdCB2bV9hcmVhX3N0cnVjdCAqdm1hX3RvX3Jlc2l6ZSh1bnNpZ25lZCBsb25nIGFkZHIsCiAJ
aWYgKG9sZF9sZW4gPiB2bWEtPnZtX2VuZCAtIGFkZHIpCiAJCWdvdG8gRWZhdWx0OwogCi0JaWYg
KHZtYS0+dm1fZmxhZ3MgJiAoVk1fRE9OVEVYUEFORCB8IFZNX1BGTk1BUCkpIHsKLQkJaWYgKG5l
d19sZW4gPiBvbGRfbGVuKQorCS8qIE5lZWQgdG8gYmUgY2FyZWZ1bCBhYm91dCBhIGdyb3dpbmcg
bWFwcGluZyAqLworCWlmIChuZXdfbGVuID4gb2xkX2xlbikgeworCQl1bnNpZ25lZCBsb25nIHBn
b2ZmOworCisJCWlmICh2bWEtPnZtX2ZsYWdzICYgKFZNX0RPTlRFWFBBTkQgfCBWTV9QRk5NQVAp
KQogCQkJZ290byBFZmF1bHQ7CisJCXBnb2ZmID0gKGFkZHIgLSB2bWEtPnZtX3N0YXJ0KSA+PiBQ
QUdFX1NISUZUOworCQlwZ29mZiArPSB2bWEtPnZtX3Bnb2ZmOworCQlpZiAocGdvZmYgKyAobmV3
X2xlbiA+PiBQQUdFX1NISUZUKSA8IHBnb2ZmKQorCQkJZ290byBFaW52YWw7CiAJfQogCiAJaWYg
KHZtYS0+dm1fZmxhZ3MgJiBWTV9MT0NLRUQpIHsK
--90e6ba6e8ff4965d4204a041b318--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
