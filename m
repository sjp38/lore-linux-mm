Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f199.google.com (mail-qk0-f199.google.com [209.85.220.199])
	by kanga.kvack.org (Postfix) with ESMTP id 3F14C6B0007
	for <linux-mm@kvack.org>; Tue,  7 Aug 2018 11:39:40 -0400 (EDT)
Received: by mail-qk0-f199.google.com with SMTP id d194-v6so16852729qkb.12
        for <linux-mm@kvack.org>; Tue, 07 Aug 2018 08:39:40 -0700 (PDT)
Received: from EUR03-VE1-obe.outbound.protection.outlook.com (mail-eopbgr50122.outbound.protection.outlook.com. [40.107.5.122])
        by mx.google.com with ESMTPS id k8-v6si1047747qvi.241.2018.08.07.08.39.38
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Tue, 07 Aug 2018 08:39:39 -0700 (PDT)
Subject: [PATCH RFC 10/10] fs: Use unregister_shrinker_delayed_{initiate,
 finalize} for super_block shrinker
From: Kirill Tkhai <ktkhai@virtuozzo.com>
Date: Tue, 07 Aug 2018 18:39:27 +0300
Message-ID: <153365636747.19074.12610817307548583381.stgit@localhost.localdomain>
In-Reply-To: <153365347929.19074.12509495712735843805.stgit@localhost.localdomain>
References: <153365347929.19074.12509495712735843805.stgit@localhost.localdomain>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org, gregkh@linuxfoundation.org, rafael@kernel.org, viro@zeniv.linux.org.uk, darrick.wong@oracle.com, paulmck@linux.vnet.ibm.com, josh@joshtriplett.org, rostedt@goodmis.org, mathieu.desnoyers@efficios.com, jiangshanlai@gmail.com, hughd@google.com, shuah@kernel.org, robh@kernel.org, ulf.hansson@linaro.org, aspriel@gmail.com, vivek.gautam@codeaurora.org, robin.murphy@arm.com, joe@perches.com, heikki.krogerus@linux.intel.com, ktkhai@virtuozzo.com, sfr@canb.auug.org.au, vdavydov.dev@gmail.com, mhocko@suse.com, chris@chris-wilson.co.uk, penguin-kernel@I-love.SAKURA.ne.jp, aryabinin@virtuozzo.com, willy@infradead.org, ying.huang@intel.com, shakeelb@google.com, jbacik@fb.com, mingo@kernel.org, mhiramat@kernel.org, linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org

Previous patches made all the data, which is touched from
super_cache_count(), destroyed from destroy_super_work():
s_dentry_lru, s_inode_lru and super_block::s_fs_info.

super_cache_scan() can't be called after SB_ACTIVE is cleared
in generic_shutdown_super().

So, it safe to move heavy unregister_shrinker_delayed_finalize()
part to delayed work, i.e. it's safe for parallel do_shrink_slab()
to be executed between unregister_shrinker_delayed_initiate() and
destroy_super_work()->unregister_shrinker_delayed_finalize().

This makes the heavy synchronize_srcu() to do not affect on user-visible
unregistration speed (since now it's executed from workqueue).

All further time-critical for unregistration places may be written
in the same conception.

Signed-off-by: Kirill Tkhai <ktkhai@virtuozzo.com>
---
 fs/super.c         |    4 +++-
 include/linux/fs.h |    5 +++++
 2 files changed, 8 insertions(+), 1 deletion(-)

diff --git a/fs/super.c b/fs/super.c
index c60f092538c7..33e829741ec0 100644
--- a/fs/super.c
+++ b/fs/super.c
@@ -165,6 +165,8 @@ static void destroy_super_work(struct work_struct *work)
 							destroy_work);
 	int i;
 
+	unregister_shrinker_delayed_finalize(&s->s_shrink);
+
 	WARN_ON(list_lru_count(&s->s_dentry_lru));
 	WARN_ON(list_lru_count(&s->s_inode_lru));
 	list_lru_destroy(&s->s_dentry_lru);
@@ -334,7 +336,7 @@ void deactivate_locked_super(struct super_block *s)
 	struct file_system_type *fs = s->s_type;
 	if (atomic_dec_and_test(&s->s_active)) {
 		cleancache_invalidate_fs(s);
-		unregister_shrinker(&s->s_shrink);
+		unregister_shrinker_delayed_initiate(&s->s_shrink);
 		fs->kill_sb(s);
 
 		put_filesystem(fs);
diff --git a/include/linux/fs.h b/include/linux/fs.h
index 33dfaed0a01a..8a1cd3097eef 100644
--- a/include/linux/fs.h
+++ b/include/linux/fs.h
@@ -1902,6 +1902,11 @@ struct super_operations {
 	struct dquot **(*get_dquots)(struct inode *);
 #endif
 	int (*bdev_try_to_free_page)(struct super_block*, struct page*, gfp_t);
+	/*
+	 * Shrinker may call these two function on destructing super_block
+	 * till unregister_shrinker_delayed_finalize() has completed
+	 * in destroy_super_work(), and they must care about that.
+	 */
 	long (*nr_cached_objects)(struct super_block *,
 				  struct shrink_control *);
 	long (*free_cached_objects)(struct super_block *,
