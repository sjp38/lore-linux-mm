Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f200.google.com (mail-io0-f200.google.com [209.85.223.200])
	by kanga.kvack.org (Postfix) with ESMTP id CA5726B0003
	for <linux-mm@kvack.org>; Mon, 21 May 2018 20:38:19 -0400 (EDT)
Received: by mail-io0-f200.google.com with SMTP id h70-v6so13441229iof.10
        for <linux-mm@kvack.org>; Mon, 21 May 2018 17:38:19 -0700 (PDT)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id d72-v6sor6655197itb.110.2018.05.21.17.38.18
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 21 May 2018 17:38:18 -0700 (PDT)
MIME-Version: 1.0
References: <aacd607f-4a0d-2b0a-d8d9-b57c686d24fc@intel.com>
 <CAKOZuetDX905PeLt5cs7e_maSeKHrP0DgM1Kr3vvOb-+n=a7Gw@mail.gmail.com>
 <e6bdfa05-fa80-41d1-7b1d-51cf7e4ac9a1@intel.com> <CAKOZuev=Pa6FkvxTPbeA1CcYG+oF2JM+JVL5ELHLZ--7wyr++g@mail.gmail.com>
 <20eeca79-0813-a921-8b86-4c2a0c98a1a1@intel.com> <CAKOZuesoh7svdmdNY9md3N+vWGurigDLZ5_xDjwgU=uYdKkwqg@mail.gmail.com>
 <2e7fb27e-90b4-38d2-8ae1-d575d62c5332@intel.com> <CAKOZueu8ckN1b-cYOxPhL5f7Bdq+LLRP20NK3x7Vtw79oUT3pg@mail.gmail.com>
 <20c9acc2-fbaf-f02d-19d7-2498f875e4c0@intel.com> <CAKOZuesScfm_5=2FYurY3ojdhQtcwPWY+=hayJ5cG7pQU1LP9g@mail.gmail.com>
 <20180522002239.GA4860@bombadil.infradead.org>
In-Reply-To: <20180522002239.GA4860@bombadil.infradead.org>
From: Daniel Colascione <dancol@google.com>
Date: Mon, 21 May 2018 17:38:06 -0700
Message-ID: <CAKOZuevBprpJ-fVKGCmuQz3dTMjKRfqp-cUuCyUzdkuQTQRNoQ@mail.gmail.com>
Subject: Re: Why do we let munmap fail?
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: willy@infradead.org
Cc: dave.hansen@intel.com, linux-mm@kvack.org, Tim Murray <timmurray@google.com>, Minchan Kim <minchan@kernel.org>

On Mon, May 21, 2018 at 5:22 PM Matthew Wilcox <willy@infradead.org> wrote:

> On Mon, May 21, 2018 at 05:00:47PM -0700, Daniel Colascione wrote:
> > On Mon, May 21, 2018 at 4:32 PM Dave Hansen <dave.hansen@intel.com>
wrote:
> > > I think there's still a potential dead-end here.  "Deallocation" does
> > > not always free resources.
> >
> > Sure, but the general principle applies: reserve resources when you
*can*
> > fail so that you don't fail where you can't fail.

> Umm.  OK.  But you want an mmap of 4TB to succeed, right?  That implies
> preallocating one billion * sizeof(*vma).  That's, what, dozens of
> gigabytes right there?

That's not what I'm proposing here. I'd hoped to make that clear in the
remainder of the email to which you've replied.

> I'm sympathetic to wanting to keep both vma-merging and
> unmap-anything-i-mapped working, but your proposal isn't going to fix it.

> You need to handle the attacker writing a program which mmaps 46 bits
> of address space and then munmaps alternate pages.  That program needs
> to be detected and stopped.

Let's look at why it's bad to mmap 46 bits of address space and munmap
alternate pages. It can't be that doing so would just use too much memory:
you can mmap 46 bits of address space *already* and touch each page, one by
one, until the kernel gets fed up and the OOM killer kills you.

So it's not because we'd allocate a lot of memory that having a huge VMA
tree is bad, because we already let processes allocate globs of memory in
other ways. The badness comes, AIUI, from the asymptotic behavior of the
address lookup algorithm in a tree that big.

One approach to dealing with this badness, the one I proposed earlier, is
to prevent that giant mmap from appearing in the first place (because we'd
cap vsize). If that giant mmap never appears, you can't generate a huge VMA
tree by splitting it.

Maybe that's not a good approach. Maybe processes really need mappings that
big. If they do, then maybe the right approach is to just make 8 billion
VMAs not "DoS the system". What actually goes wrong if we just let the VMA
tree grow that large? So what if VMA lookup ends up taking a while --- the
process with the pathological allocation pattern is paying the cost, right?
