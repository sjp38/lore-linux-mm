Received: from pong.topalis.com (localhost.localdomain [127.0.0.1])
	by localhost.pong.topalis.com (Postfix) with ESMTP id 80B4E189AE4
	for <Linux-mm@kvack.org>; Mon,  7 Feb 2005 17:30:16 +0100 (CET)
Received: from topalis.com (fw-dmz.topalis.com [195.243.109.1])
	by pong.topalis.com (Postfix) with ESMTP id 65C471ED184
	for <Linux-mm@kvack.org>; Mon,  7 Feb 2005 17:30:16 +0100 (CET)
Received: from localhost (elwood.think [192.168.10.15])
	by topalis.com (Postfix) with ESMTP id 4D351400CF
	for <Linux-mm@kvack.org>; Mon,  7 Feb 2005 17:30:16 +0100 (CET)
Message-ID: <1107793816.42079798356db@webmail.topalis>
Date: Mon,  7 Feb 2005 17:30:16 +0100
From: Stefan Voelkel <stefan.voelkel@millenux.com>
Subject: MM, TLB and speeding up suspend to disk for 2.4
MIME-Version: 1.0
Content-Type: multipart/mixed; boundary="-MOQ11077938168f7f113587421d2a429e373f62ebdb95"
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

This message is in MIME format.

---MOQ11077938168f7f113587421d2a429e373f62ebdb95
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 8bit

Hello,

since neither Understanding the Linux VMM nor the kernelnewbies ML could
help me, I am takin the problem here:

I have a IBM Thinkpad 600X and use the suspend to disk feature (called
hibernation) when carring the notebook around, but writing ~600MB to the
disk takes a while.

After finding out, that the bios does only write used pages to disk, I
wrote a small userspace programm called mhog (see attached mhog.c), that
allocates roughly as many pages as used by the page cache. mhog retrieves
the number of pages to allocate from /proc/meminfo.

This works find, but does take a while, so I wrote a kernel module
(see attached nocache.c) to do the same. During module initilization I
simply loop around a get_free_page(GFP_NIO) to get all pages that can be
discarded, and upon the first failure I free all reserved pages again and
return -ENOMEM.

The kernel module does not speed up hibernation (pages are freed just
fine), but something must be diffrent between userspace and kernelspace
page allocation. I suspect the TLB, but did not find a hint on which of the
many tlb flushing calls to use.

So what am I missing?

thanks in advance
        Stefan

-- 
Stefan Volkel                            stefan.voelkel@millenux.com
Millenux GmbH                              mobile: +49.170.79177.17
Lilienthalstrasse 2                          phone: +49.711.88770.300
70825 Stuttgart-Korntal                       fax: +49.711.88770.349
     -= linux without limits -=- http://linux.zSeries.org/ =-
---MOQ11077938168f7f113587421d2a429e373f62ebdb95
Content-Type: application/octet-stream; name="nocache.c"
Content-Transfer-Encoding: base64
Content-Disposition: attachment; filename="nocache.c"

