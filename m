Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f179.google.com (mail-pd0-f179.google.com [209.85.192.179])
	by kanga.kvack.org (Postfix) with ESMTP id 351F46B0036
	for <linux-mm@kvack.org>; Thu,  4 Sep 2014 17:08:10 -0400 (EDT)
Received: by mail-pd0-f179.google.com with SMTP id g10so2152027pdj.38
        for <linux-mm@kvack.org>; Thu, 04 Sep 2014 14:08:09 -0700 (PDT)
Received: from mga09.intel.com (mga09.intel.com. [134.134.136.24])
        by mx.google.com with ESMTP id hl1si244098pac.42.2014.09.04.14.08.08
        for <linux-mm@kvack.org>;
        Thu, 04 Sep 2014 14:08:09 -0700 (PDT)
Date: Thu, 4 Sep 2014 17:08:02 -0400
From: Matthew Wilcox <willy@linux.intel.com>
Subject: Re: [PATCH v10 19/21] xip: Add xip_zero_page_range
Message-ID: <20140904210802.GA27730@localhost.localdomain>
References: <cover.1409110741.git.matthew.r.wilcox@intel.com>
 <80c8efc903971eb3a338f262fbd3ef135db63eb0.1409110741.git.matthew.r.wilcox@intel.com>
 <20140903092116.GF20473@dastard>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20140903092116.GF20473@dastard>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Chinner <david@fromorbit.com>
Cc: Matthew Wilcox <matthew.r.wilcox@intel.com>, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, willy@linux.intel.com, Ross Zwisler <ross.zwisler@linux.intel.com>

On Wed, Sep 03, 2014 at 07:21:16PM +1000, Dave Chinner wrote:
> > @@ -481,9 +484,14 @@ int dax_truncate_page(struct inode *inode, loff_t from, get_block_t get_block)
> >  		err = dax_get_addr(&bh, &addr, inode->i_blkbits);
> >  		if (err < 0)
> >  			return err;
> > +		/*
> > +		 * ext4 sometimes asks to zero past the end of a block.  It
> > +		 * really just wants to zero to the end of the block.
> > +		 */
> > +		length = min_t(unsigned, length, PAGE_CACHE_SIZE - offset);
> >  		memset(addr + offset, 0, length);
> 
> Sorry, what?
> 
> You introduce that bug with the way dax_truncate_page() is redefined
> to always pass PAGE_CACHE_SIZE a a length later on in this patch.
> into the function. That's hardly an ext4 bug....

ext4 does (or did?) have this bug (expectation?).  I then take advantage
of the fact that we have to accommodate it, so there are now two places
that have to accommodate it.  I forget what the path was that has that
assumption, but xfstests used to display it.

I'm away this week (... bad timing), but I can certainly fix it elsewhere
in ext4 next week.

> >  int dax_clear_blocks(struct inode *, sector_t block, long size);
> > +int dax_zero_page_range(struct inode *, loff_t from, unsigned len, get_block_t);
> >  int dax_truncate_page(struct inode *, loff_t from, get_block_t);
> 
> It's still defined as a function that doesn't exist now....

Oops.

> > +/* Can't be a function because PAGE_CACHE_SIZE is defined in pagemap.h */
> > +#define dax_truncate_page(inode, from, get_block)	\
> > +	dax_zero_page_range(inode, from, PAGE_CACHE_SIZE, get_block)
> 
> And then redefined as a macro here.

Heh, which means we never notice the stale delaration above.  Thanks, C!

> This is wrong, IMO,
> dax_truncate_page() should remain as a function and it should
> correctly calculate how much of the page shoul dbe trimmed, not
> leave landmines that other code has to clean up...
> 
> (Yup, I'm tracking down a truncate bug in XFS from fsx...)

I'll put an assert in the rewrite, make sure that nobody's trying to
overtruncate.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
