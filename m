Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx173.postini.com [74.125.245.173])
	by kanga.kvack.org (Postfix) with SMTP id 9F85C6B004D
	for <linux-mm@kvack.org>; Sun, 22 Jan 2012 11:47:36 -0500 (EST)
Received: by wgbdt12 with SMTP id dt12so1793408wgb.26
        for <linux-mm@kvack.org>; Sun, 22 Jan 2012 08:47:34 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <CAJd=RBC8dCGgqXqP+yjW2+pVoSeFXwXfjx8DLHhMuY8goOadZw@mail.gmail.com>
References: <CAJd=RBC8dCGgqXqP+yjW2+pVoSeFXwXfjx8DLHhMuY8goOadZw@mail.gmail.com>
Date: Mon, 23 Jan 2012 00:47:34 +0800
Message-ID: <CAJd=RBBqp3bMGwFc14BJ7+=KsfO0gLnrnXwbRdLDYOJDdvbptA@mail.gmail.com>
Subject: Re: [PATCH] mm: vmscan: ensure reclaiming pages on the lru lists of zone
From: Hillf Danton <dhillf@gmail.com>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: Michal Hocko <mhocko@suse.cz>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Ying Han <yinghan@google.com>, Hugh Dickins <hughd@google.com>, Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>, Hillf Danton <dhillf@gmail.com>

Hi all

For easy review, it is re-prepared based on 3.3-rc1.

Thanks
Hillf

===cut please===
From: Hillf Danton <dhillf@gmail.com>
Subject: [PATCH] mm: vmscan: ensure reclaiming pages on the lru lists of zone

While iterating over memory cgroup hierarchy, pages are reclaimed from each
mem cgroup, and reclaim terminates after a full round-trip. It is possible
that no pages on the lru lists of given zone are reclaimed, as termination
is checked after the reclaiming function.

Mem cgroup iteration is rearranged a bit to make sure that pages are reclaimed
from both mem cgroups and zone.

Signed-off-by: Hillf Danton <dhillf@gmail.com>
---

--- a/mm/vmscan.c	Mon Jan 23 00:23:10 2012
+++ b/mm/vmscan.c	Mon Jan 23 00:26:44 2012
@@ -2142,14 +2142,14 @@ static void shrink_zone(int priority, st
 		.zone = zone,
 		.priority = priority,
 	};
-	struct mem_cgroup *memcg;
+	struct mem_cgroup_zone mz = {
+		.zone = zone,
+	};
+	struct mem_cgroup *memcg = NULL;

-	memcg = mem_cgroup_iter(root, NULL, &reclaim);
 	do {
-		struct mem_cgroup_zone mz = {
-			.mem_cgroup = memcg,
-			.zone = zone,
-		};
+		memcg = mem_cgroup_iter(root, memcg, &reclaim);
+		mz.mem_cgroup = memcg;

 		shrink_mem_cgroup_zone(priority, &mz, sc);
 		/*
@@ -2166,7 +2166,6 @@ static void shrink_zone(int priority, st
 			mem_cgroup_iter_break(root, memcg);
 			break;
 		}
-		memcg = mem_cgroup_iter(root, memcg, &reclaim);
 	} while (memcg);
 }

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
