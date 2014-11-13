Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f172.google.com (mail-wi0-f172.google.com [209.85.212.172])
	by kanga.kvack.org (Postfix) with ESMTP id 77A6F6B00E3
	for <linux-mm@kvack.org>; Thu, 13 Nov 2014 16:31:30 -0500 (EST)
Received: by mail-wi0-f172.google.com with SMTP id bs8so919351wib.5
        for <linux-mm@kvack.org>; Thu, 13 Nov 2014 13:31:29 -0800 (PST)
Received: from mail-wg0-x236.google.com (mail-wg0-x236.google.com. [2a00:1450:400c:c00::236])
        by mx.google.com with ESMTPS id he2si807935wib.94.2014.11.13.13.31.29
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Thu, 13 Nov 2014 13:31:29 -0800 (PST)
Received: by mail-wg0-f54.google.com with SMTP id n12so18154846wgh.41
        for <linux-mm@kvack.org>; Thu, 13 Nov 2014 13:31:29 -0800 (PST)
From: Pieter Smith <pieter@boesman.nl>
Subject: [PATCH 48/56] mm/shmem: support compiling out splice
Date: Thu, 13 Nov 2014 22:23:25 +0100
Message-Id: <1415913813-362-49-git-send-email-pieter@boesman.nl>
In-Reply-To: <1415913813-362-1-git-send-email-pieter@boesman.nl>
References: <pieter@boesman.nl>
 <1415913813-362-1-git-send-email-pieter@boesman.nl>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: pieter@boesman.nl
Cc: Josh Triplett <josh@joshtriplett.org>, Hugh Dickins <hughd@google.com>, linux-mm@kvack.org, open list <linux-kernel@vger.kernel.org>

Compile out splice support from shmem when the splice-family of syscalls is not
supported by the system (i.e. CONFIG_SYSCALL_SPLICE is undefined).

Signed-off-by: Pieter Smith <pieter@boesman.nl>
---
 mm/shmem.c | 6 ++++--
 1 file changed, 4 insertions(+), 2 deletions(-)

diff --git a/mm/shmem.c b/mm/shmem.c
index 0e5fb22..4fb78b3 100644
--- a/mm/shmem.c
+++ b/mm/shmem.c
@@ -1626,6 +1626,7 @@ static ssize_t shmem_file_read_iter(struct kiocb *iocb, struct iov_iter *to)
 	return retval ? retval : error;
 }
 
+#ifdef CONFIG_SYSCALL_SPLICE
 static ssize_t shmem_file_splice_read(struct file *in, loff_t *ppos,
 				struct pipe_inode_info *pipe, size_t len,
 				unsigned int flags)
@@ -1739,6 +1740,7 @@ static ssize_t shmem_file_splice_read(struct file *in, loff_t *ppos,
 	}
 	return error;
 }
+#endif /* #ifdef CONFIG_SYSCALL_SPLICE */
 
 /*
  * llseek SEEK_DATA or SEEK_HOLE through the radix_tree.
@@ -3088,8 +3090,8 @@ static const struct file_operations shmem_file_operations = {
 	.read_iter	= shmem_file_read_iter,
 	.write_iter	= generic_file_write_iter,
 	.fsync		= noop_fsync,
-	.splice_read	= shmem_file_splice_read,
-	.splice_write	= iter_file_splice_write,
+	SPLICE_READ_INIT(shmem_file_splice_read)
+	SPLICE_WRITE_INIT(iter_file_splice_write)
 	.fallocate	= shmem_fallocate,
 #endif
 };
-- 
1.9.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
