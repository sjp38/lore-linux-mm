Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f179.google.com (mail-wi0-f179.google.com [209.85.212.179])
	by kanga.kvack.org (Postfix) with ESMTP id 12DD96B0075
	for <linux-mm@kvack.org>; Fri, 13 Feb 2015 11:37:53 -0500 (EST)
Received: by mail-wi0-f179.google.com with SMTP id hi2so13391427wib.0
        for <linux-mm@kvack.org>; Fri, 13 Feb 2015 08:37:52 -0800 (PST)
Received: from gum.cmpxchg.org (gum.cmpxchg.org. [85.214.110.215])
        by mx.google.com with ESMTPS id ey12si4637140wid.77.2015.02.13.08.37.51
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 13 Feb 2015 08:37:52 -0800 (PST)
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: [patch] mm: memcontrol: use "max" instead of "infinity" in control knobs
Date: Fri, 13 Feb 2015 11:37:40 -0500
Message-Id: <1423845460-14673-1-git-send-email-hannes@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Michal Hocko <mhocko@suse.cz>, Tejun Heo <tj@kernel.org>, Vladimir Davydov <vdavydov@parallels.com>, linux-mm@kvack.org, cgroups@vger.kernel.org, linux-kernel@vger.kernel.org

The memcg control knobs indicate the highest possible value using the
symbolic name "infinity", which is long and awkward to type.

Switch to the string "max", which is just as descriptive but shorter
and sweeter.

This changes a user interface, so do it before the release and before
the development flag is dropped from the default hierarchy.

Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>
Cc: Michal Hocko <mhocko@suse.cz>
Cc: Tejun Heo <tj@kernel.org>
---
 Documentation/cgroups/unified-hierarchy.txt |  4 ++--
 mm/memcontrol.c                             | 12 ++++++------
 2 files changed, 8 insertions(+), 8 deletions(-)

diff --git a/Documentation/cgroups/unified-hierarchy.txt b/Documentation/cgroups/unified-hierarchy.txt
index 71daa35ec2d9..eb102fb72213 100644
--- a/Documentation/cgroups/unified-hierarchy.txt
+++ b/Documentation/cgroups/unified-hierarchy.txt
@@ -404,8 +404,8 @@ supported and the interface files "release_agent" and
   be understood as an underflow into the highest possible value, -2 or
   -10M etc. do not work, so it's not consistent.
 
-  memory.low, memory.high, and memory.max will use the string
-  "infinity" to indicate and set the highest possible value.
+  memory.low, memory.high, and memory.max will use the string "max" to
+  indicate and set the highest possible value.
 
 5. Planned Changes
 
diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index d18d3a6e7337..ef1b0be6f8e1 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -5247,7 +5247,7 @@ static int memory_low_show(struct seq_file *m, void *v)
 	unsigned long low = ACCESS_ONCE(memcg->low);
 
 	if (low == PAGE_COUNTER_MAX)
-		seq_puts(m, "infinity\n");
+		seq_puts(m, "max\n");
 	else
 		seq_printf(m, "%llu\n", (u64)low * PAGE_SIZE);
 
@@ -5262,7 +5262,7 @@ static ssize_t memory_low_write(struct kernfs_open_file *of,
 	int err;
 
 	buf = strstrip(buf);
-	err = page_counter_memparse(buf, "infinity", &low);
+	err = page_counter_memparse(buf, "max", &low);
 	if (err)
 		return err;
 
@@ -5277,7 +5277,7 @@ static int memory_high_show(struct seq_file *m, void *v)
 	unsigned long high = ACCESS_ONCE(memcg->high);
 
 	if (high == PAGE_COUNTER_MAX)
-		seq_puts(m, "infinity\n");
+		seq_puts(m, "max\n");
 	else
 		seq_printf(m, "%llu\n", (u64)high * PAGE_SIZE);
 
@@ -5292,7 +5292,7 @@ static ssize_t memory_high_write(struct kernfs_open_file *of,
 	int err;
 
 	buf = strstrip(buf);
-	err = page_counter_memparse(buf, "infinity", &high);
+	err = page_counter_memparse(buf, "max", &high);
 	if (err)
 		return err;
 
@@ -5307,7 +5307,7 @@ static int memory_max_show(struct seq_file *m, void *v)
 	unsigned long max = ACCESS_ONCE(memcg->memory.limit);
 
 	if (max == PAGE_COUNTER_MAX)
-		seq_puts(m, "infinity\n");
+		seq_puts(m, "max\n");
 	else
 		seq_printf(m, "%llu\n", (u64)max * PAGE_SIZE);
 
@@ -5322,7 +5322,7 @@ static ssize_t memory_max_write(struct kernfs_open_file *of,
 	int err;
 
 	buf = strstrip(buf);
-	err = page_counter_memparse(buf, "infinity", &max);
+	err = page_counter_memparse(buf, "max", &max);
 	if (err)
 		return err;
 
-- 
2.3.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
