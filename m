Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id 4362D6B000C
	for <linux-mm@kvack.org>; Thu, 22 Mar 2018 12:05:51 -0400 (EDT)
Received: by mail-pf0-f200.google.com with SMTP id j12so4798453pff.18
        for <linux-mm@kvack.org>; Thu, 22 Mar 2018 09:05:51 -0700 (PDT)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id l12si4640071pgr.66.2018.03.22.09.05.50
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Thu, 22 Mar 2018 09:05:50 -0700 (PDT)
Date: Thu, 22 Mar 2018 09:05:47 -0700
From: Matthew Wilcox <willy@infradead.org>
Subject: Re: [RFC PATCH 1/8] mm: mmap: unmap large mapping by section
Message-ID: <20180322160547.GC28468@bombadil.infradead.org>
References: <1521581486-99134-1-git-send-email-yang.shi@linux.alibaba.com>
 <1521581486-99134-2-git-send-email-yang.shi@linux.alibaba.com>
 <20180321130833.GM23100@dhcp22.suse.cz>
 <f88deb20-bcce-939f-53a6-1061c39a9f6c@linux.alibaba.com>
 <20180321172932.GE4780@bombadil.infradead.org>
 <f057a634-7e0a-1b51-eede-dcb6f128b18e@linux.alibaba.com>
 <20180321224631.GB3969@bombadil.infradead.org>
 <18a727fd-f006-9fae-d9ca-74b9004f0a8b@linux.vnet.ibm.com>
 <20180322154055.GB28468@bombadil.infradead.org>
 <0442fb0e-3da3-3f23-ce4d-0f6cbc3eac9a@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <0442fb0e-3da3-3f23-ce4d-0f6cbc3eac9a@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Laurent Dufour <ldufour@linux.vnet.ibm.com>
Cc: Yang Shi <yang.shi@linux.alibaba.com>, Michal Hocko <mhocko@kernel.org>, akpm@linux-foundation.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Thu, Mar 22, 2018 at 04:54:52PM +0100, Laurent Dufour wrote:
> On 22/03/2018 16:40, Matthew Wilcox wrote:
> > On Thu, Mar 22, 2018 at 04:32:00PM +0100, Laurent Dufour wrote:
> >> Regarding the page fault, why not relying on the PTE locking ?
> >>
> >> When munmap() will unset the PTE it will have to held the PTE lock, so this
> >> will serialize the access.
> >> If the page fault occurs before the mmap(MAP_FIXED), the page mapped will be
> >> removed when mmap(MAP_FIXED) would do the cleanup. Fair enough.
> > 
> > The page fault handler will walk the VMA tree to find the correct
> > VMA and then find that the VMA is marked as deleted.  If it assumes
> > that the VMA has been deleted because of munmap(), then it can raise
> > SIGSEGV immediately.  But if the VMA is marked as deleted because of
> > mmap(MAP_FIXED), it must wait until the new VMA is in place.
> 
> I'm wondering if such a complexity is required.
> If the user space process try to access the page being overwritten through
> mmap(MAP_FIXED) by another thread, there is no guarantee that it will
> manipulate the *old* page or *new* one.

Right; but it must return one or the other, it can't segfault.

> I'd think this is up to the user process to handle that concurrency.
> What needs to be guaranteed is that once mmap(MAP_FIXED) returns the old page
> are no more there, which is done through the mmap_sem and PTE locking.

Yes, and allowing the fault handler to return the *old* page risks the
old page being reinserted into the page tables after the unmapping task
has done its work.

It's *really* rare to page-fault on a VMA which is in the middle of
being replaced.  Why are you trying to optimise it?

> > I think I was wrong to describe VMAs as being *deleted*.  I think we
> > instead need the concept of a *locked* VMA that page faults will block on.
> > Conceptually, it's a per-VMA rwsem, but I'd use a completion instead of
> > an rwsem since the only reason to write-lock the VMA is because it is
> > being deleted.
> 
> Such a lock would only makes sense in the case of mmap(MAP_FIXED) since when
> the VMA is removed there is no need to wait. Isn't it ?

I can't think of another reason.  I suppose we could mark the VMA as
locked-for-deletion or locked-for-replacement and have the SIGSEGV happen
early.  But I'm not sure that optimising for SIGSEGVs is a worthwhile
use of our time.  Just always have the pagefault sleep for a deleted VMA.
