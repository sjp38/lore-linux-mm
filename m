Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f70.google.com (mail-pg0-f70.google.com [74.125.83.70])
	by kanga.kvack.org (Postfix) with ESMTP id C0E256B025F
	for <linux-mm@kvack.org>; Mon, 14 Aug 2017 11:31:20 -0400 (EDT)
Received: by mail-pg0-f70.google.com with SMTP id 83so139972347pgb.14
        for <linux-mm@kvack.org>; Mon, 14 Aug 2017 08:31:20 -0700 (PDT)
Received: from mail-pg0-x241.google.com (mail-pg0-x241.google.com. [2607:f8b0:400e:c05::241])
        by mx.google.com with ESMTPS id z1si4294664pfd.320.2017.08.14.08.31.19
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 14 Aug 2017 08:31:19 -0700 (PDT)
Received: by mail-pg0-x241.google.com with SMTP id l64so11217357pge.2
        for <linux-mm@kvack.org>; Mon, 14 Aug 2017 08:31:19 -0700 (PDT)
Date: Tue, 15 Aug 2017 00:31:06 +0900
From: Minchan Kim <minchan@kernel.org>
Subject: Re: [PATCH v1 2/6] fs: use on-stack-bio if backing device has
 BDI_CAP_SYNC capability
Message-ID: <20170814153059.GA13497@bgram>
References: <20170809023122.GF31390@bombadil.infradead.org>
 <20170809024150.GA32471@bbox>
 <20170810030433.GG31390@bombadil.infradead.org>
 <CAA9_cmekE9_PYmNnVmiOkyH2gq5o8=uvEKnAbMWw5nBX-zE69g@mail.gmail.com>
 <20170811104615.GA14397@lst.de>
 <20c5b30a-b787-1f46-f997-7542a87033f8@kernel.dk>
 <20170814085042.GG26913@bbox>
 <51f7472a-977b-be69-2688-48f2a0fa6fb3@kernel.dk>
 <20170814150620.GA12657@bgram>
 <51893dc5-05a3-629a-3b88-ecd8e25165d0@kernel.dk>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <51893dc5-05a3-629a-3b88-ecd8e25165d0@kernel.dk>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jens Axboe <axboe@kernel.dk>
Cc: Christoph Hellwig <hch@lst.de>, Dan Williams <dan.j.williams@intel.com>, Matthew Wilcox <willy@infradead.org>, Andrew Morton <akpm@linux-foundation.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Ross Zwisler <ross.zwisler@linux.intel.com>, "karam . lee" <karam.lee@lge.com>, seungho1.park@lge.com, Dave Chinner <david@fromorbit.com>, Jan Kara <jack@suse.cz>, Vishal Verma <vishal.l.verma@intel.com>, "linux-nvdimm@lists.01.org" <linux-nvdimm@lists.01.org>, kernel-team <kernel-team@lge.com>

On Mon, Aug 14, 2017 at 09:14:03AM -0600, Jens Axboe wrote:
> On 08/14/2017 09:06 AM, Minchan Kim wrote:
> > On Mon, Aug 14, 2017 at 08:36:00AM -0600, Jens Axboe wrote:
> >> On 08/14/2017 02:50 AM, Minchan Kim wrote:
> >>> Hi Jens,
> >>>
> >>> On Fri, Aug 11, 2017 at 08:26:59AM -0600, Jens Axboe wrote:
> >>>> On 08/11/2017 04:46 AM, Christoph Hellwig wrote:
> >>>>> On Wed, Aug 09, 2017 at 08:06:24PM -0700, Dan Williams wrote:
> >>>>>> I like it, but do you think we should switch to sbvec[<constant>] to
> >>>>>> preclude pathological cases where nr_pages is large?
> >>>>>
> >>>>> Yes, please.
> >>>>>
> >>>>> Then I'd like to see that the on-stack bio even matters for
> >>>>> mpage_readpage / mpage_writepage.  Compared to all the buffer head
> >>>>> overhead the bio allocation should not actually matter in practice.
> >>>>
> >>>> I'm skeptical for that path, too. I also wonder how far we could go
> >>>> with just doing a per-cpu bio recycling facility, to reduce the cost
> >>>> of having to allocate a bio. The on-stack bio parts are fine for
> >>>> simple use case, where simple means that the patch just special
> >>>> cases the allocation, and doesn't have to change much else.
> >>>>
> >>>> I had a patch for bio recycling and batched freeing a year or two
> >>>> ago, I'll see if I can find and resurrect it.
> >>>
> >>> So, you want to go with per-cpu bio recycling approach to
> >>> remove rw_page?
> >>>
> >>> So, do you want me to hold this patchset?
> >>
> >> I don't want to hold this series up, but I do think the recycling is
> >> a cleaner approach since we don't need to special case anything. I
> >> hope I'll get some time to dust it off, retest, and post soon.
> > 
> > I don't know how your bio recycling works. But my worry when I heard
> > per-cpu bio recycling firstly is if it's not reserved pool for
> > BDI_CAP_SYNCHRONOUS(IOW, if it is shared by several storages),
> > BIOs can be consumed by slow device(e.g., eMMC) so that a bio for
> > fastest device(e.g., zram in embedded system) in the system can be
> > stucked to wait on bio until IO for slow deivce is completed.
> > 
> > I guess it would be a not rare case for swap device under severe
> > memory pressure because lots of page cache are already reclaimed when
> > anonymous page start to be reclaimed so that many BIOs can be consumed
> > for eMMC to fetch code but swap IO to fetch heap data would be stucked
> > although zram-swap is much faster than eMMC.
> > As well, time to wait to get BIO among even fastest devices is
> > simple waste, I guess.
> 
> I don't think that's a valid concern. First of all, for the recycling,
> it's not like you get to wait on someone else using a recycled bio,
> if it's not there you simply go to the regular bio allocator. There
> is no waiting for free. The idea is to have allocation be faster since
> we can avoid going to the memory allocator for most cases, and speed
> up freeing as well, since we can do that in batches too.

I doubt how it performs well because at the beginning of this
thread[1], Ross said that with even dynamic bio allocation without
rw_page, there is no regression in some testing.
[1] http://lkml.kernel.org/r/<20170728165604.10455-1-ross.zwisler@linux.intel.com>

> 
> Secondly, generally you don't have slow devices and fast devices
> intermingled when running workloads. That's the rare case.

Not true. zRam is really popular swap for embedded devices where
one of low cost product has a really poor slow nand compared to
lz4/lzo [de]comression.

> 
> > To me, bio suggested by Christoph Hellwig isn't diverge current
> > path a lot and simple enough to change.
> 
> It doesn't diverge it a lot, but it does split it up.
> 
> > Anyway, I'm okay with either way if we can remove rw_page without
> > any regression because the maintainance of both rw_page and
> > make_request is rather burden for zram, too.
> 
> Agree, the ultimate goal of both is to eliminate the need for the
> rw_page hack.

Yeb.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
