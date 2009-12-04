Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with SMTP id BF83B600794
	for <linux-mm@kvack.org>; Fri,  4 Dec 2009 15:48:21 -0500 (EST)
From: Eric Paris <eparis@redhat.com>
Subject: [RFC PATCH 11/15] ima: call ima_inode_free ima_inode_free
Date: Fri, 04 Dec 2009 15:48:08 -0500
Message-ID: <20091204204808.18286.71841.stgit@paris.rdu.redhat.com>
In-Reply-To: <20091204204646.18286.24853.stgit@paris.rdu.redhat.com>
References: <20091204204646.18286.24853.stgit@paris.rdu.redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org
Cc: viro@zeniv.linux.org.uk, jmorris@namei.org, npiggin@suse.de, eparis@redhat.com, zohar@us.ibm.com, jack@suse.cz, jmalicki@metacarta.com, dsmith@redhat.com, serue@us.ibm.com, hch@lst.de, john@johnmccutchan.com, rlove@rlove.org, ebiederm@xmission.com, heiko.carstens@de.ibm.com, penguin-kernel@I-love.SAKURA.ne.jp, mszeredi@suse.cz, jens.axboe@oracle.com, akpm@linux-foundation.org, matthew@wil.cx, hugh.dickins@tiscali.co.uk, kamezawa.hiroyu@jp.fujitsu.com, nishimura@mxp.nes.nec.co.jp, davem@davemloft.net, arnd@arndb.de, eric.dumazet@gmail.com
List-ID: <linux-mm.kvack.org>

ima_inode_free() has some funky #define just to confuse the crap out of me.

#define ima_iint_free ima_inode_free

void ima_iint_delete(struct inode *inode)

and then things actually call ima_inode_free() and nothing calls
ima_iint_delete().

Signed-off-by: Eric Paris <eparis@redhat.com>
---

 security/integrity/ima/ima.h      |    1 -
 security/integrity/ima/ima_iint.c |    6 ++----
 2 files changed, 2 insertions(+), 5 deletions(-)

diff --git a/security/integrity/ima/ima.h b/security/integrity/ima/ima.h
index 268ef57..c41afe6 100644
--- a/security/integrity/ima/ima.h
+++ b/security/integrity/ima/ima.h
@@ -127,7 +127,6 @@ void ima_template_show(struct seq_file *m, void *e,
  */
 struct ima_iint_cache *ima_iint_insert(struct inode *inode);
 struct ima_iint_cache *ima_iint_find_get(struct inode *inode);
-void ima_iint_delete(struct inode *inode);
 void iint_free(struct kref *kref);
 void iint_rcu_free(struct rcu_head *rcu);
 
diff --git a/security/integrity/ima/ima_iint.c b/security/integrity/ima/ima_iint.c
index 2f6ab52..fa592ff 100644
--- a/security/integrity/ima/ima_iint.c
+++ b/security/integrity/ima/ima_iint.c
@@ -19,8 +19,6 @@
 #include <linux/radix-tree.h>
 #include "ima.h"
 
-#define ima_iint_delete ima_inode_free
-
 RADIX_TREE(ima_iint_store, GFP_ATOMIC);
 DEFINE_SPINLOCK(ima_iint_lock);
 
@@ -111,12 +109,12 @@ void iint_rcu_free(struct rcu_head *rcu_head)
 }
 
 /**
- * ima_iint_delete - called on integrity_inode_free
+ * ima_inode_free - called on security_inode_free
  * @inode: pointer to the inode
  *
  * Free the integrity information(iint) associated with an inode.
  */
-void ima_iint_delete(struct inode *inode)
+void ima_inode_free(struct inode *inode)
 {
 	struct ima_iint_cache *iint;
 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
