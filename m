Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f71.google.com (mail-oi0-f71.google.com [209.85.218.71])
	by kanga.kvack.org (Postfix) with ESMTP id EDEE82803FE
	for <linux-mm@kvack.org>; Wed, 23 Aug 2017 19:30:53 -0400 (EDT)
Received: by mail-oi0-f71.google.com with SMTP id 4so1686514oie.8
        for <linux-mm@kvack.org>; Wed, 23 Aug 2017 16:30:53 -0700 (PDT)
Received: from mail-oi0-x243.google.com (mail-oi0-x243.google.com. [2607:f8b0:4003:c06::243])
        by mx.google.com with ESMTPS id o82si2258284oia.68.2017.08.23.16.30.53
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 23 Aug 2017 16:30:53 -0700 (PDT)
Received: by mail-oi0-x243.google.com with SMTP id w8so976711oig.5
        for <linux-mm@kvack.org>; Wed, 23 Aug 2017 16:30:53 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <CA+55aFzbom=qFc2pYk07XhiMBn083EXugSUHmSVbTuu8eJtHVQ@mail.gmail.com>
References: <CA+55aFwzTMrZwh7TE_VeZt8gx5Syoop-kA=Xqs56=FkyakrM6g@mail.gmail.com>
 <37D7C6CF3E00A74B8858931C1DB2F077537879BB@SHSMSX103.ccr.corp.intel.com>
 <20170818144622.oabozle26hasg5yo@techsingularity.net> <37D7C6CF3E00A74B8858931C1DB2F07753787AE4@SHSMSX103.ccr.corp.intel.com>
 <CA+55aFxZjjqUM4kPvNEeZahPovBHFATiwADj-iPTDN0-jnU67Q@mail.gmail.com>
 <20170818185455.qol3st2nynfa47yc@techsingularity.net> <CA+55aFwX0yrUPULrDxTWVCg5c6DKh-yCG84NXVxaptXNQ4O_kA@mail.gmail.com>
 <20170821183234.kzennaaw2zt2rbwz@techsingularity.net> <37D7C6CF3E00A74B8858931C1DB2F07753788B58@SHSMSX103.ccr.corp.intel.com>
 <37D7C6CF3E00A74B8858931C1DB2F0775378A24A@SHSMSX103.ccr.corp.intel.com>
 <CA+55aFy=4y0fq9nL2WR1x8vwzJrDOdv++r036LXpR=6Jx8jpzg@mail.gmail.com>
 <37D7C6CF3E00A74B8858931C1DB2F0775378A377@SHSMSX103.ccr.corp.intel.com>
 <CA+55aFwavpFfKNW9NVgNhLggqhii-guc5aX1X5fxrPK+==id0g@mail.gmail.com>
 <37D7C6CF3E00A74B8858931C1DB2F0775378A8AB@SHSMSX103.ccr.corp.intel.com>
 <6e8b81de-e985-9222-29c5-594c6849c351@linux.intel.com> <CA+55aFzbom=qFc2pYk07XhiMBn083EXugSUHmSVbTuu8eJtHVQ@mail.gmail.com>
From: Linus Torvalds <torvalds@linux-foundation.org>
Date: Wed, 23 Aug 2017 16:30:51 -0700
Message-ID: <CA+55aFzxisTJS+Z7q+Dp9oRgvMpXEQRedYFu7-k_YXEE-=htgA@mail.gmail.com>
Subject: Re: [PATCH 1/2] sched/wait: Break up long wake list walk
Content-Type: multipart/mixed; boundary="001a11c1691e4fd90e0557741aa4"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tim Chen <tim.c.chen@linux.intel.com>
Cc: "Liang, Kan" <kan.liang@intel.com>, Mel Gorman <mgorman@techsingularity.net>, Mel Gorman <mgorman@suse.de>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Peter Zijlstra <peterz@infradead.org>, Ingo Molnar <mingo@elte.hu>, Andi Kleen <ak@linux.intel.com>, Andrew Morton <akpm@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, Jan Kara <jack@suse.cz>, linux-mm <linux-mm@kvack.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>

--001a11c1691e4fd90e0557741aa4
Content-Type: text/plain; charset="UTF-8"

