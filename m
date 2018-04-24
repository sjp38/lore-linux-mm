Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id BBCD16B0005
	for <linux-mm@kvack.org>; Tue, 24 Apr 2018 08:13:09 -0400 (EDT)
Received: by mail-pf0-f197.google.com with SMTP id j25so12969899pfh.18
        for <linux-mm@kvack.org>; Tue, 24 Apr 2018 05:13:09 -0700 (PDT)
Received: from EUR01-DB5-obe.outbound.protection.outlook.com (mail-db5eur01on0116.outbound.protection.outlook.com. [104.47.2.116])
        by mx.google.com with ESMTPS id q62si11664793pgq.297.2018.04.24.05.13.08
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Tue, 24 Apr 2018 05:13:08 -0700 (PDT)
Subject: [PATCH v3 06/14] fs: Refactoring in alloc_super()
From: Kirill Tkhai <ktkhai@virtuozzo.com>
Date: Tue, 24 Apr 2018 15:13:01 +0300
Message-ID: <152457198169.22533.5463813231801094118.stgit@localhost.localdomain>
In-Reply-To: <152457151556.22533.5742587589232401708.stgit@localhost.localdomain>
References: <152457151556.22533.5742587589232401708.stgit@localhost.localdomain>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org, vdavydov.dev@gmail.com, shakeelb@google.com, viro@zeniv.linux.org.uk, hannes@cmpxchg.org, mhocko@kernel.org, ktkhai@virtuozzo.com, tglx@linutronix.de, pombredanne@nexb.com, stummala@codeaurora.org, gregkh@linuxfoundation.org, sfr@canb.auug.org.au, guro@fb.com, mka@chromium.org, penguin-kernel@I-love.SAKURA.ne.jp, chris@chris-wilson.co.uk, longman@redhat.com, minchan@kernel.org, ying.huang@intel.com, mgorman@techsingularity.net, jbacik@fb.com, linux@roeck-us.net, linux-kernel@vger.kernel.org, linux-mm@kvack.org, willy@infradead.org, lirongqing@baidu.com, aryabinin@virtuozzo.com

Do two list_lru_init_memcg() calls after prealloc_super().
destroy_unused_super() in fail path is OK with this.
Next patch needs such the order.

Signed-off-by: Kirill Tkhai <ktkhai@virtuozzo.com>
---
 fs/super.c |    8 ++++----
 1 file changed, 4 insertions(+), 4 deletions(-)

diff --git a/fs/super.c b/fs/super.c
index 036a5522f9d0..d95fa174edab 100644
--- a/fs/super.c
+++ b/fs/super.c
@@ -234,10 +234,6 @@ static struct super_block *alloc_super(struct file_system_type *type, int flags,
 	INIT_LIST_HEAD(&s->s_inodes_wb);
 	spin_lock_init(&s->s_inode_wblist_lock);
 
-	if (list_lru_init_memcg(&s->s_dentry_lru))
-		goto fail;
-	if (list_lru_init_memcg(&s->s_inode_lru))
-		goto fail;
 	s->s_count = 1;
 	atomic_set(&s->s_active, 1);
 	mutex_init(&s->s_vfs_rename_mutex);
@@ -258,6 +254,10 @@ static struct super_block *alloc_super(struct file_system_type *type, int flags,
 	s->s_shrink.flags = SHRINKER_NUMA_AWARE | SHRINKER_MEMCG_AWARE;
 	if (prealloc_shrinker(&s->s_shrink))
 		goto fail;
+	if (list_lru_init_memcg(&s->s_dentry_lru))
+		goto fail;
+	if (list_lru_init_memcg(&s->s_inode_lru))
+		goto fail;
 	return s;
 
 fail:
