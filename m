Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f198.google.com (mail-qt0-f198.google.com [209.85.216.198])
	by kanga.kvack.org (Postfix) with ESMTP id D477E6B038D
	for <linux-mm@kvack.org>; Wed, 22 Feb 2017 13:50:48 -0500 (EST)
Received: by mail-qt0-f198.google.com with SMTP id n13so8180876qtc.0
        for <linux-mm@kvack.org>; Wed, 22 Feb 2017 10:50:48 -0800 (PST)
Received: from mx0a-00082601.pphosted.com (mx0b-00082601.pphosted.com. [67.231.153.30])
        by mx.google.com with ESMTPS id v9si2420081itb.99.2017.02.22.10.50.47
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 22 Feb 2017 10:50:47 -0800 (PST)
Received: from pps.filterd (m0001303.ppops.net [127.0.0.1])
	by m0001303.ppops.net (8.16.0.20/8.16.0.20) with SMTP id v1MIkRnP001703
	for <linux-mm@kvack.org>; Wed, 22 Feb 2017 10:50:47 -0800
Received: from mail.thefacebook.com ([199.201.64.23])
	by m0001303.ppops.net with ESMTP id 28scegrv1d-5
	(version=TLSv1 cipher=ECDHE-RSA-AES256-SHA bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Wed, 22 Feb 2017 10:50:47 -0800
Received: from facebook.com (2401:db00:21:603d:face:0:19:0)	by
 mx-out.facebook.com (10.102.107.97) with ESMTP	id
 d0fc22c2f92f11e6a5530002c99331b0-d51f8a00 for <linux-mm@kvack.org>;	Wed, 22
 Feb 2017 10:50:44 -0800
From: Shaohua Li <shli@fb.com>
Subject: [PATCH V4 6/6] proc: show MADV_FREE pages info in smaps
Date: Wed, 22 Feb 2017 10:50:44 -0800
Message-ID: <7f22d33b2f388ce33448faa75be75f9a52d57052.1487788131.git.shli@fb.com>
In-Reply-To: <cover.1487788131.git.shli@fb.com>
References: <cover.1487788131.git.shli@fb.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, linux-kernel@vger.kernel.org
Cc: Kernel-team@fb.com, mhocko@suse.com, minchan@kernel.org, hughd@google.com, hannes@cmpxchg.org, riel@redhat.com, mgorman@techsingularity.net, akpm@linux-foundation.org

show MADV_FREE pages info of each vma in smaps. The interface is for
diganose or monitoring purpose, userspace could use it to understand
what happens in the application. Since userspace could dirty MADV_FREE
pages without notice from kernel, this interface is the only place we
can get accurate accounting info about MADV_FREE pages.

Cc: Michal Hocko <mhocko@suse.com>
Cc: Minchan Kim <minchan@kernel.org>
Cc: Hugh Dickins <hughd@google.com>
Cc: Johannes Weiner <hannes@cmpxchg.org>
Cc: Rik van Riel <riel@redhat.com>
Cc: Mel Gorman <mgorman@techsingularity.net>
Cc: Andrew Morton <akpm@linux-foundation.org>
Signed-off-by: Shaohua Li <shli@fb.com>
---
 Documentation/filesystems/proc.txt | 4 ++++
 fs/proc/task_mmu.c                 | 8 +++++++-
 2 files changed, 11 insertions(+), 1 deletion(-)

diff --git a/Documentation/filesystems/proc.txt b/Documentation/filesystems/proc.txt
index c94b467..45853e1 100644
--- a/Documentation/filesystems/proc.txt
+++ b/Documentation/filesystems/proc.txt
@@ -412,6 +412,7 @@ Private_Clean:         0 kB
 Private_Dirty:         0 kB
 Referenced:          892 kB
 Anonymous:             0 kB
+LazyFree:              0 kB
 AnonHugePages:         0 kB
 ShmemPmdMapped:        0 kB
 Shared_Hugetlb:        0 kB
@@ -441,6 +442,9 @@ accessed.
 "Anonymous" shows the amount of memory that does not belong to any file.  Even
 a mapping associated with a file may contain anonymous pages: when MAP_PRIVATE
 and a page is modified, the file page is replaced by a private anonymous copy.
+"LazyFree" shows the amount of memory which is marked by madvise(MADV_FREE).
+The memory isn't freed immediately with madvise(). It's freed in memory
+pressure if the memory is clean.
 "AnonHugePages" shows the ammount of memory backed by transparent hugepage.
 "ShmemPmdMapped" shows the ammount of shared (shmem/tmpfs) memory backed by
 huge pages.
diff --git a/fs/proc/task_mmu.c b/fs/proc/task_mmu.c
index ee3efb2..8a5ec00 100644
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
+		if (!PageSwapBacked(page) && !dirty && !PageDirty(page))
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
