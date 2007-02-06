Received: from d01relay02.pok.ibm.com (d01relay02.pok.ibm.com [9.56.227.234])
	by e1.ny.us.ibm.com (8.13.8/8.13.8) with ESMTP id l160PL83011337
	for <linux-mm@kvack.org>; Mon, 5 Feb 2007 19:25:21 -0500
Received: from d01av01.pok.ibm.com (d01av01.pok.ibm.com [9.56.224.215])
	by d01relay02.pok.ibm.com (8.13.8/8.13.8/NCO v8.2) with ESMTP id l160PLEu266996
	for <linux-mm@kvack.org>; Mon, 5 Feb 2007 19:25:21 -0500
Received: from d01av01.pok.ibm.com (loopback [127.0.0.1])
	by d01av01.pok.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id l160PLgR024121
	for <linux-mm@kvack.org>; Mon, 5 Feb 2007 19:25:21 -0500
Date: Mon, 5 Feb 2007 16:25:34 -0800
From: Nishanth Aravamudan <nacc@us.ibm.com>
Subject: Re: Hugepages_Rsvd goes huge in 2.6.20-rc7
Message-ID: <20070206002534.GQ7953@us.ibm.com>
References: <20070206001903.GP7953@us.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20070206001903.GP7953@us.ibm.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
Cc: libhugetlbfs-devel@lists.sourceforge.net, david@gibson.dropbear.id.au, hugh@veritas.com
List-ID: <linux-mm.kvack.org>

Sorry, I botched Hugh's e-mail address, please make sure to reply to the
correct one.

Thanks,
Nish

On 05.02.2007 [16:19:04 -0800], Nishanth Aravamudan wrote:
> Hi all,
> 
> So, here's the current state of the hugepages portion of my
> /proc/meminfo (x86_64, 2.6.20-rc7, will test with 2.6.20 shortly, but
> AFAICS, there haven't been many changes to hugepage code between the
> two):
> 
> HugePages_Total:   100
> HugePages_Free:    100
> HugePages_Rsvd:  18446744073709551615
> Hugepagesize:     2048 kB
> 
> That's not good :)
> 
> Context: I'm currently working on some patches for libhugetlbfs which
> should ultimately help us reduce our hugepage usage when remapping
> segments so they are backed by hugepages. The current algorithm maps in
> hugepage file as MAP_SHARED, copies over the segment data, then unmaps
> the file. It then unmaps the program's segments, and maps in the same
> hugepage file MAP_PRIVATE, so that we take COW faults. Now, the problem
> is, for writable segments (data) the COW fault instatiates a new
> hugepage, but the original MAP_SHARED hugepage stays resident in the
> page cache. So, for a program that could survive (after the initial
> remapping algorithm) with only 2 hugepages in use, uses 3 hugepages
> instead.
> 
> To work around this, I've modified the algorithm to prefault in the
> writable segment in the remapping code (via a one-byte read and write).
> Then, I issue a posix_fadvise(segment_fd, 0, 0, FADV_DONTNEED), to try
> and drop the shared hugepage from the page cache. With a small dummy
> relinked app (that just sleeps), this does reduce our run-time hugepage
> cost from 3 to 2. But, I'm noticing that libhugetlbfs' `make func`
> utility, which tests libhugetlbfs' functionality only, every so often
> leads to a lot of "VM killing process ...". This only appears to happen
> to a particular testcase (xBDT.linkshare, which remaps the BSS, data and
> text segments and tries to share the text segments between 2 processes),
> but when it does, it happens for a while (that is, if I try and run that
> particular test manually, it keeps getting killed) and /proc/meminfo
> reports a garbage value for HugePages_Rsvd like I listed above. If I
> rerun `make func`, sometimes the problem goes away (Rsvd returns to a
> sane value, as well...).
> 
> I've added Hugh & David to the Cc, because they discussed a similar
> problem a few months back. Maybe there is still a race somewhere?
> 
> I'm willing to test any possible fixes, and I'll work on making this
> more easily reproducible (although it seems to happen pretty regularly
> here) with a simpler test.
> 
> Thanks,
> Nish
> 
> -- 
> Nishanth Aravamudan <nacc@us.ibm.com>
> IBM Linux Technology Center

-- 
Nishanth Aravamudan <nacc@us.ibm.com>
IBM Linux Technology Center

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
