Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f171.google.com (mail-pd0-f171.google.com [209.85.192.171])
	by kanga.kvack.org (Postfix) with ESMTP id 5865990008B
	for <linux-mm@kvack.org>; Wed, 29 Oct 2014 13:10:13 -0400 (EDT)
Received: by mail-pd0-f171.google.com with SMTP id r10so3342173pdi.30
        for <linux-mm@kvack.org>; Wed, 29 Oct 2014 10:10:12 -0700 (PDT)
Received: from mx0a-00082601.pphosted.com (mx0a-00082601.pphosted.com. [67.231.145.42])
        by mx.google.com with ESMTP id ri14si4416182pdb.189.2014.10.29.10.10.11
        for <linux-mm@kvack.org>;
        Wed, 29 Oct 2014 10:10:12 -0700 (PDT)
From: Josef Bacik <jbacik@fb.com>
Subject: [PATCH] tmpfs: truncate prealloc blocks past i_size
Date: Wed, 29 Oct 2014 13:10:08 -0400
Message-ID: <1414602608-1416-1-git-send-email-jbacik@fb.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: hughd@google.com, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org

One of the rocksdb people noticed that when you do something like this

fallocate(fd, FALLOC_FL_KEEP_SIZE, 0, 10M)
pwrite(fd, buf, 5M, 0)
ftruncate(5M)

on tmpfs the file would still take up 10M, which lead to super fun issues
because we were getting ENOSPC before we thought we should be getting ENOSPC.
This patch fixes the problem, and mirrors what all the other fs'es do.  I tested
it locally to make sure it worked properly with the following

xfs_io -f -c "falloc -k 0 10M" -c "pwrite 0 5M" -c "truncate 5M" file

Without the patch we have "Blocks: 20480", with the patch we have the correct
value of "Blocks: 10240".  Thanks,

Signed-off-by: Josef Bacik <jbacik@fb.com>
---
 mm/shmem.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/mm/shmem.c b/mm/shmem.c
index 185836b..79b7fb5 100644
--- a/mm/shmem.c
+++ b/mm/shmem.c
@@ -574,7 +574,7 @@ static int shmem_setattr(struct dentry *dentry, struct iattr *attr)
 			i_size_write(inode, newsize);
 			inode->i_ctime = inode->i_mtime = CURRENT_TIME;
 		}
-		if (newsize < oldsize) {
+		if (newsize <= oldsize) {
 			loff_t holebegin = round_up(newsize, PAGE_SIZE);
 			unmap_mapping_range(inode->i_mapping, holebegin, 0, 1);
 			shmem_truncate_range(inode, newsize, (loff_t)-1);
-- 
1.8.3.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
