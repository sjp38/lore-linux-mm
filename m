Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f71.google.com (mail-oi0-f71.google.com [209.85.218.71])
	by kanga.kvack.org (Postfix) with ESMTP id B869F2806EC
	for <linux-mm@kvack.org>; Tue, 22 Aug 2017 16:42:15 -0400 (EDT)
Received: by mail-oi0-f71.google.com with SMTP id x21so5841532oif.1
        for <linux-mm@kvack.org>; Tue, 22 Aug 2017 13:42:15 -0700 (PDT)
Received: from mail-oi0-x22e.google.com (mail-oi0-x22e.google.com. [2607:f8b0:4003:c06::22e])
        by mx.google.com with ESMTPS id l144si12225289oig.201.2017.08.22.13.42.14
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 22 Aug 2017 13:42:14 -0700 (PDT)
Received: by mail-oi0-x22e.google.com with SMTP id f11so197728684oic.0
        for <linux-mm@kvack.org>; Tue, 22 Aug 2017 13:42:14 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <37D7C6CF3E00A74B8858931C1DB2F0775378A377@SHSMSX103.ccr.corp.intel.com>
References: <CA+55aFwzTMrZwh7TE_VeZt8gx5Syoop-kA=Xqs56=FkyakrM6g@mail.gmail.com>
 <37D7C6CF3E00A74B8858931C1DB2F0775378761B@SHSMSX103.ccr.corp.intel.com>
 <CA+55aFy_RNx5TQ8esjPPOKuW-o+fXbZgWapau2MHyexcAZtqsw@mail.gmail.com>
 <20170818122339.24grcbzyhnzmr4qw@techsingularity.net> <37D7C6CF3E00A74B8858931C1DB2F077537879BB@SHSMSX103.ccr.corp.intel.com>
 <20170818144622.oabozle26hasg5yo@techsingularity.net> <37D7C6CF3E00A74B8858931C1DB2F07753787AE4@SHSMSX103.ccr.corp.intel.com>
 <CA+55aFxZjjqUM4kPvNEeZahPovBHFATiwADj-iPTDN0-jnU67Q@mail.gmail.com>
 <20170818185455.qol3st2nynfa47yc@techsingularity.net> <CA+55aFwX0yrUPULrDxTWVCg5c6DKh-yCG84NXVxaptXNQ4O_kA@mail.gmail.com>
 <20170821183234.kzennaaw2zt2rbwz@techsingularity.net> <37D7C6CF3E00A74B8858931C1DB2F07753788B58@SHSMSX103.ccr.corp.intel.com>
 <37D7C6CF3E00A74B8858931C1DB2F0775378A24A@SHSMSX103.ccr.corp.intel.com>
 <CA+55aFy=4y0fq9nL2WR1x8vwzJrDOdv++r036LXpR=6Jx8jpzg@mail.gmail.com> <37D7C6CF3E00A74B8858931C1DB2F0775378A377@SHSMSX103.ccr.corp.intel.com>
From: Linus Torvalds <torvalds@linux-foundation.org>
Date: Tue, 22 Aug 2017 13:42:13 -0700
Message-ID: <CA+55aFwavpFfKNW9NVgNhLggqhii-guc5aX1X5fxrPK+==id0g@mail.gmail.com>
Subject: Re: [PATCH 1/2] sched/wait: Break up long wake list walk
Content-Type: multipart/mixed; boundary="001a113d3a32562b9405575da121"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Liang, Kan" <kan.liang@intel.com>
Cc: Mel Gorman <mgorman@techsingularity.net>, Mel Gorman <mgorman@suse.de>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Tim Chen <tim.c.chen@linux.intel.com>, Peter Zijlstra <peterz@infradead.org>, Ingo Molnar <mingo@elte.hu>, Andi Kleen <ak@linux.intel.com>, Andrew Morton <akpm@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, Jan Kara <jack@suse.cz>, linux-mm <linux-mm@kvack.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>

--001a113d3a32562b9405575da121
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Tue, Aug 22, 2017 at 12:55 PM, Liang, Kan <kan.liang@intel.com> wrote:
>
>> So I propose testing the attached trivial patch.
>
> It doesn=E2=80=99t work.
> The call stack is the same.

So I would have expected the stack trace to be the same, and I would
even expect the CPU usage to be fairly similar, because you'd see
repeating from the callers (taking the fault again if the page is -
once again - being migrated).

