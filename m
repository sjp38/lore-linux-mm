Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f170.google.com (mail-pd0-f170.google.com [209.85.192.170])
	by kanga.kvack.org (Postfix) with ESMTP id EDA83900001
	for <linux-mm@kvack.org>; Wed,  2 Oct 2013 10:29:03 -0400 (EDT)
Received: by mail-pd0-f170.google.com with SMTP id x10so1001105pdj.1
        for <linux-mm@kvack.org>; Wed, 02 Oct 2013 07:29:03 -0700 (PDT)
From: Jan Kara <jack@suse.cz>
Subject: [PATCH 18/26] mm: Convert process_vm_rw_pages() to use get_user_pages_unlocked()
Date: Wed,  2 Oct 2013 16:27:59 +0200
Message-Id: <1380724087-13927-19-git-send-email-jack@suse.cz>
In-Reply-To: <1380724087-13927-1-git-send-email-jack@suse.cz>
References: <1380724087-13927-1-git-send-email-jack@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: LKML <linux-kernel@vger.kernel.org>
Cc: linux-mm@kvack.org, Jan Kara <jack@suse.cz>

Signed-off-by: Jan Kara <jack@suse.cz>
---
 mm/process_vm_access.c | 8 ++------
 1 file changed, 2 insertions(+), 6 deletions(-)

diff --git a/mm/process_vm_access.c b/mm/process_vm_access.c
index fd26d0433509..c1bc47d8ed90 100644
--- a/mm/process_vm_access.c
+++ b/mm/process_vm_access.c
@@ -64,12 +64,8 @@ static int process_vm_rw_pages(struct task_struct *task,
 	*bytes_copied = 0;
 
 	/* Get the pages we're interested in */
-	down_read(&mm->mmap_sem);
-	pages_pinned = get_user_pages(task, mm, pa,
-				      nr_pages_to_copy,
-				      vm_write, 0, process_pages, NULL);
-	up_read(&mm->mmap_sem);
-
+	pages_pinned = get_user_pages_unlocked(task, mm, pa, nr_pages_to_copy,
+					       vm_write, 0, process_pages);
 	if (pages_pinned != nr_pages_to_copy) {
 		rc = -EFAULT;
 		goto end;
-- 
1.8.1.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
