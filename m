Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id 05E4A6B000A
	for <linux-mm@kvack.org>; Tue, 20 Mar 2018 17:32:21 -0400 (EDT)
Received: by mail-pf0-f199.google.com with SMTP id n15so1623945pff.14
        for <linux-mm@kvack.org>; Tue, 20 Mar 2018 14:32:20 -0700 (PDT)
Received: from out30-130.freemail.mail.aliyun.com (out30-130.freemail.mail.aliyun.com. [115.124.30.130])
        by mx.google.com with ESMTPS id h125si1923642pfc.133.2018.03.20.14.32.19
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 20 Mar 2018 14:32:19 -0700 (PDT)
From: Yang Shi <yang.shi@linux.alibaba.com>
Subject: [RFC PATCH 5/8] ipc: shm: pass atomic parameter to do_munmap()
Date: Wed, 21 Mar 2018 05:31:23 +0800
Message-Id: <1521581486-99134-6-git-send-email-yang.shi@linux.alibaba.com>
In-Reply-To: <1521581486-99134-1-git-send-email-yang.shi@linux.alibaba.com>
References: <1521581486-99134-1-git-send-email-yang.shi@linux.alibaba.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org
Cc: yang.shi@linux.alibaba.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org

It looks safe to do unlock/relock mmap_sem in the middle of shmat(), so
passing "false" here.

Signed-off-by: Yang Shi <yang.shi@linux.alibaba.com>
---
 ipc/shm.c | 9 ++++++---
 1 file changed, 6 insertions(+), 3 deletions(-)

diff --git a/ipc/shm.c b/ipc/shm.c
index 4643865..1617523 100644
--- a/ipc/shm.c
+++ b/ipc/shm.c
@@ -1537,7 +1537,8 @@ long do_shmat(int shmid, char __user *shmaddr, int shmflg,
 			 */
 			file = vma->vm_file;
 			size = i_size_read(file_inode(vma->vm_file));
-			do_munmap(mm, vma->vm_start, vma->vm_end - vma->vm_start, NULL);
+			do_munmap(mm, vma->vm_start, vma->vm_end - vma->vm_start,
+				  NULL, false);
 			/*
 			 * We discovered the size of the shm segment, so
 			 * break out of here and fall through to the next
@@ -1564,7 +1565,8 @@ long do_shmat(int shmid, char __user *shmaddr, int shmflg,
 		if ((vma->vm_ops == &shm_vm_ops) &&
 		    ((vma->vm_start - addr)/PAGE_SIZE == vma->vm_pgoff) &&
 		    (vma->vm_file == file))
-			do_munmap(mm, vma->vm_start, vma->vm_end - vma->vm_start, NULL);
+			do_munmap(mm, vma->vm_start, vma->vm_end - vma->vm_start,
+				  NULL, false);
 		vma = next;
 	}
 
@@ -1573,7 +1575,8 @@ long do_shmat(int shmid, char __user *shmaddr, int shmflg,
 	 * given
 	 */
 	if (vma && vma->vm_start == addr && vma->vm_ops == &shm_vm_ops) {
-		do_munmap(mm, vma->vm_start, vma->vm_end - vma->vm_start, NULL);
+		do_munmap(mm, vma->vm_start, vma->vm_end - vma->vm_start,
+			  NULL, false);
 		retval = 0;
 	}
 
-- 
1.8.3.1
