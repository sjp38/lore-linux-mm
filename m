Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f200.google.com (mail-io0-f200.google.com [209.85.223.200])
	by kanga.kvack.org (Postfix) with ESMTP id B58716B02F3
	for <linux-mm@kvack.org>; Thu, 22 Jun 2017 03:23:31 -0400 (EDT)
Received: by mail-io0-f200.google.com with SMTP id j24so18197774ioi.0
        for <linux-mm@kvack.org>; Thu, 22 Jun 2017 00:23:31 -0700 (PDT)
Received: from aserp1040.oracle.com (aserp1040.oracle.com. [141.146.126.69])
        by mx.google.com with ESMTPS id y88si858549ioe.130.2017.06.22.00.23.30
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 22 Jun 2017 00:23:30 -0700 (PDT)
Date: Thu, 22 Jun 2017 00:23:20 -0700
From: "Darrick J. Wong" <darrick.wong@oracle.com>
Subject: Re: [RFC PATCH 2/2] mm, fs: daxfile, an interface for
 byte-addressable updates to pmem
Message-ID: <20170622072320.GH3787@birch.djwong.org>
References: <149766212410.22552.15957843500156182524.stgit@dwillia2-desk3.amr.corp.intel.com>
 <149766213493.22552.4057048843646200083.stgit@dwillia2-desk3.amr.corp.intel.com>
 <20170620052214.GA3787@birch.djwong.org>
 <20170621233714.GH11993@dastard>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170621233714.GH11993@dastard>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Chinner <david@fromorbit.com>
Cc: Dan Williams <dan.j.williams@intel.com>, akpm@linux-foundation.org, Jan Kara <jack@suse.cz>, linux-nvdimm@lists.01.org, linux-api@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Jeff Moyer <jmoyer@redhat.com>, linux-fsdevel@vger.kernel.org, Ross Zwisler <ross.zwisler@linux.intel.com>, Christoph Hellwig <hch@lst.de>, xfs <linux-xfs@vger.kernel.org>

On Thu, Jun 22, 2017 at 09:37:14AM +1000, Dave Chinner wrote:
> On Mon, Jun 19, 2017 at 10:22:14PM -0700, Darrick J. Wong wrote:
> > [add linux-xfs to the fray]
> > 
> > On Fri, Jun 16, 2017 at 06:15:35PM -0700, Dan Williams wrote:
> > > +	spin_lock(&dax_lock);
> > > +	list_add(&d->list, &daxfiles);
> > > +	spin_unlock(&dax_lock);
> > > +
> > > +	/*
> > > +	 * We set S_SWAPFILE to gain "no truncate" / static block
> > > +	 * allocation semantics, and S_DAXFILE so we can differentiate
> > > +	 * traditional swapfiles and assume static block mappings in the
> > > +	 * dax mmap path.
> > > +	 */
> > > +	inode->i_flags |= S_SWAPFILE | S_DAXFILE;
> > 
> > Yikes.  You know, I hadn't even thought about considering swap files as
> > a subcase of files with immutable block maps, but here we are.  Both
> > swap files and DAX require absolutely stable block mappings, they are
> > both (probably) intolerant of inode metadata changes (size, mtime, etc.)
> 
> Swap files are intolerant of any metadata changes because once the
> mapping has been sucked into the swapfile code, the inode is never
> looked at again. DAX file data access always goes through the inode,
> so they is much more tolerant of metadata changes given certain
> constraints.

Fair enough.

> <snip bmap rant>
> 
> > Honestly, I realize we've gone back, forth, and around all over the
> > place on this.  I still prefer something similar to a permanent flag,
> > similar to what Dave suggested, though I hate the name PMEM_IMMUTABLE
> > and some of the semantics.
> > 
> > First, a new inode flag S_IOMAP_FROZEN that means the file's block map
> > cannot change.
> 
> I've been calling it "immutable extents" - freezing has implications
> that it's only temporary (i.e. freezing filesystems) and will be
> followed shortly by a thaw. That isn't the case here - we truly want
> the extent/block map to be immutable....