On Wed, Aug 23, 2017 at 11:17 AM, Linus Torvalds
<torvalds@linux-foundation.org> wrote:
> On Wed, Aug 23, 2017 at 8:58 AM, Tim Chen <tim.c.chen@linux.intel.com> wrote:
>>
>> Will you still consider the original patch as a fail safe mechanism?
>
> I don't think we have much choice, although I would *really* want to
> get this root-caused rather than just papering over the symptoms.

Oh well. Apparently we're not making progress on that, so I looked at
the patch again.

Can we fix it up a bit? In particular, the "bookmark_wake_function()"
thing added no value, and definitely shouldn't have been exported.
Just use NULL instead.

And the WAITQUEUE_WALK_BREAK_CNT thing should be internal to
__wake_up_common(), not in some common header file. Again, there's no
value in exporting it to anybody else.

And doing

                if (curr->flags & WQ_FLAG_BOOKMARK)

looks odd, when we just did

                unsigned flags = curr->flags;

one line earlier, so that can be just simplified.

So can you test that simplified version of the patch? I'm attaching my
suggested edited patch, but you may just want to do those changes
directly to your tree instead.

Hmm?

               Linus

--001a11c1691e4fd90e0557741aa4
Content-Type: text/plain; charset="US-ASCII"; name="patch.diff"
Content-Disposition: attachment; filename="patch.diff"
Content-Transfer-Encoding: base64
X-Attachment-Id: f_j6pnkae10

