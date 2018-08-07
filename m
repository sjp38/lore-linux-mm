Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f199.google.com (mail-qt0-f199.google.com [209.85.216.199])
	by kanga.kvack.org (Postfix) with ESMTP id 6E74D6B0281
	for <linux-mm@kvack.org>; Tue,  7 Aug 2018 11:39:27 -0400 (EDT)
Received: by mail-qt0-f199.google.com with SMTP id x26-v6so13833852qtb.2
        for <linux-mm@kvack.org>; Tue, 07 Aug 2018 08:39:27 -0700 (PDT)
Received: from EUR03-DB5-obe.outbound.protection.outlook.com (mail-eopbgr40102.outbound.protection.outlook.com. [40.107.4.102])
        by mx.google.com with ESMTPS id q51-v6si229545qtj.66.2018.08.07.08.39.26
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Tue, 07 Aug 2018 08:39:26 -0700 (PDT)
Subject: [PATCH RFC 09/10] shmem: Implement shmem_destroy_super()
From: Kirill Tkhai <ktkhai@virtuozzo.com>
Date: Tue, 07 Aug 2018 18:39:15 +0300
Message-ID: <153365635538.19074.16684830171993560909.stgit@localhost.localdomain>
In-Reply-To: <153365347929.19074.12509495712735843805.stgit@localhost.localdomain>
References: <153365347929.19074.12509495712735843805.stgit@localhost.localdomain>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org, gregkh@linuxfoundation.org, rafael@kernel.org, viro@zeniv.linux.org.uk, darrick.wong@oracle.com, paulmck@linux.vnet.ibm.com, josh@joshtriplett.org, rostedt@goodmis.org, mathieu.desnoyers@efficios.com, jiangshanlai@gmail.com, hughd@google.com, shuah@kernel.org, robh@kernel.org, ulf.hansson@linaro.org, aspriel@gmail.com, vivek.gautam@codeaurora.org, robin.murphy@arm.com, joe@perches.com, heikki.krogerus@linux.intel.com, ktkhai@virtuozzo.com, sfr@canb.auug.org.au, vdavydov.dev@gmail.com, mhocko@suse.com, chris@chris-wilson.co.uk, penguin-kernel@I-love.SAKURA.ne.jp, aryabinin@virtuozzo.com, willy@infradead.org, ying.huang@intel.com, shakeelb@google.com, jbacik@fb.com, mingo@kernel.org, mhiramat@kernel.org, linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org

Similar to xfs_fs_destroy_super() implement the method
for shmem.

shmem_unused_huge_count() just touches sb->s_fs_info.
After such the later freeing it will be safe for
unregister_shrinker() splitting (which is made in next
patch).

Signed-off-by: Kirill Tkhai <ktkhai@virtuozzo.com>
---
 mm/shmem.c |    8 ++++++++
 1 file changed, 8 insertions(+)

diff --git a/mm/shmem.c b/mm/shmem.c
index 4829798869b6..35c65afefbc8 100644
--- a/mm/shmem.c
+++ b/mm/shmem.c
@@ -3427,6 +3427,12 @@ static void shmem_put_super(struct super_block *sb)
 
 	percpu_counter_destroy(&sbinfo->used_blocks);
 	mpol_put(sbinfo->mpol);
+}
+
+static void shmem_destroy_super(struct super_block *sb)
+{
+	struct shmem_sb_info *sbinfo = SHMEM_SB(sb);
+
 	kfree(sbinfo);
 	sb->s_fs_info = NULL;
 }
@@ -3504,6 +3510,7 @@ int shmem_fill_super(struct super_block *sb, void *data, size_t data_size,
 
 failed:
 	shmem_put_super(sb);
+	shmem_destroy_super(sb);
 	return err;
 }
 
@@ -3630,6 +3637,7 @@ static const struct super_operations shmem_ops = {
 	.evict_inode	= shmem_evict_inode,
 	.drop_inode	= generic_delete_inode,
 	.put_super	= shmem_put_super,
+	.destroy_super	= shmem_destroy_super,
 #ifdef CONFIG_TRANSPARENT_HUGE_PAGECACHE
 	.nr_cached_objects	= shmem_unused_huge_count,
 	.free_cached_objects	= shmem_unused_huge_scan,
