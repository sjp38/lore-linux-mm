Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ee0-f44.google.com (mail-ee0-f44.google.com [74.125.83.44])
	by kanga.kvack.org (Postfix) with ESMTP id AC3F46B003A
	for <linux-mm@kvack.org>; Wed, 11 Dec 2013 09:16:43 -0500 (EST)
Received: by mail-ee0-f44.google.com with SMTP id b57so2940456eek.3
        for <linux-mm@kvack.org>; Wed, 11 Dec 2013 06:16:43 -0800 (PST)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTP id e48si19238364eeh.113.2013.12.11.06.16.42
        for <linux-mm@kvack.org>;
        Wed, 11 Dec 2013 06:16:43 -0800 (PST)
From: Michal Hocko <mhocko@suse.cz>
Subject: [RFC 3/4] memcg: Allow setting low_limit
Date: Wed, 11 Dec 2013 15:15:54 +0100
Message-Id: <1386771355-21805-4-git-send-email-mhocko@suse.cz>
In-Reply-To: <1386771355-21805-1-git-send-email-mhocko@suse.cz>
References: <1386771355-21805-1-git-send-email-mhocko@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, Johannes Weiner <hannes@cmpxchg.org>, Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: LKML <linux-kernel@vger.kernel.org>, Ying Han <yinghan@google.com>, Hugh Dickins <hughd@google.com>, Michel Lespinasse <walken@google.com>, Greg Thelen <gthelen@google.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Tejun Heo <tj@kernel.org>

Export memory.low_limit_in_bytes knob with the same rules as the hard
limit represented by limit_in_bytes knob (e.g. no limit to be set for
the root cgroup). There is no memsw alternative for low_limit_in_bytes
because the primary motivation behind this limit is to protect the
working set of the group and so considering swap doesn't make much
sense. There is also no kmem variant exported because we do not have any
easy way to protect kernel allocations now.

Please note that the low limit might exceed the hard limit which
basically means that the group is never reclaimable. If the hard limit
is reached with this setting then the memcg OOM killer is triggered to
sort out the situation.

TODO: update Documentation/cgroups/memory.txt

Signed-off-by: Michal Hocko <mhocko@suse.cz>
---
 include/linux/res_counter.h | 13 +++++++++++++
 kernel/res_counter.c        |  2 ++
 mm/memcontrol.c             | 27 ++++++++++++++++++++++++++-
 3 files changed, 41 insertions(+), 1 deletion(-)

diff --git a/include/linux/res_counter.h b/include/linux/res_counter.h
index c7e7dfeca847..7befcf3c2ee2 100644
--- a/include/linux/res_counter.h
+++ b/include/linux/res_counter.h
@@ -93,6 +93,7 @@ enum {
 	RES_LIMIT,
 	RES_FAILCNT,
 	RES_SOFT_LIMIT,
+	RES_LOW_LIMIT,
 };
 
 /*
@@ -251,4 +252,16 @@ res_counter_set_soft_limit(struct res_counter *cnt,
 	return 0;
 }
 
+static inline int
+res_counter_set_low_limit(struct res_counter *cnt,
+				unsigned long long low_limit)
+{
+	unsigned long flags;
+
+	spin_lock_irqsave(&cnt->lock, flags);
+	cnt->low_limit = low_limit;
+	spin_unlock_irqrestore(&cnt->lock, flags);
+	return 0;
+}
+
 #endif
diff --git a/kernel/res_counter.c b/kernel/res_counter.c
index 4aa8a305aede..c57daf997d9d 100644
--- a/kernel/res_counter.c
+++ b/kernel/res_counter.c
@@ -135,6 +135,8 @@ res_counter_member(struct res_counter *counter, int member)
 		return &counter->failcnt;
 	case RES_SOFT_LIMIT:
 		return &counter->soft_limit;
+	case RES_LOW_LIMIT:
+		return &counter->low_limit;
 	};
 
 	BUG();
diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index 102e2da9ec8d..afe7c84d823f 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -1694,8 +1694,9 @@ void mem_cgroup_print_oom_info(struct mem_cgroup *memcg, struct task_struct *p)
 	pr_cont(" as a result of limit of %s\n", memcg_name);
 done:
 
-	pr_info("memory: usage %llukB, limit %llukB, failcnt %llu\n",
+	pr_info("memory: usage %llukB, low_limit %llukB limit %llukB, failcnt %llu\n",
 		res_counter_read_u64(&memcg->res, RES_USAGE) >> 10,
+		res_counter_read_u64(&memcg->res, RES_LOW_LIMIT) >> 10,
 		res_counter_read_u64(&memcg->res, RES_LIMIT) >> 10,
 		res_counter_read_u64(&memcg->res, RES_FAILCNT));
 	pr_info("memory+swap: usage %llukB, limit %llukB, failcnt %llu\n",
@@ -5300,6 +5301,24 @@ static int mem_cgroup_write(struct cgroup_subsys_state *css, struct cftype *cft,
 		else
 			return -EINVAL;
 		break;
+	case RES_LOW_LIMIT:
+		if (mem_cgroup_is_root(memcg)) { /* Can't set limit on root */
+			ret = -EINVAL;
+			break;
+		}
+		ret = res_counter_memparse_write_strategy(buffer, &val);
+		if (ret)
+			break;
+		if (type == _MEM) {
+			ret = res_counter_set_low_limit(&memcg->res, val);
+			break;
+		}
+		/*
+		 * memsw low limit doesn't make any sense and kmem is not
+		 * implemented yet - if ever
+		 */
+		return -EINVAL;
+
 	case RES_SOFT_LIMIT:
 		ret = res_counter_memparse_write_strategy(buffer, &val);
 		if (ret)
@@ -6013,6 +6032,12 @@ static struct cftype mem_cgroup_files[] = {
 		.read = mem_cgroup_read,
 	},
 	{
+		.name = "low_limit_in_bytes",
+		.private = MEMFILE_PRIVATE(_MEM, RES_LOW_LIMIT),
+		.write_string = mem_cgroup_write,
+		.read = mem_cgroup_read,
+	},
+	{
 		.name = "soft_limit_in_bytes",
 		.private = MEMFILE_PRIVATE(_MEM, RES_SOFT_LIMIT),
 		.write_string = mem_cgroup_write,
-- 
1.8.4.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
