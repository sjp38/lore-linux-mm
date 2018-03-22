Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id 3C3926B0062
	for <linux-mm@kvack.org>; Thu, 22 Mar 2018 12:51:07 -0400 (EDT)
Received: by mail-pf0-f200.google.com with SMTP id j12so4861591pff.18
        for <linux-mm@kvack.org>; Thu, 22 Mar 2018 09:51:07 -0700 (PDT)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id p12-v6si6336094plo.194.2018.03.22.09.51.06
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Thu, 22 Mar 2018 09:51:06 -0700 (PDT)
Date: Thu, 22 Mar 2018 09:51:03 -0700
From: Matthew Wilcox <willy@infradead.org>
Subject: Re: [RFC PATCH 1/8] mm: mmap: unmap large mapping by section
Message-ID: <20180322165102.GF28468@bombadil.infradead.org>
References: <20180321130833.GM23100@dhcp22.suse.cz>
 <f88deb20-bcce-939f-53a6-1061c39a9f6c@linux.alibaba.com>
 <20180321172932.GE4780@bombadil.infradead.org>
 <f057a634-7e0a-1b51-eede-dcb6f128b18e@linux.alibaba.com>
 <20180321224631.GB3969@bombadil.infradead.org>
 <18a727fd-f006-9fae-d9ca-74b9004f0a8b@linux.vnet.ibm.com>
 <20180322154055.GB28468@bombadil.infradead.org>
 <0442fb0e-3da3-3f23-ce4d-0f6cbc3eac9a@linux.vnet.ibm.com>
 <20180322160547.GC28468@bombadil.infradead.org>
 <55ac947f-fd77-3754-ebfe-30d458c54403@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <55ac947f-fd77-3754-ebfe-30d458c54403@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Laurent Dufour <ldufour@linux.vnet.ibm.com>
Cc: Yang Shi <yang.shi@linux.alibaba.com>, Michal Hocko <mhocko@kernel.org>, akpm@linux-foundation.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Thu, Mar 22, 2018 at 05:18:55PM +0100, Laurent Dufour wrote:
> > It's *really* rare to page-fault on a VMA which is in the middle of
> > being replaced.  Why are you trying to optimise it?
> 
> I was not trying to optimize it, but to not wait in the page fault handler.
> This could become tricky in the case the VMA is removed once mmap(MAP_FIXED) is
> done and before the waiting page fault got woken up. This means that the
> removed VMA structure will have to remain until all the waiters are woken up
> which implies ref_count or similar.

Yes, that's why we don't want an actual rwsem.  What I had in mind was
a struct completion on the stack of the caller of munmap(), and a pointer
to it from the vma.  The page fault handler grabs the VMA tree lock, walks
the VMA tree and finds a VMA.  If the VMA is marked as locked, it waits
for the completion.  Upon wakeup *it does not look at the VMA*, instead it
restarts the page fault.
