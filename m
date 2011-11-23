Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta12.messagelabs.com (mail6.bemta12.messagelabs.com [216.82.250.247])
	by kanga.kvack.org (Postfix) with ESMTP id A453C6B00D8
	for <linux-mm@kvack.org>; Wed, 23 Nov 2011 10:43:19 -0500 (EST)
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: [patch 7/8] mm: memcg: modify PageCgroupAcctLRU non-atomically
Date: Wed, 23 Nov 2011 16:42:30 +0100
Message-Id: <1322062951-1756-8-git-send-email-hannes@cmpxchg.org>
In-Reply-To: <1322062951-1756-1-git-send-email-hannes@cmpxchg.org>
References: <1322062951-1756-1-git-send-email-hannes@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Michal Hocko <mhocko@suse.cz>, Balbir Singh <bsingharora@gmail.com>, cgroups@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

From: Johannes Weiner <jweiner@redhat.com>

This bit is protected by zone->lru_lock, there is no need for locked
operations when setting and clearing it.

Signed-off-by: Johannes Weiner <jweiner@redhat.com>
---
 include/linux/page_cgroup.h |   16 ++++++++++++----
 mm/memcontrol.c             |    4 ++--
 2 files changed, 14 insertions(+), 6 deletions(-)

diff --git a/include/linux/page_cgroup.h b/include/linux/page_cgroup.h
index aaa60da..a0bc9d0 100644
--- a/include/linux/page_cgroup.h
+++ b/include/linux/page_cgroup.h
@@ -57,14 +57,23 @@ static inline int PageCgroup##uname(struct page_cgroup *pc)	\
 #define SETPCGFLAG(uname, lname)			\
 static inline void SetPageCgroup##uname(struct page_cgroup *pc)\
 	{ set_bit(PCG_##lname, &pc->flags);  }
+#define __SETPCGFLAG(uname, lname)			\
+static inline void __SetPageCgroup##uname(struct page_cgroup *pc)\
+	{ __set_bit(PCG_##lname, &pc->flags);  }
 
 #define CLEARPCGFLAG(uname, lname)			\
 static inline void ClearPageCgroup##uname(struct page_cgroup *pc)	\
 	{ clear_bit(PCG_##lname, &pc->flags);  }
+#define __CLEARPCGFLAG(uname, lname)			\
+static inline void __ClearPageCgroup##uname(struct page_cgroup *pc)	\
+	{ __clear_bit(PCG_##lname, &pc->flags);  }
 
 #define TESTCLEARPCGFLAG(uname, lname)			\
 static inline int TestClearPageCgroup##uname(struct page_cgroup *pc)	\
 	{ return test_and_clear_bit(PCG_##lname, &pc->flags);  }
+#define __TESTCLEARPCGFLAG(uname, lname)			\
+static inline int __TestClearPageCgroup##uname(struct page_cgroup *pc)	\
+	{ return __test_and_clear_bit(PCG_##lname, &pc->flags);  }
 
 /* Cache flag is set only once (at allocation) */
 TESTPCGFLAG(Cache, CACHE)
@@ -75,11 +84,10 @@ TESTPCGFLAG(Used, USED)
 CLEARPCGFLAG(Used, USED)
 SETPCGFLAG(Used, USED)
 
-SETPCGFLAG(AcctLRU, ACCT_LRU)
-CLEARPCGFLAG(AcctLRU, ACCT_LRU)
+__SETPCGFLAG(AcctLRU, ACCT_LRU)
+__CLEARPCGFLAG(AcctLRU, ACCT_LRU)
 TESTPCGFLAG(AcctLRU, ACCT_LRU)
-TESTCLEARPCGFLAG(AcctLRU, ACCT_LRU)
-
+__TESTCLEARPCGFLAG(AcctLRU, ACCT_LRU)
 
 SETPCGFLAG(FileMapped, FILE_MAPPED)
 CLEARPCGFLAG(FileMapped, FILE_MAPPED)
diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index b9a3b94..51aba19 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -995,7 +995,7 @@ struct lruvec *mem_cgroup_lru_add_list(struct zone *zone, struct page *page,
 		/* Ensure pc->mem_cgroup is visible after reading PCG_USED. */
 		smp_rmb();
 		memcg = pc->mem_cgroup;
-		SetPageCgroupAcctLRU(pc);
+		__SetPageCgroupAcctLRU(pc);
 	} else
 		memcg = root_mem_cgroup;
 	mz = page_cgroup_zoneinfo(memcg, page);
@@ -1031,7 +1031,7 @@ void mem_cgroup_lru_del_list(struct page *page, enum lru_list lru)
 	 * LRU-accounting happened against pc->mem_cgroup or
 	 * root_mem_cgroup.
 	 */
-	if (TestClearPageCgroupAcctLRU(pc)) {
+	if (__TestClearPageCgroupAcctLRU(pc)) {
 		VM_BUG_ON(!pc->mem_cgroup);
 		memcg = pc->mem_cgroup;
 	} else
-- 
1.7.6.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
