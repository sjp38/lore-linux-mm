Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f49.google.com (mail-pa0-f49.google.com [209.85.220.49])
	by kanga.kvack.org (Postfix) with ESMTP id 318886B0035
	for <linux-mm@kvack.org>; Mon, 15 Sep 2014 02:15:55 -0400 (EDT)
Received: by mail-pa0-f49.google.com with SMTP id lf10so5610654pab.8
        for <linux-mm@kvack.org>; Sun, 14 Sep 2014 23:15:54 -0700 (PDT)
Received: from ipmail07.adl2.internode.on.net (ipmail07.adl2.internode.on.net. [150.101.137.131])
        by mx.google.com with ESMTP id j4si20958726pdb.62.2014.09.14.23.15.52
        for <linux-mm@kvack.org>;
        Sun, 14 Sep 2014 23:15:53 -0700 (PDT)
Date: Mon, 15 Sep 2014 16:15:35 +1000
From: Dave Chinner <david@fromorbit.com>
Subject: Re: [PATCH v10 20/21] ext4: Add DAX functionality
Message-ID: <20140915061534.GF4322@dastard>
References: <cover.1409110741.git.matthew.r.wilcox@intel.com>
 <5422062f87eb5606f4632fd06575254379f40ddc.1409110741.git.matthew.r.wilcox@intel.com>
 <20140903111302.GG20473@dastard>
 <54108124.9030707@gmail.com>
 <20140911043815.GP20518@dastard>
 <54158949.8080009@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <54158949.8080009@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Boaz Harrosh <openosd@gmail.com>
Cc: Matthew Wilcox <matthew.r.wilcox@intel.com>, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Ross Zwisler <ross.zwisler@linux.intel.com>, willy@linux.intel.com

On Sun, Sep 14, 2014 at 03:25:45PM +0300, Boaz Harrosh wrote:
> On 09/11/2014 07:38 AM, Dave Chinner wrote:
> <>
> > 
> > And so ext4 is buggy, because what ext4 does ....
> > 
> > ... is not a retry - it falls back to a fundamentally different
> > code path. i.e:
> > 
> > sys_write()
> > ....
> > 	new_sync_write
> > 	  ext4_file_write_iter
> > 	    __generic_file_write_iter(O_DIRECT)
> > 	      written = generic_file_direct_write()
> > 	      if (error || complete write)
> > 	        return
> > 	      /* short write! do buffered IO to finish! */
> > 	      generic_perform_write()
> > 	        loop {
> > 			ext4_write_begin
> > 			ext4_write_end
> > 		}
> > 
> > and so we allocate pages in the page cache and do buffered IO into
> > them because DAX doesn't hook ->writebegin/write_end as we are
> > supposed to intercept all buffered IO at a higher level.
> > 
> > This causes data corruption when tested at ENOSPC on DAX enabled
> > ext4 filesystems. I think that it's an oversight and hence a bug
> > that needs to be fixed but I'm first asking Willy to see if it was
> > intentional or not because maybe I missed sometihng in the past 4
> > months since I've paid really close attention to the DAX code.
> > 
> > And in saying that, Boaz, I'd suggest you spend some time looking at
> > the history of the DAX patchset. Pay careful note to who came up
> > with the original idea and architecture that led to the IO path you
> > are so stridently defending.....
> > 
> 
> Yes! you are completely right, and I have not seen this bug. The same bug
> exist with ext2 as well. I think this is a bug in patch:
> 	[PATCH v10 07/21] Replace XIP read and write with DAX I/O
> 
> It needs a:
> @@ -2584,7 +2584,7 @@ ssize_t __generic_file_write_iter(struct kiocb *iocb, struct iov_iter *from)
>  		loff_t endbyte;
>  
>  		written = generic_file_direct_write(iocb, from, pos);
> -		if (written < 0 || written == count)
> +		if (written < 0 || written == count || IS_DAX(inode))
>  			goto out;
>  
>  		/*
> 
> Or something like that. Is that what you meant?

Well, that's one way of working around the immediate issue, but I
don't think it solves the whole problem. e.g. what do you do with the
bit of the partial write that failed? We may have allocated space
for it but not written data to it, so to simply fail exposes stale
data in the file(*).

Hence it's not clear to me that simply returning the short write is
a valid solution for DAX-enabled filesystems. I think that the
above - initially, at least - is much better than falling back to
buffered IO but filesystems are going to have to be updated to work
correctly without that fallback.

> Yes I agree this is a very bad data corruption bug. I also think
> that the read path should not be allowed to fall back to buffered
> IO just the same for the same reason. We must not allow any real
> data in page_cache for a DAX file.

Right, I didn't check the read path for the same issue as XFS won't
return a short read on direct IO unless the read spans EOF. And in
that case it won't ever do buffered reads. ;)

Cheers,

Dave.

(*) XFS avoids this problem by always using unwritten extents for
direct IO allocation, but I'm pretty sure that ext4 doesn't do this.
Using unwritten extents means that we don't expose stale data in the
event we don't end up writing to the allocated space.
-- 
Dave Chinner
david@fromorbit.com

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
