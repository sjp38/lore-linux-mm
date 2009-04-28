Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id 788E86B003D
	for <linux-mm@kvack.org>; Tue, 28 Apr 2009 11:28:23 -0400 (EDT)
Message-ID: <49F7209E.2090405@redhat.com>
Date: Tue, 28 Apr 2009 11:28:30 -0400
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: Swappiness vs. mmap() and interactive response
References: <20090428044426.GA5035@eskimo.com> <20090428143019.EBBF.A69D9226@jp.fujitsu.com>
In-Reply-To: <20090428143019.EBBF.A69D9226@jp.fujitsu.com>
Content-Type: multipart/mixed;
 boundary="------------030309060908000804060301"
Sender: owner-linux-mm@kvack.org
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: Elladan <elladan@eskimo.com>, linux-kernel@vger.kernel.org, linux-mm <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

This is a multi-part message in MIME format.
--------------030309060908000804060301
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit

KOSAKI Motohiro wrote:

>> Next, I set the following:
>>
>> echo 0 > /proc/sys/vm/swappiness
>>
>> ... hoping it would prevent paging out of the UI in favor of file data that's
>> only used once.  It did appear to help to a small degree, but not much.  The
>> system is still effectively unusable while a file copy is going on.
>>
>> From this, I diagnosed that most likely, the kernel was paging out all my
>> application file mmap() data (such as my executables and shared libraries) in
>> favor of total garbage VM load from the file copy.

I believe your analysis is correct.

When merging the split LRU code upstream, some code was changed
(for scalability reasons) that results in active file pages being
moved to the inactive list any time we evict inactive file pages.

Even if the active file pages are referenced, they are not
protected from the streaming IO.

However, the use-once policy in the VM depends on the active
pages being protected from streaming IO.

A little before the decision to no longer honor the referenced
bit on active file pages was made, we dropped an ugly patch (by
me) after deciding it was just too much of a hack.  However, now
that we have _no_ protection for active file pages against large
amounts of streaming IO, we may want to reinstate something like
it.  Hopefully in a prettier way...

The old patch is attached for inspiration, discussion and maybe
testing :)

-- 
All rights reversed.

--------------030309060908000804060301
Content-Type: text/plain;
 name="evict-cache-first.patch"
Content-Transfer-Encoding: base64
Content-Disposition: inline;
 filename="evict-cache-first.patch"

