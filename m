Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk1-f197.google.com (mail-qk1-f197.google.com [209.85.222.197])
	by kanga.kvack.org (Postfix) with ESMTP id 6D82D8E0001
	for <linux-mm@kvack.org>; Wed, 19 Sep 2018 21:28:53 -0400 (EDT)
Received: by mail-qk1-f197.google.com with SMTP id 123-v6so5519471qkl.3
        for <linux-mm@kvack.org>; Wed, 19 Sep 2018 18:28:53 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id l29-v6si1146670qta.53.2018.09.19.18.28.52
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 19 Sep 2018 18:28:52 -0700 (PDT)
Date: Thu, 20 Sep 2018 09:28:37 +0800
From: Ming Lei <ming.lei@redhat.com>
Subject: Re: block: DMA alignment of IO buffer allocated from slab
Message-ID: <20180920012836.GA27645@ming.t460p>
References: <CACVXFVOBq3L_EjSTCoiqUL1PH=HMR5EuNNQV0hNndFpGxmUK6g@mail.gmail.com>
 <877ejh3jv0.fsf@vitty.brq.redhat.com>
 <20180919100256.GD23172@ming.t460p>
 <8736u53fij.fsf@vitty.brq.redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <8736u53fij.fsf@vitty.brq.redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vitaly Kuznetsov <vkuznets@redhat.com>, Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Andrew Morton <akpm@linux-foundation.org>
Cc: Ming Lei <tom.leiming@gmail.com>, linux-block <linux-block@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Linux FS Devel <linux-fsdevel@vger.kernel.org>, "open list:XFS FILESYSTEM" <linux-xfs@vger.kernel.org>, Dave Chinner <dchinner@redhat.com>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Christoph Hellwig <hch@lst.de>, Jens Axboe <axboe@kernel.dk>

On Wed, Sep 19, 2018 at 01:15:00PM +0200, Vitaly Kuznetsov wrote:
> Ming Lei <ming.lei@redhat.com> writes:
> 
> > Hi Vitaly,
> >
> > On Wed, Sep 19, 2018 at 11:41:07AM +0200, Vitaly Kuznetsov wrote:
> >> Ming Lei <tom.leiming@gmail.com> writes:
> >> 
> >> > Hi Guys,
> >> >
> >> > Some storage controllers have DMA alignment limit, which is often set via
> >> > blk_queue_dma_alignment(), such as 512-byte alignment for IO buffer.
> >> 
> >> While mostly drivers use 512-byte alignment it is not a rule of thumb,
> >> 'git grep' tell me we have:
> >> ide-cd.c with 32-byte alignment
> >> ps3disk.c and rsxx/dev.c with variable alignment.
> >> 
> >> What if our block configuration consists of several devices (in raid
> >> array, for example) with different requirements, e.g. one requiring
> >> 512-byte alignment and the other requiring 256?
> >
> > 512-byte alignment is also 256-byte aligned, and the sector size is 512 byte.
> >
> 
> Yes, but it doesn't work the other way around, e.g. what if some device
> has e.g. PAGE_SIZE alignment requirement (this would likely imply that
> it's sector size is also not 512 I guess)?

Yeah, that can be true if one controller has 4k-byte sector size, also
its DMA alignment is 4K. But there shouldn't be cases in which the two
doesn't match.

> 
> >
> > From the Red Hat BZ, looks I understand this issue is only triggered when
> > KASAN is enabled, or you have figured out how to reproduce it without
> > KASAN involved?
> 
> Yes, any SLUB debug triggers it (e.g. build your kernel with
> SLUB_DEBUG_ON or slub_debug= options (Red zoning, User tracking, ... -
> everything will trigger it)

That means the slab always return 512-byte aligned buffer if the buffer
size is 512byte in case of no any slab debug options enabled.

The question is that if it is one reliable rule in slab. If yes, any
slab debug option does violate the rule.

The same is true for 4k alignment and 4k sector size.

I think we need our MM guys to clarify this point.


Thanks,
Ming
