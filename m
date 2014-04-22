Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ve0-f176.google.com (mail-ve0-f176.google.com [209.85.128.176])
	by kanga.kvack.org (Postfix) with ESMTP id 7F5BE6B0070
	for <linux-mm@kvack.org>; Tue, 22 Apr 2014 14:57:51 -0400 (EDT)
Received: by mail-ve0-f176.google.com with SMTP id db11so10116321veb.35
        for <linux-mm@kvack.org>; Tue, 22 Apr 2014 11:57:51 -0700 (PDT)
Received: from mail-vc0-x236.google.com (mail-vc0-x236.google.com [2607:f8b0:400c:c03::236])
        by mx.google.com with ESMTPS id sw4si7031015vdc.192.2014.04.22.11.57.50
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Tue, 22 Apr 2014 11:57:50 -0700 (PDT)
Received: by mail-vc0-f182.google.com with SMTP id ib6so3168379vcb.13
        for <linux-mm@kvack.org>; Tue, 22 Apr 2014 11:57:50 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20140422180308.GA19038@redhat.com>
References: <20140422180308.GA19038@redhat.com>
Date: Tue, 22 Apr 2014 11:57:50 -0700
Message-ID: <CA+55aFxjADAB80AV6qK-b4QPzP7fgog_EyH-7dSpWVgzpZmL8Q@mail.gmail.com>
Subject: Re: 3.15rc2 hanging processes on exit.
From: Linus Torvalds <torvalds@linux-foundation.org>
Content-Type: multipart/mixed; boundary=089e0158a82a4b5d7704f7a63140
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Jones <davej@redhat.com>, Linux Kernel <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Hugh Dickins <hughd@google.com>

--089e0158a82a4b5d7704f7a63140
Content-Type: text/plain; charset=UTF-8

On Tue, Apr 22, 2014 at 11:03 AM, Dave Jones <davej@redhat.com> wrote:
> I've got a test box that's running my fuzzer that is in an odd state.
> The processes are about to end, but they don't seem to be making any
> progress.  They've been spinning in the same state for a few hours now..
>
> perf top -a is showing a lot of time is being spent in page_fault and bad_gs
>
> there's a large trace file here from the function tracer:
> http://codemonkey.org.uk/junk/trace.out

The trace says that it's one of the infinite loops that do

 - cmpxchg_futex_value_locked() fails
 - we do fault_in_user_writeable(FAULT_FLAG_WRITE) and that succeeds
 - so we try again

So it implies that handle_mm_fault() returned without VM_FAULT_ERROR,
but the page still isn't actually writable.

And to me that smells like (vm_flags & VM_WRITE) isn't set. We'll
fault in the page all right, but the resulting page table entry still
isn't writable.

Are you testing anything new? Or is this strictly new to 3.15? The
only thing in this area we do differently is commit cda540ace6a1 ("mm:
get_user_pages(write,force) refuse to COW in shared areas"), but
fault_in_user_writeable() never used the force bit afaik. Adding Hugh
just in case.

So I think we should make fault_in_user_writeable() just check the
vm_flags. Something like the attached (UNTESTED!) patch.

Guys? Comments?

                    Linus

--089e0158a82a4b5d7704f7a63140
Content-Type: text/plain; charset=US-ASCII; name="patch.diff"
Content-Disposition: attachment; filename="patch.diff"
Content-Transfer-Encoding: base64
X-Attachment-Id: f_hubk1h2i0

IG1tL21lbW9yeS5jIHwgNSArKysrKwogMSBmaWxlIGNoYW5nZWQsIDUgaW5zZXJ0aW9ucygrKQoK
ZGlmZiAtLWdpdCBhL21tL21lbW9yeS5jIGIvbW0vbWVtb3J5LmMKaW5kZXggZDBmMGJlZjNiZTQ4
Li45MWEzZTg0ODc0NWQgMTAwNjQ0Ci0tLSBhL21tL21lbW9yeS5jCisrKyBiL21tL21lbW9yeS5j
CkBAIC0xOTU1LDEyICsxOTU1LDE3IEBAIGludCBmaXh1cF91c2VyX2ZhdWx0KHN0cnVjdCB0YXNr
X3N0cnVjdCAqdHNrLCBzdHJ1Y3QgbW1fc3RydWN0ICptbSwKIAkJICAgICB1bnNpZ25lZCBsb25n
IGFkZHJlc3MsIHVuc2lnbmVkIGludCBmYXVsdF9mbGFncykKIHsKIAlzdHJ1Y3Qgdm1fYXJlYV9z
dHJ1Y3QgKnZtYTsKKwl1bnNpZ25lZCB2bV9mbGFnczsKIAlpbnQgcmV0OwogCiAJdm1hID0gZmlu
ZF9leHRlbmRfdm1hKG1tLCBhZGRyZXNzKTsKIAlpZiAoIXZtYSB8fCBhZGRyZXNzIDwgdm1hLT52
bV9zdGFydCkKIAkJcmV0dXJuIC1FRkFVTFQ7CiAKKwl2bV9mbGFncyA9IChmYXVsdF9mbGFncyAm
IEZBVUxUX0ZMQUdfV1JJVEUpID8gVk1fV1JJVEUgOiBWTV9SRUFEOworCWlmICghKHZtX2ZsYWdz
ICYgdm1hLT52bV9mbGFncykpCisJCXJldHVybiAtRUZBVUxUOworCiAJcmV0ID0gaGFuZGxlX21t
X2ZhdWx0KG1tLCB2bWEsIGFkZHJlc3MsIGZhdWx0X2ZsYWdzKTsKIAlpZiAocmV0ICYgVk1fRkFV
TFRfRVJST1IpIHsKIAkJaWYgKHJldCAmIFZNX0ZBVUxUX09PTSkK
--089e0158a82a4b5d7704f7a63140--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
