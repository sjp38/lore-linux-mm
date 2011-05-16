Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id 6C46E6B0023
	for <linux-mm@kvack.org>; Mon, 16 May 2011 15:05:03 -0400 (EDT)
Received: from d03relay01.boulder.ibm.com (d03relay01.boulder.ibm.com [9.17.195.226])
	by e39.co.us.ibm.com (8.14.4/8.13.1) with ESMTP id p4GIp6Af025245
	for <linux-mm@kvack.org>; Mon, 16 May 2011 12:51:06 -0600
Received: from d03av04.boulder.ibm.com (d03av04.boulder.ibm.com [9.17.195.170])
	by d03relay01.boulder.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id p4GJ4TsK118964
	for <linux-mm@kvack.org>; Mon, 16 May 2011 13:04:31 -0600
Received: from d03av04.boulder.ibm.com (loopback [127.0.0.1])
	by d03av04.boulder.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id p4GD4S9v010250
	for <linux-mm@kvack.org>; Mon, 16 May 2011 07:04:28 -0600
Date: Mon, 16 May 2011 12:04:27 -0700
From: "Darrick J. Wong" <djwong@us.ibm.com>
Subject: Re: [PATCHSET v3.1 0/7] data integrity: Stabilize pages during
	writeback for various fses
Message-ID: <20110516190427.GN20579@tux1.beaverton.ibm.com>
Reply-To: djwong@us.ibm.com
References: <20110509230318.19566.66202.stgit@elm3c44.beaverton.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20110509230318.19566.66202.stgit@elm3c44.beaverton.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Theodore Tso <tytso@mit.edu>, Jan Kara <jack@suse.cz>, Alexander Viro <viro@zeniv.linux.org.uk>, OGAWA Hirofumi <hirofumi@mail.parknet.co.jp>
Cc: Jens Axboe <axboe@kernel.dk>, "Martin K. Petersen" <martin.petersen@oracle.com>, Jeff Layton <jlayton@redhat.com>, Dave Chinner <david@fromorbit.com>, linux-kernel <linux-kernel@vger.kernel.org>, Dave Hansen <dave@linux.vnet.ibm.com>, Christoph Hellwig <hch@infradead.org>, linux-mm@kvack.org, Chris Mason <chris.mason@oracle.com>, Joel Becker <jlbec@evilplan.org>, linux-scsi <linux-scsi@vger.kernel.org>, linux-fsdevel <linux-fsdevel@vger.kernel.org>, linux-ext4@vger.kernel.org, Mingming Cao <mcao@us.ibm.com>

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
> 
> To assess the performance impact of stable page writes, I moved to a disk that
> doesn't have DIF support so that I could measure just the impact of waiting for
> writeback.  I first ran wac with 64 threads madly scribbling on a 64k file and
> saw about a 12 percent performance decrease.  I then reran the wac program with
> 64 threads and a 64MB file and saw about the same performance numbers.  As I
> suspected, the patchset only seems to impact workloads that rewrite the same
> memory page frequently.
> 
> I am still chasing down what exactly is broken in ext3.  data=writeback mode
> passes with no failures.  data=ordered, however, does not pass; my current
> suspicion is that jbd is calling submit_bh on data buffers but doesn't call
> page_mkclean to kick the userspace programs off the page before writing it.
> 
> Per various comments regarding v3 of this patchset, I've integrated his
> suggestions, reworked the patch descriptions to make it clearer which ones
> touch all the filesystems and which ones are to fix remaining holes in specific
> filesystems, and expanded the scope of filesystems that got fixed.
> 
> As always, questions and comments are welcome; and thank you to all the
> previous reviewers of this patchset.  I am also soliciting people's opinions on
> whether or not these patches could go upstream for .40.

[adding Andrew Morton to cc]

Ted, Mingming, and I were discussing how we might get this patchset pushed
upstream on today's ext4 community call.  The ext2 patch can be dropped since
it really only was there as a proof that the generic mm/fs fixes actually
worked.  I'm unsure of the vfat maintainer's feelings on the patchset, though
he seems concerned about the performance of apps that rewrite pages frequently.
Ted seemed agreeable with the ext4 changes, though I don't know if he's
reviewed them thoroughly yet.

Ted asked for clarification as to which patches are needed to fix ext4.
Patches 1 and 5 are the two that are required for ext4, and patch 4 cleans up
some ext4 code.

Patches 1 and 2 are needed to fix xfs and nilfs.

Patches 1 and 3 (and fs-specific patches such as 6 & 7) are needed to fix the
rest.

Unfortunately, Ted and I weren't sure who (if anyone) is in charge of pushing
mm and generic fs patches upstream.  Ted suggested Andrew Morton for the mm
patches (1 & 3) and we weren't sure if Al Viro or Christoph (or someone else)
is in charge of generic vfs patches (patch #2).

So, who do I actually ask to take the mm and vfs patches?  Andrew, can I send
you patches?

--D

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
