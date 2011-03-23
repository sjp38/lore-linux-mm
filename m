Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with ESMTP id 2B8F28D0040
	for <linux-mm@kvack.org>; Tue, 22 Mar 2011 22:06:03 -0400 (EDT)
Received: by yib2 with SMTP id 2so4150062yib.14
        for <linux-mm@kvack.org>; Tue, 22 Mar 2011 19:05:57 -0700 (PDT)
From: Valerie Aurora <valerie.aurora@gmail.com>
Subject: [PATCH 59/74] fallthru: tmpfs support for lookup of d_type/d_ino in fallthrus
Date: Tue, 22 Mar 2011 19:04:50 -0700
Message-Id: <1300845905-14433-16-git-send-email-valerie.aurora@gmail.com>
In-Reply-To: <1300845905-14433-1-git-send-email-valerie.aurora@gmail.com>
References: <1300845905-14433-1-git-send-email-valerie.aurora@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-fsdevel@vger.kernel.org, linux@vger.kernel.org
Cc: viro@zeniv.linux.org.uk, Valerie Aurora <vaurora@redhat.com>, Hugh Dickins <hughd@google.com>, linux-mm@kvack.org, Valerie Aurora <valerie.aurora@gmail.com>

From: Valerie Aurora <vaurora@redhat.com>

Now that we have full union lookup support, lookup the true d_type and
d_ino of a fallthru.

Cc: Hugh Dickins <hughd@google.com>
Cc: linux-mm@kvack.org
Signed-off-by: Valerie Aurora <valerie.aurora@gmail.com>
---
 fs/libfs.c |   11 ++++++++---
 1 files changed, 8 insertions(+), 3 deletions(-)

diff --git a/fs/libfs.c b/fs/libfs.c
index a73423d..8453c75 100644
--- a/fs/libfs.c
+++ b/fs/libfs.c
@@ -132,6 +132,7 @@ int dcache_readdir(struct file * filp, void * dirent, filldir_t filldir)
 	ino_t ino;
 	char d_type;
 	int i = filp->f_pos;
+	int err = 0;
 
 	switch (i) {
 		case 0:
@@ -161,9 +162,13 @@ int dcache_readdir(struct file * filp, void * dirent, filldir_t filldir)
 
 				spin_unlock(&dcache_lock);
 				if (d_is_fallthru(next)) {
-					/* XXX placeholder until generic_readdir_fallthru() arrives */
-					ino = 1;
-					d_type = DT_UNKNOWN;
+					/* On tmpfs, should only fail with ENOMEM, EIO, etc. */
+					err = generic_readdir_fallthru(filp->f_path.dentry,
+								       next->d_name.name,
+								       next->d_name.len,
+								       &ino, &d_type);
+					if (err)
+						return err;
 				} else {
 					ino = next->d_inode->i_ino;
 					d_type = dt_type(next->d_inode);
-- 
1.7.0.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
