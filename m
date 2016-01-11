Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lb0-f173.google.com (mail-lb0-f173.google.com [209.85.217.173])
	by kanga.kvack.org (Postfix) with ESMTP id 82E69828F3
	for <linux-mm@kvack.org>; Mon, 11 Jan 2016 07:23:13 -0500 (EST)
Received: by mail-lb0-f173.google.com with SMTP id cl12so35620039lbc.1
        for <linux-mm@kvack.org>; Mon, 11 Jan 2016 04:23:13 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id ok2si68900196lbb.144.2016.01.11.04.23.11
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Mon, 11 Jan 2016 04:23:11 -0800 (PST)
Date: Mon, 11 Jan 2016 13:23:20 +0100
From: Jan Kara <jack@suse.cz>
Subject: Re: [PATCH v7 2/9] dax: fix conversion of holes to PMDs
Message-ID: <20160111122320.GB6262@quack.suse.cz>
References: <1452103263-1592-1-git-send-email-ross.zwisler@linux.intel.com>
 <1452103263-1592-3-git-send-email-ross.zwisler@linux.intel.com>
 <20160107132206.GE8380@quack.suse.cz>
 <20160107221114.GA20802@linux.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20160107221114.GA20802@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ross Zwisler <ross.zwisler@linux.intel.com>
Cc: Jan Kara <jack@suse.cz>, linux-kernel@vger.kernel.org, "H. Peter Anvin" <hpa@zytor.com>, "J. Bruce Fields" <bfields@fieldses.org>, Theodore Ts'o <tytso@mit.edu>, Alexander Viro <viro@zeniv.linux.org.uk>, Andreas Dilger <adilger.kernel@dilger.ca>, Andrew Morton <akpm@linux-foundation.org>, Dan Williams <dan.j.williams@intel.com>, Dave Chinner <david@fromorbit.com>, Dave Hansen <dave.hansen@linux.intel.com>, Ingo Molnar <mingo@redhat.com>, Jan Kara <jack@suse.com>, Jeff Layton <jlayton@poochiereds.net>, Matthew Wilcox <matthew.r.wilcox@intel.com>, Matthew Wilcox <willy@linux.intel.com>, Thomas Gleixner <tglx@linutronix.de>, linux-ext4@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, linux-nvdimm@lists.01.org, x86@kernel.org, xfs@oss.sgi.com

On Thu 07-01-16 15:11:14, Ross Zwisler wrote:
> On Thu, Jan 07, 2016 at 02:22:06PM +0100, Jan Kara wrote:
> > On Wed 06-01-16 11:00:56, Ross Zwisler wrote:
> > > When we get a DAX PMD fault for a write it is possible that there could be
> > > some number of 4k zero pages already present for the same range that were
> > > inserted to service reads from a hole.  These 4k zero pages need to be
> > > unmapped from the VMAs and removed from the struct address_space radix tree
> > > before the real DAX PMD entry can be inserted.
> > > 
> > > For PTE faults this same use case also exists and is handled by a
> > > combination of unmap_mapping_range() to unmap the VMAs and
> > > delete_from_page_cache() to remove the page from the address_space radix
> > > tree.
> > > 
> > > For PMD faults we do have a call to unmap_mapping_range() (protected by a
> > > buffer_new() check), but nothing clears out the radix tree entry.  The
> > > buffer_new() check is also incorrect as the current ext4 and XFS filesystem
> > > code will never return a buffer_head with BH_New set, even when allocating
> > > new blocks over a hole.  Instead the filesystem will zero the blocks
> > > manually and return a buffer_head with only BH_Mapped set.
> > > 
> > > Fix this situation by removing the buffer_new() check and adding a call to
> > > truncate_inode_pages_range() to clear out the radix tree entries before we
> > > insert the DAX PMD.
> > 
> > Ho, hum, let me understand this. So we have a file, different processes are
> > mapping it. One process maps is with normal page granularity and another
> > process with huge page granularity. Thus when the first process read-faults
> > a few normal pages and then the second process write-faults the huge page
> > in the same range, we have a problem. Do I understand this correctly?
> > Because otherwise I don't understand how a single page table can have both
> > huge page and normal page in the same range...
> 
> I don't think that it necessarily has to do with multiple threads.  The bit to
> notice here is we *always* use 4k zero pages to cover holes.  So, a single
> thread can hit this condition by doing some reads from a hole (insert 4k
> pages), then doing a write.  This write is the first time that we will try and
> use real DAX storage to insert into the page tables, and we may end up getting
> a PMD.  This means that we need to clear out all the 4k pages that we inserted
> while reading holes in this same range, now that we have a 2M segment
> allocated by the filesystem and the entire range is no longer a hole.

OK, I see. Thanks for explanation.

