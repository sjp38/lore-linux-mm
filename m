Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f171.google.com (mail-wi0-f171.google.com [209.85.212.171])
	by kanga.kvack.org (Postfix) with ESMTP id DEFBD6B0038
	for <linux-mm@kvack.org>; Wed, 21 Oct 2015 14:50:07 -0400 (EDT)
Received: by wicll6 with SMTP id ll6so87983954wic.1
        for <linux-mm@kvack.org>; Wed, 21 Oct 2015 11:50:07 -0700 (PDT)
Received: from gum.cmpxchg.org (gum.cmpxchg.org. [85.214.110.215])
        by mx.google.com with ESMTPS id jt2si13395175wjc.99.2015.10.21.11.50.06
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 21 Oct 2015 11:50:06 -0700 (PDT)
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: [PATCH] mm: memcontrol: eliminate root memory.current
Date: Wed, 21 Oct 2015 14:49:54 -0400
Message-Id: <1445453394-15156-1-git-send-email-hannes@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, cgroups@vger.kernel.org, linux-kernel@vger.kernel.org, Michal Hocko <mhocko@suse.cz>, Tejun Heo <tj@kernel.org>

memory.current on the root level doesn't add anything that wouldn't be
more accurate and detailed using system statistics. It already doesn't
include slabs, and it'll be a pain to keep in sync when further memory
types are accounted in the memory controller. Remove it.

Note that this applies to the new unified hierarchy interface only.

Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>
---
 mm/memcontrol.c | 3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

Tejun, we should probably do this with the other controllers too.
I don't think it makes sense anywhere to shoddily duplicate the
system statistics on the controller root levels.

diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index 4f04510..c71fe40 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -5022,7 +5022,7 @@ static void mem_cgroup_bind(struct cgroup_subsys_state *root_css)
 static u64 memory_current_read(struct cgroup_subsys_state *css,
 			       struct cftype *cft)
 {
-	return mem_cgroup_usage(mem_cgroup_from_css(css), false);
+	return page_counter_read(&mem_cgroup_from_css(css)->memory);
 }
 
 static int memory_low_show(struct seq_file *m, void *v)
@@ -5134,6 +5134,7 @@ static int memory_events_show(struct seq_file *m, void *v)
 static struct cftype memory_files[] = {
 	{
 		.name = "current",
+		.flags = CFTYPE_NOT_ON_ROOT,
 		.read_u64 = memory_current_read,
 	},
 	{
-- 
2.6.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
