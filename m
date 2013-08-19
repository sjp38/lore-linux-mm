Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx163.postini.com [74.125.245.163])
	by kanga.kvack.org (Postfix) with SMTP id 1EFFF6B0033
	for <linux-mm@kvack.org>; Mon, 19 Aug 2013 02:05:45 -0400 (EDT)
Received: by mail-pb0-f42.google.com with SMTP id un15so4607425pbc.1
        for <linux-mm@kvack.org>; Sun, 18 Aug 2013 23:05:44 -0700 (PDT)
Date: Sun, 18 Aug 2013 23:05:25 -0700 (PDT)
From: Hugh Dickins <hughd@google.com>
Subject: [PATCH mmotm,next] mm: fix memcg-less page reclaim
Message-ID: <alpine.LNX.2.00.1308182254220.1040@eggly.anvils>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org

Now that everybody loves memcg, configures it on, and would not dream
of booting with cgroup_disable=memory, it can pass unnoticed for weeks
that memcg-less page reclaim is completely broken.

mmotm's "memcg: enhance memcg iterator to support predicates" replaces
__shrink_zone()'s "do { } while (memcg);" loop by a "while (memcg) {}"
loop: which is nicer for memcg, but does nothing for !CONFIG_MEMCG or
cgroup_disable=memory.  Page reclaim hangs, making no progress.

Adding mem_cgroup_disabled() and once++ test there is ugly.  Ideally,
even a !CONFIG_MEMCG build might in future have a stub root_mem_cgroup,
which would get around this: but that's not so at present.

However, it appears that nothing actually dereferences the memcg pointer
in the mem_cgroup_disabled() case, here or anywhere else that case can
reach mem_cgroup_iter() (mem_cgroup_iter_break() is not called in
global reclaim).

So, simply pass back an ordinarily-oopsing non-NULL address the first
time, and we shall hear about it if I'm wrong.

Signed-off-by: Hugh Dickins <hughd@google.com>
---
By all means fold in to
memcg-enhance-memcg-iterator-to-support-predicates.patch

 include/linux/memcontrol.h |    3 ++-
 mm/memcontrol.c            |    6 ++++--
 2 files changed, 6 insertions(+), 3 deletions(-)

--- 3.11-rc5-mm1/include/linux/memcontrol.h	2013-08-15 18:10:50.504539510 -0700
+++ linux/include/linux/memcontrol.h	2013-08-18 12:30:58.116460318 -0700
@@ -370,7 +370,8 @@ mem_cgroup_iter_cond(struct mem_cgroup *
 		struct mem_cgroup_reclaim_cookie *reclaim,
 		mem_cgroup_iter_filter cond)
 {
-	return NULL;
+	/* first call must return non-NULL, second return NULL */
+	return (struct mem_cgroup *)(unsigned long)!prev;
 }
 
 static inline struct mem_cgroup *
--- 3.11-rc5-mm1/mm/memcontrol.c	2013-08-15 18:10:50.720539516 -0700
+++ linux/mm/memcontrol.c	2013-08-18 12:29:15.352460818 -0700
@@ -1086,8 +1086,10 @@ struct mem_cgroup *mem_cgroup_iter_cond(
 	struct mem_cgroup *memcg = NULL;
 	struct mem_cgroup *last_visited = NULL;
 
-	if (mem_cgroup_disabled())
-		return NULL;
+	if (mem_cgroup_disabled()) {
+		/* first call must return non-NULL, second return NULL */
+		return (struct mem_cgroup *)(unsigned long)!prev;
+	}
 
 	if (!root)
 		root = root_mem_cgroup;

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
