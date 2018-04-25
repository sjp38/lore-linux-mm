Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id 09E9E6B0003
	for <linux-mm@kvack.org>; Wed, 25 Apr 2018 12:22:25 -0400 (EDT)
Received: by mail-pf0-f200.google.com with SMTP id j25so16073384pfh.18
        for <linux-mm@kvack.org>; Wed, 25 Apr 2018 09:22:25 -0700 (PDT)
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.99])
        by mx.google.com with ESMTPS id az2-v6si2245507plb.555.2018.04.25.09.22.23
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 25 Apr 2018 09:22:23 -0700 (PDT)
Received: from mail-wr0-f175.google.com (mail-wr0-f175.google.com [209.85.128.175])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPSA id 57F4421837
	for <linux-mm@kvack.org>; Wed, 25 Apr 2018 16:22:23 +0000 (UTC)
Received: by mail-wr0-f175.google.com with SMTP id g21-v6so26435751wrb.8
        for <linux-mm@kvack.org>; Wed, 25 Apr 2018 09:22:23 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20180425160413.GC8546@bombadil.infradead.org>
References: <20180425052722.73022-1-edumazet@google.com> <20180425052722.73022-2-edumazet@google.com>
 <20180425062859.GA23914@infradead.org> <5cd31eba-63b5-9160-0a2e-f441340df0d3@gmail.com>
 <20180425160413.GC8546@bombadil.infradead.org>
From: Andy Lutomirski <luto@kernel.org>
Date: Wed, 25 Apr 2018 09:22:01 -0700
Message-ID: <CALCETrWaekirEe+rKiPB-Zim6ZHKL-n7nfk9wrsHra_FtrS=DA@mail.gmail.com>
Subject: Re: [PATCH net-next 1/2] tcp: add TCP_ZEROCOPY_RECEIVE support for
 zerocopy receive
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Matthew Wilcox <willy@infradead.org>
Cc: Eric Dumazet <eric.dumazet@gmail.com>, Christoph Hellwig <hch@infradead.org>, Eric Dumazet <edumazet@google.com>, "David S . Miller" <davem@davemloft.net>, netdev <netdev@vger.kernel.org>, Andy Lutomirski <luto@kernel.org>, linux-kernel <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Soheil Hassas Yeganeh <soheil@google.com>

On Wed, Apr 25, 2018 at 9:04 AM, Matthew Wilcox <willy@infradead.org> wrote:
> On Wed, Apr 25, 2018 at 06:01:02AM -0700, Eric Dumazet wrote:
>> On 04/24/2018 11:28 PM, Christoph Hellwig wrote:
>> > On Tue, Apr 24, 2018 at 10:27:21PM -0700, Eric Dumazet wrote:
>> >> When adding tcp mmap() implementation, I forgot that socket lock
>> >> had to be taken before current->mm->mmap_sem. syzbot eventually caught
>> >> the bug.
>> >>
>> >> Since we can not lock the socket in tcp mmap() handler we have to
>> >> split the operation in two phases.
>> >>
>> >> 1) mmap() on a tcp socket simply reserves VMA space, and nothing else.
>> >>   This operation does not involve any TCP locking.
>> >>
>> >> 2) setsockopt(fd, IPPROTO_TCP, TCP_ZEROCOPY_RECEIVE, ...) implements
>> >>  the transfert of pages from skbs to one VMA.
>> >>   This operation only uses down_read(&current->mm->mmap_sem) after
>> >>   holding TCP lock, thus solving the lockdep issue.
>> >>
>> >> This new implementation was suggested by Andy Lutomirski with great details.
>> >
>> > Thanks, this looks much more sensible to me.
>> >
>>
>> Thanks Christoph
>>
>> Note the high cost of zap_page_range(), needed to avoid -EBUSY being returned
>> from vm_insert_page() the second time TCP_ZEROCOPY_RECEIVE is used on one VMA.
>>
>> Ideally a vm_replace_page() would avoid this cost ?
>
> If you don't zap the page range, any of the CPUs in the system where
> any thread in this task have ever run may have a TLB entry pointing to
> this page ... if the page is being recycled into the page allocator,
> then that page might end up as a slab page or page table or page cache
> while the other CPU still have access to it.

Indeed.  This is one of the reasons that Linus has generally been
quite vocal that he doesn't like MMU-based zerocopy schemes.

>
> You could hang onto the page until you've built up a sufficiently large
> batch, then bulk-invalidate all of the TLB entries, but we start to get
> into weirdnesses on different CPU architectures.

The existing mmu_gather code should already handle this at least
moderately well.  If it's not, then it should be fixed.

On x86, there is no operation to flush a range of addresses.  You can
flush one address or you can flush all of them.  If you flush one page
at a time, then you might never recover the performance of a plain old
memcpy().  If you flush all of them, then you're hurting the
performance of everything else in the task.

In general, I suspect that the zerocopy receive mechanism will only
really be a win in single-threaded applications that consume large
amounts of receive bandwidth on a single TCP socket using lots of
memory and don't do all that much else.
