Received: from digeo-nav01.digeo.com (digeo-nav01.digeo.com [192.168.1.233])
	by packet.digeo.com (8.9.3+Sun/8.9.3) with SMTP id OAA15293
	for <linux-mm@kvack.org>; Sun, 8 Sep 2002 14:33:25 -0700 (PDT)
Message-ID: <3D7BC58F.D8AC82E8@digeo.com>
Date: Sun, 08 Sep 2002 14:47:59 -0700
From: Andrew Morton <akpm@digeo.com>
MIME-Version: 1.0
Subject: Re: [PATCH] slabasap-mm5_A2
References: <200209071006.18869.tomlins@cam.org> <200209081142.02839.tomlins@cam.org> <3D7BB97A.6B6E4CA5@digeo.com> <200209081714.54110.tomlins@cam.org>
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Ed Tomlinson <tomlins@cam.org>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

Ed Tomlinson wrote:
> 
> On September 8, 2002 04:56 pm, Andrew Morton wrote:
> > Ed Tomlinson wrote:
> > > Hi,
> > >
> > > Here is a rewritten slablru - this time its not using the lru...  If
> > > changes long standing slab behavior.  Now slab.c releases pages as soon
> > > as possible.  This was done since we noticed that slablru was taking a
> > > long time to release the pages it freed - from other vm experiences this
> > > is not a good thing.
> >
> > Right.  There remains the issue that we're ripping away constructed
> > objects from slabs which have constructors, as Stephen points out.
> 
> I have a small optimization coded in slab.  If there are not any free
> slab objects I do not free the page.   If we have problems with high
> order slabs we can change this to be if we do not have <n> objects
> do not free it.

OK.

> > I doubt if that matters.  slab constructors just initialise stuff.
> > If the memory is in cache then the initialisation is negligible.
> > If the memory is not in cache then the initialisation will pull
> > it into cache, which is something which we needed to do anyway.  And
> > unless the slab's access pattern is extremely LIFO, chances are that
> > most allocations will come in from part-filled slab pages anyway.
> >
> > And other such waffly words ;)  I'll do the global LIFO page hotlists
> > soonl; that'll fix it up.
> >
> > > In this patch I have tried to make as few changes as possible.
> >
> > Thanks.  I've shuffled the patching sequence (painful), and diddled
> > a few things.  We actually do have the "number of scanned pages"
> > in there, so we can use that.  I agree that the ratio should be
> > nr_scanned/total rather than nr_reclaimed/total.   This way, if
> > nr_reclaimed < nr_scanned (page reclaim is in trouble) then we
> > put more pressure on slabs.
> 
> OK will change this.  This also means the changes to prune functions
> made for slablru will come back - they convert these fuctions so they
> age <n> object rather than purge <n>.

That would make the slab pruning less aggressive than the code I'm
testing now.  I'm not sure it needs that change.  Not sure...
 
> > >   With this in mind I am using
> > > the percentage of the active+inactive pages reclaimed to recover the same
> > > percentage of the pruneable caches.  In slablru the affect was to age the
> > > pruneable caches by percentage of the active+inactive pages scanned -
> > > this could be done but required more code so I went used pages reclaimed.
> > >  The same choise was made about accounting of pages freed by the
> > > shrink_<something>_memory calls.
> > >
> > > There is also a question as to if we should only use the ZONE_DMA and
> > > ZONE_NORMAL to drive the cache shrinking.  Talk with Rik on irc convinced
> > > me to go with the choise that required less code, so we use all zones.
> >
> > OK.  We could do with a `gimme_the_direct_addressed_classzone' utility
> > anyway.  It is currently open-coded in fs/buffer.c:free_more_memory().
> > We can just pull that out of there and use memclass() on it for this.
> 
> Ah thanks.  Was wondering the best way to do this.  Will read the code.

Then again, shrinking slab harder for big highmem machines is good ;)
 
> ...
> > From a quick test, the shrinking rate seems quite reasonable to
> > me.  mem=512m, with twenty megs of ext2 inodes in core, a `dd'
> > of one gigabyte (twice the size of memory) steadily pushed the
> > ext2 inodes down to 2.5 megs (although total memory was still
> > 9 megs - internal fragmentation of the slab).
> >
> > A second 1G dd pushed it down to 1M/3M.
> >
> > A third 1G dd pushed it down to .25M/1.25M
> >
> > Seems OK.
> >
> > A few things we should do later:
> >
> > - We're calling prune_icache with a teeny number of inodes, many times.
> >   Would be better to batch that up a bit.
> 
> Why not move the prunes to try_to_free_pages?   The should help a little to get
> bigger batches of pages as will using the number of scanned pages.

But the prunes are miles too small at present.  We go into try_to_free_pages()
and reclaim 32 pages.  And we also call into prune_cache() and free about 0.3
pages.  It's out of whack.  I'd suggest not calling out to the pruner until
we want at least several pages' worth of objects.
 
> ...
> > But let's get the current code settled in before doing these
> > refinements.
> 
> I can get the aging changes to you real fast if you want them.  I initially
> coded it this way then pull the changes to reduce the code...  see below

No rush.
 
> The other thing we want to be careful with is to make sure the lack of
> free page accounting is detected by oom - we definitly do not want to
> oom when slab has freed memory by try_to_free_pages does not
> realize it..

How much memory are we talking about here?  Not much I think?
 
> > There are some usage patterns in which the dentry/inode aging
> > might be going wrong.  Try, with mem=512m
> >
> >       cp -a linux a
> >       cp -a linux b
> >       cp -a linux c
> >
> > etc.
> >
> > Possibly the inode/dentry cache is just being FIFO here and is doing
> > exactly the wrong thing.  But the dcache referenced-bit logic should
> > cause the inodes in `linux' to be pinned with this test, so that
> > should be OK.  Dunno.
> >
> > The above test will be hurt a bit by the aggressively lowered (10%)
> > background writeback threshold - more reads competing with writes.
> > Maybe I should not kick off background writeback until the dirty
> > threshold reaches 30% if there are reads queued against the device.
> > That's easy enough to do.
> >
> > drop-behind should help here too.
> 
> This converts the prunes in inode and dcache to age <n> entries rather
> than purge them.  Think this is the more correct behavior.  Code is from
> slablru.

Makes sense (I think).
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
