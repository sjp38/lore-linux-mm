Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id E888E6B0033
	for <linux-mm@kvack.org>; Fri, 27 Oct 2017 02:48:59 -0400 (EDT)
Received: by mail-pf0-f199.google.com with SMTP id v2so4204063pfa.10
        for <linux-mm@kvack.org>; Thu, 26 Oct 2017 23:48:59 -0700 (PDT)
Received: from ipmail07.adl2.internode.on.net (ipmail07.adl2.internode.on.net. [150.101.137.131])
        by mx.google.com with ESMTP id 136si4462931pgf.563.2017.10.26.23.48.57
        for <linux-mm@kvack.org>;
        Thu, 26 Oct 2017 23:48:58 -0700 (PDT)
Date: Fri, 27 Oct 2017 17:48:54 +1100
From: Dave Chinner <david@fromorbit.com>
Subject: Re: [PATCH v3 00/13] dax: fix dma vs truncate and remove 'page-less'
 support
Message-ID: <20171027064854.GE3666@dastard>
References: <150846713528.24336.4459262264611579791.stgit@dwillia2-desk3.amr.corp.intel.com>
 <20171020074750.GA13568@lst.de>
 <20171020093148.GA20304@lst.de>
 <20171026105850.GA31161@quack2.suse.cz>
 <1509061831.25213.2.camel@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <1509061831.25213.2.camel@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Williams, Dan J" <dan.j.williams@intel.com>
Cc: "hch@lst.de" <hch@lst.de>, "jack@suse.cz" <jack@suse.cz>, "schwidefsky@de.ibm.com" <schwidefsky@de.ibm.com>, "darrick.wong@oracle.com" <darrick.wong@oracle.com>, "dledford@redhat.com" <dledford@redhat.com>, "linux-rdma@vger.kernel.org" <linux-rdma@vger.kernel.org>, "linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>, "bfields@fieldses.org" <bfields@fieldses.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "heiko.carstens@de.ibm.com" <heiko.carstens@de.ibm.com>, "dave.hansen@linux.intel.com" <dave.hansen@linux.intel.com>, "linux-xfs@vger.kernel.org" <linux-xfs@vger.kernel.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "jmoyer@redhat.com" <jmoyer@redhat.com>, "viro@zeniv.linux.org.uk" <viro@zeniv.linux.org.uk>, "kirill.shutemov@linux.intel.com" <kirill.shutemov@linux.intel.com>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "Hefty, Sean" <sean.hefty@intel.com>, "linux-nvdimm@lists.01.org" <linux-nvdimm@lists.01.org>, "jlayton@poochiereds.net" <jlayton@poochiereds.net>, "mawilcox@microsoft.com" <mawilcox@microsoft.com>, "mhocko@suse.com" <mhocko@suse.com>, "ross.zwisler@linux.intel.com" <ross.zwisler@linux.intel.com>, "gerald.schaefer@de.ibm.com" <gerald.schaefer@de.ibm.com>, "jgunthorpe@obsidianresearch.com" <jgunthorpe@obsidianresearch.com>, "hal.rosenstock@gmail.com" <hal.rosenstock@gmail.com>, "benh@kernel.crashing.org" <benh@kernel.crashing.org>, "mpe@ellerman.id.au" <mpe@ellerman.id.au>, "paulus@samba.org" <paulus@samba.org>

On Thu, Oct 26, 2017 at 11:51:04PM +0000, Williams, Dan J wrote:
> On Thu, 2017-10-26 at 12:58 +0200, Jan Kara wrote:
> > On Fri 20-10-17 11:31:48, Christoph Hellwig wrote:
> > > On Fri, Oct 20, 2017 at 09:47:50AM +0200, Christoph Hellwig wrote:
> > > > I'd like to brainstorm how we can do something better.
> > > > 
> > > > How about:
> > > > 
> > > > If we hit a page with an elevated refcount in truncate / hole puch
> > > > etc for a DAX file system we do not free the blocks in the file system,
> > > > but add it to the extent busy list.  We mark the page as delayed
> > > > free (e.g. page flag?) so that when it finally hits refcount zero we
> > > > call back into the file system to remove it from the busy list.
> > > 
> > > Brainstorming some more:
> > > 
> > > Given that on a DAX file there shouldn't be any long-term page
> > > references after we unmap it from the page table and don't allow
> > > get_user_pages calls why not wait for the references for all
> > > DAX pages to go away first?  E.g. if we find a DAX page in
> > > truncate_inode_pages_range that has an elevated refcount we set
> > > a new flag to prevent new references from showing up, and then
> > > simply wait for it to go away.  Instead of a busy way we can
> > > do this through a few hashed waitqueued in dev_pagemap.  And in
> > > fact put_zone_device_page already gets called when putting the
> > > last page so we can handle the wakeup from there.
> > > 
> > > In fact if we can't find a page flag for the stop new callers
> > > things we could probably come up with a way to do that through
> > > dev_pagemap somehow, but I'm not sure how efficient that would
> > > be.
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
> > 
> 
> No, that's a good summary of what we talked about. However, I did go
> back and give the new lock approach a try and was able to get my test
> to pass. The new locking is not pretty especially since you need to
> drop and reacquire the lock so that get_user_pages() can finish
> grabbing all the pages it needs. Here are the two primary patches in
> the series, do you think the extent-busy approach would be cleaner?

The XFS_DAXDMA.... 

$DEITY that patch is so ugly I can't even bring myself to type it.

-Dave.
-- 
Dave Chinner
david@fromorbit.com

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
