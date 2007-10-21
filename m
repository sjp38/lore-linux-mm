From: ebiederm@xmission.com (Eric W. Biederman)
Subject: Re: [PATCH] rd: Use a private inode for backing storage
References: <200710151028.34407.borntraeger@de.ibm.com>
	<200710211524.52595.nickpiggin@yahoo.com.au>
	<m1d4v9c690.fsf@ebiederm.dsl.xmission.com>
	<200710211939.04015.nickpiggin@yahoo.com.au>
Date: Sun, 21 Oct 2007 11:56:08 -0600
In-Reply-To: <200710211939.04015.nickpiggin@yahoo.com.au> (Nick Piggin's
	message of "Sun, 21 Oct 2007 19:39:03 +1000")
Message-ID: <m1ir50bbd3.fsf@ebiederm.dsl.xmission.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nick Piggin <nickpiggin@yahoo.com.au>
Cc: Christian Borntraeger <borntraeger@de.ibm.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Martin Schwidefsky <schwidefsky@de.ibm.com>, Theodore Ts'o <tytso@mit.edu>, stable@kernel.org
List-ID: <linux-mm.kvack.org>

Nick Piggin <nickpiggin@yahoo.com.au> writes:

> OK, I missed that you set the new inode's aops to the ramdisk_aops
> rather than the bd_inode. Which doesn't make a lot of sense because
> you just have a lot of useless aops there now.

Not totally useless as you have mentioned they are accessed by
the lru so we still need something there just not much.

>> Frankly I suspect the whole 
>> issue is to subtle and rare to make any backport make any sense.  My
>> apologies Christian.
>
> It's a data corruption issue. I think it should be fixed.

Of course it should be fixed.  I just don't know if a backport
makes sense.  The problem once understood is hard to trigger
and easy to avoid.

>> >> The only way we make it to that inode is through block
>> >> device I/O so it lives at exactly the same level in the hierarchy as
>> >> a real block device.
>> >
>> > No, it doesn't. A real block device driver does have its own
>> > buffer cache as it's backing store. It doesn't know about
>> > readpage or writepage or set_page_dirty or buffers or pagecache.
>>
>> Well those pages are only accessed through rd_blkdev_pagecache_IO
>> and rd_ioctl.
>
> Wrong. It will be via the LRU, will get ->writepage() called,
> block_invalidate_page, etc. And I guess also via sb->s_inodes, where
> drop_pagecache_sb might do stuff to it (although it probably escapes
> harm). But you're right that it isn't the obviously correct fix for
> the problem.

Yes.  We will be accessed via the LRU.  Yes I knew that.  The truth is
whatever we do we will be visible to the LRU.  My preferences run
towards having something that is less of a special case then a new
potentially huge cache that is completely unaccounted for, that we
have to build and maintain all of the infrastructure for
independently.  The ramdisk code doesn't seem interesting enough
long term to get people to do independent maintenance.

With my patch we are on the road to being just like the ramdisk
for maintenance purposes code except having a different GFP mask.

I think I might have to send in a patch that renames
block_invalidatepage to block_invalidate_page which is how everyone
seems to be spelling it. 

Anyway nothing in the ramdisk code sets PagePrivate o
block_invalidagepage should never be called, nor try_to_free_buffers
for that matter.

>> >> My patch is the considered rewrite boiled down
>> >> to it's essentials and made a trivial patch.
>> >
>> > What's the considered rewrite here? The rewrite I posted is the
>> > only one so far that's come up that I would consider [worthy],
>> > while these patches are just more of the same wrongness.
>>
>> Well it looks like you were blind when you read the patch.
>
> If you think it is a nice way to go, then I think you are
> blind ;)

Well we each have different tastes.  I think my patch
is a sane sensible small incremental step that does just what
is needed to fix the problem.   It doesn't drag a lot of other
stuff into the problem like a rewrite would so we can easily verify
it.

>> Because the semantics between the two are almost identical,
>> except I managed to implement BLKFLSBUF in a backwards compatible
>> way by flushing both the buffer cache and my private cache.  You
>> failed to flush the buffer cache in your implementation.
>
> Obviously a simple typo that can be fixed by adding one line
> of code.

Quite true.  I noticed the breakage in mine because the patch
was so simple, and I only had to worry about one aspect.  With
a rewrite I missed it because there was so much other noise I
couldn't see any issues.


>> Yes. I use an inode 99% for it's mapping and the mapping 99% for it's
>> radix_tree.  But having truncate_inode_pages and grab_cache_page
>> continue to work sure is convenient.
>
> It's horrible. And using truncate_inode_pages / grab_cache_page and
> new_inode is an incredible argument to save a few lines of code. You
> obviously didn't realise your so called private pages would get
> accessed via the LRU, for example. 

I did but but that is relatively minor.  Using the pagecache this
way for this purpose is a well established idiom in the kernel
so I didn't figure I was introducing anything to hard to maintain.

> This is making a relatively
> larger logical change than my patch, because now as well as having
> a separate buffer cache and backing store, you are also making the
> backing store pages visible to the VM.

I am continuing to have the backing store pages visible to the VM,
and from that perspective it is a smaller change then where we are
today.  Not that we can truly hide pages from the VM. 

>> I certainly think it makes it a 
>> lot simpler to audit the code to change just one thing at a time (the
>> backing store) then to rip out and replace everything and then try and
>> prove that the two patches are equivalent.
>
> I think it's a bad idea just to stir the shit. We should take the
> simple fix for the problem, and then fix it properly.

The code in rd.c isn't terrible, and it isn't shit.  There is only one
fundamental problem with it.  rd.c is fundamentally incompatible with
the buffer cache.  Currently rd.c is a legitimate if a bit ugly
user of the page cache.  The ugliness comes from working around
the buffer cache placing buffer heads on it's pages.

With my patch I stop using the same pages as the buffer cache which
removes that one fundamental problem.

Once we get the problem actually fixed I have no problem with
cleaning up the code.  I even have patches queued I just believe
in only changing one thing at a time if I can.

Eric

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
