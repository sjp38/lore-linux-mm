From: ebiederm@xmission.com (Eric W. Biederman)
Subject: Re: [PATCH] rd: Use a private inode for backing storage
References: <200710151028.34407.borntraeger@de.ibm.com>
	<200710211428.55611.nickpiggin@yahoo.com.au>
	<m1wsthcatk.fsf@ebiederm.dsl.xmission.com>
	<200710211524.52595.nickpiggin@yahoo.com.au>
Date: Sun, 21 Oct 2007 00:48:59 -0600
In-Reply-To: <200710211524.52595.nickpiggin@yahoo.com.au> (Nick Piggin's
	message of "Sun, 21 Oct 2007 15:24:52 +1000")
Message-ID: <m1d4v9c690.fsf@ebiederm.dsl.xmission.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nick Piggin <nickpiggin@yahoo.com.au>
Cc: Christian Borntraeger <borntraeger@de.ibm.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Martin Schwidefsky <schwidefsky@de.ibm.com>, Theodore Ts'o <tytso@mit.edu>, stable@kernel.org
List-ID: <linux-mm.kvack.org>

Nick Piggin <nickpiggin@yahoo.com.au> writes:

> Yes it does. It is exactly breaking the coherency between block
> device and filesystem metadata coherency that Andrew cared about.
> Whether or not that matters, that is a much bigger conceptual
> change than simply using slightly more (reclaimable) memory in
> some situations that my patch does.
>
> If you want to try convincing people to break that coherency,
> fine, but it has to be done consistently and everywhere rather than
> for a special case in rd.c.

Nick.  Reread the patch.  The only thing your arguments have
established for me is that this patch is not obviously correct.  Which
makes it ineligible for a back port.  Frankly I suspect the whole
issue is to subtle and rare to make any backport make any sense.  My
apologies Christian.

>> The only way we make it to that inode is through block 
>> device I/O so it lives at exactly the same level in the hierarchy as
>> a real block device.
>
> No, it doesn't. A real block device driver does have its own
> buffer cache as it's backing store. It doesn't know about
> readpage or writepage or set_page_dirty or buffers or pagecache.

Well those pages are only accessed through rd_blkdev_pagecache_IO
and rd_ioctl.

The address space operations can (after my patch) be deleted or
be replaced by their generic versions.  I just didn't take that
step because it was an unnecessary change and I wanted the minimal
change for a backport.

>> My patch is the considered rewrite boiled down 
>> to it's essentials and made a trivial patch.
>
> What's the considered rewrite here? The rewrite I posted is the
> only one so far that's come up that I would consider [worthy],
> while these patches are just more of the same wrongness.

Well it looks like you were blind when you read the patch.

Because the semantics between the two are almost identical,
except I managed to implement BLKFLSBUF in a backwards compatible
way by flushing both the buffer cache and my private cache.  You
failed to flush the buffer cache in your implementation.

Yes. I use an inode 99% for it's mapping and the mapping 99% for it's
radix_tree.  But having truncate_inode_pages and grab_cache_page
continue to work sure is convenient.  I certainly think it makes it a
lot simpler to audit the code to change just one thing at a time (the
backing store) then to rip out and replace everything and then try and
prove that the two patches are equivalent.

Eric

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
