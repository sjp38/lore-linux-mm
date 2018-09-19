Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f200.google.com (mail-qt0-f200.google.com [209.85.216.200])
	by kanga.kvack.org (Postfix) with ESMTP id 5E25D8E0001
	for <linux-mm@kvack.org>; Wed, 19 Sep 2018 05:41:35 -0400 (EDT)
Received: by mail-qt0-f200.google.com with SMTP id k21-v6so3511176qtj.23
        for <linux-mm@kvack.org>; Wed, 19 Sep 2018 02:41:35 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id m67-v6si1987539qki.353.2018.09.19.02.41.34
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 19 Sep 2018 02:41:34 -0700 (PDT)
From: Vitaly Kuznetsov <vkuznets@redhat.com>
Subject: Re: block: DMA alignment of IO buffer allocated from slab
References: <CACVXFVOBq3L_EjSTCoiqUL1PH=HMR5EuNNQV0hNndFpGxmUK6g@mail.gmail.com>
Date: Wed, 19 Sep 2018 11:41:07 +0200
In-Reply-To: <CACVXFVOBq3L_EjSTCoiqUL1PH=HMR5EuNNQV0hNndFpGxmUK6g@mail.gmail.com>
	(Ming Lei's message of "Wed, 19 Sep 2018 17:15:43 +0800")
Message-ID: <877ejh3jv0.fsf@vitty.brq.redhat.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ming Lei <tom.leiming@gmail.com>
Cc: linux-block <linux-block@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Linux FS Devel <linux-fsdevel@vger.kernel.org>, "open list:XFS FILESYSTEM" <linux-xfs@vger.kernel.org>, Dave Chinner <dchinner@redhat.com>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Christoph Hellwig <hch@lst.de>, Jens Axboe <axboe@kernel.dk>, Ming Lei <ming.lei@redhat.com>

Ming Lei <tom.leiming@gmail.com> writes:

> Hi Guys,
>
> Some storage controllers have DMA alignment limit, which is often set via
> blk_queue_dma_alignment(), such as 512-byte alignment for IO buffer.

While mostly drivers use 512-byte alignment it is not a rule of thumb,
'git grep' tell me we have:
ide-cd.c with 32-byte alignment
ps3disk.c and rsxx/dev.c with variable alignment.

What if our block configuration consists of several devices (in raid
array, for example) with different requirements, e.g. one requiring
512-byte alignment and the other requiring 256?

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
>
> 2) If it is a rule for kmalloc-N slab to return N-byte aligned buffer,
> seems KASAN violates this
> rule?

(as I was kinda involved in debugging): the issue was observed with SLUB
allocator KASAN is not to blame, everything wich requires aditional
metadata space will break this, see e.g. calculate_sizes() in slub.c

>
> 3) If slab can't guarantee to return 512-aligned buffer, how to fix
> this data corruption issue?

I'm no expert in block layer but in case of complex block device
configurations when bio submitter can't know all the requirements I see
no other choice than bouncing.

-- 
  Vitaly
