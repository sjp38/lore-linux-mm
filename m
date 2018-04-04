Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f198.google.com (mail-qk0-f198.google.com [209.85.220.198])
	by kanga.kvack.org (Postfix) with ESMTP id 4241D6B0005
	for <linux-mm@kvack.org>; Wed,  4 Apr 2018 15:19:01 -0400 (EDT)
Received: by mail-qk0-f198.google.com with SMTP id q185so15491541qke.0
        for <linux-mm@kvack.org>; Wed, 04 Apr 2018 12:19:01 -0700 (PDT)
Received: from mx1.redhat.com (mx3-rdu2.redhat.com. [66.187.233.73])
        by mx.google.com with ESMTPS id t19si4470722qtb.327.2018.04.04.12.19.00
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 04 Apr 2018 12:19:00 -0700 (PDT)
From: jglisse@redhat.com
Subject: [RFC PATCH 04/79] pipe: add inode field to struct pipe_inode_info
Date: Wed,  4 Apr 2018 15:17:51 -0400
Message-Id: <20180404191831.5378-2-jglisse@redhat.com>
In-Reply-To: <20180404191831.5378-1-jglisse@redhat.com>
References: <20180404191831.5378-1-jglisse@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, linux-block@vger.kernel.org
Cc: linux-kernel@vger.kernel.org, =?UTF-8?q?J=C3=A9r=C3=B4me=20Glisse?= <jglisse@redhat.com>, Eric Biggers <ebiggers@google.com>, Kees Cook <keescook@chromium.org>, Joe Lawrence <joe.lawrence@redhat.com>, Willy Tarreau <w@1wt.eu>, Andrew Morton <akpm@linux-foundation.org>, Tejun Heo <tj@kernel.org>, Jan Kara <jack@suse.cz>, Josef Bacik <jbacik@fb.com>, Mel Gorman <mgorman@techsingularity.net>, Jeff Layton <jlayton@redhat.com>

From: JA(C)rA'me Glisse <jglisse@redhat.com>

Pipes are associated with a file and thus an inode, store a pointer
back to the inode in struct pipe_inode_info, this will be use when
testing pages haven't been truncated.

Signed-off-by: JA(C)rA'me Glisse <jglisse@redhat.com>
Cc: Eric Biggers <ebiggers@google.com>
Cc: Kees Cook <keescook@chromium.org>
Cc: Joe Lawrence <joe.lawrence@redhat.com>
Cc: Willy Tarreau <w@1wt.eu>
Cc: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-fsdevel@vger.kernel.org
Cc: Tejun Heo <tj@kernel.org>
Cc: Jan Kara <jack@suse.cz>
Cc: Josef Bacik <jbacik@fb.com>
Cc: Mel Gorman <mgorman@techsingularity.net>
Cc: Jeff Layton <jlayton@redhat.com>
---
 fs/pipe.c                 | 2 ++
 fs/splice.c               | 1 +
 include/linux/pipe_fs_i.h | 2 ++
 3 files changed, 5 insertions(+)

diff --git a/fs/pipe.c b/fs/pipe.c
index 7b1954caf388..41e115b0bde7 100644
--- a/fs/pipe.c
+++ b/fs/pipe.c
@@ -715,6 +715,7 @@ static struct inode * get_pipe_inode(void)
 
 	inode->i_pipe = pipe;
 	pipe->files = 2;
+	pipe->inode = inode;
 	pipe->readers = pipe->writers = 1;
 	inode->i_fop = &pipefifo_fops;
 
@@ -903,6 +904,7 @@ static int fifo_open(struct inode *inode, struct file *filp)
 		pipe = alloc_pipe_info();
 		if (!pipe)
 			return -ENOMEM;
+		pipe->inode = inode;
 		pipe->files = 1;
 		spin_lock(&inode->i_lock);
 		if (unlikely(inode->i_pipe)) {
diff --git a/fs/splice.c b/fs/splice.c
index 39e2dc01ac12..acab52a7fe56 100644
--- a/fs/splice.c
+++ b/fs/splice.c
@@ -927,6 +927,7 @@ ssize_t splice_direct_to_actor(struct file *in, struct splice_desc *sd,
 		 * PIPE_READERS appropriately.
 		 */
 		pipe->readers = 1;
+		pipe->inode = file_inode(in);
 
 		current->splice_pipe = pipe;
 	}
diff --git a/include/linux/pipe_fs_i.h b/include/linux/pipe_fs_i.h
index 5a3bb3b7c9ad..171aa78ebbf0 100644
--- a/include/linux/pipe_fs_i.h
+++ b/include/linux/pipe_fs_i.h
@@ -44,6 +44,7 @@ struct pipe_buffer {
  *	@fasync_writers: writer side fasync
  *	@bufs: the circular array of pipe buffers
  *	@user: the user who created this pipe
+ *	@inode: inode this pipe is associated to
  **/
 struct pipe_inode_info {
 	struct mutex mutex;
@@ -60,6 +61,7 @@ struct pipe_inode_info {
 	struct fasync_struct *fasync_writers;
 	struct pipe_buffer *bufs;
 	struct user_struct *user;
+	struct inode *inode;
 };
 
 /*
-- 
2.14.3
