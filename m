Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f48.google.com (mail-pa0-f48.google.com [209.85.220.48])
	by kanga.kvack.org (Postfix) with ESMTP id 70A726B0038
	for <linux-mm@kvack.org>; Thu,  3 Dec 2015 09:23:02 -0500 (EST)
Received: by pacdm15 with SMTP id dm15so69781992pac.3
        for <linux-mm@kvack.org>; Thu, 03 Dec 2015 06:23:02 -0800 (PST)
Received: from m50-138.163.com (m50-138.163.com. [123.125.50.138])
        by mx.google.com with ESMTP id wh2si12310597pac.170.2015.12.03.06.23.00
        for <linux-mm@kvack.org>;
        Thu, 03 Dec 2015 06:23:01 -0800 (PST)
From: Geliang Tang <geliangtang@163.com>
Subject: [PATCH] shmem: use list_for_each_entry_safe in shmem_unuse
Date: Thu,  3 Dec 2015 22:22:07 +0800
Message-Id: <73d897527151da752a219a6c38b2c261cb5b74fe.1449152443.git.geliangtang@163.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hugh Dickins <hughd@google.com>
Cc: Geliang Tang <geliangtang@163.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

Simplify the code with list_for_each_entry_safe().

Signed-off-by: Geliang Tang <geliangtang@163.com>
---
 mm/shmem.c | 6 ++----
 1 file changed, 2 insertions(+), 4 deletions(-)

diff --git a/mm/shmem.c b/mm/shmem.c
index 9b05111..816685f 100644
--- a/mm/shmem.c
+++ b/mm/shmem.c
@@ -793,8 +793,7 @@ static int shmem_unuse_inode(struct shmem_inode_info *info,
  */
 int shmem_unuse(swp_entry_t swap, struct page *page)
 {
-	struct list_head *this, *next;
-	struct shmem_inode_info *info;
+	struct shmem_inode_info *info, *next;
 	struct mem_cgroup *memcg;
 	int error = 0;
 
@@ -818,8 +817,7 @@ int shmem_unuse(swp_entry_t swap, struct page *page)
 	error = -EAGAIN;
 
 	mutex_lock(&shmem_swaplist_mutex);
-	list_for_each_safe(this, next, &shmem_swaplist) {
-		info = list_entry(this, struct shmem_inode_info, swaplist);
+	list_for_each_entry_safe(info, next, &shmem_swaplist, swaplist) {
 		if (info->swapped)
 			error = shmem_unuse_inode(info, swap, &page);
 		else
-- 
2.5.0


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
