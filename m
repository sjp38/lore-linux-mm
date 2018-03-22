Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f70.google.com (mail-pg0-f70.google.com [74.125.83.70])
	by kanga.kvack.org (Postfix) with ESMTP id 800F86B0024
	for <linux-mm@kvack.org>; Thu, 22 Mar 2018 11:41:00 -0400 (EDT)
Received: by mail-pg0-f70.google.com with SMTP id m198so4353059pga.4
        for <linux-mm@kvack.org>; Thu, 22 Mar 2018 08:41:00 -0700 (PDT)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id c11-v6si7174804plr.354.2018.03.22.08.40.59
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Thu, 22 Mar 2018 08:40:59 -0700 (PDT)
Date: Thu, 22 Mar 2018 08:40:55 -0700
From: Matthew Wilcox <willy@infradead.org>
Subject: Re: [RFC PATCH 1/8] mm: mmap: unmap large mapping by section
Message-ID: <20180322154055.GB28468@bombadil.infradead.org>
References: <1521581486-99134-1-git-send-email-yang.shi@linux.alibaba.com>
 <1521581486-99134-2-git-send-email-yang.shi@linux.alibaba.com>
 <20180321130833.GM23100@dhcp22.suse.cz>
 <f88deb20-bcce-939f-53a6-1061c39a9f6c@linux.alibaba.com>
 <20180321172932.GE4780@bombadil.infradead.org>
 <f057a634-7e0a-1b51-eede-dcb6f128b18e@linux.alibaba.com>
 <20180321224631.GB3969@bombadil.infradead.org>
 <18a727fd-f006-9fae-d9ca-74b9004f0a8b@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <18a727fd-f006-9fae-d9ca-74b9004f0a8b@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Laurent Dufour <ldufour@linux.vnet.ibm.com>
Cc: Yang Shi <yang.shi@linux.alibaba.com>, Michal Hocko <mhocko@kernel.org>, akpm@linux-foundation.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Thu, Mar 22, 2018 at 04:32:00PM +0100, Laurent Dufour wrote:
> On 21/03/2018 23:46, Matthew Wilcox wrote:
> > On Wed, Mar 21, 2018 at 02:45:44PM -0700, Yang Shi wrote:
> >> Marking vma as deleted sounds good. The problem for my current approach is
> >> the concurrent page fault may succeed if it access the not yet unmapped
> >> section. Marking deleted vma could tell page fault the vma is not valid
> >> anymore, then return SIGSEGV.
> >>
> >>> does not care; munmap will need to wait for the existing munmap operation
> >>
> >> Why mmap doesn't care? How about MAP_FIXED? It may fail unexpectedly, right?
> > 
> > The other thing about MAP_FIXED that we'll need to handle is unmapping
> > conflicts atomically.  Say a program has a 200GB mapping and then
> > mmap(MAP_FIXED) another 200GB region on top of it.  So I think page faults
> > are also going to have to wait for deleted vmas (then retry the fault)
> > rather than immediately raising SIGSEGV.
> 
> Regarding the page fault, why not relying on the PTE locking ?
> 
> When munmap() will unset the PTE it will have to held the PTE lock, so this
> will serialize the access.
> If the page fault occurs before the mmap(MAP_FIXED), the page mapped will be
> removed when mmap(MAP_FIXED) would do the cleanup. Fair enough.

The page fault handler will walk the VMA tree to find the correct
VMA and then find that the VMA is marked as deleted.  If it assumes
that the VMA has been deleted because of munmap(), then it can raise
SIGSEGV immediately.  But if the VMA is marked as deleted because of
mmap(MAP_FIXED), it must wait until the new VMA is in place.

I think I was wrong to describe VMAs as being *deleted*.  I think we
instead need the concept of a *locked* VMA that page faults will block on.
Conceptually, it's a per-VMA rwsem, but I'd use a completion instead of
an rwsem since the only reason to write-lock the VMA is because it is
being deleted.
