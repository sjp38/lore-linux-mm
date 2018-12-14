Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt1-f200.google.com (mail-qt1-f200.google.com [209.85.160.200])
	by kanga.kvack.org (Postfix) with ESMTP id F1B7E8E01DC
	for <linux-mm@kvack.org>; Fri, 14 Dec 2018 16:53:21 -0500 (EST)
Received: by mail-qt1-f200.google.com with SMTP id z6so6891510qtj.21
        for <linux-mm@kvack.org>; Fri, 14 Dec 2018 13:53:21 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id t64si3253694qkf.154.2018.12.14.13.53.21
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 14 Dec 2018 13:53:21 -0800 (PST)
From: Waiman Long <longman@redhat.com>
Subject: [RESEND PATCH v4 1/3] fs/dcache: Fix incorrect nr_dentry_unused accounting in shrink_dcache_sb()
Date: Fri, 14 Dec 2018 16:53:02 -0500
Message-Id: <1544824384-17668-2-git-send-email-longman@redhat.com>
In-Reply-To: <1544824384-17668-1-git-send-email-longman@redhat.com>
References: <1544824384-17668-1-git-send-email-longman@redhat.com>
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
index 2593153..44e5652 100644
--- a/fs/dcache.c
+++ b/fs/dcache.c
@@ -1188,15 +1188,11 @@ static enum lru_status dentry_lru_isolate_shrink(struct list_head *item,
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
