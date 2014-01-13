Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f179.google.com (mail-pd0-f179.google.com [209.85.192.179])
	by kanga.kvack.org (Postfix) with ESMTP id 449976B0031
	for <linux-mm@kvack.org>; Mon, 13 Jan 2014 13:46:24 -0500 (EST)
Received: by mail-pd0-f179.google.com with SMTP id y10so770013pdj.38
        for <linux-mm@kvack.org>; Mon, 13 Jan 2014 10:46:23 -0800 (PST)
Received: from mx0a-00082601.pphosted.com (mx0b-00082601.pphosted.com. [67.231.153.30])
        by mx.google.com with ESMTP id yd9si16440256pab.234.2014.01.13.10.46.22
        for <linux-mm@kvack.org>;
        Mon, 13 Jan 2014 10:46:23 -0800 (PST)
From: Josef Bacik <jbacik@fb.com>
Subject: [PATCH] shmem: init on stack vmas
Date: Mon, 13 Jan 2014 13:46:17 -0500
Message-ID: <1389638777-31891-1-git-send-email-jbacik@fb.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, linux-fsdevel@vger.kernel.org

We were hitting a weird bug with our cgroup stuff because shmem uses on stack
vmas.  These aren't properly init'ed so we'd have garbage in vma->mm and bad
things would happen.  Fix this by just init'ing to empty structs.  Thanks,

Signed-off-by: Josef Bacik <jbacik@fb.com>
---
 mm/shmem.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/mm/shmem.c b/mm/shmem.c
index 902a148..ee6b834 100644
--- a/mm/shmem.c
+++ b/mm/shmem.c
@@ -911,7 +911,7 @@ static struct mempolicy *shmem_get_sbmpol(struct shmem_sb_info *sbinfo)
 static struct page *shmem_swapin(swp_entry_t swap, gfp_t gfp,
 			struct shmem_inode_info *info, pgoff_t index)
 {
-	struct vm_area_struct pvma;
+	struct vm_area_struct pvma = {};
 	struct page *page;
 
 	/* Create a pseudo vma that just contains the policy */
@@ -932,7 +932,7 @@ static struct page *shmem_swapin(swp_entry_t swap, gfp_t gfp,
 static struct page *shmem_alloc_page(gfp_t gfp,
 			struct shmem_inode_info *info, pgoff_t index)
 {
-	struct vm_area_struct pvma;
+	struct vm_area_struct pvma = {};
 	struct page *page;
 
 	/* Create a pseudo vma that just contains the policy */
-- 
1.8.3.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
