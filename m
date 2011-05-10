Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id 7F93090010B
	for <linux-mm@kvack.org>; Mon,  9 May 2011 20:06:36 -0400 (EDT)
Date: Tue, 10 May 2011 10:06:25 +1000
From: Dave Chinner <david@fromorbit.com>
Subject: Re: [PATCHSET v3.1 0/7] data integrity: Stabilize pages during
 writeback for various fses
Message-ID: <20110510000625.GA19446@dastard>
References: <20110509230318.19566.66202.stgit@elm3c44.beaverton.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20110509230318.19566.66202.stgit@elm3c44.beaverton.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Darrick J. Wong" <djwong@us.ibm.com>
Cc: Theodore Tso <tytso@mit.edu>, Jan Kara <jack@suse.cz>, Alexander Viro <viro@zeniv.linux.org.uk>, OGAWA Hirofumi <hirofumi@mail.parknet.co.jp>, Jens Axboe <axboe@kernel.dk>, "Martin K. Petersen" <martin.petersen@oracle.com>, Jeff Layton <jlayton@redhat.com>, linux-kernel <linux-kernel@vger.kernel.org>, Dave Hansen <dave@linux.vnet.ibm.com>, Christoph Hellwig <hch@infradead.org>, linux-mm@kvack.org, Chris Mason <chris.mason@oracle.com>, Joel Becker <jlbec@evilplan.org>, linux-scsi <linux-scsi@vger.kernel.org>, linux-fsdevel <linux-fsdevel@vger.kernel.org>, linux-ext4@vger.kernel.org, Mingming Cao <mcao@us.ibm.com>

On Mon, May 09, 2011 at 04:03:18PM -0700, Darrick J. Wong wrote:
> Hi all,
> 
> This is v3.1 of the stable-page-writes patchset for ext4/3/2, xfs, and fat.
> The purpose of this patchset is to prohibit processes from writing on memory
> pages that are currently being written to disk because certain storage setups
> (e.g. SCSI disks with DIF integrity checksums) will fail a write if the page
> contents don't match the checksum.  btrfs already guarantees page stability, so
> it does not use these changes.
> 
> The technique used is fairly simple -- whenever a page is about to become
> writable (either because of a write fault to a mapped page, or a buffered write
> is in progress), wait for the page writeback flag to be clear, indicating that
> the page is not being written to disk.  This means that it is necessary (1) to
> add wait for writeback code to grab_cache_page_write_begin to take care of
> buffered writes, and (2) all filesystems must have a page_mkwrite that locks a
> page, waits for writeback, and returns the locked page.  For filesystems that
> piggyback on the generic block_page_mkwrite, the patchset adds the writeback
> wait to that function; for filesystems that do not use the page_mkwrite hook at
> all, the patchset provides a stub page_mkwrite.
> 
> I ran my write-after-checksum ("wac") reproducer program to try to create the
> DIF checksum errors by madly rewriting the same memory pages.  In fact, I tried
> the following combinations against ext2/3/4, xfs, btrfs, and vfat:
> 
> a. 64 write() threads + sync_file_range
> b. 64 mmap write threads + msync
> c. 32 write() threads + sync_file_range + 32 mmap write threads + msync
> d. Same as C, but with all threads in directio mode
> e. Same as A, but with all threads in directio mode
> f. Same as B, but with all threads in directio mode
> 
> After running profiles A-F for 30 minutes each on 6 different machines, ext2,
> ext4, xfs, and vfat reported no errors.  ext3 still has a lingering failure
> case (which I will touch on briefly later) and btrfs eventually reports -ENOSPC
> and fails the test, though it does that even without any of the patches applied.

Can you turn this into an new test for xfstests? That was the test
is published and can be run by anyone and (hopefully) prevent
regressions from being introduced...

Cheers,

Dave.

-- 
Dave Chinner
david@fromorbit.com

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
