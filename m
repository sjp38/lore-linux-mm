Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f198.google.com (mail-qt0-f198.google.com [209.85.216.198])
	by kanga.kvack.org (Postfix) with ESMTP id E2DAC6B0279
	for <linux-mm@kvack.org>; Tue,  7 Aug 2018 11:38:37 -0400 (EDT)
Received: by mail-qt0-f198.google.com with SMTP id b7-v6so13775280qtp.14
        for <linux-mm@kvack.org>; Tue, 07 Aug 2018 08:38:37 -0700 (PDT)
Received: from EUR03-DB5-obe.outbound.protection.outlook.com (mail-eopbgr40096.outbound.protection.outlook.com. [40.107.4.96])
        by mx.google.com with ESMTPS id u27-v6si1642637qte.81.2018.08.07.08.38.36
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Tue, 07 Aug 2018 08:38:37 -0700 (PDT)
Subject: [PATCH RFC 05/10] fs: Move list_lru_destroy() to
 destroy_super_work()
From: Kirill Tkhai <ktkhai@virtuozzo.com>
Date: Tue, 07 Aug 2018 18:38:23 +0300
Message-ID: <153365630328.19074.5326096793225967868.stgit@localhost.localdomain>
In-Reply-To: <153365347929.19074.12509495712735843805.stgit@localhost.localdomain>
References: <153365347929.19074.12509495712735843805.stgit@localhost.localdomain>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org, gregkh@linuxfoundation.org, rafael@kernel.org, viro@zeniv.linux.org.uk, darrick.wong@oracle.com, paulmck@linux.vnet.ibm.com, josh@joshtriplett.org, rostedt@goodmis.org, mathieu.desnoyers@efficios.com, jiangshanlai@gmail.com, hughd@google.com, shuah@kernel.org, robh@kernel.org, ulf.hansson@linaro.org, aspriel@gmail.com, vivek.gautam@codeaurora.org, robin.murphy@arm.com, joe@perches.com, heikki.krogerus@linux.intel.com, ktkhai@virtuozzo.com, sfr@canb.auug.org.au, vdavydov.dev@gmail.com, mhocko@suse.com, chris@chris-wilson.co.uk, penguin-kernel@I-love.SAKURA.ne.jp, aryabinin@virtuozzo.com, willy@infradead.org, ying.huang@intel.com, shakeelb@google.com, jbacik@fb.com, mingo@kernel.org, mhiramat@kernel.org, linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org

The patch makes s_dentry_lru and s_inode_lru be destroyed
later from the workqueue. This is preparation to split
unregister_shrinker(super_block::s_shrink) in two stages,
and to call finalize stage from destroy_super_work().

Note, that generic filesystem shrinker unregistration
is safe to be splitted in two stages right after this
patch, since super_cache_count() and super_cache_scan()
have a deal with s_dentry_lru and s_inode_lru only.

But there are two exceptions: XFS and SHMEM, which
define .nr_cached_objects() and .free_cached_objects()
callbacks. These two do not allow us to do the splitting
right after this patch. They touch fs-specific data,
which is destroyed earlier, than destroy_super_work().
So, we can't call unregister_shrinker_delayed_finalize()
from destroy_super_work() because of them, and next
patches make preparations to make this possible.

Signed-off-by: Kirill Tkhai <ktkhai@virtuozzo.com>
---
 fs/super.c |   17 +++++------------
 1 file changed, 5 insertions(+), 12 deletions(-)

diff --git a/fs/super.c b/fs/super.c
index 426161360af3..457834278e37 100644
--- a/fs/super.c
+++ b/fs/super.c
@@ -159,6 +159,11 @@ static void destroy_super_work(struct work_struct *work)
 							destroy_work);
 	int i;
 
+	WARN_ON(list_lru_count(&s->s_dentry_lru));
+	WARN_ON(list_lru_count(&s->s_inode_lru));
+	list_lru_destroy(&s->s_dentry_lru);
+	list_lru_destroy(&s->s_inode_lru);
+
 	for (i = 0; i < SB_FREEZE_LEVELS; i++)
 		percpu_free_rwsem(&s->s_writers.rw_sem[i]);
 	kfree(s);
@@ -177,8 +182,6 @@ static void destroy_unused_super(struct super_block *s)
 	if (!s)
 		return;
 	up_write(&s->s_umount);
-	list_lru_destroy(&s->s_dentry_lru);
-	list_lru_destroy(&s->s_inode_lru);
 	security_sb_free(s);
 	put_user_ns(s->s_user_ns);
 	kfree(s->s_subtype);
@@ -283,8 +286,6 @@ static void __put_super(struct super_block *s)
 {
 	if (!--s->s_count) {
 		list_del_init(&s->s_list);
-		WARN_ON(s->s_dentry_lru.node);
-		WARN_ON(s->s_inode_lru.node);
 		WARN_ON(!list_empty(&s->s_mounts));
 		security_sb_free(s);
 		put_user_ns(s->s_user_ns);
@@ -327,14 +328,6 @@ void deactivate_locked_super(struct super_block *s)
 		unregister_shrinker(&s->s_shrink);
 		fs->kill_sb(s);
 
-		/*
-		 * Since list_lru_destroy() may sleep, we cannot call it from
-		 * put_super(), where we hold the sb_lock. Therefore we destroy
-		 * the lru lists right now.
-		 */
-		list_lru_destroy(&s->s_dentry_lru);
-		list_lru_destroy(&s->s_inode_lru);
-
 		put_filesystem(fs);
 		put_super(s);
 	} else {
