Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qa0-f49.google.com (mail-qa0-f49.google.com [209.85.216.49])
	by kanga.kvack.org (Postfix) with ESMTP id 7DB266B006E
	for <linux-mm@kvack.org>; Wed, 17 Dec 2014 11:28:25 -0500 (EST)
Received: by mail-qa0-f49.google.com with SMTP id s7so11342721qap.36
        for <linux-mm@kvack.org>; Wed, 17 Dec 2014 08:28:25 -0800 (PST)
Received: from mail-qg0-x229.google.com (mail-qg0-x229.google.com. [2607:f8b0:400d:c04::229])
        by mx.google.com with ESMTPS id 18si5054403qgm.109.2014.12.17.08.28.23
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Wed, 17 Dec 2014 08:28:24 -0800 (PST)
Received: by mail-qg0-f41.google.com with SMTP id j5so12097014qga.0
        for <linux-mm@kvack.org>; Wed, 17 Dec 2014 08:28:23 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20141217100810.GA3461@arm.com>
References: <5490A5F8.6050504@sr71.net>
	<20141217100810.GA3461@arm.com>
Date: Wed, 17 Dec 2014 08:28:23 -0800
Message-ID: <CA+55aFyVxOw0upa=At6MmiNYEHzfPz4rE5bZUBCs9h4vKGh1iA@mail.gmail.com>
Subject: Re: post-3.18 performance regression in TLB flushing code
From: Linus Torvalds <torvalds@linux-foundation.org>
Content-Type: multipart/mixed; boundary=001a11c13d36e6ce28050a6bf638
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Will Deacon <will.deacon@arm.com>
Cc: Dave Hansen <dave@sr71.net>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Peter Zijlstra <peterz@infradead.org>, Russell King - ARM Linux <linux@arm.linux.org.uk>, Michal Simek <monstr@monstr.eu>, LKML <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>

--001a11c13d36e6ce28050a6bf638
Content-Type: text/plain; charset=UTF-8

On Wed, Dec 17, 2014 at 2:08 AM, Will Deacon <will.deacon@arm.com> wrote:
>
> I think there are a couple of things you could try to see if that 2% comes
> back:
>
>   * Revert the patch and try the one here [1] instead (which only does part
>     (1) of the above).
>
> -- or --
>
>   * Instead of adding the tlb->end check to tlb_flush_mmu, add it to
>     tlb_flush_mmu_free

or just move the check back to tlb_flush_mmu() where it belongs.

I don't see why you moved it to "tlb_flush_mmu_tlbonly()" in the first
place, or why you'd now want to add it to tlb_flush_mmu_free().

Both of those helper functions have two callers:

 - tlb_flush_mmu(). Doing it here (instead of in the helper functions)
is the right thing to do

 - the "force_flush" case: we know we have added at least one page to
the TLB state so checking for it is pointless.

So I'm not seeing why you wanted to do it in tlb_flush_mmu_tlbonly(),
and now add it to tlb_flush_mmu_free(). That seems bogus.

So why not just this trivial patch, to make the logic be the same it
used to be (just using "end > 0" instead of the old "need_flush")?

                           Linus

--001a11c13d36e6ce28050a6bf638
Content-Type: text/plain; charset=US-ASCII; name="patch.diff"
Content-Disposition: attachment; filename="patch.diff"
Content-Transfer-Encoding: base64
X-Attachment-Id: f_i3swvmfa0

IG1tL21lbW9yeS5jIHwgNiArKystLS0KIDEgZmlsZSBjaGFuZ2VkLCAzIGluc2VydGlvbnMoKyks
IDMgZGVsZXRpb25zKC0pCgpkaWZmIC0tZ2l0IGEvbW0vbWVtb3J5LmMgYi9tbS9tZW1vcnkuYwpp
bmRleCBjM2I5MDk3MjUxYzUuLjZlZmUzNmE5OThiYSAxMDA2NDQKLS0tIGEvbW0vbWVtb3J5LmMK
KysrIGIvbW0vbWVtb3J5LmMKQEAgLTIzNSw5ICsyMzUsNiBAQCB2b2lkIHRsYl9nYXRoZXJfbW11
KHN0cnVjdCBtbXVfZ2F0aGVyICp0bGIsIHN0cnVjdCBtbV9zdHJ1Y3QgKm1tLCB1bnNpZ25lZCBs
b25nCiAKIHN0YXRpYyB2b2lkIHRsYl9mbHVzaF9tbXVfdGxib25seShzdHJ1Y3QgbW11X2dhdGhl
ciAqdGxiKQogewotCWlmICghdGxiLT5lbmQpCi0JCXJldHVybjsKLQogCXRsYl9mbHVzaCh0bGIp
OwogCW1tdV9ub3RpZmllcl9pbnZhbGlkYXRlX3JhbmdlKHRsYi0+bW0sIHRsYi0+c3RhcnQsIHRs
Yi0+ZW5kKTsKICNpZmRlZiBDT05GSUdfSEFWRV9SQ1VfVEFCTEVfRlJFRQpAQCAtMjU5LDYgKzI1
Niw5IEBAIHN0YXRpYyB2b2lkIHRsYl9mbHVzaF9tbXVfZnJlZShzdHJ1Y3QgbW11X2dhdGhlciAq
dGxiKQogCiB2b2lkIHRsYl9mbHVzaF9tbXUoc3RydWN0IG1tdV9nYXRoZXIgKnRsYikKIHsKKwlp
ZiAoIXRsYi0+ZW5kKQorCQlyZXR1cm47CisKIAl0bGJfZmx1c2hfbW11X3RsYm9ubHkodGxiKTsK
IAl0bGJfZmx1c2hfbW11X2ZyZWUodGxiKTsKIH0K
--001a11c13d36e6ce28050a6bf638--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
