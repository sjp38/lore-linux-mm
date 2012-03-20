Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx184.postini.com [74.125.245.184])
	by kanga.kvack.org (Postfix) with SMTP id 31A786B0044
	for <linux-mm@kvack.org>; Tue, 20 Mar 2012 12:55:16 -0400 (EDT)
From: Glauber Costa <glommer@parallels.com>
Subject: [PATCH] memcg: Do not open code accesses to res_counter members
Date: Tue, 20 Mar 2012 20:53:44 +0400
Message-Id: <1332262424-13484-1-git-send-email-glommer@parallels.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: cgroups@vger.kernel.org
Cc: linux-mm@kvack.org, devel@openvz.org, Glauber Costa <glommer@parallels.com>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

We should use the acessor res_counter_read_u64 for that.
Although a purely cosmetic change is sometimes better of delayed,
to avoid conflicting with other people's work, we are starting to
have people touching this code as well, and reproducing the open
code behavior because that's the standard =)

Time to fix it, then.

Signed-off-by: Glauber Costa <glommer@parallels.com>
Cc: Johannes Weiner <hannes@cmpxchg.org>
Cc: Michal Hocko <mhocko@suse.cz>
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
---
 mm/memcontrol.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index 87a1e21..27c1bfa 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -3708,7 +3708,7 @@ move_account:
 			goto try_to_free;
 		cond_resched();
 	/* "ret" should also be checked to ensure all lists are empty. */
-	} while (memcg->res.usage > 0 || ret);
+	} while (res_counter_read_u64(&memcg->res, RES_USAGE) > 0 || ret);
 out:
 	css_put(&memcg->css);
 	return ret;
@@ -3723,7 +3723,7 @@ try_to_free:
 	lru_add_drain_all();
 	/* try to free all pages in this cgroup */
 	shrink = 1;
-	while (nr_retries && memcg->res.usage > 0) {
+	while (nr_retries && res_counter_read_u64(&memcg->res, RES_USAGE) > 0) {
 		int progress;
 
 		if (signal_pending(current)) {
-- 
1.7.7.6

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
