Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ee0-f41.google.com (mail-ee0-f41.google.com [74.125.83.41])
	by kanga.kvack.org (Postfix) with ESMTP id B880D6B0038
	for <linux-mm@kvack.org>; Wed, 15 Jan 2014 10:01:27 -0500 (EST)
Received: by mail-ee0-f41.google.com with SMTP id e49so957334eek.28
        for <linux-mm@kvack.org>; Wed, 15 Jan 2014 07:01:27 -0800 (PST)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id j47si8192881eeo.179.2014.01.15.07.01.22
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Wed, 15 Jan 2014 07:01:22 -0800 (PST)
From: Michal Hocko <mhocko@suse.cz>
Subject: [RFC 2/3] memcg: do not check PF_EXITING in mem_cgroup_out_of_memory
Date: Wed, 15 Jan 2014 16:01:07 +0100
Message-Id: <1389798068-19885-3-git-send-email-mhocko@suse.cz>
In-Reply-To: <1389798068-19885-1-git-send-email-mhocko@suse.cz>
References: <1389798068-19885-1-git-send-email-mhocko@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: LKML <linux-kernel@vger.kernel.org>, Johannes Weiner <hannes@cmpxchg.org>, David Rientjes <rientjes@google.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Andrew Morton <akpm@linux-foundation.org>

because all tasks with PF_EXITING will skip the charge since (memcg: do
not hang on OOM when killed by userspace OOM access to memory reserves)
was merged.

Signed-off-by: Michal Hocko <mhocko@suse.cz>
---
 mm/memcontrol.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index 491d368ae488..97ae5cf12f5e 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -1766,7 +1766,7 @@ static void mem_cgroup_out_of_memory(struct mem_cgroup *memcg, gfp_t gfp_mask,
 	 * select it.  The goal is to allow it to allocate so that it may
 	 * quickly exit and free its memory.
 	 */
-	if (fatal_signal_pending(current) || current->flags & PF_EXITING) {
+	if (fatal_signal_pending(current)) {
 		set_thread_flag(TIF_MEMDIE);
 		return;
 	}
-- 
1.8.5.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
