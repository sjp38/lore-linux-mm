From: ebiederm@xmission.com (Eric W. Biederman)
Subject: Re: [PATCH] rd: Mark ramdisk buffers heads dirty
References: <200710151028.34407.borntraeger@de.ibm.com>
	<m1zlykj8zl.fsf_-_@ebiederm.dsl.xmission.com>
	<200710160956.58061.borntraeger@de.ibm.com>
	<200710171814.01717.borntraeger@de.ibm.com>
	<m1sl49ei8x.fsf@ebiederm.dsl.xmission.com>
	<1192648456.15717.7.camel@think.oraclecorp.com>
	<m17illeb8f.fsf@ebiederm.dsl.xmission.com>
	<1192654481.15717.16.camel@think.oraclecorp.com>
Date: Wed, 17 Oct 2007 15:30:19 -0600
In-Reply-To: <1192654481.15717.16.camel@think.oraclecorp.com> (Chris Mason's
	message of "Wed, 17 Oct 2007 16:54:41 -0400")
Message-ID: <m1ve95ctuc.fsf@ebiederm.dsl.xmission.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Chris Mason <chris.mason@oracle.com>
Cc: Christian Borntraeger <borntraeger@de.ibm.com>, Andrew Morton <akpm@linux-foundation.org>, Nick Piggin <nickpiggin@yahoo.com.au>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Martin Schwidefsky <schwidefsky@de.ibm.com>, Theodore Ts'o <tytso@mit.edu>, stable@kernel.org
List-ID: <linux-mm.kvack.org>

Chris Mason <chris.mason@oracle.com> writes:

>> Thinking about it.  I don't believe anyone has ever intentionally built
>> a filesystem tool that depends on being able to modify a file systems
>> metadata buffer heads while the filesystem is running, and doing that
>> would seem to be fragile as it would require a lot of cooperation
>> between the tool and the filesystem about how the filesystem uses and
>> implement things.
>> 
>
> That's right.  For example, ext2 is doing directories in the page cache
> of the directory inode, so there's a cache alias between the block
> device page cache and the directory inode page cache.
>
>> Now I guess I need to see how difficult a patch would be to give
>> filesystems magic inodes to keep their metadata buffer heads in.
>
> Not hard, the block device inode is already a magic inode for metadata
> buffer heads.  You could just make another one attached to the bdev.
>
> But, I don't think I fully understand the problem you're trying to
> solve?


So the start:
When we write buffers from the buffer cache we clear buffer_dirty
but not PageDirty

So try_to_free_buffers() will mark any page with clean buffer_heads
that is not clean itself clean.

The ramdisk set pages dirty to keep them from being removed from the
page cache, just like ramfs.

Unfortunately when those dirty ramdisk pages get buffers on them and
those buffers all go clean and we are trying to reclaim buffer_heads
we drop those pages from the page cache.   Ouch!

We can fix the ramdisk by setting making certain that buffer_heads
on ramdisk pages stay dirty as well.  The problem is this breaks
filesystems like reiserfs and ext3 that expect to be able to make 
buffer_heads clean sometimes.

There are other ways to solve this for ramdisks, such as changing
where ramdisks are stored.  However fixing the ramdisks this way
still leaves the general problem that there are other paths to the
filesystem metadata buffers, and those other paths cause the code
to be complicated and buggy.

So I'm trying to see if we can untangle this Gordian knot, so the
code because more easily maintainable.  

To make the buffer cache a helper library instead of require
infrastructure, it looks like two things need to happen.
- Move metadata buffer heads off block devices page cache entries, 
- Communicate the mappings of data pages to block device sectors
  in a generic way without buffer heads.

How we ultimately fix the ramdisk tends to depend on how we untangle
the buffer head problem.  Right now the only simple solution is to
suppress try_to_free_buffers, which is a bit ugly.  We can also come
up with a completely separate store for the pages in the buffer cache
but if we wind up moving the metadata buffer heads anyway then that
should not be necessary.

Eric

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
