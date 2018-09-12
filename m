Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f200.google.com (mail-qt0-f200.google.com [209.85.216.200])
	by kanga.kvack.org (Postfix) with ESMTP id 345088E0001
	for <linux-mm@kvack.org>; Wed, 12 Sep 2018 13:35:56 -0400 (EDT)
Received: by mail-qt0-f200.google.com with SMTP id d1-v6so2193506qth.21
        for <linux-mm@kvack.org>; Wed, 12 Sep 2018 10:35:56 -0700 (PDT)
Received: from mx1.redhat.com (mx3-rdu2.redhat.com. [66.187.233.73])
        by mx.google.com with ESMTPS id u17-v6si1006102qvi.90.2018.09.12.10.35.55
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 12 Sep 2018 10:35:55 -0700 (PDT)
From: Waiman Long <longman@redhat.com>
Subject: [PATCH v4 1/3] fs/dcache: Fix incorrect nr_dentry_unused accounting in shrink_dcache_sb()
Date: Wed, 12 Sep 2018 13:35:40 -0400
Message-Id: <1536773742-32687-2-git-send-email-longman@redhat.com>
In-Reply-To: <1536773742-32687-1-git-send-email-longman@redhat.com>
References: <1536773742-32687-1-git-send-email-longman@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Alexander Viro <viro@zeniv.linux.org.uk>, Jonathan Corbet <corbet@lwn.net>, Andrew Morton <akpm@linux-foundation.org>
Cc: linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, linux-doc@vger.kernel.org, "Luis R. Rodriguez" <mcgrof@kernel.org>, Kees Cook <keescook@chromium.org>, Linus Torvalds <torvalds@linux-foundation.org>, Jan Kara <jack@suse.cz>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, Ingo Molnar <mingo@kernel.org>, Miklos Szeredi <mszeredi@redhat.com>, Matthew Wilcox <willy@infradead.org>, Larry Woodman <lwoodman@redhat.com>, James Bottomley <James.Bottomley@HansenPartnership.com>, "Wangkai (Kevin C)" <wangkai86@huawei.com>, Michal Hocko <mhocko@kernel.org>, Waiman Long <longman@redhat.com>, stable@vger.kernel.org

The nr_dentry_unused per-cpu counter tracks dentries in both the
LRU lists and the shrink lists where the DCACHE_LRU_LIST bit is set.
The shrink_dcache_sb() function moves dentries from the LRU list to a
shrink list and subtracts the dentry count from nr_dentry_unused. This
is incorrect as the nr_dentry_unused count Will also be decremented in
shrink_dentry_list() via d_shrink_del(). To fix this double decrement,
the decrement in the shrink_dcache_sb() function is taken out.

Fixes: 4e717f5c1083 ("list_lru: remove special case function list_lru_dispose_all."
Cc: stable@vger.kernel.org

Signed-off-by: Waiman Long <longman@redhat.com>
Reviewed-by: Dave Chinner <dchinner@redhat.com>
---
 fs/dcache.c | 6 +-----
 1 file changed, 1 insertion(+), 5 deletions(-)

diff --git a/fs/dcache.c b/fs/dcache.c
index 2e7e8d8..cb515f1 100644
--- a/fs/dcache.c
+++ b/fs/dcache.c
@@ -1202,15 +1202,11 @@ static enum lru_status dentry_lru_isolate_shrink(struct list_head *item,
  */
 void shrink_dcache_sb(struct super_block *sb)
 {
-	long freed;
-
 	do {
 		LIST_HEAD(dispose);
 
-		freed = list_lru_walk(&sb->s_dentry_lru,
+		list_lru_walk(&sb->s_dentry_lru,
 			dentry_lru_isolate_shrink, &dispose, 1024);
-
-		this_cpu_sub(nr_dentry_unused, freed);
 		shrink_dentry_list(&dispose);
 	} while (list_lru_count(&sb->s_dentry_lru) > 0);
 }
-- 
1.8.3.1
