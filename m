Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f43.google.com (mail-wg0-f43.google.com [74.125.82.43])
	by kanga.kvack.org (Postfix) with ESMTP id BF4036B00CF
	for <linux-mm@kvack.org>; Tue, 19 May 2015 11:27:37 -0400 (EDT)
Received: by wgbgq6 with SMTP id gq6so22311695wgb.3
        for <linux-mm@kvack.org>; Tue, 19 May 2015 08:27:37 -0700 (PDT)
Received: from mx0b-00082601.pphosted.com (mx0b-00082601.pphosted.com. [67.231.153.30])
        by mx.google.com with ESMTPS id e5si5102149wix.88.2015.05.19.08.27.35
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Tue, 19 May 2015 08:27:36 -0700 (PDT)
From: Josef Bacik <jbacik@fb.com>
Subject: [PATCH] tmpfs: truncate at i_size
Date: Tue, 19 May 2015 11:27:31 -0400
Message-ID: <1432049251-3298-1-git-send-email-jbacik@fb.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: hughd@google.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org

If we fallocate past i_size with KEEP_SIZE, extend the file to use some but not
all of this space, and then truncate(i_size) we won't trim the excess
preallocated space.  We decided at LSF that we want to truncate the fallocated
bit past i_size when we truncate to i_size, which is what this patch does.
Thanks,

Signed-off-by: Josef Bacik <jbacik@fb.com>
---
 mm/shmem.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/mm/shmem.c b/mm/shmem.c
index de98137..089afde 100644
--- a/mm/shmem.c
+++ b/mm/shmem.c
@@ -569,7 +569,7 @@ static int shmem_setattr(struct dentry *dentry, struct iattr *attr)
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
