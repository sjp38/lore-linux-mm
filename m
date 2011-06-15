Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta12.messagelabs.com (mail6.bemta12.messagelabs.com [216.82.250.247])
	by kanga.kvack.org (Postfix) with ESMTP id 17A106B0012
	for <linux-mm@kvack.org>; Tue, 14 Jun 2011 23:51:33 -0400 (EDT)
Received: from mail-vw0-f41.google.com (mail-vw0-f41.google.com [209.85.212.41])
	(authenticated bits=0)
	by smtp1.linux-foundation.org (8.14.2/8.13.5/Debian-3ubuntu1.1) with ESMTP id p5F3oxYi020680
	(version=TLSv1/SSLv3 cipher=RC4-SHA bits=128 verify=FAIL)
	for <linux-mm@kvack.org>; Tue, 14 Jun 2011 20:51:00 -0700
Received: by vws4 with SMTP id 4so17073vws.14
        for <linux-mm@kvack.org>; Tue, 14 Jun 2011 20:50:59 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <BANLkTinEhVY4aZ+M6H=380zd0Osr_6VFCA@mail.gmail.com>
References: <1308097798.17300.142.camel@schen9-DESK> <BANLkTinEhVY4aZ+M6H=380zd0Osr_6VFCA@mail.gmail.com>
From: Linus Torvalds <torvalds@linux-foundation.org>
Date: Tue, 14 Jun 2011 20:42:27 -0700
Message-ID: <BANLkTinFtUXar+dRnSLakhBe6Bf25p7YAA@mail.gmail.com>
Subject: Re: REGRESSION: Performance regressions from switching anon_vma->lock
 to mutex
Content-Type: multipart/mixed; boundary=bcaec5014ba927443104a5b7f2ba
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tim Chen <tim.c.chen@linux.intel.com>
Cc: Peter Zijlstra <a.p.zijlstra@chello.nl>, Andrew Morton <akpm@linux-foundation.org>, Hugh Dickins <hughd@google.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, David Miller <davem@davemloft.net>, Martin Schwidefsky <schwidefsky@de.ibm.com>, Russell King <rmk@arm.linux.org.uk>, Paul Mundt <lethal@linux-sh.org>, Jeff Dike <jdike@addtoit.com>, Richard Weinberger <richard@nod.at>, Tony Luck <tony.luck@intel.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Mel Gorman <mel@csn.ul.ie>, Nick Piggin <npiggin@kernel.dk>, Namhyung Kim <namhyung@gmail.com>, ak@linux.intel.com, shaohua.li@intel.com, alex.shi@intel.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, "Rafael J. Wysocki" <rjw@sisk.pl>

--bcaec5014ba927443104a5b7f2ba
Content-Type: text/plain; charset=ISO-8859-1

On Tue, Jun 14, 2011 at 6:21 PM, Linus Torvalds
<torvalds@linux-foundation.org> wrote:
>
> Anyway, please check me if I'm wrong, but won't the "anon_vma->root"
> be the same for all the anon_vma's that are associated with one
> particular vma?
>
> The reason I ask [...]

So here's a trial patch that moves the anon_vma locking one level up
in the anon_vma_clone() call chain. It actually does allow the root to
change, but has a WARN_ON_ONCE() if that ever happens.

I *suspect* this will help the locking numbers a bit, but I'd like to
note that it does this *only* for the anon_vma_clone() case, and the
exact same thing should be done for the exit case too (ie the
unlink_anon_vmas()). So if it does work it's still just one step on
the way, and there would be more work along the same lines to possibly
improve the locking further.

The patch is "tested" in the sense that I booted the kernel and am
running it right now (and compiled a kernel with it). But that's not a
whole lot of actual real life testing, so caveat emptor.

And I won't really even guarantee that the main problem locking-wise
would be a long chain of "same_vma" anon-vma's that this does with
just a single lock. So who knows - maybe it doesn't help at all. I
suspect it's worth testing, though.

                              Linus

--bcaec5014ba927443104a5b7f2ba
Content-Type: text/x-patch; charset=US-ASCII; name="patch.diff"
Content-Disposition: attachment; filename="patch.diff"
Content-Transfer-Encoding: base64
X-Attachment-Id: f_goxqgqiz0

