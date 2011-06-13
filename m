Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id 16BC46B004A
	for <linux-mm@kvack.org>; Mon, 13 Jun 2011 13:56:03 -0400 (EDT)
Received: by gxk23 with SMTP id 23so4034205gxk.14
        for <linux-mm@kvack.org>; Mon, 13 Jun 2011 10:56:00 -0700 (PDT)
MIME-Version: 1.0
Reply-To: M.K.Edwards@gmail.com
In-Reply-To: <BANLkTikkCV=rWM_Pq6t6EyVRHcWeoMPUqw@mail.gmail.com>
References: <1306308920-8602-1-git-send-email-m.szyprowski@samsung.com>
	<BANLkTi=HtrFETnjk1Zu0v9wqa==r0OALvA@mail.gmail.com>
	<201106131707.49217.arnd@arndb.de>
	<BANLkTikR5AE=-wTWzrSJ0TUaks0_rA3mcg@mail.gmail.com>
	<20110613154033.GA29185@1n450.cable.virginmedia.net>
	<BANLkTikkCV=rWM_Pq6t6EyVRHcWeoMPUqw@mail.gmail.com>
Date: Mon, 13 Jun 2011 10:55:59 -0700
Message-ID: <BANLkTi=C6NKT94Fk6Rq6wmhndVixOqC6mg@mail.gmail.com>
Subject: Re: [Linaro-mm-sig] [RFC 0/2] ARM: DMA-mapping & IOMMU integration
From: "Michael K. Edwards" <m.k.edwards@gmail.com>
Content-Type: multipart/mixed; boundary=485b397dd0ffc5cbc504a59ba1e0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: KyongHo Cho <pullip.cho@samsung.com>
Cc: Catalin Marinas <catalin.marinas@arm.com>, Russell King - ARM Linux <linux@arm.linux.org.uk>, Arnd Bergmann <arnd@arndb.de>, Joerg Roedel <joro@8bytes.org>, linaro-mm-sig@lists.linaro.org, linux-mm@kvack.org, Kyungmin Park <kyungmin.park@samsung.com>, linux-arm-kernel@lists.infradead.org

--485b397dd0ffc5cbc504a59ba1e0
Content-Type: text/plain; charset=ISO-8859-1

The need to allocate pages for "write combining" access goes deeper
than anything to do with DMA or IOMMUs.  Please keep "write combine"
distinct from "coherent" in the allocation/mapping APIs.

