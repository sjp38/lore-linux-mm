Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id 5B4ED8D0039
	for <linux-mm@kvack.org>; Wed,  9 Feb 2011 14:54:22 -0500 (EST)
Received: from d01dlp01.pok.ibm.com (d01dlp01.pok.ibm.com [9.56.224.56])
	by e5.ny.us.ibm.com (8.14.4/8.13.1) with ESMTP id p19JUFBl015181
	for <linux-mm@kvack.org>; Wed, 9 Feb 2011 14:30:17 -0500
Received: from d01relay02.pok.ibm.com (d01relay02.pok.ibm.com [9.56.227.234])
	by d01dlp01.pok.ibm.com (Postfix) with ESMTP id 71F2E728063
	for <linux-mm@kvack.org>; Wed,  9 Feb 2011 14:54:19 -0500 (EST)
Received: from d03av03.boulder.ibm.com (d03av03.boulder.ibm.com [9.17.195.169])
	by d01relay02.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id p19JsIEw449608
	for <linux-mm@kvack.org>; Wed, 9 Feb 2011 14:54:19 -0500
Received: from d03av03.boulder.ibm.com (loopback [127.0.0.1])
	by d03av03.boulder.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id p19JsHdV030562
	for <linux-mm@kvack.org>; Wed, 9 Feb 2011 12:54:18 -0700
Subject: [PATCH 5/5] have smaps show transparent huge pages
From: Dave Hansen <dave@linux.vnet.ibm.com>
Date: Wed, 09 Feb 2011 11:54:13 -0800
References: <20110209195406.B9F23C9F@kernel>
In-Reply-To: <20110209195406.B9F23C9F@kernel>
Message-Id: <20110209195413.6D3CB37F@kernel>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: linux-mm@kvack.org, Michael J Wolf <mjwolf@us.ibm.com>, Andrea Arcangeli <aarcange@redhat.com>, Dave Hansen <dave@linux.vnet.ibm.com>, Johannes Weiner <hannes@cmpxchg.org>, David Rientjes <rientjes@google.com>


Now that the mere act of _looking_ at /proc/$pid/smaps will not
destroy transparent huge pages, tell how much of the VMA is
actually mapped with them.

This way, we can make sure that we're getting THPs where we
expect to see them.

Signed-off-by: Dave Hansen <dave@linux.vnet.ibm.com>
Acked-by: David Rientjes <rientjes@google.com>
---

 linux-2.6.git-dave/fs/proc/task_mmu.c |    4 ++++
 1 file changed, 4 insertions(+)

diff -puN fs/proc/task_mmu.c~teach-smaps-thp fs/proc/task_mmu.c
--- linux-2.6.git/fs/proc/task_mmu.c~teach-smaps-thp	2011-02-09 11:41:44.423556779 -0800
+++ linux-2.6.git-dave/fs/proc/task_mmu.c	2011-02-09 11:41:52.611550670 -0800
@@ -331,6 +331,7 @@ struct mem_size_stats {
 	unsigned long private_dirty;
 	unsigned long referenced;
 	unsigned long anonymous;
+	unsigned long anonymous_thp;
 	unsigned long swap;
 	u64 pss;
 };
@@ -394,6 +395,7 @@ static int smaps_pte_range(pmd_t *pmd, u
 			spin_lock(&walk->mm->page_table_lock);
 		} else {
 			smaps_pte_entry(*(pte_t *)pmd, addr, HPAGE_SIZE, walk);
+			mss->anonymous_thp += HPAGE_SIZE;
 			return 0;
 		}
 	}
@@ -435,6 +437,7 @@ static int show_smap(struct seq_file *m,
 		   "Private_Dirty:  %8lu kB\n"
 		   "Referenced:     %8lu kB\n"
 		   "Anonymous:      %8lu kB\n"
+		   "AnonHugePages:  %8lu kB\n"
 		   "Swap:           %8lu kB\n"
 		   "KernelPageSize: %8lu kB\n"
 		   "MMUPageSize:    %8lu kB\n"
@@ -448,6 +451,7 @@ static int show_smap(struct seq_file *m,
 		   mss.private_dirty >> 10,
 		   mss.referenced >> 10,
 		   mss.anonymous >> 10,
+		   mss.anonymous_thp >> 10,
 		   mss.swap >> 10,
 		   vma_kernel_pagesize(vma) >> 10,
 		   vma_mmu_pagesize(vma) >> 10,
_

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
