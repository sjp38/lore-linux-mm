Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f69.google.com (mail-pl0-f69.google.com [209.85.160.69])
	by kanga.kvack.org (Postfix) with ESMTP id 8EC306B000D
	for <linux-mm@kvack.org>; Mon, 11 Jun 2018 13:55:15 -0400 (EDT)
Received: by mail-pl0-f69.google.com with SMTP id 39-v6so1054879ple.6
        for <linux-mm@kvack.org>; Mon, 11 Jun 2018 10:55:15 -0700 (PDT)
Received: from mx0b-00082601.pphosted.com (mx0b-00082601.pphosted.com. [67.231.153.30])
        by mx.google.com with ESMTPS id q15-v6si38652432pls.358.2018.06.11.10.55.13
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 11 Jun 2018 10:55:14 -0700 (PDT)
From: Roman Gushchin <guro@fb.com>
Subject: [PATCH v2 2/3] mm, memcg: propagate memory effective protection on setting memory.min/low
Date: Mon, 11 Jun 2018 10:54:17 -0700
Message-ID: <20180611175418.7007-3-guro@fb.com>
In-Reply-To: <20180611175418.7007-1-guro@fb.com>
References: <20180611175418.7007-1-guro@fb.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@kernel.org>, Tejun Heo <tj@kernel.org>, linux-mm@kvack.org, kernel-team@fb.com, linux-kernel@vger.kernel.org, Roman Gushchin <guro@fb.com>, Vladimir Davydov <vdavydov.dev@gmail.com>, Greg Thelen <gthelen@google.com>, Shuah Khan <shuah@kernel.org>, Andrew Morton <akpm@linuxfoundation.org>

Explicitly propagate effective memory min/low values down by the tree.

If there is the global memory pressure, it's not really necessary.
Effective memory guarantees will be propagated automatically as we
traverse memory cgroup tree in the reclaim path.

But if there is no global memory pressure, effective memory protection
still matters for local (memcg-scoped) memory pressure.  So, we have to
update effective limits in the subtree, if a user changes memory.min and
memory.low values.

Link: http://lkml.kernel.org/r/20180522132528.23769-1-guro@fb.com
Signed-off-by: Roman Gushchin <guro@fb.com>
Cc: Johannes Weiner <hannes@cmpxchg.org>
Cc: Michal Hocko <mhocko@kernel.org>
Cc: Vladimir Davydov <vdavydov.dev@gmail.com>
Cc: Greg Thelen <gthelen@google.com>
Cc: Tejun Heo <tj@kernel.org>
Cc: Shuah Khan <shuah@kernel.org>
Signed-off-by: Andrew Morton <akpm@linuxfoundation.org>
---
 mm/memcontrol.c | 14 ++++++++++++--
 1 file changed, 12 insertions(+), 2 deletions(-)

diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index 5a3873e9d657..485df6f63d26 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -5084,7 +5084,7 @@ static int memory_min_show(struct seq_file *m, void *v)
 static ssize_t memory_min_write(struct kernfs_open_file *of,
 				char *buf, size_t nbytes, loff_t off)
 {
-	struct mem_cgroup *memcg = mem_cgroup_from_css(of_css(of));
+	struct mem_cgroup *iter, *memcg = mem_cgroup_from_css(of_css(of));
 	unsigned long min;
 	int err;
 
@@ -5095,6 +5095,11 @@ static ssize_t memory_min_write(struct kernfs_open_file *of,
 
 	page_counter_set_min(&memcg->memory, min);
 
+	rcu_read_lock();
+	for_each_mem_cgroup_tree(iter, memcg)
+		mem_cgroup_protected(NULL, iter);
+	rcu_read_unlock();
+
 	return nbytes;
 }
 
@@ -5114,7 +5119,7 @@ static int memory_low_show(struct seq_file *m, void *v)
 static ssize_t memory_low_write(struct kernfs_open_file *of,
 				char *buf, size_t nbytes, loff_t off)
 {
-	struct mem_cgroup *memcg = mem_cgroup_from_css(of_css(of));
+	struct mem_cgroup *iter, *memcg = mem_cgroup_from_css(of_css(of));
 	unsigned long low;
 	int err;
 
@@ -5125,6 +5130,11 @@ static ssize_t memory_low_write(struct kernfs_open_file *of,
 
 	page_counter_set_low(&memcg->memory, low);
 
+	rcu_read_lock();
+	for_each_mem_cgroup_tree(iter, memcg)
+		mem_cgroup_protected(NULL, iter);
+	rcu_read_unlock();
+
 	return nbytes;
 }
 
-- 
2.14.4
