Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f71.google.com (mail-pg0-f71.google.com [74.125.83.71])
	by kanga.kvack.org (Postfix) with ESMTP id 6B1A16B02FA
	for <linux-mm@kvack.org>; Mon, 28 Aug 2017 17:35:22 -0400 (EDT)
Received: by mail-pg0-f71.google.com with SMTP id t3so2552873pgt.8
        for <linux-mm@kvack.org>; Mon, 28 Aug 2017 14:35:22 -0700 (PDT)
Received: from mail-pg0-x233.google.com (mail-pg0-x233.google.com. [2607:f8b0:400e:c05::233])
        by mx.google.com with ESMTPS id 5si1062339plx.114.2017.08.28.14.35.21
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 28 Aug 2017 14:35:21 -0700 (PDT)
Received: by mail-pg0-x233.google.com with SMTP id t3so5023746pgt.0
        for <linux-mm@kvack.org>; Mon, 28 Aug 2017 14:35:21 -0700 (PDT)
From: Kees Cook <keescook@chromium.org>
Subject: [PATCH v2 06/30] vfs: Copy struct mount.mnt_id to userspace using put_user()
Date: Mon, 28 Aug 2017 14:34:47 -0700
Message-Id: <1503956111-36652-7-git-send-email-keescook@chromium.org>
In-Reply-To: <1503956111-36652-1-git-send-email-keescook@chromium.org>
References: <1503956111-36652-1-git-send-email-keescook@chromium.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: Kees Cook <keescook@chromium.org>, David Windsor <dave@nullcore.net>, Alexander Viro <viro@zeniv.linux.org.uk>, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, kernel-hardening@lists.openwall.com

From: David Windsor <dave@nullcore.net>

The mnt_id field can be copied with put_user(), so there is no need to
use copy_to_user(). In both cases, hardened usercopy is being bypassed
since the size is constant, and not open to runtime manipulation.

This patch is verbatim from Brad Spengler/PaX Team's PAX_USERCOPY
whitelisting code in the last public patch of grsecurity/PaX based on my
understanding of the code. Changes or omissions from the original code are
mine and don't reflect the original grsecurity/PaX code.

Signed-off-by: David Windsor <dave@nullcore.net>
[kees: adjust commit log]
Cc: Alexander Viro <viro@zeniv.linux.org.uk>
Cc: linux-fsdevel@vger.kernel.org
Signed-off-by: Kees Cook <keescook@chromium.org>
---
 fs/fhandle.c | 3 +--
 1 file changed, 1 insertion(+), 2 deletions(-)

diff --git a/fs/fhandle.c b/fs/fhandle.c
index 58a61f55e0d0..46e00ccca8f0 100644
--- a/fs/fhandle.c
+++ b/fs/fhandle.c
@@ -68,8 +68,7 @@ static long do_sys_name_to_handle(struct path *path,
 	} else
 		retval = 0;
 	/* copy the mount id */
-	if (copy_to_user(mnt_id, &real_mount(path->mnt)->mnt_id,
-			 sizeof(*mnt_id)) ||
+	if (put_user(real_mount(path->mnt)->mnt_id, mnt_id) ||
 	    copy_to_user(ufh, handle,
 			 sizeof(struct file_handle) + handle_bytes))
 		retval = -EFAULT;
-- 
2.7.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
