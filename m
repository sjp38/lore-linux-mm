Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f176.google.com (mail-pd0-f176.google.com [209.85.192.176])
	by kanga.kvack.org (Postfix) with ESMTP id 56AA86B00AF
	for <linux-mm@kvack.org>; Thu, 11 Sep 2014 11:42:39 -0400 (EDT)
Received: by mail-pd0-f176.google.com with SMTP id y13so9845699pdi.7
        for <linux-mm@kvack.org>; Thu, 11 Sep 2014 08:42:39 -0700 (PDT)
Received: from mx2.parallels.com (mx2.parallels.com. [199.115.105.18])
        by mx.google.com with ESMTPS id e4si2416655pdj.133.2014.09.11.08.42.37
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 11 Sep 2014 08:42:38 -0700 (PDT)
From: Vladimir Davydov <vdavydov@parallels.com>
Subject: [PATCH RFC 2/2] memcg: add threshold for anon rss
Date: Thu, 11 Sep 2014 19:41:50 +0400
Message-ID: <b7e7abb6cadc1301a775177ef3d4f4944192c579.1410447097.git.vdavydov@parallels.com>
In-Reply-To: <cover.1410447097.git.vdavydov@parallels.com>
References: <cover.1410447097.git.vdavydov@parallels.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: Kamezawa Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>, Greg Thelen <gthelen@google.com>, Hugh Dickins <hughd@google.com>, Motohiro Kosaki <Motohiro.Kosaki@us.fujitsu.com>, Glauber Costa <glommer@gmail.com>, Tejun Heo <tj@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Pavel Emelianov <xemul@parallels.com>, Konstantin Khorenko <khorenko@parallels.com>, linux-mm@kvack.org, cgroups@vger.kernel.org

Though hard memory limits suit perfectly for sand-boxing, they are not
that efficient when it comes to partitioning a server's resources among
multiple containers. The point is a container consuming a particular
amount of memory most of time may have infrequent spikes in the load.
Setting the hard limit to the maximal possible usage (spike) will lower
server utilization while setting it to the "normal" usage will result in
heavy lags during the spikes.

To handle such scenarios soft limits were introduced. The idea is to
allow a container to breach the limit freely when there's enough free
memory, but shrink it back to the limit aggressively on global memory
pressure. However, the concept of soft limits is intrinsically unsafe
by itself: if a container eats too much anonymous memory, it will be
very slow or even impossible (if there's no swap) to reclaim its
resources back to the limit. As a result the whole system will be
feeling bad until it finally realizes the culprit must die.

Currently we have no way to react to anonymous memory + swap usage
growth inside a container: the memsw counter accounts both anonymous
memory and file caches and swap, so we have neither a limit for
anon+swap nor a threshold notification. Actually, memsw is totally
useless if one wants to make full use of soft limits: it should be set
to a very large value or infinity then, otherwise it just makes no
sense.

That's one of the reasons why I think we should replace memsw with a
kind of anonsw so that it'd account only anon+swap. This way we'd still
be able to sand-box apps, but it'd also allow us to avoid nasty
surprises like the one I described above. For more arguments for and
against this idea, please see the following thread:

http://www.spinics.net/lists/linux-mm/msg78180.html

There's an alternative to this approach backed by Kamezawa. He thinks
that OOM on anon+swap limit hit is a no-go and proposes to use memory
thresholds for it. I still strongly disagree with the proposal, because
it's unsafe (what if the userspace handler won't react in time?).
Nevertheless, I implement his idea in this RFC. I hope this will fuel
the debate, because sadly enough nobody seems to care about this
problem.

So this patch adds the "memory.rss" file that shows the amount of
anonymous memory consumed by a cgroup and the event to handle threshold
notifications coming from it. The notification works exactly in the same
fashion as the existing memory/memsw usage notifications.

Please note this is improper implementation - we should rework
thresholds interface first.

Signed-off-by: Vladimir Davydov <vdavydov@parallels.com>
---
 mm/memcontrol.c |   61 +++++++++++++++++++++++++++++++++++++++++++++++--------
 1 file changed, 53 insertions(+), 8 deletions(-)

diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index 7e8d65e0608a..2cb4e498bc5f 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -325,6 +325,9 @@ struct mem_cgroup {
 	/* thresholds for mem+swap usage. RCU-protected */
 	struct mem_cgroup_thresholds memsw_thresholds;
 
+	/* thresholds for anonymous memory usage. RCU-protected */
+	struct mem_cgroup_thresholds rss_thresholds;
+
 	/* For oom notifier event fd */
 	struct list_head oom_notify;
 
@@ -464,6 +467,7 @@ enum res_type {
 	_MEMSWAP,
 	_OOM_TYPE,
 	_KMEM,
+	_RSS,
 };
 
 #define MEMFILE_PRIVATE(x, val)	((x) << 16 | (val))
@@ -4076,6 +4080,10 @@ static u64 mem_cgroup_read_u64(struct cgroup_subsys_state *css,
 		if (name == RES_USAGE)
 			return mem_cgroup_usage(memcg, true);
 		return res_counter_read_u64(&memcg->memsw, name);
+	case _RSS:
+		BUG_ON(name != RES_USAGE);
+		return mem_cgroup_recursive_stat(memcg, MEM_CGROUP_STAT_RSS)
+								<< PAGE_SHIFT;
 	case _KMEM:
 		return res_counter_read_u64(&memcg->kmem, name);
 		break;
@@ -4528,22 +4536,30 @@ static int mem_cgroup_swappiness_write(struct cgroup_subsys_state *css,
 	return 0;
 }
 
-static void __mem_cgroup_threshold(struct mem_cgroup *memcg, bool swap)
+static void __mem_cgroup_threshold(struct mem_cgroup *memcg, enum res_type type)
 {
 	struct mem_cgroup_threshold_ary *t;
 	u64 usage;
 	int i;
 
 	rcu_read_lock();
-	if (!swap)
+	if (type == _MEM)
 		t = rcu_dereference(memcg->thresholds.primary);
-	else
+	else if (type == _MEMSWAP)
 		t = rcu_dereference(memcg->memsw_thresholds.primary);
+	else if (type == _RSS)
+		t = rcu_dereference(memcg->rss_thresholds.primary);
+	else
+		BUG();
 
 	if (!t)
 		goto unlock;
 
-	usage = mem_cgroup_usage(memcg, swap);
+	if (type == _RSS)
+		usage = mem_cgroup_recursive_stat(memcg, MEM_CGROUP_STAT_RSS)
+								<< PAGE_SHIFT;
+	else
+		usage = mem_cgroup_usage(memcg, type == _MEMSWAP);
 
 	/*
 	 * current_threshold points to threshold just below or equal to usage.
@@ -4582,9 +4598,10 @@ unlock:
 static void mem_cgroup_threshold(struct mem_cgroup *memcg)
 {
 	while (memcg) {
-		__mem_cgroup_threshold(memcg, false);
+		__mem_cgroup_threshold(memcg, _MEM);
 		if (do_swap_account)
-			__mem_cgroup_threshold(memcg, true);
+			__mem_cgroup_threshold(memcg, _MEMSWAP);
+		__mem_cgroup_threshold(memcg, _RSS);
 
 		memcg = parent_mem_cgroup(memcg);
 	}
@@ -4645,12 +4662,16 @@ static int __mem_cgroup_usage_register_event(struct mem_cgroup *memcg,
 	} else if (type == _MEMSWAP) {
 		thresholds = &memcg->memsw_thresholds;
 		usage = mem_cgroup_usage(memcg, true);
+	} else if (type == _RSS) {
+		thresholds = &memcg->rss_thresholds;
+		usage = mem_cgroup_recursive_stat(memcg, MEM_CGROUP_STAT_RSS)
+								<< PAGE_SHIFT;
 	} else
 		BUG();
 
 	/* Check if a threshold crossed before adding a new one */
 	if (thresholds->primary)
-		__mem_cgroup_threshold(memcg, type == _MEMSWAP);
+		__mem_cgroup_threshold(memcg, type);
 
 	size = thresholds->primary ? thresholds->primary->size + 1 : 1;
 
@@ -4718,6 +4739,12 @@ static int memsw_cgroup_usage_register_event(struct mem_cgroup *memcg,
 	return __mem_cgroup_usage_register_event(memcg, eventfd, args, _MEMSWAP);
 }
 
+static int mem_cgroup_rss_register_event(struct mem_cgroup *memcg,
+	struct eventfd_ctx *eventfd, const char *args)
+{
+	return __mem_cgroup_usage_register_event(memcg, eventfd, args, _RSS);
+}
+
 static void __mem_cgroup_usage_unregister_event(struct mem_cgroup *memcg,
 	struct eventfd_ctx *eventfd, enum res_type type)
 {
@@ -4734,6 +4761,10 @@ static void __mem_cgroup_usage_unregister_event(struct mem_cgroup *memcg,
 	} else if (type == _MEMSWAP) {
 		thresholds = &memcg->memsw_thresholds;
 		usage = mem_cgroup_usage(memcg, true);
+	} else if (type == _RSS) {
+		thresholds = &memcg->rss_thresholds;
+		usage = mem_cgroup_recursive_stat(memcg, MEM_CGROUP_STAT_RSS)
+								<< PAGE_SHIFT;
 	} else
 		BUG();
 
@@ -4741,7 +4772,7 @@ static void __mem_cgroup_usage_unregister_event(struct mem_cgroup *memcg,
 		goto unlock;
 
 	/* Check if a threshold crossed before removing */
-	__mem_cgroup_threshold(memcg, type == _MEMSWAP);
+	__mem_cgroup_threshold(memcg, type);
 
 	/* Calculate new number of threshold */
 	size = 0;
@@ -4808,6 +4839,12 @@ static void memsw_cgroup_usage_unregister_event(struct mem_cgroup *memcg,
 	return __mem_cgroup_usage_unregister_event(memcg, eventfd, _MEMSWAP);
 }
 
+static void mem_cgroup_rss_unregister_event(struct mem_cgroup *memcg,
+	struct eventfd_ctx *eventfd)
+{
+	return __mem_cgroup_usage_unregister_event(memcg, eventfd, _RSS);
+}
+
 static int mem_cgroup_oom_register_event(struct mem_cgroup *memcg,
 	struct eventfd_ctx *eventfd, const char *args)
 {
@@ -5112,6 +5149,9 @@ static ssize_t memcg_write_event_control(struct kernfs_open_file *of,
 	} else if (!strcmp(name, "memory.memsw.usage_in_bytes")) {
 		event->register_event = memsw_cgroup_usage_register_event;
 		event->unregister_event = memsw_cgroup_usage_unregister_event;
+	} else if (!strcmp(name, "memory.rss")) {
+		event->register_event = mem_cgroup_rss_register_event;
+		event->unregister_event = mem_cgroup_rss_unregister_event;
 	} else {
 		ret = -EINVAL;
 		goto out_put_cfile;
@@ -5192,6 +5232,11 @@ static struct cftype mem_cgroup_files[] = {
 		.read_u64 = mem_cgroup_read_u64,
 	},
 	{
+		.name = "rss",
+		.private = MEMFILE_PRIVATE(_RSS, RES_USAGE),
+		.read_u64 = mem_cgroup_read_u64,
+	},
+	{
 		.name = "stat",
 		.seq_show = memcg_stat_show,
 	},
-- 
1.7.10.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
