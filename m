Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl1-f199.google.com (mail-pl1-f199.google.com [209.85.214.199])
	by kanga.kvack.org (Postfix) with ESMTP id 843838E0001
	for <linux-mm@kvack.org>; Mon, 24 Sep 2018 11:08:30 -0400 (EDT)
Received: by mail-pl1-f199.google.com with SMTP id g12-v6so10103304plo.1
        for <linux-mm@kvack.org>; Mon, 24 Sep 2018 08:08:30 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id i10-v6sor3529887pgs.421.2018.09.24.08.08.29
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 24 Sep 2018 08:08:29 -0700 (PDT)
Message-ID: <1537801706.195115.7.camel@acm.org>
Subject: Re: block: DMA alignment of IO buffer allocated from slab
From: Bart Van Assche <bvanassche@acm.org>
Date: Mon, 24 Sep 2018 08:08:26 -0700
In-Reply-To: <12eee877-affa-c822-c9d5-fda3aa0a50da@virtuozzo.com>
References: 
	<CACVXFVOBq3L_EjSTCoiqUL1PH=HMR5EuNNQV0hNndFpGxmUK6g@mail.gmail.com>
	 <20180920063129.GB12913@lst.de> <87h8ij0zot.fsf@vitty.brq.redhat.com>
	 <20180923224206.GA13618@ming.t460p>
	 <38c03920-0fd0-0a39-2a6e-70cd8cb4ef34@virtuozzo.com>
	 <20a20568-5089-541d-3cee-546e549a0bc8@acm.org>
	 <12eee877-affa-c822-c9d5-fda3aa0a50da@virtuozzo.com>
Content-Type: text/plain; charset="UTF-7"
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrey Ryabinin <aryabinin@virtuozzo.com>, Ming Lei <ming.lei@redhat.com>, Vitaly Kuznetsov <vkuznets@redhat.com>
Cc: Christoph Hellwig <hch@lst.de>, Ming Lei <tom.leiming@gmail.com>, linux-block <linux-block@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Linux FS Devel <linux-fsdevel@vger.kernel.org>, "open list:XFS FILESYSTEM" <linux-xfs@vger.kernel.org>, Dave Chinner <dchinner@redhat.com>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Jens Axboe <axboe@kernel.dk>, Christoph Lameter <cl@linux.com>, Linus Torvalds <torvalds@linux-foundation.org>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>

On Mon, 2018-09-24 at 17:43 +-0300, Andrey Ryabinin wrote:
+AD4 
+AD4 On 09/24/2018 05:19 PM, Bart Van Assche wrote:
+AD4 +AD4 On 9/24/18 2:46 AM, Andrey Ryabinin wrote:
+AD4 +AD4 +AD4 On 09/24/2018 01:42 AM, Ming Lei wrote:
+AD4 +AD4 +AD4 +AD4 On Fri, Sep 21, 2018 at 03:04:18PM +-0200, Vitaly Kuznetsov wrote:
+AD4 +AD4 +AD4 +AD4 +AD4 Christoph Hellwig +ADw-hch+AEA-lst.de+AD4 writes:
+AD4 +AD4 +AD4 +AD4 +AD4 
+AD4 +AD4 +AD4 +AD4 +AD4 +AD4 On Wed, Sep 19, 2018 at 05:15:43PM +-0800, Ming Lei wrote:
+AD4 +AD4 +AD4 +AD4 +AD4 +AD4 +AD4 1) does kmalloc-N slab guarantee to return N-byte aligned buffer?  If
+AD4 +AD4 +AD4 +AD4 +AD4 +AD4 +AD4 yes, is it a stable rule?
+AD4 +AD4 +AD4 +AD4 +AD4 +AD4 
+AD4 +AD4 +AD4 +AD4 +AD4 +AD4 This is the assumption in a lot of the kernel, so I think if somethings
+AD4 +AD4 +AD4 +AD4 +AD4 +AD4 breaks this we are in a lot of pain.
+AD4 +AD4 +AD4 
+AD4 +AD4 +AD4 This assumption is not correct. And it's not correct at least from the beginning of the
+AD4 +AD4 +AD4 git era, which is even before SLUB allocator appeared. With CONFIG+AF8-DEBUG+AF8-SLAB+AD0-y
+AD4 +AD4 +AD4 the same as with CONFIG+AF8-SLUB+AF8-DEBUG+AF8-ON+AD0-y kmalloc return 'unaligned' objects.
+AD4 +AD4 +AD4 The guaranteed arch-and-config-independent alignment of kmalloc() result is +ACI-sizeof(void+ACo)+ACI.
+AD4 
+AD4 Correction sizeof(unsigned long long), so 8-byte alignment guarantee.
+AD4 
+AD4 +AD4 +AD4 
+AD4 +AD4 +AD4 If objects has higher alignment requirement, the could be allocated via specifically created kmem+AF8-cache.
+AD4 +AD4 
+AD4 +AD4 Hello Andrey,
+AD4 +AD4 
+AD4 +AD4 The above confuses me. Can you explain to me why the following comment is present in include/linux/slab.h?
+AD4 +AD4 
+AD4 +AD4 /+ACo
+AD4 +AD4  +ACo kmalloc and friends return ARCH+AF8-KMALLOC+AF8-MINALIGN aligned
+AD4 +AD4  +ACo pointers. kmem+AF8-cache+AF8-alloc and friends return ARCH+AF8-SLAB+AF8-MINALIGN
+AD4 +AD4  +ACo aligned pointers.
+AD4 +AD4  +ACo-/
+AD4 +AD4 
+AD4 
+AD4 ARCH+AF8-KMALLOC+AF8-MINALIGN - guaranteed alignment of the kmalloc() result.
+AD4 ARCH+AF8-SLAB+AF8-MINALIGN - guaranteed alignment of kmem+AF8-cache+AF8-alloc() result.
+AD4 
+AD4 If the 'align' argument passed into kmem+AF8-cache+AF8-create() is bigger than ARCH+AF8-SLAB+AF8-MINALIGN
+AD4 than kmem+AF8-cache+AF8-alloc() from that cache should return 'align'-aligned pointers.

Hello Andrey,

Do you realize that that comment from +ADw-linux/slab.h+AD4 contradicts what you
wrote about kmalloc() if ARCH+AF8-KMALLOC+AF8-MINALIGN +AD4 sizeof(unsigned long long)?

Additionally, shouldn't CONFIG+AF8-DEBUG+AF8-SLAB+AD0-y and CONFIG+AF8-SLUB+AF8-DEBUG+AF8-ON+AD0-y
provide the same guarantees as with debugging disabled, namely that kmalloc()
buffers are aligned on ARCH+AF8-KMALLOC+AF8-MINALIGN boundaries? Since buffers
allocated with kmalloc() are often used for DMA, how otherwise is DMA assumed
to work?

Thanks,

Bart.
