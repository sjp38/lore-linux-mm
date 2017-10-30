Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f70.google.com (mail-pg0-f70.google.com [74.125.83.70])
	by kanga.kvack.org (Postfix) with ESMTP id BCA706B0033
	for <linux-mm@kvack.org>; Sun, 29 Oct 2017 22:00:30 -0400 (EDT)
Received: by mail-pg0-f70.google.com with SMTP id 15so11817807pgc.16
        for <linux-mm@kvack.org>; Sun, 29 Oct 2017 19:00:30 -0700 (PDT)
Received: from ipmail07.adl2.internode.on.net (ipmail07.adl2.internode.on.net. [150.101.137.131])
        by mx.google.com with ESMTP id 34si7989631pln.732.2017.10.29.19.00.27
        for <linux-mm@kvack.org>;
        Sun, 29 Oct 2017 19:00:28 -0700 (PDT)
Date: Mon, 30 Oct 2017 13:00:23 +1100
From: Dave Chinner <david@fromorbit.com>
Subject: Re: [PATCH v3 00/13] dax: fix dma vs truncate and remove 'page-less'
 support
Message-ID: <20171030020023.GG3666@dastard>
References: <150846713528.24336.4459262264611579791.stgit@dwillia2-desk3.amr.corp.intel.com>
 <20171020074750.GA13568@lst.de>
 <20171020093148.GA20304@lst.de>
 <20171026105850.GA31161@quack2.suse.cz>
 <CAA9_cmeiT2CU8Nue-HMCv+AyuDmSzXoCVxD1bebt2+cBDRTWog@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAA9_cmeiT2CU8Nue-HMCv+AyuDmSzXoCVxD1bebt2+cBDRTWog@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dan Williams <dan.j.williams@gmail.com>
Cc: Jan Kara <jack@suse.cz>, Christoph Hellwig <hch@lst.de>, Michal Hocko <mhocko@suse.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Dave Hansen <dave.hansen@linux.intel.com>, Heiko Carstens <heiko.carstens@de.ibm.com>, "J. Bruce Fields" <bfields@fieldses.org>, linux-mm <linux-mm@kvack.org>, Paul Mackerras <paulus@samba.org>, Sean Hefty <sean.hefty@intel.com>, Jeff Layton <jlayton@poochiereds.net>, Matthew Wilcox <mawilcox@microsoft.com>, linux-rdma@vger.kernel.org, Michael Ellerman <mpe@ellerman.id.au>, Jason Gunthorpe <jgunthorpe@obsidianresearch.com>, Doug Ledford <dledford@redhat.com>, Hal Rosenstock <hal.rosenstock@gmail.com>, linux-fsdevel <linux-fsdevel@vger.kernel.org>, Alexander Viro <viro@zeniv.linux.org.uk>, Gerald Schaefer <gerald.schaefer@de.ibm.com>, "linux-nvdimm@lists.01.org" <linux-nvdimm@lists.01.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, linux-xfs@vger.kernel.org, Martin Schwidefsky <schwidefsky@de.ibm.com>, Andrew Morton <akpm@linux-foundation.org>, "Darrick J. Wong" <darrick.wong@oracle.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

