Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with ESMTP id F2A8A6B004D
	for <linux-mm@kvack.org>; Mon, 17 Aug 2009 18:24:06 -0400 (EDT)
Date: Mon, 17 Aug 2009 23:24:09 +0100 (BST)
From: Alexey Korolev <akorolev@infradead.org>
Subject: [PATCH 0/3]HTLB mapping for drivers (take 2)
Message-ID: <alpine.LFD.2.00.0908172317470.32114@casper.infradead.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Mel Gorman <mel@csn.ul.ie>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

Hi,

The patch set listed below provides device drivers with the ability to
map memory regions to user space via HTLB interfaces.

Why we need it? 
Device drivers often need to map memory regions to user-space to allow
efficient data handling in user mode. Involving hugetlb mapping may
bring performance gain if mapped regions are relatively large. Our tests
showed that it is possible to gain up to 7% performance if hugetlb
mapping is enabled. In my case involving hugetlb starts to make sense if
buffer is more or equal to 4MB. Since typically, device throughput
increase over time there are more and more reasons to involve huge pages
to remap large regions.
For example hugetlb remapping could be important for performance of Data
acquisition systems (logic analyzers, DSO), Network monitoring systems
(packet capture), HD video capture/frame buffer  and probably other. 

How it is implemented?
Implementation and idea is very close to what is already done in
ipc/shm.c. 
We create file on hugetlbfs vfsmount point and populate file with pages
we want to mmap. Then we associate hugetlbfs file mapping with file
mapping we want to access. 

So typical procedure for mapping of huge pages to userspace by drivers
should be:
1 Allocate some huge pages
2 Create file on vfs mount of hugetlbfs
3 Add pages to page cache of mapping associated with hugetlbfs file 
4 Replace file's mapping with the hugetlbfs file mapping
..............
5 Remove pages from page cache
6 Remove hugetlbfs file
7 Free pages
(Please find example in following messages)

Detailed description is given in the following messages.
Thanks a lot to Mel Gorman who gave good advice and code prototype and
Stephen Donnelly for assistance in description composing.

Alexey

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
