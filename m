Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f69.google.com (mail-pg0-f69.google.com [74.125.83.69])
	by kanga.kvack.org (Postfix) with ESMTP id A3FB26B0003
	for <linux-mm@kvack.org>; Wed, 25 Apr 2018 12:04:19 -0400 (EDT)
Received: by mail-pg0-f69.google.com with SMTP id t4so8351882pgv.21
        for <linux-mm@kvack.org>; Wed, 25 Apr 2018 09:04:19 -0700 (PDT)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id k14si12865848pgs.418.2018.04.25.09.04.18
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Wed, 25 Apr 2018 09:04:18 -0700 (PDT)
Date: Wed, 25 Apr 2018 09:04:13 -0700
From: Matthew Wilcox <willy@infradead.org>
Subject: Re: [PATCH net-next 1/2] tcp: add TCP_ZEROCOPY_RECEIVE support for
 zerocopy receive
Message-ID: <20180425160413.GC8546@bombadil.infradead.org>
References: <20180425052722.73022-1-edumazet@google.com>
 <20180425052722.73022-2-edumazet@google.com>
 <20180425062859.GA23914@infradead.org>
 <5cd31eba-63b5-9160-0a2e-f441340df0d3@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <5cd31eba-63b5-9160-0a2e-f441340df0d3@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Cc: Christoph Hellwig <hch@infradead.org>, Eric Dumazet <edumazet@google.com>, "David S . Miller" <davem@davemloft.net>, netdev <netdev@vger.kernel.org>, Andy Lutomirski <luto@kernel.org>, linux-kernel <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Soheil Hassas Yeganeh <soheil@google.com>

On Wed, Apr 25, 2018 at 06:01:02AM -0700, Eric Dumazet wrote:
> On 04/24/2018 11:28 PM, Christoph Hellwig wrote:
> > On Tue, Apr 24, 2018 at 10:27:21PM -0700, Eric Dumazet wrote:
> >> When adding tcp mmap() implementation, I forgot that socket lock
> >> had to be taken before current->mm->mmap_sem. syzbot eventually caught
> >> the bug.
> >>
> >> Since we can not lock the socket in tcp mmap() handler we have to
> >> split the operation in two phases.
> >>
> >> 1) mmap() on a tcp socket simply reserves VMA space, and nothing else.
> >>   This operation does not involve any TCP locking.
> >>
> >> 2) setsockopt(fd, IPPROTO_TCP, TCP_ZEROCOPY_RECEIVE, ...) implements
> >>  the transfert of pages from skbs to one VMA.
> >>   This operation only uses down_read(&current->mm->mmap_sem) after
> >>   holding TCP lock, thus solving the lockdep issue.
> >>
> >> This new implementation was suggested by Andy Lutomirski with great details.
> > 
> > Thanks, this looks much more sensible to me.
> > 
> 
> Thanks Christoph
> 
> Note the high cost of zap_page_range(), needed to avoid -EBUSY being returned
> from vm_insert_page() the second time TCP_ZEROCOPY_RECEIVE is used on one VMA.
> 
> Ideally a vm_replace_page() would avoid this cost ?

If you don't zap the page range, any of the CPUs in the system where
any thread in this task have ever run may have a TLB entry pointing to
this page ... if the page is being recycled into the page allocator,
then that page might end up as a slab page or page table or page cache
while the other CPU still have access to it.

You could hang onto the page until you've built up a sufficiently large
batch, then bulk-invalidate all of the TLB entries, but we start to get
into weirdnesses on different CPU architectures.
