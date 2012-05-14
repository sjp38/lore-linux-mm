Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx205.postini.com [74.125.245.205])
	by kanga.kvack.org (Postfix) with SMTP id 062578D000B
	for <linux-mm@kvack.org>; Mon, 14 May 2012 07:58:37 -0400 (EDT)
Received: from /spool/local
	by e06smtp14.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <ehrhardt@linux.vnet.ibm.com>;
	Mon, 14 May 2012 12:58:36 +0100
Received: from d06av04.portsmouth.uk.ibm.com (d06av04.portsmouth.uk.ibm.com [9.149.37.216])
	by d06nrmr1507.portsmouth.uk.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id q4EBwXJ72465980
	for <linux-mm@kvack.org>; Mon, 14 May 2012 12:58:33 +0100
Received: from d06av04.portsmouth.uk.ibm.com (loopback [127.0.0.1])
	by d06av04.portsmouth.uk.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id q4EBwXD2028891
	for <linux-mm@kvack.org>; Mon, 14 May 2012 05:58:33 -0600
From: ehrhardt@linux.vnet.ibm.com
Subject: [PATCH 2/2] documentation: update how page-cluster affects swap I/O
Date: Mon, 14 May 2012 13:58:29 +0200
Message-Id: <1336996709-8304-3-git-send-email-ehrhardt@linux.vnet.ibm.com>
In-Reply-To: <1336996709-8304-1-git-send-email-ehrhardt@linux.vnet.ibm.com>
References: <1336996709-8304-1-git-send-email-ehrhardt@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: axboe@kernel.dk, Christian Ehrhardt <ehrhardt@linux.vnet.ibm.com>

From: Christian Ehrhardt <ehrhardt@linux.vnet.ibm.com>

Fix of the documentation of /proc/sys/vm/page-cluster to match the behavior of
the code and add some comments about what the tunable will change in that
behavior.

Signed-off-by: Christian Ehrhardt <ehrhardt@linux.vnet.ibm.com>
---
 Documentation/sysctl/vm.txt |   12 ++++++++++--
 1 files changed, 10 insertions(+), 2 deletions(-)

diff --git a/Documentation/sysctl/vm.txt b/Documentation/sysctl/vm.txt
index 96f0ee8..4d87dc0 100644
--- a/Documentation/sysctl/vm.txt
+++ b/Documentation/sysctl/vm.txt
@@ -574,16 +574,24 @@ of physical RAM.  See above.
 
 page-cluster
 
-page-cluster controls the number of pages which are written to swap in
-a single attempt.  The swap I/O size.
+page-cluster controls the number of pages up to which consecutive pages (if
+available) are read in from swap in a single attempt. This is the swap
+counterpart to page cache readahead.
+The mentioned consecutivity is not in terms of virtual/physical addresses,
+but consecutive on swap space - that means they were swapped out together.
 
 It is a logarithmic value - setting it to zero means "1 page", setting
 it to 1 means "2 pages", setting it to 2 means "4 pages", etc.
+Zero disables swap readahead completely.
 
 The default value is three (eight pages at a time).  There may be some
 small benefits in tuning this to a different value if your workload is
 swap-intensive.
 
+Lower values mean lower latencies for initial faults, but at the same time
+extra faults and I/O delays for following faults if they would have been part of
+that consecutive pages readahead would have brought in.
+
 =============================================================
 
 panic_on_oom
-- 
1.7.0.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
