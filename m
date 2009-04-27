Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id C53456B00B2
	for <linux-mm@kvack.org>; Mon, 27 Apr 2009 12:10:19 -0400 (EDT)
Received: from d03relay02.boulder.ibm.com (d03relay02.boulder.ibm.com [9.17.195.227])
	by e34.co.us.ibm.com (8.13.1/8.13.1) with ESMTP id n3RG7wHf012738
	for <linux-mm@kvack.org>; Mon, 27 Apr 2009 10:07:58 -0600
Received: from d03av03.boulder.ibm.com (d03av03.boulder.ibm.com [9.17.195.169])
	by d03relay02.boulder.ibm.com (8.13.8/8.13.8/NCO v9.2) with ESMTP id n3RGAOeG038528
	for <linux-mm@kvack.org>; Mon, 27 Apr 2009 10:10:25 -0600
Received: from d03av03.boulder.ibm.com (loopback [127.0.0.1])
	by d03av03.boulder.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id n3RGANcl015847
	for <linux-mm@kvack.org>; Mon, 27 Apr 2009 10:10:24 -0600
From: Eric B Munson <ebmunson@us.ibm.com>
Subject: [PATCH] Display 0 in meminfo for Committed_AS when value underflows
Date: Mon, 27 Apr 2009 17:10:20 +0100
Message-Id: <1240848620-16751-1-git-send-email-ebmunson@us.ibm.com>
Sender: owner-linux-mm@kvack.org
To: akpm@linux-foundation.org
Cc: kosaki.motohiro@jp.fujitsu.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, mel@csn.ul.ie, cl@linux-foundation.org, dave@linux.vnet.ibm.com, Eric B Munson <ebmunson@us.ibm.com>
List-ID: <linux-mm.kvack.org>

Andrew,

Please merge the following patch.

Splitting this patch from the chunk that addresses the cause of the underflow
because the solution still requires some discussion.

Dave Hansen reported that under certain cirumstances the Committed_AS value
can underflow which causes extremely large numbers to be displayed in
meminfo.  This patch adds an underflow check to meminfo_proc_show() for the
Committed_AS value.  Most fields in /proc/meminfo already have an underflow
check, this brings Committed_AS into line.

Reported-by: Dave Hansen <dave@linux.vnet.ibm.com>
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Signed-off-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Signed-off-by: Eric B Munson <ebmunson@us.ibm.com>
---
 fs/proc/meminfo.c |    4 +++-
 1 files changed, 3 insertions(+), 1 deletions(-)

diff --git a/fs/proc/meminfo.c b/fs/proc/meminfo.c
index 74ea974..facb9fb 100644
--- a/fs/proc/meminfo.c
+++ b/fs/proc/meminfo.c
@@ -22,7 +22,7 @@ void __attribute__((weak)) arch_report_meminfo(struct seq_file *m)
 static int meminfo_proc_show(struct seq_file *m, void *v)
 {
 	struct sysinfo i;
-	unsigned long committed;
+	long committed;
 	unsigned long allowed;
 	struct vmalloc_info vmi;
 	long cached;
@@ -36,6 +36,8 @@ static int meminfo_proc_show(struct seq_file *m, void *v)
 	si_meminfo(&i);
 	si_swapinfo(&i);
 	committed = atomic_long_read(&vm_committed_space);
+	if (committed < 0)
+		committed = 0;
 	allowed = ((totalram_pages - hugetlb_total_pages())
 		* sysctl_overcommit_ratio / 100) + total_swap_pages;
 
-- 
1.6.1.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
