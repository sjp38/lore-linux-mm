Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f181.google.com (mail-wi0-f181.google.com [209.85.212.181])
	by kanga.kvack.org (Postfix) with ESMTP id 9AE836B0038
	for <linux-mm@kvack.org>; Tue, 16 Jun 2015 16:10:07 -0400 (EDT)
Received: by wiga1 with SMTP id a1so119121716wig.0
        for <linux-mm@kvack.org>; Tue, 16 Jun 2015 13:10:07 -0700 (PDT)
Received: from mail-wg0-x231.google.com (mail-wg0-x231.google.com. [2a00:1450:400c:c00::231])
        by mx.google.com with ESMTPS id by11si4809159wib.105.2015.06.16.13.10.05
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 16 Jun 2015 13:10:06 -0700 (PDT)
Received: by wgzl5 with SMTP id l5so20290335wgz.3
        for <linux-mm@kvack.org>; Tue, 16 Jun 2015 13:10:05 -0700 (PDT)
Date: Tue, 16 Jun 2015 13:07:04 -0700 (PDT)
From: Hugh Dickins <hughd@google.com>
Subject: [PATCH] tmpfs: truncate prealloc blocks past i_size
In-Reply-To: <alpine.LSU.2.11.1506161256490.1050@eggly.anvils>
Message-ID: <alpine.LSU.2.11.1506161302520.1050@eggly.anvils>
References: <1432049251-3298-1-git-send-email-jbacik@fb.com> <alpine.LSU.2.11.1506161256490.1050@eggly.anvils>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Josef Bacik <jbacik@fb.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org

From: Josef Bacik <jbacik@fb.com>

One of the rocksdb people noticed that when you do something like this

fallocate(fd, FALLOC_FL_KEEP_SIZE, 0, 10M)
pwrite(fd, buf, 5M, 0)
ftruncate(5M)

on tmpfs, the file would still take up 10M: which led to super fun issues
because we were getting ENOSPC before we thought we should be getting
ENOSPC.  This patch fixes the problem, and mirrors what all the other
fs'es do (and was agreed to be the correct behaviour at LSF).

I tested it locally to make sure it worked properly with the following

xfs_io -f -c "falloc -k 0 10M" -c "pwrite 0 5M" -c "truncate 5M" file

Without the patch we have "Blocks: 20480", with the patch we have the
correct value of "Blocks: 10240".

Signed-off-by: Josef Bacik <jbacik@fb.com>
Signed-off-by: Hugh Dickins <hughd@google.com>
---
 mm/shmem.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

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
