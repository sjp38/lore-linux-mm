Received: from localhost (garlick@localhost)
	by spork.llnl.gov (8.9.3/8.9.3) with ESMTP id RAA06508
	for <linux-mm@kvack.org>; Wed, 20 Sep 2000 17:07:34 -0700
Date: Wed, 20 Sep 2000 17:07:32 -0700 (PDT)
From: Jim Garlick <garlick@llnl.gov>
Subject: 2.2.14 - pte's not cleared before fop->mmap?
Message-ID: <Pine.LNX.4.21.0009201700300.6478-100000@spork.llnl.gov>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hi,

I'm working on a driver (2.2.14 / alpha) which has an mmap facility.  
In my fop->mmap function, just prior to calling remap_page_range to 
actually perform the mapping, I scan the user virtual address space I'm 
about to map to look for pte's that are not clear.  Occasionally I find 
a range that has valid pte's in it, pointing to strange physical addresses:

verify_area_isclean: uaddr=20000800000 already mapped to paddr=0
verify_area_isclean: uaddr=20000802000 already mapped to paddr=1ffff1002000
verify_area_isclean: uaddr=20000804000 already mapped to paddr=0
verify_area_isclean: uaddr=20000806000 already mapped to paddr=1ffff1002000
verify_area_isclean: uaddr=20000808000 already mapped to paddr=0
verify_area_isclean: uaddr=2000080e000 already mapped to paddr=0
verify_area_isclean: uaddr=20000810000 already mapped to paddr=0
verify_area_isclean: uaddr=20000812000 already mapped to paddr=1002000
verify_area_isclean: uaddr=20000814000 already mapped to paddr=1002000
verify_area_isclean: uaddr=20000816000 already mapped to paddr=1002000
verify_area_isclean: uaddr=2000081e000 already mapped to paddr=1ffff0000000
verify_area_isclean: uaddr=20000820000 already mapped to paddr=1002000
verify_area_isclean: uaddr=20000822000 already mapped to paddr=6000
verify_area_isclean: uaddr=20000824000 already mapped to paddr=1ffff0000000
verify_area_isclean: uaddr=20000828000 already mapped to paddr=0
verify_area_isclean: uaddr=2000082a000 already mapped to paddr=6e77c000
verify_area_isclean: uaddr=2000082c000 already mapped to paddr=0
verify_area_isclean: uaddr=2000082e000 already mapped to paddr=0
verify_area_isclean: uaddr=20000830000 already mapped to paddr=1ffff0000000
...


I'm at a loss as to why this is the case.  It looks like do_mmap calls
do_munmap, which calls zap_page_range on the pte's just prior to calling
my fop->mmap function, so the range should be clear, right?

This only occurs occasionally.  Any thoughts would be appreciated.

Jim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
