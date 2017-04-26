Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id 1CD196B02F2
	for <linux-mm@kvack.org>; Wed, 26 Apr 2017 18:52:40 -0400 (EDT)
Received: by mail-pf0-f200.google.com with SMTP id f5so9674499pff.13
        for <linux-mm@kvack.org>; Wed, 26 Apr 2017 15:52:40 -0700 (PDT)
Received: from mga07.intel.com (mga07.intel.com. [134.134.136.100])
        by mx.google.com with ESMTPS id s1si686806plj.295.2017.04.26.15.52.38
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 26 Apr 2017 15:52:38 -0700 (PDT)
Date: Wed, 26 Apr 2017 16:52:36 -0600
From: Ross Zwisler <ross.zwisler@linux.intel.com>
Subject: Re: [PATCH 2/2] dax: fix data corruption due to stale mmap reads
Message-ID: <20170426225236.GA25838@linux.intel.com>
References: <20170420191446.GA21694@linux.intel.com>
 <20170421034437.4359-1-ross.zwisler@linux.intel.com>
 <20170421034437.4359-2-ross.zwisler@linux.intel.com>
 <20170425111043.GH2793@quack2.suse.cz>
 <20170425225936.GA29655@linux.intel.com>
 <20170426085235.GA21738@quack2.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170426085235.GA21738@quack2.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jan Kara <jack@suse.cz>
Cc: Ross Zwisler <ross.zwisler@linux.intel.com>, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, Alexander Viro <viro@zeniv.linux.org.uk>, Alexey Kuznetsov <kuznet@virtuozzo.com>, Andrey Ryabinin <aryabinin@virtuozzo.com>, Anna Schumaker <anna.schumaker@netapp.com>, Christoph Hellwig <hch@lst.de>, Dan Williams <dan.j.williams@intel.com>, "Darrick J. Wong" <darrick.wong@oracle.com>, Eric Van Hensbergen <ericvh@gmail.com>, Jens Axboe <axboe@kernel.dk>, Johannes Weiner <hannes@cmpxchg.org>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, Latchesar Ionkov <lucho@ionkov.net>, linux-cifs@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, linux-nfs@vger.kernel.org, linux-nvdimm@lists.01.org, Matthew Wilcox <mawilcox@microsoft.com>, Ron Minnich <rminnich@sandia.gov>, samba-technical@lists.samba.org, Steve French <sfrench@samba.org>, Trond Myklebust <trond.myklebust@primarydata.com>, v9fs-developer@lists.sourceforge.net

On Wed, Apr 26, 2017 at 10:52:35AM +0200, Jan Kara wrote:
> On Tue 25-04-17 16:59:36, Ross Zwisler wrote:
> > On Tue, Apr 25, 2017 at 01:10:43PM +0200, Jan Kara wrote:
> > <>
> > > Hum, but now thinking more about it I have hard time figuring out why write
> > > vs fault cannot actually still race:
> > > 
> > > CPU1 - write(2)				CPU2 - read fault
> > > 
> > > 					dax_iomap_pte_fault()
> > > 					  ->iomap_begin() - sees hole
> > > dax_iomap_rw()
> > >   iomap_apply()
> > >     ->iomap_begin - allocates blocks
> > >     dax_iomap_actor()
> > >       invalidate_inode_pages2_range()
> > >         - there's nothing to invalidate
> > > 					  grab_mapping_entry()
> > > 					  - we add zero page in the radix
> > > 					    tree & map it to page tables
> > > 
> > > Similarly read vs write fault may end up racing in a wrong way and try to
> > > replace already existing exceptional entry with a hole page?
> > 
> > Yep, this race seems real to me, too.  This seems very much like the issues
> > that exist when a thread is doing direct I/O.  One thread is doing I/O to an
> > intermediate buffer (page cache for direct I/O case, zero page for us), and
> > the other is going around it directly to media, and they can get out of sync.
> > 
> > IIRC the direct I/O code looked something like:
> > 
> > 1/ invalidate existing mappings
> > 2/ do direct I/O to media
> > 3/ invalidate mappings again, just in case.  Should be cheap if there weren't
> >    any conflicting faults.  This makes sure any new allocations we made are
> >    faulted in.
> 
> Yeah, the problem is people generally expect weird behavior when they mix
> direct and buffered IO (or let alone mmap) however everyone expects
> standard read(2) and write(2) to be completely coherent with mmap(2).

Yep, fair enough.

> > I guess one option would be to replicate that logic in the DAX I/O path, or we
> > could try and enhance our locking so page faults can't race with I/O since
> > both can allocate blocks.
> 
> In the abstract way, the problem is that we have radix tree (and page
> tables) cache block mapping information and the operation: "read block
> mapping information, store it in the radix tree" is not serialized in any
> way against other block allocations so the information we store can be out
> of date by the time we store it.
> 
> One way to solve this would be to move ->iomap_begin call in the fault
> paths under entry lock although that would mean I have to redo how ext4
> handles DAX faults because with current code it would create lock inversion
> wrt transaction start.

I don't think this alone is enough to save us.  The I/O path doesn't currently
take any DAX radix tree entry locks, so our race would just become:

CPU1 - write(2)				CPU2 - read fault

					dax_iomap_pte_fault()
					  grab_mapping_entry() // newly moved
					  ->iomap_begin() - sees hole
dax_iomap_rw()
  iomap_apply()
    ->iomap_begin - allocates blocks
    dax_iomap_actor()
      invalidate_inode_pages2_range()
        - there's nothing to invalidate
					  - we add zero page in the radix
					    tree & map it to page tables

In their current form I don't think we want to take DAX radix tree entry locks
in the I/O path because that would effectively serialize I/O over a given
radix tree entry. For a 2MiB entry, for example, all I/O to that 2MiB range
would be serialized.

> Another solution would be to grab i_mmap_sem for write when doing write
> fault of a page and similarly have it grabbed for writing when doing
> write(2). This would scale rather poorly but if we later replaced it with a
> range lock (Davidlohr has already posted a nice implementation of it) it
> won't be as bad. But I guess option 1) is better...

The best idea I had for handling this sounds similar, which would be to
convert the radix tree locks to essentially be reader/writer locks.  I/O and
faults that don't modify the block mapping could just take read-level locks,
and could all run concurrently.  I/O or faults that modify a block mapping
would take a write lock, and serialize with other writers and readers.

You could know if you needed a write lock without asking the filesystem - if
you're a write and the radix tree entry is empty or is for a zero page, you
grab the write lock.

This dovetails nicely with the idea of having the radix tree act as a cache
for block mappings.  You take the appropriate lock on the radix tree entry,
and it has the block mapping info for your I/O or fault so you don't have to
call into the FS.  I/O would also participate so we would keep info about
block mappings that we gather from I/O to help shortcut our page faults.

How does this sound vs the range lock idea?  How hard do you think it would be
to convert our current wait queue system to reader/writer style locking?

Also, how do you think we should deal with the current PMD corruption?  Should
we go with the current fix (I can augment the comments as you suggested), and
then handle optimizations to that approach and the solution to this larger
race as a follow-on?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
