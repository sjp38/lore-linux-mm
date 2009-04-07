Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id 4C8445F0001
	for <linux-mm@kvack.org>; Tue,  7 Apr 2009 02:37:29 -0400 (EDT)
Received: from d23relay02.au.ibm.com (d23relay02.au.ibm.com [202.81.31.244])
	by e23smtp04.au.ibm.com (8.13.1/8.13.1) with ESMTP id n376ZtgE001487
	for <linux-mm@kvack.org>; Tue, 7 Apr 2009 16:35:55 +1000
Received: from d23av04.au.ibm.com (d23av04.au.ibm.com [9.190.235.139])
	by d23relay02.au.ibm.com (8.13.8/8.13.8/NCO v9.2) with ESMTP id n376btUB1151222
	for <linux-mm@kvack.org>; Tue, 7 Apr 2009 16:37:57 +1000
Received: from d23av04.au.ibm.com (loopback [127.0.0.1])
	by d23av04.au.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id n376bsL1004744
	for <linux-mm@kvack.org>; Tue, 7 Apr 2009 16:37:54 +1000
Date: Tue, 7 Apr 2009 12:07:22 +0530
From: Balbir Singh <balbir@linux.vnet.ibm.com>
Subject: [RFI] Shared accounting for memory resource controller
Message-ID: <20090407063722.GQ7082@balbir.in.ibm.com>
Reply-To: balbir@linux.vnet.ibm.com
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
To: "linux-mm@kvack.org" <linux-mm@kvack.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, "lizf@cn.fujitsu.com" <lizf@cn.fujitsu.com>, Rik van Riel <riel@surriel.com>, Bharata B Rao <bharata.rao@in.ibm.com>, Dhaval Giani <dhaval@linux.vnet.ibm.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

Hi, All,

This is a request for input for the design of shared page accounting for
the memory resource controller, here is what I have so far

Motivation for shared page accounting
-------------------------------------
1. Memory cgroup administrators will benefit from the knowledge of how
   much of the data is shared, it helps size the groups correctly.
2. We currently report only the pages brought in by the cgroup, knowledge
   of shared data will give a complete picture of the actual usage.

Use rmap to account sharing/unsharing through mapcount
-------------------------------------------------------

The current page has links to

	+-------+
	|       |
	|	+--->pc->mem_cgroup (first mem_cgroup to touch the page)
	|	|
	| page	|
	|	+--->mapping (used for rmap)
	|	|
	+-------+

While accounting shared pages works well, as pages get unshared, I've hit a
problem. Here is the current flow for shared accounting

Flow for sharing
----------------
1. Page not yet mapped anywhere (_mapcount is -1 and mem_cgroup,mapping is NULL)
2. Page gets mapped for the first time (_mapcount is 0, mem_cgroup points
   to the memory resource group that brought in the page, mapping is set)
3. Page gets shared (_mapcount is 1, mem_cgroup points to the cgroup that
   brought in the page, mapping is set and now has rmap information)

When a page is being shared at step 3, we detect we are sharing the page and

1. For page->pc->mem_cgroup, we note that the page is being shared
2. For any vma that maps this page, we get to vma->vm_mm and then to the
   other mem_cgroup that is sharing this page and note this page is being
   shared.

So far so good

When a page is being uncharged

1. We note that we need to deduct the shared accounting from the mem_cgroup
2. When the _mapcount reaches 0, we have no way of knowing which of the
   mm's or mem_cgroup's is left behind. The original page->pc->mem_cgroup
   could have unmapped this page long time back. At this point we want
   to note the only mm that has this page mapped and the mem_cgroup is not
   sharing the page, but that the page is private to it.

Figuring out the mem_cgroup/mm for the last uncharge, requires a rmap
lookup, which we cannot do with PTE lock held (I have all my hooks in
page_add.*rmap() and page_remove_rmap()).

Questions, suggestions

1. Does it make sense to use the rmap routines for shared accounting?
2. How do we solve the problem of the last unshare causing the pages
   becoming private
	a. Can we use rmap?
	b. Can we live with leaving the page being marked as shared, even
           though it is no longer shared?


-- 
	Balbir

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
