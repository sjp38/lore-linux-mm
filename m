Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf1-f197.google.com (mail-pf1-f197.google.com [209.85.210.197])
	by kanga.kvack.org (Postfix) with ESMTP id D37ED8E0041
	for <linux-mm@kvack.org>; Mon, 24 Sep 2018 23:28:36 -0400 (EDT)
Received: by mail-pf1-f197.google.com with SMTP id x6-v6so2893700pfn.21
        for <linux-mm@kvack.org>; Mon, 24 Sep 2018 20:28:36 -0700 (PDT)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id k70-v6si1090181pge.379.2018.09.24.20.28.35
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Mon, 24 Sep 2018 20:28:35 -0700 (PDT)
Date: Mon, 24 Sep 2018 20:28:26 -0700
From: Matthew Wilcox <willy@infradead.org>
Subject: Re: block: DMA alignment of IO buffer allocated from slab
Message-ID: <20180925032826.GA4110@bombadil.infradead.org>
References: <38c03920-0fd0-0a39-2a6e-70cd8cb4ef34@virtuozzo.com>
 <20a20568-5089-541d-3cee-546e549a0bc8@acm.org>
 <12eee877-affa-c822-c9d5-fda3aa0a50da@virtuozzo.com>
 <1537801706.195115.7.camel@acm.org>
 <c844c598-be1d-bef4-fb99-09cf99571fd7@virtuozzo.com>
 <1537804720.195115.9.camel@acm.org>
 <10c706fd-2252-f11b-312e-ae0d97d9a538@virtuozzo.com>
 <1537805984.195115.14.camel@acm.org>
 <20180924185753.GA32269@bombadil.infradead.org>
 <20180925001615.GA14386@ming.t460p>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180925001615.GA14386@ming.t460p>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ming Lei <ming.lei@redhat.com>
Cc: Bart Van Assche <bvanassche@acm.org>, Andrey Ryabinin <aryabinin@virtuozzo.com>, Vitaly Kuznetsov <vkuznets@redhat.com>, Christoph Hellwig <hch@lst.de>, Ming Lei <tom.leiming@gmail.com>, linux-block <linux-block@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Linux FS Devel <linux-fsdevel@vger.kernel.org>, "open list:XFS FILESYSTEM" <linux-xfs@vger.kernel.org>, Dave Chinner <dchinner@redhat.com>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Jens Axboe <axboe@kernel.dk>, Christoph Lameter <cl@linux.com>, Linus Torvalds <torvalds@linux-foundation.org>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>

On Tue, Sep 25, 2018 at 08:16:16AM +0800, Ming Lei wrote:
> On Mon, Sep 24, 2018 at 11:57:53AM -0700, Matthew Wilcox wrote:
> > On Mon, Sep 24, 2018 at 09:19:44AM -0700, Bart Van Assche wrote:
> > You're not supposed to use kmalloc memory for DMA.  This is why we have
> > dma_alloc_coherent() and friends.  Also, from DMA-API.txt:
> 
> Please take a look at USB drivers, or storage drivers or scsi layer. Lot of
> DMA buffers are allocated via kmalloc.

Then we have lots of broken places.  I mean, this isn't new.  We used
to have lots of broken places that did DMA to the stack.  And then
the stack was changed to be vmalloc'ed and all those places got fixed.
The difference this time is that it's only certain rare configurations
that are broken, and the brokenness is only found by corruption in some
fairly unlikely scenarios.

> Also see the following description in DMA-API-HOWTO.txt:
> 
> 	If the device supports DMA, the driver sets up a buffer using kmalloc() or
> 	a similar interface, which returns a virtual address (X).  The virtual
> 	memory system maps X to a physical address (Y) in system RAM.  The driver
> 	can use virtual address X to access the buffer, but the device itself
> 	cannot because DMA doesn't go through the CPU virtual memory system.

Sure, but that's not addressing the cacheline coherency problem.

Regardless of what the docs did or didn't say, let's try answering
the question: what makes for a more useful system?

A: A kmalloc implementation which always returns an address suitable
for mapping using the DMA interfaces

B: A kmalloc implementation which is more efficient, but requires drivers
to use a different interface for allocating space for the purposes of DMA

I genuinely don't know the answer to this question, and I think there are
various people in this thread who believe A or B quite strongly.

I would also like to ask people who believe in A what should happen in
this situation:

        blocks = kmalloc(4, GFP_KERNEL);
        sg_init_one(&sg, blocks, 4);
...
        result = ntohl(*blocks);
        kfree(blocks);

(this is just one example; there are others).  Because if we have to
round all allocations below 64 bytes up to 64 bytes, that's going to be
a memory consumption problem.  On my laptop:

kmalloc-96         11527  15792     96   42    1 : slabdata    376    376      0
kmalloc-64         54406  62912     64   64    1 : slabdata    983    983      0
kmalloc-32         80325  84096     32  128    1 : slabdata    657    657      0
kmalloc-16         26844  30208     16  256    1 : slabdata    118    118      0
kmalloc-8          17141  21504      8  512    1 : slabdata     42     42      0

I make that an extra 1799 pages (7MB).  Not the end of the world, but
not free either.
