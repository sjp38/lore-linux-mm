Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f171.google.com (mail-pd0-f171.google.com [209.85.192.171])
	by kanga.kvack.org (Postfix) with ESMTP id 08472800CA
	for <linux-mm@kvack.org>; Fri,  7 Nov 2014 03:38:42 -0500 (EST)
Received: by mail-pd0-f171.google.com with SMTP id r10so2907790pdi.30
        for <linux-mm@kvack.org>; Fri, 07 Nov 2014 00:38:41 -0800 (PST)
Received: from mga01.intel.com (mga01.intel.com. [192.55.52.88])
        by mx.google.com with ESMTP id q2si4156893pdf.63.2014.11.07.00.38.40
        for <linux-mm@kvack.org>;
        Fri, 07 Nov 2014 00:38:40 -0800 (PST)
From: Xiaokang Qin <xiaokang.qin@intel.com>
Subject: [PATCH] proc/smaps: add proportional size of anonymous page
Date: Fri,  7 Nov 2014 16:31:28 +0800
Message-Id: <1415349088-24078-1-git-send-email-xiaokang.qin@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: fengwei.yin@intel.com, Xiaokang Qin <xiaokang.qin@intel.com>

Anonymous page could be shared if allocated before process fork. On Android, all
applications are forked from Zygote and it makes shared anonymous page common in
Android. Currently, the "Anonymous" in smaps doesn't reflect the shared count.
A proportional anonymous page size is better to understand the anonymous page
that the applications really using.
The "proportional anonymous page size" (PropAnonymous) of a process is the count of
anonymous pages it has in memory, where each anonymous page is devided by the number
of processes sharing it.

Signed-off-by: Xiaokang Qin <xiaokang.qin@intel.com>
---
 fs/proc/task_mmu.c |    7 +++++++
 1 file changed, 7 insertions(+)

diff --git a/fs/proc/task_mmu.c b/fs/proc/task_mmu.c
index cfa63ee..74a4f42 100644
--- a/fs/proc/task_mmu.c
+++ b/fs/proc/task_mmu.c
@@ -442,6 +442,7 @@ struct mem_size_stats {
 	unsigned long swap;
 	unsigned long nonlinear;
 	u64 pss;
+	u64 panon;
 };
 
 
@@ -488,12 +489,16 @@ static void smaps_pte_entry(pte_t ptent, unsigned long addr,
 		else
 			mss->shared_clean += ptent_size;
 		mss->pss += (ptent_size << PSS_SHIFT) / mapcount;
+		if (PageAnon(page))
+			mss->panon += (ptent_size << PSS_SHIFT) / mapcount;
 	} else {
 		if (pte_dirty(ptent) || PageDirty(page))
 			mss->private_dirty += ptent_size;
 		else
 			mss->private_clean += ptent_size;
 		mss->pss += (ptent_size << PSS_SHIFT);
+		if (PageAnon(page))
+			mss->panon += (ptent_size << PSS_SHIFT);
 	}
 }
 
@@ -611,6 +616,7 @@ static int show_smap(struct seq_file *m, void *v, int is_pid)
 		   "Private_Dirty:  %8lu kB\n"
 		   "Referenced:     %8lu kB\n"
 		   "Anonymous:      %8lu kB\n"
+		   "PropAnonymous:  %8lu kB\n"
 		   "AnonHugePages:  %8lu kB\n"
 		   "Swap:           %8lu kB\n"
 		   "KernelPageSize: %8lu kB\n"
@@ -625,6 +631,7 @@ static int show_smap(struct seq_file *m, void *v, int is_pid)
 		   mss.private_dirty >> 10,
 		   mss.referenced >> 10,
 		   mss.anonymous >> 10,
+		   (unsigned long)(mss.panon >> (10 + PSS_SHIFT)),
 		   mss.anonymous_thp >> 10,
 		   mss.swap >> 10,
 		   vma_kernel_pagesize(vma) >> 10,
-- 
1.7.9.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
