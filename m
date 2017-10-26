Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f198.google.com (mail-wr0-f198.google.com [209.85.128.198])
	by kanga.kvack.org (Postfix) with ESMTP id F05EA6B0033
	for <linux-mm@kvack.org>; Thu, 26 Oct 2017 06:58:58 -0400 (EDT)
Received: by mail-wr0-f198.google.com with SMTP id v105so1431497wrc.11
        for <linux-mm@kvack.org>; Thu, 26 Oct 2017 03:58:58 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id r21si3210460edc.548.2017.10.26.03.58.56
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 26 Oct 2017 03:58:56 -0700 (PDT)
Date: Thu, 26 Oct 2017 12:58:50 +0200
From: Jan Kara <jack@suse.cz>
Subject: Re: [PATCH v3 00/13] dax: fix dma vs truncate and remove 'page-less'
 support
Message-ID: <20171026105850.GA31161@quack2.suse.cz>
References: <150846713528.24336.4459262264611579791.stgit@dwillia2-desk3.amr.corp.intel.com>
 <20171020074750.GA13568@lst.de>
 <20171020093148.GA20304@lst.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20171020093148.GA20304@lst.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Hellwig <hch@lst.de>
Cc: Dan Williams <dan.j.williams@intel.com>, akpm@linux-foundation.org, Michal Hocko <mhocko@suse.com>, Jan Kara <jack@suse.cz>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Dave Hansen <dave.hansen@linux.intel.com>, Dave Chinner <david@fromorbit.com>, "J. Bruce Fields" <bfields@fieldses.org>, linux-mm@kvack.org, Paul Mackerras <paulus@samba.org>, Sean Hefty <sean.hefty@intel.com>, Jeff Layton <jlayton@poochiereds.net>, Matthew Wilcox <mawilcox@microsoft.com>, linux-rdma@vger.kernel.org, Michael Ellerman <mpe@ellerman.id.au>, Jeff Moyer <jmoyer@redhat.com>, Jason Gunthorpe <jgunthorpe@obsidianresearch.com>, Doug Ledford <dledford@redhat.com>, Ross Zwisler <ross.zwisler@linux.intel.com>, Hal Rosenstock <hal.rosenstock@gmail.com>, Heiko Carstens <heiko.carstens@de.ibm.com>, linux-nvdimm@lists.01.org, Alexander Viro <viro@zeniv.linux.org.uk>, Gerald Schaefer <gerald.schaefer@de.ibm.com>, "Darrick J. Wong" <darrick.wong@oracle.com>, linux-kernel@vger.kernel.org, linux-xfs@vger.kernel.org, Martin Schwidefsky <schwidefsky@de.ibm.com>, linux-fsdevel@vger.kernel.org, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

On Fri 20-10-17 11:31:48, Christoph Hellwig wrote:
> On Fri, Oct 20, 2017 at 09:47:50AM +0200, Christoph Hellwig wrote:
> > I'd like to brainstorm how we can do something better.
> > 
> > How about:
> > 
> > If we hit a page with an elevated refcount in truncate / hole puch
> > etc for a DAX file system we do not free the blocks in the file system,
> > but add it to the extent busy list.  We mark the page as delayed
> > free (e.g. page flag?) so that when it finally hits refcount zero we
> > call back into the file system to remove it from the busy list.
> 
> Brainstorming some more:
> 
> Given that on a DAX file there shouldn't be any long-term page
> references after we unmap it from the page table and don't allow
> get_user_pages calls why not wait for the references for all
> DAX pages to go away first?  E.g. if we find a DAX page in
> truncate_inode_pages_range that has an elevated refcount we set
> a new flag to prevent new references from showing up, and then
> simply wait for it to go away.  Instead of a busy way we can
> do this through a few hashed waitqueued in dev_pagemap.  And in
> fact put_zone_device_page already gets called when putting the
> last page so we can handle the wakeup from there.
> 
> In fact if we can't find a page flag for the stop new callers
> things we could probably come up with a way to do that through
> dev_pagemap somehow, but I'm not sure how efficient that would
> be.

We were talking about this yesterday with Dan so some more brainstorming
from us. We can implement the solution with extent busy list in ext4
relatively easily - we already have such list currently similarly to XFS.
There would be some modifications needed but nothing too complex. The
biggest downside of this solution I see is that it requires per-filesystem
solution for busy extents - ext4 and XFS are reasonably fine, however btrfs
may have problems and ext2 definitely will need some modifications.
Invisible used blocks may be surprising to users at times although given
page refs should be relatively short term, that should not be a big issue.
But are we guaranteed page refs are short term? E.g. if someone creates
v4l2 videobuf in MAP_SHARED mapping of a file on DAX filesystem, page refs
can be rather long-term similarly as in RDMA case. Also freeing of blocks
on page reference drop is another async entry point into the filesystem
which could unpleasantly surprise us but I guess workqueues would solve
that reasonably fine.

WRT waiting for page refs to be dropped before proceeding with truncate (or
punch hole for that matter - that case is even nastier since we don't have
i_size to guard us). What I like about this solution is that it is very
visible there's something unusual going on with the file being truncated /
punched and so problems are easier to diagnose / fix from the admin side.
So far we have guarded hole punching from concurrent faults (and
get_user_pages() does fault once you do unmap_mapping_range()) with
I_MMAP_LOCK (or its equivalent in ext4). We cannot easily wait for page
refs to be dropped under I_MMAP_LOCK as that could deadlock - the most
obvious case Dan came up with is when GUP obtains ref to page A, then hole
punch comes grabbing I_MMAP_LOCK and waiting for page ref on A to be
dropped, and then GUP blocks on trying to fault in another page.

I think we cannot easily prevent new page references to be grabbed as you
write above since nobody expects stuff like get_page() to fail. But I 
think that unmapping relevant pages and then preventing them to be faulted
in again is workable and stops GUP as well. The problem with that is though
what to do with page faults to such pages - you cannot just fail them for
hole punch, and you cannot easily allocate new blocks either. So we are
back at a situation where we need to detach blocks from the inode and then
wait for page refs to be dropped - so some form of busy extents. Am I
missing something?

								Honza
-- 
Jan Kara <jack@suse.com>
SUSE Labs, CR

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
