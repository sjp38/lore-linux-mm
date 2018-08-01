Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f70.google.com (mail-pl0-f70.google.com [209.85.160.70])
	by kanga.kvack.org (Postfix) with ESMTP id 2F6C46B0003
	for <linux-mm@kvack.org>; Wed,  1 Aug 2018 16:52:05 -0400 (EDT)
Received: by mail-pl0-f70.google.com with SMTP id d22-v6so14293628pls.4
        for <linux-mm@kvack.org>; Wed, 01 Aug 2018 13:52:05 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id g34-v6sor5484570pld.68.2018.08.01.13.52.03
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 01 Aug 2018 13:52:03 -0700 (PDT)
Date: Wed, 1 Aug 2018 23:51:56 +0300
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: Linux 4.18-rc7
Message-ID: <20180801205156.zv45fcveexwa2dqs@kshutemo-mobl1>
References: <alpine.LSU.2.11.1807301410470.4805@eggly.anvils>
 <CA+55aFx3qR1FW0T3na25NrwLZAvpOdUEUJa879CnaJT2ZPfhkg@mail.gmail.com>
 <alpine.LSU.2.11.1807301940460.5904@eggly.anvils>
 <CALAqxLU3cmu4g+HaB6A7=VhY-hW=d9e68EZ=_4JiwX_BigzjPQ@mail.gmail.com>
 <CAMi1Hd0-2eDod4HiBifKCxY0cUUEW_A-yv7sZ7GRgL0whWQt+w@mail.gmail.com>
 <CA+55aFx=-tHXjv3gv4W=xYwM+VOHJQE5q5VyihkPK7s560x-vQ@mail.gmail.com>
 <20180731170328.ocb5oikwhwtkyzrj@kshutemo-mobl1>
 <20180731174349.GA12944@agluck-desk>
 <CA+55aFxJpJvcYKos-sVTsn9q4wK0-m4up1SXrcqfbXHKxaKxjg@mail.gmail.com>
 <CA+55aFz0eKks=v872LA-tDx4qcmBtxTYXbeztZcWbgx6SeQHNg@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CA+55aFz0eKks=v872LA-tDx4qcmBtxTYXbeztZcWbgx6SeQHNg@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Tony Luck <tony.luck@intel.com>, Amit Pundir <amit.pundir@linaro.org>, John Stultz <john.stultz@linaro.org>, Hugh Dickins <hughd@google.com>, Matthew Wilcox <willy@infradead.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Andrew Morton <akpm@linux-foundation.org>, Dmitry Vyukov <dvyukov@google.com>, Oleg Nesterov <oleg@redhat.com>, Andrea Arcangeli <aarcange@redhat.com>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, linux-mm <linux-mm@kvack.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, youling 257 <youling257@gmail.com>, Joel Fernandes <joelaf@google.com>, Colin Cross <ccross@google.com>

On Wed, Aug 01, 2018 at 01:05:48PM -0700, Linus Torvalds wrote:
> On Wed, Aug 1, 2018 at 10:15 AM Linus Torvalds
> <torvalds@linux-foundation.org> wrote:
> >
> > I'm still unhappy about the vma_init() ones, and I have not decided
> > how to go with those. Either the memset() in vma_init(), or just
> > reverting the (imho unnecessary) commit 2c4541e24c55. Kirill, Andrew,
> > comments?
> 
> Ugh. Adding a memset looks simple, but screws up some places that have
> other initialization. It also requires adding a new include of
> <linux/string.h>, or we'd need to uninline vma_init() and put it
> somewhere else.
> 
> But just reverting commit 2c4541e24c55 ("mm: use vma_init() to
> initialize VMAs on stack and data segments") entirely isn't good
> either, because some of the cases aren't about the TLB flush
> interface, and call down to "real" VM functions. The 'pseudo_vma' use
> of remove_inode_hugepages() and hugetlbfs_fallocate() in particular is
> odd, but using vma_init() looks good there. And those places had the
> memset() already.
> 
> So I'm inclined to simply mark the TLB-related vma_init() cases
> special, and use something like this:
> 
>   #define TLB_FLUSH_VMA(mm,flags) { .vm_mm = (mm), .vm_flags = (flags) }
> 
> to make it very obvious when we're doing that vma initialization for
> flush_tlb_range(). It's done as an initializer, exactly so that the
> only valid syntax is to do somethin glike this:
> 
>         struct vm_area_struct vma = TLB_FLUSH_VMA(mm, VM_EXEC);
> 
> That leaves vma_init() users to be just the actual real allocation
> path, and a few very specific specual vmas (the hugetlbfs and
> mempolicy pseudo-vma, and a couple of "gate" vmas).
> 
> Suggested patch attached. Comments?

Is there a reason why we pass vma to flush_tlb_range?

It's not obvious to me what information from VMA can be useful for an
implementation. I see that ecard.c initialize vm_flags too, but it seems
unused by flush_tlb_range.

Maybe it's cleaner to have generic helper flush_tlb_range_mm() or
something?

In longer term we can change the interface to take mm instead of vma.

-- 
 Kirill A. Shutemov
