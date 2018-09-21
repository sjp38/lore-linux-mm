Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr1-f72.google.com (mail-wr1-f72.google.com [209.85.221.72])
	by kanga.kvack.org (Postfix) with ESMTP id 1BDA68E0001
	for <linux-mm@kvack.org>; Fri, 21 Sep 2018 03:08:05 -0400 (EDT)
Received: by mail-wr1-f72.google.com with SMTP id 40-v6so11605551wrb.23
        for <linux-mm@kvack.org>; Fri, 21 Sep 2018 00:08:05 -0700 (PDT)
Received: from newverein.lst.de (verein.lst.de. [213.95.11.211])
        by mx.google.com with ESMTPS id k71-v6si4833817wmd.104.2018.09.21.00.08.03
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 21 Sep 2018 00:08:03 -0700 (PDT)
Date: Fri, 21 Sep 2018 09:08:05 +0200
From: Christoph Hellwig <hch@lst.de>
Subject: Re: block: DMA alignment of IO buffer allocated from slab
Message-ID: <20180921070805.GC14529@lst.de>
References: <CACVXFVOBq3L_EjSTCoiqUL1PH=HMR5EuNNQV0hNndFpGxmUK6g@mail.gmail.com> <20180921015608.GA31060@dastard>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180921015608.GA31060@dastard>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Chinner <david@fromorbit.com>
Cc: Ming Lei <tom.leiming@gmail.com>, linux-block <linux-block@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Linux FS Devel <linux-fsdevel@vger.kernel.org>, "open list:XFS FILESYSTEM" <linux-xfs@vger.kernel.org>, Dave Chinner <dchinner@redhat.com>, Vitaly Kuznetsov <vkuznets@redhat.com>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Christoph Hellwig <hch@lst.de>, Jens Axboe <axboe@kernel.dk>, Ming Lei <ming.lei@redhat.com>

On Fri, Sep 21, 2018 at 11:56:08AM +1000, Dave Chinner wrote:
> > 3) If slab can't guarantee to return 512-aligned buffer, how to fix
> > this data corruption issue?
> 
> I think that the block layer needs to check the alignment of memory
> buffers passed to it and take appropriate action rather than
> corrupting random memory and returning a sucess status to the bad
> bio.

Or just reject the I/O.  But yes, we already have the
queue_dma_alignment helper in the block layer, we just don't do it
in the fast path.  I think generic_make_request_checks needs to
check it, and print an error and return a warning if the alignment
requirement isn't met.
