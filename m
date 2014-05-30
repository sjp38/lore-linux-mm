Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ve0-f170.google.com (mail-ve0-f170.google.com [209.85.128.170])
	by kanga.kvack.org (Postfix) with ESMTP id D9D2E6B0035
	for <linux-mm@kvack.org>; Thu, 29 May 2014 20:05:18 -0400 (EDT)
Received: by mail-ve0-f170.google.com with SMTP id db11so1290766veb.29
        for <linux-mm@kvack.org>; Thu, 29 May 2014 17:05:18 -0700 (PDT)
Received: from mail-ve0-x22e.google.com (mail-ve0-x22e.google.com [2607:f8b0:400c:c01::22e])
        by mx.google.com with ESMTPS id va3si1864289veb.77.2014.05.29.17.05.18
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Thu, 29 May 2014 17:05:18 -0700 (PDT)
Received: by mail-ve0-f174.google.com with SMTP id jw12so1297752veb.33
        for <linux-mm@kvack.org>; Thu, 29 May 2014 17:05:18 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20140529233638.GJ10092@bbox>
References: <1401260039-18189-1-git-send-email-minchan@kernel.org>
	<1401260039-18189-2-git-send-email-minchan@kernel.org>
	<CA+55aFxXdc22dirnE49UbQP_2s2vLQpjQFL+NptuyK7Xry6c=g@mail.gmail.com>
	<20140528223142.GO8554@dastard>
	<CA+55aFyRk6_v6COPGVvu6hvt=i2A8-dPcs1X3Ydn1g24AxbPkg@mail.gmail.com>
	<20140529013007.GF6677@dastard>
	<20140529015830.GG6677@dastard>
	<20140529233638.GJ10092@bbox>
Date: Thu, 29 May 2014 17:05:17 -0700
Message-ID: <CA+55aFyvn_fTnWEmTCSGgfM18c21-YDU_s=FJP=grDDLQe+aDA@mail.gmail.com>
Subject: Re: [RFC 2/2] x86_64: expand kernel stack to 16K
From: Linus Torvalds <torvalds@linux-foundation.org>
Content-Type: multipart/mixed; boundary=047d7bd6b332fb11ca04fa92cc07
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>
Cc: Dave Chinner <david@fromorbit.com>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, linux-mm <linux-mm@kvack.org>, "H. Peter Anvin" <hpa@zytor.com>, Ingo Molnar <mingo@kernel.org>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Hugh Dickins <hughd@google.com>, Rusty Russell <rusty@rustcorp.com.au>, "Michael S. Tsirkin" <mst@redhat.com>, Dave Hansen <dave.hansen@intel.com>, Steven Rostedt <rostedt@goodmis.org>

--047d7bd6b332fb11ca04fa92cc07
Content-Type: text/plain; charset=UTF-8

On Thu, May 29, 2014 at 4:36 PM, Minchan Kim <minchan@kernel.org> wrote:
>
> I did below hacky test to apply your idea and the result is overflow again.
> So, again it would second stack expansion. Otherwise, we should prevent
> swapout in direct reclaim.

