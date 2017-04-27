Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f70.google.com (mail-wm0-f70.google.com [74.125.82.70])
	by kanga.kvack.org (Postfix) with ESMTP id 8E6E46B03A0
	for <linux-mm@kvack.org>; Thu, 27 Apr 2017 03:45:05 -0400 (EDT)
Received: by mail-wm0-f70.google.com with SMTP id 184so739404wmy.18
        for <linux-mm@kvack.org>; Thu, 27 Apr 2017 00:45:05 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id b20si2284084wmd.114.2017.04.27.00.45.03
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 27 Apr 2017 00:45:04 -0700 (PDT)
Date: Thu, 27 Apr 2017 09:26:59 +0200
From: Jan Kara <jack@suse.cz>
Subject: Re: [PATCH 2/2] dax: fix data corruption due to stale mmap reads
Message-ID: <20170427072659.GA29789@quack2.suse.cz>
References: <20170420191446.GA21694@linux.intel.com>
 <20170421034437.4359-1-ross.zwisler@linux.intel.com>
 <20170421034437.4359-2-ross.zwisler@linux.intel.com>
 <20170425111043.GH2793@quack2.suse.cz>
 <20170425225936.GA29655@linux.intel.com>
 <20170426085235.GA21738@quack2.suse.cz>
 <20170426225236.GA25838@linux.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170426225236.GA25838@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ross Zwisler <ross.zwisler@linux.intel.com>
Cc: Jan Kara <jack@suse.cz>, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, Alexander Viro <viro@zeniv.linux.org.uk>, Alexey Kuznetsov <kuznet@virtuozzo.com>, Andrey Ryabinin <aryabinin@virtuozzo.com>, Anna Schumaker <anna.schumaker@netapp.com>, Christoph Hellwig <hch@lst.de>, Dan Williams <dan.j.williams@intel.com>, "Darrick J. Wong" <darrick.wong@oracle.com>, Eric Van Hensbergen <ericvh@gmail.com>, Jens Axboe <axboe@kernel.dk>, Johannes Weiner <hannes@cmpxchg.org>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, Latchesar Ionkov <lucho@ionkov.net>, linux-cifs@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, linux-nfs@vger.kernel.org, linux-nvdimm@lists.01.org, Matthew Wilcox <mawilcox@microsoft.com>, Ron Minnich <rminnich@sandia.gov>, samba-technical@lists.samba.org, Steve French <sfrench@samba.org>, Trond Myklebust <trond.myklebust@primarydata.com>, v9fs-developer@lists.sourceforge.net

On Wed 26-04-17 16:52:36, Ross Zwisler wrote:
> On Wed, Apr 26, 2017 at 10:52:35AM +0200, Jan Kara wrote:
> > On Tue 25-04-17 16:59:36, Ross Zwisler wrote:
> > > On Tue, Apr 25, 2017 at 01:10:43PM +0200, Jan Kara wrote:
> > > <>
> > > > Hum, but now thinking more about it I have hard time figuring out why write
> > > > vs fault cannot actually still race:
> > > > 
> > > > CPU1 - write(2)				CPU2 - read fault
> > > > 
> > > > 					dax_iomap_pte_fault()
> > > > 					  ->iomap_begin() - sees hole
> > > > dax_iomap_rw()
> > > >   iomap_apply()
> > > >     ->iomap_begin - allocates blocks
> > > >     dax_iomap_actor()
> > > >       invalidate_inode_pages2_range()
> > > >         - there's nothing to invalidate
> > > > 					  grab_mapping_entry()
> > > > 					  - we add zero page in the radix
> > > > 					    tree & map it to page tables
> > > > 
> > > > Similarly read vs write fault may end up racing in a wrong way and try to
> > > > replace already existing exceptional entry with a hole page?
> > > 
> > > Yep, this race seems real to me, too.  This seems very much like the issues
> > > that exist when a thread is doing direct I/O.  One thread is doing I/O to an
> > > intermediate buffer (page cache for direct I/O case, zero page for us), and
> > > the other is going around it directly to media, and they can get out of sync.
> > > 
> > > IIRC the direct I/O code looked something like:
> > > 
> > > 1/ invalidate existing mappings
> > > 2/ do direct I/O to media
> > > 3/ invalidate mappings again, just in case.  Should be cheap if there weren't
> > >    any conflicting faults.  This makes sure any new allocations we made are
> > >    faulted in.
> > 
> > Yeah, the problem is people generally expect weird behavior when they mix
> > direct and buffered IO (or let alone mmap) however everyone expects
> > standard read(2) and write(2) to be completely coherent with mmap(2).
> 
> Yep, fair enough.
> 
> > > I guess one option would be to replicate that logic in the DAX I/O path, or we
> > > could try and enhance our locking so page faults can't race with I/O since
> > > both can allocate blocks.
> > 
> > In the abstract way, the problem is that we have radix tree (and page
> > tables) cache block mapping information and the operation: "read block
> > mapping information, store it in the radix tree" is not serialized in any
> > way against other block allocations so the information we store can be out
> > of date by the time we store it.
> > 
> > One way to solve this would be to move ->iomap_begin call in the fault
> > paths under entry lock although that would mean I have to redo how ext4
> > handles DAX faults because with current code it would create lock inversion
> > wrt transaction start.
> 
> I don't think this alone is enough to save us.  The I/O path doesn't currently
> take any DAX radix tree entry locks, so our race would just become:
> 
> CPU1 - write(2)				CPU2 - read fault
> 
> 					dax_iomap_pte_fault()
> 					  grab_mapping_entry() // newly moved
> 					  ->iomap_begin() - sees hole
> dax_iomap_rw()
>   iomap_apply()
>     ->iomap_begin - allocates blocks
>     dax_iomap_actor()
>       invalidate_inode_pages2_range()
>         - there's nothing to invalidate
> 					  - we add zero page in the radix
> 					    tree & map it to page tables
> 
> In their current form I don't think we want to take DAX radix tree entry locks
> in the I/O path because that would effectively serialize I/O over a given
> radix tree entry. For a 2MiB entry, for example, all I/O to that 2MiB range
> would be serialized.

