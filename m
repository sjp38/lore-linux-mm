Date: Tue, 16 Oct 2007 19:25:10 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: [PATCH] memory cgroup enhancements [2/5] remember charge as cache
Message-Id: <20071016192510.9423835e.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20071016191949.cd50f12f.kamezawa.hiroyu@jp.fujitsu.com>
References: <20071016191949.cd50f12f.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "containers@lists.osdl.org" <containers@lists.osdl.org>, "balbir@linux.vnet.ibm.com" <balbir@linux.vnet.ibm.com>, "yamamoto@valinux.co.jp" <yamamoto@valinux.co.jp>
List-ID: <linux-mm.kvack.org>

Add PCGF_PAGECACHE flag to page_cgroup to remember "this page is
charged as page-cache."
This is very useful for implementing precise accounting in memory cgroup.


Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Signed-off-by: YAMAMOTO Takashi <yamamoto@valinux.co.jp>

 mm/memcontrol.c |   18 +++++++++++++++---
 1 file changed, 15 insertions(+), 3 deletions(-)

Index: devel-2.6.23-mm1/mm/memcontrol.c
===================================================================
--- devel-2.6.23-mm1.orig/mm/memcontrol.c
+++ devel-2.6.23-mm1/mm/memcontrol.c
@@ -83,6 +83,8 @@ struct page_cgroup {
 	struct mem_cgroup *mem_cgroup;
 	atomic_t ref_cnt;		/* Helpful when pages move b/w  */
 					/* mapped and cached states     */
+	int	 flags;
+#define PCGF_PAGECACHE		(0x1)	/* charged as page-cache */
 };
 
 enum {
@@ -315,8 +317,8 @@ unsigned long mem_cgroup_isolate_pages(u
  * 0 if the charge was successful
  * < 0 if the cgroup is over its limit
  */
-int mem_cgroup_charge(struct page *page, struct mm_struct *mm,
-				gfp_t gfp_mask)
+static int mem_cgroup_charge_common(struct page *page, struct mm_struct *mm,
+				gfp_t gfp_mask, int is_cache)
 {
 	struct mem_cgroup *mem;
 	struct page_cgroup *pc;
@@ -418,6 +420,10 @@ noreclaim:
 	atomic_set(&pc->ref_cnt, 1);
 	pc->mem_cgroup = mem;
 	pc->page = page;
+	if (is_cache)
+		pc->flags = PCGF_PAGECACHE;
+	else
+		pc->flags = 0;
 	if (page_cgroup_assign_new_page_cgroup(page, pc)) {
 		/*
 		 * an another charge is added to this page already.
@@ -442,6 +448,12 @@ err:
 	return -ENOMEM;
 }
 
+int mem_cgroup_charge(struct page *page, struct mm_struct *mm,
+			gfp_t gfp_mask)
+{
+	return mem_cgroup_charge_common(page, mm, gfp_mask, 0);
+}
+
 /*
  * See if the cached pages should be charged at all?
  */
@@ -454,7 +466,7 @@ int mem_cgroup_cache_charge(struct page 
 
 	mem = rcu_dereference(mm->mem_cgroup);
 	if (mem->control_type == MEM_CGROUP_TYPE_ALL)
-		return mem_cgroup_charge(page, mm, gfp_mask);
+		return mem_cgroup_charge_common(page, mm, gfp_mask, 1);
 	else
 		return 0;
 }

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
