Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ot0-f200.google.com (mail-ot0-f200.google.com [74.125.82.200])
	by kanga.kvack.org (Postfix) with ESMTP id 083F06B0003
	for <linux-mm@kvack.org>; Thu, 24 May 2018 14:14:01 -0400 (EDT)
Received: by mail-ot0-f200.google.com with SMTP id m10-v6so1411559otb.5
        for <linux-mm@kvack.org>; Thu, 24 May 2018 11:14:01 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id p23-v6si7793071ota.167.2018.05.24.11.13.59
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 24 May 2018 11:13:59 -0700 (PDT)
Date: Thu, 24 May 2018 14:13:56 -0400
From: Brian Foster <bfoster@redhat.com>
Subject: Re: [PATCH 22/34] xfs: make xfs_writepage_map extent map centric
Message-ID: <20180524181356.GA89391@bfoster.bfoster>
References: <20180523144357.18985-1-hch@lst.de>
 <20180523144357.18985-23-hch@lst.de>
 <20180524145935.GA84959@bfoster.bfoster>
 <20180524165350.GA22675@lst.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180524165350.GA22675@lst.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Hellwig <hch@lst.de>
Cc: linux-xfs@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, Dave Chinner <dchinner@redhat.com>

On Thu, May 24, 2018 at 06:53:50PM +0200, Christoph Hellwig wrote:
> > > +		if (!wpc->imap_valid || wpc->io_type == XFS_IO_HOLE) {
> > > +			/*
> > > +			 * set_page_dirty dirties all buffers in a page, independent
> > > +			 * of their state.  The dirty state however is entirely
> > > +			 * meaningless for holes (!mapped && uptodate), so check we did
> > > +			 * have a buffer covering a hole here and continue.
> > > +			 */
> > 
> > The comment above doesn't make much sense given that we don't check for
> > anything here and just continue the loop.
> 
> It gets removed in the last patch of the original series when we
> kill buffer heads.  But I can fold the removal into this patch as well.
> 

Ah, I was thinking this patch added that comment when it actually mostly
moves it (it does tweak it a bit). Eh, no big deal either way.

> > That aside, the concern I had with this patch when it was last posted is
> > that it indirectly dropped the error/consistency check between page
> > state and extent state provided by the XFS_BMAPI_DELALLOC flag. What was
> > historically an accounting/reservation issue was turned into something
> > like this by XFS_BMAPI_DELALLOC:
> > 
> > # xfs_io -c "pwrite 0 4k" -c fsync /mnt/file
> > wrote 4096/4096 bytes at offset 0
> > 4 KiB, 1 ops; 0.0041 sec (974.184 KiB/sec and 243.5460 ops/sec)
> > fsync: Input/output error
> 
> What is that issue that gets you an I/O error on a 4k write?  That
> is what is missing in the above reproducer?
> 

Sorry... I should have mentioned this is a simulated error and not
something that actually occurs right now. You can manufacture it easy
enough using the drop_writes error tag and comment out the pagecache
truncate code in xfs_file_iomap_end_delalloc().

> > As of this patch, that same error condition now behaves something like
> > this:
> > 
> > [root@localhost ~]# xfs_io -c "pwrite 0 4k" -c fsync /mnt/file
> > wrote 4096/4096 bytes at offset 0
> > 4 KiB, 1 ops; 0.0029 sec (1.325 MiB/sec and 339.2130 ops/sec)
> > [root@localhost ~]# ls -al /mnt/file
> > -rw-r--r--. 1 root root 4096 May 24 08:27 /mnt/file
> > [root@localhost ~]# umount  /mnt ; mount /dev/test/scratch /mnt/
> > [root@localhost ~]# ls -al /mnt/file
> > -rw-r--r--. 1 root root 0 May 24 08:27 /mnt/file
> > 
> > So our behavior has changed from forced block allocation (violating
> > reservation) and writing the data, to instead return an error, and now
> > to silently skip the page.
> 
> We should never, ever allocate space that we didn't have a delalloc
> reservation for in writepage/writepages.  But I agree that we should
> record and error.  I have to admit I'm lost on where we did record
> the error and why we don't do that now.  I'd be happy to fix it.
> 

Right, the error behavior came from the XFS_BMAPI_DELALLOC flag that was
passed from xfs_iomap_write_allocate(). It caused xfs_bmapi_write() to
detect that we were in a hole and return an error in the !COW_FORK case
since we were expecting to do delalloc conversion from writeback.

Note that I'm not saying there's a vector to reproduce this problem in
the current code that I'm aware of. I'm just saying it's happened in the
past due to bugs and I'd like to preserve some kind of basic sanity
check (as an error or assert) if we have enough state available to do
so.

> > I suppose there are situations (i.e., races
> > with truncate) where a hole is valid and the correct behavior is to skip
> > the page, and this is admittedly an error condition that "should never
> > happen," but can we at least add an assert somewhere in this series that
> > ensures if uptodate data maps over a hole that the associated block
> > offset is beyond EOF (or something of that nature)?
> 
> We can have plenty of holes in dirty pages.  However we should never
> allocate blocks for them.  Fortunately we stop even looking at anything
> but the extent tree for block status by the end of this series for 4k
> file systems, and with the next series even for small block sizes, so
> that whole mismatch is a thing of the past now.

Ok, so I guess writeback can see uptodate blocks over a hole if some
other block in that page is dirty. Perhaps we could make sure that a
dirty page has at least one block that maps to an actual extent or
otherwise the page has been truncated..?

I guess having another dirty block bitmap similar to
iomap_page->uptodate could be required to tell for sure whether a
particular block should definitely have a block on-disk or not. It may
not be worth doing that just for additional error checks, but I still
have to look into the last few patches to grok all the iomap_page stuff.

Brian
