Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx117.postini.com [74.125.245.117])
	by kanga.kvack.org (Postfix) with SMTP id 8C27D8D0001
	for <linux-mm@kvack.org>; Mon, 14 May 2012 07:58:34 -0400 (EDT)
Received: from /spool/local
	by e06smtp16.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <ehrhardt@linux.vnet.ibm.com>;
	Mon, 14 May 2012 12:58:32 +0100
Received: from d06av02.portsmouth.uk.ibm.com (d06av02.portsmouth.uk.ibm.com [9.149.37.228])
	by d06nrmr1407.portsmouth.uk.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id q4EBwVMZ2449570
	for <linux-mm@kvack.org>; Mon, 14 May 2012 12:58:31 +0100
Received: from d06av02.portsmouth.uk.ibm.com (loopback [127.0.0.1])
	by d06av02.portsmouth.uk.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id q4EBwVBa027298
	for <linux-mm@kvack.org>; Mon, 14 May 2012 05:58:31 -0600
From: ehrhardt@linux.vnet.ibm.com
Subject: [PATCH 0/2] swap: improve swap I/O rate
Date: Mon, 14 May 2012 13:58:27 +0200
Message-Id: <1336996709-8304-1-git-send-email-ehrhardt@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: axboe@kernel.dk, Ehrhardt Christian <ehrhardt@linux.vnet.ibm.com>

From: Ehrhardt Christian <ehrhardt@linux.vnet.ibm.com>

From: Christian Ehrhardt <ehrhardt@linux.vnet.ibm.com>

In an memory overcommitment scneario with KVM I ran into a lot of wiats for
swap. While checking the I/O done on the swap disks I found almost all I/Os
to be done as single page 4k request. Despite the fact that swap in is a
batch of 1<<page-cluster pages as swap readahead and swap out is a list of
pages written in shrink_page_list.

[1/2 swap in improvment]
The read patch shows improvements of up to 50% swap throughput, much happier
guest systems and even when running with comparable throughput a lot I/O per
seconds saved leaving resources in the SAN for other consumers.

[2/2 documentation]
While doing so I also realized that the documentation for
proc/sys/vm/page-cluster is no more matching the code

[missing patch #3]
I tried to get a similar patch working for swap out in shrink_page_list. And
it worked in functional terms, but the additional mergin was negligible.
Maybe the cond_resched triggers much mor often than I expected, I'm open for
suggestions regarding improving the pagout I/O sizes as well.

Kind regards,
Christian Ehrhardt


Christian Ehrhardt (2):
  swap: allow swap readahead to be merged
  documentation: update how page-cluster affects swap I/O

 Documentation/sysctl/vm.txt |   12 ++++++++++--
 mm/swap_state.c             |    5 +++++
 2 files changed, 15 insertions(+), 2 deletions(-)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
