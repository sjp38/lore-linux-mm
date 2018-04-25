Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id D2F786B0007
	for <linux-mm@kvack.org>; Wed, 25 Apr 2018 12:30:18 -0400 (EDT)
Received: by mail-pf0-f199.google.com with SMTP id z22so11761475pfi.7
        for <linux-mm@kvack.org>; Wed, 25 Apr 2018 09:30:18 -0700 (PDT)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id y2si14113597pgs.351.2018.04.25.09.30.16
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Wed, 25 Apr 2018 09:30:17 -0700 (PDT)
Date: Wed, 25 Apr 2018 09:30:14 -0700
From: Matthew Wilcox <willy@infradead.org>
Subject: Re: [PATCH net-next 1/2] tcp: add TCP_ZEROCOPY_RECEIVE support for
 zerocopy receive
Message-ID: <20180425163014.GD8546@bombadil.infradead.org>
References: <20180425052722.73022-1-edumazet@google.com>
 <20180425052722.73022-2-edumazet@google.com>
 <20180425062859.GA23914@infradead.org>
 <5cd31eba-63b5-9160-0a2e-f441340df0d3@gmail.com>
 <20180425160413.GC8546@bombadil.infradead.org>
 <8ce78bd6-8142-2937-11fd-2e4a2b22d90c@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <8ce78bd6-8142-2937-11fd-2e4a2b22d90c@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Cc: Christoph Hellwig <hch@infradead.org>, Eric Dumazet <edumazet@google.com>, "David S . Miller" <davem@davemloft.net>, netdev <netdev@vger.kernel.org>, Andy Lutomirski <luto@kernel.org>, linux-kernel <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Soheil Hassas Yeganeh <soheil@google.com>

On Wed, Apr 25, 2018 at 09:20:55AM -0700, Eric Dumazet wrote:
> On 04/25/2018 09:04 AM, Matthew Wilcox wrote:
> > If you don't zap the page range, any of the CPUs in the system where
> > any thread in this task have ever run may have a TLB entry pointing to
> > this page ... if the page is being recycled into the page allocator,
> > then that page might end up as a slab page or page table or page cache
> > while the other CPU still have access to it.
> 
> Yes, this makes sense.
> 
> > 
> > You could hang onto the page until you've built up a sufficiently large
> > batch, then bulk-invalidate all of the TLB entries, but we start to get
> > into weirdnesses on different CPU architectures.
> > 
> 
> zap_page_range() is already doing a bulk-invalidate,
> so maybe vm_replace_page() wont bring serious improvement if we end-up doing same dance.

Sorry, I was unclear.  zap_page_range() bulk-invalidates all pages that
were torn down as part of this call.  What I was trying to say was that
we could have a whole new API which put page after page into the same
address, and bumped the refcount on them to prevent them from actually
being freed.  Once we get to a batch limit, we invalidate all of the
pages which were mapped at those addresses and can then free the pages
back to the allocator.

I don't think you can implement this scheme on s390 because it requires
the userspace address to still be mapped to that page on shootdown
(?) but I think we could implement it on x86.

Another possibility is if we had some way to insert the TLB entry into
the local CPU's page tables only, we wouldn't need to broadcast-invalidate
the TLB entry; we could just do it locally which is relatively quick.
