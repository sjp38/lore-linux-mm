Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f48.google.com (mail-pa0-f48.google.com [209.85.220.48])
	by kanga.kvack.org (Postfix) with ESMTP id 90F496B0035
	for <linux-mm@kvack.org>; Wed, 30 Jul 2014 15:45:07 -0400 (EDT)
Received: by mail-pa0-f48.google.com with SMTP id et14so2099480pad.35
        for <linux-mm@kvack.org>; Wed, 30 Jul 2014 12:45:06 -0700 (PDT)
Received: from mga03.intel.com (mga03.intel.com. [143.182.124.21])
        by mx.google.com with ESMTP id uz1si3416476pac.88.2014.07.30.12.45.05
        for <linux-mm@kvack.org>;
        Wed, 30 Jul 2014 12:45:06 -0700 (PDT)
Date: Wed, 30 Jul 2014 15:45:03 -0400
From: Matthew Wilcox <willy@linux.intel.com>
Subject: Re: [PATCH v8 04/22] Change direct_access calling convention
Message-ID: <20140730194503.GQ6754@linux.intel.com>
References: <cover.1406058387.git.matthew.r.wilcox@intel.com>
 <b78b33d94b669a5fbd02e06f2493b43dd5d77698.1406058387.git.matthew.r.wilcox@intel.com>
 <53D9174C.7040906@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <53D9174C.7040906@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Boaz Harrosh <openosd@gmail.com>
Cc: Matthew Wilcox <matthew.r.wilcox@intel.com>, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Wed, Jul 30, 2014 at 07:03:24PM +0300, Boaz Harrosh wrote:
> > +long bdev_direct_access(struct block_device *bdev, sector_t sector,
> > +			void **addr, unsigned long *pfn, long size)
> > +{
> > +	const struct block_device_operations *ops = bdev->bd_disk->fops;
> > +	if (!ops->direct_access)
> > +		return -EOPNOTSUPP;
> 
> You need to check alignment on PAGE_SIZE since this API requires it, do
> to pfn defined to a page_number.
> 
> (Unless you want to define another output-param like page_offset.
>  but this exercise can be left to the caller)
> 
> You also need to check against the partition boundary. so something like:
> 
> + 	if (sector & (PAGE_SECTORS-1))
> + 		return -EINVAL;

Mmm.  PAGE_SECTORS is private to brd (and also private to bcache!) at
this point.  We've got a real mess of defines of SECTOR_SIZE, SECTORSIZE,
SECTOR_SHIFT and so on, dotted throughout various random include files.
I am not the river to flush those Augean stables today.

I'll go with this, from the dcssblk driver:

        if (sector % (PAGE_SIZE / 512))
                return -EINVAL;

> +	if (unlikely(sector + size > part_nr_sects_read(bdev->bd_part)))
> + 		return -ERANGE;
> 
> Then perhaps you can remove that check from drivers

As noted in your followup, size is in terms of bytes.  Perhaps it should
be named 'length' to make it more clear that it's a byte count, not a
sector count?

In any case, this looks best to me:

        if ((sector + DIV_ROUND_UP(size, 512)) >
                                        part_nr_sects_read(bdev->bd_part))
                return -ERANGE;


> Style: Need a space between declaration and code (have you check-patch)

That's a bullshit check.  I don't know why it's in checkpatch.

> > +	if (size < 0)
> 
> 	if(size < PAGE_SIZE), No?

No, absolutely not.  PAGE_SIZE is unsigned long, which (if I understand
my C integer promotions correctly) means that 'size' gets promoted to
an unsigned long, and we compare them unsigned, so errors will never be
caught by this check.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
