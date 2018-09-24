Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg1-f197.google.com (mail-pg1-f197.google.com [209.85.215.197])
	by kanga.kvack.org (Postfix) with ESMTP id E17048E0001
	for <linux-mm@kvack.org>; Mon, 24 Sep 2018 14:58:00 -0400 (EDT)
Received: by mail-pg1-f197.google.com with SMTP id 11-v6so3157719pgd.1
        for <linux-mm@kvack.org>; Mon, 24 Sep 2018 11:58:00 -0700 (PDT)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id y4-v6si86079pgk.361.2018.09.24.11.57.58
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Mon, 24 Sep 2018 11:57:59 -0700 (PDT)
Date: Mon, 24 Sep 2018 11:57:53 -0700
From: Matthew Wilcox <willy@infradead.org>
Subject: Re: block: DMA alignment of IO buffer allocated from slab
Message-ID: <20180924185753.GA32269@bombadil.infradead.org>
References: <87h8ij0zot.fsf@vitty.brq.redhat.com>
 <20180923224206.GA13618@ming.t460p>
 <38c03920-0fd0-0a39-2a6e-70cd8cb4ef34@virtuozzo.com>
 <20a20568-5089-541d-3cee-546e549a0bc8@acm.org>
 <12eee877-affa-c822-c9d5-fda3aa0a50da@virtuozzo.com>
 <1537801706.195115.7.camel@acm.org>
 <c844c598-be1d-bef4-fb99-09cf99571fd7@virtuozzo.com>
 <1537804720.195115.9.camel@acm.org>
 <10c706fd-2252-f11b-312e-ae0d97d9a538@virtuozzo.com>
 <1537805984.195115.14.camel@acm.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1537805984.195115.14.camel@acm.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Bart Van Assche <bvanassche@acm.org>
Cc: Andrey Ryabinin <aryabinin@virtuozzo.com>, Ming Lei <ming.lei@redhat.com>, Vitaly Kuznetsov <vkuznets@redhat.com>, Christoph Hellwig <hch@lst.de>, Ming Lei <tom.leiming@gmail.com>, linux-block <linux-block@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Linux FS Devel <linux-fsdevel@vger.kernel.org>, "open list:XFS FILESYSTEM" <linux-xfs@vger.kernel.org>, Dave Chinner <dchinner@redhat.com>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Jens Axboe <axboe@kernel.dk>, Christoph Lameter <cl@linux.com>, Linus Torvalds <torvalds@linux-foundation.org>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>

On Mon, Sep 24, 2018 at 09:19:44AM -0700, Bart Van Assche wrote:
> That means that two buffers allocated with kmalloc() may share a cache line on
> x86-64. Since it is allowed to use a buffer allocated by kmalloc() for DMA, can
> this lead to data corruption, e.g. if the CPU writes into one buffer allocated
> with kmalloc() and a device performs a DMA write to another kmalloc() buffer and
> both write operations affect the same cache line?

You're not supposed to use kmalloc memory for DMA.  This is why we have
dma_alloc_coherent() and friends.  Also, from DMA-API.txt:

        Memory coherency operates at a granularity called the cache
        line width.  In order for memory mapped by this API to operate
        correctly, the mapped region must begin exactly on a cache line
        boundary and end exactly on one (to prevent two separately mapped
        regions from sharing a single cache line).  Since the cache line size
        may not be known at compile time, the API will not enforce this
        requirement.  Therefore, it is recommended that driver writers who
        don't take special care to determine the cache line size at run time
        only map virtual regions that begin and end on page boundaries (which
        are guaranteed also to be cache line boundaries).