But I was hoping that the wait queues would be shorter because the
loop for the retry would be bigger.

Oh well.

I'm slightly out of ideas. Apparently the yield() worked ok (apart
from not catching all cases), and maybe we could do a version that
waits on the page bit in the non-contended case, but yields under
contention?

IOW, maybe this is the best we can do for now? Introducing that
"wait_on_page_migration()" helper might allow us to tweak this a bit
as people come up with better ideas..

And then add Tim's patch for the general worst-case just in case?

             Linus

--001a113d3a32562b9405575da121
Content-Type: text/plain; charset="US-ASCII"; name="patch.diff"
Content-Disposition: attachment; filename="patch.diff"
Content-Transfer-Encoding: base64
X-Attachment-Id: f_j6o22s610

IGluY2x1ZGUvbGludXgvcGFnZW1hcC5oIHwgNyArKysrKysrCiBtbS9maWxlbWFwLmMgICAgICAg
ICAgICB8IDkgKysrKysrKysrCiBtbS9odWdlX21lbW9yeS5jICAgICAgICB8IDIgKy0KIG1tL21p
Z3JhdGUuYyAgICAgICAgICAgIHwgMiArLQogNCBmaWxlcyBjaGFuZ2VkLCAxOCBpbnNlcnRpb25z
KCspLCAyIGRlbGV0aW9ucygtKQoKZGlmZiAtLWdpdCBhL2luY2x1ZGUvbGludXgvcGFnZW1hcC5o
IGIvaW5jbHVkZS9saW51eC9wYWdlbWFwLmgKaW5kZXggNzliMzZmNTdjM2JhLi5kMDQ1MWYyNTAx
YmEgMTAwNjQ0Ci0tLSBhL2luY2x1ZGUvbGludXgvcGFnZW1hcC5oCisrKyBiL2luY2x1ZGUvbGlu
dXgvcGFnZW1hcC5oCkBAIC01MDMsNiArNTAzLDcgQEAgc3RhdGljIGlubGluZSBpbnQgbG9ja19w
YWdlX29yX3JldHJ5KHN0cnVjdCBwYWdlICpwYWdlLCBzdHJ1Y3QgbW1fc3RydWN0ICptbSwKICAq
LwogZXh0ZXJuIHZvaWQgd2FpdF9vbl9wYWdlX2JpdChzdHJ1Y3QgcGFnZSAqcGFnZSwgaW50IGJp
dF9ucik7CiBleHRlcm4gaW50IHdhaXRfb25fcGFnZV9iaXRfa2lsbGFibGUoc3RydWN0IHBhZ2Ug
KnBhZ2UsIGludCBiaXRfbnIpOworZXh0ZXJuIHZvaWQgd2FpdF9vbl9wYWdlX2JpdF9vcl95aWVs
ZChzdHJ1Y3QgcGFnZSAqcGFnZSwgaW50IGJpdF9ucik7CiAKIC8qIAogICogV2FpdCBmb3IgYSBw
YWdlIHRvIGJlIHVubG9ja2VkLgpAQCAtNTI0LDYgKzUyNSwxMiBAQCBzdGF0aWMgaW5saW5lIGlu
dCB3YWl0X29uX3BhZ2VfbG9ja2VkX2tpbGxhYmxlKHN0cnVjdCBwYWdlICpwYWdlKQogCXJldHVy
biB3YWl0X29uX3BhZ2VfYml0X2tpbGxhYmxlKGNvbXBvdW5kX2hlYWQocGFnZSksIFBHX2xvY2tl
ZCk7CiB9CiAKK3N0YXRpYyBpbmxpbmUgdm9pZCB3YWl0X29uX3BhZ2VfbWlncmF0aW9uKHN0cnVj
dCBwYWdlICpwYWdlKQoreworCWlmIChQYWdlTG9ja2VkKHBhZ2UpKQorCQl3YWl0X29uX3BhZ2Vf
Yml0X29yX3lpZWxkKGNvbXBvdW5kX2hlYWQocGFnZSksIFBHX2xvY2tlZCk7Cit9CisKIC8qIAog
ICogV2FpdCBmb3IgYSBwYWdlIHRvIGNvbXBsZXRlIHdyaXRlYmFjawogICovCmRpZmYgLS1naXQg
YS9tbS9maWxlbWFwLmMgYi9tbS9maWxlbWFwLmMKaW5kZXggYTQ5NzAyNDQ1Y2UwLi45ZTM0ZTc1
MDJjYWMgMTAwNjQ0Ci0tLSBhL21tL2ZpbGVtYXAuYworKysgYi9tbS9maWxlbWFwLmMKQEAgLTEw
MjYsNiArMTAyNiwxNSBAQCBpbnQgd2FpdF9vbl9wYWdlX2JpdF9raWxsYWJsZShzdHJ1Y3QgcGFn
ZSAqcGFnZSwgaW50IGJpdF9ucikKIAlyZXR1cm4gd2FpdF9vbl9wYWdlX2JpdF9jb21tb24ocSwg
cGFnZSwgYml0X25yLCBUQVNLX0tJTExBQkxFLCBmYWxzZSk7CiB9CiAKK3ZvaWQgd2FpdF9vbl9w
YWdlX2JpdF9vcl95aWVsZChzdHJ1Y3QgcGFnZSAqcGFnZSwgaW50IGJpdF9ucikKK3sKKwlpZiAo
UGFnZVdhaXRlcnMocGFnZSkpIHsKKwkJeWllbGQoKTsKKwkJcmV0dXJuOworCX0KKwl3YWl0X29u
X3BhZ2VfYml0KHBhZ2UsIGJpdF9ucik7Cit9CisKIC8qKgogICogYWRkX3BhZ2Vfd2FpdF9xdWV1
ZSAtIEFkZCBhbiBhcmJpdHJhcnkgd2FpdGVyIHRvIGEgcGFnZSdzIHdhaXQgcXVldWUKICAqIEBw
YWdlOiBQYWdlIGRlZmluaW5nIHRoZSB3YWl0IHF1ZXVlIG9mIGludGVyZXN0CmRpZmYgLS1naXQg
YS9tbS9odWdlX21lbW9yeS5jIGIvbW0vaHVnZV9tZW1vcnkuYwppbmRleCA5MDczMWUzYjdlNTgu
LmQ5NGU4OWNhOWYwYyAxMDA2NDQKLS0tIGEvbW0vaHVnZV9tZW1vcnkuYworKysgYi9tbS9odWdl
X21lbW9yeS5jCkBAIC0xNDQzLDcgKzE0NDMsNyBAQCBpbnQgZG9faHVnZV9wbWRfbnVtYV9wYWdl
KHN0cnVjdCB2bV9mYXVsdCAqdm1mLCBwbWRfdCBwbWQpCiAJCWlmICghZ2V0X3BhZ2VfdW5sZXNz
X3plcm8ocGFnZSkpCiAJCQlnb3RvIG91dF91bmxvY2s7CiAJCXNwaW5fdW5sb2NrKHZtZi0+cHRs
KTsKLQkJd2FpdF9vbl9wYWdlX2xvY2tlZChwYWdlKTsKKwkJd2FpdF9vbl9wYWdlX21pZ3JhdGlv
bihwYWdlKTsKIAkJcHV0X3BhZ2UocGFnZSk7CiAJCWdvdG8gb3V0OwogCX0KZGlmZiAtLWdpdCBh
L21tL21pZ3JhdGUuYyBiL21tL21pZ3JhdGUuYwppbmRleCBlODRlZWI0ZTQzNTYuLmYwYWE2OGY3
NzVhYSAxMDA2NDQKLS0tIGEvbW0vbWlncmF0ZS5jCisrKyBiL21tL21pZ3JhdGUuYwpAQCAtMzA4
LDcgKzMwOCw3IEBAIHZvaWQgX19taWdyYXRpb25fZW50cnlfd2FpdChzdHJ1Y3QgbW1fc3RydWN0
ICptbSwgcHRlX3QgKnB0ZXAsCiAJaWYgKCFnZXRfcGFnZV91bmxlc3NfemVybyhwYWdlKSkKIAkJ
Z290byBvdXQ7CiAJcHRlX3VubWFwX3VubG9jayhwdGVwLCBwdGwpOwotCXdhaXRfb25fcGFnZV9s
b2NrZWQocGFnZSk7CisJd2FpdF9vbl9wYWdlX21pZ3JhdGlvbihwYWdlKTsKIAlwdXRfcGFnZShw
YWdlKTsKIAlyZXR1cm47CiBvdXQ6Cg==
--001a113d3a32562b9405575da121--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
