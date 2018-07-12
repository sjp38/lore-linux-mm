Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f198.google.com (mail-qk0-f198.google.com [209.85.220.198])
	by kanga.kvack.org (Postfix) with ESMTP id D6E186B026A
	for <linux-mm@kvack.org>; Thu, 12 Jul 2018 12:47:05 -0400 (EDT)
Received: by mail-qk0-f198.google.com with SMTP id h67-v6so33333905qke.18
        for <linux-mm@kvack.org>; Thu, 12 Jul 2018 09:47:05 -0700 (PDT)
Received: from mx1.redhat.com (mx3-rdu2.redhat.com. [66.187.233.73])
        by mx.google.com with ESMTPS id 42-v6si3210596qvf.139.2018.07.12.09.47.04
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 12 Jul 2018 09:47:04 -0700 (PDT)
From: Waiman Long <longman@redhat.com>
Subject: [PATCH v7 4/6] fs/dcache: Print negative dentry warning every min until turned off by user
Date: Thu, 12 Jul 2018 12:46:03 -0400
Message-Id: <1531413965-5401-5-git-send-email-longman@redhat.com>
In-Reply-To: <1531413965-5401-1-git-send-email-longman@redhat.com>
References: <1531413965-5401-1-git-send-email-longman@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Alexander Viro <viro@zeniv.linux.org.uk>, Jonathan Corbet <corbet@lwn.net>, "Luis R. Rodriguez" <mcgrof@kernel.org>, Kees Cook <keescook@chromium.org>
Cc: linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, linux-doc@vger.kernel.org, Linus Torvalds <torvalds@linux-foundation.org>, Jan Kara <jack@suse.cz>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, Andrew Morton <akpm@linux-foundation.org>, Ingo Molnar <mingo@kernel.org>, Miklos Szeredi <mszeredi@redhat.com>, Matthew Wilcox <willy@infradead.org>, Larry Woodman <lwoodman@redhat.com>, James Bottomley <James.Bottomley@HansenPartnership.com>, "Wangkai (Kevin C)" <wangkai86@huawei.com>, Michal Hocko <mhocko@kernel.org>, Waiman Long <longman@redhat.com>

When there are too many negative dentries, printing a warning once may
not get the attention of the system administrator. So it is now change
to print a warning every minute until it is turned off by either writing
a 0 into fs/neg-dentry-limit or the limit is increased. After that the
system administrator can look into the reason why there are so many
negative dentries.

Note that the warning is printed when the global negative dentry free
pool is depleted even if there are space in other percpu negative dentry
counts for more.

Signed-off-by: Waiman Long <longman@redhat.com>
---
 fs/dcache.c | 35 ++++++++++++++++++++++++++++++++---
 1 file changed, 32 insertions(+), 3 deletions(-)

diff --git a/fs/dcache.c b/fs/dcache.c
index 1fad368..b2c1585 100644
--- a/fs/dcache.c
+++ b/fs/dcache.c
@@ -139,6 +139,7 @@ struct dentry_stat_t dentry_stat = {
  * the extra ones will be returned back to the global pool.
  */
 #define NEG_DENTRY_BATCH	(1 << 8)
+#define NEG_WARN_PERIOD 	(60 * HZ)	/* Print a warning every min */
 
 static struct static_key limit_neg_key = STATIC_KEY_INIT_FALSE;
 static int neg_dentry_limit_old;
@@ -150,6 +151,7 @@ struct dentry_stat_t dentry_stat = {
 static struct {
 	raw_spinlock_t nfree_lock;
 	long nfree;			/* Negative dentry free pool */
+	unsigned long warn_jiffies;	/* Time when last warning is printed */
 } ndblk ____cacheline_aligned_in_smp;
 proc_handler proc_neg_dentry_limit;
 
@@ -309,6 +311,7 @@ static long __neg_dentry_nfree_dec(long cnt)
 static noinline void neg_dentry_inc_slowpath(struct dentry *dentry)
 {
 	long cnt = 0, *pcnt;
+	unsigned long current_time;
 
 	/*
 	 * Try to move some negative dentry quota from the global free
@@ -323,12 +326,38 @@ static noinline void neg_dentry_inc_slowpath(struct dentry *dentry)
 	}
 	put_cpu_ptr(&nr_dentry_neg);
 
+	if (cnt)
+		goto out;
+
 	/*
-	 * Put out a warning if there are too many negative dentries.
+	 * Put out a warning every minute or so if there are just too many
+	 * negative dentries.
 	 */
-	if (!cnt)
-		pr_warn_once("There are too many negative dentries.");
+	current_time = jiffies;
+
+	if (current_time < ndblk.warn_jiffies + NEG_WARN_PERIOD)
+		goto out;
+	/*
+	 * Update the time in ndblk.warn_jiffies and print a warning
+	 * if time update is successful.
+	 */
+	raw_spin_lock(&ndblk.nfree_lock);
+	if (current_time < ndblk.warn_jiffies + NEG_WARN_PERIOD) {
+		raw_spin_unlock(&ndblk.nfree_lock);
+		goto out;
+	}
+	ndblk.warn_jiffies = current_time;
+	raw_spin_unlock(&ndblk.nfree_lock);
 
+	/*
+	 * Get the current negative dentry count & print a warning.
+	 */
+	cnt = get_nr_dentry_neg();
+	pr_warn("Warning: Too many negative dentries (%ld). "
+		"This warning can be disabled by writing 0 to \"fs/neg-dentry-limit\" or increasing the limit.\n",
+		cnt);
+out:
+	return;
 }
 
 /*
-- 
1.8.3.1