IG1tL3JtYXAuYyB8ICAgMTggKysrKysrKysrKysrKysrKy0tCiAxIGZpbGVzIGNoYW5nZWQsIDE2
IGluc2VydGlvbnMoKyksIDIgZGVsZXRpb25zKC0pCgpkaWZmIC0tZ2l0IGEvbW0vcm1hcC5jIGIv
bW0vcm1hcC5jCmluZGV4IDBlYjQ2M2VhODhkZC4uMjA2YzNmYjA3MmFmIDEwMDY0NAotLS0gYS9t
bS9ybWFwLmMKKysrIGIvbW0vcm1hcC5jCkBAIC0yMDgsMTMgKzIwOCwxMSBAQCBzdGF0aWMgdm9p
ZCBhbm9uX3ZtYV9jaGFpbl9saW5rKHN0cnVjdCB2bV9hcmVhX3N0cnVjdCAqdm1hLAogCWF2Yy0+
YW5vbl92bWEgPSBhbm9uX3ZtYTsKIAlsaXN0X2FkZCgmYXZjLT5zYW1lX3ZtYSwgJnZtYS0+YW5v
bl92bWFfY2hhaW4pOwogCi0JYW5vbl92bWFfbG9jayhhbm9uX3ZtYSk7CiAJLyoKIAkgKiBJdCdz
IGNyaXRpY2FsIHRvIGFkZCBuZXcgdm1hcyB0byB0aGUgdGFpbCBvZiB0aGUgYW5vbl92bWEsCiAJ
ICogc2VlIGNvbW1lbnQgaW4gaHVnZV9tZW1vcnkuYzpfX3NwbGl0X2h1Z2VfcGFnZSgpLgogCSAq
LwogCWxpc3RfYWRkX3RhaWwoJmF2Yy0+c2FtZV9hbm9uX3ZtYSwgJmFub25fdm1hLT5oZWFkKTsK
LQlhbm9uX3ZtYV91bmxvY2soYW5vbl92bWEpOwogfQogCiAvKgpAQCAtMjI0LDE2ICsyMjIsMzAg
QEAgc3RhdGljIHZvaWQgYW5vbl92bWFfY2hhaW5fbGluayhzdHJ1Y3Qgdm1fYXJlYV9zdHJ1Y3Qg
KnZtYSwKIGludCBhbm9uX3ZtYV9jbG9uZShzdHJ1Y3Qgdm1fYXJlYV9zdHJ1Y3QgKmRzdCwgc3Ry
dWN0IHZtX2FyZWFfc3RydWN0ICpzcmMpCiB7CiAJc3RydWN0IGFub25fdm1hX2NoYWluICphdmMs
ICpwYXZjOworCXN0cnVjdCBhbm9uX3ZtYSAqcm9vdCA9IE5VTEw7CiAKIAlsaXN0X2Zvcl9lYWNo
X2VudHJ5X3JldmVyc2UocGF2YywgJnNyYy0+YW5vbl92bWFfY2hhaW4sIHNhbWVfdm1hKSB7CisJ
CXN0cnVjdCBhbm9uX3ZtYSAqYW5vbl92bWEgPSBwYXZjLT5hbm9uX3ZtYSwgKm5ld19yb290ID0g
YW5vbl92bWEtPnJvb3Q7CisKKwkJaWYgKG5ld19yb290ICE9IHJvb3QpIHsKKwkJCWlmIChXQVJO
X09OX09OQ0Uocm9vdCkpCisJCQkJbXV0ZXhfdW5sb2NrKCZyb290LT5tdXRleCk7CisJCQlyb290
ID0gbmV3X3Jvb3Q7CisJCQltdXRleF9sb2NrKCZyb290LT5tdXRleCk7CisJCX0KKwogCQlhdmMg
PSBhbm9uX3ZtYV9jaGFpbl9hbGxvYygpOwogCQlpZiAoIWF2YykKIAkJCWdvdG8gZW5vbWVtX2Zh
aWx1cmU7CiAJCWFub25fdm1hX2NoYWluX2xpbmsoZHN0LCBhdmMsIHBhdmMtPmFub25fdm1hKTsK
IAl9CisJaWYgKHJvb3QpCisJCW11dGV4X3VubG9jaygmcm9vdC0+bXV0ZXgpOwogCXJldHVybiAw
OwogCiAgZW5vbWVtX2ZhaWx1cmU6CisJaWYgKHJvb3QpCisJCW11dGV4X3VubG9jaygmcm9vdC0+
bXV0ZXgpOwogCXVubGlua19hbm9uX3ZtYXMoZHN0KTsKIAlyZXR1cm4gLUVOT01FTTsKIH0KQEAg
LTI4MCw3ICsyOTIsOSBAQCBpbnQgYW5vbl92bWFfZm9yayhzdHJ1Y3Qgdm1fYXJlYV9zdHJ1Y3Qg
KnZtYSwgc3RydWN0IHZtX2FyZWFfc3RydWN0ICpwdm1hKQogCWdldF9hbm9uX3ZtYShhbm9uX3Zt
YS0+cm9vdCk7CiAJLyogTWFyayB0aGlzIGFub25fdm1hIGFzIHRoZSBvbmUgd2hlcmUgb3VyIG5l
dyAoQ09XZWQpIHBhZ2VzIGdvLiAqLwogCXZtYS0+YW5vbl92bWEgPSBhbm9uX3ZtYTsKKwlhbm9u
X3ZtYV9sb2NrKGFub25fdm1hKTsKIAlhbm9uX3ZtYV9jaGFpbl9saW5rKHZtYSwgYXZjLCBhbm9u
X3ZtYSk7CisJYW5vbl92bWFfdW5sb2NrKGFub25fdm1hKTsKIAogCXJldHVybiAwOwogCg==
--bcaec5014ba927443104a5b7f2ba--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
