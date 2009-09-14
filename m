Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id 0B1FD6B004D
	for <linux-mm@kvack.org>; Mon, 14 Sep 2009 01:11:12 -0400 (EDT)
Received: by yxe12 with SMTP id 12so3913569yxe.1
        for <linux-mm@kvack.org>; Sun, 13 Sep 2009 22:11:15 -0700 (PDT)
MIME-Version: 1.0
Date: Mon, 14 Sep 2009 17:11:15 +1200
Message-ID: <202cde0e0909132211q3766c7daq4349b97dd8864438@mail.gmail.com>
Subject: [PATCH 0/3]Huge pages mapping for device drivers. (Take 3)
From: Alexey Korolev <akorolex@gmail.com>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
To: Mel Gorman <mel@csn.ul.ie>, Eric Munson <linux-mm@mgebm.net>, Alexey Korolev <akorolev@infradead.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

Hi,

The patch set listed below provides device drivers with the ability to
map memory regions to user space using HTLB interfaces.

The patches are applicable over Eric's patches for ANON_HUGETLB.

Why do we need this feature for drivers?
Device drivers often need to map memory regions to a user-space to
allow efficient data handling in user mode. Involving hugetlb mapping
may bring a performance gain if the mapped regions are relatively
large. Our tests showed that it is possible to gain up to 10%
performance if hugetlb mapping is enabled. In my case involving
hugetlb starts to make sense if the buffer is greater than or equal to
the size of one huge page. Since typically, the device throughput
increases over time there are more and more reasons to remap large
regions using hugetlb.

For example hugetlb remapping could be important for performance of
data acquisition systems (logic analyzers, DSO), network monitoring
systems (packet capture), HD video capture/frame buffer and probably
other.

How it is implemented?

Implementation and approach is very close to what is already done in
ipc/shm.c. We create a file on hugetlbfs vfs mount point using
standard procedures. Then we associate hugetlbfs file mapping with the
file mapping we want to access. A helper returns the page at a given
offset within a hugetlbfs file for population before the page has been
faulted. Allocation process is fully based on standard htlb
procedures, so accounting is not touched.

The typical procedure for mapping of huge pages to userspace by drivers is:
1 Create file on vfs mount of hugetlbfs
2 Replace file mapping with the hugetlbfs file mapping
3 Get huge page for configuring DMA or for something else.
...................
4 Remove hugetlbfs file

A detailed description is given in the following messages.

This implementation is based on the idea of Mel Gorman.
The patches do not contain changes for having GFP alloc mask per
inode. I made patch, but changes are not very small and not so
critical for us. I can post it if someone ask.

Thanks,
Alexey

P/S: Sorry for delay in posting - was much busy with other tasks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
