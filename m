Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ee0-f41.google.com (mail-ee0-f41.google.com [74.125.83.41])
	by kanga.kvack.org (Postfix) with ESMTP id 83A5D6B0037
	for <linux-mm@kvack.org>; Mon, 28 Apr 2014 08:27:07 -0400 (EDT)
Received: by mail-ee0-f41.google.com with SMTP id t10so4882476eei.28
        for <linux-mm@kvack.org>; Mon, 28 Apr 2014 05:27:06 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id m49si22936229eeo.101.2014.04.28.05.27.05
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Mon, 28 Apr 2014 05:27:06 -0700 (PDT)
From: Michal Hocko <mhocko@suse.cz>
Subject: [PATCH 2/4] memcg: Allow setting low_limit
Date: Mon, 28 Apr 2014 14:26:43 +0200
Message-Id: <1398688005-26207-3-git-send-email-mhocko@suse.cz>
In-Reply-To: <1398688005-26207-1-git-send-email-mhocko@suse.cz>
References: <1398688005-26207-1-git-send-email-mhocko@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>, Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Greg Thelen <gthelen@google.com>, Michel Lespinasse <walken@google.com>, Tejun Heo <tj@kernel.org>, Hugh Dickins <hughd@google.com>, Roman Gushchin <klamm@yandex-team.ru>, LKML <linux-kernel@vger.kernel.org>, linux-mm@kvack.org

Export memory.low_limit_in_bytes knob with the same rules as the hard
limit represented by limit_in_bytes knob (e.g. no limit to be set for
the root cgroup). There is no memsw alternative for low_limit_in_bytes
because the primary motivation behind this limit is to protect the
working set of the group and so considering swap doesn't make much
sense. There is also no kmem variant exported because we do not have any
easy way to protect kernel allocations now.

Please note that the low limit might exceed the hard limit which
basically means that the group is not reclaimable if there is other
reclaim target in the hierarchy under pressure.

Signed-off-by: Michal Hocko <mhocko@suse.cz>
---
 include/linux/res_counter.h | 13 +++++++++++++
 kernel/res_counter.c        |  2 ++
 mm/memcontrol.c             | 27 ++++++++++++++++++++++++++-
 3 files changed, 41 insertions(+), 1 deletion(-)

diff --git a/include/linux/res_counter.h b/include/linux/res_counter.h
index 408724eeec71..b810855024f9 100644
--- a/include/linux/res_counter.h
+++ b/include/linux/res_counter.h
@@ -93,6 +93,7 @@ enum {
 	RES_LIMIT,
 	RES_FAILCNT,
 	RES_SOFT_LIMIT,
+	RES_LOW_LIMIT,
 };
 
 /*
@@ -247,4 +248,16 @@ res_counter_set_soft_limit(struct res_counter *cnt,
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
index 51dbac6a3633..e851a9ad50bf 100644
--- a/kernel/res_counter.c
+++ b/kernel/res_counter.c
@@ -136,6 +136,8 @@ res_counter_member(struct res_counter *counter, int member)
 		return &counter->failcnt;
 	case RES_SOFT_LIMIT:
 		return &counter->soft_limit;
+	case RES_LOW_LIMIT:
+		return &counter->low_limit;
 	};
 
 	BUG();
diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index 40e517630138..53193fec8c50 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -1695,8 +1695,9 @@ void mem_cgroup_print_oom_info(struct mem_cgroup *memcg, struct task_struct *p)
 
 	rcu_read_unlock();
 
-	pr_info("memory: usage %llukB, limit %llukB, failcnt %llu\n",
+	pr_info("memory: usage %llukB, low_limit %llukB limit %llukB, failcnt %llu\n",
 		res_counter_read_u64(&memcg->res, RES_USAGE) >> 10,
+		res_counter_read_u64(&memcg->res, RES_LOW_LIMIT) >> 10,
 		res_counter_read_u64(&memcg->res, RES_LIMIT) >> 10,
 		res_counter_read_u64(&memcg->res, RES_FAILCNT));
 	pr_info("memory+swap: usage %llukB, limit %llukB, failcnt %llu\n",
@@ -5134,6 +5135,24 @@ static int mem_cgroup_write(struct cgroup_subsys_state *css, struct cftype *cft,
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
@@ -6056,6 +6075,12 @@ static struct cftype mem_cgroup_files[] = {
 		.read_u64 = mem_cgroup_read_u64,
 	},
 	{
+		.name = "low_limit_in_bytes",
+		.private = MEMFILE_PRIVATE(_MEM, RES_LOW_LIMIT),
+		.write_string = mem_cgroup_write,
+		.read_u64 = mem_cgroup_read_u64,
+	},
+	{
 		.name = "soft_limit_in_bytes",
 		.private = MEMFILE_PRIVATE(_MEM, RES_SOFT_LIMIT),
 		.write_string = mem_cgroup_write,
-- 
2.0.0.rc0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
