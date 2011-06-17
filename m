Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta12.messagelabs.com (mail6.bemta12.messagelabs.com [216.82.250.247])
	by kanga.kvack.org (Postfix) with ESMTP id EA7BF6B0012
	for <linux-mm@kvack.org>; Fri, 17 Jun 2011 00:11:54 -0400 (EDT)
Received: from mail-vx0-f169.google.com (mail-vx0-f169.google.com [209.85.220.169])
	(authenticated bits=0)
	by smtp1.linux-foundation.org (8.14.2/8.13.5/Debian-3ubuntu1.1) with ESMTP id p5H4Boq1018232
	(version=TLSv1/SSLv3 cipher=RC4-SHA bits=128 verify=FAIL)
	for <linux-mm@kvack.org>; Thu, 16 Jun 2011 21:11:51 -0700
Received: by vxg38 with SMTP id 38so988390vxg.14
        for <linux-mm@kvack.org>; Thu, 16 Jun 2011 21:11:50 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <BANLkTimLV8aCZ7snXT_Do+f4vRY0EkoS4A@mail.gmail.com>
References: <1308097798.17300.142.camel@schen9-DESK> <1308101214.15392.151.camel@sli10-conroe>
 <1308138750.15315.62.camel@twins> <20110615161827.GA11769@tassilo.jf.intel.com>
 <1308156337.2171.23.camel@laptop> <1308163398.17300.147.camel@schen9-DESK>
 <1308169937.15315.88.camel@twins> <4DF91CB9.5080504@linux.intel.com>
 <1308172336.17300.177.camel@schen9-DESK> <1308173849.15315.91.camel@twins>
 <BANLkTim5TPKQ9RdLYRxy=mphOVKw5EXvTA@mail.gmail.com> <1308255972.17300.450.camel@schen9-DESK>
 <BANLkTinptaydNvK4ZvGvy0KVLnRmmza7tA@mail.gmail.com> <BANLkTi=GPtwjQ-bYDNUYCwzW5h--y86Law@mail.gmail.com>
 <BANLkTim-dBjva9w7AajqggKT3iUVYG2euQ@mail.gmail.com> <BANLkTimLV8aCZ7snXT_Do+f4vRY0EkoS4A@mail.gmail.com>
From: Linus Torvalds <torvalds@linux-foundation.org>
Date: Thu, 16 Jun 2011 20:58:27 -0700
Message-ID: <BANLkTinUBTYWxrF5TCuDSQuFUAyivXJXjQ@mail.gmail.com>
Subject: Re: REGRESSION: Performance regressions from switching anon_vma->lock
 to mutex
Content-Type: multipart/mixed; boundary=bcaec501c58ca202e904a5e07c30
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tim Chen <tim.c.chen@linux.intel.com>
Cc: Peter Zijlstra <a.p.zijlstra@chello.nl>, Andi Kleen <ak@linux.intel.com>, Shaohua Li <shaohua.li@intel.com>, Andrew Morton <akpm@linux-foundation.org>, Hugh Dickins <hughd@google.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, David Miller <davem@davemloft.net>, Martin Schwidefsky <schwidefsky@de.ibm.com>, Russell King <rmk@arm.linux.org.uk>, Paul Mundt <lethal@linux-sh.org>, Jeff Dike <jdike@addtoit.com>, Richard Weinberger <richard@nod.at>, "Luck, Tony" <tony.luck@intel.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Mel Gorman <mel@csn.ul.ie>, Nick Piggin <npiggin@kernel.dk>, Namhyung Kim <namhyung@gmail.com>, "Shi, Alex" <alex.shi@intel.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "Rafael J. Wysocki" <rjw@sisk.pl>

--bcaec501c58ca202e904a5e07c30
Content-Type: text/plain; charset=ISO-8859-1

On Thu, Jun 16, 2011 at 2:26 PM, Linus Torvalds
<torvalds@linux-foundation.org> wrote:
>
> So the unlink_anon_vmas() case is actually much more complicated than
> the clone case.
>
> In other words, just forget that second patch. I'll have to think about it.

Ok, I'm still thinking. I have an approach that I think will handle it
fairly cleanly, but that involves walking the same_vma list twice:
once to actually unlink the anon_vma's under the lock, and then a
second pass that does the rest. It should work.

But in the meantime I cleaned up the patch I already sent out a bit,
because the lock/unlock sequence will be the same, so I abstracted it
out a bit and added a couple of comments.

So Tim, I'd like you to test out my first patch (that only does the
anon_vma_clone() case) once again, but now in the cleaned-up version.
Does this patch really make a big improvement for you? If so, this
first step is probably worth doing regardless of the more complicated
second step, but I'd want to really make sure it's ok, and that the
performance improvement you saw is consistent and not a fluke.

                 Linus

