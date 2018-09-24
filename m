Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io1-f72.google.com (mail-io1-f72.google.com [209.85.166.72])
	by kanga.kvack.org (Postfix) with ESMTP id A88F98E0001
	for <linux-mm@kvack.org>; Mon, 24 Sep 2018 13:49:40 -0400 (EDT)
Received: by mail-io1-f72.google.com with SMTP id a3-v6so40836134iod.23
        for <linux-mm@kvack.org>; Mon, 24 Sep 2018 10:49:40 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id t3-v6sor5132841jaj.78.2018.09.24.10.49.39
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 24 Sep 2018 10:49:39 -0700 (PDT)
Subject: Re: block: DMA alignment of IO buffer allocated from slab
References: <CACVXFVOBq3L_EjSTCoiqUL1PH=HMR5EuNNQV0hNndFpGxmUK6g@mail.gmail.com>
 <20180920063129.GB12913@lst.de> <87h8ij0zot.fsf@vitty.brq.redhat.com>
 <20180921130504.GA22551@lst.de>
 <010001660c54fb65-b9d3a770-6678-40d0-8088-4db20af32280-000000@email.amazonses.com>
From: Jens Axboe <axboe@kernel.dk>
Message-ID: <1f88f59a-2cac-e899-4c2e-402e919b1034@kernel.dk>
Date: Mon, 24 Sep 2018 11:49:36 -0600
MIME-Version: 1.0
In-Reply-To: <010001660c54fb65-b9d3a770-6678-40d0-8088-4db20af32280-000000@email.amazonses.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christopher Lameter <cl@linux.com>, Christoph Hellwig <hch@lst.de>
Cc: Vitaly Kuznetsov <vkuznets@redhat.com>, Ming Lei <tom.leiming@gmail.com>, linux-block <linux-block@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Linux FS Devel <linux-fsdevel@vger.kernel.org>, "open list:XFS FILESYSTEM" <linux-xfs@vger.kernel.org>, Dave Chinner <dchinner@redhat.com>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Ming Lei <ming.lei@redhat.com>

On 9/24/18 10:06 AM, Christopher Lameter wrote:
> On Fri, 21 Sep 2018, Christoph Hellwig wrote:
> 
>> On Fri, Sep 21, 2018 at 03:04:18PM +0200, Vitaly Kuznetsov wrote:
>>> Christoph Hellwig <hch@lst.de> writes:
>>>
>>>> On Wed, Sep 19, 2018 at 05:15:43PM +0800, Ming Lei wrote:
>>>>> 1) does kmalloc-N slab guarantee to return N-byte aligned buffer?  If
>>>>> yes, is it a stable rule?
>>>>
>>>> This is the assumption in a lot of the kernel, so I think if somethings
>>>> breaks this we are in a lot of pain.
>>>
>>> It seems that SLUB debug breaks this assumption. Kernel built with
>>>
>>> CONFIG_SLUB_DEBUG=y
>>> CONFIG_SLUB=y
>>> CONFIG_SLUB_DEBUG_ON=y
>>
>> Looks like we should fix SLUB debug then..
> 
> Nope. We need to not make unwarranted assumptions. Alignment is guaranteed
> to ARCH_KMALLOC_MINALIGN for kmalloc requests. Fantasizing about
> alighments and guessing from alignments that result on a particular
> hardware and slab configuration that these are general does not work.

The summary is that, no, kmalloc(N) is not N-1 aligned and nobody should
rely on that. On the block side, a few drivers set DMA alignment to
the sector size. Given that things seem to Just Work, even with XFS doing
kmalloc(512) and submitting IO with that, I think we can fairly safely
assume that most of those drivers are just being overly cautious and are
probably quite fine with 4/8 byte alignment.

The situation is making me a little uncomfortable, though. If we export
such a setting, we really should be honoring it...

-- 
Jens Axboe
