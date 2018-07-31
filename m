Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f72.google.com (mail-it0-f72.google.com [209.85.214.72])
	by kanga.kvack.org (Postfix) with ESMTP id D1B446B0007
	for <linux-mm@kvack.org>; Mon, 30 Jul 2018 21:01:39 -0400 (EDT)
Received: by mail-it0-f72.google.com with SMTP id g4-v6so1131151itf.6
        for <linux-mm@kvack.org>; Mon, 30 Jul 2018 18:01:39 -0700 (PDT)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id p3-v6sor399413ita.27.2018.07.30.18.01.38
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 30 Jul 2018 18:01:38 -0700 (PDT)
MIME-Version: 1.0
References: <CA+55aFxpFefwVdTGVML99PSFUqwpJXPx5LVCA3D=g2t2_QLNsA@mail.gmail.com>
 <CAMi1Hd0fJuAgP09_KkbjyGwszOXmxcPybKyBxP3U1y5JUqxxSw@mail.gmail.com>
 <20180730130134.yvn5tcmoavuxtwt5@kshutemo-mobl1> <CA+55aFwxwCPZs=h5wy-5PELwfBVuTETm+wuZB5cM2SDoXJi68g@mail.gmail.com>
 <alpine.LSU.2.11.1807301410470.4805@eggly.anvils>
In-Reply-To: <alpine.LSU.2.11.1807301410470.4805@eggly.anvils>
From: Linus Torvalds <torvalds@linux-foundation.org>
Date: Mon, 30 Jul 2018 18:01:26 -0700
Message-ID: <CA+55aFx3qR1FW0T3na25NrwLZAvpOdUEUJa879CnaJT2ZPfhkg@mail.gmail.com>
Subject: Re: Linux 4.18-rc7
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hugh Dickins <hughd@google.com>
Cc: "Kirill A. Shutemov" <kirill@shutemov.name>, Matthew Wilcox <willy@infradead.org>, Amit Pundir <amit.pundir@linaro.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Andrew Morton <akpm@linux-foundation.org>, Dmitry Vyukov <dvyukov@google.com>, Oleg Nesterov <oleg@redhat.com>, Andrea Arcangeli <aarcange@redhat.com>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, John Stultz <john.stultz@linaro.org>, linux-mm <linux-mm@kvack.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, youling257@gmail.com

On Mon, Jul 30, 2018 at 2:53 PM Hugh Dickins <hughd@google.com> wrote:
>
> I have no problem with reverting -rc7's vma_is_anonymous() series.

I don't think we need to revert the whole series: I think the rest are
all fairly obvious cleanups, and shouldn't really have any semantic
changes.

It's literally only that last patch in the series that then changes
that meaning of "vm_ops". And I don't really _mind_ that last step
either, but since we don't know exactly what it was that it broke, and
we're past rc7, I don't think we really have any option but the revert
it.

And if we revert it, I think we need to just remove the
VM_BUG_ON_VMA() that it was supposed to fix. Because I do think that
it is quite likely that the real bug is that overzealous BUG_ON(),
since I can't see any reason why anonymous mappings should be special
there.

But I'm certainly also ok with re-visiting that commit later.  I just
think that right _now_ the above is my preferred plan.

Kirill?

> I'm all for deleting that VM_BUG_ON_VMA() in zap_pmd_range(), it was
> just a compromise with those who wanted to keep something there;
> I don't think we even need a WARN_ON_ONCE() now.

So to me it looks like a historical check that simply doesn't
"normally" trigger, but there's no reason I can see why we should care
about the case it tests against.

> (It remains quite interesting how exit_mmap() does not come that way,
> and most syscalls split the vma beforehand in vma_adjust(): it's mostly
> about madvise(,,MADV_DONTNEED), perhaps others now, which zap ptes
> without prior splitting.)

Well, in this case it's the ftruncate() path, which fundamentally
doesn't split the vma at all (prior *or* later). But yes, madvise() is
in the same boat - it doesn't change the vma at all, it just changes
the contents of the vma.

And exit_mmap() is special because it just tears down everything.

So we do have three very distinct cases:

 (a) changing and thus splitting the vma itself (mprotect, munmap/mmap, mlock),

 (b) not changing the vma, but changing the underlying mapping
(truncate and madvise(MADV_DONTNEED)

 (c) tearing down everything, and no locking needed because it's the
last user (exit_mmap).

that are different for what I think are good reasons.

                   Linus
