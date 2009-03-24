Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with ESMTP id D69196B004D
	for <linux-mm@kvack.org>; Tue, 24 Mar 2009 08:45:25 -0400 (EDT)
Date: Tue, 24 Mar 2009 13:55:11 +0100
From: Jan Kara <jack@suse.cz>
Subject: Re: ftruncate-mmap: pages are lost after writing to mmaped file.
Message-ID: <20090324125510.GA9434@duck.suse.cz>
References: <604427e00903181244w360c5519k9179d5c3e5cd6ab3@mail.gmail.com> <200903200248.22623.nickpiggin@yahoo.com.au> <20090319164638.GB3899@duck.suse.cz> <200903241844.22851.nickpiggin@yahoo.com.au> <20090324123935.GD23439@duck.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20090324123935.GD23439@duck.suse.cz>
Sender: owner-linux-mm@kvack.org
To: Nick Piggin <nickpiggin@yahoo.com.au>
Cc: "Martin J. Bligh" <mbligh@mbligh.org>, linux-ext4@vger.kernel.org, Ying Han <yinghan@google.com>, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, linux-kernel <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, guichaz@gmail.com, Alex Khesin <alexk@google.com>, Mike Waychison <mikew@google.com>, Rohit Seth <rohitseth@google.com>, Peter Zijlstra <a.p.zijlstra@chello.nl>
List-ID: <linux-mm.kvack.org>

On Tue 24-03-09 13:39:36, Jan Kara wrote:
>   Hi,
> 
> On Tue 24-03-09 18:44:21, Nick Piggin wrote:
> > On Friday 20 March 2009 03:46:39 Jan Kara wrote:
> > > On Fri 20-03-09 02:48:21, Nick Piggin wrote:
> > 
> > > > Holding mapping->private_lock over the __set_page_dirty should
> > > > fix it, although I guess you'd want to release it before calling
> > > > __mark_inode_dirty so as not to put inode_lock under there. I
> > > > have a patch for this if it sounds reasonable.
> > >
> > >   Yes, that seems to be a bug - the function actually looked suspitious to
> > > me yesterday but I somehow convinced myself that it's fine. Probably
> > > because fsx-linux is single-threaded.
> > 
> > 
> > After a whole lot of chasing my own tail in the VM and buffer layers,
> > I think it is a problem in ext2 (and I haven't been able to reproduce
> > with ext3 yet, which might lend weight to that, although as we have
> > seen, it is very timing dependent).
> > 
> > That would be slightly unfortunate because we still have Jan's ext3
> > problem, and also another reported problem of corruption on ext3 (on
> > brd driver).
> > 
> > Anyway, when I have reproduced the problem with the test case, the
> > "lost" writes are all reported to be holes. Unfortunately, that doesn't
> > point straight to the filesystem, because ext2 allocates blocks in this
> > case at writeout time, so if dirty bits are getting lost, then it would
> > be normal to see holes.
> > 
> > I then put in a whole lot of extra infrastructure to track metadata about
> > each struct page (when it was last written out, when it last had the number
> > of writable ptes reach 0, when the dirty bits were last cleared etc). And
> > none of the normal asertions were triggering: eg. when any page is removed
> > from pagecache (except truncates), it has always had all its buffers
> > written out *after* all ptes were made readonly or unmapped. Lots of other
> > tests and crap like that.
>   I see we're going the same way ;)
> 
> > So I tried what I should have done to start with and did an e2fsck after
> > seeing corruption. Yes, it comes up with errors. Now that is unusual
> > because that should be largely insulated from the vm: if a dirty bit gets
> > lost, then the filesystem image should be quite happy and error-free with
> > a hole or unwritten data there.
>   This is different for me. I see no corruption on the filesystem with
> ext3. Anyway, errors from fsck would be useful to see what kind of
> corruption you saw.
> 
> > I don't know ext? locking very well, except that it looks pretty overly
> > complex and crufty.
> > 
> > Usually, blocks are instantiated by write(2), under i_mutex, serialising
> > the allocator somewhat. mmap-write blocks are instantiated at writeout
> > time, unserialised. I moved truncate_mutex to cover the entire get_blocks
> > function, and can no longer trigger the problem. Might be a timing issue
> > though -- Ying, can you try this and see if you can still reproduce?
> > 
> > I close my eyes and pick something out of a hat. a686cd89. Search for XXX.
> > Nice. Whether or not this cased the problem, can someone please tell me
> > why it got merged in that state?
>   Maybe, I see it did some changes to ext2_get_blocks() which could be
> where the problem was introduced...
> 
> > I'm leaving ext3 running for now. It looks like a nasty task to bisect
> > ext2 down to that commit :( and I would be more interested in trying to
> > reproduce Jan's ext3 problem, however, because I'm not too interested in
> > diving into ext2 locking to work out exactly what is racing and how to
> > fix it properly. I suspect it would be most productive to wire up some
> > ioctls right into the block allocator/lookup and code up a userspace
> > tester for it that could probably stress it a lot harder than kernel
> > writeout can.
>   Yes, what I observed with ext3 so far is that data is properly copied and
> page marked dirty when the data is copied in. But then at some point dirty
> bit is cleared via block_write_full_page() but we don't get to submitting
> at least one buffer in that page. I'm now debugging which path we take so
> that this happens...
  And one more interesting thing I don't yet fully understand - I see pages
having PageError() set when they are removed from page cache (and they have
been faulted in before). It's probably some interaction with pagecache
readahead...

 									Honza

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
