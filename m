Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id A6BC06B025F
	for <linux-mm@kvack.org>; Wed, 16 Aug 2017 00:48:03 -0400 (EDT)
Received: by mail-pf0-f199.google.com with SMTP id j83so3145456pfe.10
        for <linux-mm@kvack.org>; Tue, 15 Aug 2017 21:48:03 -0700 (PDT)
Received: from lgeamrelo13.lge.com (LGEAMRELO13.lge.com. [156.147.23.53])
        by mx.google.com with ESMTP id d22si3642077pli.530.2017.08.15.21.48.01
        for <linux-mm@kvack.org>;
        Tue, 15 Aug 2017 21:48:01 -0700 (PDT)
Date: Wed, 16 Aug 2017 13:48:00 +0900
From: Minchan Kim <minchan@kernel.org>
Subject: Re: [PATCH v1 2/6] fs: use on-stack-bio if backing device has
 BDI_CAP_SYNC capability
Message-ID: <20170816044759.GC24294@blaptop>
References: <CAA9_cmekE9_PYmNnVmiOkyH2gq5o8=uvEKnAbMWw5nBX-zE69g@mail.gmail.com>
 <20170811104615.GA14397@lst.de>
 <20c5b30a-b787-1f46-f997-7542a87033f8@kernel.dk>
 <20170814085042.GG26913@bbox>
 <51f7472a-977b-be69-2688-48f2a0fa6fb3@kernel.dk>
 <20170814150620.GA12657@bgram>
 <51893dc5-05a3-629a-3b88-ecd8e25165d0@kernel.dk>
 <20170814153059.GA13497@bgram>
 <0c83e7af-10a4-3462-bb4c-4254adcf6f7a@kernel.dk>
 <058b4ae5-c6e9-ff32-6440-fb1e1b85b6fd@kernel.dk>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <058b4ae5-c6e9-ff32-6440-fb1e1b85b6fd@kernel.dk>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jens Axboe <axboe@kernel.dk>
Cc: Christoph Hellwig <hch@lst.de>, Dan Williams <dan.j.williams@intel.com>, Matthew Wilcox <willy@infradead.org>, Andrew Morton <akpm@linux-foundation.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Ross Zwisler <ross.zwisler@linux.intel.com>, "karam . lee" <karam.lee@lge.com>, seungho1.park@lge.com, Dave Chinner <david@fromorbit.com>, Jan Kara <jack@suse.cz>, Vishal Verma <vishal.l.verma@intel.com>, "linux-nvdimm@lists.01.org" <linux-nvdimm@lists.01.org>, kernel-team <kernel-team@lge.com>

Hi Jens,

On Mon, Aug 14, 2017 at 10:17:09AM -0600, Jens Axboe wrote:
> On 08/14/2017 09:38 AM, Jens Axboe wrote:
> > On 08/14/2017 09:31 AM, Minchan Kim wrote:
> >>> Secondly, generally you don't have slow devices and fast devices
> >>> intermingled when running workloads. That's the rare case.
> >>
> >> Not true. zRam is really popular swap for embedded devices where
> >> one of low cost product has a really poor slow nand compared to
> >> lz4/lzo [de]comression.
> > 
> > I guess that's true for some cases. But as I said earlier, the recycling
> > really doesn't care about this at all. They can happily coexist, and not
> > step on each others toes.
> 
> Dusted it off, result is here against -rc5:
> 
> http://git.kernel.dk/cgit/linux-block/log/?h=cpu-alloc-cache
> 
> I'd like to split the amount of units we cache and the amount of units
> we free, right now they are both CPU_ALLOC_CACHE_SIZE. This means that
> once we hit that count, we free all of the, and then store the one we
> were asked to free. That always keeps 1 local, but maybe it'd make more
> sense to cache just free CPU_ALLOC_CACHE_SIZE/2 (or something like that)
> so that we retain more than 1 per cpu in case and app preempts when
> sleeping for IO and the new task on that CPU then issues IO as well.
> Probably minor.
> 
> Ran a quick test on nullb0 with 32 sync readers. The test was O_DIRECT
> on the block device, so I disabled the __blkdev_direct_IO_simple()
> bypass. With the above branch, we get ~18.0M IOPS, and without we get
> ~14M IOPS. Both ran with iostats disabled, to avoid any interference
> from that.

Looks promising.
If recycling bio works well enough, I think we don't need to introduce
new split in the path for on-stack bio.
I will test your version on zram-swap!

Thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
