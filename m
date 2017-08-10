Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f72.google.com (mail-pg0-f72.google.com [74.125.83.72])
	by kanga.kvack.org (Postfix) with ESMTP id 203796B0292
	for <linux-mm@kvack.org>; Wed,  9 Aug 2017 23:04:39 -0400 (EDT)
Received: by mail-pg0-f72.google.com with SMTP id s14so83738297pgs.4
        for <linux-mm@kvack.org>; Wed, 09 Aug 2017 20:04:39 -0700 (PDT)
Received: from bombadil.infradead.org (bombadil.infradead.org. [65.50.211.133])
        by mx.google.com with ESMTPS id r63si3650583plb.349.2017.08.09.20.04.37
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 09 Aug 2017 20:04:37 -0700 (PDT)
Date: Wed, 9 Aug 2017 20:04:33 -0700
From: Matthew Wilcox <willy@infradead.org>
Subject: Re: [PATCH v1 2/6] fs: use on-stack-bio if backing device has
 BDI_CAP_SYNC capability
Message-ID: <20170810030433.GG31390@bombadil.infradead.org>
References: <1502175024-28338-1-git-send-email-minchan@kernel.org>
 <1502175024-28338-3-git-send-email-minchan@kernel.org>
 <20170808124959.GB31390@bombadil.infradead.org>
 <20170808132904.GC31390@bombadil.infradead.org>
 <20170809015113.GB32338@bbox>
 <20170809023122.GF31390@bombadil.infradead.org>
 <20170809024150.GA32471@bbox>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170809024150.GA32471@bbox>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Ross Zwisler <ross.zwisler@linux.intel.com>, "karam . lee" <karam.lee@lge.com>, seungho1.park@lge.com, Christoph Hellwig <hch@lst.de>, Dan Williams <dan.j.williams@intel.com>, Dave Chinner <david@fromorbit.com>, jack@suse.cz, Jens Axboe <axboe@kernel.dk>, Vishal Verma <vishal.l.verma@intel.com>, linux-nvdimm@lists.01.org, kernel-team <kernel-team@lge.com>

On Wed, Aug 09, 2017 at 11:41:50AM +0900, Minchan Kim wrote:
> On Tue, Aug 08, 2017 at 07:31:22PM -0700, Matthew Wilcox wrote:
> > On Wed, Aug 09, 2017 at 10:51:13AM +0900, Minchan Kim wrote:
> > > On Tue, Aug 08, 2017 at 06:29:04AM -0700, Matthew Wilcox wrote:
> > > > On Tue, Aug 08, 2017 at 05:49:59AM -0700, Matthew Wilcox wrote:
> > > > > +	struct bio sbio;
> > > > > +	struct bio_vec sbvec;
> > > > 
> > > > ... this needs to be sbvec[nr_pages], of course.
> > > > 
> > > > > -		bio = mpage_alloc(bdev, blocks[0] << (blkbits - 9),
> > > > > +		if (bdi_cap_synchronous_io(inode_to_bdi(inode))) {
> > > > > +			bio = &sbio;
> > > > > +			bio_init(bio, &sbvec, nr_pages);
> > > > 
> > > > ... and this needs to be 'sbvec', not '&sbvec'.
> > > 
> > > I don't get it why we need sbvec[nr_pages].
> > > On-stack-bio works with per-page.
> > > May I miss something?
> > 
> > The way I redid it, it will work with an arbitrary number of pages.
> 
> IIUC, it would be good things with dynamic bio alloction with passing
> allocated bio back and forth but on-stack bio cannot work like that.
> It should be done in per-page so it is worth?

I'm not passing the bio back and forth between do_mpage_readpage() and
its callers.  The version I sent allows for multiple pages in a single
on-stack bio (when called from mpage_readpages()).

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
