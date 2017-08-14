Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f72.google.com (mail-oi0-f72.google.com [209.85.218.72])
	by kanga.kvack.org (Postfix) with ESMTP id BB54B6B025F
	for <linux-mm@kvack.org>; Mon, 14 Aug 2017 12:17:14 -0400 (EDT)
Received: by mail-oi0-f72.google.com with SMTP id f11so11570844oic.3
        for <linux-mm@kvack.org>; Mon, 14 Aug 2017 09:17:14 -0700 (PDT)
Received: from mail-it0-x22a.google.com (mail-it0-x22a.google.com. [2607:f8b0:4001:c0b::22a])
        by mx.google.com with ESMTPS id m83si4827961oia.86.2017.08.14.09.17.13
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 14 Aug 2017 09:17:13 -0700 (PDT)
Received: by mail-it0-x22a.google.com with SMTP id 76so20320222ith.0
        for <linux-mm@kvack.org>; Mon, 14 Aug 2017 09:17:13 -0700 (PDT)
Subject: Re: [PATCH v1 2/6] fs: use on-stack-bio if backing device has
 BDI_CAP_SYNC capability
From: Jens Axboe <axboe@kernel.dk>
References: <20170809023122.GF31390@bombadil.infradead.org>
 <20170809024150.GA32471@bbox> <20170810030433.GG31390@bombadil.infradead.org>
 <CAA9_cmekE9_PYmNnVmiOkyH2gq5o8=uvEKnAbMWw5nBX-zE69g@mail.gmail.com>
 <20170811104615.GA14397@lst.de>
 <20c5b30a-b787-1f46-f997-7542a87033f8@kernel.dk>
 <20170814085042.GG26913@bbox>
 <51f7472a-977b-be69-2688-48f2a0fa6fb3@kernel.dk>
 <20170814150620.GA12657@bgram>
 <51893dc5-05a3-629a-3b88-ecd8e25165d0@kernel.dk>
 <20170814153059.GA13497@bgram>
 <0c83e7af-10a4-3462-bb4c-4254adcf6f7a@kernel.dk>
Message-ID: <058b4ae5-c6e9-ff32-6440-fb1e1b85b6fd@kernel.dk>
Date: Mon, 14 Aug 2017 10:17:09 -0600
MIME-Version: 1.0
In-Reply-To: <0c83e7af-10a4-3462-bb4c-4254adcf6f7a@kernel.dk>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>
Cc: Christoph Hellwig <hch@lst.de>, Dan Williams <dan.j.williams@intel.com>, Matthew Wilcox <willy@infradead.org>, Andrew Morton <akpm@linux-foundation.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Ross Zwisler <ross.zwisler@linux.intel.com>, "karam . lee" <karam.lee@lge.com>, seungho1.park@lge.com, Dave Chinner <david@fromorbit.com>, Jan Kara <jack@suse.cz>, Vishal Verma <vishal.l.verma@intel.com>, "linux-nvdimm@lists.01.org" <linux-nvdimm@lists.01.org>, kernel-team <kernel-team@lge.com>

On 08/14/2017 09:38 AM, Jens Axboe wrote:
> On 08/14/2017 09:31 AM, Minchan Kim wrote:
>>> Secondly, generally you don't have slow devices and fast devices
>>> intermingled when running workloads. That's the rare case.
>>
>> Not true. zRam is really popular swap for embedded devices where
>> one of low cost product has a really poor slow nand compared to
>> lz4/lzo [de]comression.
> 
> I guess that's true for some cases. But as I said earlier, the recycling
> really doesn't care about this at all. They can happily coexist, and not
> step on each others toes.

Dusted it off, result is here against -rc5:

http://git.kernel.dk/cgit/linux-block/log/?h=cpu-alloc-cache

I'd like to split the amount of units we cache and the amount of units
we free, right now they are both CPU_ALLOC_CACHE_SIZE. This means that
once we hit that count, we free all of the, and then store the one we
were asked to free. That always keeps 1 local, but maybe it'd make more
sense to cache just free CPU_ALLOC_CACHE_SIZE/2 (or something like that)
so that we retain more than 1 per cpu in case and app preempts when
sleeping for IO and the new task on that CPU then issues IO as well.
Probably minor.

Ran a quick test on nullb0 with 32 sync readers. The test was O_DIRECT
on the block device, so I disabled the __blkdev_direct_IO_simple()
bypass. With the above branch, we get ~18.0M IOPS, and without we get
~14M IOPS. Both ran with iostats disabled, to avoid any interference
from that.

-- 
Jens Axboe

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
