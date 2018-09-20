Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr1-f70.google.com (mail-wr1-f70.google.com [209.85.221.70])
	by kanga.kvack.org (Postfix) with ESMTP id C18CA8E0001
	for <linux-mm@kvack.org>; Thu, 20 Sep 2018 10:07:32 -0400 (EDT)
Received: by mail-wr1-f70.google.com with SMTP id k96-v6so9524637wrc.3
        for <linux-mm@kvack.org>; Thu, 20 Sep 2018 07:07:32 -0700 (PDT)
Received: from out002.mailprotect.be (out002.mailprotect.be. [83.217.72.86])
        by mx.google.com with ESMTPS id n201-v6si2417525wmd.195.2018.09.20.07.07.30
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 20 Sep 2018 07:07:31 -0700 (PDT)
Subject: Re: block: DMA alignment of IO buffer allocated from slab
References: <CACVXFVOBq3L_EjSTCoiqUL1PH=HMR5EuNNQV0hNndFpGxmUK6g@mail.gmail.com>
From: Bart Van Assche <bvanassche@acm.org>
Message-ID: <c5acf280-b3e3-51b3-da98-0809d9d76cc4@acm.org>
Date: Thu, 20 Sep 2018 07:07:19 -0700
MIME-Version: 1.0
In-Reply-To: <CACVXFVOBq3L_EjSTCoiqUL1PH=HMR5EuNNQV0hNndFpGxmUK6g@mail.gmail.com>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ming Lei <tom.leiming@gmail.com>, linux-block <linux-block@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Linux FS Devel <linux-fsdevel@vger.kernel.org>, "open list:XFS FILESYSTEM" <linux-xfs@vger.kernel.org>, Dave Chinner <dchinner@redhat.com>, Vitaly Kuznetsov <vkuznets@redhat.com>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>
Cc: Christoph Hellwig <hch@lst.de>, Jens Axboe <axboe@kernel.dk>, Ming Lei <ming.lei@redhat.com>

On 9/19/18 2:15 AM, Ming Lei wrote:
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
> 
> 2) If it is a rule for kmalloc-N slab to return N-byte aligned buffer,
> seems KASAN violates this
> rule?
> 
> 3) If slab can't guarantee to return 512-aligned buffer, how to fix
> this data corruption issue?

I don't think that (1) is correct, especially if N is not a power of 
two. In the skd driver I addressed this problem by using 
kmem_cache_create() and kmem_cache_alloc() instead of kmalloc(). 
kmem_cache_create() allows to specify the alignment explicitly.

Bart.
