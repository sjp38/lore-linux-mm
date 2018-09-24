Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk1-f200.google.com (mail-qk1-f200.google.com [209.85.222.200])
	by kanga.kvack.org (Postfix) with ESMTP id EED758E0001
	for <linux-mm@kvack.org>; Mon, 24 Sep 2018 05:46:08 -0400 (EDT)
Received: by mail-qk1-f200.google.com with SMTP id p192-v6so20633430qke.13
        for <linux-mm@kvack.org>; Mon, 24 Sep 2018 02:46:08 -0700 (PDT)
Received: from EUR01-VE1-obe.outbound.protection.outlook.com (mail-ve1eur01on0119.outbound.protection.outlook.com. [104.47.1.119])
        by mx.google.com with ESMTPS id r7-v6si3751662qvm.102.2018.09.24.02.46.07
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Mon, 24 Sep 2018 02:46:07 -0700 (PDT)
Subject: Re: block: DMA alignment of IO buffer allocated from slab
References: <CACVXFVOBq3L_EjSTCoiqUL1PH=HMR5EuNNQV0hNndFpGxmUK6g@mail.gmail.com>
 <20180920063129.GB12913@lst.de> <87h8ij0zot.fsf@vitty.brq.redhat.com>
 <20180923224206.GA13618@ming.t460p>
From: Andrey Ryabinin <aryabinin@virtuozzo.com>
Message-ID: <38c03920-0fd0-0a39-2a6e-70cd8cb4ef34@virtuozzo.com>
Date: Mon, 24 Sep 2018 12:46:27 +0300
MIME-Version: 1.0
In-Reply-To: <20180923224206.GA13618@ming.t460p>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ming Lei <ming.lei@redhat.com>, Vitaly Kuznetsov <vkuznets@redhat.com>
Cc: Christoph Hellwig <hch@lst.de>, Ming Lei <tom.leiming@gmail.com>, linux-block <linux-block@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Linux FS Devel <linux-fsdevel@vger.kernel.org>, "open list:XFS FILESYSTEM" <linux-xfs@vger.kernel.org>, Dave Chinner <dchinner@redhat.com>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Jens Axboe <axboe@kernel.dk>, Christoph Lameter <cl@linux.com>, Linus Torvalds <torvalds@linux-foundation.org>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>

On 09/24/2018 01:42 AM, Ming Lei wrote:
> On Fri, Sep 21, 2018 at 03:04:18PM +0200, Vitaly Kuznetsov wrote:
>> Christoph Hellwig <hch@lst.de> writes:
>>
>>> On Wed, Sep 19, 2018 at 05:15:43PM +0800, Ming Lei wrote:
>>>> 1) does kmalloc-N slab guarantee to return N-byte aligned buffer?  If
>>>> yes, is it a stable rule?
>>>
>>> This is the assumption in a lot of the kernel, so I think if somethings
>>> breaks this we are in a lot of pain.

This assumption is not correct. And it's not correct at least from the beginning of the
git era, which is even before SLUB allocator appeared. With CONFIG_DEBUG_SLAB=y
the same as with CONFIG_SLUB_DEBUG_ON=y kmalloc return 'unaligned' objects.
The guaranteed arch-and-config-independent alignment of kmalloc() result is "sizeof(void*)".

If objects has higher alignment requirement, the could be allocated via specifically created kmem_cache.


> 
> Even some of buffer address is _not_ L1 cache size aligned, this way is
> totally broken wrt. DMA to/from this buffer.
> 
> So this issue has to be fixed in slab debug side.
> 

Well, this definitely would increase memory consumption. Many (probably most) of the kmalloc()
users doesn't need such alignment, why should they pay the cost? 
