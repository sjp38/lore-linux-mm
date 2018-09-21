Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl1-f200.google.com (mail-pl1-f200.google.com [209.85.214.200])
	by kanga.kvack.org (Postfix) with ESMTP id CC2FF8E0001
	for <linux-mm@kvack.org>; Thu, 20 Sep 2018 21:56:14 -0400 (EDT)
Received: by mail-pl1-f200.google.com with SMTP id n4-v6so5328706plk.7
        for <linux-mm@kvack.org>; Thu, 20 Sep 2018 18:56:14 -0700 (PDT)
Received: from ipmail03.adl2.internode.on.net (ipmail03.adl2.internode.on.net. [150.101.137.141])
        by mx.google.com with ESMTP id w68-v6si26076420pfw.308.2018.09.20.18.56.12
        for <linux-mm@kvack.org>;
        Thu, 20 Sep 2018 18:56:13 -0700 (PDT)
Date: Fri, 21 Sep 2018 11:56:08 +1000
From: Dave Chinner <david@fromorbit.com>
Subject: Re: block: DMA alignment of IO buffer allocated from slab
Message-ID: <20180921015608.GA31060@dastard>
References: <CACVXFVOBq3L_EjSTCoiqUL1PH=HMR5EuNNQV0hNndFpGxmUK6g@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CACVXFVOBq3L_EjSTCoiqUL1PH=HMR5EuNNQV0hNndFpGxmUK6g@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ming Lei <tom.leiming@gmail.com>
Cc: linux-block <linux-block@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Linux FS Devel <linux-fsdevel@vger.kernel.org>, "open list:XFS FILESYSTEM" <linux-xfs@vger.kernel.org>, Dave Chinner <dchinner@redhat.com>, Vitaly Kuznetsov <vkuznets@redhat.com>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Christoph Hellwig <hch@lst.de>, Jens Axboe <axboe@kernel.dk>, Ming Lei <ming.lei@redhat.com>

On Wed, Sep 19, 2018 at 05:15:43PM +0800, Ming Lei wrote:
> Hi Guys,
> 
> Some storage controllers have DMA alignment limit, which is often set via
> blk_queue_dma_alignment(), such as 512-byte alignment for IO buffer.
> 
> Block layer now only checks if this limit is respected for buffer of
> pass-through request,
> see blk_rq_map_user_iov(), bio_map_user_iov().
> 
> The userspace buffer for direct IO is checked in dio path, see
> do_blockdev_direct_IO().
> IO buffer from page cache should be fine wrt. this limit too.
> 
> However, some file systems, such as XFS, may allocate single sector IO buffer
> via slab. Usually I guess kmalloc-512 should be fine to return
> 512-aligned buffer.
> But once KASAN or other slab debug options are enabled, looks this
> isn't true any
> more, kmalloc-512 may not return 512-aligned buffer. Then data corruption
> can be observed because the IO buffer from fs layer doesn't respect the DMA
> alignment limit any more.
> 
> Follows several related questions:
> 
> 1) does kmalloc-N slab guarantee to return N-byte aligned buffer?  If
> yes, is it a stable rule?

It has behaved like this for both slab and slub for many, many
years.  A quick check indicates that at least XFS and hfsplus feed
kmalloc()d buffers straight to bios without any memory buffer
alignment checks at all.

> 2) If it is a rule for kmalloc-N slab to return N-byte aligned buffer,
> seems KASAN violates this
> rule?

XFS has been using kmalloc()d memory like this since 2012 and lots
of people use KASAN on XFS systems, including me. From this, it
would seem that the problem of mishandling unaligned memory buffers
is not widespread in the storage subsystem - it's taken years of
developers using slub debug and/or KASAN to find a driver that has
choked on an inappropriately aligned memory buffer....

> 3) If slab can't guarantee to return 512-aligned buffer, how to fix
> this data corruption issue?

I think that the block layer needs to check the alignment of memory
buffers passed to it and take appropriate action rather than
corrupting random memory and returning a sucess status to the bad
bio.

IMO, trusting higher layers of kernel code to get everything right
is somewhat naive. The block layer does not trust userspace to get
everything right for good reason and those same reasons extend to
kernel code. i.e. all software has bugs, we have an impossible
complex kernel config test matrix, and even if correctly written,
proven bug-free software existed, that perfect code can still
misbehave when things like memory corruption from other bad code or
hardware occurs.

>From that persepective, I think that if the the receiver of a bio
has specific alignment requirements and the bio does not meet them,
then it needs to either enforce the alignment requirements (i.e.
error out) or make it right by bouncing the bio to an acceptible
alignment. Erroring out will cause things to fail hard until
whatever problem causing the error is fixed, while bouncing them
provides the "everything just works normally" solution...

Cheers,

Dave.
-- 
Dave Chinner
david@fromorbit.com