> > And if this is indeed the problem then what prevents the unmapping and
> > truncation in huge page fault to race with mapping the same range again
> > using small pages? Sure now blocks are allocated so the mapping itself will
> > be consistent but radix tree will have the same issues it had before this
> > patch, won't it?
> 
> Yep, this is a separate issue, but I think that we handle this case
> successfully, though we may end up flushing the same address multiple times.
> Once the filesystem has established a block mapping (assuming we avoid the
> race described below where one thread is mapping in holes and the other sees a
> block allocation), I think we are okay.  It's true that one thread can map in
> PMDs, and another thread could potentially map in PTEs that cover the same
> range if they hare working with mmaps that are smaller than a PMD, but the
> sectors inserted into the radix tree by each of those threads will be
> individually correct - the only issue is that they may overlap.
> 
> Say, for example you have the following:
> 
> CPU1 - process 1				CPU2 - process 2
> mmap for sector 0, size 2M
> insert PMD into radix tree for sector 0
>   This radix tree covers sectors 0-4096
> 						mmap for sector 32, size 4k
> 						insert PTE entry into radix
> 						tree for sector 32
> 
> In this case a fsync of the fd by process 1 will end up flushing sector 32
> twice, which is correct but inefficient.  I think we can make this more
> efficient by adjusting the insertion code and dirtying code in
> dax_radix_entry() to look for PMDs that cover this same range.

Yes, this is what I ended up with as well. So we are in agreement here.

> > ... thinking some more about this ...
> > 
> > OK, there is some difference - we will only have DAX exceptional entries
> > for the range covered by huge page and those we replace properly in
> > dax_radix_entry() code. So things are indeed fine *except* that nothing
> > seems so serialize dax_load() hole with PMD fault. The race like following
> > seems possible:
> > 
> > CPU1 - process 1		CPU2 - process 2
> > 
> > __dax_fault() - file f, index 1
> >   get_block() -> returns hole
> > 				__dax_pmd_fault() - file f, index 0
> > 				  get_block() -> allocates blocks
> > 				  ...
> > 				  truncate_pagecache_range()
> >   dax_load_hole()
> > 
> > Boom, we have hole page instantiated for allocated range (data corruption)
> > and corruption of radix tree entries as well. Actually this problem is
> > there even for two different processes doing normal page faults (one read,
> > one write) against the same page in the file.
> 
> Yea, I agree, this seems like an existing issue that you could hit with just
> the PTE path:
> 
> CPU1 - process 1		CPU2 - process 2
> 
> __dax_fault() - read file f, index 0
>   get_block() -> returns hole
> 				__dax_fault() - write file f, index 0
> 				  get_block() -> allocates blocks
> 				  ...
> 				  skips unmap_mapping_range() and
> 				    delete_from_page_cache() because it didn't
> 				    find a page for this pgoff
> 				  dax_insert_mapping()
>   dax_load_hole()
>   *data corruption*
> 
> > ... thinking about possible fixes ...
> > 
> > So we need some exclusion that makes sure pgoff->block mapping information
> > is uptodate at the moment we insert it into page tables. The simplest
> > reasonably fast thing I can see is:
> > 
> > When handling a read fault, things stay as is and filesystem protects the
> > fault with an equivalent of EXT4_I(inode)->i_mmap_sem held for reading. When
> > handling a write fault we first grab EXT4_I(inode)->i_mmap_sem for reading
> > and try a read fault. If __dax_fault() sees a hole returned from
> > get_blocks() during a write fault, it bails out. Filesystem grabs
> > EXT4_I(inode)->i_mmap_sem for writing and retries with different
> > get_blocks() callback which will allocate blocks. That way we get proper
> > exclusion for faults needing to allocate blocks. Thoughts?
> 
> I think this would work.  ext4, ext2 and xfs all handle their exclusion with
> rw_semaphores, so this should work for each of them, I think.  Thanks for the
> problem statement & solution!  :) 
> 
> I guess our best course is to make sure that we don't make this existing
> problem worse via the fsync/msync patches by handling the error gracefully,
> and fix this for v4.6.  I do feel the need to point out that this is a
> pre-existing issue with DAX, and that my fsync patches just happened to help
> us find it.  They don't make the situation any better or any worse, and I
> really hope this issue doesn't end up blocking the fsync/msync patches from
> getting merged for v4.5.

Yeah, I agree this is a preexisting problem and mostly independent of your
fsync series so it can be dealt with once fsync series lands. The only
thing where this meets is the locking - you will have exclusive hold of the
inode and all its mapping when doing a write fault allocating a block. That
may save you some dances with i_mmap_lock (but I didn't think about this
too much).

								Honza
-- 
Jan Kara <jack@suse.com>
SUSE Labs, CR

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