V2hlbiB0aGVyZSBpcyBhIGxvdCBvZiBzdHJlYW1pbmcgSU8gZ29pbmcgb24sIHdlIGRvIG5v
dCB3YW50CnRvIHNjYW4gb3IgZXZpY3QgcGFnZXMgZnJvbSB0aGUgd29ya2luZyBzZXQuICBU
aGUgb2xkIFZNIHVzZWQKdG8gc2tpcCBhbnkgbWFwcGVkIHBhZ2UsIGJ1dCBzdGlsbCBldmlj
dCBpbmRpcmVjdCBibG9ja3MgYW5kCm90aGVyIGRhdGEgdGhhdCBpcyB1c2VmdWwgdG8gY2Fj
aGUuCgpUaGlzIHBhdGNoIGFkZHMgbG9naWMgdG8gc2tpcCBzY2FubmluZyB0aGUgYW5vbiBs
aXN0cyBhbmQKdGhlIGFjdGl2ZSBmaWxlIGxpc3QgaWYgbW9zdCBvZiB0aGUgZmlsZSBwYWdl
cyBhcmUgb24gdGhlCmluYWN0aXZlIGZpbGUgbGlzdCAod2hlcmUgc3RyZWFtaW5nIElPIHBh
Z2VzIGxpdmUpLCB3aGlsZQphdCB0aGUgbG93ZXN0IHNjYW5uaW5nIHByaW9yaXR5LgoKSWYg
dGhlIHN5c3RlbSBpcyBub3QgZG9pbmcgYSBsb3Qgb2Ygc3RyZWFtaW5nIElPLCBlZy4gdGhl
CnN5c3RlbSBpcyBydW5uaW5nIGEgZGF0YWJhc2Ugd29ya2xvYWQsIHRoZW4gbW9yZSBvZnRl
biB1c2VkCmZpbGUgcGFnZXMgd2lsbCBiZSBvbiB0aGUgYWN0aXZlIGZpbGUgbGlzdCBhbmQg
dGhpcyBsb2dpYwppcyBhdXRvbWF0aWNhbGx5IGRpc2FibGVkLgoKU2lnbmVkLW9mZi1ieTog
UmlrIHZhbiBSaWVsIDxyaWVsQHJlZGhhdC5jb20+Ci0tLQogaW5jbHVkZS9saW51eC9tbXpv
bmUuaCB8ICAgIDEgKwogbW0vdm1zY2FuLmMgICAgICAgICAgICB8ICAgMTggKysrKysrKysr
KysrKysrKy0tCiAyIGZpbGVzIGNoYW5nZWQsIDE3IGluc2VydGlvbnMoKyksIDIgZGVsZXRp
b25zKC0pCgpJbmRleDogbGludXgtMi42LjI2LXJjOC1tbTEvaW5jbHVkZS9saW51eC9tbXpv
bmUuaAo9PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09
PT09PT09PT09PT09PT09PT09Ci0tLSBsaW51eC0yLjYuMjYtcmM4LW1tMS5vcmlnL2luY2x1
ZGUvbGludXgvbW16b25lLmgJMjAwOC0wNy0wNyAxNTo0MTozMi4wMDAwMDAwMDAgLTA0MDAK
KysrIGxpbnV4LTIuNi4yNi1yYzgtbW0xL2luY2x1ZGUvbGludXgvbW16b25lLmgJMjAwOC0w
Ny0xNSAxNDo1ODo1MC4wMDAwMDAwMDAgLTA0MDAKQEAgLTQ1Myw2ICs0NTMsNyBAQCBzdGF0
aWMgaW5saW5lIGludCB6b25lX2lzX29vbV9sb2NrZWQoY29uCiAgKiBxdWV1ZXMgKCJxdWV1
ZV9sZW5ndGggPj4gMTIiKSBkdXJpbmcgYW4gYWdpbmcgcm91bmQuCiAgKi8KICNkZWZpbmUg
REVGX1BSSU9SSVRZIDEyCisjZGVmaW5lIFBSSU9fQ0FDSEVfT05MWSBERUZfUFJJT1JJVFkr
MQogCiAvKiBNYXhpbXVtIG51bWJlciBvZiB6b25lcyBvbiBhIHpvbmVsaXN0ICovCiAjZGVm
aW5lIE1BWF9aT05FU19QRVJfWk9ORUxJU1QgKE1BWF9OVU1OT0RFUyAqIE1BWF9OUl9aT05F
UykKSW5kZXg6IGxpbnV4LTIuNi4yNi1yYzgtbW0xL21tL3Ztc2Nhbi5jCj09PT09PT09PT09
PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09
PT0KLS0tIGxpbnV4LTIuNi4yNi1yYzgtbW0xLm9yaWcvbW0vdm1zY2FuLmMJMjAwOC0wNy0w
NyAxNTo0MTozMy4wMDAwMDAwMDAgLTA0MDAKKysrIGxpbnV4LTIuNi4yNi1yYzgtbW0xL21t
L3Ztc2Nhbi5jCTIwMDgtMDctMTUgMTU6MTA6MDUuMDAwMDAwMDAwIC0wNDAwCkBAIC0xNDgx
LDYgKzE0ODEsMjAgQEAgc3RhdGljIHVuc2lnbmVkIGxvbmcgc2hyaW5rX3pvbmUoaW50IHBy
aQogCQl9CiAJfQogCisJLyoKKwkgKiBJZiB0aGVyZSBpcyBhIGxvdCBvZiBzZXF1ZW50aWFs
IElPIGdvaW5nIG9uLCBtb3N0IG9mIHRoZQorCSAqIGZpbGUgcGFnZXMgd2lsbCBiZSBvbiB0
aGUgaW5hY3RpdmUgZmlsZSBsaXN0LiAgV2Ugc3RhcnQKKwkgKiBvdXQgYnkgcmVjbGFpbWlu
ZyB0aG9zZSBwYWdlcywgd2l0aG91dCBwdXR0aW5nIHByZXNzdXJlIG9uCisJICogdGhlIHdv
cmtpbmcgc2V0LiAgV2Ugb25seSBkbyB0aGlzIGlmIHRoZSBidWxrIG9mIHRoZSBmaWxlIHBh
Z2VzCisJICogYXJlIG5vdCBpbiB0aGUgd29ya2luZyBzZXQgKG9uIHRoZSBhY3RpdmUgZmls
ZSBsaXN0KS4KKwkgKi8KKwlpZiAocHJpb3JpdHkgPT0gUFJJT19DQUNIRV9PTkxZICYmCisJ
CQkobnJbTFJVX0lOQUNUSVZFX0ZJTEVdID4gbnJbTFJVX0FDVElWRV9GSUxFXSkpCisJCWZv
cl9lYWNoX2V2aWN0YWJsZV9scnUobCkKKwkJCS8qIFNjYW4gb25seSB0aGUgaW5hY3RpdmVf
ZmlsZSBsaXN0LiAqLworCQkJaWYgKGwgIT0gTFJVX0lOQUNUSVZFX0ZJTEUpCisJCQkJbnJb
bF0gPSAwOworCiAJd2hpbGUgKG5yW0xSVV9JTkFDVElWRV9BTk9OXSB8fCBucltMUlVfQUNU
SVZFX0ZJTEVdIHx8CiAJCQkJCW5yW0xSVV9JTkFDVElWRV9GSUxFXSkgewogCQlmb3JfZWFj
aF9ldmljdGFibGVfbHJ1KGwpIHsKQEAgLTE2MDksNyArMTYyMyw3IEBAIHN0YXRpYyB1bnNp
Z25lZCBsb25nIGRvX3RyeV90b19mcmVlX3BhZ2UKIAkJfQogCX0KIAotCWZvciAocHJpb3Jp
dHkgPSBERUZfUFJJT1JJVFk7IHByaW9yaXR5ID49IDA7IHByaW9yaXR5LS0pIHsKKwlmb3Ig
KHByaW9yaXR5ID0gUFJJT19DQUNIRV9PTkxZOyBwcmlvcml0eSA+PSAwOyBwcmlvcml0eS0t
KSB7CiAJCXNjLT5ucl9zY2FubmVkID0gMDsKIAkJaWYgKCFwcmlvcml0eSkKIAkJCWRpc2Fi
bGVfc3dhcF90b2tlbigpOwpAQCAtMTc3MSw3ICsxNzg1LDcgQEAgbG9vcF9hZ2FpbjoKIAlm
b3IgKGkgPSAwOyBpIDwgcGdkYXQtPm5yX3pvbmVzOyBpKyspCiAJCXRlbXBfcHJpb3JpdHlb
aV0gPSBERUZfUFJJT1JJVFk7CiAKLQlmb3IgKHByaW9yaXR5ID0gREVGX1BSSU9SSVRZOyBw
cmlvcml0eSA+PSAwOyBwcmlvcml0eS0tKSB7CisJZm9yIChwcmlvcml0eSA9IFBSSU9fQ0FD
SEVfT05MWTsgcHJpb3JpdHkgPj0gMDsgcHJpb3JpdHktLSkgewogCQlpbnQgZW5kX3pvbmUg
PSAwOwkvKiBJbmNsdXNpdmUuICAwID0gWk9ORV9ETUEgKi8KIAkJdW5zaWduZWQgbG9uZyBs
cnVfcGFnZXMgPSAwOwogCg==
--------------030309060908000804060301--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
