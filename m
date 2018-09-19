Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr1-f70.google.com (mail-wr1-f70.google.com [209.85.221.70])
	by kanga.kvack.org (Postfix) with ESMTP id C709D8E0001
	for <linux-mm@kvack.org>; Wed, 19 Sep 2018 05:15:56 -0400 (EDT)
Received: by mail-wr1-f70.google.com with SMTP id i11-v6so5049838wrr.10
        for <linux-mm@kvack.org>; Wed, 19 Sep 2018 02:15:56 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id y199-v6sor9327175wmd.8.2018.09.19.02.15.55
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 19 Sep 2018 02:15:55 -0700 (PDT)
MIME-Version: 1.0
From: Ming Lei <tom.leiming@gmail.com>
Date: Wed, 19 Sep 2018 17:15:43 +0800
Message-ID: <CACVXFVOBq3L_EjSTCoiqUL1PH=HMR5EuNNQV0hNndFpGxmUK6g@mail.gmail.com>
Subject: block: DMA alignment of IO buffer allocated from slab
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-block <linux-block@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Linux FS Devel <linux-fsdevel@vger.kernel.org>, "open list:XFS FILESYSTEM" <linux-xfs@vger.kernel.org>, Dave Chinner <dchinner@redhat.com>, Vitaly Kuznetsov <vkuznets@redhat.com>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>
Cc: Christoph Hellwig <hch@lst.de>, Jens Axboe <axboe@kernel.dk>, Ming Lei <ming.lei@redhat.com>

Hi Guys,

Some storage controllers have DMA alignment limit, which is often set via
blk_queue_dma_alignment(), such as 512-byte alignment for IO buffer.

Block layer now only checks if this limit is respected for buffer of
pass-through request,
see blk_rq_map_user_iov(), bio_map_user_iov().

The userspace buffer for direct IO is checked in dio path, see
do_blockdev_direct_IO().
IO buffer from page cache should be fine wrt. this limit too.

However, some file systems, such as XFS, may allocate single sector IO buffer
via slab. Usually I guess kmalloc-512 should be fine to return
512-aligned buffer.
But once KASAN or other slab debug options are enabled, looks this
isn't true any
more, kmalloc-512 may not return 512-aligned buffer. Then data corruption
can be observed because the IO buffer from fs layer doesn't respect the DMA
alignment limit any more.

Follows several related questions:

1) does kmalloc-N slab guarantee to return N-byte aligned buffer?  If
yes, is it a stable rule?

2) If it is a rule for kmalloc-N slab to return N-byte aligned buffer,
seems KASAN violates this
rule?

3) If slab can't guarantee to return 512-aligned buffer, how to fix
this data corruption issue?

Thanks,
Ming Lei