<nod> S_IOMAP_IMMUTABLE it is, then.

> > Second, some kind of function to toggle the S_IOMAP_FROZEN flag.
> > Turning it on will lock the inode, check the extent map for holes,
> > shared, or unwritten bits, and bail out if it finds any, or set the
> > flag. 
> 
> Hmmm, I disagree on the unwritten state here.  We want swap files to
> be able to use unwritten extents - it means we can preallocate the
> swap file and hand it straight to swapon without having to zero it
> (i.e. no I/O needed to demand allocate more swap space when memory
> is very low).  Also, anyone who tries to read the swap file from
> userspace will be reading unwritten extents, which will always
> return zeros rather than whatever is in the swap file...

Now I've twisted all the way around to thinking that swap files
should be /totally/ unwritten, except for the file header. :)

> > Not sure if we should require CAP_LINUX_IMMUTABLE -- probably
> > yes, at least at first.  I don't currently have any objection to writing
> > non-iomap inode metadata out to disk.
> > 
> > Third, the flag can only be cleared if the file isn't mapped.
> 
> How do we check this from the fs without racing? AFAICT we can't
> prevent a concurrent map operation from occurring while we are
> changing the state of the inode - we can only block page faults
> after then inode is mapped....

I'd thought we could coordinate that via xfs_file_mmap, but tbh my brain
paged that out a while ago.

> > Fourth, the VFS entry points for things like read, write, truncate,
> > utimes, fallocate, etc. all just bail out if S_IOMAP_FROZEN is set on a
> > file, so that the block map cannot be modified.
> > mmap is still allowed,
> > as we've discussed.  /Maybe/ we can allow fallocate to extend a file
> > with zeroed extents (it will be slow) as I've heard murmurs about
> > wanting to be able to extend a file, maybe not.
> 
> read is fine, write should be fine as long as the iomap call can
> error out operations that would require extent map modifications.

Ok.

> fallocate should be allowed to modify the extent map, too, because
> it should be the mechanism used be applications to set up file
> extents in the correct form for applications to use as immutable
> (i.e. lock out page faults, allocate, zero, extend and fsync in
> one atomic operation)....

<nod>

> > Fifth, swapfiles now require the S_IOMAP_FROZEN flag since they want
> > stable iomap but probably don't care about things like mtime.  Maybe
> > they can call iomap too.
> > 
> > Sixth, XFS can record the S_IOMAP_FROZEN state in di_flags2 and set it
> > whenever the in-core inode gets constructed.  This enables us to
> > prohibit reflinking and other such undesirable activity.
> 
> *nod*
> 
> > If we actually /do/ come up with a reference implementation for XFS, I'd
> > be ok with tacking it on the end of my dev branch, which will give us a
> > loooong runway to try it out.  The end of the dev branch is beyond
> > online XFS fsck and repair and the "root metadata btrees in inodes"
> > rework; since that's ~90 patches with my name on it that I cannot also
> > review, it won't go in for a long time indeed!
> 
> I don't think it's so complex to need such a long dev time -
> all the infrastructure we need is pretty much there already...

It definitely is, but we've been bikeshedding so long it now has
momentum. :)

That said, it (and having a go at dax+reflink) are things that I'd like
to look at (after pushing the scrub stuff) for the rest of the year.

> > (Yes, that was also sort of a plea for someone to go review the XFS
> > scrub patches.)
> > 
> > > +	return 0;
> > > +}
> > > +
> > > +SYSCALL_DEFINE3(daxctl, const char __user *, path, int, flags, int, align)
> > 
> > I was /about/ to grouse about this syscall, then realized that maybe it
> > /is/ useful to be able to check a specific alignment.  Maybe not, since
> > I had something more permanent in mind anyway.  In any case, just pass
> > in an opened fd if this sticks around.
> 
> We can do all that via fallocate(), too...
> 
> Cheers,
> 
> Dave.
> -- 
> Dave Chinner
> david@fromorbit.com
> --
> To unsubscribe from this list: send the line "unsubscribe linux-api" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