Note that invalidate_inode_pages2_range() will see the entry created by
grab_mapping_entry() on CPU2 and block waiting for its lock and this is
exactly what stops the race. The invalidate_inode_pages2_range()
effectively makes sure there isn't any page fault in progress for given
range...

Also note that writes to a file are serialized by i_rwsem anyway (and at
least serialization of writes to the overlapping range is required by POSIX)
so this doesn't add any more serialization than we already have.

> > Another solution would be to grab i_mmap_sem for write when doing write
> > fault of a page and similarly have it grabbed for writing when doing
> > write(2). This would scale rather poorly but if we later replaced it with a
> > range lock (Davidlohr has already posted a nice implementation of it) it
> > won't be as bad. But I guess option 1) is better...
> 
> The best idea I had for handling this sounds similar, which would be to
> convert the radix tree locks to essentially be reader/writer locks.  I/O and
> faults that don't modify the block mapping could just take read-level locks,
> and could all run concurrently.  I/O or faults that modify a block mapping
> would take a write lock, and serialize with other writers and readers.

Well, this would be difficult to implement inside the radix tree (not
enough bits in the entry) so you'd have to go for some external locking
primitive anyway. And if you do that, read-write range lock Davidlohr has
implemented is what you describe - well we could also have a radix tree
with rwsems but I suspect the overhead of maintaining that would be too
large. It would require larger rewrite than reusing entry locks as I
suggest above though and it isn't an obvious performance win for realistic
workloads either so I'd like to see some performance numbers before going
that way. It likely improves a situation where processes race to fault the
same page for which we already know the block mapping but I'm not sure if
that translates to any measurable performance wins for workloads on DAX
filesystem.

> You could know if you needed a write lock without asking the filesystem - if
> you're a write and the radix tree entry is empty or is for a zero page, you
> grab the write lock.
> 
> This dovetails nicely with the idea of having the radix tree act as a cache
> for block mappings.  You take the appropriate lock on the radix tree entry,
> and it has the block mapping info for your I/O or fault so you don't have to
> call into the FS.  I/O would also participate so we would keep info about
> block mappings that we gather from I/O to help shortcut our page faults.
> 
> How does this sound vs the range lock idea?  How hard do you think it would be
> to convert our current wait queue system to reader/writer style locking?
> 
> Also, how do you think we should deal with the current PMD corruption?  Should
> we go with the current fix (I can augment the comments as you suggested), and
> then handle optimizations to that approach and the solution to this larger
> race as a follow-on?

So for now I'm still more inclined to just stay with the radix tree lock as
is and just fix up the locking as I suggest and go for larger rewrite only
if we can demonstrate further performance wins.

WRT your second patch, if we go with the locking as I suggest, it is enough
to unmap the whole range after invalidate_inode_pages2() has cleared radix
tree entries (*) which will be much cheaper (for large writes) than doing
unmapping entry by entry. So I'd go for that. I'll prepare a patch for the
locking change - it will require changes to ext4 transaction handling so it
won't be completely trivial.

(*) The flow of information is: filesystem block mapping info -> radix tree
-> page tables so if 'filesystem block mapping info' changes, we should go
invalidate corresponding radix tree entries (new entries will already have
uptodate info) and then invalidate corresponding page tables (again once
radix tree has no stale entries, we are sure new page table entries will be
uptodate).

								Honza
-- 
Jan Kara <jack@suse.com>
SUSE Labs, CR

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
