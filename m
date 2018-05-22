Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f71.google.com (mail-wm0-f71.google.com [74.125.82.71])
	by kanga.kvack.org (Postfix) with ESMTP id 94C976B0006
	for <linux-mm@kvack.org>; Tue, 22 May 2018 09:28:45 -0400 (EDT)
Received: by mail-wm0-f71.google.com with SMTP id t195-v6so9546776wmt.9
        for <linux-mm@kvack.org>; Tue, 22 May 2018 06:28:45 -0700 (PDT)
Received: from mx0a-00082601.pphosted.com (mx0b-00082601.pphosted.com. [67.231.153.30])
        by mx.google.com with ESMTPS id a68-v6si2735189lfl.184.2018.05.22.06.28.43
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 22 May 2018 06:28:44 -0700 (PDT)
From: Roman Gushchin <guro@fb.com>
Subject: [PATCH 1/2] mm: propagate memory effective protection on setting memory.min/low
Date: Tue, 22 May 2018 14:25:27 +0100
Message-ID: <20180522132528.23769-1-guro@fb.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: kernel-team@fb.com, linux-kernel@vger.kernel.org, Roman Gushchin <guro@fb.com>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@kernel.org>, Vladimir Davydov <vdavydov.dev@gmail.com>, Greg Thelen <gthelen@google.com>, Tejun Heo <tj@kernel.org>, Andrew Morton <akpm@linux-foundation.org>

Explicitly propagate effective memory min/low values down by the tree.

If there is the global memory pressure, it's not really necessary.
Effective memory guarantees will be propagated automatically
as we traverse memory cgroup tree in the reclaim path.

But if there is no global memory pressure, effective memory protection
still matters for local (memcg-scoped) memory pressure.
So, we have to update effective limits in the subtree,
if a user changes memory.min and memory.low values.

Signed-off-by: Roman Gushchin <guro@fb.com>
Cc: Johannes Weiner <hannes@cmpxchg.org>
Cc: Michal Hocko <mhocko@kernel.org>
Cc: Vladimir Davydov <vdavydov.dev@gmail.com>
Cc: Greg Thelen <gthelen@google.com>
Cc: Tejun Heo <tj@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>
---
 mm/memcontrol.c | 14 ++++++++++++--
 1 file changed, 12 insertions(+), 2 deletions(-)

diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index ab5673dbfc4e..b9cd0bb63759 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -5374,7 +5374,7 @@ static int memory_min_show(struct seq_file *m, void *v)
 static ssize_t memory_min_write(struct kernfs_open_file *of,
 				char *buf, size_t nbytes, loff_t off)
 {
-	struct mem_cgroup *memcg = mem_cgroup_from_css(of_css(of));
+	struct mem_cgroup *iter, *memcg = mem_cgroup_from_css(of_css(of));
 	unsigned long min;
 	int err;
 
@@ -5385,6 +5385,11 @@ static ssize_t memory_min_write(struct kernfs_open_file *of,
 
 	page_counter_set_min(&memcg->memory, min);
 
+	rcu_read_lock();
+	for_each_mem_cgroup_tree(iter, memcg)
+		mem_cgroup_protected(NULL, iter);
+	rcu_read_unlock();
+
 	return nbytes;
 }
 
@@ -5404,7 +5409,7 @@ static int memory_low_show(struct seq_file *m, void *v)
 static ssize_t memory_low_write(struct kernfs_open_file *of,
 				char *buf, size_t nbytes, loff_t off)
 {
-	struct mem_cgroup *memcg = mem_cgroup_from_css(of_css(of));
+	struct mem_cgroup *iter, *memcg = mem_cgroup_from_css(of_css(of));
 	unsigned long low;
 	int err;
 
@@ -5415,6 +5420,11 @@ static ssize_t memory_low_write(struct kernfs_open_file *of,
 
 	page_counter_set_low(&memcg->memory, low);
 
+	rcu_read_lock();
+	for_each_mem_cgroup_tree(iter, memcg)
+		mem_cgroup_protected(NULL, iter);
+	rcu_read_unlock();
+
 	return nbytes;
 }
 
-- 
2.14.3
