Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f178.google.com (mail-pd0-f178.google.com [209.85.192.178])
	by kanga.kvack.org (Postfix) with ESMTP id 586366B0031
	for <linux-mm@kvack.org>; Thu, 10 Apr 2014 10:16:55 -0400 (EDT)
Received: by mail-pd0-f178.google.com with SMTP id x10so3936665pdj.9
        for <linux-mm@kvack.org>; Thu, 10 Apr 2014 07:16:54 -0700 (PDT)
Received: from mga02.intel.com (mga02.intel.com. [134.134.136.20])
        by mx.google.com with ESMTP id h3si2280220paw.414.2014.04.10.07.16.53
        for <linux-mm@kvack.org>;
        Thu, 10 Apr 2014 07:16:54 -0700 (PDT)
Date: Thu, 10 Apr 2014 10:16:30 -0400
From: Matthew Wilcox <willy@linux.intel.com>
Subject: Re: [PATCH v7 11/22] Replace ext2_clear_xip_target with
 dax_clear_blocks
Message-ID: <20140410141630.GH5727@linux.intel.com>
References: <cover.1395591795.git.matthew.r.wilcox@intel.com>
 <b94af75d7123feced8ea8ba42d1d0e7c740d5009.1395591795.git.matthew.r.wilcox@intel.com>
 <20140409094644.GD32103@quack.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20140409094644.GD32103@quack.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jan Kara <jack@suse.cz>
Cc: Matthew Wilcox <matthew.r.wilcox@intel.com>, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Wed, Apr 09, 2014 at 11:46:44AM +0200, Jan Kara wrote:
>   Another day, some more review ;) Comments below.

I'm really grateful for all this review!  It's killing me, though ;-)

> > +int dax_clear_blocks(struct inode *inode, sector_t block, long size)
> > +{
> > +	struct block_device *bdev = inode->i_sb->s_bdev;
> > +	const struct block_device_operations *ops = bdev->bd_disk->fops;
> > +	sector_t sector = block << (inode->i_blkbits - 9);
> > +	unsigned long pfn;
> > +
> > +	might_sleep();
> > +	do {
> > +		void *addr;
> > +		long count = ops->direct_access(bdev, sector, &addr, &pfn,
> > +									size);
>   So do you assume blocksize == PAGE_SIZE here? If not, addr could be in
> the middle of the page AFAICT.

You're right.  Depending on how clear_page() is implemented, that
might go badly wrong.  Of course, both ext2 & ext4 require block_size
== PAGE_SIZE right now, so anything else is by definition untested.
I've been trying to keep DAX free from that assumption, but obviously
haven't caught all the places.

How does this look?

typedef long (*direct_access_t)(struct block_device *, sector_t, void **,
                                unsigned long *pfn, long size);

int dax_clear_blocks(struct inode *inode, sector_t block, long size)
{
        struct block_device *bdev = inode->i_sb->s_bdev;
        direct_access_t direct_access = bdev->bd_disk->fops->direct_access;
        sector_t sector = block << (inode->i_blkbits - 9);
        unsigned long pfn;

        might_sleep();
        do {
                void *addr;
                long count = direct_access(bdev, sector, &addr, &pfn, size);
                if (count < 0)
                        return count;
                while (count > 0) {
                        unsigned pgsz = PAGE_SIZE - offset_in_page(addr);
                        if (pgsz > count)
                                pgsz = count;
                        if (pgsz < PAGE_SIZE)
                                memset(addr, 0, pgsz);
                        else
                                clear_page(addr);
                        addr += pgsz;
                        size -= pgsz;
                        count -= pgsz;
                        sector += pgsz / 512;
                        cond_resched();
                }
        } while (size);

        return 0;
}
EXPORT_SYMBOL_GPL(dax_clear_blocks);

> >  	if (IS_DAX(inode)) {
> >  		/*
> > -		 * we need to clear the block
> > +		 * block must be initialised before we put it in the tree
> > +		 * so that it's not found by another thread before it's
> > +		 * initialised
> >  		 */
> > -		err = ext2_clear_xip_target (inode,
> > -			le32_to_cpu(chain[depth-1].key));
> > +		err = dax_clear_blocks(inode, le32_to_cpu(chain[depth-1].key),
> > +						count << inode->i_blkbits);
>   Umm 'count' looks wrong here. You want to clear only one block, don't
> you?

I think I got confused between ext2 and ext4 here.  I do want to clear
only one block.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
