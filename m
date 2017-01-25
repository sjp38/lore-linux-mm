Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f69.google.com (mail-pg0-f69.google.com [74.125.83.69])
	by kanga.kvack.org (Postfix) with ESMTP id 3206E6B026F
	for <linux-mm@kvack.org>; Wed, 25 Jan 2017 16:07:07 -0500 (EST)
Received: by mail-pg0-f69.google.com with SMTP id f5so285899570pgi.1
        for <linux-mm@kvack.org>; Wed, 25 Jan 2017 13:07:07 -0800 (PST)
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.136])
        by mx.google.com with ESMTPS id p25si2704723pli.325.2017.01.25.13.07.06
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 25 Jan 2017 13:07:06 -0800 (PST)
From: Andy Lutomirski <luto@kernel.org>
Subject: [PATCH 2/2] fs: Harden against open(..., O_CREAT, 02777) in a setgid directory
Date: Wed, 25 Jan 2017 13:06:52 -0800
Message-Id: <826ec4aab64ec304944098d15209f8c1ae65bb29.1485377903.git.luto@kernel.org>
In-Reply-To: <cover.1485377903.git.luto@kernel.org>
References: <cover.1485377903.git.luto@kernel.org>
In-Reply-To: <cover.1485377903.git.luto@kernel.org>
References: <cover.1485377903.git.luto@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: security@kernel.org
Cc: Konstantin Khlebnikov <koct9i@gmail.com>, Alexander Viro <viro@zeniv.linux.org.uk>, Kees Cook <keescook@chromium.org>, Willy Tarreau <w@1wt.eu>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, yalin wang <yalin.wang2010@gmail.com>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Jan Kara <jack@suse.cz>, Linux FS Devel <linux-fsdevel@vger.kernel.org>, Andy Lutomirski <luto@kernel.org>

Currently, if you open("foo", O_WRONLY | O_CREAT | ..., 02777) in a
directory that is setgid and owned by a different gid than current's
fsgid, you end up with an SGID executable that is owned by the
directory's GID.  This is a Bad Thing (tm).  Exploiting this is
nontrivial because most ways of creating a new file create an empty
file and empty executables aren't particularly interesting, but this
is nevertheless quite dangerous.

Harden against this type of attack by detecting this particular
corner case (unprivileged program creates SGID executable inode in
SGID directory owned by a different GID) and clearing the new
inode's SGID bit.

Signed-off-by: Andy Lutomirski <luto@kernel.org>
---
 fs/inode.c | 21 +++++++++++++++++++--
 1 file changed, 19 insertions(+), 2 deletions(-)

diff --git a/fs/inode.c b/fs/inode.c
index f7029c40cfbd..d7e4b80470dd 100644
--- a/fs/inode.c
+++ b/fs/inode.c
@@ -2007,11 +2007,28 @@ void inode_init_owner(struct inode *inode, const struct inode *dir,
 {
 	inode->i_uid = current_fsuid();
 	if (dir && dir->i_mode & S_ISGID) {
+		bool changing_gid = !gid_eq(inode->i_gid, dir->i_gid);
+
 		inode->i_gid = dir->i_gid;
-		if (S_ISDIR(mode))
+		if (S_ISDIR(mode)) {
 			mode |= S_ISGID;
-	} else
+		} else if (((mode & (S_ISGID | S_IXGRP)) == (S_ISGID | S_IXGRP))
+			   && S_ISREG(mode) && changing_gid
+			   && !capable(CAP_FSETID)) {
+			/*
+			 * Whoa there!  An unprivileged program just
+			 * tried to create a new executable with SGID
+			 * set in a directory with SGID set that belongs
+			 * to a different group.  Don't let this program
+			 * create a SGID executable that ends up owned
+			 * by the wrong group.
+			 */
+			mode &= ~S_ISGID;
+		}
+
+	} else {
 		inode->i_gid = current_fsgid();
+	}
 	inode->i_mode = mode;
 }
 EXPORT_SYMBOL(inode_init_owner);
-- 
2.9.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
