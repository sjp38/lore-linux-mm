Received: from d01relay04.pok.ibm.com (d01relay04.pok.ibm.com [9.56.227.236])
	by e2.ny.us.ibm.com (8.13.8/8.13.8) with ESMTP id m8MFtvNG021744
	for <linux-mm@kvack.org>; Mon, 22 Sep 2008 11:55:57 -0400
Received: from d01av02.pok.ibm.com (d01av02.pok.ibm.com [9.56.224.216])
	by d01relay04.pok.ibm.com (8.13.8/8.13.8/NCO v9.1) with ESMTP id m8MFtv26218586
	for <linux-mm@kvack.org>; Mon, 22 Sep 2008 11:55:57 -0400
Received: from d01av02.pok.ibm.com (loopback [127.0.0.1])
	by d01av02.pok.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id m8MFtu95032689
	for <linux-mm@kvack.org>; Mon, 22 Sep 2008 11:55:56 -0400
Subject: Re: [PATCH 1/2] Report the pagesize backing a VMA in
	/proc/pid/smaps
From: Dave Hansen <dave@linux.vnet.ibm.com>
In-Reply-To: <1222047492-27622-2-git-send-email-mel@csn.ul.ie>
References: <1222047492-27622-1-git-send-email-mel@csn.ul.ie>
	 <1222047492-27622-2-git-send-email-mel@csn.ul.ie>
Content-Type: text/plain
Date: Mon, 22 Sep 2008 08:55:55 -0700
Message-Id: <1222098955.8533.50.camel@nimitz>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Mel Gorman <mel@csn.ul.ie>
Cc: LKML <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Mon, 2008-09-22 at 02:38 +0100, Mel Gorman wrote:
> It is useful to verify that a hugepage-aware application is using the expected
> pagesizes in each of its memory regions. This patch reports the pagesize
> backing the VMA in /proc/pid/smaps. This should not break any sensible
> parser as the file format is multi-line and it should skip information it
> does not recognise.

Time to play devil's advocate. :)

To be fair, this doesn't return the MMU pagesize backing the VMA.  It
returns pagesize that hugetlb reports *or* the kernel's base PAGE_SIZE.

The ppc64 case where we have a 64k PAGE_SIZE, but no hardware 64k
support means that we'll have a 4k MMU pagesize that we're pretending is
a 64k MMU page.  That might confuse someone seeing 16x the number of TLB
misses they expect.

This also doesn't work if, in the future, we get multiple page sizes
mapped under one VMA.  But, I guess that all only matters if you worry
about how the kernel is treating the pages vs. the MMU hardware.

-- Dave

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
