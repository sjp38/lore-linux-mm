Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id 7837F6B003D
	for <linux-mm@kvack.org>; Thu, 26 Mar 2009 13:29:47 -0400 (EDT)
Date: Thu, 26 Mar 2009 19:29:47 +0100
From: Jan Kara <jack@suse.cz>
Subject: Re: ftruncate-mmap: pages are lost after writing to mmaped file.
Message-ID: <20090326182947.GE17159@duck.suse.cz>
References: <604427e00903181244w360c5519k9179d5c3e5cd6ab3@mail.gmail.com> <200903241844.22851.nickpiggin@yahoo.com.au> <20090324033204.64f3da9d.akpm@linux-foundation.org> <200903250235.02816.nickpiggin@yahoo.com.au>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <200903250235.02816.nickpiggin@yahoo.com.au>
Sender: owner-linux-mm@kvack.org
To: Nick Piggin <nickpiggin@yahoo.com.au>
Cc: Andrew Morton <akpm@linux-foundation.org>, "Martin J. Bligh" <mbligh@mbligh.org>, linux-ext4@vger.kernel.org, Ying Han <yinghan@google.com>, Linus Torvalds <torvalds@linux-foundation.org>, linux-kernel <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, guichaz@gmail.com, Alex Khesin <alexk@google.com>, Mike Waychison <mikew@google.com>, Rohit Seth <rohitseth@google.com>, Peter Zijlstra <a.p.zijlstra@chello.nl>
List-ID: <linux-mm.kvack.org>

On Wed 25-03-09 02:35:01, Nick Piggin wrote:
> On Tuesday 24 March 2009 21:32:04 Andrew Morton wrote:
> > On Tue, 24 Mar 2009 18:44:21 +1100 Nick Piggin <nickpiggin@yahoo.com.au> 
> wrote:
> > > On Friday 20 March 2009 03:46:39 Jan Kara wrote:
> > > > On Fri 20-03-09 02:48:21, Nick Piggin wrote:
> > > > > Holding mapping->private_lock over the __set_page_dirty should
> > > > > fix it, although I guess you'd want to release it before calling
> > > > > __mark_inode_dirty so as not to put inode_lock under there. I
> > > > > have a patch for this if it sounds reasonable.
> > > >
> > > >   Yes, that seems to be a bug - the function actually looked suspitious
> > > > to me yesterday but I somehow convinced myself that it's fine. Probably
> > > > because fsx-linux is single-threaded.
> > >
> > > After a whole lot of chasing my own tail in the VM and buffer layers,
> > > I think it is a problem in ext2 (and I haven't been able to reproduce
> > > with ext3 yet, which might lend weight to that, although as we have
> > > seen, it is very timing dependent).
> > >
> > > That would be slightly unfortunate because we still have Jan's ext3
> > > problem, and also another reported problem of corruption on ext3 (on
> > > brd driver).
> > >
> > > Anyway, when I have reproduced the problem with the test case, the
> > > "lost" writes are all reported to be holes. Unfortunately, that doesn't
> > > point straight to the filesystem, because ext2 allocates blocks in this
> > > case at writeout time, so if dirty bits are getting lost, then it would
> > > be normal to see holes.
> > >
> > > I then put in a whole lot of extra infrastructure to track metadata about
> > > each struct page (when it was last written out, when it last had the
> > > number of writable ptes reach 0, when the dirty bits were last cleared
> > > etc). And none of the normal asertions were triggering: eg. when any page
> > > is removed from pagecache (except truncates), it has always had all its
> > > buffers written out *after* all ptes were made readonly or unmapped. Lots
> > > of other tests and crap like that.
> > >
> > > So I tried what I should have done to start with and did an e2fsck after
> > > seeing corruption. Yes, it comes up with errors.
> >
> > Do you recall what the errors were?
> 
> OK, after running several tests in parallel and having 3 of them
> blow up, I unmounted the fs (so error-case files are still intact).
  Nick, what tests do you use? Because on the first reading the ext2 code
looks correct so I'll probably have to reproduce the corruption...

									Honza
-- 
Jan Kara <jack@suse.cz>
SUSE Labs, CR

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
