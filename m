Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx126.postini.com [74.125.245.126])
	by kanga.kvack.org (Postfix) with SMTP id EBDCA6B005D
	for <linux-mm@kvack.org>; Tue,  3 Jul 2012 22:58:52 -0400 (EDT)
Received: from m4.gw.fujitsu.co.jp (unknown [10.0.50.74])
	by fgwmail6.fujitsu.co.jp (Postfix) with ESMTP id EC1CC3EE0B6
	for <linux-mm@kvack.org>; Wed,  4 Jul 2012 11:58:50 +0900 (JST)
Received: from smail (m4 [127.0.0.1])
	by outgoing.m4.gw.fujitsu.co.jp (Postfix) with ESMTP id D30AC45DE50
	for <linux-mm@kvack.org>; Wed,  4 Jul 2012 11:58:50 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (s4.gw.fujitsu.co.jp [10.0.50.94])
	by m4.gw.fujitsu.co.jp (Postfix) with ESMTP id BE0D645DE4D
	for <linux-mm@kvack.org>; Wed,  4 Jul 2012 11:58:50 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id B2CB31DB8037
	for <linux-mm@kvack.org>; Wed,  4 Jul 2012 11:58:50 +0900 (JST)
Received: from ml14.s.css.fujitsu.com (ml14.s.css.fujitsu.com [10.240.81.134])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id 6AC341DB803E
	for <linux-mm@kvack.org>; Wed,  4 Jul 2012 11:58:50 +0900 (JST)
Message-ID: <4FF3B0DC.5090508@jp.fujitsu.com>
Date: Wed, 04 Jul 2012 11:56:28 +0900
From: Kamezawa Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Subject: [PATCH v2 1/2] memcg: add res_counter_usage_safe()
Content-Type: text/plain; charset=ISO-2022-JP
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm <linux-mm@kvack.org>
Cc: David Rientjes <rientjes@google.com>, Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.cz>, Tejun Heo <tj@kernel.org>, Johannes Weiner <hannes@cmpxchg.org>

I think usage > limit means a sign of BUG. But, sometimes,
res_counter_charge_nofail() is very convenient. tcp_memcg uses it.
And I'd like to use it for helping page migration.

This patch adds res_counter_usage_safe() which returns min(usage,limit).
By this we can use res_counter_charge_nofail() without breaking
user experience.

Changelog:
 - read res_counter directrly under lock.
 - fixed comment.

Acked-by: Glauber Costa <glommer@parallels.com>
Acked-by: David Rientjes <rientjes@google.com>
Reviewed-by: Michal Hocko <mhocko@suse.cz>
Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
---
 include/linux/res_counter.h |    2 ++
 kernel/res_counter.c        |   18 ++++++++++++++++++
 net/ipv4/tcp_memcontrol.c   |    2 +-
 3 files changed, 21 insertions(+), 1 deletions(-)

diff --git a/include/linux/res_counter.h b/include/linux/res_counter.h
index 7d7fbe2..a6f8cc5 100644
--- a/include/linux/res_counter.h
+++ b/include/linux/res_counter.h
@@ -226,4 +226,6 @@ res_counter_set_soft_limit(struct res_counter *cnt,
 	return 0;
 }
 
+u64 res_counter_usage_safe(struct res_counter *cnt);
+
 #endif
diff --git a/kernel/res_counter.c b/kernel/res_counter.c
index ad581aa..f0507cd 100644
--- a/kernel/res_counter.c
+++ b/kernel/res_counter.c
@@ -171,6 +171,24 @@ u64 res_counter_read_u64(struct res_counter *counter, int member)
 }
 #endif
 
+/*
+ * Returns usage. If usage > limit, limit is returned.
+ * This is useful not to break user experiance if the excess
+ * is temporary.
+ */
+u64 res_counter_usage_safe(struct res_counter *counter)
+{
+	unsigned long flags;
+	u64 usage, limit;
+
+	spin_lock_irqsave(&counter->lock, flags);
+	limit = counter->limit;
+	usage = counter->usage;
+	spin_unlock_irqrestore(&counter->lock, flags);
+
+	return min(usage, limit);
+}
+
 int res_counter_memparse_write_strategy(const char *buf,
 					unsigned long long *res)
 {
diff --git a/net/ipv4/tcp_memcontrol.c b/net/ipv4/tcp_memcontrol.c
index b6f3583..a73dce6 100644
--- a/net/ipv4/tcp_memcontrol.c
+++ b/net/ipv4/tcp_memcontrol.c
@@ -180,7 +180,7 @@ static u64 tcp_read_usage(struct mem_cgroup *memcg)
 		return atomic_long_read(&tcp_memory_allocated) << PAGE_SHIFT;
 
 	tcp = tcp_from_cgproto(cg_proto);
-	return res_counter_read_u64(&tcp->tcp_memory_allocated, RES_USAGE);
+	return res_counter_usage_safe(&tcp->tcp_memory_allocated);
 }
 
 static u64 tcp_cgroup_read(struct cgroup *cont, struct cftype *cft)
-- 
1.7.4.1


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