IGluY2x1ZGUvbGludXgvd2FpdC5oIHwgIDEgKwoga2VybmVsL3NjaGVkL3dhaXQuYyAgfCA3NCAr
KysrKysrKysrKysrKysrKysrKysrKysrKysrKysrKysrKysrKysrKystLS0tLS0tLS0tCiAyIGZp
bGVzIGNoYW5nZWQsIDYxIGluc2VydGlvbnMoKyksIDE0IGRlbGV0aW9ucygtKQoKZGlmZiAtLWdp
dCBhL2luY2x1ZGUvbGludXgvd2FpdC5oIGIvaW5jbHVkZS9saW51eC93YWl0LmgKaW5kZXggZGMx
OTg4MGMwMmY1Li43ODQwMWVmMDJkMjkgMTAwNjQ0Ci0tLSBhL2luY2x1ZGUvbGludXgvd2FpdC5o
CisrKyBiL2luY2x1ZGUvbGludXgvd2FpdC5oCkBAIC0xOCw2ICsxOCw3IEBAIGludCBkZWZhdWx0
X3dha2VfZnVuY3Rpb24oc3RydWN0IHdhaXRfcXVldWVfZW50cnkgKndxX2VudHJ5LCB1bnNpZ25l
ZCBtb2RlLCBpbnQKIC8qIHdhaXRfcXVldWVfZW50cnk6OmZsYWdzICovCiAjZGVmaW5lIFdRX0ZM
QUdfRVhDTFVTSVZFCTB4MDEKICNkZWZpbmUgV1FfRkxBR19XT0tFTgkJMHgwMgorI2RlZmluZSBX
UV9GTEFHX0JPT0tNQVJLCTB4MDQKIAogLyoKICAqIEEgc2luZ2xlIHdhaXQtcXVldWUgZW50cnkg
c3RydWN0dXJlOgpkaWZmIC0tZ2l0IGEva2VybmVsL3NjaGVkL3dhaXQuYyBiL2tlcm5lbC9zY2hl
ZC93YWl0LmMKaW5kZXggMTdmMTFjNmIwYTlmLi43ODlkYzI0YTMyM2QgMTAwNjQ0Ci0tLSBhL2tl
cm5lbC9zY2hlZC93YWl0LmMKKysrIGIva2VybmVsL3NjaGVkL3dhaXQuYwpAQCAtNTMsNiArNTMs
MTIgQEAgdm9pZCByZW1vdmVfd2FpdF9xdWV1ZShzdHJ1Y3Qgd2FpdF9xdWV1ZV9oZWFkICp3cV9o
ZWFkLCBzdHJ1Y3Qgd2FpdF9xdWV1ZV9lbnRyeQogfQogRVhQT1JUX1NZTUJPTChyZW1vdmVfd2Fp
dF9xdWV1ZSk7CiAKKy8qCisgKiBTY2FuIHRocmVzaG9sZCB0byBicmVhayB3YWl0IHF1ZXVlIHdh
bGsuCisgKiBUaGlzIGFsbG93cyBhIHdha2VyIHRvIHRha2UgYSBicmVhayBmcm9tIGhvbGRpbmcg
dGhlCisgKiB3YWl0IHF1ZXVlIGxvY2sgZHVyaW5nIHRoZSB3YWl0IHF1ZXVlIHdhbGsuCisgKi8K
KyNkZWZpbmUgV0FJVFFVRVVFX1dBTEtfQlJFQUtfQ05UIDY0CiAKIC8qCiAgKiBUaGUgY29yZSB3
YWtldXAgZnVuY3Rpb24uIE5vbi1leGNsdXNpdmUgd2FrZXVwcyAobnJfZXhjbHVzaXZlID09IDAp
IGp1c3QKQEAgLTYzLDE3ICs2OSw2NCBAQCBFWFBPUlRfU1lNQk9MKHJlbW92ZV93YWl0X3F1ZXVl
KTsKICAqIHN0YXJ0ZWQgdG8gcnVuIGJ1dCBpcyBub3QgaW4gc3RhdGUgVEFTS19SVU5OSU5HLiB0
cnlfdG9fd2FrZV91cCgpIHJldHVybnMKICAqIHplcm8gaW4gdGhpcyAocmFyZSkgY2FzZSwgYW5k
IHdlIGhhbmRsZSBpdCBieSBjb250aW51aW5nIHRvIHNjYW4gdGhlIHF1ZXVlLgogICovCi1zdGF0
aWMgdm9pZCBfX3dha2VfdXBfY29tbW9uKHN0cnVjdCB3YWl0X3F1ZXVlX2hlYWQgKndxX2hlYWQs
IHVuc2lnbmVkIGludCBtb2RlLAotCQkJaW50IG5yX2V4Y2x1c2l2ZSwgaW50IHdha2VfZmxhZ3Ms
IHZvaWQgKmtleSkKK3N0YXRpYyBpbnQgX193YWtlX3VwX2NvbW1vbihzdHJ1Y3Qgd2FpdF9xdWV1
ZV9oZWFkICp3cV9oZWFkLCB1bnNpZ25lZCBpbnQgbW9kZSwKKwkJCWludCBucl9leGNsdXNpdmUs
IGludCB3YWtlX2ZsYWdzLCB2b2lkICprZXksCisJCQl3YWl0X3F1ZXVlX2VudHJ5X3QgKmJvb2tt
YXJrKQogewogCXdhaXRfcXVldWVfZW50cnlfdCAqY3VyciwgKm5leHQ7CisJaW50IGNudCA9IDA7
CisKKwlpZiAoYm9va21hcmsgJiYgKGJvb2ttYXJrLT5mbGFncyAmIFdRX0ZMQUdfQk9PS01BUksp
KSB7CisJCWN1cnIgPSBsaXN0X25leHRfZW50cnkoYm9va21hcmssIGVudHJ5KTsKIAotCWxpc3Rf
Zm9yX2VhY2hfZW50cnlfc2FmZShjdXJyLCBuZXh0LCAmd3FfaGVhZC0+aGVhZCwgZW50cnkpIHsK
KwkJbGlzdF9kZWwoJmJvb2ttYXJrLT5lbnRyeSk7CisJCWJvb2ttYXJrLT5mbGFncyA9IDA7CisJ
fSBlbHNlCisJCWN1cnIgPSBsaXN0X2ZpcnN0X2VudHJ5KCZ3cV9oZWFkLT5oZWFkLCB3YWl0X3F1
ZXVlX2VudHJ5X3QsIGVudHJ5KTsKKworCWlmICgmY3Vyci0+ZW50cnkgPT0gJndxX2hlYWQtPmhl
YWQpCisJCXJldHVybiBucl9leGNsdXNpdmU7CisKKwlsaXN0X2Zvcl9lYWNoX2VudHJ5X3NhZmVf
ZnJvbShjdXJyLCBuZXh0LCAmd3FfaGVhZC0+aGVhZCwgZW50cnkpIHsKIAkJdW5zaWduZWQgZmxh
Z3MgPSBjdXJyLT5mbGFnczsKIAorCQlpZiAoZmxhZ3MgJiBXUV9GTEFHX0JPT0tNQVJLKQorCQkJ
Y29udGludWU7CisKIAkJaWYgKGN1cnItPmZ1bmMoY3VyciwgbW9kZSwgd2FrZV9mbGFncywga2V5
KSAmJgogCQkJCShmbGFncyAmIFdRX0ZMQUdfRVhDTFVTSVZFKSAmJiAhLS1ucl9leGNsdXNpdmUp
CiAJCQlicmVhazsKKworCQlpZiAoYm9va21hcmsgJiYgKCsrY250ID4gV0FJVFFVRVVFX1dBTEtf
QlJFQUtfQ05UKSAmJgorCQkJCSgmbmV4dC0+ZW50cnkgIT0gJndxX2hlYWQtPmhlYWQpKSB7CisJ
CQlib29rbWFyay0+ZmxhZ3MgPSBXUV9GTEFHX0JPT0tNQVJLOworCQkJbGlzdF9hZGRfdGFpbCgm
Ym9va21hcmstPmVudHJ5LCAmbmV4dC0+ZW50cnkpOworCQkJYnJlYWs7CisJCX0KKwl9CisJcmV0
dXJuIG5yX2V4Y2x1c2l2ZTsKK30KKworc3RhdGljIHZvaWQgX193YWtlX3VwX2NvbW1vbl9sb2Nr
KHN0cnVjdCB3YWl0X3F1ZXVlX2hlYWQgKndxX2hlYWQsIHVuc2lnbmVkIGludCBtb2RlLAorCQkJ
aW50IG5yX2V4Y2x1c2l2ZSwgaW50IHdha2VfZmxhZ3MsIHZvaWQgKmtleSkKK3sKKwl1bnNpZ25l
ZCBsb25nIGZsYWdzOworCXdhaXRfcXVldWVfZW50cnlfdCBib29rbWFyazsKKworCWJvb2ttYXJr
LmZsYWdzID0gMDsKKwlib29rbWFyay5wcml2YXRlID0gTlVMTDsKKwlib29rbWFyay5mdW5jID0g
TlVMTDsKKwlJTklUX0xJU1RfSEVBRCgmYm9va21hcmsuZW50cnkpOworCisJc3Bpbl9sb2NrX2ly
cXNhdmUoJndxX2hlYWQtPmxvY2ssIGZsYWdzKTsKKwlucl9leGNsdXNpdmUgPSBfX3dha2VfdXBf
Y29tbW9uKHdxX2hlYWQsIG1vZGUsIG5yX2V4Y2x1c2l2ZSwgd2FrZV9mbGFncywga2V5LCAmYm9v
a21hcmspOworCXNwaW5fdW5sb2NrX2lycXJlc3RvcmUoJndxX2hlYWQtPmxvY2ssIGZsYWdzKTsK
KworCXdoaWxlIChib29rbWFyay5mbGFncyAmIFdRX0ZMQUdfQk9PS01BUkspIHsKKwkJc3Bpbl9s
b2NrX2lycXNhdmUoJndxX2hlYWQtPmxvY2ssIGZsYWdzKTsKKwkJbnJfZXhjbHVzaXZlID0gX193
YWtlX3VwX2NvbW1vbih3cV9oZWFkLCBtb2RlLCBucl9leGNsdXNpdmUsCisJCQkJCQl3YWtlX2Zs
YWdzLCBrZXksICZib29rbWFyayk7CisJCXNwaW5fdW5sb2NrX2lycXJlc3RvcmUoJndxX2hlYWQt
PmxvY2ssIGZsYWdzKTsKIAl9CiB9CiAKQEAgLTkwLDExICsxNDMsNyBAQCBzdGF0aWMgdm9pZCBf
X3dha2VfdXBfY29tbW9uKHN0cnVjdCB3YWl0X3F1ZXVlX2hlYWQgKndxX2hlYWQsIHVuc2lnbmVk
IGludCBtb2RlLAogdm9pZCBfX3dha2VfdXAoc3RydWN0IHdhaXRfcXVldWVfaGVhZCAqd3FfaGVh
ZCwgdW5zaWduZWQgaW50IG1vZGUsCiAJCQlpbnQgbnJfZXhjbHVzaXZlLCB2b2lkICprZXkpCiB7
Ci0JdW5zaWduZWQgbG9uZyBmbGFnczsKLQotCXNwaW5fbG9ja19pcnFzYXZlKCZ3cV9oZWFkLT5s
b2NrLCBmbGFncyk7Ci0JX193YWtlX3VwX2NvbW1vbih3cV9oZWFkLCBtb2RlLCBucl9leGNsdXNp
dmUsIDAsIGtleSk7Ci0Jc3Bpbl91bmxvY2tfaXJxcmVzdG9yZSgmd3FfaGVhZC0+bG9jaywgZmxh
Z3MpOworCV9fd2FrZV91cF9jb21tb25fbG9jayh3cV9oZWFkLCBtb2RlLCBucl9leGNsdXNpdmUs
IDAsIGtleSk7CiB9CiBFWFBPUlRfU1lNQk9MKF9fd2FrZV91cCk7CiAKQEAgLTEwMywxMyArMTUy
LDEzIEBAIEVYUE9SVF9TWU1CT0woX193YWtlX3VwKTsKICAqLwogdm9pZCBfX3dha2VfdXBfbG9j
a2VkKHN0cnVjdCB3YWl0X3F1ZXVlX2hlYWQgKndxX2hlYWQsIHVuc2lnbmVkIGludCBtb2RlLCBp
bnQgbnIpCiB7Ci0JX193YWtlX3VwX2NvbW1vbih3cV9oZWFkLCBtb2RlLCBuciwgMCwgTlVMTCk7
CisJX193YWtlX3VwX2NvbW1vbih3cV9oZWFkLCBtb2RlLCBuciwgMCwgTlVMTCwgTlVMTCk7CiB9
CiBFWFBPUlRfU1lNQk9MX0dQTChfX3dha2VfdXBfbG9ja2VkKTsKIAogdm9pZCBfX3dha2VfdXBf
bG9ja2VkX2tleShzdHJ1Y3Qgd2FpdF9xdWV1ZV9oZWFkICp3cV9oZWFkLCB1bnNpZ25lZCBpbnQg
bW9kZSwgdm9pZCAqa2V5KQogewotCV9fd2FrZV91cF9jb21tb24od3FfaGVhZCwgbW9kZSwgMSwg
MCwga2V5KTsKKwlfX3dha2VfdXBfY29tbW9uKHdxX2hlYWQsIG1vZGUsIDEsIDAsIGtleSwgTlVM
TCk7CiB9CiBFWFBPUlRfU1lNQk9MX0dQTChfX3dha2VfdXBfbG9ja2VkX2tleSk7CiAKQEAgLTEz
Myw3ICsxODIsNiBAQCBFWFBPUlRfU1lNQk9MX0dQTChfX3dha2VfdXBfbG9ja2VkX2tleSk7CiB2
b2lkIF9fd2FrZV91cF9zeW5jX2tleShzdHJ1Y3Qgd2FpdF9xdWV1ZV9oZWFkICp3cV9oZWFkLCB1
bnNpZ25lZCBpbnQgbW9kZSwKIAkJCWludCBucl9leGNsdXNpdmUsIHZvaWQgKmtleSkKIHsKLQl1
bnNpZ25lZCBsb25nIGZsYWdzOwogCWludCB3YWtlX2ZsYWdzID0gMTsgLyogWFhYIFdGX1NZTkMg
Ki8KIAogCWlmICh1bmxpa2VseSghd3FfaGVhZCkpCkBAIC0xNDIsOSArMTkwLDcgQEAgdm9pZCBf
X3dha2VfdXBfc3luY19rZXkoc3RydWN0IHdhaXRfcXVldWVfaGVhZCAqd3FfaGVhZCwgdW5zaWdu
ZWQgaW50IG1vZGUsCiAJaWYgKHVubGlrZWx5KG5yX2V4Y2x1c2l2ZSAhPSAxKSkKIAkJd2FrZV9m
bGFncyA9IDA7CiAKLQlzcGluX2xvY2tfaXJxc2F2ZSgmd3FfaGVhZC0+bG9jaywgZmxhZ3MpOwot
CV9fd2FrZV91cF9jb21tb24od3FfaGVhZCwgbW9kZSwgbnJfZXhjbHVzaXZlLCB3YWtlX2ZsYWdz
LCBrZXkpOwotCXNwaW5fdW5sb2NrX2lycXJlc3RvcmUoJndxX2hlYWQtPmxvY2ssIGZsYWdzKTsK
KwlfX3dha2VfdXBfY29tbW9uX2xvY2sod3FfaGVhZCwgbW9kZSwgbnJfZXhjbHVzaXZlLCB3YWtl
X2ZsYWdzLCBrZXkpOwogfQogRVhQT1JUX1NZTUJPTF9HUEwoX193YWtlX3VwX3N5bmNfa2V5KTsK
IAo=
--001a11c1691e4fd90e0557741aa4--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
