Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f198.google.com (mail-io0-f198.google.com [209.85.223.198])
	by kanga.kvack.org (Postfix) with ESMTP id 8DAED6B0005
	for <linux-mm@kvack.org>; Wed,  1 Aug 2018 13:15:18 -0400 (EDT)
Received: by mail-io0-f198.google.com with SMTP id y4-v6so14402317iol.2
        for <linux-mm@kvack.org>; Wed, 01 Aug 2018 10:15:18 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id e133-v6sor5630849ioa.63.2018.08.01.10.15.16
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 01 Aug 2018 10:15:17 -0700 (PDT)
MIME-Version: 1.0
References: <CAMi1Hd0fJuAgP09_KkbjyGwszOXmxcPybKyBxP3U1y5JUqxxSw@mail.gmail.com>
 <20180730130134.yvn5tcmoavuxtwt5@kshutemo-mobl1> <CA+55aFwxwCPZs=h5wy-5PELwfBVuTETm+wuZB5cM2SDoXJi68g@mail.gmail.com>
 <alpine.LSU.2.11.1807301410470.4805@eggly.anvils> <CA+55aFx3qR1FW0T3na25NrwLZAvpOdUEUJa879CnaJT2ZPfhkg@mail.gmail.com>
 <alpine.LSU.2.11.1807301940460.5904@eggly.anvils> <CALAqxLU3cmu4g+HaB6A7=VhY-hW=d9e68EZ=_4JiwX_BigzjPQ@mail.gmail.com>
 <CAMi1Hd0-2eDod4HiBifKCxY0cUUEW_A-yv7sZ7GRgL0whWQt+w@mail.gmail.com>
 <CA+55aFx=-tHXjv3gv4W=xYwM+VOHJQE5q5VyihkPK7s560x-vQ@mail.gmail.com>
 <20180731170328.ocb5oikwhwtkyzrj@kshutemo-mobl1> <20180731174349.GA12944@agluck-desk>
In-Reply-To: <20180731174349.GA12944@agluck-desk>
From: Linus Torvalds <torvalds@linux-foundation.org>
Date: Wed, 1 Aug 2018 10:15:05 -0700
Message-ID: <CA+55aFxJpJvcYKos-sVTsn9q4wK0-m4up1SXrcqfbXHKxaKxjg@mail.gmail.com>
Subject: Re: Linux 4.18-rc7
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tony Luck <tony.luck@intel.com>
Cc: "Kirill A. Shutemov" <kirill@shutemov.name>, Amit Pundir <amit.pundir@linaro.org>, John Stultz <john.stultz@linaro.org>, Hugh Dickins <hughd@google.com>, Matthew Wilcox <willy@infradead.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Andrew Morton <akpm@linux-foundation.org>, Dmitry Vyukov <dvyukov@google.com>, Oleg Nesterov <oleg@redhat.com>, Andrea Arcangeli <aarcange@redhat.com>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, linux-mm <linux-mm@kvack.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, youling 257 <youling257@gmail.com>, Joel Fernandes <joelaf@google.com>, Colin Cross <ccross@google.com>

On Tue, Jul 31, 2018 at 10:43 AM Luck, Tony <tony.luck@intel.com> wrote:
>
> On Tue, Jul 31, 2018 at 08:03:28PM +0300, Kirill A. Shutemov wrote:
> > But it's not the only issue unfortunately. Tony reported issue with
> > booting ia64 with the patch. I have no clue why. I rechecked everything
> > ia64-specific and looks fine to me. :-/
>
> If I just revert bfd40eaff5ab ("mm: fix vma_is_anonymous() false-positives")
> then ia64 boots again.

Ok, I'd love to have more information about this, but I'm assuming
that Tony isn't running some odd ia64 version of Android, so there's
definitely something else than just the ashmem thing going on. Either
it's some odd ia64-specific special vma, or it's just something
triggered on an ia64 boot that nobody else noticed or cared about.

And I was just going to do the final revert and started this email to
say so, when I looked at the obvious candidate: the
ia64_init_addr_space() function. Trivially fixed.

But as I was doing that, I also noticed another problem with the vma
series: the vma_init() conversion of automatic variables is buggy.
Commit 2c4541e24c55 ("mm: use vma_init() to initialize VMAs on stack
and data segments") is really bad, because it never grew the memset()
that was discussed, and the patch that was applied was the original
one - so vma_init() only initializes a couple of fields. As a result,
doing things like this:

-       struct vm_area_struct vma = { .vm_mm = mm };
+       struct vm_area_struct vma;

+       vma_init(&vma, mm);

is just completely wrong, because it actually initializes much less
than it used to, and leaves most of the vma filled with random stack
garbage. In particular, it now fills with garbage the fields that TLB
flushing really can care about: things like vm_flags that says "is
this perhaps an executable-only mapping that only needs to flush the
ITLB?"

I don't actually believe that we should do vma_init() on those
on-stack vma's anyway, since they aren't "real" vma's. They are
literally crafted just for TLB flushing - filling in the vm_mm (and
sometimes vm_flags) pointers so that the TLB flushing knows what to
do.

So using "vma_init()" on them is actively detrimental as things stand
right now. The reason I looked at them was that I was trying to see
who actually uses "vm_area_alloc()" and "vma_init()" right now that
would be affected by that commit bfd40eaff5ab ("mm: fix
vma_is_anonymous() false-positives") outside of actual
honest-to-goodness device file mmaps.

Anyway, the upshot of all this is that I think I know what the ia64
problem was, and John sent the patch for the ashmem case, and I'm
going to hold off reverting that vma_is_anonymous() false-positives
commit after all.

I'm still unhappy about the vma_init() ones, and I have not decided
how to go with those. Either the memset() in vma_init(), or just
reverting the (imho unnecessary) commit 2c4541e24c55. Kirill, Andrew,
comments?

Tony, can you please double-check my commit ebad825cdd4e ("ia64: mark
special ia64 memory areas anonymous") fixes things for  you? I didn't
even compile it, but it really looks so obvious that I just committed
it directly. It's not pushed out yet (I'm doing the normal full build
test because of the ashmem commit first), but it should be out in
about 20 minutes when my testing has finished.

I'd like to get this sorted out asap, although at this point I still
think that I'll have to do an rc8 even though I feel like we may have
caught everything.

                        Linus
