Received: from chip by tytlal.su.valinux.com with local (Exim 3.12 #1 (Debian))
	id 12ztFM-0003X8-00
	for <linux-mm@kvack.org>; Wed, 07 Jun 2000 20:44:44 -0700
Date: Wed, 7 Jun 2000 20:44:44 -0700
From: Chip Salzenberg <chip@valinux.com>
Subject: raid0 and buffers larger than PAGE_SIZE
Message-ID: <20000607204444.A453@perlsupport.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

I'm using raid0 under 2.2.16pre4 and I've just started observing a new
failure mode that's completely preventing it from working: getblk(),
and therefore refill_freelist(), is being called with a size greater
than PAGE_SIZE.  This is triggered by e2fsck on the /dev/md0, and it's
probably been a while since the last e2fsck, so I don't know when the
was actually introduced.

I'm using an Intel CPU, so PAGE_SIZE is 4K, but getblk() is being
called with a size of 16K, which is (not coincidentally) my raid0
chunk size.  It ends up in an infinite loop, as getblk() calls
refill_freelist() forever until it succeeds, which it never does!

I'm not sure whether the bug is in raid0 (is setting a block device
block size greater than PAGE_SIZE legal?), refill_freelist (is
creating buffer heads that span multiple pages legal?), or something
else entirely....  Help?!

Clues, anyone?
-- 
Chip Salzenberg              - a.k.a. -              <chip@valinux.com>
"I wanted to play hopscotch with the impenetrable mystery of existence,
    but he stepped in a wormhole and had to go in early."  // MST3K
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
