Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f69.google.com (mail-it0-f69.google.com [209.85.214.69])
	by kanga.kvack.org (Postfix) with ESMTP id DC89E6B0006
	for <linux-mm@kvack.org>; Wed,  1 Aug 2018 16:56:31 -0400 (EDT)
Received: by mail-it0-f69.google.com with SMTP id r184-v6so100038ith.0
        for <linux-mm@kvack.org>; Wed, 01 Aug 2018 13:56:31 -0700 (PDT)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id h6-v6sor3770448ioq.55.2018.08.01.13.56.30
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 01 Aug 2018 13:56:30 -0700 (PDT)
MIME-Version: 1.0
References: <alpine.LSU.2.11.1807301410470.4805@eggly.anvils>
 <CA+55aFx3qR1FW0T3na25NrwLZAvpOdUEUJa879CnaJT2ZPfhkg@mail.gmail.com>
 <alpine.LSU.2.11.1807301940460.5904@eggly.anvils> <CALAqxLU3cmu4g+HaB6A7=VhY-hW=d9e68EZ=_4JiwX_BigzjPQ@mail.gmail.com>
 <CAMi1Hd0-2eDod4HiBifKCxY0cUUEW_A-yv7sZ7GRgL0whWQt+w@mail.gmail.com>
 <CA+55aFx=-tHXjv3gv4W=xYwM+VOHJQE5q5VyihkPK7s560x-vQ@mail.gmail.com>
 <20180731170328.ocb5oikwhwtkyzrj@kshutemo-mobl1> <20180731174349.GA12944@agluck-desk>
 <CA+55aFxJpJvcYKos-sVTsn9q4wK0-m4up1SXrcqfbXHKxaKxjg@mail.gmail.com>
 <CA+55aFz0eKks=v872LA-tDx4qcmBtxTYXbeztZcWbgx6SeQHNg@mail.gmail.com> <20180801205156.zv45fcveexwa2dqs@kshutemo-mobl1>
In-Reply-To: <20180801205156.zv45fcveexwa2dqs@kshutemo-mobl1>
From: Linus Torvalds <torvalds@linux-foundation.org>
Date: Wed, 1 Aug 2018 13:56:19 -0700
Message-ID: <CA+55aFzDxsUU8jUyJN7J35TfeUh7n2xRDjEbW-A-2Fq1CDYQ0w@mail.gmail.com>
Subject: Re: Linux 4.18-rc7
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill@shutemov.name>
Cc: Tony Luck <tony.luck@intel.com>, Amit Pundir <amit.pundir@linaro.org>, John Stultz <john.stultz@linaro.org>, Hugh Dickins <hughd@google.com>, Matthew Wilcox <willy@infradead.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Andrew Morton <akpm@linux-foundation.org>, Dmitry Vyukov <dvyukov@google.com>, Oleg Nesterov <oleg@redhat.com>, Andrea Arcangeli <aarcange@redhat.com>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, linux-mm <linux-mm@kvack.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, youling 257 <youling257@gmail.com>, Joel Fernandes <joelaf@google.com>, Colin Cross <ccross@google.com>

On Wed, Aug 1, 2018 at 1:52 PM Kirill A. Shutemov <kirill@shutemov.name> wrote:
>
> Is there a reason why we pass vma to flush_tlb_range?

Yes. It's even in that patch.

The fact is, real MM users *have* a vma, and passing it in to the TLB
flushing is the right thing to do. That allows architectures that care
(mainly powerpc, I think) to notice that "hey, this range only had
execute permissions, so I only need to flush the ITLB".

The people who use tlb_flush_range() any other way are doing an
arch-specific hack.  It's not how tlb_flush_range() was defined, and
it's not how you can use it in general.

> It's not obvious to me what information from VMA can be useful for an
> implementation.

See the patch I sent, which had this as part of it:

-                * XXX fix me: flush_tlb_range() should take an mm
pointer instead of a
-                * vma pointer.
+                * flush_tlb_range() takes a vma instead of a mm pointer because
+                * some architectures want the vm_flags for ITLB/DTLB flush.

because I wanted to educate people about why the interface was what it
was, and the "fixme" was bogus shit.

> In longer term we can change the interface to take mm instead of vma.

FUCK NO!

Goddammit, read the code, or read the patch. The places ytou added
those broken vma_init() calls to were architecture-specific hacks.

Those architecture-specific hacks do not get to screw up the design
for everybody else.

                     Linus
