Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk1-f198.google.com (mail-qk1-f198.google.com [209.85.222.198])
	by kanga.kvack.org (Postfix) with ESMTP id 2F8B08E0041
	for <linux-mm@kvack.org>; Mon, 24 Sep 2018 20:16:33 -0400 (EDT)
Received: by mail-qk1-f198.google.com with SMTP id v14-v6so4237949qkg.8
        for <linux-mm@kvack.org>; Mon, 24 Sep 2018 17:16:33 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id a9-v6si589580qkj.205.2018.09.24.17.16.32
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 24 Sep 2018 17:16:32 -0700 (PDT)
Date: Tue, 25 Sep 2018 08:16:16 +0800
From: Ming Lei <ming.lei@redhat.com>
Subject: Re: block: DMA alignment of IO buffer allocated from slab
Message-ID: <20180925001615.GA14386@ming.t460p>
References: <20180923224206.GA13618@ming.t460p>
 <38c03920-0fd0-0a39-2a6e-70cd8cb4ef34@virtuozzo.com>
 <20a20568-5089-541d-3cee-546e549a0bc8@acm.org>
 <12eee877-affa-c822-c9d5-fda3aa0a50da@virtuozzo.com>
 <1537801706.195115.7.camel@acm.org>
 <c844c598-be1d-bef4-fb99-09cf99571fd7@virtuozzo.com>
 <1537804720.195115.9.camel@acm.org>
 <10c706fd-2252-f11b-312e-ae0d97d9a538@virtuozzo.com>
 <1537805984.195115.14.camel@acm.org>
 <20180924185753.GA32269@bombadil.infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180924185753.GA32269@bombadil.infradead.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Matthew Wilcox <willy@infradead.org>
Cc: Bart Van Assche <bvanassche@acm.org>, Andrey Ryabinin <aryabinin@virtuozzo.com>, Vitaly Kuznetsov <vkuznets@redhat.com>, Christoph Hellwig <hch@lst.de>, Ming Lei <tom.leiming@gmail.com>, linux-block <linux-block@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Linux FS Devel <linux-fsdevel@vger.kernel.org>, "open list:XFS FILESYSTEM" <linux-xfs@vger.kernel.org>, Dave Chinner <dchinner@redhat.com>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Jens Axboe <axboe@kernel.dk>, Christoph Lameter <cl@linux.com>, Linus Torvalds <torvalds@linux-foundation.org>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>

On Mon, Sep 24, 2018 at 11:57:53AM -0700, Matthew Wilcox wrote:
> On Mon, Sep 24, 2018 at 09:19:44AM -0700, Bart Van Assche wrote:
> > That means that two buffers allocated with kmalloc() may share a cache line on
> > x86-64. Since it is allowed to use a buffer allocated by kmalloc() for DMA, can
> > this lead to data corruption, e.g. if the CPU writes into one buffer allocated
> > with kmalloc() and a device performs a DMA write to another kmalloc() buffer and
> > both write operations affect the same cache line?
> 
> You're not supposed to use kmalloc memory for DMA.  This is why we have
> dma_alloc_coherent() and friends.  Also, from DMA-API.txt:

Please take a look at USB drivers, or storage drivers or scsi layer. Lot of
DMA buffers are allocated via kmalloc.

Also see the following description in DMA-API-HOWTO.txt:

	If the device supports DMA, the driver sets up a buffer using kmalloc() or
	a similar interface, which returns a virtual address (X).  The virtual
	memory system maps X to a physical address (Y) in system RAM.  The driver
	can use virtual address X to access the buffer, but the device itself
	cannot because DMA doesn't go through the CPU virtual memory system.

Also still see DMA-API-HOWTO.txt:

Types of DMA mappings
=====================

There are two types of DMA mappings:

- Consistent DMA mappings which are usually mapped at driver
  initialization, unmapped at the end and for which the hardware should
  guarantee that the device and the CPU can access the data
  in parallel and will see updates made by each other without any
  explicit software flushing.

  Think of "consistent" as "synchronous" or "coherent".


- Streaming DMA mappings which are usually mapped for one DMA
  transfer, unmapped right after it (unless you use dma_sync_* below)
  and for which hardware can optimize for sequential accesses.



Thanks,
Ming
