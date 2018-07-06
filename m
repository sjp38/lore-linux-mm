Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f198.google.com (mail-qk0-f198.google.com [209.85.220.198])
	by kanga.kvack.org (Postfix) with ESMTP id 829286B026D
	for <linux-mm@kvack.org>; Fri,  6 Jul 2018 15:34:31 -0400 (EDT)
Received: by mail-qk0-f198.google.com with SMTP id u19-v6so14555686qkl.13
        for <linux-mm@kvack.org>; Fri, 06 Jul 2018 12:34:31 -0700 (PDT)
Received: from mx1.redhat.com (mx3-rdu2.redhat.com. [66.187.233.73])
        by mx.google.com with ESMTPS id b6-v6si5916511qtc.19.2018.07.06.12.34.30
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 06 Jul 2018 12:34:30 -0700 (PDT)
From: Waiman Long <longman@redhat.com>
Subject: [PATCH v6 4/7] fs/dcache: Spread negative dentry pruning across multiple CPUs
Date: Fri,  6 Jul 2018 15:32:49 -0400
Message-Id: <1530905572-817-5-git-send-email-longman@redhat.com>
In-Reply-To: <1530905572-817-1-git-send-email-longman@redhat.com>
References: <1530905572-817-1-git-send-email-longman@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Alexander Viro <viro@zeniv.linux.org.uk>, Jonathan Corbet <corbet@lwn.net>, "Luis R. Rodriguez" <mcgrof@kernel.org>, Kees Cook <keescook@chromium.org>
Cc: linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, linux-doc@vger.kernel.org, Linus Torvalds <torvalds@linux-foundation.org>, Jan Kara <jack@suse.cz>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, Andrew Morton <akpm@linux-foundation.org>, Ingo Molnar <mingo@kernel.org>, Miklos Szeredi <mszeredi@redhat.com>, Matthew Wilcox <willy@infradead.org>, Larry Woodman <lwoodman@redhat.com>, James Bottomley <James.Bottomley@HansenPartnership.com>, "Wangkai (Kevin C)" <wangkai86@huawei.com>, Waiman Long <longman@redhat.com>

Doing negative dentry pruning using schedule_delayed_work() will
typically concentrate the pruning effort on one particular CPU. That is
not fair to the tasks running on that CPU. In addition, it is possible
that one CPU can have all its negative dentries pruned away while the
others can still have more negative dentries than the percpu limit.

To be fair, negative dentries pruning is now done across all the online
CPUs, if they all have close to the percpu limit of negative dentries.

Signed-off-by: Waiman Long <longman@redhat.com>
---
 fs/dcache.c | 43 ++++++++++++++++++++++++++++++++++++++-----
 1 file changed, 38 insertions(+), 5 deletions(-)

diff --git a/fs/dcache.c b/fs/dcache.c
index ac25029..3be9246 100644
--- a/fs/dcache.c
+++ b/fs/dcache.c
@@ -367,7 +367,8 @@ static void __neg_dentry_inc(struct dentry *dentry)
 			WRITE_ONCE(ndblk.prune_sb, NULL);
 		} else {
 			atomic_inc(&ndblk.prune_sb->s_active);
-			schedule_delayed_work(&prune_neg_dentry_work, 1);
+			schedule_delayed_work_on(smp_processor_id(),
+						&prune_neg_dentry_work, 1);
 		}
 	}
 }
@@ -1508,8 +1509,9 @@ static enum lru_status dentry_negative_lru_isolate(struct list_head *item,
  */
 static void prune_negative_dentry(struct work_struct *work)
 {
+	int cpu = smp_processor_id();
 	int freed, last_n_neg;
-	long nfree;
+	long nfree, excess;
 	struct super_block *sb = READ_ONCE(ndblk.prune_sb);
 	LIST_HEAD(dispose);
 
@@ -1543,9 +1545,40 @@ static void prune_negative_dentry(struct work_struct *work)
 	    (nfree >= neg_dentry_nfree_init/2) || NEG_IS_SB_UMOUNTING(sb))
 		goto stop_pruning;
 
-	schedule_delayed_work(&prune_neg_dentry_work,
-			     (nfree < neg_dentry_nfree_init/8)
-			     ? NEG_PRUNING_FAST_RATE : NEG_PRUNING_SLOW_RATE);
+	/*
+	 * If the negative dentry count in the current cpu is less than the
+	 * per_cpu limit, schedule the pruning in the next cpu if it has
+	 * more negative dentries. This will make the negative dentry count
+	 * reduction spread more evenly across multiple per-cpu counters.
+	 */
+	excess = neg_dentry_percpu_limit - __this_cpu_read(nr_dentry_neg);
+	if (excess > 0) {
+		int next_cpu = cpumask_next(cpu, cpu_online_mask);
+
+		if (next_cpu >= nr_cpu_ids)
+			next_cpu = cpumask_first(cpu_online_mask);
+		if (per_cpu(nr_dentry_neg, next_cpu) >
+		    __this_cpu_read(nr_dentry_neg)) {
+			cpu = next_cpu;
+
+			/*
+			 * Transfer some of the excess negative dentry count
+			 * to the free pool if the current percpu pool is less
+			 * than 3/4 of the limit.
+			 */
+			if ((excess > neg_dentry_percpu_limit/4) &&
+			    raw_spin_trylock(&ndblk.nfree_lock)) {
+				WRITE_ONCE(ndblk.nfree,
+					   ndblk.nfree + NEG_DENTRY_BATCH);
+				__this_cpu_add(nr_dentry_neg, NEG_DENTRY_BATCH);
+				raw_spin_unlock(&ndblk.nfree_lock);
+			}
+		}
+	}
+
+	schedule_delayed_work_on(cpu, &prune_neg_dentry_work,
+			(nfree < neg_dentry_nfree_init/8)
+			? NEG_PRUNING_FAST_RATE : NEG_PRUNING_SLOW_RATE);
 	return;
 
 stop_pruning:
-- 
1.8.3.1
