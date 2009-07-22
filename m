Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id CCB776B00D6
	for <linux-mm@kvack.org>; Wed, 22 Jul 2009 06:10:30 -0400 (EDT)
From: Oren Laadan <orenl@librato.com>
Subject: [RFC v17][PATCH 59/60] c/r: restore file->f_cred
Date: Wed, 22 Jul 2009 06:00:21 -0400
Message-Id: <1248256822-23416-60-git-send-email-orenl@librato.com>
In-Reply-To: <1248256822-23416-1-git-send-email-orenl@librato.com>
References: <1248256822-23416-1-git-send-email-orenl@librato.com>
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Linus Torvalds <torvalds@osdl.org>, containers@lists.linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-api@vger.kernel.org, Serge Hallyn <serue@us.ibm.com>, Dave Hansen <dave@linux.vnet.ibm.com>, Ingo Molnar <mingo@elte.hu>, "H. Peter Anvin" <hpa@zytor.com>, Alexander Viro <viro@zeniv.linux.org.uk>, Pavel Emelyanov <xemul@openvz.org>, Alexey Dobriyan <adobriyan@gmail.com>
List-ID: <linux-mm.kvack.org>

From: Serge E. Hallyn <serue@us.ibm.com>

Restore a file's f_cred.  This is set to the cred of the task doing
the open, so often it will be the same as that of the restarted task.

Signed-off-by: Serge E. Hallyn <serue@us.ibm.com>
---
 checkpoint/files.c             |   16 ++++++++++++++--
 include/linux/checkpoint_hdr.h |    2 +-
 2 files changed, 15 insertions(+), 3 deletions(-)

diff --git a/checkpoint/files.c b/checkpoint/files.c
index c247d44..bcdc774 100644
--- a/checkpoint/files.c
+++ b/checkpoint/files.c
@@ -150,7 +150,11 @@ int checkpoint_file_common(struct ckpt_ctx *ctx, struct file *file,
 	h->f_pos = file->f_pos;
 	h->f_version = file->f_version;
 
-	/* FIX: need also file->uid, file->gid, file->f_owner, etc */
+	h->f_credref = checkpoint_obj(ctx, file->f_cred, CKPT_OBJ_CRED);
+	if (h->f_credref < 0)
+		return h->f_credref;
+
+	/* FIX: need also file->f_owner, etc */
 
 	return 0;
 }
@@ -454,8 +458,16 @@ int restore_file_common(struct ckpt_ctx *ctx, struct file *file,
 	fmode_t new_mode = (__force fmode_t) file->f_mode;
 	fmode_t saved_mode = (__force fmode_t) h->f_mode;
 	int ret;
+	struct cred *cred;
+
+	/* FIX: need to restore owner etc */
 
-	/* FIX: need to restore uid, gid, owner etc */
+	/* restore the cred */
+	cred = ckpt_obj_fetch(ctx, h->f_credref, CKPT_OBJ_CRED);
+	if (IS_ERR(cred))
+		return PTR_ERR(cred);
+	put_cred(file->f_cred);
+	file->f_cred = get_cred(cred);
 
 	/* safe to set 1st arg (fd) to 0, as command is F_SETFL */
 	ret = vfs_fcntl(0, F_SETFL, h->f_flags & CKPT_SETFL_MASK, file);
diff --git a/include/linux/checkpoint_hdr.h b/include/linux/checkpoint_hdr.h
index ca02d9d..0863a07 100644
--- a/include/linux/checkpoint_hdr.h
+++ b/include/linux/checkpoint_hdr.h
@@ -329,7 +329,7 @@ struct ckpt_hdr_file {
 	__u32 f_type;
 	__u32 f_mode;
 	__u32 f_flags;
-	__u32 _padding;
+	__s32 f_credref;
 	__u64 f_pos;
 	__u64 f_version;
 } __attribute__((aligned(8)));
-- 
1.6.0.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
