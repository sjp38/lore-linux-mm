Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-bk0-f53.google.com (mail-bk0-f53.google.com [209.85.214.53])
	by kanga.kvack.org (Postfix) with ESMTP id 1E0956B016F
	for <linux-mm@kvack.org>; Wed, 19 Mar 2014 15:07:53 -0400 (EDT)
Received: by mail-bk0-f53.google.com with SMTP id r7so631909bkg.26
        for <linux-mm@kvack.org>; Wed, 19 Mar 2014 12:07:52 -0700 (PDT)
Received: from mail-bk0-x235.google.com (mail-bk0-x235.google.com [2a00:1450:4008:c01::235])
        by mx.google.com with ESMTPS id cn4si10030525bkc.146.2014.03.19.12.07.51
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Wed, 19 Mar 2014 12:07:51 -0700 (PDT)
Received: by mail-bk0-f53.google.com with SMTP id r7so633629bkg.40
        for <linux-mm@kvack.org>; Wed, 19 Mar 2014 12:07:51 -0700 (PDT)
From: David Herrmann <dh.herrmann@gmail.com>
Subject: [PATCH 1/6] fs: fix i_writecount on shmem and friends
Date: Wed, 19 Mar 2014 20:06:46 +0100
Message-Id: <1395256011-2423-2-git-send-email-dh.herrmann@gmail.com>
In-Reply-To: <1395256011-2423-1-git-send-email-dh.herrmann@gmail.com>
References: <1395256011-2423-1-git-send-email-dh.herrmann@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: Hugh Dickins <hughd@google.com>, Alexander Viro <viro@zeniv.linux.org.uk>, Matthew Wilcox <matthew@wil.cx>, Karol Lewandowski <k.lewandowsk@samsung.com>, Kay Sievers <kay@vrfy.org>, Daniel Mack <zonque@gmail.com>, Lennart Poettering <lennart@poettering.net>, =?UTF-8?q?Kristian=20H=C3=B8gsberg?= <krh@bitplanet.net>, john.stultz@linaro.org, Greg Kroah-Hartman <greg@kroah.com>, Tejun Heo <tj@kernel.org>, Johannes Weiner <hannes@cmpxchg.org>, dri-devel@lists.freedesktop.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>, Ryan Lortie <desrt@desrt.ca>, "Michael Kerrisk (man-pages)" <mtk.manpages@gmail.com>, David Herrmann <dh.herrmann@gmail.com>

VM_DENYWRITE currently relies on i_writecount. Unless there's an active
writable reference to an inode, VM_DENYWRITE is not allowed.
Unfortunately, alloc_file() does not increase i_writecount, therefore,
does not prevent a following VM_DENYWRITE even though the new file might
have been opened with FMODE_WRITE. However, callers of alloc_file() expect
the file object to be fully instantiated so they can call fput() on it. We
could now either fix all callers to do an get_write_access() if opened
with FMODE_WRITE, or simply fix alloc_file() to do that. I chose the
latter.

Note that this bug allows some rather subtle misbehavior. The following
sequence of calls should work just fine, but currently fails:
    int p[2], orig, ro, rw;
    char buf[128];

    pipe(p);
    sprintf(buf, "/proc/self/fd/%d", p[1]);
    ro = open(buf, O_RDONLY);
    close(p[1]);
    sprintf(buf, "/proc/self/fd/%d", ro);
    rw = open(buf, O_RDWR);

The final open() cannot succeed as close(p[1]) caused an integer underflow
on i_writecount, effectively causing VM_DENYWRITE on the inode. The open
will fail with -ETXTBUSY.

It's a rather odd sequence of calls and given that open() doesn't use
alloc_file() (and thus not affected by this bug), it's rather unlikely
that this is a serious issue. But stuff like anon_inode shares a *single*
inode across a huge set of interfaces. If any of these is broken like
pipe(), it will affect all of these (ranging from dma-buf to epoll).

Signed-off-by: David Herrmann <dh.herrmann@gmail.com>
---
Hi

This patch is only included for reference. It was submitted to fs-devel
separately and is being worked on. However, this bug must be fixed in order to
make use of memfd_create(), so I decided to include it here.

David

 fs/file_table.c | 27 ++++++++++++++++++---------
 1 file changed, 18 insertions(+), 9 deletions(-)

diff --git a/fs/file_table.c b/fs/file_table.c
index 5b24008..8059d68 100644
--- a/fs/file_table.c
+++ b/fs/file_table.c
@@ -168,6 +168,7 @@ struct file *alloc_file(struct path *path, fmode_t mode,
 		const struct file_operations *fop)
 {
 	struct file *file;
+	int error;
 
 	file = get_empty_filp();
 	if (IS_ERR(file))
@@ -179,15 +180,23 @@ struct file *alloc_file(struct path *path, fmode_t mode,
 	file->f_mode = mode;
 	file->f_op = fop;
 
-	/*
-	 * These mounts don't really matter in practice
-	 * for r/o bind mounts.  They aren't userspace-
-	 * visible.  We do this for consistency, and so
-	 * that we can do debugging checks at __fput()
-	 */
-	if ((mode & FMODE_WRITE) && !special_file(path->dentry->d_inode->i_mode)) {
-		file_take_write(file);
-		WARN_ON(mnt_clone_write(path->mnt));
+	if (mode & FMODE_WRITE) {
+		error = get_write_access(path->dentry->d_inode);
+		if (error) {
+			put_filp(file);
+			return ERR_PTR(error);
+		}
+
+		/*
+		 * These mounts don't really matter in practice
+		 * for r/o bind mounts.  They aren't userspace-
+		 * visible.  We do this for consistency, and so
+		 * that we can do debugging checks at __fput()
+		 */
+		if (!special_file(path->dentry->d_inode->i_mode)) {
+			file_take_write(file);
+			WARN_ON(mnt_clone_write(path->mnt));
+		}
 	}
 	if ((mode & (FMODE_READ | FMODE_WRITE)) == FMODE_READ)
 		i_readcount_inc(path->dentry->d_inode);
-- 
1.9.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
