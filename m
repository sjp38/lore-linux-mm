Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f71.google.com (mail-pg0-f71.google.com [74.125.83.71])
	by kanga.kvack.org (Postfix) with ESMTP id C00A46B02F3
	for <linux-mm@kvack.org>; Tue,  8 Aug 2017 21:51:21 -0400 (EDT)
Received: by mail-pg0-f71.google.com with SMTP id s14so51799732pgs.4
        for <linux-mm@kvack.org>; Tue, 08 Aug 2017 18:51:21 -0700 (PDT)
Received: from lgeamrelo11.lge.com (LGEAMRELO11.lge.com. [156.147.23.51])
        by mx.google.com with ESMTP id x33si1779886plb.216.2017.08.08.18.51.20
        for <linux-mm@kvack.org>;
        Tue, 08 Aug 2017 18:51:20 -0700 (PDT)
Date: Wed, 9 Aug 2017 10:51:13 +0900
From: Minchan Kim <minchan@kernel.org>
Subject: Re: [PATCH v1 2/6] fs: use on-stack-bio if backing device has
 BDI_CAP_SYNC capability
Message-ID: <20170809015113.GB32338@bbox>
References: <1502175024-28338-1-git-send-email-minchan@kernel.org>
 <1502175024-28338-3-git-send-email-minchan@kernel.org>
 <20170808124959.GB31390@bombadil.infradead.org>
 <20170808132904.GC31390@bombadil.infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170808132904.GC31390@bombadil.infradead.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Matthew Wilcox <willy@infradead.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Ross Zwisler <ross.zwisler@linux.intel.com>, "karam . lee" <karam.lee@lge.com>, seungho1.park@lge.com, Christoph Hellwig <hch@lst.de>, Dan Williams <dan.j.williams@intel.com>, Dave Chinner <david@fromorbit.com>, jack@suse.cz, Jens Axboe <axboe@kernel.dk>, Vishal Verma <vishal.l.verma@intel.com>, linux-nvdimm@lists.01.org, kernel-team <kernel-team@lge.com>

On Tue, Aug 08, 2017 at 06:29:04AM -0700, Matthew Wilcox wrote:
> On Tue, Aug 08, 2017 at 05:49:59AM -0700, Matthew Wilcox wrote:
> > +	struct bio sbio;
> > +	struct bio_vec sbvec;
> 
> ... this needs to be sbvec[nr_pages], of course.
> 
> > -		bio = mpage_alloc(bdev, blocks[0] << (blkbits - 9),
> > +		if (bdi_cap_synchronous_io(inode_to_bdi(inode))) {
> > +			bio = &sbio;
> > +			bio_init(bio, &sbvec, nr_pages);
> 
> ... and this needs to be 'sbvec', not '&sbvec'.

I don't get it why we need sbvec[nr_pages].
On-stack-bio works with per-page.
May I miss something?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
