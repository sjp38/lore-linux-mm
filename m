Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f72.google.com (mail-lf0-f72.google.com [209.85.215.72])
	by kanga.kvack.org (Postfix) with ESMTP id 84F1B6B0268
	for <linux-mm@kvack.org>; Tue, 24 May 2016 04:49:52 -0400 (EDT)
Received: by mail-lf0-f72.google.com with SMTP id k186so5527437lfe.3
        for <linux-mm@kvack.org>; Tue, 24 May 2016 01:49:52 -0700 (PDT)
Received: from EUR01-VE1-obe.outbound.protection.outlook.com (mail-ve1eur01on0096.outbound.protection.outlook.com. [104.47.1.96])
        by mx.google.com with ESMTPS id 71si22108338wmr.122.2016.05.24.01.49.46
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Tue, 24 May 2016 01:49:46 -0700 (PDT)
From: Vladimir Davydov <vdavydov@virtuozzo.com>
Subject: [PATCH RESEND 7/8] pipe: account to kmemcg
Date: Tue, 24 May 2016 11:49:29 +0300
Message-ID: <2c2545563b6201f118946f96dd8cfc90e564aff6.1464079538.git.vdavydov@virtuozzo.com>
In-Reply-To: <cover.1464079537.git.vdavydov@virtuozzo.com>
References: <cover.1464079537.git.vdavydov@virtuozzo.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Alexander Viro <viro@zeniv.linux.org.uk>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@kernel.org>, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, netdev@vger.kernel.org, x86@kernel.org, linux-kernel@vger.kernel.org

Pipes can consume a significant amount of system memory, hence they
should be accounted to kmemcg.

This patch marks pipe_inode_info and anonymous pipe buffer page
allocations as __GFP_ACCOUNT so that they would be charged to kmemcg.
Note, since a pipe buffer page can be "stolen" and get reused for other
purposes, including mapping to userspace, we clear PageKmemcg thus
resetting page->_mapcount and uncharge it in anon_pipe_buf_steal, which
is introduced by this patch.

Signed-off-by: Vladimir Davydov <vdavydov@virtuozzo.com>
Cc: Alexander Viro <viro@zeniv.linux.org.uk>
---
 fs/pipe.c | 32 ++++++++++++++++++++++++++------
 1 file changed, 26 insertions(+), 6 deletions(-)

diff --git a/fs/pipe.c b/fs/pipe.c
index 0d3f5165cb0b..4b32928f5426 100644
--- a/fs/pipe.c
+++ b/fs/pipe.c
@@ -21,6 +21,7 @@
 #include <linux/audit.h>
 #include <linux/syscalls.h>
 #include <linux/fcntl.h>
+#include <linux/memcontrol.h>
 
 #include <asm/uaccess.h>
 #include <asm/ioctls.h>
@@ -137,6 +138,22 @@ static void anon_pipe_buf_release(struct pipe_inode_info *pipe,
 		put_page(page);
 }
 
+static int anon_pipe_buf_steal(struct pipe_inode_info *pipe,
+			       struct pipe_buffer *buf)
+{
+	struct page *page = buf->page;
+
+	if (page_count(page) == 1) {
+		if (memcg_kmem_enabled()) {
+			memcg_kmem_uncharge(page, 0);
+			__ClearPageKmemcg(page);
+		}
+		__SetPageLocked(page);
+		return 0;
+	}
+	return 1;
+}
+
 /**
  * generic_pipe_buf_steal - attempt to take ownership of a &pipe_buffer
  * @pipe:	the pipe that the buffer belongs to
@@ -219,7 +236,7 @@ static const struct pipe_buf_operations anon_pipe_buf_ops = {
 	.can_merge = 1,
 	.confirm = generic_pipe_buf_confirm,
 	.release = anon_pipe_buf_release,
-	.steal = generic_pipe_buf_steal,
+	.steal = anon_pipe_buf_steal,
 	.get = generic_pipe_buf_get,
 };
 
@@ -227,7 +244,7 @@ static const struct pipe_buf_operations packet_pipe_buf_ops = {
 	.can_merge = 0,
 	.confirm = generic_pipe_buf_confirm,
 	.release = anon_pipe_buf_release,
-	.steal = generic_pipe_buf_steal,
+	.steal = anon_pipe_buf_steal,
 	.get = generic_pipe_buf_get,
 };
 
@@ -405,7 +422,7 @@ pipe_write(struct kiocb *iocb, struct iov_iter *from)
 			int copied;
 
 			if (!page) {
-				page = alloc_page(GFP_HIGHUSER);
+				page = alloc_page(GFP_HIGHUSER | __GFP_ACCOUNT);
 				if (unlikely(!page)) {
 					ret = ret ? : -ENOMEM;
 					break;
@@ -611,7 +628,7 @@ struct pipe_inode_info *alloc_pipe_info(void)
 {
 	struct pipe_inode_info *pipe;
 
-	pipe = kzalloc(sizeof(struct pipe_inode_info), GFP_KERNEL);
+	pipe = kzalloc(sizeof(struct pipe_inode_info), GFP_KERNEL_ACCOUNT);
 	if (pipe) {
 		unsigned long pipe_bufs = PIPE_DEF_BUFFERS;
 		struct user_struct *user = get_current_user();
@@ -619,7 +636,9 @@ struct pipe_inode_info *alloc_pipe_info(void)
 		if (!too_many_pipe_buffers_hard(user)) {
 			if (too_many_pipe_buffers_soft(user))
 				pipe_bufs = 1;
-			pipe->bufs = kzalloc(sizeof(struct pipe_buffer) * pipe_bufs, GFP_KERNEL);
+			pipe->bufs = kcalloc(pipe_bufs,
+					     sizeof(struct pipe_buffer),
+					     GFP_KERNEL_ACCOUNT);
 		}
 
 		if (pipe->bufs) {
@@ -1010,7 +1029,8 @@ static long pipe_set_size(struct pipe_inode_info *pipe, unsigned long nr_pages)
 	if (nr_pages < pipe->nrbufs)
 		return -EBUSY;
 
-	bufs = kcalloc(nr_pages, sizeof(*bufs), GFP_KERNEL | __GFP_NOWARN);
+	bufs = kcalloc(nr_pages, sizeof(*bufs),
+		       GFP_KERNEL_ACCOUNT | __GFP_NOWARN);
 	if (unlikely(!bufs))
 		return -ENOMEM;
 
-- 
2.1.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
