Date: Sat, 28 Jul 2007 20:39:00 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: RFT: updatedb "morning after" problem [was: Re: -mm merge plans
 for 2.6.23]
Message-Id: <20070728203900.fb75c307.akpm@linux-foundation.org>
In-Reply-To: <46ABEE87.5090907@redhat.com>
References: <9a8748490707231608h453eefffx68b9c391897aba70@mail.gmail.com>
	<46A57068.3070701@yahoo.com.au>
	<2c0942db0707232153j3670ef31kae3907dff1a24cb7@mail.gmail.com>
	<46A58B49.3050508@yahoo.com.au>
	<2c0942db0707240915h56e007e3l9110e24a065f2e73@mail.gmail.com>
	<46A6CC56.6040307@yahoo.com.au>
	<p73abtkrz37.fsf@bingen.suse.de>
	<46A85D95.509@kingswood-consulting.co.uk>
	<20070726092025.GA9157@elte.hu>
	<20070726023401.f6a2fbdf.akpm@linux-foundation.org>
	<20070726094024.GA15583@elte.hu>
	<20070726030902.02f5eab0.akpm@linux-foundation.org>
	<1185454019.6449.12.camel@Homer.simpson.net>
	<20070726110549.da3a7a0d.akpm@linux-foundation.org>
	<1185513177.6295.21.camel@Homer.simpson.net>
	<1185521021.6295.50.camel@Homer.simpson.net>
	<20070727014749.85370e77.akpm@linux-foundation.org>
	<46ABEE87.5090907@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Rik van Riel <riel@redhat.com>
Cc: Mike Galbraith <efault@gmx.de>, Ingo Molnar <mingo@elte.hu>, Frank Kingswood <frank@kingswood-consulting.co.uk>, Andi Kleen <andi@firstfloor.org>, Nick Piggin <nickpiggin@yahoo.com.au>, Ray Lee <ray-lk@madrabbit.org>, Jesper Juhl <jesper.juhl@gmail.com>, ck list <ck@vds.kolivas.org>, Paul Jackson <pj@sgi.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Sat, 28 Jul 2007 21:33:59 -0400 Rik van Riel <riel@redhat.com> wrote:

> Andrew Morton wrote:
> 
> > What I think is killing us here is the blockdev pagecache: the pagecache
> > which backs those directory entries and inodes.  These pages get read
> > multiple times because they hold multiple directory entries and multiple
> > inodes.  These multiple touches will put those pages onto the active list
> > so they stick around for a long time and everything else gets evicted.
> > 
> > I've never been very sure about this policy for the metadata pagecache.  We
> > read the filesystem objects into the dcache and icache and then we won't
> > read from that page again for a long time (I expect).  But the page will
> > still hang around for a long time.
> > 
> > It could be that we should leave those pages inactive.
> 
> Good idea for updatedb.
> 
> However, it may be a bad idea for files that are often
> written to.  Turning an inode write into a read plus a
> write does not sound like such a hot idea, we really
> want to keep those in the cache.

Remember that this problem applies to both inode blocks and to directory
blocks.  Yes, it might be useful to hold onto an inode block for a future
write (atime, mtime, usually), but not a directory block.

> I think what you need is to ignore multiple references
> to the same page when they all happen in one time
> interval, counting them only if they happen in multiple
> time intervals.

Yes, the sudden burst of accesses for adjacent inode/dirents will be a
common pattern, and it'd make heaps of sense to treat that as a single
touch.  It'd have to be done in the fs I guess, and it might be a bit hard
to do.  And it turns out that embedding the touch_buffer() all the way down
in __find_get_block() was convenient, but it's going to be tricky to
change.

For now I'm fairly inclined to just nuke the touch_buffer() on the read side
and maybe add one on the modification codepaths and see what happens.

As always, testing is the problem.

> The use-once cleanup (which takes a page flag for PG_new,
> I know...) would solve that problem.
> 
> However, it would introduce the problem of having to scan
> all the pages on the list before a page becomes freeable.
> We would have to add some background scanning (or a separate
> list for PG_new pages) to make the initial pageout run use
> an acceptable amount of CPU time.
> 
> Not sure that complexity will be worth it...
> 

I suspect that the situation we have now is so bad that pretty much
anything we do will be an improvement.  I've always wondered "ytf is there
so much blockdev pagecache?"

This machine I'm typing at:

MemTotal:      3975080 kB
MemFree:        750400 kB
Buffers:        547736 kB
Cached:        1299532 kB
SwapCached:      12772 kB
Active:        1789864 kB
Inactive:       861420 kB
HighTotal:           0 kB
HighFree:            0 kB
LowTotal:      3975080 kB
LowFree:        750400 kB
SwapTotal:     4875716 kB
SwapFree:      4715660 kB
Dirty:              76 kB
Writeback:           0 kB
Mapped:         638036 kB
Slab:           522724 kB
CommitLimit:   6863256 kB
Committed_AS:  1115632 kB
PageTables:      14452 kB
VmallocTotal: 34359738367 kB
VmallocUsed:     36432 kB
VmallocChunk: 34359696379 kB
HugePages_Total:     0
HugePages_Free:      0
HugePages_Rsvd:      0
Hugepagesize:     2048 kB

More that a quarter of my RAM in fs metadata!  Most of it I'll bet is on the
active list.  And the fs on which I do most of the work is mounted
noatime..


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