Write-combining is a special case because it's an end-to-end
requirement, usually architecturally invisible, and getting it to
happen requires a very specific combination of mappings and code.
There's a good explanation here of the requirements on some Intel
implementations of the x86 architecture:
http://software.intel.com/en-us/articles/copying-accelerated-video-decode-frame-buffers/
.  As I understand it, similar considerations apply on at least some
ARMv7 implementations, with NEON multi-register load/store operations
taking the place of MOVNTDQ.  (See
http://www.arm.com/files/pdf/A8_Paper.pdf for instance; although I
don't think there's enough detail about the conditions under which "if
the full cache line is written, the Level-2 line is simply marked
dirty and no external memory requests are required.")

As far as I can tell, there is not yet any way to get real
cache-bypassing write-combining from userland in a mainline kernel,
for x86/x86_64 or ARM.  I have been able to do it from inside a driver
on x86, including in an ISR with some fixes to the kernel's FPU
context save/restore code (patch attached, if you're curious);
otherwise I haven't yet seen write-combining in operation on Linux.
The code that needs to bypass the cache is part of a SoC silicon
erratum workaround supplied by Intel.  It didn't work as delivered --
it oopsed the kernel -- but is now shipping inside our product, and no
problems have been reported from QA or the field.  So I'm fairly sure
that the changes I made are effective.

I am not expert in this area; I was just forced to learn something
about it in order to make a product work.  My assertion that "there's
no way to do it yet" is almost certainly wrong.  I am hoping and
expecting to be immediately contradicted, with a working code example
and benchmarks that show that cache lines are not being fetched,
clobbered, and stored again, with the latencies hidden inside the
cache architecture.  :-)  (Seriously: there are four bits in the
Cortex-A8's "L2 Cache Auxiliary Control Register" that control various
aspects of this mechanism, and if you don't have a fairly good
explanation of which bits do and don't affect your benchmark, then I
contend that the job isn't done.  I don't begin to understand the
equivalent for the multi-core A9 I'm targeting next.)

If some kind person doesn't help me see the error of my ways, I'm
going to have to figure it out for myself on ARM in the next couple of
months, this time for performance reasons rather than to work around
silicon errata.  Unfortunately, I do not expect it to be particularly
low-hanging fruit.  I expect to switch to the hard-float ABI first
(the only remaining obstacle being a couple of TI-supplied binary-only
libraries).  That might provide enough of a system-level performance
win (by allowing the compiler to reorder fetches to NEON registers
across function/method calls) to obviate the need.

Cheers,
- Michael

--485b397dd0ffc5cbc504a59ba1e0
Content-Type: application/octet-stream;
	name="0011-Clean-up-task-FPU-state-thoroughly-during-exec-and-p.patch"
Content-Disposition: attachment;
	filename="0011-Clean-up-task-FPU-state-thoroughly-during-exec-and-p.patch"
Content-Transfer-Encoding: base64
X-Attachment-Id: f_govoxs550

RnJvbSBmZmIzZmViNzNmODlhMzQ0NTliODRmMjI5YTlhYzY5OWE1ODllZDhmIE1vbiBTZXAgMTcg
MDA6MDA6MDAgMjAwMQpGcm9tOiBNaWNoYWVsIEVkd2FyZHMgPG1pY2hhZWR3QGNpc2NvLmNvbT4K
RGF0ZTogU2F0LCAyNCBBcHIgMjAxMCAyMDo1MzozOCAtMDcwMApTdWJqZWN0OiBbUEFUQ0hdIHg4
NixmcHU6IFByb3RlY3QgRlBVIGNvbnRleHQgY2xlYW51cCBhZ2FpbnN0IFNTRTIgaW4gSVNScwoK
IENsZWFuIHVwIHRhc2sgRlBVIHN0YXRlIHRob3JvdWdobHkgZHVyaW5nIGV4ZWMoKSBhbmQgcHJv
Y2VzcyB0ZWFyLWRvd24sCiBhbmQgbG9jayBvdXQgbG9jYWwgSVJRcyB3aGlsZSBkb2luZyBpdCwg
c28gdGhhdCBTU0UyIGluc3RydWN0aW9ucyBpbgogSVNScyBkb24ndCBjYXVzZSBmeHNhdmUvZnhy
c3RvciB0by9mcm9tIGEgbnVsbCBwb2ludGVyLgogKFRoZXkgc3RpbGwgbmVlZCB0byBiZSBndWFy
ZGVkIHdpdGgga2VybmVsX2ZwdV8oYmVnaW58ZW5kKSwgb2YgY291cnNlLikKClNpZ25lZC1vZmYt
Ynk6IE1pY2hhZWwgRWR3YXJkcyA8bWljaGFlZHdAY2lzY28uY29tPgotLS0KIGFyY2gveDg2L2tl
cm5lbC9wcm9jZXNzLmMgICAgfCAgIDEwICsrKysrKysrKysKIGFyY2gveDg2L2tlcm5lbC9wcm9j
ZXNzXzMyLmMgfCAgICA0ICstLS0KIDIgZmlsZXMgY2hhbmdlZCwgMTEgaW5zZXJ0aW9ucygrKSwg
MyBkZWxldGlvbnMoLSkKCmRpZmYgLS1naXQgYS9hcmNoL3g4Ni9rZXJuZWwvcHJvY2Vzcy5jIGIv
YXJjaC94ODYva2VybmVsL3Byb2Nlc3MuYwppbmRleCA4NzZlOTE4Li5iZGU3ZDA5IDEwMDY0NAot
LS0gYS9hcmNoL3g4Ni9rZXJuZWwvcHJvY2Vzcy5jCisrKyBiL2FyY2gveDg2L2tlcm5lbC9wcm9j
ZXNzLmMKQEAgLTgsNiArOCw3IEBACiAjaW5jbHVkZSA8bGludXgvcG0uaD4KICNpbmNsdWRlIDxs
aW51eC9jbG9ja2NoaXBzLmg+CiAjaW5jbHVkZSA8YXNtL3N5c3RlbS5oPgorI2luY2x1ZGUgPGFz
bS9pMzg3Lmg+CiAKIHVuc2lnbmVkIGxvbmcgaWRsZV9oYWx0OwogRVhQT1JUX1NZTUJPTChpZGxl
X2hhbHQpOwpAQCAtMzEsMTIgKzMyLDIxIEBAIGludCBhcmNoX2R1cF90YXNrX3N0cnVjdChzdHJ1
Y3QgdGFza19zdHJ1Y3QgKmRzdCwgc3RydWN0IHRhc2tfc3RydWN0ICpzcmMpCiAJcmV0dXJuIDA7
CiB9CiAKKy8qCisgKiBMb2NrcyBvdXQgbG9jYWwgSVJRcyB3aGlsZSBjbGVhcmluZyBGUFUgc3Rh
dGUgYW5kCisgKiByZWxhdGVkIHRhc2sgcHJvcGVydGllcywgc28gdGhhdCBJU1JzIGNhbiB1c2Ug
U1NFMi4KKyAqLwogdm9pZCBmcmVlX3RocmVhZF94c3RhdGUoc3RydWN0IHRhc2tfc3RydWN0ICp0
c2spCiB7CisJbG9jYWxfaXJxX2Rpc2FibGUoKTsKIAlpZiAodHNrLT50aHJlYWQueHN0YXRlKSB7
CisJCXRzay0+ZnB1X2NvdW50ZXIgPSAwOworCQljbGVhcl9zdG9wcGVkX2NoaWxkX3VzZWRfbWF0
aCh0c2spOworCQlfX2NsZWFyX2ZwdSh0c2spOwogCQlrbWVtX2NhY2hlX2ZyZWUodGFza194c3Rh
dGVfY2FjaGVwLCB0c2stPnRocmVhZC54c3RhdGUpOwogCQl0c2stPnRocmVhZC54c3RhdGUgPSBO
VUxMOwogCX0KKwlsb2NhbF9pcnFfZW5hYmxlKCk7CiB9CiAKIHZvaWQgZnJlZV90aHJlYWRfaW5m
byhzdHJ1Y3QgdGhyZWFkX2luZm8gKnRpKQpkaWZmIC0tZ2l0IGEvYXJjaC94ODYva2VybmVsL3By
b2Nlc3NfMzIuYyBiL2FyY2gveDg2L2tlcm5lbC9wcm9jZXNzXzMyLmMKaW5kZXggMzFmNDBiMi4u
NzEyMjE2MCAxMDA2NDQKLS0tIGEvYXJjaC94ODYva2VybmVsL3Byb2Nlc3NfMzIuYworKysgYi9h
cmNoL3g4Ni9rZXJuZWwvcHJvY2Vzc18zMi5jCkBAIC0yOTQsOSArMjk0LDcgQEAgdm9pZCBmbHVz
aF90aHJlYWQodm9pZCkKIAkvKgogCSAqIEZvcmdldCBjb3Byb2Nlc3NvciBzdGF0ZS4uCiAJICov
Ci0JdHNrLT5mcHVfY291bnRlciA9IDA7Ci0JY2xlYXJfZnB1KHRzayk7Ci0JY2xlYXJfdXNlZF9t
YXRoKCk7CisJZnJlZV90aHJlYWRfeHN0YXRlKHRzayk7CiB9CiAKIHZvaWQgcmVsZWFzZV90aHJl
YWQoc3RydWN0IHRhc2tfc3RydWN0ICpkZWFkX3Rhc2spCi0tIAoxLjcuMAoK
--485b397dd0ffc5cbc504a59ba1e0--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
