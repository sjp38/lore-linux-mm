Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ee0-f44.google.com (mail-ee0-f44.google.com [74.125.83.44])
	by kanga.kvack.org (Postfix) with ESMTP id BCE686B0035
	for <linux-mm@kvack.org>; Thu, 10 Apr 2014 14:31:09 -0400 (EDT)
Received: by mail-ee0-f44.google.com with SMTP id e49so3317719eek.17
        for <linux-mm@kvack.org>; Thu, 10 Apr 2014 11:31:07 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id 43si7060355eei.265.2014.04.10.11.31.06
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Thu, 10 Apr 2014 11:31:06 -0700 (PDT)
Date: Thu, 10 Apr 2014 20:31:04 +0200
From: Jan Kara <jack@suse.cz>
Subject: Re: [PATCH v7 11/22] Replace ext2_clear_xip_target with
 dax_clear_blocks
Message-ID: <20140410183104.GA8060@quack.suse.cz>
References: <cover.1395591795.git.matthew.r.wilcox@intel.com>
 <b94af75d7123feced8ea8ba42d1d0e7c740d5009.1395591795.git.matthew.r.wilcox@intel.com>
 <20140409094644.GD32103@quack.suse.cz>
 <20140410141630.GH5727@linux.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20140410141630.GH5727@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Matthew Wilcox <willy@linux.intel.com>
Cc: Jan Kara <jack@suse.cz>, Matthew Wilcox <matthew.r.wilcox@intel.com>, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Thu 10-04-14 10:16:30, Matthew Wilcox wrote:
> On Wed, Apr 09, 2014 at 11:46:44AM +0200, Jan Kara wrote:
> >   Another day, some more review ;) Comments below.
> 
> I'm really grateful for all this review!  It's killing me, though ;-)
  Yeah, I know that feeling. :)

> > > +int dax_clear_blocks(struct inode *inode, sector_t block, long size)
> > > +{
> > > +	struct block_device *bdev = inode->i_sb->s_bdev;
> > > +	const struct block_device_operations *ops = bdev->bd_disk->fops;
> > > +	sector_t sector = block << (inode->i_blkbits - 9);
> > > +	unsigned long pfn;
> > > +
> > > +	might_sleep();
> > > +	do {
> > > +		void *addr;
> > > +		long count = ops->direct_access(bdev, sector, &addr, &pfn,
> > > +									size);
> >   So do you assume blocksize == PAGE_SIZE here? If not, addr could be in
> > the middle of the page AFAICT.
> 
> You're right.  Depending on how clear_page() is implemented, that
> might go badly wrong.  Of course, both ext2 & ext4 require block_size
> == PAGE_SIZE right now, so anything else is by definition untested.
> I've been trying to keep DAX free from that assumption, but obviously
> haven't caught all the places.
> 
> How does this look?
  That looks fine.

								Honza
-- 
Jan Kara <jack@suse.cz>
SUSE Labs, CR

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
