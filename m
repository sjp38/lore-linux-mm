Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f72.google.com (mail-it0-f72.google.com [209.85.214.72])
	by kanga.kvack.org (Postfix) with ESMTP id A077A680FC1
	for <linux-mm@kvack.org>; Tue, 14 Feb 2017 14:36:16 -0500 (EST)
Received: by mail-it0-f72.google.com with SMTP id y196so40566942ity.1
        for <linux-mm@kvack.org>; Tue, 14 Feb 2017 11:36:16 -0800 (PST)
Received: from mx0b-00082601.pphosted.com (mx0b-00082601.pphosted.com. [67.231.153.30])
        by mx.google.com with ESMTPS id e3si3832044ith.24.2017.02.14.11.36.15
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 14 Feb 2017 11:36:16 -0800 (PST)
Received: from pps.filterd (m0109332.ppops.net [127.0.0.1])
	by mx0a-00082601.pphosted.com (8.16.0.20/8.16.0.20) with SMTP id v1EJY9Qh003466
	for <linux-mm@kvack.org>; Tue, 14 Feb 2017 11:36:15 -0800
Received: from mail.thefacebook.com ([199.201.64.23])
	by mx0a-00082601.pphosted.com with ESMTP id 28m7bm85j3-4
	(version=TLSv1 cipher=ECDHE-RSA-AES256-SHA bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Tue, 14 Feb 2017 11:36:15 -0800
Received: from facebook.com (2401:db00:21:603d:face:0:19:0)	by
 mx-out.facebook.com (10.102.107.99) with ESMTP	id
 d8c72d24f2ec11e689030002c99293a0-42a236c0 for <linux-mm@kvack.org>;	Tue, 14
 Feb 2017 11:36:14 -0800
From: Shaohua Li <shli@fb.com>
Subject: [PATCH V3 6/7] proc: show MADV_FREE pages info in smaps
Date: Tue, 14 Feb 2017 11:36:12 -0800
Message-ID: <f522f2b4e7297281fab0652a11230563bab4c940.1487100204.git.shli@fb.com>
In-Reply-To: <cover.1487100204.git.shli@fb.com>
References: <cover.1487100204.git.shli@fb.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, linux-kernel@vger.kernel.org
Cc: Kernel-team@fb.com, mhocko@suse.com, minchan@kernel.org, hughd@google.com, hannes@cmpxchg.org, riel@redhat.com, mgorman@techsingularity.net, akpm@linux-foundation.org

show MADV_FREE pages info of each vma in smaps. This is mainly for
diagnose purpose. Userspace could use it to understand what happens in
the vma.

Cc: Michal Hocko <mhocko@suse.com>
Cc: Minchan Kim <minchan@kernel.org>
Cc: Hugh Dickins <hughd@google.com>
Cc: Johannes Weiner <hannes@cmpxchg.org>
Cc: Rik van Riel <riel@redhat.com>
Cc: Mel Gorman <mgorman@techsingularity.net>
Cc: Andrew Morton <akpm@linux-foundation.org>
Signed-off-by: Shaohua Li <shli@fb.com>
---
 fs/proc/task_mmu.c | 8 +++++++-
 1 file changed, 7 insertions(+), 1 deletion(-)

diff --git a/fs/proc/task_mmu.c b/fs/proc/task_mmu.c
index ee3efb2..8f2423f 100644
--- a/fs/proc/task_mmu.c
+++ b/fs/proc/task_mmu.c
@@ -440,6 +440,7 @@ struct mem_size_stats {
 	unsigned long private_dirty;
 	unsigned long referenced;
 	unsigned long anonymous;
+	unsigned long lazyfree;
 	unsigned long anonymous_thp;
 	unsigned long shmem_thp;
 	unsigned long swap;
@@ -456,8 +457,11 @@ static void smaps_account(struct mem_size_stats *mss, struct page *page,
 	int i, nr = compound ? 1 << compound_order(page) : 1;
 	unsigned long size = nr * PAGE_SIZE;
 
-	if (PageAnon(page))
+	if (PageAnon(page)) {
 		mss->anonymous += size;
+		if (!PageSwapBacked(page))
+			mss->lazyfree += size;
+	}
 
 	mss->resident += size;
 	/* Accumulate the size in pages that have been accessed. */
@@ -770,6 +774,7 @@ static int show_smap(struct seq_file *m, void *v, int is_pid)
 		   "Private_Dirty:  %8lu kB\n"
 		   "Referenced:     %8lu kB\n"
 		   "Anonymous:      %8lu kB\n"
+		   "LazyFree:       %8lu kB\n"
 		   "AnonHugePages:  %8lu kB\n"
 		   "ShmemPmdMapped: %8lu kB\n"
 		   "Shared_Hugetlb: %8lu kB\n"
@@ -788,6 +793,7 @@ static int show_smap(struct seq_file *m, void *v, int is_pid)
 		   mss.private_dirty >> 10,
 		   mss.referenced >> 10,
 		   mss.anonymous >> 10,
+		   mss.lazyfree >> 10,
 		   mss.anonymous_thp >> 10,
 		   mss.shmem_thp >> 10,
 		   mss.shared_hugetlb >> 10,
-- 
2.9.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
