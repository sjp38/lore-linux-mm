Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx162.postini.com [74.125.245.162])
	by kanga.kvack.org (Postfix) with SMTP id E936C6B004A
	for <linux-mm@kvack.org>; Thu,  5 Apr 2012 12:32:29 -0400 (EDT)
MIME-version: 1.0
Content-transfer-encoding: 7BIT
Content-type: TEXT/PLAIN
Received: from euspt2 ([210.118.77.13]) by mailout3.w1.samsung.com
 (Sun Java(tm) System Messaging Server 6.3-8.04 (built Jul 29 2009; 32bit))
 with ESMTP id <0M2000NP9LXN0J80@mailout3.w1.samsung.com> for
 linux-mm@kvack.org; Thu, 05 Apr 2012 17:32:11 +0100 (BST)
Received: from linux.samsung.com ([106.116.38.10])
 by spt2.w1.samsung.com (iPlanet Messaging Server 5.2 Patch 2 (built Jul 14
 2004)) with ESMTPA id <0M2000MD7LY1VB@spt2.w1.samsung.com> for
 linux-mm@kvack.org; Thu, 05 Apr 2012 17:32:25 +0100 (BST)
Date: Thu, 05 Apr 2012 18:32:11 +0200
From: Bartlomiej Zolnierkiewicz <b.zolnierkie@samsung.com>
Subject: [PATCH 0/2] mm: compaction: improve free pages selection
Message-id: <1333643534-1591-1-git-send-email-b.zolnierkie@samsung.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: mgorman@suse.de, Bartlomiej Zolnierkiewicz <b.zolnierkie@samsung.com>

These patches lift some limitations on free pages selection so there
is a much higher chance of memory migration succeeding in case of heavy
memory fragmentation.

[ From looking at the compaction free pages selection code I'm under
  the impression that the noticed limitations exist because the code
  was originally designed to mainly deal with hugepages? ]


My test case on a ARM EXYNOS4 device with 512 MiB (to be exact:
131072 standard 4KiB pages in 'Normal' zone) is to:
- allocate 120000 pages for kernel's usage
- free every second page (60000 pages) of memory just allocated
- allocate and use 60000 pages from user space
- free remaining 60000 pages of kernel memory
(now we have fragmented memory occupied mostly by user space pages)
- try to allocate 100 order-9 (2048 KiB) pages for kernel's usage

The results:
- with compaction disabled I get 11 successful allocations
- with compaction enabled - 14 successful allocations
- with patch #1 - 34 successful allocations
- with patches #1+2 all 100 allocations succeed


On the cons side of the changes is the increased CPU usage spent on
finding suitable free pages.  However once we try memory compaction to
help us to allocate higher order pages we are already in the slow-path
and it is better to spent some extra cycles than to fail the allocation
completely.

Best regards,
--
Bartlomiej Zolnierkiewicz
Samsung Poland R&D Center


Bartlomiej Zolnierkiewicz (2):
  mm: compaction: try harder to isolate free pages
  mm: compaction: allow isolation of lower order buddy pages

 mm/compaction.c |    9 ++++-----
 1 file changed, 4 insertions(+), 5 deletions(-)

-- 
1.7.9.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
