Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yh0-f44.google.com (mail-yh0-f44.google.com [209.85.213.44])
	by kanga.kvack.org (Postfix) with ESMTP id EACFA6B0031
	for <linux-mm@kvack.org>; Mon, 13 Jan 2014 20:51:24 -0500 (EST)
Received: by mail-yh0-f44.google.com with SMTP id f35so804939yha.3
        for <linux-mm@kvack.org>; Mon, 13 Jan 2014 17:51:24 -0800 (PST)
Received: from mail-pb0-x236.google.com (mail-pb0-x236.google.com [2607:f8b0:400e:c01::236])
        by mx.google.com with ESMTPS id v3si22880889yhv.169.2014.01.13.17.51.23
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Mon, 13 Jan 2014 17:51:23 -0800 (PST)
Received: by mail-pb0-f54.google.com with SMTP id un15so8015284pbc.41
        for <linux-mm@kvack.org>; Mon, 13 Jan 2014 17:51:22 -0800 (PST)
Date: Mon, 13 Jan 2014 17:50:49 -0800 (PST)
From: Hugh Dickins <hughd@google.com>
Subject: [PATCH 1/3] mm/memcg: fix last_dead_count memory wastage
Message-ID: <alpine.LSU.2.11.1401131742370.2229@eggly.anvils>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>
Cc: Johannes Weiner <hannes@cmpxchg.org>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

Shorten mem_cgroup_reclaim_iter.last_dead_count from unsigned long to
int: it's assigned from an int and compared with an int, and adjacent
to an unsigned int: so there's no point to it being unsigned long,
which wasted 104 bytes in every mem_cgroup_per_zone.
    
Signed-off-by: Hugh Dickins <hughd@google.com>
---
Putting this one first as it should be nicely uncontroversial.
I'm assuming much too late for v3.13, so all 3 diffed against mmotm.

 mm/memcontrol.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

--- mmotm/mm/memcontrol.c	2014-01-10 18:25:02.236448954 -0800
+++ linux/mm/memcontrol.c	2014-01-12 22:21:10.700570471 -0800
@@ -149,7 +149,7 @@ struct mem_cgroup_reclaim_iter {
 	 * matches memcg->dead_count of the hierarchy root group.
 	 */
 	struct mem_cgroup *last_visited;
-	unsigned long last_dead_count;
+	int last_dead_count;
 
 	/* scan generation, increased every round-trip */
 	unsigned int generation;

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
