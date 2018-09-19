Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk1-f198.google.com (mail-qk1-f198.google.com [209.85.222.198])
	by kanga.kvack.org (Postfix) with ESMTP id 08DDA8E0001
	for <linux-mm@kvack.org>; Wed, 19 Sep 2018 07:15:11 -0400 (EDT)
Received: by mail-qk1-f198.google.com with SMTP id u129-v6so3600097qkf.15
        for <linux-mm@kvack.org>; Wed, 19 Sep 2018 04:15:11 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id n13-v6si716178qvk.215.2018.09.19.04.15.09
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 19 Sep 2018 04:15:09 -0700 (PDT)
From: Vitaly Kuznetsov <vkuznets@redhat.com>
Subject: Re: block: DMA alignment of IO buffer allocated from slab
References: <CACVXFVOBq3L_EjSTCoiqUL1PH=HMR5EuNNQV0hNndFpGxmUK6g@mail.gmail.com>
	<877ejh3jv0.fsf@vitty.brq.redhat.com>
	<20180919100256.GD23172@ming.t460p>
Date: Wed, 19 Sep 2018 13:15:00 +0200
In-Reply-To: <20180919100256.GD23172@ming.t460p> (Ming Lei's message of "Wed,
	19 Sep 2018 18:02:57 +0800")
Message-ID: <8736u53fij.fsf@vitty.brq.redhat.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ming Lei <ming.lei@redhat.com>
Cc: Ming Lei <tom.leiming@gmail.com>, linux-block <linux-block@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Linux FS Devel <linux-fsdevel@vger.kernel.org>, "open list:XFS FILESYSTEM" <linux-xfs@vger.kernel.org>, Dave Chinner <dchinner@redhat.com>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Christoph Hellwig <hch@lst.de>, Jens Axboe <axboe@kernel.dk>

Ming Lei <ming.lei@redhat.com> writes:

> Hi Vitaly,
>
> On Wed, Sep 19, 2018 at 11:41:07AM +0200, Vitaly Kuznetsov wrote:
>> Ming Lei <tom.leiming@gmail.com> writes:
>> 
>> > Hi Guys,
>> >
>> > Some storage controllers have DMA alignment limit, which is often set via
>> > blk_queue_dma_alignment(), such as 512-byte alignment for IO buffer.
>> 
>> While mostly drivers use 512-byte alignment it is not a rule of thumb,
>> 'git grep' tell me we have:
>> ide-cd.c with 32-byte alignment
>> ps3disk.c and rsxx/dev.c with variable alignment.
>> 
>> What if our block configuration consists of several devices (in raid
>> array, for example) with different requirements, e.g. one requiring
>> 512-byte alignment and the other requiring 256?
>
> 512-byte alignment is also 256-byte aligned, and the sector size is 512 byte.
>

Yes, but it doesn't work the other way around, e.g. what if some device
has e.g. PAGE_SIZE alignment requirement (this would likely imply that
it's sector size is also not 512 I guess)?

>
> From the Red Hat BZ, looks I understand this issue is only triggered when
> KASAN is enabled, or you have figured out how to reproduce it without
> KASAN involved?

Yes, any SLUB debug triggers it (e.g. build your kernel with
SLUB_DEBUG_ON or slub_debug= options (Red zoning, User tracking, ... -
everything will trigger it)

>
>> 
>> >
>> > 3) If slab can't guarantee to return 512-aligned buffer, how to fix
>> > this data corruption issue?
>> 
>> I'm no expert in block layer but in case of complex block device
>> configurations when bio submitter can't know all the requirements I see
>> no other choice than bouncing.
>
> I guess that might be the last straw, given the current way without
> bouncing works for decades, and seems no one complains before.

Not many drivers have alignment requirements and not many filesystems
do requests of this kind. Another option would be to give an API to
figure out alignment requirements for the whole block stack (returning
which alignment would work for _all_ devices in the stack, not just for
one of them) and mandating that all users have to use this while
allocating buffers.

-- 
  Vitaly
