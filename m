Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id 9DCB66B0012
	for <linux-mm@kvack.org>; Fri, 17 Jun 2011 14:46:54 -0400 (EDT)
Received: from mail-wy0-f169.google.com (mail-wy0-f169.google.com [74.125.82.169])
	(authenticated bits=0)
	by smtp1.linux-foundation.org (8.14.2/8.13.5/Debian-3ubuntu1.1) with ESMTP id p5HIkKlh018048
	(version=TLSv1/SSLv3 cipher=RC4-SHA bits=128 verify=FAIL)
	for <linux-mm@kvack.org>; Fri, 17 Jun 2011 11:46:21 -0700
Received: by wyf19 with SMTP id 19so2575746wyf.14
        for <linux-mm@kvack.org>; Fri, 17 Jun 2011 11:46:19 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <1308335557.12801.24.camel@laptop>
References: <1308097798.17300.142.camel@schen9-DESK> <1308101214.15392.151.camel@sli10-conroe>
 <1308138750.15315.62.camel@twins> <20110615161827.GA11769@tassilo.jf.intel.com>
 <1308156337.2171.23.camel@laptop> <1308163398.17300.147.camel@schen9-DESK>
 <1308169937.15315.88.camel@twins> <4DF91CB9.5080504@linux.intel.com>
 <1308172336.17300.177.camel@schen9-DESK> <1308173849.15315.91.camel@twins>
 <BANLkTim5TPKQ9RdLYRxy=mphOVKw5EXvTA@mail.gmail.com> <1308255972.17300.450.camel@schen9-DESK>
 <BANLkTinptaydNvK4ZvGvy0KVLnRmmza7tA@mail.gmail.com> <BANLkTi=GPtwjQ-bYDNUYCwzW5h--y86Law@mail.gmail.com>
 <BANLkTim-dBjva9w7AajqggKT3iUVYG2euQ@mail.gmail.com> <BANLkTimLV8aCZ7snXT_Do+f4vRY0EkoS4A@mail.gmail.com>
 <BANLkTinUBTYWxrF5TCuDSQuFUAyivXJXjQ@mail.gmail.com> <1308310080.2355.19.camel@twins>
 <BANLkTim2bmPfeRT1tS7hx2Z85QHjPHwU3Q@mail.gmail.com> <alpine.LSU.2.00.1106171040460.7018@sister.anvils>
 <BANLkTim3vo0vpovV=5sU=GLxkotheB=Ryg@mail.gmail.com> <1308334688.12801.19.camel@laptop>
 <1308335557.12801.24.camel@laptop>
From: Linus Torvalds <torvalds@linux-foundation.org>
Date: Fri, 17 Jun 2011 11:39:04 -0700
Message-ID: <BANLkTimStT22tA2YkeuYBzarnnWTnMjiKQ@mail.gmail.com>
Subject: Re: REGRESSION: Performance regressions from switching anon_vma->lock
 to mutex
Content-Type: multipart/mixed; boundary=000e0cdfd88e63a01704a5ecb463
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Zijlstra <peterz@infradead.org>
Cc: Hugh Dickins <hughd@google.com>, Tim Chen <tim.c.chen@linux.intel.com>, Andi Kleen <ak@linux.intel.com>, Shaohua Li <shaohua.li@intel.com>, Andrew Morton <akpm@linux-foundation.org>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, David Miller <davem@davemloft.net>, Martin Schwidefsky <schwidefsky@de.ibm.com>, Russell King <rmk@arm.linux.org.uk>, Paul Mundt <lethal@linux-sh.org>, Jeff Dike <jdike@addtoit.com>, Richard Weinberger <richard@nod.at>, "Luck, Tony" <tony.luck@intel.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Mel Gorman <mel@csn.ul.ie>, Nick Piggin <npiggin@kernel.dk>, Namhyung Kim <namhyung@gmail.com>, "Shi, Alex" <alex.shi@intel.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "Rafael J. Wysocki" <rjw@sisk.pl>

