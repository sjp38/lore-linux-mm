Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id 44D4B6B025F
	for <linux-mm@kvack.org>; Tue,  8 Aug 2017 22:41:53 -0400 (EDT)
Received: by mail-pf0-f199.google.com with SMTP id b83so50516214pfl.6
        for <linux-mm@kvack.org>; Tue, 08 Aug 2017 19:41:53 -0700 (PDT)
Received: from lgeamrelo11.lge.com (LGEAMRELO11.lge.com. [156.147.23.51])
        by mx.google.com with ESMTP id n14si1681046pgu.854.2017.08.08.19.41.51
        for <linux-mm@kvack.org>;
        Tue, 08 Aug 2017 19:41:52 -0700 (PDT)
Date: Wed, 9 Aug 2017 11:41:50 +0900
From: Minchan Kim <minchan@kernel.org>
Subject: Re: [PATCH v1 2/6] fs: use on-stack-bio if backing device has
 BDI_CAP_SYNC capability
Message-ID: <20170809024150.GA32471@bbox>
References: <1502175024-28338-1-git-send-email-minchan@kernel.org>
 <1502175024-28338-3-git-send-email-minchan@kernel.org>
 <20170808124959.GB31390@bombadil.infradead.org>
 <20170808132904.GC31390@bombadil.infradead.org>
 <20170809015113.GB32338@bbox>
 <20170809023122.GF31390@bombadil.infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170809023122.GF31390@bombadil.infradead.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Matthew Wilcox <willy@infradead.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Ross Zwisler <ross.zwisler@linux.intel.com>, "karam . lee" <karam.lee@lge.com>, seungho1.park@lge.com, Christoph Hellwig <hch@lst.de>, Dan Williams <dan.j.williams@intel.com>, Dave Chinner <david@fromorbit.com>, jack@suse.cz, Jens Axboe <axboe@kernel.dk>, Vishal Verma <vishal.l.verma@intel.com>, linux-nvdimm@lists.01.org, kernel-team <kernel-team@lge.com>

On Tue, Aug 08, 2017 at 07:31:22PM -0700, Matthew Wilcox wrote:
> On Wed, Aug 09, 2017 at 10:51:13AM +0900, Minchan Kim wrote:
> > On Tue, Aug 08, 2017 at 06:29:04AM -0700, Matthew Wilcox wrote:
> > > On Tue, Aug 08, 2017 at 05:49:59AM -0700, Matthew Wilcox wrote:
> > > > +	struct bio sbio;
> > > > +	struct bio_vec sbvec;
> > > 
> > > ... this needs to be sbvec[nr_pages], of course.
> > > 
> > > > -		bio = mpage_alloc(bdev, blocks[0] << (blkbits - 9),
> > > > +		if (bdi_cap_synchronous_io(inode_to_bdi(inode))) {
> > > > +			bio = &sbio;
> > > > +			bio_init(bio, &sbvec, nr_pages);
> > > 
> > > ... and this needs to be 'sbvec', not '&sbvec'.
> > 
> > I don't get it why we need sbvec[nr_pages].
> > On-stack-bio works with per-page.
> > May I miss something?
> 
> The way I redid it, it will work with an arbitrary number of pages.

IIUC, it would be good things with dynamic bio alloction with passing
allocated bio back and forth but on-stack bio cannot work like that.
It should be done in per-page so it is worth?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
