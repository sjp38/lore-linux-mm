Received: from Tandem.com (suntan.tandem.com [192.216.221.8])
	by kvack.org (8.8.7/8.8.7) with ESMTP id HAA01641
	for <linux-mm@kvack.org>; Thu, 26 Mar 1998 07:33:43 -0500
Date: Thu, 26 Mar 1998 18:04:23 +0530 (GMT+0530)
From: Chirayu Patel <chirayu@wipro.tcpn.com>
Subject: shrink_mmap ()?
Message-Id: <Pine.SUN.3.95.980326175034.17975N-100000@Kabini>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: linux-mm@kvack.org, linux-kernel@vger.rutgers.edu
List-ID: <linux-mm.kvack.org>


Hi,

I was going through the source for shrink_mmap.......

The attached code puzzled me..

We are freeing a page with count = 1 (referenced by one process only) but
we are not manipulating any page table entries. Why? Shouldnt we be
manipulating the page table entries or where are the page table entries
getting manipulated?

I know I have missed something terribly obvious over here. Can someone
please help me out. 

Thanks.

-- Chirayu

-----------------------------------------------------------------------
switch (atomic_read(&page->count)) {
	case 1:
		/* is it a swap-cache or page-cache page? */
		if (page->inode) {
			if (test_and_clear_bit(PG_referenced,
                                               &page->flags)) {
				touch_page(page);
				break;
			}
			age_page(page);
			if (page->age)
				break;
			if (PageSwapCache(page)) {
				delete_from_swap_cache(page);
				return 1;
			}
			remove_page_from_hash_queue(page);
			remove_page_from_inode_queue(page);
			__free_page(page);
			return 1;
		}
------------------------------------------------------------------------------
