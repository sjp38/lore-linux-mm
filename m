Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f197.google.com (mail-qk0-f197.google.com [209.85.220.197])
	by kanga.kvack.org (Postfix) with ESMTP id 280D96B027D
	for <linux-mm@kvack.org>; Tue,  7 Aug 2018 11:39:02 -0400 (EDT)
Received: by mail-qk0-f197.google.com with SMTP id u68-v6so17126220qku.5
        for <linux-mm@kvack.org>; Tue, 07 Aug 2018 08:39:02 -0700 (PDT)
Received: from EUR03-VE1-obe.outbound.protection.outlook.com (mail-eopbgr50115.outbound.protection.outlook.com. [40.107.5.115])
        by mx.google.com with ESMTPS id k35-v6si265732qte.335.2018.08.07.08.39.01
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Tue, 07 Aug 2018 08:39:01 -0700 (PDT)
Subject: [PATCH RFC 07/10] fs: Introduce struct
 super_operations::destroy_super() callback.
From: Kirill Tkhai <ktkhai@virtuozzo.com>
Date: Tue, 07 Aug 2018 18:38:48 +0300
Message-ID: <153365632811.19074.14026254201855676335.stgit@localhost.localdomain>
In-Reply-To: <153365347929.19074.12509495712735843805.stgit@localhost.localdomain>
References: <153365347929.19074.12509495712735843805.stgit@localhost.localdomain>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org, gregkh@linuxfoundation.org, rafael@kernel.org, viro@zeniv.linux.org.uk, darrick.wong@oracle.com, paulmck@linux.vnet.ibm.com, josh@joshtriplett.org, rostedt@goodmis.org, mathieu.desnoyers@efficios.com, jiangshanlai@gmail.com, hughd@google.com, shuah@kernel.org, robh@kernel.org, ulf.hansson@linaro.org, aspriel@gmail.com, vivek.gautam@codeaurora.org, robin.murphy@arm.com, joe@perches.com, heikki.krogerus@linux.intel.com, ktkhai@virtuozzo.com, sfr@canb.auug.org.au, vdavydov.dev@gmail.com, mhocko@suse.com, chris@chris-wilson.co.uk, penguin-kernel@I-love.SAKURA.ne.jp, aryabinin@virtuozzo.com, willy@infradead.org, ying.huang@intel.com, shakeelb@google.com, jbacik@fb.com, mingo@kernel.org, mhiramat@kernel.org, linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org

The patch introduces a new callback, which will be called
asynchronous from delayed work.

This will allows to make ::nr_cached_objects() safe
to be called on destroying superblock in next patches,
and to split unregister_shrinker() into two primitives.

Signed-off-by: Kirill Tkhai <ktkhai@virtuozzo.com>
---
 fs/super.c         |    3 +++
 include/linux/fs.h |    1 +
 2 files changed, 4 insertions(+)

diff --git a/fs/super.c b/fs/super.c
index 9222cfc196bf..c60f092538c7 100644
--- a/fs/super.c
+++ b/fs/super.c
@@ -170,6 +170,9 @@ static void destroy_super_work(struct work_struct *work)
 	list_lru_destroy(&s->s_dentry_lru);
 	list_lru_destroy(&s->s_inode_lru);
 
+	if (s->s_op->destroy_super)
+		s->s_op->destroy_super(s);
+
 	for (i = 0; i < SB_FREEZE_LEVELS; i++)
 		percpu_free_rwsem(&s->s_writers.rw_sem[i]);
 	kfree(s);
diff --git a/include/linux/fs.h b/include/linux/fs.h
index 842fde0f0981..33dfaed0a01a 100644
--- a/include/linux/fs.h
+++ b/include/linux/fs.h
@@ -1880,6 +1880,7 @@ struct super_operations {
 	int (*drop_inode) (struct inode *);
 	void (*evict_inode) (struct inode *);
 	void (*put_super) (struct super_block *);
+	void (*destroy_super) (struct super_block *);
 	int (*sync_fs)(struct super_block *sb, int wait);
 	int (*freeze_super) (struct super_block *);
 	int (*freeze_fs) (struct super_block *);
