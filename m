Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f43.google.com (mail-pa0-f43.google.com [209.85.220.43])
	by kanga.kvack.org (Postfix) with ESMTP id 568406B0035
	for <linux-mm@kvack.org>; Thu, 11 Sep 2014 00:38:21 -0400 (EDT)
Received: by mail-pa0-f43.google.com with SMTP id fa1so8471594pad.2
        for <linux-mm@kvack.org>; Wed, 10 Sep 2014 21:38:21 -0700 (PDT)
Received: from ipmail04.adl6.internode.on.net (ipmail04.adl6.internode.on.net. [150.101.137.141])
        by mx.google.com with ESMTP id ps4si11441971pac.239.2014.09.10.21.38.18
        for <linux-mm@kvack.org>;
        Wed, 10 Sep 2014 21:38:20 -0700 (PDT)
Date: Thu, 11 Sep 2014 14:38:15 +1000
From: Dave Chinner <david@fromorbit.com>
Subject: Re: [PATCH v10 20/21] ext4: Add DAX functionality
Message-ID: <20140911043815.GP20518@dastard>
References: <cover.1409110741.git.matthew.r.wilcox@intel.com>
 <5422062f87eb5606f4632fd06575254379f40ddc.1409110741.git.matthew.r.wilcox@intel.com>
 <20140903111302.GG20473@dastard>
 <54108124.9030707@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <54108124.9030707@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Boaz Harrosh <openosd@gmail.com>
Cc: Matthew Wilcox <matthew.r.wilcox@intel.com>, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Ross Zwisler <ross.zwisler@linux.intel.com>, willy@linux.intel.com

On Wed, Sep 10, 2014 at 07:49:40PM +0300, Boaz Harrosh wrote:
> On 09/03/2014 02:13 PM, Dave Chinner wrote:
> <>
> > 
> > When direct IO fails ext4 falls back to buffered IO, right? And
> > dax_do_io() can return partial writes, yes?
> > 
> 
> There is no buffered writes with DAX. .I.E buffered writes are always
> direct as well. (No page cache)

Yes, I know. But you didn't actually read the code I pointed out,
did you?

> > So that means if you get, say, ENOSPC part way through a DAX write,
> > ext4 can start dirtying the page cache from
> > __generic_file_write_iter() because the DAX write didn't wholly
> > complete? And say this ENOSPC races with space being freed from
> > another inode, then the buffered write will succeed and we'll end up
> > with coherency issues, right?
> > 
> > This is not an idle question - XFS if firing asserts all over the
> > place when doing ENOSPC testing because DAX is returning partial
> > writes and the XFS direct IO code is expecting them to either wholly
> > complete or wholly fail. I can make the DAX variant do allow partial
> > writes, but I'm not going to add a useless fallback to buffered IO
> > for XFS when the (fully featured) direct allocation fails.
> > 
> 
> Right, no fall back.

And so ext4 is buggy, because what ext4 does ....

> Because a fallback is just a retry, because in any
> way DAX assumes there is never a page_cache_page for a written data

... is not a retry - it falls back to a fundamentally different
code path. i.e:

sys_write()
....
	new_sync_write
	  ext4_file_write_iter
	    __generic_file_write_iter(O_DIRECT)
	      written = generic_file_direct_write()
	      if (error || complete write)
	        return
	      /* short write! do buffered IO to finish! */
	      generic_perform_write()
	        loop {
			ext4_write_begin
			ext4_write_end
		}

and so we allocate pages in the page cache and do buffered IO into
them because DAX doesn't hook ->writebegin/write_end as we are
supposed to intercept all buffered IO at a higher level.

This causes data corruption when tested at ENOSPC on DAX enabled
ext4 filesystems. I think that it's an oversight and hence a bug
that needs to be fixed but I'm first asking Willy to see if it was
intentional or not because maybe I missed sometihng in the past 4
months since I've paid really close attention to the DAX code.

And in saying that, Boaz, I'd suggest you spend some time looking at
the history of the DAX patchset. Pay careful note to who came up
with the original idea and architecture that led to the IO path you
are so stridently defending.....

Cheers,

Dave.
-- 
Dave Chinner
david@fromorbit.com

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
