Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta8.messagelabs.com (mail6.bemta8.messagelabs.com [216.82.243.55])
	by kanga.kvack.org (Postfix) with ESMTP id 10CE06B0011
	for <linux-mm@kvack.org>; Thu, 19 May 2011 18:48:46 -0400 (EDT)
Received: from d01relay05.pok.ibm.com (d01relay05.pok.ibm.com [9.56.227.237])
	by e8.ny.us.ibm.com (8.14.4/8.13.1) with ESMTP id p4JMMEMg026375
	for <linux-mm@kvack.org>; Thu, 19 May 2011 18:22:14 -0400
Received: from d01av04.pok.ibm.com (d01av04.pok.ibm.com [9.56.224.64])
	by d01relay05.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id p4JMmiXg111084
	for <linux-mm@kvack.org>; Thu, 19 May 2011 18:48:44 -0400
Received: from d01av04.pok.ibm.com (loopback [127.0.0.1])
	by d01av04.pok.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id p4JMmiBl025488
	for <linux-mm@kvack.org>; Thu, 19 May 2011 18:48:44 -0400
Subject: [PATCHSET v3.2 0/3] data integrity: Stabilize pages during writeback
	for various fses
From: "Darrick J. Wong" <djwong@us.ibm.com>
Date: Thu, 19 May 2011 15:48:41 -0700
Message-ID: <20110519224841.28755.80650.stgit@elm3c44.beaverton.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Alexander Viro <viro@zeniv.linux.org.uk>, "Darrick J. Wong" <djwong@us.ibm.com>
Cc: Jens Axboe <axboe@kernel.dk>, Theodore Tso <tytso@mit.edu>, "Martin K. Petersen" <martin.petersen@oracle.com>, Jeff Layton <jlayton@redhat.com>, Dave Chinner <david@fromorbit.com>, linux-kernel <linux-kernel@vger.kernel.org>, Dave Hansen <dave@linux.vnet.ibm.com>, Christoph Hellwig <hch@infradead.org>, linux-mm@kvack.org, Chris Mason <chris.mason@oracle.com>, Joel Becker <jlbec@evilplan.org>, linux-scsi <linux-scsi@vger.kernel.org>, linux-fsdevel <linux-fsdevel@vger.kernel.org>, Jan Kara <jack@suse.cz>, linux-ext4@vger.kernel.org, Mingming Cao <mcao@us.ibm.com>

Hi all,

This is v3.2 of the stable-page-writes patchset for ext4 and xfs.  The purpose
of this patchset is to prohibit processes from writing on memory pages that are
currently being written to disk because certain storage setups (e.g. SCSI disks
with DIF integrity checksums) will fail a write if the page contents don't
match the checksum.  btrfs already guarantees page stability, so it does not
use these changes.

The technique used is fairly simple -- whenever a page is about to become
writable (either because of a write fault to a mapped page, or a buffered write
is in progress), wait for the page writeback flag to be clear, indicating that
the page is not being written to disk.  This means that it is necessary (1) to
add wait for writeback code to grab_cache_page_write_begin to take care of
buffered writes, and (2) all filesystems must have a page_mkwrite that locks a
page, waits for writeback, and returns the locked page.  For filesystems that
piggyback on the generic block_page_mkwrite, the patchset adds the writeback
wait to that function; for filesystems that do not use the page_mkwrite hook at
all, the patchset provides a stub page_mkwrite.

I ran my write-after-checksum ("wac") reproducer program to try to create the
DIF checksum errors by madly rewriting the same memory pages.  In fact, I tried
the following combinations against ext4, xfs, and btrfs:

a. 64 write() threads + sync_file_range
b. 64 mmap write threads + msync
c. 32 write() threads + sync_file_range + 32 mmap write threads + msync
d. Same as C, but with all threads in directio mode
e. Same as A, but with all threads in directio mode
f. Same as B, but with all threads in directio mode

After running profiles A-F for 30 minutes each on 6 different machines, ext4
and xfs report no errors.   btrfs eventually reports -ENOSPC and fails the
test, though it does that even without any of the patches applied.

To assess the performance impact of stable page writes, I moved to a disk that
doesn't have DIF support so that I could measure just the impact of waiting for
writeback.  I first ran wac with 64 threads madly scribbling on a 64k file and
saw about a 12 percent performance decrease.  I then reran the wac program with
64 threads and a 64MB file and saw about the same performance numbers.  As I
suspected, the patchset only seems to impact workloads that rewrite the same
memory page frequently.

Per various comments regarding v3 of this patchset, I've integrated his
suggestions, reworked the patch descriptions to make it clearer which ones
touch all the filesystems and which ones are to fix remaining holes in specific
filesystems, and expanded the scope of filesystems that got fixed.

As always, questions and comments are welcome; and thank you to all the
previous reviewers of this patchset.  I am also soliciting people's opinions on
whether or not these patches could go upstream for .40.

This latest iteration of the patchset focuses solely on the generic changes
necessary to provide stable pages.  It is being sent to Al Viro (just like v3.1
was).

--D

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
