Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx202.postini.com [74.125.245.202])
	by kanga.kvack.org (Postfix) with SMTP id 3F3EA6B0069
	for <linux-mm@kvack.org>; Thu, 16 Aug 2012 11:40:23 -0400 (EDT)
Date: Thu, 16 Aug 2012 11:36:22 -0400
From: Rik van Riel <riel@redhat.com>
Subject: [RFC][PATCH -mm -v2 2/4] mm,memcontrol: export mem_cgroup_get/put
Message-ID: <20120816113622.58c1bc85@cuia.bos.redhat.com>
In-Reply-To: <20120816113450.52f4e633@cuia.bos.redhat.com>
References: <20120816113450.52f4e633@cuia.bos.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: yinghan@google.com, aquini@redhat.com, hannes@cmpxchg.org, mhocko@suse.cz, Mel Gorman <mel@csn.ul.ie>

The page reclaim code should keep a reference to a cgroup while
reclaiming from that cgroup.  In order to do this when selecting
the highest score cgroup for reclaim, the VM code needs access
to refcounting functions for the memory cgroup code.

Signed-off-by: Rik van Riel <riel@redhat.com>
---
 include/linux/memcontrol.h |   11 +++++++++++
 mm/memcontrol.c            |    6 ++----
 2 files changed, 13 insertions(+), 4 deletions(-)

diff --git a/include/linux/memcontrol.h b/include/linux/memcontrol.h
index 65538f9..c4cc64c 100644
--- a/include/linux/memcontrol.h
+++ b/include/linux/memcontrol.h
@@ -65,6 +65,9 @@ extern int mem_cgroup_cache_charge(struct page *page, struct mm_struct *mm,
 struct lruvec *mem_cgroup_zone_lruvec(struct zone *, struct mem_cgroup *);
 struct lruvec *mem_cgroup_page_lruvec(struct page *, struct zone *);
 
+extern void mem_cgroup_get(struct mem_cgroup *memcg);
+extern void mem_cgroup_put(struct mem_cgroup *memcg);
+
 /* For coalescing uncharge for reducing memcg' overhead*/
 extern void mem_cgroup_uncharge_start(void);
 extern void mem_cgroup_uncharge_end(void);
@@ -298,6 +301,14 @@ static inline void mem_cgroup_iter_break(struct mem_cgroup *root,
 {
 }
 
+static inline void mem_cgroup_get(struct mem_cgroup *memcg)
+{
+}
+
+static inline void mem_cgroup_put(struct mem_cgroup *memcg)
+{
+}
+
 static inline bool mem_cgroup_disabled(void)
 {
 	return true;
diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index a18a0d5..376f680 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -368,8 +368,6 @@ enum charge_type {
 #define MEM_CGROUP_RECLAIM_SHRINK_BIT	0x1
 #define MEM_CGROUP_RECLAIM_SHRINK	(1 << MEM_CGROUP_RECLAIM_SHRINK_BIT)
 
-static void mem_cgroup_get(struct mem_cgroup *memcg);
-static void mem_cgroup_put(struct mem_cgroup *memcg);
 static bool mem_cgroup_is_root(struct mem_cgroup *memcg);
 
 /* Writing them here to avoid exposing memcg's inner layout */
@@ -4492,7 +4490,7 @@ static void __mem_cgroup_free(struct mem_cgroup *memcg)
 	call_rcu(&memcg->rcu_freeing, free_rcu);
 }
 
-static void mem_cgroup_get(struct mem_cgroup *memcg)
+void mem_cgroup_get(struct mem_cgroup *memcg)
 {
 	atomic_inc(&memcg->refcnt);
 }
@@ -4507,7 +4505,7 @@ static void __mem_cgroup_put(struct mem_cgroup *memcg, int count)
 	}
 }
 
-static void mem_cgroup_put(struct mem_cgroup *memcg)
+void mem_cgroup_put(struct mem_cgroup *memcg)
 {
 	__mem_cgroup_put(memcg, 1);
 }

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
