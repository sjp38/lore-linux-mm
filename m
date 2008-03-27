Date: Thu, 27 Mar 2008 17:51:37 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: [-mm] [PATCH 4/4] memcg : radix-tree page_cgroup v2
Message-Id: <20080327175137.c26b2bb8.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20080327174435.e69f5b45.kamezawa.hiroyu@jp.fujitsu.com>
References: <20080327174435.e69f5b45.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "balbir@linux.vnet.ibm.com" <balbir@linux.vnet.ibm.com>, lizf@cn.fujitsu.com, a.p.zijlstra@chello.nl
List-ID: <linux-mm.kvack.org>

This 2 prefetches works well under my test.
(*)Tested on x86_64 and ia64 by unixbench/execl.

Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

---
 mm/memcontrol.c  |    5 ++++-
 mm/page_cgroup.c |    4 +++-
 2 files changed, 7 insertions(+), 2 deletions(-)

Index: linux-2.6.25-rc5-mm1-k/mm/memcontrol.c
===================================================================
--- linux-2.6.25-rc5-mm1-k.orig/mm/memcontrol.c
+++ linux-2.6.25-rc5-mm1-k/mm/memcontrol.c
@@ -182,10 +182,13 @@ static struct mem_cgroup_per_zone *
 page_cgroup_zoneinfo(struct page_cgroup *pc)
 {
 	struct mem_cgroup *mem = pc->mem_cgroup;
+	struct mem_cgroup_per_zone *mz;
 	int nid = page_cgroup_nid(pc);
 	int zid = page_cgroup_zid(pc);
 
-	return mem_cgroup_zoneinfo(mem, nid, zid);
+	mz = mem_cgroup_zoneinfo(mem, nid, zid);
+	prefetch(mz);
+	return mz;
 }
 
 static unsigned long mem_cgroup_get_all_zonestat(struct mem_cgroup *mem,
Index: linux-2.6.25-rc5-mm1-k/mm/page_cgroup.c
===================================================================
--- linux-2.6.25-rc5-mm1-k.orig/mm/page_cgroup.c
+++ linux-2.6.25-rc5-mm1-k/mm/page_cgroup.c
@@ -106,8 +106,10 @@ static struct page_cgroup *pcp_lookup(un
 	int hnum = hashfunc(idx);
 
 	pcp = &get_cpu_var(pcpu_pcgroup_cache);
-	if (pcp->ents[hnum].idx == idx && pcp->ents[hnum].base)
+	if (pcp->ents[hnum].idx == idx && pcp->ents[hnum].base) {
 		ret = pcp->ents[hnum].base + pfn;
+		prefetch(ret);
+	}
 	put_cpu_var(pcpu_pcgroup_cache);
 	return ret;
 }

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
