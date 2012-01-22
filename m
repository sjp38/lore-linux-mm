Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx176.postini.com [74.125.245.176])
	by kanga.kvack.org (Postfix) with SMTP id DEA956B004D
	for <linux-mm@kvack.org>; Sat, 21 Jan 2012 22:08:22 -0500 (EST)
Received: by wgbdt12 with SMTP id dt12so1545206wgb.26
        for <linux-mm@kvack.org>; Sat, 21 Jan 2012 19:08:21 -0800 (PST)
MIME-Version: 1.0
Date: Sun, 22 Jan 2012 11:08:20 +0800
Message-ID: <CAJd=RBC8dCGgqXqP+yjW2+pVoSeFXwXfjx8DLHhMuY8goOadZw@mail.gmail.com>
Subject: [PATCH] mm: vmscan: ensure reclaiming pages on the lru lists of zone
From: Hillf Danton <dhillf@gmail.com>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: Michal Hocko <mhocko@suse.cz>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Ying Han <yinghan@google.com>, Hugh Dickins <hughd@google.com>, Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>, Hillf Danton <dhillf@gmail.com>

It is possible that the memcg input into shrink_mem_cgroup_zone() in
each round is not NULL, and the loop terminates at NULL case. And there
is chance that pages on the lru lists of zone are not reclaimed.

Mem cgroup iteration is refactored a bit to ensure the NULL case is also
input into the function.

Signed-off-by: Hillf Danton <dhillf@gmail.com>
---

--- a/mm/vmscan.c	Sat Jan 14 14:02:20 2012
+++ b/mm/vmscan.c	Sun Jan 22 10:09:32 2012
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
+		mz.mem_cgroup = memcg,

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
