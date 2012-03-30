Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx151.postini.com [74.125.245.151])
	by kanga.kvack.org (Postfix) with SMTP id B513F6B0044
	for <linux-mm@kvack.org>; Fri, 30 Mar 2012 04:07:44 -0400 (EDT)
From: Glauber Costa <glommer@parallels.com>
Subject: [RFC 4/7] move res_counter_set limit to res_counter.c
Date: Fri, 30 Mar 2012 10:04:42 +0200
Message-Id: <1333094685-5507-5-git-send-email-glommer@parallels.com>
In-Reply-To: <1333094685-5507-1-git-send-email-glommer@parallels.com>
References: <1333094685-5507-1-git-send-email-glommer@parallels.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: cgroups@vger.kernel.org
Cc: Li Zefan <lizefan@huawei.com>, kamezawa.hiroyu@jp.fujitsu.com, Tejun Heo <tj@kernel.org>, devel@openvz.org, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>, Linux MM <linux-mm@kvack.org>, Pavel Emelyanov <xemul@parallels.com>, Glauber Costa <glommer@parallels.com>

Preparation patch. Function is about to get complication to be
inline. Move it to the main file for consistency.

Signed-off-by: Glauber Costa <glommer@parallels.com>
---
 include/linux/res_counter.h |   17 ++---------------
 kernel/res_counter.c        |   14 ++++++++++++++
 2 files changed, 16 insertions(+), 15 deletions(-)

diff --git a/include/linux/res_counter.h b/include/linux/res_counter.h
index d4f3674..53b271c 100644
--- a/include/linux/res_counter.h
+++ b/include/linux/res_counter.h
@@ -188,21 +188,8 @@ static inline void res_counter_reset_failcnt(struct res_counter *cnt)
 	raw_spin_unlock_irqrestore(&cnt->usage_pcp.lock, flags);
 }
 
-static inline int res_counter_set_limit(struct res_counter *cnt,
-		unsigned long long limit)
-{
-	unsigned long flags;
-	int ret = -EBUSY;
-
-	raw_spin_lock_irqsave(&cnt->usage_pcp.lock, flags);
-	if (cnt->usage <= limit) {
-		cnt->limit = limit;
-		ret = 0;
-	}
-	raw_spin_unlock_irqrestore(&cnt->usage_pcp.lock, flags);
-	return ret;
-}
-
+int res_counter_set_limit(struct res_counter *cnt,
+			  unsigned long long limit);
 static inline int
 res_counter_set_soft_limit(struct res_counter *cnt,
 				unsigned long long soft_limit)
diff --git a/kernel/res_counter.c b/kernel/res_counter.c
index 70c46c9..052efaf 100644
--- a/kernel/res_counter.c
+++ b/kernel/res_counter.c
@@ -111,6 +111,20 @@ void res_counter_uncharge(struct res_counter *counter, unsigned long val)
 	local_irq_restore(flags);
 }
 
+int res_counter_set_limit(struct res_counter *cnt,
+			  unsigned long long limit)
+{
+	unsigned long flags;
+	int ret = -EBUSY;
+
+	raw_spin_lock_irqsave(&cnt->usage_pcp.lock, flags);
+	if (cnt->usage <= limit) {
+		cnt->limit = limit;
+		ret = 0;
+	}
+	raw_spin_unlock_irqrestore(&cnt->usage_pcp.lock, flags);
+	return ret;
+}
 
 static inline unsigned long long *
 res_counter_member(struct res_counter *counter, int member)
-- 
1.7.4.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
