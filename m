Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yh0-f41.google.com (mail-yh0-f41.google.com [209.85.213.41])
	by kanga.kvack.org (Postfix) with ESMTP id 3AD326B0031
	for <linux-mm@kvack.org>; Mon, 13 Jan 2014 20:52:58 -0500 (EST)
Received: by mail-yh0-f41.google.com with SMTP id i57so1240529yha.14
        for <linux-mm@kvack.org>; Mon, 13 Jan 2014 17:52:58 -0800 (PST)
Received: from mail-pd0-x22a.google.com (mail-pd0-x22a.google.com [2607:f8b0:400e:c02::22a])
        by mx.google.com with ESMTPS id t39si22920586yhp.25.2014.01.13.17.52.57
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Mon, 13 Jan 2014 17:52:57 -0800 (PST)
Received: by mail-pd0-f170.google.com with SMTP id z10so2837469pdj.29
        for <linux-mm@kvack.org>; Mon, 13 Jan 2014 17:52:56 -0800 (PST)
Date: Mon, 13 Jan 2014 17:52:30 -0800 (PST)
From: Hugh Dickins <hughd@google.com>
Subject: [PATCH 2/3] mm/memcg: fix endless iteration in reclaim
In-Reply-To: <alpine.LSU.2.11.1401131742370.2229@eggly.anvils>
Message-ID: <alpine.LSU.2.11.1401131751080.2229@eggly.anvils>
References: <alpine.LSU.2.11.1401131742370.2229@eggly.anvils>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>
Cc: Johannes Weiner <hannes@cmpxchg.org>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On one home machine I can easily reproduce (by rmdir of memcgdir during
reclaim) multiple processes stuck looping forever in mem_cgroup_iter():
__mem_cgroup_iter_next() keeps selecting the memcg being destroyed, fails
to tryget it, returns NULL to mem_cgroup_iter(), which goes around again.

It's better to err on the side of leaving the loop too soon than never
when such races occur: once we've served prev (using root if none),
get out the next time __mem_cgroup_iter_next() cannot deliver.

Signed-off-by: Hugh Dickins <hughd@google.com>
---
Securing the tree iterator against such races is difficult, I've
certainly got it wrong myself before.  Although the bug is real, and
deserves a Cc stable, you may want to play around with other solutions
before committing to this one.  The current iterator goes back to v3.12:
I'm really not sure if v3.11 was good or not - I never saw the problem
in the vanilla kernel, but with Google mods in we also had to make an
adjustment, there to stop __mem_cgroup_iter() being called endlessly
from the reclaim level.

 mm/memcontrol.c |    5 ++++-
 1 file changed, 4 insertions(+), 1 deletion(-)

--- mmotm/mm/memcontrol.c	2014-01-10 18:25:02.236448954 -0800
+++ linux/mm/memcontrol.c	2014-01-12 22:21:10.700570471 -0800
@@ -1254,8 +1252,11 @@ struct mem_cgroup *mem_cgroup_iter(struc
 				reclaim->generation = iter->generation;
 		}
 
-		if (prev && !memcg)
+		if (!memcg) {
+			if (!prev)
+				memcg = root;
 			goto out_unlock;
+		}
 	}
 out_unlock:
 	rcu_read_unlock();

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