LyoKCW5vY2FjaGUuYyAoYykgMjAwNSBTdGVmYW4uVm9lbGtlbEBtaWxsZW51eC5jb20KCglsaWNl
bnNlZCB1bmRlciB0aGUgR1BMIHYyLgoqLwoKI2luY2x1ZGUgPGxpbnV4L21vZHVsZS5oPgojaW5j
bHVkZSA8bGludXgvdmVyc2lvbi5oPgojaW5jbHVkZSA8bGludXgvbW0uaD4KI2luY2x1ZGUgPGFz
bS9wZ2FsbG9jLmg+CgpzdHJ1Y3QgbmNfcGFnZXM7CgojZGVmaW5lIE5DX1BBR0VTICgoUEFHRV9T
SVpFIC0gc2l6ZW9mKHN0cnVjdCBuY19wYWdlcyAqKSAtIHNpemVvZih1bnNpZ25lZCBpbnQpKS8g
c2l6ZW9mKHVuc2lnbmVkIGxvbmcpKQoKc3RydWN0IG5jX3BhZ2VzIHsKCXN0cnVjdCBuY19wYWdl
cyAqbmV4dDsKCXVuc2lnbmVkIGludCBvcmRlcjsKCXVuc2lnbmVkIGxvbmcgcGFnZXNbTkNfUEFH
RVNdOwp9OwoKc3RhdGljIHN0cnVjdCBuY19wYWdlcyAqcGEgPSAwOwoKc3RhdGljIGlubGluZSB2
b2lkIG5jX2FsbG9jX3BhZ2VzKHZvaWQpIHsKCXN0cnVjdCBuY19wYWdlcyAqbGlzdDsKCXVuc2ln
bmVkIGxvbmcgcGFnZTsKCgl1bnNpZ25lZCBsb25nIGluZGV4ID0gMDsKCXVuc2lnbmVkIGludCBv
cmRlciA9IE1BWF9PUkRFUiAtIDE7CgoJd2hpbGUgKG9yZGVyIDwgTUFYX09SREVSKSB7CgkJcGFn
ZSA9IF9fZ2V0X2ZyZWVfcGFnZXMoR0ZQX05PSU8sIG9yZGVyKTsKCQlpZiAoIXBhZ2UpIHsKCQkJ
LS1vcmRlcjsKCQkJY29udGludWU7CgkJfQoJCQoJCWlmICghcGEgfHwgaW5kZXggPj0gTkNfUEFH
RVMgfHwgb3JkZXIgIT0gcGEtPm9yZGVyKSB7CgkJCQoJCQlsaXN0ID0gKHN0cnVjdCBuY19wYWdl
cyAqKSBnZXRfemVyb2VkX3BhZ2UoR0ZQX05PSU8pOwoKCQkJaWYgKCFsaXN0KSB7CgkJCQlmcmVl
X3BhZ2VzKHBhZ2UsIG9yZGVyKTsKCQkJCWJyZWFrOwoJCQl9CgoJCQlsaXN0LT5uZXh0ID0gcGE7
CgkJCXBhID0gbGlzdDsKCQkJcGEtPm9yZGVyID0gb3JkZXI7CgkJCWluZGV4ID0gMDsKCQl9CgoJ
CXBhLT5wYWdlc1tpbmRleF0gPSBwYWdlOwoJCSsraW5kZXg7Cgl9Cn0KCnN0YXRpYyBpbmxpbmUg
dm9pZCBuY19mcmVlX3BhZ2VzKHZvaWQpIHsKCXN0cnVjdCBuY19wYWdlcyAqc2F2ZTsKCXVuc2ln
bmVkIGxvbmcgaW5kZXg7CgoJd2hpbGUocGEpIHsKCQlmb3IgKGluZGV4ID0gMDsgaW5kZXggPCBO
Q19QQUdFUyAmJiBwYS0+cGFnZXNbaW5kZXhdOyArK2luZGV4KQoJCQlmcmVlX3BhZ2VzKHBhLT5w
YWdlc1tpbmRleF0sIHBhLT5vcmRlcik7CgkJCgkJc2F2ZSA9IHBhOwoJCXBhID0gcGEtPm5leHQ7
CgoJCWZyZWVfcGFnZSgodW5zaWduZWQgbG9uZykgc2F2ZSk7Cgl9Cn0KCmludCBpbml0X21vZHVs
ZSh2b2lkKQp7CgluY19hbGxvY19wYWdlcygpOwoJbmNfZnJlZV9wYWdlcygpOwoKCWZsdXNoX3Rs
YigpOwoKCXJldHVybiAtRU5PTUVNOwp9Cgp2b2lkIGNsZWFudXBfbW9kdWxlKHZvaWQpCnsKfQoK
TU9EVUxFX0FVVEhPUigiU3RlZmFuIFb2bGtlbCA8c3RlZmFuLnZvZWxrZWxAbWlsbGVudXguY29t
PiIpOwpNT0RVTEVfTElDRU5TRSgiR1BMIik7CgpFWFBPUlRfTk9fU1lNQk9MUzsK

---MOQ11077938168f7f113587421d2a429e373f62ebdb95
Content-Type: application/octet-stream; name="mhog.c"
Content-Transfer-Encoding: base64
Content-Disposition: attachment; filename="mhog.c"

