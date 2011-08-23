Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id 8D0736B016C
	for <linux-mm@kvack.org>; Tue, 23 Aug 2011 04:56:52 -0400 (EDT)
From: Dave Chinner <david@fromorbit.com>
Subject: [PATCH 02/13] dcache: convert dentry_stat.nr_unused to per-cpu counters
Date: Tue, 23 Aug 2011 18:56:15 +1000
Message-Id: <1314089786-20535-3-git-send-email-david@fromorbit.com>
In-Reply-To: <1314089786-20535-1-git-send-email-david@fromorbit.com>
References: <1314089786-20535-1-git-send-email-david@fromorbit.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, khlebnikov@openvz.org

From: Dave Chinner <dchinner@redhat.com>

Before we split up the dcache_lru_lock, the unused dentry counter
needs to be made independent of the global dcache_lru_lock. Convert
it to per-cpu counters to do this.

Signed-off-by: Dave Chinner <dchinner@redhat.com>
---
 fs/dcache.c |   17 ++++++++++++++---
 1 files changed, 14 insertions(+), 3 deletions(-)

diff --git a/fs/dcache.c b/fs/dcache.c
index a88948b..febe701 100644
--- a/fs/dcache.c
+++ b/fs/dcache.c
@@ -116,6 +116,7 @@ struct dentry_stat_t dentry_stat = {
 };
 
 static DEFINE_PER_CPU(unsigned int, nr_dentry);
+static DEFINE_PER_CPU(unsigned int, nr_dentry_unused);
 
 #if defined(CONFIG_SYSCTL) && defined(CONFIG_PROC_FS)
 static int get_nr_dentry(void)
@@ -127,10 +128,20 @@ static int get_nr_dentry(void)
 	return sum < 0 ? 0 : sum;
 }
 
+static int get_nr_dentry_unused(void)
+{
+	int i;
+	int sum = 0;
+	for_each_possible_cpu(i)
+		sum += per_cpu(nr_dentry_unused, i);
+	return sum < 0 ? 0 : sum;
+}
+
 int proc_nr_dentry(ctl_table *table, int write, void __user *buffer,
 		   size_t *lenp, loff_t *ppos)
 {
 	dentry_stat.nr_dentry = get_nr_dentry();
+	dentry_stat.nr_unused = get_nr_dentry_unused();
 	return proc_dointvec(table, write, buffer, lenp, ppos);
 }
 #endif
@@ -233,7 +244,7 @@ static void dentry_lru_add(struct dentry *dentry)
 		spin_lock(&dcache_lru_lock);
 		list_add(&dentry->d_lru, &dentry->d_sb->s_dentry_lru);
 		dentry->d_sb->s_nr_dentry_unused++;
-		dentry_stat.nr_unused++;
+		this_cpu_inc(nr_dentry_unused);
 		spin_unlock(&dcache_lru_lock);
 	}
 }
@@ -242,7 +253,7 @@ static void __dentry_lru_del(struct dentry *dentry)
 {
 	list_del_init(&dentry->d_lru);
 	dentry->d_sb->s_nr_dentry_unused--;
-	dentry_stat.nr_unused--;
+	this_cpu_dec(nr_dentry_unused);
 }
 
 static void dentry_lru_del(struct dentry *dentry)
@@ -260,7 +271,7 @@ static void dentry_lru_move_tail(struct dentry *dentry)
 	if (list_empty(&dentry->d_lru)) {
 		list_add_tail(&dentry->d_lru, &dentry->d_sb->s_dentry_lru);
 		dentry->d_sb->s_nr_dentry_unused++;
-		dentry_stat.nr_unused++;
+		this_cpu_inc(nr_dentry_unused);
 	} else {
 		list_move_tail(&dentry->d_lru, &dentry->d_sb->s_dentry_lru);
 	}
-- 
1.7.5.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