On Sun, Oct 29, 2017 at 04:46:44PM -0700, Dan Williams wrote:
> On Thu, Oct 26, 2017 at 3:58 AM, Jan Kara <jack@suse.cz> wrote:
> > On Fri 20-10-17 11:31:48, Christoph Hellwig wrote:
> >> On Fri, Oct 20, 2017 at 09:47:50AM +0200, Christoph Hellwig wrote:
> >> > I'd like to brainstorm how we can do something better.
> >> >
> >> > How about:
> >> >
> >> > If we hit a page with an elevated refcount in truncate / hole puch
> >> > etc for a DAX file system we do not free the blocks in the file system,
> >> > but add it to the extent busy list.  We mark the page as delayed
> >> > free (e.g. page flag?) so that when it finally hits refcount zero we
> >> > call back into the file system to remove it from the busy list.
> >>
> >> Brainstorming some more:
> >>
> >> Given that on a DAX file there shouldn't be any long-term page
> >> references after we unmap it from the page table and don't allow
> >> get_user_pages calls why not wait for the references for all
> >> DAX pages to go away first?  E.g. if we find a DAX page in
> >> truncate_inode_pages_range that has an elevated refcount we set
> >> a new flag to prevent new references from showing up, and then
> >> simply wait for it to go away.  Instead of a busy way we can
> >> do this through a few hashed waitqueued in dev_pagemap.  And in
> >> fact put_zone_device_page already gets called when putting the
> >> last page so we can handle the wakeup from there.
> >>
> >> In fact if we can't find a page flag for the stop new callers
> >> things we could probably come up with a way to do that through
> >> dev_pagemap somehow, but I'm not sure how efficient that would
> >> be.
> >
> > We were talking about this yesterday with Dan so some more brainstorming
> > from us. We can implement the solution with extent busy list in ext4
> > relatively easily - we already have such list currently similarly to XFS.
> > There would be some modifications needed but nothing too complex. The
> > biggest downside of this solution I see is that it requires per-filesystem
> > solution for busy extents - ext4 and XFS are reasonably fine, however btrfs
> > may have problems and ext2 definitely will need some modifications.
> > Invisible used blocks may be surprising to users at times although given
> > page refs should be relatively short term, that should not be a big issue.
> > But are we guaranteed page refs are short term? E.g. if someone creates
> > v4l2 videobuf in MAP_SHARED mapping of a file on DAX filesystem, page refs
> > can be rather long-term similarly as in RDMA case. Also freeing of blocks
> > on page reference drop is another async entry point into the filesystem
> > which could unpleasantly surprise us but I guess workqueues would solve
> > that reasonably fine.
> >
> > WRT waiting for page refs to be dropped before proceeding with truncate (or
> > punch hole for that matter - that case is even nastier since we don't have
> > i_size to guard us). What I like about this solution is that it is very
> > visible there's something unusual going on with the file being truncated /
> > punched and so problems are easier to diagnose / fix from the admin side.
> > So far we have guarded hole punching from concurrent faults (and
> > get_user_pages() does fault once you do unmap_mapping_range()) with
> > I_MMAP_LOCK (or its equivalent in ext4). We cannot easily wait for page
> > refs to be dropped under I_MMAP_LOCK as that could deadlock - the most
> > obvious case Dan came up with is when GUP obtains ref to page A, then hole
> > punch comes grabbing I_MMAP_LOCK and waiting for page ref on A to be
> > dropped, and then GUP blocks on trying to fault in another page.
> >
> > I think we cannot easily prevent new page references to be grabbed as you
> > write above since nobody expects stuff like get_page() to fail. But I
> > think that unmapping relevant pages and then preventing them to be faulted
> > in again is workable and stops GUP as well. The problem with that is though
> > what to do with page faults to such pages - you cannot just fail them for
> > hole punch, and you cannot easily allocate new blocks either. So we are
> > back at a situation where we need to detach blocks from the inode and then
> > wait for page refs to be dropped - so some form of busy extents. Am I
> > missing something?
> 
> Coming back to this since Dave has made clear that new locking to
> coordinate get_user_pages() is a no-go.
> 
> We can unmap to force new get_user_pages() attempts to block on the
> per-fs mmap lock, but if punch-hole finds any elevated pages it needs
> to drop the mmap lock and wait. We need this lock dropped to get
> around the problem that the driver will not start to drop page
> references until it has elevated the page references on all the pages
> in the I/O. If we need to drop the mmap lock that makes it impossible
> to coordinate this unlock/retry loop within truncate_inode_pages_range
> which would otherwise be the natural place to land this code.
> 
> Would it be palatable to unmap and drain dma in any path that needs to
> detach blocks from an inode? Something like the following that builds
> on dax_wait_dma() tried to achieve, but does not introduce a new lock
> for the fs to manage:
> 
> retry:
>     per_fs_mmap_lock(inode);
>     unmap_mapping_range(mapping, start, end); /* new page references
> cannot be established */
>     if ((dax_page = dax_dma_busy_page(mapping, start, end)) != NULL) {
>         per_fs_mmap_unlock(inode); /* new page references can happen,
> so we need to start over */
>         wait_for_page_idle(dax_page);
>         goto retry;
>     }
>     truncate_inode_pages_range(mapping, start, end);
>     per_fs_mmap_unlock(inode);

These retry loops you keep proposing are just bloody horrible.  They
are basically just a method for blocking an operation until whatever
condition is preventing the invalidation goes away. IMO, that's an
ugly solution no matter how much lipstick you dress it up with.

i.e. the blocking loops mean the user process is going to be blocked
for arbitrary lengths of time. That's not a solution, it's just
passing the buck - now the userspace developers need to work around
truncate/hole punch being randomly blocked for arbitrary lengths of
time.

The whole point of pushing this into the busy extent list is that it
doesn't require blocking operations. i.e the re-use of the underlying
storage is simply delayed until notification that it is safe to
re-use comes along, but the extent removal operation doesn't get
blocked.

That's how we treat extents that require discard operations after
they have been freed - they remain in the busy list until the
discard IO completion signals "all done" and clears the busy extent.
Here we need to hold off clearing the extent until we get the "all
done" from the dax code.

e.g. what needs to happen when trying to do the invalidation is
something like this (assuming invalidate_inode_pages2_range() will
actually fail on pages under DMA):

	flags = 0;
	if (IS_DAX()) {
		error = invalidate_inode_pages2_range()
		if (error == -EBUSY && dax_dma_busy_page())
			flags = EXTENT_BUSY_DAX;
		else
			truncate_pagecache(); /* blocking */
	} else {
		truncate_pagecache();
	}

that EXTENT_BUSY_DAX flag needs to be carried all the way through to
the xfs_free_extent -> xfs_extent_busy_insert(). That's probably the
most complex part of the patch.

This flag then prevents xfs_extent_busy_reuse() from allowing reuse
of the extent.

And in xfs_extent_busy_clear(), they need to be treated sort of like
discarded extents. On transaction commit callback, we need to check
if there are still busy daxdma pages over the extent range, and if
there are we leave it in the busy list, otherwise it can be cleared.
For everything that is left in the busy list, the dax dma code will
need to call back into the filesystem when that page is released and
when the extent no long has any dax dma busy pages left over it it
can be cleared from the list.

Once we have the dax code to call back into the filesystem when the
problematic daxdma pages are released, and everything else should be
relatively straight forward...

Cheers,

Dave.
-- 
Dave Chinner
david@fromorbit.com

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
