Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id 345EC6B004F
	for <linux-mm@kvack.org>; Thu,  2 Jul 2009 17:22:28 -0400 (EDT)
Message-ID: <4A4D26C5.9070606@redhat.com>
Date: Thu, 02 Jul 2009 16:29:41 -0500
From: Eric Sandeen <sandeen@redhat.com>
MIME-Version: 1.0
Subject: [PATCH] bump up nr_to_write in xfs_vm_writepage
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: xfs mailing list <xfs@oss.sgi.com>
Cc: linux-mm@kvack.org, Christoph Hellwig <hch@infradead.org>, "MASON,CHRISTOPHER" <CHRIS.MASON@oracle.com>
List-ID: <linux-mm.kvack.org>

Talking w/ someone who had a raid6 of 15 drives on an areca
controller, he wondered why he could only get 300MB/s or so
out of a streaming buffered write to xfs like so:

dd if=/dev/zero of=/mnt/storage/10gbfile bs=128k count=81920
10737418240 bytes (11 GB) copied, 34.294 s, 313 MB/s

when the same write directly to the device was going closer
to 700MB/s...

With the following change things get moving again for xfs:

dd if=/dev/zero of=/mnt/storage/10gbfile bs=128k count=81920
10737418240 bytes (11 GB) copied, 16.2938 s, 659 MB/s

Chris had sent out something similar at Christoph's suggestion,
and Christoph reminded me of it, and I tested it a variant of
it, and it seems to help shockingly well.

Feels like a bandaid though; thoughts?  Other tests to do?

Thanks,
-Eric

Signed-off-by: Christoph Hellwig <hch@infradead.org>
Signed-off-by: Eric Sandeen <sandeen@sandeen.net>
Cc: Chris Mason <chris.mason@oracle.com>
---

Index: linux-2.6/fs/xfs/linux-2.6/xfs_aops.c
===================================================================
--- linux-2.6.orig/fs/xfs/linux-2.6/xfs_aops.c
+++ linux-2.6/fs/xfs/linux-2.6/xfs_aops.c
@@ -1268,6 +1268,13 @@ xfs_vm_writepage(
 	if (!page_has_buffers(page))
 		create_empty_buffers(page, 1 << inode->i_blkbits, 0);
 
+
+	/*
+	 *  VM calculation for nr_to_write seems off.  Bump it way
+	 *  up, this gets simple streaming writes zippy again.
+	 */
+	wbc->nr_to_write *= 4;
+
 	/*
 	 * Convert delayed allocate, unwritten or unmapped space
 	 * to real space and flush out to disk.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
