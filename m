Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg1-f199.google.com (mail-pg1-f199.google.com [209.85.215.199])
	by kanga.kvack.org (Postfix) with ESMTP id 158AE8E0041
	for <linux-mm@kvack.org>; Mon, 24 Sep 2018 15:56:22 -0400 (EDT)
Received: by mail-pg1-f199.google.com with SMTP id a18-v6so3747557pgn.10
        for <linux-mm@kvack.org>; Mon, 24 Sep 2018 12:56:22 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id be1-v6sor41706plb.91.2018.09.24.12.56.20
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 24 Sep 2018 12:56:20 -0700 (PDT)
Message-ID: <1537818978.195115.25.camel@acm.org>
Subject: Re: block: DMA alignment of IO buffer allocated from slab
From: Bart Van Assche <bvanassche@acm.org>
Date: Mon, 24 Sep 2018 12:56:18 -0700
In-Reply-To: <20180924185753.GA32269@bombadil.infradead.org>
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
	 <20180924185753.GA32269@bombadil.infradead.org>
Content-Type: text/plain; charset="UTF-7"
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Matthew Wilcox <willy@infradead.org>
Cc: Andrey Ryabinin <aryabinin@virtuozzo.com>, Ming Lei <ming.lei@redhat.com>, Vitaly Kuznetsov <vkuznets@redhat.com>, Christoph Hellwig <hch@lst.de>, Ming Lei <tom.leiming@gmail.com>, linux-block <linux-block@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Linux FS Devel <linux-fsdevel@vger.kernel.org>, "open list:XFS FILESYSTEM" <linux-xfs@vger.kernel.org>, Dave Chinner <dchinner@redhat.com>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Jens Axboe <axboe@kernel.dk>, Christoph Lameter <cl@linux.com>, Linus Torvalds <torvalds@linux-foundation.org>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>

On Mon, 2018-09-24 at 11:57 -0700, Matthew Wilcox wrote:
+AD4 On Mon, Sep 24, 2018 at 09:19:44AM -0700, Bart Van Assche wrote:
+AD4 +AD4 That means that two buffers allocated with kmalloc() may share a cache line on
+AD4 +AD4 x86-64. Since it is allowed to use a buffer allocated by kmalloc() for DMA, can
+AD4 +AD4 this lead to data corruption, e.g. if the CPU writes into one buffer allocated
+AD4 +AD4 with kmalloc() and a device performs a DMA write to another kmalloc() buffer and
+AD4 +AD4 both write operations affect the same cache line?
+AD4 
+AD4 You're not supposed to use kmalloc memory for DMA.  This is why we have
+AD4 dma+AF8-alloc+AF8-coherent() and friends.

Are you claiming that all drivers that use DMA should use coherent DMA only? If
coherent DMA is the only DMA style that should be used, why do the following
function pointers exist in struct dma+AF8-map+AF8-ops?

	void (+ACo-sync+AF8-single+AF8-for+AF8-cpu)(struct device +ACo-dev,
				    dma+AF8-addr+AF8-t dma+AF8-handle, size+AF8-t size,
				    enum dma+AF8-data+AF8-direction dir)+ADs
	void (+ACo-sync+AF8-single+AF8-for+AF8-device)(struct device +ACo-dev,
				       dma+AF8-addr+AF8-t dma+AF8-handle, size+AF8-t size,
				       enum dma+AF8-data+AF8-direction dir)+ADs
	void (+ACo-sync+AF8-sg+AF8-for+AF8-cpu)(struct device +ACo-dev,
				struct scatterlist +ACo-sg, int nents,
				enum dma+AF8-data+AF8-direction dir)+ADs
	void (+ACo-sync+AF8-sg+AF8-for+AF8-device)(struct device +ACo-dev,
				   struct scatterlist +ACo-sg, int nents,
				   enum dma+AF8-data+AF8-direction dir)+ADs

Thanks,

Bart.
