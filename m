Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id C27F0280245
	for <linux-mm@kvack.org>; Wed,  1 Nov 2017 11:37:08 -0400 (EDT)
Received: by mail-pf0-f200.google.com with SMTP id v2so2515319pfa.10
        for <linux-mm@kvack.org>; Wed, 01 Nov 2017 08:37:08 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id a33si5729pli.294.2017.11.01.08.37.04
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 01 Nov 2017 08:37:04 -0700 (PDT)
From: Jan Kara <jack@suse.cz>
Subject: [PATCH 0/18 v6] dax, ext4, xfs: Synchronous page faults
Date: Wed,  1 Nov 2017 16:36:29 +0100
Message-Id: <20171101153648.30166-1-jack@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dan Williams <dan.j.williams@intel.com>
Cc: Ross Zwisler <ross.zwisler@linux.intel.com>, Christoph Hellwig <hch@infradead.org>, linux-fsdevel@vger.kernel.org, linux-nvdimm@lists.01.org, linux-mm@kvack.org, linux-api@vger.kernel.org, linux-ext4@vger.kernel.org, linux-xfs@vger.kernel.org, "Darrick J . Wong" <darrick.wong@oracle.com>, Jan Kara <jack@suse.cz>

Hello,

here is the sixth version of my patches to implement synchronous page faults
for DAX mappings to make flushing of DAX mappings possible from userspace so
that they can be flushed on finer than page granularity and also avoid the
overhead of a syscall.

I think we are ready to get this merged - I've talked to Dan and he said he
could take the patches through his tree. It would just be nice to get final
ack from Christoph for the first patch implementing MAP_VALIDATE and someone
from XFS folks to check patch 17 (make xfs_filemap_pfn_mkwrite use
__xfs_filemap_fault()).

---

We use a new mmap flag MAP_SYNC to indicate that page faults for the mapping
should be synchronous.  The guarantee provided by this flag is: While a block
is writeably mapped into page tables of this mapping, it is guaranteed to be
visible in the file at that offset also after a crash.

How I implement this is that ->iomap_begin() indicates by a flag that inode
block mapping metadata is unstable and may need flushing (use the same test as
whether fdatasync() has metadata to write). If yes, DAX fault handler refrains
from inserting / write-enabling the page table entry and returns special flag
VM_FAULT_NEEDDSYNC together with a PFN to map to the filesystem fault handler.
The handler then calls fdatasync() (vfs_fsync_range()) for the affected range
and after that calls DAX code to update the page table entry appropriately.

I did some basic performance testing on the patches over ramdisk - timed
latency of page faults when faulting 512 pages. I did several tests: with file
preallocated / with file empty, with background file copying going on / without
it, with / without MAP_SYNC (so that we get comparison).  The results are
(numbers are in microseconds):

File preallocated, no background load no MAP_SYNC:
min=9 avg=10 max=46
8 - 15 us: 508
16 - 31 us: 3
32 - 63 us: 1

File preallocated, no background load, MAP_SYNC:
min=9 avg=10 max=47
8 - 15 us: 508
16 - 31 us: 2
32 - 63 us: 2

File empty, no background load, no MAP_SYNC:
min=21 avg=22 max=70
16 - 31 us: 506
32 - 63 us: 5
64 - 127 us: 1

File empty, no background load, MAP_SYNC:
min=40 avg=124 max=242
32 - 63 us: 1
64 - 127 us: 333
128 - 255 us: 178

File empty, background load, no MAP_SYNC:
min=21 avg=23 max=67
16 - 31 us: 507
32 - 63 us: 4
64 - 127 us: 1

File empty, background load, MAP_SYNC:
min=94 avg=112 max=181
64 - 127 us: 489
128 - 255 us: 23

So here we can see the difference between MAP_SYNC vs non MAP_SYNC is about
100-200 us when we need to wait for transaction commit in this setup. 

Changes since v5:
* really updated the manpage
* improved comment describing IOMAP_F_DIRTY
* fixed XFS handling of VM_FAULT_NEEDSYNC in xfs_filemap_pfn_mkwrite()

Changes since v4:
* fixed couple of minor things in the manpage
* make legacy mmap flags always supported, remove them from mask declared
  to be supported by ext4 and xfs

Changes since v3:
* updated some changelogs
* folded fs support for VM_SYNC flag into patches implementing the
  functionality
* removed ->mmap_validate, use ->mmap_supported_flags instead
* added some Reviewed-by tags
* added manpage patch

Changes since v2:
* avoid unnecessary flushing of faulted page (Ross) - I've realized it makes no
  sense to remeasure my benchmark results (after actually doing that and seeing
  no difference, sigh) since I use ramdisk and not real PMEM HW and so flushes
  are ignored.
* handle nojournal mode of ext4
* other smaller cleanups & fixes (Ross)
* factor larger part of finishing of synchronous fault into a helper (Christoph)
* reorder pfnp argument of dax_iomap_fault() (Christoph)
* add XFS support from Christoph
* use proper MAP_SYNC support in mmap(2)
* rebased on top of 4.14-rc4

Changes since v1:
* switched to using mmap flag MAP_SYNC
* cleaned up fault handlers to avoid passing pfn in vmf->orig_pte
* switched to not touching page tables before we are ready to insert final
  entry as it was unnecessary and not really simplifying anything
* renamed fault flag to VM_FAULT_NEEDDSYNC
* other smaller fixes found by reviewers

								Honza

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
