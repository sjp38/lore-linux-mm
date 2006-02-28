Received: from msilexch01.marvell.com (msilexch01.il.marvell.com [10.4.5.104])
	by il.marvell.com (8.13.1/8.13.1) with ESMTP id k1SGI61C013085
	for <linux-mm@kvack.org>; Tue, 28 Feb 2006 18:18:11 +0200 (IST)
Content-class: urn:content-classes:message
MIME-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Subject: using DMA acceleration in copy_from/to_user
Date: Tue, 28 Feb 2006 18:18:06 +0200
Message-ID: <B9FFC3F97441D04093A504CEA31B7C41881113@msilexch01.marvell.com>
From: "Saeed Bishara" <saeed@marvell.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
Cc: Saeed Bishara <saeed@marvell.com>
List-ID: <linux-mm.kvack.org>

Hi,
	I trying to improve performance by using DMA engine in
copy_to/from_user functions. My first implementation was based on the
xscale linux project from
http://sourceforge.net/project/showfiles.php?group_id=115074.

Using the DMA really improved the performance, but I think that this
code is buggy since it doesn't ensure that user pages will be pinned
before activating the DMA.

So I tried to use the get_user_pages function for that purpose. But
unfortunately, the performance decreased even less that the original
code (no DMA). I noticed that this function calls flush_dcache_page()
which adds a lot of delay, I created new version of get_user_pages (
called get_user_pages_no_flush) that doesn't call flush_dcache_page; My
copy_from/to_user makes sure to flush the from pointer and to invalidate
the to pointer. The performance improved significantly with the last
change.

However I still have some open questions:
1. Is there any implementation for DMA acceleration other than the
mentioned above project?
2. In some cases the copy_from_user get user address that belongs to
kernel space. Does that make sense?



Saeed Bishara

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