--000e0cdfd88e63a01704a5ecb463
Content-Type: text/plain; charset=ISO-8859-1

On Fri, Jun 17, 2011 at 11:32 AM, Peter Zijlstra <peterz@infradead.org> wrote:
>
> something like so I guess, completely untested etc..

Having gone over it a bit more, I actually think I prefer to just
special-case the allocation instead.

We already have to drop the anon_vma lock for the "out of memory"
case, and a slight re-organization of clone_anon_vma() makes it easy
to just first try a NOIO allocation with the lock still held, and then
if that fails do the "drop lock, retry, and hard-fail" case.

IOW, something like the attached (on top of the patches already posted
except for your memory reclaim thing)

Hugh, does this fix the lockdep issue?

                        Linus

--000e0cdfd88e63a01704a5ecb463
Content-Type: text/x-patch; charset=US-ASCII; name="patch.diff"
Content-Disposition: attachment; filename="patch.diff"
Content-Transfer-Encoding: base64
X-Attachment-Id: f_gp1hdgxs0

IG1tL3JtYXAuYyB8ICAgMjAgKysrKysrKysrKysrLS0tLS0tLS0KIDEgZmlsZXMgY2hhbmdlZCwg
MTIgaW5zZXJ0aW9ucygrKSwgOCBkZWxldGlvbnMoLSkKCmRpZmYgLS1naXQgYS9tbS9ybWFwLmMg
Yi9tbS9ybWFwLmMKaW5kZXggNjg3NTZhNzdlZjg3Li4yN2RmZDNiODJiMGYgMTAwNjQ0Ci0tLSBh
L21tL3JtYXAuYworKysgYi9tbS9ybWFwLmMKQEAgLTExMiw5ICsxMTIsOSBAQCBzdGF0aWMgaW5s
aW5lIHZvaWQgYW5vbl92bWFfZnJlZShzdHJ1Y3QgYW5vbl92bWEgKmFub25fdm1hKQogCWttZW1f
Y2FjaGVfZnJlZShhbm9uX3ZtYV9jYWNoZXAsIGFub25fdm1hKTsKIH0KIAotc3RhdGljIGlubGlu
ZSBzdHJ1Y3QgYW5vbl92bWFfY2hhaW4gKmFub25fdm1hX2NoYWluX2FsbG9jKHZvaWQpCitzdGF0
aWMgaW5saW5lIHN0cnVjdCBhbm9uX3ZtYV9jaGFpbiAqYW5vbl92bWFfY2hhaW5fYWxsb2MoZ2Zw
X3QgZ2ZwKQogewotCXJldHVybiBrbWVtX2NhY2hlX2FsbG9jKGFub25fdm1hX2NoYWluX2NhY2hl
cCwgR0ZQX0tFUk5FTCk7CisJcmV0dXJuIGttZW1fY2FjaGVfYWxsb2MoYW5vbl92bWFfY2hhaW5f
Y2FjaGVwLCBnZnApOwogfQogCiBzdGF0aWMgdm9pZCBhbm9uX3ZtYV9jaGFpbl9mcmVlKHN0cnVj
dCBhbm9uX3ZtYV9jaGFpbiAqYW5vbl92bWFfY2hhaW4pCkBAIC0xNTksNyArMTU5LDcgQEAgaW50
IGFub25fdm1hX3ByZXBhcmUoc3RydWN0IHZtX2FyZWFfc3RydWN0ICp2bWEpCiAJCXN0cnVjdCBt
bV9zdHJ1Y3QgKm1tID0gdm1hLT52bV9tbTsKIAkJc3RydWN0IGFub25fdm1hICphbGxvY2F0ZWQ7
CiAKLQkJYXZjID0gYW5vbl92bWFfY2hhaW5fYWxsb2MoKTsKKwkJYXZjID0gYW5vbl92bWFfY2hh
aW5fYWxsb2MoR0ZQX0tFUk5FTCk7CiAJCWlmICghYXZjKQogCQkJZ290byBvdXRfZW5vbWVtOwog
CkBAIC0yNTMsOSArMjUzLDE0IEBAIGludCBhbm9uX3ZtYV9jbG9uZShzdHJ1Y3Qgdm1fYXJlYV9z
dHJ1Y3QgKmRzdCwgc3RydWN0IHZtX2FyZWFfc3RydWN0ICpzcmMpCiAJbGlzdF9mb3JfZWFjaF9l
bnRyeV9yZXZlcnNlKHBhdmMsICZzcmMtPmFub25fdm1hX2NoYWluLCBzYW1lX3ZtYSkgewogCQlz
dHJ1Y3QgYW5vbl92bWEgKmFub25fdm1hOwogCi0JCWF2YyA9IGFub25fdm1hX2NoYWluX2FsbG9j
KCk7Ci0JCWlmICghYXZjKQotCQkJZ290byBlbm9tZW1fZmFpbHVyZTsKKwkJYXZjID0gYW5vbl92
bWFfY2hhaW5fYWxsb2MoR0ZQX05PV0FJVCB8IF9fR0ZQX05PV0FSTik7CisJCWlmICh1bmxpa2Vs
eSghYXZjKSkgeworCQkJdW5sb2NrX2Fub25fdm1hX3Jvb3Qocm9vdCk7CisJCQlyb290ID0gTlVM
TDsKKwkJCWF2YyA9IGFub25fdm1hX2NoYWluX2FsbG9jKEdGUF9LRVJORUwpOworCQkJaWYgKCFh
dmMpCisJCQkJZ290byBlbm9tZW1fZmFpbHVyZTsKKwkJfQogCQlhbm9uX3ZtYSA9IHBhdmMtPmFu
b25fdm1hOwogCQlyb290ID0gbG9ja19hbm9uX3ZtYV9yb290KHJvb3QsIGFub25fdm1hKTsKIAkJ
YW5vbl92bWFfY2hhaW5fbGluayhkc3QsIGF2YywgYW5vbl92bWEpOwpAQCAtMjY0LDcgKzI2OSw2
IEBAIGludCBhbm9uX3ZtYV9jbG9uZShzdHJ1Y3Qgdm1fYXJlYV9zdHJ1Y3QgKmRzdCwgc3RydWN0
IHZtX2FyZWFfc3RydWN0ICpzcmMpCiAJcmV0dXJuIDA7CiAKICBlbm9tZW1fZmFpbHVyZToKLQl1
bmxvY2tfYW5vbl92bWFfcm9vdChyb290KTsKIAl1bmxpbmtfYW5vbl92bWFzKGRzdCk7CiAJcmV0
dXJuIC1FTk9NRU07CiB9CkBAIC0yOTQsNyArMjk4LDcgQEAgaW50IGFub25fdm1hX2Zvcmsoc3Ry
dWN0IHZtX2FyZWFfc3RydWN0ICp2bWEsIHN0cnVjdCB2bV9hcmVhX3N0cnVjdCAqcHZtYSkKIAlh
bm9uX3ZtYSA9IGFub25fdm1hX2FsbG9jKCk7CiAJaWYgKCFhbm9uX3ZtYSkKIAkJZ290byBvdXRf
ZXJyb3I7Ci0JYXZjID0gYW5vbl92bWFfY2hhaW5fYWxsb2MoKTsKKwlhdmMgPSBhbm9uX3ZtYV9j
aGFpbl9hbGxvYyhHRlBfS0VSTkVMKTsKIAlpZiAoIWF2YykKIAkJZ290byBvdXRfZXJyb3JfZnJl
ZV9hbm9uX3ZtYTsKIAo=
--000e0cdfd88e63a01704a5ecb463--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