So changing io_schedule() is bad, for the reasons I outlined elsewhere
(we use it for wait_for_page*() - see sleep_on_page().

It's the congestion waiting where the io_schedule() should be avoided.

So maybe test a patch something like the attached.

NOTE! This is absolutely TOTALLY UNTESTED! It might do horrible
horrible things. It seems to compile, but I have absolutely no reason
to believe that it would work. I didn't actually test that this moves
anything at all to kblockd. So think of it as a concept patch that
*might* work, but as Dave said, there might also be other things that
cause unplugging and need some tough love.

                   Linus

--047d7bd6b332fb11ca04fa92cc07
Content-Type: text/plain; charset=US-ASCII; name="patch.diff"
Content-Disposition: attachment; filename="patch.diff"
Content-Transfer-Encoding: base64
X-Attachment-Id: f_hvsqbr3p0

IG1tL2JhY2tpbmctZGV2LmMgfCAyOCArKysrKysrKysrKysrKysrKystLS0tLS0tLS0tCiBtbS92
bXNjYW4uYyAgICAgIHwgIDQgKy0tLQogMiBmaWxlcyBjaGFuZ2VkLCAxOSBpbnNlcnRpb25zKCsp
LCAxMyBkZWxldGlvbnMoLSkKCmRpZmYgLS1naXQgYS9tbS9iYWNraW5nLWRldi5jIGIvbW0vYmFj
a2luZy1kZXYuYwppbmRleCAwOWQ5NTkxYjc3MDguLmNiMjZiMjRjMmRhMiAxMDA2NDQKLS0tIGEv
bW0vYmFja2luZy1kZXYuYworKysgYi9tbS9iYWNraW5nLWRldi5jCkBAIC0xMSw2ICsxMSw3IEBA
CiAjaW5jbHVkZSA8bGludXgvd3JpdGViYWNrLmg+CiAjaW5jbHVkZSA8bGludXgvZGV2aWNlLmg+
CiAjaW5jbHVkZSA8dHJhY2UvZXZlbnRzL3dyaXRlYmFjay5oPgorI2luY2x1ZGUgPGxpbnV4L2Js
a2Rldi5oPgogCiBzdGF0aWMgYXRvbWljX2xvbmdfdCBiZGlfc2VxID0gQVRPTUlDX0xPTkdfSU5J
VCgwKTsKIApAQCAtNTczLDYgKzU3NCwyMSBAQCB2b2lkIHNldF9iZGlfY29uZ2VzdGVkKHN0cnVj
dCBiYWNraW5nX2Rldl9pbmZvICpiZGksIGludCBzeW5jKQogfQogRVhQT1JUX1NZTUJPTChzZXRf
YmRpX2Nvbmdlc3RlZCk7CiAKK3N0YXRpYyBsb25nIGNvbmdlc3Rpb25fdGltZW91dChpbnQgc3lu
YywgbG9uZyB0aW1lb3V0KQoreworCWxvbmcgcmV0OworCURFRklORV9XQUlUKHdhaXQpOworCXN0
cnVjdCBibGtfcGx1ZyAqcGx1ZyA9IGN1cnJlbnQtPnBsdWc7CisJd2FpdF9xdWV1ZV9oZWFkX3Qg
KndxaCA9ICZjb25nZXN0aW9uX3dxaFtzeW5jXTsKKworCXByZXBhcmVfdG9fd2FpdCh3cWgsICZ3
YWl0LCBUQVNLX1VOSU5URVJSVVBUSUJMRSk7CisJaWYgKHBsdWcpCisJCWJsa19mbHVzaF9wbHVn
X2xpc3QocGx1ZywgdHJ1ZSk7CisJcmV0ID0gc2NoZWR1bGVfdGltZW91dCh0aW1lb3V0KTsKKwlm
aW5pc2hfd2FpdCh3cWgsICZ3YWl0KTsKKwlyZXR1cm4gcmV0OworfQorCiAvKioKICAqIGNvbmdl
c3Rpb25fd2FpdCAtIHdhaXQgZm9yIGEgYmFja2luZ19kZXYgdG8gYmVjb21lIHVuY29uZ2VzdGVk
CiAgKiBAc3luYzogU1lOQyBvciBBU1lOQyBJTwpAQCAtNTg2LDEyICs2MDIsOCBAQCBsb25nIGNv
bmdlc3Rpb25fd2FpdChpbnQgc3luYywgbG9uZyB0aW1lb3V0KQogewogCWxvbmcgcmV0OwogCXVu
c2lnbmVkIGxvbmcgc3RhcnQgPSBqaWZmaWVzOwotCURFRklORV9XQUlUKHdhaXQpOwotCXdhaXRf
cXVldWVfaGVhZF90ICp3cWggPSAmY29uZ2VzdGlvbl93cWhbc3luY107CiAKLQlwcmVwYXJlX3Rv
X3dhaXQod3FoLCAmd2FpdCwgVEFTS19VTklOVEVSUlVQVElCTEUpOwotCXJldCA9IGlvX3NjaGVk
dWxlX3RpbWVvdXQodGltZW91dCk7Ci0JZmluaXNoX3dhaXQod3FoLCAmd2FpdCk7CisJcmV0ID0g
Y29uZ2VzdGlvbl90aW1lb3V0KHN5bmMsdGltZW91dCk7CiAKIAl0cmFjZV93cml0ZWJhY2tfY29u
Z2VzdGlvbl93YWl0KGppZmZpZXNfdG9fdXNlY3ModGltZW91dCksCiAJCQkJCWppZmZpZXNfdG9f
dXNlY3MoamlmZmllcyAtIHN0YXJ0KSk7CkBAIC02MjIsOCArNjM0LDYgQEAgbG9uZyB3YWl0X2lm
Zl9jb25nZXN0ZWQoc3RydWN0IHpvbmUgKnpvbmUsIGludCBzeW5jLCBsb25nIHRpbWVvdXQpCiB7
CiAJbG9uZyByZXQ7CiAJdW5zaWduZWQgbG9uZyBzdGFydCA9IGppZmZpZXM7Ci0JREVGSU5FX1dB
SVQod2FpdCk7Ci0Jd2FpdF9xdWV1ZV9oZWFkX3QgKndxaCA9ICZjb25nZXN0aW9uX3dxaFtzeW5j
XTsKIAogCS8qCiAJICogSWYgdGhlcmUgaXMgbm8gY29uZ2VzdGlvbiwgb3IgaGVhdnkgY29uZ2Vz
dGlvbiBpcyBub3QgYmVpbmcKQEAgLTY0Myw5ICs2NTMsNyBAQCBsb25nIHdhaXRfaWZmX2Nvbmdl
c3RlZChzdHJ1Y3Qgem9uZSAqem9uZSwgaW50IHN5bmMsIGxvbmcgdGltZW91dCkKIAl9CiAKIAkv
KiBTbGVlcCB1bnRpbCB1bmNvbmdlc3RlZCBvciBhIHdyaXRlIGhhcHBlbnMgKi8KLQlwcmVwYXJl
X3RvX3dhaXQod3FoLCAmd2FpdCwgVEFTS19VTklOVEVSUlVQVElCTEUpOwotCXJldCA9IGlvX3Nj
aGVkdWxlX3RpbWVvdXQodGltZW91dCk7Ci0JZmluaXNoX3dhaXQod3FoLCAmd2FpdCk7CisJcmV0
ID0gY29uZ2VzdGlvbl90aW1lb3V0KHN5bmMsIHRpbWVvdXQpOwogCiBvdXQ6CiAJdHJhY2Vfd3Jp
dGViYWNrX3dhaXRfaWZmX2Nvbmdlc3RlZChqaWZmaWVzX3RvX3VzZWNzKHRpbWVvdXQpLApkaWZm
IC0tZ2l0IGEvbW0vdm1zY2FuLmMgYi9tbS92bXNjYW4uYwppbmRleCAzMmM2NjFkNjZhNDUuLjFl
NTI0MDAwYjgzZSAxMDA2NDQKLS0tIGEvbW0vdm1zY2FuLmMKKysrIGIvbW0vdm1zY2FuLmMKQEAg
LTk4OSw5ICs5ODksNyBAQCBzdGF0aWMgdW5zaWduZWQgbG9uZyBzaHJpbmtfcGFnZV9saXN0KHN0
cnVjdCBsaXN0X2hlYWQgKnBhZ2VfbGlzdCwKIAkJCSAqIGF2b2lkIHJpc2sgb2Ygc3RhY2sgb3Zl
cmZsb3cgYnV0IG9ubHkgd3JpdGViYWNrCiAJCQkgKiBpZiBtYW55IGRpcnR5IHBhZ2VzIGhhdmUg
YmVlbiBlbmNvdW50ZXJlZC4KIAkJCSAqLwotCQkJaWYgKHBhZ2VfaXNfZmlsZV9jYWNoZShwYWdl
KSAmJgotCQkJCQkoIWN1cnJlbnRfaXNfa3N3YXBkKCkgfHwKLQkJCQkJICF6b25lX2lzX3JlY2xh
aW1fZGlydHkoem9uZSkpKSB7CisJCQlpZiAoIWN1cnJlbnRfaXNfa3N3YXBkKCkgfHwgIXpvbmVf
aXNfcmVjbGFpbV9kaXJ0eSh6b25lKSkgewogCQkJCS8qCiAJCQkJICogSW1tZWRpYXRlbHkgcmVj
bGFpbSB3aGVuIHdyaXR0ZW4gYmFjay4KIAkJCQkgKiBTaW1pbGFyIGluIHByaW5jaXBhbCB0byBk
ZWFjdGl2YXRlX3BhZ2UoKQo=
--047d7bd6b332fb11ca04fa92cc07--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
