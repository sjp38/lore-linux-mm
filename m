From: Nick Piggin <nickpiggin@yahoo.com.au>
Subject: Re: [PATCH] rd: Use a private inode for backing storage
Date: Sun, 21 Oct 2007 19:39:03 +1000
References: <200710151028.34407.borntraeger@de.ibm.com> <200710211524.52595.nickpiggin@yahoo.com.au> <m1d4v9c690.fsf@ebiederm.dsl.xmission.com>
In-Reply-To: <m1d4v9c690.fsf@ebiederm.dsl.xmission.com>
MIME-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Message-Id: <200710211939.04015.nickpiggin@yahoo.com.au>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "Eric W. Biederman" <ebiederm@xmission.com>
Cc: Christian Borntraeger <borntraeger@de.ibm.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Martin Schwidefsky <schwidefsky@de.ibm.com>, Theodore Ts'o <tytso@mit.edu>, stable@kernel.org
List-ID: <linux-mm.kvack.org>

On Sunday 21 October 2007 16:48, Eric W. Biederman wrote:
> Nick Piggin <nickpiggin@yahoo.com.au> writes:
> > Yes it does. It is exactly breaking the coherency between block
> > device and filesystem metadata coherency that Andrew cared about.
> > Whether or not that matters, that is a much bigger conceptual
> > change than simply using slightly more (reclaimable) memory in
> > some situations that my patch does.
> >
> > If you want to try convincing people to break that coherency,
> > fine, but it has to be done consistently and everywhere rather than
> > for a special case in rd.c.
>
> Nick.  Reread the patch.  The only thing your arguments have
> established for me is that this patch is not obviously correct.  Which
> makes it ineligible for a back port.

OK, I missed that you set the new inode's aops to the ramdisk_aops
rather than the bd_inode. Which doesn't make a lot of sense because
you just have a lot of useless aops there now.


> Frankly I suspect the whole 
> issue is to subtle and rare to make any backport make any sense.  My
> apologies Christian.

It's a data corruption issue. I think it should be fixed.


> >> The only way we make it to that inode is through block
> >> device I/O so it lives at exactly the same level in the hierarchy as
> >> a real block device.
> >
> > No, it doesn't. A real block device driver does have its own
> > buffer cache as it's backing store. It doesn't know about
> > readpage or writepage or set_page_dirty or buffers or pagecache.
>
> Well those pages are only accessed through rd_blkdev_pagecache_IO
> and rd_ioctl.

Wrong. It will be via the LRU, will get ->writepage() called,
block_invalidate_page, etc. And I guess also via sb->s_inodes, where
drop_pagecache_sb might do stuff to it (although it probably escapes
harm). But you're right that it isn't the obviously correct fix for
the problem.


> >> My patch is the considered rewrite boiled down
> >> to it's essentials and made a trivial patch.
> >
> > What's the considered rewrite here? The rewrite I posted is the
> > only one so far that's come up that I would consider [worthy],
> > while these patches are just more of the same wrongness.
>
> Well it looks like you were blind when you read the patch.

If you think it is a nice way to go, then I think you are
blind ;)


> Because the semantics between the two are almost identical,
> except I managed to implement BLKFLSBUF in a backwards compatible
> way by flushing both the buffer cache and my private cache.  You
> failed to flush the buffer cache in your implementation.

Obviously a simple typo that can be fixed by adding one line
of code.


> Yes. I use an inode 99% for it's mapping and the mapping 99% for it's
> radix_tree.  But having truncate_inode_pages and grab_cache_page
> continue to work sure is convenient.

It's horrible. And using truncate_inode_pages / grab_cache_page and
new_inode is an incredible argument to save a few lines of code. You
obviously didn't realise your so called private pages would get
accessed via the LRU, for example. This is making a relatively
larger logical change than my patch, because now as well as having
a separate buffer cache and backing store, you are also making the
backing store pages visible to the VM.


> I certainly think it makes it a 
> lot simpler to audit the code to change just one thing at a time (the
> backing store) then to rip out and replace everything and then try and
> prove that the two patches are equivalent.

I think it's a bad idea just to stir the shit. We should take the
simple fix for the problem, and then fix it properly.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
