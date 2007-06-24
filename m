Date: Sun, 24 Jun 2007 05:47:55 +0200
From: Nick Piggin <npiggin@suse.de>
Subject: Re: [RFC] fsblock
Message-ID: <20070624034755.GA3292@wotan.suse.de>
References: <20070624014528.GA17609@wotan.suse.de> <467DE00A.9080700@garzik.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <467DE00A.9080700@garzik.org>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Jeff Garzik <jeff@garzik.org>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Linux Memory Management List <linux-mm@kvack.org>, linux-fsdevel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Sat, Jun 23, 2007 at 11:07:54PM -0400, Jeff Garzik wrote:
> Nick Piggin wrote:
> >- No deadlocks (hopefully). The buffer layer is technically deadlocky by
> >  design, because it can require memory allocations at page writeout-time.
> >  It also has one path that cannot tolerate memory allocation failures.
> >  No such problems for fsblock, which keeps fsblock metadata around for as
> >  long as a page is dirty (this still has problems vs get_user_pages, but
> >  that's going to require an audit of all get_user_pages sites. Phew).
> >
> >- In line with the above item, filesystem block allocation is performed
> >  before a page is dirtied. In the buffer layer, mmap writes can dirty a
> >  page with no backing blocks which is a problem if the filesystem is
> >  ENOSPC (patches exist for buffer.c for this).
> 
> This raises an eyebrow...  The handling of ENOSPC prior to mmap write is 
> more an ABI behavior, so I don't see how this can be fixed with internal 
> changes, yet without changing behavior currently exported to userland 
> (and thus affecting code based on such assumptions).

I believe people are happy to have it SIGBUS (which is how the VM
is already set up with page_mkwrite, and what fsblock does).
 
 
> >- An inode's metadata must be tracked per-inode in order for fsync to
> >  work correctly. buffer contains helpers to do this for basic
> >  filesystems, but any block can be only the metadata for a single inode.
> >  This is not really correct for things like inode descriptor blocks.
> >  fsblock can track multiple inodes per block. (This is non trivial,
> >  and it may be overkill so it could be reverted to a simpler scheme
> >  like buffer).
> 
> hrm; no specific comment but this seems like an idea/area that needs to 
> be fleshed out more, by converting some of the more advanced filesystems.

Yep. It's conceptually fairly simple though, and it might be easier
than having filesystems implement their own complex syncing that finds
and syncs everything themselves.


> >- Large block support. I can mount and run an 8K block size minix3 fs on
> >  my 4K page system and it didn't require anything special in the fs. We
> >  can go up to about 32MB blocks now, and gigabyte+ blocks would only
> >  require  one more bit in the fsblock flags. fsblock_superpage blocks
> >  are > PAGE_CACHE_SIZE, midpage ==, and subpage <.
> 
> definitely useful, especially if I rewrite my ibu filesystem for 2.6.x, 
> like I've been planning.

Yeah, it wasn't the primary motivation for the rewrite, but it would
be negligent to not even consider large blocks in such a rewrite, I
think.


> >So. Comments? Is this something we want? If yes, then how would we
> >transition from buffer.c to fsblock.c?
> 
> Your work is definitely interesting, but I think it will be even more 
> interesting once ext2 (w/ dir in pagecache) and ext3 (journalling) are 
> converted.

Well minix has dir in pagecache ;) But you're completely right: ext2
will be the next step and then ext3 and things like XFS and NTFS
will be the real test. I think I could eventually get ext2 done (one
of the biggest headaches is simply just converting ->b_data accesses),
however unlikely a journalling one.

 
> My gut feeling is that there are several problem areas you haven't hit 
> yet, with the new code.

I would agree with your gut :)

 
> Also, once things are converted, the question of transitioning from 
> buffer.c will undoubtedly answer itself.  That's the way several of us 
> handle transitions:  finish all the work, then look with fresh eyes and 
> conceive a path from the current code to your enhanced code.

Yeah that would be nice. It's very difficult because of so much
filesystem code. I'd say it would be feasible to step buffer.c into
fsblock.c, however if we were to track all (or even the common)
filesystems along with that it would introduce a huge number of
kind-of-redundant changes that I don't think all fs maintainers would
have time to write (and as I said, I can't do it myself). Anyway,
let's cross that bridge if and when we come to it.

For now, the big thing that needs to be done is convert a "big" fs
and see if the results tell us that it's workable.

Thanks for the comments Jeff.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
