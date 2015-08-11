Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f178.google.com (mail-wi0-f178.google.com [209.85.212.178])
	by kanga.kvack.org (Postfix) with ESMTP id 934F86B0038
	for <linux-mm@kvack.org>; Tue, 11 Aug 2015 11:28:54 -0400 (EDT)
Received: by wijp15 with SMTP id p15so181421955wij.0
        for <linux-mm@kvack.org>; Tue, 11 Aug 2015 08:28:54 -0700 (PDT)
Received: from mail-wi0-f173.google.com (mail-wi0-f173.google.com. [209.85.212.173])
        by mx.google.com with ESMTPS id jv5si5326185wid.14.2015.08.11.08.28.52
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 11 Aug 2015 08:28:52 -0700 (PDT)
Received: by wicne3 with SMTP id ne3so181951557wic.1
        for <linux-mm@kvack.org>; Tue, 11 Aug 2015 08:28:52 -0700 (PDT)
Date: Tue, 11 Aug 2015 18:28:50 +0300
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: [PATCH, RFC 2/2] dax: use range_lock instead of i_mmap_lock
Message-ID: <20150811152850.GA2608@node.dhcp.inet.fi>
References: <1439219664-88088-1-git-send-email-kirill.shutemov@linux.intel.com>
 <1439219664-88088-3-git-send-email-kirill.shutemov@linux.intel.com>
 <20150811081909.GD2650@quack.suse.cz>
 <20150811093708.GB906@dastard>
 <20150811135004.GC2659@quack.suse.cz>
 <55CA0728.7060001@plexistor.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <55CA0728.7060001@plexistor.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Boaz Harrosh <boaz@plexistor.com>
Cc: Jan Kara <jack@suse.cz>, Dave Chinner <david@fromorbit.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Andrew Morton <akpm@linux-foundation.org>, Matthew Wilcox <matthew.r.wilcox@intel.com>, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org, Davidlohr Bueso <dbueso@suse.de>, Theodore Ts'o <tytso@mit.edu>

On Tue, Aug 11, 2015 at 05:31:04PM +0300, Boaz Harrosh wrote:
> On 08/11/2015 04:50 PM, Jan Kara wrote:
> > On Tue 11-08-15 19:37:08, Dave Chinner wrote:
> >>>> The patch below tries to recover some scalability for DAX by introducing
> >>>> per-mapping range lock.
> >>>
> >>> So this grows noticeably (3 longs if I'm right) struct address_space and
> >>> thus struct inode just for DAX. That looks like a waste but I don't see an
> >>> easy solution.
> >>>
> >>> OTOH filesystems in normal mode might want to use the range lock as well to
> >>> provide truncate / punch hole vs page fault exclusion (XFS already has a
> >>> private rwsem for this and ext4 needs something as well) and at that point
> >>> growing generic struct inode would be acceptable for me.
> >>
> >> It sounds to me like the way DAX has tried to solve this race is the
> >> wrong direction. We really need to drive the truncate/page fault
> >> serialisation higher up the stack towards the filesystem, not deeper
> >> into the mm subsystem where locking is greatly limited.
> >>
> >> As Jan mentions, we already have this serialisation in XFS, and I
> >> think it would be better first step to replicate that locking model
> >> in each filesystem that is supports DAX. I think this is a better
> >> direction because it moves towards solving a whole class of problems
> >> fileystem face with page fault serialisation, not just for DAX.
> > 
> > Well, but at least in XFS you take XFS_MMAPLOCK in shared mode for the
> > fault / page_mkwrite callback so it doesn't provide the exclusion necessary
> > for DAX which needs exclusive access to the page given range in the page
> > cache. And replacing i_mmap_lock with fs-private mmap rwsem is a moot
> > excercise (at least from DAX POV).
> > 
> 
> Hi Jan. So you got me confused above. You say:
> 	"DAX which needs exclusive access to the page given range in the page cache"
> 
> but DAX and page-cache are mutually exclusive. I guess you meant the VMA
> range, or the inode->mapping range (which one is it)

The second -- pgoff range within the inode->mapping.

> Actually I do not understand this race you guys found at all. (Please bear with
> me sorry for being slow)
> 
> If two threads of the same VMA fault on the same pte
> (I'm not sure how you call it I mean a single 4k entry at each VMAs page-table)
> then the mm knows how to handle this just fine.

It does. But only if we have struct page. See lock_page_or_retry() in
filemap_fault(). Without lock_page() it's problematic.

> If two processes, ie two VMAs fault on the same inode->mapping. Then an inode
> wide lock like XFS's to protect against i_size-change / truncate is more than
> enough.

We also used lock_page() to make sure we shoot out all pages as we don't
exclude page faults during truncate. Consider this race:

	<fault>			<truncate>
	get_block
	check i_size
    				update i_size
				unmap
	setup pte

With normal page cache we make sure that all pages beyond i_size is
dropped using lock_page() in truncate_inode_pages_range().

For DAX we need a way to stop all page faults to the pgoff range before
doing unmap.

> Because with DAX there is no inode->mapping "mapping" at all. You have the call
> into the FS with get_block() to replace "holes" (zero pages) with real allocated
> blocks, on WRITE faults, but this conversion should be protected inside the FS
> already. Then there is the atomic exchange of the PTE which is fine.
> (And vis versa with holes mapping and writes)

Having unmap_mapping_range() in PMD fault handling is very unfortunate.
Go to rmap just to solve page fault is very wrong.
BTW, we need to do it in write path too.

I'm not convinced that all these "let's avoid backing storage allocation"
in DAX code is not layering violation. I think the right place to solve
this is filesystem. And we have almost all required handles for this in
place.  We only need to change vm_ops->page_mkwrite() interface to be able
to return different page than what was given on input.

> > So regardless whether the lock will be a fs-private one or in
> > address_space, DAX needs something like the range lock Kirill suggested.
> > Having the range lock in fs-private part of inode has the advantage that
> > only filesystems supporting DAX / punch hole will pay the memory overhead.
> > OTOH most major filesystems need it so the savings would be IMO noticeable
> 
> punch-hole is truncate for me. With the xfs model of read-write lock where
> truncate takes write, any fault taking read before executing the fault looks
> good for the FS side of things. I guess you mean the optimization of the
> radix-tree lock. But you see DAX does not have a radix-tree, ie it is empty.

Hm. Where does XFS take this read-write lock in fault path?

IIUC, truncation vs. page fault serialization relies on i_size being
updated before doing truncate_pagecache() and checking i_size under
page_lock() on fault side. We don't have i_size fence for punch hole.

BTW, how things like ext4_collapse_range() can be safe wrt parallel page
fault? Ted? 

-- 
 Kirill A. Shutemov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
