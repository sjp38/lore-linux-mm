Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg1-f197.google.com (mail-pg1-f197.google.com [209.85.215.197])
	by kanga.kvack.org (Postfix) with ESMTP id C51068E0001
	for <linux-mm@kvack.org>; Mon, 24 Sep 2018 12:19:48 -0400 (EDT)
Received: by mail-pg1-f197.google.com with SMTP id l65-v6so7904755pge.17
        for <linux-mm@kvack.org>; Mon, 24 Sep 2018 09:19:48 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id t16-v6sor5780666pfh.9.2018.09.24.09.19.47
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 24 Sep 2018 09:19:47 -0700 (PDT)
Message-ID: <1537805984.195115.14.camel@acm.org>
Subject: Re: block: DMA alignment of IO buffer allocated from slab
From: Bart Van Assche <bvanassche@acm.org>
Date: Mon, 24 Sep 2018 09:19:44 -0700
In-Reply-To: <10c706fd-2252-f11b-312e-ae0d97d9a538@virtuozzo.com>
References: 
	<CACVXFVOBq3L_EjSTCoiqUL1PH=HMR5EuNNQV0hNndFpGxmUK6g@mail.gmail.com>
	 <20180920063129.GB12913@lst.de> <87h8ij0zot.fsf@vitty.brq.redhat.com>
	 <20180923224206.GA13618@ming.t460p>
	 <38c03920-0fd0-0a39-2a6e-70cd8cb4ef34@virtuozzo.com>
	 <20a20568-5089-541d-3cee-546e549a0bc8@acm.org>
	 <12eee877-affa-c822-c9d5-fda3aa0a50da@virtuozzo.com>
	 <1537801706.195115.7.camel@acm.org>
	 <c844c598-be1d-bef4-fb99-09cf99571fd7@virtuozzo.com>
	 <1537804720.195115.9.camel@acm.org>
	 <10c706fd-2252-f11b-312e-ae0d97d9a538@virtuozzo.com>
Content-Type: text/plain; charset="UTF-7"
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrey Ryabinin <aryabinin@virtuozzo.com>, Ming Lei <ming.lei@redhat.com>, Vitaly Kuznetsov <vkuznets@redhat.com>
Cc: Christoph Hellwig <hch@lst.de>, Ming Lei <tom.leiming@gmail.com>, linux-block <linux-block@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Linux FS Devel <linux-fsdevel@vger.kernel.org>, "open list:XFS FILESYSTEM" <linux-xfs@vger.kernel.org>, Dave Chinner <dchinner@redhat.com>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Jens Axboe <axboe@kernel.dk>, Christoph Lameter <cl@linux.com>, Linus Torvalds <torvalds@linux-foundation.org>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>

On Mon, 2018-09-24 at 19:07 +-0300, Andrey Ryabinin wrote:
+AD4 On 09/24/2018 06:58 PM, Bart Van Assche wrote:
+AD4 +AD4 On Mon, 2018-09-24 at 18:52 +-0300, Andrey Ryabinin wrote:
+AD4 +AD4 +AD4 Yes, with CONFIG+AF8-DEBUG+AF8-SLAB+AD0-y, CONFIG+AF8-SLUB+AF8-DEBUG+AF8-ON+AD0-y kmalloc() guarantees
+AD4 +AD4 +AD4 that result is aligned on ARCH+AF8-KMALLOC+AF8-MINALIGN boundary.
+AD4 +AD4 
+AD4 +AD4 Had you noticed that Vitaly Kuznetsov showed that this is not the case? See
+AD4 +AD4 also https://lore.kernel.org/lkml/87h8ij0zot.fsf+AEA-vitty.brq.redhat.com/.
+AD4 
+AD4 I'm not following. On x86-64 ARCH+AF8-KMALLOC+AF8-MINALIGN is 8, all pointers that
+AD4 Vitaly Kuznetsov showed are 8-byte aligned.

Hi Andrey,

That means that two buffers allocated with kmalloc() may share a cache line on
x86-64. Since it is allowed to use a buffer allocated by kmalloc() for DMA, can
this lead to data corruption, e.g. if the CPU writes into one buffer allocated
with kmalloc() and a device performs a DMA write to another kmalloc() buffer and
both write operations affect the same cache line?

Thanks,

Bart.
