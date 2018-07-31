Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f71.google.com (mail-pl0-f71.google.com [209.85.160.71])
	by kanga.kvack.org (Postfix) with ESMTP id CFE636B000D
	for <linux-mm@kvack.org>; Mon, 30 Jul 2018 23:26:21 -0400 (EDT)
Received: by mail-pl0-f71.google.com with SMTP id d22-v6so10391571pls.4
        for <linux-mm@kvack.org>; Mon, 30 Jul 2018 20:26:21 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id v4-v6sor3420785pga.346.2018.07.30.20.26.20
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 30 Jul 2018 20:26:20 -0700 (PDT)
Date: Mon, 30 Jul 2018 20:26:10 -0700 (PDT)
From: Hugh Dickins <hughd@google.com>
Subject: Re: Linux 4.18-rc7
In-Reply-To: <CA+55aFx3qR1FW0T3na25NrwLZAvpOdUEUJa879CnaJT2ZPfhkg@mail.gmail.com>
Message-ID: <alpine.LSU.2.11.1807301940460.5904@eggly.anvils>
References: <CA+55aFxpFefwVdTGVML99PSFUqwpJXPx5LVCA3D=g2t2_QLNsA@mail.gmail.com> <CAMi1Hd0fJuAgP09_KkbjyGwszOXmxcPybKyBxP3U1y5JUqxxSw@mail.gmail.com> <20180730130134.yvn5tcmoavuxtwt5@kshutemo-mobl1> <CA+55aFwxwCPZs=h5wy-5PELwfBVuTETm+wuZB5cM2SDoXJi68g@mail.gmail.com>
 <alpine.LSU.2.11.1807301410470.4805@eggly.anvils> <CA+55aFx3qR1FW0T3na25NrwLZAvpOdUEUJa879CnaJT2ZPfhkg@mail.gmail.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Hugh Dickins <hughd@google.com>, "Kirill A. Shutemov" <kirill@shutemov.name>, Matthew Wilcox <willy@infradead.org>, Amit Pundir <amit.pundir@linaro.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Andrew Morton <akpm@linux-foundation.org>, Dmitry Vyukov <dvyukov@google.com>, Oleg Nesterov <oleg@redhat.com>, Andrea Arcangeli <aarcange@redhat.com>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, John Stultz <john.stultz@linaro.org>, linux-mm <linux-mm@kvack.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, youling257@gmail.com

On Mon, 30 Jul 2018, Linus Torvalds wrote:
> On Mon, Jul 30, 2018 at 2:53 PM Hugh Dickins <hughd@google.com> wrote:
> >
> > I have no problem with reverting -rc7's vma_is_anonymous() series.
> 
> I don't think we need to revert the whole series: I think the rest are
> all fairly obvious cleanups, and shouldn't really have any semantic
> changes.

Okay.

> 
> It's literally only that last patch in the series that then changes
> that meaning of "vm_ops". And I don't really _mind_ that last step
> either, but since we don't know exactly what it was that it broke, and
> we're past rc7, I don't think we really have any option but the revert
> it.

It took me a long time to grasp what was happening, that that last
patch bfd40eaff5ab was fixing. Not quite explained in the commit.

I think it was that by mistakenly passing the vma_is_anonymous() test,
create_huge_pmd() gave the MAP_PRIVATE kcov mapping a THP (instead of
COWing pages from kcov); which the truncate then had to split, and in
going to do so, again hit the mistaken vma_is_anonymous() test, BUG.

> 
> And if we revert it, I think we need to just remove the
> VM_BUG_ON_VMA() that it was supposed to fix. Because I do think that
> it is quite likely that the real bug is that overzealous BUG_ON(),
> since I can't see any reason why anonymous mappings should be special
> there.

Yes, that probably has to go: but it's not clear what state it leaves
us in, with an anon THP being split by a truncate, without the expected
locking; I don't remember offhand, probably a subtler bug than that BUG,
which you may or may not consider an improvement.

I fear that Kirill has not missed inserting a vma_set_anonymous() from
somewhere that it should be, but rather that zygote is working with some
special mapping which used to satisfy vma_is_anonymous(), faults supplying
backing pages, but now comes out as !vma_is_anonymous(), so do_fault()
finds !dummy_vm_ops.fault hence SIGBUS.

If that's so, perhaps dummy_vm_ops needs to be given a back-compatible
fault handler; or the driver(?) in question given vm_ops and that fault
handler. But when I say "back-compatible", I don't think it should ever
go so far as to supply a THP.

> 
> But I'm certainly also ok with re-visiting that commit later.  I just
> think that right _now_ the above is my preferred plan.
> 
> Kirill?
> 
> > I'm all for deleting that VM_BUG_ON_VMA() in zap_pmd_range(), it was
> > just a compromise with those who wanted to keep something there;
> > I don't think we even need a WARN_ON_ONCE() now.
> 
> So to me it looks like a historical check that simply doesn't
> "normally" trigger, but there's no reason I can see why we should care
> about the case it tests against.
> 
> > (It remains quite interesting how exit_mmap() does not come that way,
> > and most syscalls split the vma beforehand in vma_adjust(): it's mostly
> > about madvise(,,MADV_DONTNEED), perhaps others now, which zap ptes
> > without prior splitting.)
> 
> Well, in this case it's the ftruncate() path, which fundamentally
> doesn't split the vma at all (prior *or* later). But yes, madvise() is
> in the same boat - it doesn't change the vma at all, it just changes
> the contents of the vma.
> 
> And exit_mmap() is special because it just tears down everything.
> 
> So we do have three very distinct cases:
> 
>  (a) changing and thus splitting the vma itself (mprotect, munmap/mmap, mlock),

Yes.

> 
>  (b) not changing the vma, but changing the underlying mapping
> (truncate and madvise(MADV_DONTNEED)

Yes, though I think I would distinguish the truncate & hole-punch case
from the madvise zap case, they have different characteristics in other
ways (or did, before that awkward case of truncating an anon THP surfaced).

> 
>  (c) tearing down everything, and no locking needed because it's the
> last user (exit_mmap).

Yes; and it goes linearly from start to finish, never jumping into
the middle of a vma, so never needing to split a THP.

> 
> that are different for what I think are good reasons.
> 
>                    Linus