--bcaec501c58ca202e904a5e07c30
Content-Type: text/x-patch; charset=US-ASCII; name="patch.diff"
Content-Disposition: attachment; filename="patch.diff"
Content-Transfer-Encoding: base64
X-Attachment-Id: f_gp0lypwm0

Y29tbWl0IDYzN2ZiYmY5NmZkZDkyZDIzMTQxN2JlNTA5MjFiM2JlYWZkNDM5YjkKQXV0aG9yOiBM
aW51cyBUb3J2YWxkcyA8dG9ydmFsZHNAbGludXgtZm91bmRhdGlvbi5vcmc+CkRhdGU6ICAgVGh1
IEp1biAxNiAyMDo0NDo1MSAyMDExIC0wNzAwCgogICAgbW06IGF2b2lkIHJlcGVhdGVkIGFub25f
dm1hIGxvY2svdW5sb2NrIHNlcXVlbmNlcyBpbiBhbm9uX3ZtYV9jbG9uZSgpCiAgICAKICAgIElu
IGFub25fdm1hX2Nsb25lKCkgd2UgdHJhdmVyc2UgdGhlIHZtYS0+YW5vbl92bWFfY2hhaW4gb2Yg
dGhlIHNvdXJjZQogICAgdm1hLCBsb2NraW5nIHRoZSBhbm9uX3ZtYSBmb3IgZWFjaCBlbnRyeS4K
ICAgIAogICAgQnV0IHRoZXkgYXJlIGFsbCBnb2luZyB0byBoYXZlIHRoZSBzYW1lIHJvb3QgZW50
cnksIHdoaWNoIG1lYW5zIHRoYXQKICAgIHdlJ3JlIGxvY2tpbmcgYW5kIHVubG9ja2luZyB0aGUg
c2FtZSBsb2NrIG92ZXIgYW5kIG92ZXIgYWdhaW4uICBXaGljaCBpcwogICAgZXhwZW5zaXZlIGlu
IGxvY2tlZCBvcGVyYXRpb25zLCBidXQgY2FuIGdldCBfcmVhbGx5XyBleHBlbnNpdmUgd2hlbiB0
aGF0CiAgICByb290IGVudHJ5IHNlZXMgYW55IGtpbmQgb2YgbG9jayBjb250ZW50aW9uLgogICAg
CiAgICBJbiBmYWN0LCBUaW0gQ2hlbiByZXBvcnRzIGEgYmlnIHBlcmZvcm1hbmNlIHJlZ3Jlc3Np
b24gZHVlIHRvIHRoaXM6IHdoZW4KICAgIHdlIHN3aXRjaGVkIHRvIHVzZSBhIG11dGV4IGluc3Rl
YWQgb2YgYSBzcGlubG9jaywgdGhlIGNvbnRlbnRpb24gY2FzZQogICAgZ2V0cyBtdWNoIHdvcnNl
LgogICAgCiAgICBTbyB0byBhbGxldmlhdGUgdGhpcyBhbGwsIHRoaXMgY29tbWl0IGNyZWF0ZXMg
YSBzbWFsbCBoZWxwZXIgZnVuY3Rpb24KICAgIChsb2NrX2Fub25fdm1hX3Jvb3QoKSkgdGhhdCBj
YW4gYmUgdXNlZCB0byB0YWtlIHRoZSBsb2NrIGp1c3Qgb25jZQogICAgcmF0aGVyIHRoYW4gdGFr
aW5nIGFuZCByZWxlYXNpbmcgaXQgb3ZlciBhbmQgb3ZlciBhZ2Fpbi4KICAgIAogICAgV2Ugc3Rp
bGwgaGF2ZSB0aGUgc2FtZSAidGFrZSB0aGUgbG9jayBhbmQgcmVsZWFzZSIgaXQgYmVoYXZpb3Ig
aW4gdGhlCiAgICBleGl0IHBhdGggKGluIHVubGlua19hbm9uX3ZtYXMoKSksIGJ1dCB0aGF0IG9u
ZSBpcyBhIGJpdCBoYXJkZXIgdG8gZml4CiAgICBzaW5jZSB3ZSdyZSBhY3R1YWxseSBmcmVlaW5n
IHRoZSBhbm9uX3ZtYSBlbnRyaWVzIGFzIHdlIGdvLCBhbmQgdGhhdAogICAgd2lsbCB0b3VjaCB0
aGUgbG9jayB0b28uCiAgICAKICAgIFJlcG9ydGVkLWJ5OiBUaW0gQ2hlbiA8dGltLmMuY2hlbkBs
aW51eC5pbnRlbC5jb20+CiAgICBDYzogUGV0ZXIgWmlqbHN0cmEgPGEucC56aWpsc3RyYUBjaGVs
bG8ubmw+CiAgICBDYzogQW5kaSBLbGVlbiA8YWtAbGludXguaW50ZWwuY29tPgogICAgU2lnbmVk
LW9mZi1ieTogTGludXMgVG9ydmFsZHMgPHRvcnZhbGRzQGxpbnV4LWZvdW5kYXRpb24ub3JnPgot
LS0KIG1tL3JtYXAuYyB8ICAgMzkgKysrKysrKysrKysrKysrKysrKysrKysrKysrKysrKysrKysr
LS0tCiAxIGZpbGVzIGNoYW5nZWQsIDM2IGluc2VydGlvbnMoKyksIDMgZGVsZXRpb25zKC0pCgpk
aWZmIC0tZ2l0IGEvbW0vcm1hcC5jIGIvbW0vcm1hcC5jCmluZGV4IDBlYjQ2M2VhODhkZC4uZjI4
NjY5N2M2MWRjIDEwMDY0NAotLS0gYS9tbS9ybWFwLmMKKysrIGIvbW0vcm1hcC5jCkBAIC0yMDAs
NiArMjAwLDMyIEBAIGludCBhbm9uX3ZtYV9wcmVwYXJlKHN0cnVjdCB2bV9hcmVhX3N0cnVjdCAq
dm1hKQogCXJldHVybiAtRU5PTUVNOwogfQogCisvKgorICogVGhpcyBpcyBhIHVzZWZ1bCBoZWxw
ZXIgZnVuY3Rpb24gZm9yIGxvY2tpbmcgdGhlIGFub25fdm1hIHJvb3QgYXMKKyAqIHdlIHRyYXZl
cnNlIHRoZSB2bWEtPmFub25fdm1hX2NoYWluLCBsb29waW5nIG92ZXIgYW5vbl92bWEncyB0aGF0
CisgKiBoYXZlIHRoZSBzYW1lIHZtYS4KKyAqCisgKiBTdWNoIGFub25fdm1hJ3Mgc2hvdWxkIGhh
dmUgdGhlIHNhbWUgcm9vdCwgc28geW91J2QgZXhwZWN0IHRvIHNlZQorICoganVzdCBhIHNpbmds
ZSBtdXRleF9sb2NrIGZvciB0aGUgd2hvbGUgdHJhdmVyc2FsLgorICovCitzdGF0aWMgaW5saW5l
IHN0cnVjdCBhbm9uX3ZtYSAqbG9ja19hbm9uX3ZtYV9yb290KHN0cnVjdCBhbm9uX3ZtYSAqcm9v
dCwgc3RydWN0IGFub25fdm1hICphbm9uX3ZtYSkKK3sKKwlzdHJ1Y3QgYW5vbl92bWEgKm5ld19y
b290ID0gYW5vbl92bWEtPnJvb3Q7CisJaWYgKG5ld19yb290ICE9IHJvb3QpIHsKKwkJaWYgKFdB
Uk5fT05fT05DRShyb290KSkKKwkJCW11dGV4X3VubG9jaygmcm9vdC0+bXV0ZXgpOworCQlyb290
ID0gbmV3X3Jvb3Q7CisJCW11dGV4X2xvY2soJnJvb3QtPm11dGV4KTsKKwl9CisJcmV0dXJuIHJv
b3Q7Cit9CisKK3N0YXRpYyBpbmxpbmUgdm9pZCB1bmxvY2tfYW5vbl92bWFfcm9vdChzdHJ1Y3Qg
YW5vbl92bWEgKnJvb3QpCit7CisJaWYgKHJvb3QpCisJCW11dGV4X3VubG9jaygmcm9vdC0+bXV0
ZXgpOworfQorCiBzdGF0aWMgdm9pZCBhbm9uX3ZtYV9jaGFpbl9saW5rKHN0cnVjdCB2bV9hcmVh
X3N0cnVjdCAqdm1hLAogCQkJCXN0cnVjdCBhbm9uX3ZtYV9jaGFpbiAqYXZjLAogCQkJCXN0cnVj
dCBhbm9uX3ZtYSAqYW5vbl92bWEpCkBAIC0yMDgsMTMgKzIzNCwxMSBAQCBzdGF0aWMgdm9pZCBh
bm9uX3ZtYV9jaGFpbl9saW5rKHN0cnVjdCB2bV9hcmVhX3N0cnVjdCAqdm1hLAogCWF2Yy0+YW5v
bl92bWEgPSBhbm9uX3ZtYTsKIAlsaXN0X2FkZCgmYXZjLT5zYW1lX3ZtYSwgJnZtYS0+YW5vbl92
bWFfY2hhaW4pOwogCi0JYW5vbl92bWFfbG9jayhhbm9uX3ZtYSk7CiAJLyoKIAkgKiBJdCdzIGNy
aXRpY2FsIHRvIGFkZCBuZXcgdm1hcyB0byB0aGUgdGFpbCBvZiB0aGUgYW5vbl92bWEsCiAJICog
c2VlIGNvbW1lbnQgaW4gaHVnZV9tZW1vcnkuYzpfX3NwbGl0X2h1Z2VfcGFnZSgpLgogCSAqLwog
CWxpc3RfYWRkX3RhaWwoJmF2Yy0+c2FtZV9hbm9uX3ZtYSwgJmFub25fdm1hLT5oZWFkKTsKLQlh
bm9uX3ZtYV91bmxvY2soYW5vbl92bWEpOwogfQogCiAvKgpAQCAtMjI0LDE2ICsyNDgsMjMgQEAg
c3RhdGljIHZvaWQgYW5vbl92bWFfY2hhaW5fbGluayhzdHJ1Y3Qgdm1fYXJlYV9zdHJ1Y3QgKnZt
YSwKIGludCBhbm9uX3ZtYV9jbG9uZShzdHJ1Y3Qgdm1fYXJlYV9zdHJ1Y3QgKmRzdCwgc3RydWN0
IHZtX2FyZWFfc3RydWN0ICpzcmMpCiB7CiAJc3RydWN0IGFub25fdm1hX2NoYWluICphdmMsICpw
YXZjOworCXN0cnVjdCBhbm9uX3ZtYSAqcm9vdCA9IE5VTEw7CiAKIAlsaXN0X2Zvcl9lYWNoX2Vu
dHJ5X3JldmVyc2UocGF2YywgJnNyYy0+YW5vbl92bWFfY2hhaW4sIHNhbWVfdm1hKSB7CisJCXN0
cnVjdCBhbm9uX3ZtYSAqYW5vbl92bWE7CisKIAkJYXZjID0gYW5vbl92bWFfY2hhaW5fYWxsb2Mo
KTsKIAkJaWYgKCFhdmMpCiAJCQlnb3RvIGVub21lbV9mYWlsdXJlOwotCQlhbm9uX3ZtYV9jaGFp
bl9saW5rKGRzdCwgYXZjLCBwYXZjLT5hbm9uX3ZtYSk7CisJCWFub25fdm1hID0gcGF2Yy0+YW5v
bl92bWE7CisJCXJvb3QgPSBsb2NrX2Fub25fdm1hX3Jvb3Qocm9vdCwgYW5vbl92bWEpOworCQlh
bm9uX3ZtYV9jaGFpbl9saW5rKGRzdCwgYXZjLCBhbm9uX3ZtYSk7CiAJfQorCXVubG9ja19hbm9u
X3ZtYV9yb290KHJvb3QpOwogCXJldHVybiAwOwogCiAgZW5vbWVtX2ZhaWx1cmU6CisJdW5sb2Nr
X2Fub25fdm1hX3Jvb3Qocm9vdCk7CiAJdW5saW5rX2Fub25fdm1hcyhkc3QpOwogCXJldHVybiAt
RU5PTUVNOwogfQpAQCAtMjgwLDcgKzMxMSw5IEBAIGludCBhbm9uX3ZtYV9mb3JrKHN0cnVjdCB2
bV9hcmVhX3N0cnVjdCAqdm1hLCBzdHJ1Y3Qgdm1fYXJlYV9zdHJ1Y3QgKnB2bWEpCiAJZ2V0X2Fu
b25fdm1hKGFub25fdm1hLT5yb290KTsKIAkvKiBNYXJrIHRoaXMgYW5vbl92bWEgYXMgdGhlIG9u
ZSB3aGVyZSBvdXIgbmV3IChDT1dlZCkgcGFnZXMgZ28uICovCiAJdm1hLT5hbm9uX3ZtYSA9IGFu
b25fdm1hOworCWFub25fdm1hX2xvY2soYW5vbl92bWEpOwogCWFub25fdm1hX2NoYWluX2xpbmso
dm1hLCBhdmMsIGFub25fdm1hKTsKKwlhbm9uX3ZtYV91bmxvY2soYW5vbl92bWEpOwogCiAJcmV0
dXJuIDA7CiAK
--bcaec501c58ca202e904a5e07c30--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
