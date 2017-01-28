Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f72.google.com (mail-pg0-f72.google.com [74.125.83.72])
	by kanga.kvack.org (Postfix) with ESMTP id 290ED6B025E
	for <linux-mm@kvack.org>; Fri, 27 Jan 2017 21:49:46 -0500 (EST)
Received: by mail-pg0-f72.google.com with SMTP id 204so375602638pge.5
        for <linux-mm@kvack.org>; Fri, 27 Jan 2017 18:49:46 -0800 (PST)
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.136])
        by mx.google.com with ESMTPS id b26si3309964pgf.332.2017.01.27.18.49.45
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 27 Jan 2017 18:49:45 -0800 (PST)
From: Andy Lutomirski <luto@kernel.org>
Subject: [PATCH v2 2/2] fs: Harden against open(..., O_CREAT, 02777) in a setgid directory
Date: Fri, 27 Jan 2017 18:49:32 -0800
Message-Id: <99f64a2676f0bec4ad32e39fc76eb0914ee091b8.1485571668.git.luto@kernel.org>
In-Reply-To: <cover.1485571668.git.luto@kernel.org>
References: <cover.1485571668.git.luto@kernel.org>
In-Reply-To: <cover.1485571668.git.luto@kernel.org>
References: <cover.1485571668.git.luto@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: security@kernel.org
Cc: Konstantin Khlebnikov <koct9i@gmail.com>, Alexander Viro <viro@zeniv.linux.org.uk>, Kees Cook <keescook@chromium.org>, Willy Tarreau <w@1wt.eu>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, yalin wang <yalin.wang2010@gmail.com>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Jan Kara <jack@suse.cz>, Linux FS Devel <linux-fsdevel@vger.kernel.org>, Frank Filz <ffilzlnx@mindspring.com>, Andy Lutomirski <luto@kernel.org>, stable@vger.kernel.org

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

Cc: stable@vger.kernel.org
Signed-off-by: Andy Lutomirski <luto@kernel.org>
---
 fs/inode.c | 24 +++++++++++++++++++++---
 1 file changed, 21 insertions(+), 3 deletions(-)

diff --git a/fs/inode.c b/fs/inode.c
index 0e1e141b094c..f6acb9232263 100644
--- a/fs/inode.c
+++ b/fs/inode.c
@@ -2025,12 +2025,30 @@ void inode_init_owner(struct inode *inode, const struct inode *dir,
 			umode_t mode)
 {
 	inode->i_uid = current_fsuid();
+	inode->i_gid = current_fsgid();
+
 	if (dir && dir->i_mode & S_ISGID) {
+		bool changing_gid = !gid_eq(inode->i_gid, dir->i_gid);
+
 		inode->i_gid = dir->i_gid;
-		if (S_ISDIR(mode))
+
+		if (S_ISDIR(mode)) {
 			mode |= S_ISGID;
-	} else
-		inode->i_gid = current_fsgid();
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
+	}
+
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
