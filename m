Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id 8980B6B003D
	for <linux-mm@kvack.org>; Fri,  4 Dec 2009 15:48:45 -0500 (EST)
From: Eric Paris <eparis@redhat.com>
Subject: [RFC PATCH 14/15] security: move ima_file_check() to lsm hook
Date: Fri, 04 Dec 2009 15:48:32 -0500
Message-ID: <20091204204832.18286.19016.stgit@paris.rdu.redhat.com>
In-Reply-To: <20091204204646.18286.24853.stgit@paris.rdu.redhat.com>
References: <20091204204646.18286.24853.stgit@paris.rdu.redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org
Cc: viro@zeniv.linux.org.uk, jmorris@namei.org, npiggin@suse.de, eparis@redhat.com, zohar@us.ibm.com, jack@suse.cz, jmalicki@metacarta.com, dsmith@redhat.com, serue@us.ibm.com, hch@lst.de, john@johnmccutchan.com, rlove@rlove.org, ebiederm@xmission.com, heiko.carstens@de.ibm.com, penguin-kernel@I-love.SAKURA.ne.jp, mszeredi@suse.cz, jens.axboe@oracle.com, akpm@linux-foundation.org, matthew@wil.cx, hugh.dickins@tiscali.co.uk, kamezawa.hiroyu@jp.fujitsu.com, nishimura@mxp.nes.nec.co.jp, davem@davemloft.net, arnd@arndb.de, eric.dumazet@gmail.com
List-ID: <linux-mm.kvack.org>

From: Mimi Zohar <zohar@linux.vnet.ibm.com>

Move the ima_file_check() hook from the vfs into the LSM hook.

Signed-off-by: Mimi Zohar <zohar@linux.vnet.ibm.com>
Signed-off-by: Eric Paris <eparis@redhat.com>
---

 fs/open.c           |    7 -------
 security/security.c |    8 +++++++-
 2 files changed, 7 insertions(+), 8 deletions(-)

diff --git a/fs/open.c b/fs/open.c
index 10bd04e..25c1436 100644
--- a/fs/open.c
+++ b/fs/open.c
@@ -30,7 +30,6 @@
 #include <linux/audit.h>
 #include <linux/falloc.h>
 #include <linux/fs_struct.h>
-#include <linux/ima.h>
 
 #include "internal.h"
 
@@ -875,12 +874,6 @@ static struct file *__dentry_open(struct dentry *dentry, struct vfsmount *mnt,
 		}
 	}
 
-	error = ima_file_check(f);
-	if (error) {
-		fput(f);
-		f = ERR_PTR(error);
-	}
-
 	return f;
 
 cleanup_all:
diff --git a/security/security.c b/security/security.c
index fd2d450..a42586b 100644
--- a/security/security.c
+++ b/security/security.c
@@ -722,7 +722,13 @@ int security_file_receive(struct file *file)
 
 int security_dentry_open(struct file *file, const struct cred *cred)
 {
-	return security_ops->dentry_open(file, cred);
+	int ret;
+
+	ret = security_ops->dentry_open(file, cred);
+	if (ret)
+		return ret;
+
+	return ima_file_check(file);
 }
 
 int security_task_create(unsigned long clone_flags)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
