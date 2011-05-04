Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id 7588A6B0011
	for <linux-mm@kvack.org>; Wed,  4 May 2011 13:37:10 -0400 (EDT)
Received: from d01relay03.pok.ibm.com (d01relay03.pok.ibm.com [9.56.227.235])
	by e1.ny.us.ibm.com (8.14.4/8.13.1) with ESMTP id p44HQAHk011032
	for <linux-mm@kvack.org>; Wed, 4 May 2011 13:26:10 -0400
Received: from d01av02.pok.ibm.com (d01av02.pok.ibm.com [9.56.224.216])
	by d01relay03.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id p44Hb6uL097468
	for <linux-mm@kvack.org>; Wed, 4 May 2011 13:37:06 -0400
Received: from d01av02.pok.ibm.com (loopback [127.0.0.1])
	by d01av02.pok.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id p44Hb5om031668
	for <linux-mm@kvack.org>; Wed, 4 May 2011 14:37:06 -0300
Date: Wed, 4 May 2011 10:37:04 -0700
From: "Darrick J. Wong" <djwong@us.ibm.com>
Subject: [PATCH v3 0/3] data integrity: Stabilize pages during writeback
	for ext4
Message-ID: <20110504173704.GE20579@tux1.beaverton.ibm.com>
Reply-To: djwong@us.ibm.com
References: <20110321164305.GC7153@quack.suse.cz> <20110406232938.GF1110@tux1.beaverton.ibm.com> <20110407165700.GB7363@quack.suse.cz> <20110408203135.GH1110@tux1.beaverton.ibm.com> <20110411124229.47bc28f6@corrin.poochiereds.net> <1302543595-sup-4352@think> <1302569212.2580.13.camel@mingming-laptop> <20110412005719.GA23077@infradead.org> <1302742128.2586.274.camel@mingming-laptop> <20110422000226.GA22189@tux1.beaverton.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20110422000226.GA22189@tux1.beaverton.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Theodore Ts'o <tytso@mit.edu>
Cc: Christoph Hellwig <hch@infradead.org>, Chris Mason <chris.mason@oracle.com>, Jeff Layton <jlayton@redhat.com>, Jan Kara <jack@suse.cz>, Dave Chinner <david@fromorbit.com>, Joel Becker <jlbec@evilplan.org>, "Martin K. Petersen" <martin.petersen@oracle.com>, Jens Axboe <axboe@kernel.dk>, linux-kernel <linux-kernel@vger.kernel.org>, linux-fsdevel <linux-fsdevel@vger.kernel.org>, Mingming Cao <mcao@us.ibm.com>, linux-scsi <linux-scsi@vger.kernel.org>, Dave Hansen <dave@linux.vnet.ibm.com>, linux-mm@kvack.org

Hi all,

This is v3 of the stable-page-writes patchset for ext4.  A lot of code has been
cut out since v2 of this patch set.  For v3, the large hairy function to walk
the page tables of every process is gone since Chris Mason pointed out that
page_mkclean does what I need.  The set_memory_* hack is also gone, since (I
think) the only time the kernel maps a file data blocks for writing is in the
buffered IO case.  That leaves us with some surgery to ext4_page_mkwrite to
return locked pages and to be careful about re-checking the writeback status
after dropping and re-grabbing the page lock; and a slight modification to the
mm code to wait for page writeback when grabbing pages for buffered writes.
There are also some cleanups for wait_on_page_writeback use in ext4.

I ran my write-after-checksum ("wac") reproducer program to try to create the
DIF checksum errors by madly rewriting the same memory pages.  In fact, I tried
the following combinations:

a. 64 write() threads + sync_file_range
b. 64 mmap write threads + msync
c. 32 write() threads + sync_file_range + 32 mmap write threads + msync
d. Same as C, but with all threads in directio mode
e. Same as A, but with all threads in directio mode
f. Same as B, but with all threads in directio mode

After some 44 hours of safety testing across 4 machines, I saw zero errors.
Before the patchset, I could run any of A-F for 10 seconds or less and have a
screen full of errors.

To assess the performance impact of stable page writes, I moved to a disk that
doesn't have DIF support so that I could measure just the impact of waiting for
writeback.  I first ran wac with 64 threads madly scribbling on a 64k file and
saw about a 12% performance decrease.  I then reran the wac program with 64
threads and a 64MB file and saw about the same performance numbers.  I will of
course be testing a wider range of hardware now that I have a functioning patch
set, though as I suspected the patchset only seems to impact workloads that
rewrite the same memory page frequently.

As always, questions and comments are welcome; and thank you to all the
previous reviewers of this patchset!

--D

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