LyoKICogbWhvZy5jIChjKSBTdGVmYW4gVvZsa2VsIDxzdGVmYW4udm9lbGtlbEBtaWxsZW51eC5j
b20+CiAqCiAqIExJQ0VOU0VEIFVOREVSIFRIRSBHUEwgdjIKICoKICovCgojaW5jbHVkZSA8c3Ry
aW5nLmg+CiNpbmNsdWRlIDxzeXMvbW1hbi5oPgojaW5jbHVkZSA8ZmNudGwuaD4KI2luY2x1ZGUg
PGVycm5vLmg+CiNpbmNsdWRlIDxzeXMvdHlwZXMuaD4KI2luY2x1ZGUgPHN5cy9zdGF0Lmg+CiNp
bmNsdWRlIDx1bmlzdGQuaD4KI2luY2x1ZGUgPHN0ZGlvLmg+CiNpbmNsdWRlIDxzdGRsaWIuaD4K
CiNkZWZpbmUgUEFHRV9CSVQgMTIKI2RlZmluZSBQQUdFX1NJWkUgKDEgPDwgUEFHRV9CSVQpCgpp
bnQgbWFpbih2b2lkKQp7CglGSUxFICpmOwoJbG9uZyBidWZmZXJzLCBjYWNoZWQsIGZyZWUsIG1l
bW9yeTsKCWludCByZXQ7CgoJLyogZ2V0IGZyZWUgbWVtb3J5LCBidWZmZXJzIGFuZCBjYWNoZWQg
ZnJvbSAvcHJvYyB0byBjYWxjdWxhdGUgdGhlCgkgKiBudW1iZXIgb2YgcGFnZXMgd2UgbmVlZCB0
byBtYWxsb2MoKSBpbiBvcmRlciB0byBpbnZhbGlkYXRlIHRoZQoJICogY2FjaGUgKi8KCWYgPSBm
b3BlbigiL3Byb2MvbWVtaW5mbyIsICJyIik7CglpZiAoIWYpIHsKCQlwcmludGYoIkU6IGZvcGVu
KCkgJWQ6JyVzJ1xuIiwgZXJybm8sIHN0cmVycm9yKGVycm5vKSk7CgkJZXhpdChlcnJubyk7Cgl9
CgoJcmV0ID0gZnNjYW5mKGYsICIlKnMgJSpzICUqcyAlKnMgJSpzICUqc1xuIik7CglpZiAocmV0
KSB7CgkJcHJpbnRmKCJFOiBzc2NhbmYoKSAoMSkgJWQ6JyVzJ1xuIiwgZXJybm8sIHN0cmVycm9y
KGVycm5vKSk7CgkJZXhpdChlcnJubyk7Cgl9CgoJcmV0ID0gZnNjYW5mKGYsICIlKnMgJSpsZCAl
KmxkICVsZCAlKmxkICVsZCAlbGRcbiIsICZmcmVlLCAKCQkJJmJ1ZmZlcnMsICZjYWNoZWQpOwoJ
aWYgKDMgIT0gcmV0KSB7CgkJcHJpbnRmKCJFOiAlZCA9IHNzY2FuZigpICgyKSAlZDonJXMnXG4i
LCByZXQsIGVycm5vLAoJCQkJc3RyZXJyb3IoZXJybm8pKTsKCQlleGl0KGVycm5vKTsKCX0KCglm
Y2xvc2UoZik7CgoJbWVtb3J5ID0gYnVmZmVycyArIGNhY2hlZCArIGZyZWU7CgltZW1vcnkgPj49
IFBBR0VfQklUOwoKCXByaW50ZigiTmVlZCB0byBmbHVzaCAlbGQgcGFnZXNcbiIsIG1lbW9yeSk7
CgoJLyogd2UgbmVlZCB0byB3cml0ZSBhdCBsZWFzdCBvbmUgYnl0ZSB0byBlYWNoIHBhZ2UgdG8g
dGFrZSBpdCBhd2F5IGZyb20KCSAqIHRoZSBzeXN0ZW0gKi8KCXdoaWxlIChtZW1vcnktLSkgewoJ
CWNoYXIgKmMgPSBtYWxsb2MoUEFHRV9TSVpFKTsKCQkqYyA9ICcwJzsKCgkJcHJpbnRmKCIlZCBs
ZWZ0IFxyIiwgbWVtb3J5KTsKCX0KCglyZXR1cm4gMDsKfQo=

---MOQ11077938168f7f113587421d2a429e373f62ebdb95--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
