Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f44.google.com (mail-pa0-f44.google.com [209.85.220.44])
	by kanga.kvack.org (Postfix) with ESMTP id 061CD6B0032
	for <linux-mm@kvack.org>; Wed,  3 Dec 2014 19:24:35 -0500 (EST)
Received: by mail-pa0-f44.google.com with SMTP id et14so16946007pad.3
        for <linux-mm@kvack.org>; Wed, 03 Dec 2014 16:24:34 -0800 (PST)
Received: from aserp1040.oracle.com (aserp1040.oracle.com. [141.146.126.69])
        by mx.google.com with ESMTPS id fb1si40730313pab.61.2014.12.03.16.24.32
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Wed, 03 Dec 2014 16:24:33 -0800 (PST)
From: Sasha Levin <sasha.levin@oracle.com>
Subject: [PATCH] mm: shmem: avoid overflowing in shmem_fallocate
Date: Wed,  3 Dec 2014 19:24:07 -0500
Message-Id: <1417652657-1801-1-git-send-email-sasha.levin@oracle.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: Sasha Levin <sasha.levin@oracle.com>, Hugh Dickins <hughd@google.com>, linux-mm@kvack.org

"offset + len" has the potential of overflowing. Validate this user input
first to avoid undefined behaviour.

Signed-off-by: Sasha Levin <sasha.levin@oracle.com>
---
 mm/shmem.c |    3 +++
 1 file changed, 3 insertions(+)

diff --git a/mm/shmem.c b/mm/shmem.c
index 185836b..5a0e344 100644
--- a/mm/shmem.c
+++ b/mm/shmem.c
@@ -2098,6 +2098,9 @@ static long shmem_fallocate(struct file *file, int mode, loff_t offset,
 	}
 
 	/* We need to check rlimit even when FALLOC_FL_KEEP_SIZE */
+	error = -EOVERFLOW;
+	if ((u64)len + offset < (u64)len)
+		goto out;
 	error = inode_newsize_ok(inode, offset + len);
 	if (error)
 		goto out;
-- 
1.7.10.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
