Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk1-f197.google.com (mail-qk1-f197.google.com [209.85.222.197])
	by kanga.kvack.org (Postfix) with ESMTP id 03EC28E0001
	for <linux-mm@kvack.org>; Wed, 19 Sep 2018 06:03:14 -0400 (EDT)
Received: by mail-qk1-f197.google.com with SMTP id y130-v6so3524498qka.1
        for <linux-mm@kvack.org>; Wed, 19 Sep 2018 03:03:13 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id h42-v6si1072434qte.159.2018.09.19.03.03.12
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 19 Sep 2018 03:03:13 -0700 (PDT)
Date: Wed, 19 Sep 2018 18:02:57 +0800
From: Ming Lei <ming.lei@redhat.com>
Subject: Re: block: DMA alignment of IO buffer allocated from slab
Message-ID: <20180919100256.GD23172@ming.t460p>
References: <CACVXFVOBq3L_EjSTCoiqUL1PH=HMR5EuNNQV0hNndFpGxmUK6g@mail.gmail.com>
 <877ejh3jv0.fsf@vitty.brq.redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <877ejh3jv0.fsf@vitty.brq.redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vitaly Kuznetsov <vkuznets@redhat.com>
Cc: Ming Lei <tom.leiming@gmail.com>, linux-block <linux-block@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Linux FS Devel <linux-fsdevel@vger.kernel.org>, "open list:XFS FILESYSTEM" <linux-xfs@vger.kernel.org>, Dave Chinner <dchinner@redhat.com>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Christoph Hellwig <hch@lst.de>, Jens Axboe <axboe@kernel.dk>

Hi Vitaly,

On Wed, Sep 19, 2018 at 11:41:07AM +0200, Vitaly Kuznetsov wrote:
> Ming Lei <tom.leiming@gmail.com> writes:
> 
> > Hi Guys,
> >
> > Some storage controllers have DMA alignment limit, which is often set via
> > blk_queue_dma_alignment(), such as 512-byte alignment for IO buffer.
> 
> While mostly drivers use 512-byte alignment it is not a rule of thumb,
> 'git grep' tell me we have:
> ide-cd.c with 32-byte alignment
> ps3disk.c and rsxx/dev.c with variable alignment.
> 
> What if our block configuration consists of several devices (in raid
> array, for example) with different requirements, e.g. one requiring
> 512-byte alignment and the other requiring 256?

512-byte alignment is also 256-byte aligned, and the sector size is 512 byte.

> 
> >
> > Block layer now only checks if this limit is respected for buffer of
> > pass-through request,
> > see blk_rq_map_user_iov(), bio_map_user_iov().
> >
> > The userspace buffer for direct IO is checked in dio path, see
> > do_blockdev_direct_IO().
> > IO buffer from page cache should be fine wrt. this limit too.
> >
> > However, some file systems, such as XFS, may allocate single sector IO buffer
> > via slab. Usually I guess kmalloc-512 should be fine to return
> > 512-aligned buffer.
> > But once KASAN or other slab debug options are enabled, looks this
> > isn't true any
> > more, kmalloc-512 may not return 512-aligned buffer. Then data corruption
> > can be observed because the IO buffer from fs layer doesn't respect the DMA
> > alignment limit any more.
> >
> > Follows several related questions:
> >
> > 1) does kmalloc-N slab guarantee to return N-byte aligned buffer?  If
> > yes, is it a stable rule?
> >
> > 2) If it is a rule for kmalloc-N slab to return N-byte aligned buffer,
> > seems KASAN violates this
> > rule?
> 
> (as I was kinda involved in debugging): the issue was observed with SLUB
> allocator KASAN is not to blame, everything wich requires aditional
> metadata space will break this, see e.g. calculate_sizes() in slub.c

Buffer allocated via kmalloc() should be aligned with L1 HW cache size
at least.

I have raised the question: does kmalloc-512 slab guarantee to return
512-byte aligned buffer, let's see what the answer is from MM guys,:-) 

>From the Red Hat BZ, looks I understand this issue is only triggered when
KASAN is enabled, or you have figured out how to reproduce it without
KASAN involved?

> 
> >
> > 3) If slab can't guarantee to return 512-aligned buffer, how to fix
> > this data corruption issue?
> 
> I'm no expert in block layer but in case of complex block device
> configurations when bio submitter can't know all the requirements I see
> no other choice than bouncing.

I guess that might be the last straw, given the current way without
bouncing works for decades, and seems no one complains before.

Thanks,
Ming
