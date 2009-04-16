Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id 136A25F0001
	for <linux-mm@kvack.org>; Thu, 16 Apr 2009 17:12:38 -0400 (EDT)
Received: from sj-core-1.cisco.com (sj-core-1.cisco.com [171.71.177.237])
	by sj-dkim-1.cisco.com (8.12.11/8.12.11) with ESMTP id n3GLCnq9008092
	for <linux-mm@kvack.org>; Thu, 16 Apr 2009 14:12:49 -0700
Received: from cliff.cisco.com (cliff.cisco.com [171.69.11.141])
	by sj-core-1.cisco.com (8.13.8/8.13.8) with ESMTP id n3GLCn37004652
	for <linux-mm@kvack.org>; Thu, 16 Apr 2009 21:12:49 GMT
Received: from cuplxvomd02.corp.sa.net ([64.101.20.155]) by cliff.cisco.com (8.6.12/8.6.5) with ESMTP id VAA11429 for <linux-mm@kvack.org>; Thu, 16 Apr 2009 21:12:49 GMT
Date: Thu, 16 Apr 2009 14:12:49 -0700
From: VomLehn <dvomlehn@cisco.com>
Subject: Puzzled by __vm_enough_memory with OVERCOMMIT_NEVER
Message-ID: <20090416211249.GA9828@cuplxvomd02.corp.sa.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
To: Linux Memory Management Mailing List <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

The function __vm_enough_memory in mm/mmap.c has a piece of code for
handling the case of disabled overcommit that has puzzled me for a while
and looks like it may be causing a problem:

	/* Don't let a single process grow too big:
	   leave 3% of the size of this process for other processes */
	if (mm)
		allowed -= mm->total_vm / 32;

At this point, it seems like total_vm does not yet include the pages
we are trying to add, so this is limiting a single process to no more than
97% of its *old* size rather than its new size. So, this seems to make more
sense:

	if (mm)
		allowed -= (mm->total_vm + pages)/ 32;

Even then, it seems like the real way to do this would be simply to lop off
3% of the total available virtual memory, and use:

	allowed -= allowed / 32;

Or, perhaps I'm missing something.
--
David VomLehn

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
