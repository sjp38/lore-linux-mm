Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id A8CB56B007D
	for <linux-mm@kvack.org>; Thu,  2 Jun 2011 03:01:43 -0400 (EDT)
From: Dave Chinner <david@fromorbit.com>
Subject: [PATCH 05/12] inode: convert inode_stat.nr_unused to per-cpu counters
Date: Thu,  2 Jun 2011 17:01:00 +1000
Message-Id: <1306998067-27659-6-git-send-email-david@fromorbit.com>
In-Reply-To: <1306998067-27659-1-git-send-email-david@fromorbit.com>
References: <1306998067-27659-1-git-send-email-david@fromorbit.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-fsdevel@vger.kernel.org
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, xfs@oss.sgi.com

From: Dave Chinner <dchinner@redhat.com>

Before we split up the inode_lru_lock, the unused inode counter
needs to be made independent of the global inode_lru_lock. Convert
it to per-cpu counters to do this.

Signed-off-by: Dave Chinner <dchinner@redhat.com>
---
 fs/inode.c |   16 +++++++++++-----
 1 files changed, 11 insertions(+), 5 deletions(-)

diff --git a/fs/inode.c b/fs/inode.c
index 0f7e88a..17fea5b 100644
--- a/fs/inode.c
+++ b/fs/inode.c
@@ -95,6 +95,7 @@ EXPORT_SYMBOL(empty_aops);
 struct inodes_stat_t inodes_stat;
 
 static DEFINE_PER_CPU(unsigned int, nr_inodes);
+static DEFINE_PER_CPU(unsigned int, nr_unused);
 
 static struct kmem_cache *inode_cachep __read_mostly;
 
@@ -109,7 +110,11 @@ static int get_nr_inodes(void)
 
 static inline int get_nr_inodes_unused(void)
 {
-	return inodes_stat.nr_unused;
+	int i;
+	int sum = 0;
+	for_each_possible_cpu(i)
+		sum += per_cpu(nr_unused, i);
+	return sum < 0 ? 0 : sum;
 }
 
 int get_nr_dirty_inodes(void)
@@ -127,6 +132,7 @@ int proc_nr_inodes(ctl_table *table, int write,
 		   void __user *buffer, size_t *lenp, loff_t *ppos)
 {
 	inodes_stat.nr_inodes = get_nr_inodes();
+	inodes_stat.nr_unused = get_nr_inodes_unused();
 	return proc_dointvec(table, write, buffer, lenp, ppos);
 }
 #endif
@@ -340,7 +346,7 @@ static void inode_lru_list_add(struct inode *inode)
 	spin_lock(&inode_lru_lock);
 	if (list_empty(&inode->i_lru)) {
 		list_add(&inode->i_lru, &inode_lru);
-		inodes_stat.nr_unused++;
+		this_cpu_inc(nr_unused);
 	}
 	spin_unlock(&inode_lru_lock);
 }
@@ -350,7 +356,7 @@ static void inode_lru_list_del(struct inode *inode)
 	spin_lock(&inode_lru_lock);
 	if (!list_empty(&inode->i_lru)) {
 		list_del_init(&inode->i_lru);
-		inodes_stat.nr_unused--;
+		this_cpu_dec(nr_unused);
 	}
 	spin_unlock(&inode_lru_lock);
 }
@@ -649,7 +655,7 @@ static void prune_icache(int nr_to_scan)
 		    (inode->i_state & ~I_REFERENCED)) {
 			list_del_init(&inode->i_lru);
 			spin_unlock(&inode->i_lock);
-			inodes_stat.nr_unused--;
+			this_cpu_dec(nr_unused);
 			continue;
 		}
 
@@ -686,7 +692,7 @@ static void prune_icache(int nr_to_scan)
 		spin_unlock(&inode->i_lock);
 
 		list_move(&inode->i_lru, &freeable);
-		inodes_stat.nr_unused--;
+		this_cpu_dec(nr_unused);
 	}
 	if (current_is_kswapd())
 		__count_vm_events(KSWAPD_INODESTEAL, reap);
-- 
1.7.5.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
