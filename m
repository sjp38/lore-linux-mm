Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f200.google.com (mail-qt0-f200.google.com [209.85.216.200])
	by kanga.kvack.org (Postfix) with ESMTP id 98F7B6B5394
	for <linux-mm@kvack.org>; Thu, 30 Aug 2018 17:55:29 -0400 (EDT)
Received: by mail-qt0-f200.google.com with SMTP id y54-v6so10408340qta.8
        for <linux-mm@kvack.org>; Thu, 30 Aug 2018 14:55:29 -0700 (PDT)
Received: from mx1.redhat.com (mx3-rdu2.redhat.com. [66.187.233.73])
        by mx.google.com with ESMTPS id 14-v6si7913924qvj.188.2018.08.30.14.55.28
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 30 Aug 2018 14:55:28 -0700 (PDT)
From: Waiman Long <longman@redhat.com>
Subject: [PATCH v2 2/4] fs: Don't need to put list_lru into its own cacheline
Date: Thu, 30 Aug 2018 17:55:05 -0400
Message-Id: <1535666107-25699-3-git-send-email-longman@redhat.com>
In-Reply-To: <1535666107-25699-1-git-send-email-longman@redhat.com>
References: <1535666107-25699-1-git-send-email-longman@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Alexander Viro <viro@zeniv.linux.org.uk>, Jonathan Corbet <corbet@lwn.net>
Cc: linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, linux-doc@vger.kernel.org, "Luis R. Rodriguez" <mcgrof@kernel.org>, Kees Cook <keescook@chromium.org>, Linus Torvalds <torvalds@linux-foundation.org>, Jan Kara <jack@suse.cz>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, Andrew Morton <akpm@linux-foundation.org>, Ingo Molnar <mingo@kernel.org>, Miklos Szeredi <mszeredi@redhat.com>, Matthew Wilcox <willy@infradead.org>, Larry Woodman <lwoodman@redhat.com>, James Bottomley <James.Bottomley@HansenPartnership.com>, "Wangkai (Kevin C)" <wangkai86@huawei.com>, Michal Hocko <mhocko@kernel.org>, Waiman Long <longman@redhat.com>

The list_lru structure is essentially just a pointer to a table of
per-node LRU lists. Even if CONFIG_MEMCG_KMEM is defined, the list
field is just used for LRU list registration and shrinker_id is set
at initialization. Those fields won't need to be touched that often.

So there is no point to make the list_lru structures to sit in their
own cachelines.

Signed-off-by: Waiman Long <longman@redhat.com>
---
 include/linux/fs.h | 9 +++++----
 1 file changed, 5 insertions(+), 4 deletions(-)

diff --git a/include/linux/fs.h b/include/linux/fs.h
index 3332270..fd4cd8a 100644
--- a/include/linux/fs.h
+++ b/include/linux/fs.h
@@ -1443,11 +1443,12 @@ struct super_block {
 	struct user_namespace *s_user_ns;
 
 	/*
-	 * Keep the lru lists last in the structure so they always sit on their
-	 * own individual cachelines.
+	 * The list_lru structure is essentially just a pointer to a table
+	 * of per-node lru lists, each of which has its own spinlock.
+	 * There is no need to put them into separate cachelines.
 	 */
-	struct list_lru		s_dentry_lru ____cacheline_aligned_in_smp;
-	struct list_lru		s_inode_lru ____cacheline_aligned_in_smp;
+	struct list_lru		s_dentry_lru;
+	struct list_lru		s_inode_lru;
 	struct rcu_head		rcu;
 	struct work_struct	destroy_work;
 
-- 
1.8.3.1
