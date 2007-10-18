From: Nick Piggin <nickpiggin@yahoo.com.au>
Subject: Re: [patch][rfc] rewrite ramdisk
Date: Thu, 18 Oct 2007 11:06:56 +1000
References: <200710151028.34407.borntraeger@de.ibm.com> <200710172249.13877.nickpiggin@yahoo.com.au> <m1k5pleg0w.fsf@ebiederm.dsl.xmission.com>
In-Reply-To: <m1k5pleg0w.fsf@ebiederm.dsl.xmission.com>
MIME-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Message-Id: <200710181106.57317.nickpiggin@yahoo.com.au>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "Eric W. Biederman" <ebiederm@xmission.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Christian Borntraeger <borntraeger@de.ibm.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Martin Schwidefsky <schwidefsky@de.ibm.com>, Theodore Ts'o <tytso@mit.edu>
List-ID: <linux-mm.kvack.org>

On Thursday 18 October 2007 04:45, Eric W. Biederman wrote:
> At this point my concern is what makes a clean code change in the
> kernel.  Because user space can currently play with buffer_heads
> by way of the block device and cause lots of havoc (see the recent

Well if userspace is writing to the filesystem metadata via the
blockdevice while it is running... that's the definition of havoc,
isn't it? ;) Whether or not the writes are going via a unified
metadata/blockdev cache or separate ones.

You really just have to not do that.

The actual reiserfs problem being seen is not because of userspace
going silly, but because ramdisk is hijacking the dirty bits.


> If that change is made then it happens that the current ramdisk
> would not need to worry about buffer heads and all of that
> nastiness and could just lock pages in the page cache.  It would not
> be quite as good for testing filesystems but retaining the existing
> characteristics would be simple.

No, it wouldn't. Because if you're proposing to split up the buffer
cache and the metadata cache, then you're back to a 2 cache
solution which is basically has the memory characteristics of my
proposal while still being horribly incestuous with the pagecache.


> After having looked a bit deeper the buffer_heads and the block
> devices don't look as intricately tied up as I had first thought.
> We still have the nasty case of:
> 	if (buffer_new(bh))
> 		unmap_underlying_metadata(bh->b_bdev, bh->b_blocknr);
> That I don't know how it got merged.  But otherwise the caches
> are fully separate.

Well its needed because some filesystems forget about their old
metadata. It's not really there to solve aliasing with the blockdev
pagecache.


> So currently it looks to me like there are two big things that will
> clean up that part of the code a lot:
> - moving the metadata buffer_heads to a magic filesystem inode.
> - Using a simpler non-buffer_head returning version of get_block
>   so we can make simple generic code for generating BIOs.

Although this is going off the track of the ramdisk problem. For
that we should just do the rewrite.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
