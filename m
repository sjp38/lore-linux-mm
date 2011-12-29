Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx167.postini.com [74.125.245.167])
	by kanga.kvack.org (Postfix) with SMTP id 5181A6B0062
	for <linux-mm@kvack.org>; Wed, 28 Dec 2011 19:22:06 -0500 (EST)
Received: by iacb35 with SMTP id b35so27279030iac.14
        for <linux-mm@kvack.org>; Wed, 28 Dec 2011 16:22:05 -0800 (PST)
Date: Wed, 28 Dec 2011 16:21:57 -0800 (PST)
From: Hugh Dickins <hughd@google.com>
Subject: [PATCH 2/4] memcg: fix NULL mem_cgroup_try_charge
In-Reply-To: <alpine.LSU.2.00.1112281613550.8257@eggly.anvils>
Message-ID: <alpine.LSU.2.00.1112281620400.8257@eggly.anvils>
References: <alpine.LSU.2.00.1112281613550.8257@eggly.anvils>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>, linux-mm@kvack.org

There is one way out of __mem_cgroup_try_charge() which claims success
but still leaves memcg NULL, causing oops thereafter: make sure that
it is set to root_mem_cgroup in this case.

Signed-off-by: Hugh Dickins <hughd@google.com>
---
Fix to memcg: return -EINTR at bypassing try_charge()

 mm/memcontrol.c |    4 +++-
 1 file changed, 3 insertions(+), 1 deletion(-)

--- mmotm.orig/mm/memcontrol.c	2011-12-28 12:53:23.420367847 -0800
+++ mmotm/mm/memcontrol.c	2011-12-28 14:41:19.803018025 -0800
@@ -2263,7 +2263,9 @@ again:
 		 * task-struct. So, mm->owner can be NULL.
 		 */
 		memcg = mem_cgroup_from_task(p);
-		if (!memcg || mem_cgroup_is_root(memcg)) {
+		if (!memcg)
+			memcg = root_mem_cgroup;
+		if (mem_cgroup_is_root(memcg)) {
 			rcu_read_unlock();
 			goto done;
 		}

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
