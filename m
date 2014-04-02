Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f52.google.com (mail-pa0-f52.google.com [209.85.220.52])
	by kanga.kvack.org (Postfix) with ESMTP id E58246B00F2
	for <linux-mm@kvack.org>; Wed,  2 Apr 2014 15:28:02 -0400 (EDT)
Received: by mail-pa0-f52.google.com with SMTP id rd3so637464pab.39
        for <linux-mm@kvack.org>; Wed, 02 Apr 2014 12:28:02 -0700 (PDT)
Received: from mga11.intel.com (mga11.intel.com. [192.55.52.93])
        by mx.google.com with ESMTP id ta1si1822034pab.31.2014.04.02.12.28.01
        for <linux-mm@kvack.org>;
        Wed, 02 Apr 2014 12:28:01 -0700 (PDT)
Date: Wed, 2 Apr 2014 15:27:59 -0400
From: Matthew Wilcox <willy@linux.intel.com>
Subject: Re: [PATCH v7 04/22] Change direct_access calling convention
Message-ID: <20140402192759.GD27299@linux.intel.com>
References: <cover.1395591795.git.matthew.r.wilcox@intel.com>
 <214af2a38d840d0b8e983d39d03711d1292bc2d6.1395591795.git.matthew.r.wilcox@intel.com>
 <20140329163028.GD1211@quack.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20140329163028.GD1211@quack.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jan Kara <jack@suse.cz>
Cc: Matthew Wilcox <matthew.r.wilcox@intel.com>, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Sat, Mar 29, 2014 at 05:30:28PM +0100, Jan Kara wrote:
> > @@ -379,7 +379,9 @@ static int brd_direct_access(struct block_device *bdev, sector_t sector,
> >  	*kaddr = page_address(page);
> >  	*pfn = page_to_pfn(page);
> >  
> > -	return 0;
> > +	/* Could optimistically check to see if the next page in the
> > +	 * file is mapped to the next page of physical RAM */
> > +	return PAGE_SIZE;
>   This should be min_t(long, PAGE_SIZE, size), shouldn't it?

Yes, it should.  In practice, I don't think anyone's calling it with
size < PAGE_SIZE, but we might as well future-proof it.

> > @@ -866,25 +866,26 @@ fail:
> >  	bio_io_error(bio);
> >  }
> >  
> > -static int
> > +static long
> >  dcssblk_direct_access (struct block_device *bdev, sector_t secnum,
> > -			void **kaddr, unsigned long *pfn)
> > +			void **kaddr, unsigned long *pfn, long size)
> >  {
> >  	struct dcssblk_dev_info *dev_info;
> > -	unsigned long pgoff;
> > +	unsigned long offset, dev_sz;

> > -	return 0;
> > +	return min_t(unsigned long, size, dev_sz - offset);
>                      ^^^ Why unsigned? Everything seems to be long...

offset is unsigned long ... but might as well do the comparison in signed
as unsigned.  'size' shouldn't be passed in as < 0 anyway.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
