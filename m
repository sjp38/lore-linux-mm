Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f43.google.com (mail-wm0-f43.google.com [74.125.82.43])
	by kanga.kvack.org (Postfix) with ESMTP id 579B46B0254
	for <linux-mm@kvack.org>; Thu, 10 Mar 2016 15:51:35 -0500 (EST)
Received: by mail-wm0-f43.google.com with SMTP id l68so3574259wml.0
        for <linux-mm@kvack.org>; Thu, 10 Mar 2016 12:51:35 -0800 (PST)
Received: from gum.cmpxchg.org (gum.cmpxchg.org. [85.214.110.215])
        by mx.google.com with ESMTPS id i6si405706wmf.31.2016.03.10.12.51.34
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 10 Mar 2016 12:51:34 -0800 (PST)
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: [PATCH] mm: memcontrol: reclaim when shrinking memory.high below usage
Date: Thu, 10 Mar 2016 15:50:13 -0500
Message-Id: <1457643015-8828-1-git-send-email-hannes@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Michal Hocko <mhocko@suse.cz>, Vladimir Davydov <vdavydov@virtuozzo.com>, linux-mm@kvack.org, cgroups@vger.kernel.org, linux-kernel@vger.kernel.org, kernel-team@fb.com

When setting memory.high below usage, nothing happens until the next
charge comes along, and then it will only reclaim its own charge and
not the now potentially huge excess of the new memory.high. This can
cause groups to stay in excess of their memory.high indefinitely.

To fix that, when shrinking memory.high, kick off a reclaim cycle that
goes after the delta.

Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>
---
 mm/memcontrol.c | 6 ++++++
 1 file changed, 6 insertions(+)

diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index 8615b066b642..f7c9b4cbdf01 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -4992,6 +4992,7 @@ static ssize_t memory_high_write(struct kernfs_open_file *of,
 				 char *buf, size_t nbytes, loff_t off)
 {
 	struct mem_cgroup *memcg = mem_cgroup_from_css(of_css(of));
+	unsigned long nr_pages;
 	unsigned long high;
 	int err;
 
@@ -5002,6 +5003,11 @@ static ssize_t memory_high_write(struct kernfs_open_file *of,
 
 	memcg->high = high;
 
+	nr_pages = page_counter_read(&memcg->memory);
+	if (nr_pages > high)
+		try_to_free_mem_cgroup_pages(memcg, nr_pages - high,
+					     GFP_KERNEL, true);
+
 	memcg_wb_domain_size_changed(memcg);
 	return nbytes;
 }
-- 
2.7.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
