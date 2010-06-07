Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with ESMTP id C79826B01B4
	for <linux-mm@kvack.org>; Mon,  7 Jun 2010 02:04:06 -0400 (EDT)
Date: Mon, 7 Jun 2010 14:53:37 +0900
From: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
Subject: [cleanup][PATCH -mmotm 2/2] memcg: remove mem from arg of
 charge_common
Message-Id: <20100607145337.c0b5ad79.nishimura@mxp.nes.nec.co.jp>
In-Reply-To: <20100607145239.cb5cb917.nishimura@mxp.nes.nec.co.jp>
References: <20100607145239.cb5cb917.nishimura@mxp.nes.nec.co.jp>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Balbir Singh <balbir@linux.vnet.ibm.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
List-ID: <linux-mm.kvack.org>

From: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>

mem_cgroup_charge_common() is always called with @mem = NULL, so it's
meaningless. This patch removes it.

Signed-off-by: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
---
 mm/memcontrol.c |   17 ++++++++---------
 1 files changed, 8 insertions(+), 9 deletions(-)

diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index 7146055..8f57ec2 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -2025,10 +2025,9 @@ out:
  * < 0 if the cgroup is over its limit
  */
 static int mem_cgroup_charge_common(struct page *page, struct mm_struct *mm,
-				gfp_t gfp_mask, enum charge_type ctype,
-				struct mem_cgroup *memcg)
+				gfp_t gfp_mask, enum charge_type ctype)
 {
-	struct mem_cgroup *mem;
+	struct mem_cgroup *mem = NULL;
 	struct page_cgroup *pc;
 	int ret;
 
@@ -2038,7 +2037,6 @@ static int mem_cgroup_charge_common(struct page *page, struct mm_struct *mm,
 		return 0;
 	prefetchw(pc);
 
-	mem = memcg;
 	ret = __mem_cgroup_try_charge(mm, gfp_mask, &mem, true);
 	if (ret || !mem)
 		return ret;
@@ -2066,7 +2064,7 @@ int mem_cgroup_newpage_charge(struct page *page,
 	if (unlikely(!mm))
 		mm = &init_mm;
 	return mem_cgroup_charge_common(page, mm, gfp_mask,
-				MEM_CGROUP_CHARGE_TYPE_MAPPED, NULL);
+				MEM_CGROUP_CHARGE_TYPE_MAPPED);
 }
 
 static void
@@ -2076,7 +2074,6 @@ __mem_cgroup_commit_charge_swapin(struct page *page, struct mem_cgroup *ptr,
 int mem_cgroup_cache_charge(struct page *page, struct mm_struct *mm,
 				gfp_t gfp_mask)
 {
-	struct mem_cgroup *mem = NULL;
 	int ret;
 
 	if (mem_cgroup_disabled())
@@ -2108,22 +2105,24 @@ int mem_cgroup_cache_charge(struct page *page, struct mm_struct *mm,
 		unlock_page_cgroup(pc);
 	}
 
-	if (unlikely(!mm && !mem))
+	if (unlikely(!mm))
 		mm = &init_mm;
 
 	if (page_is_file_cache(page))
 		return mem_cgroup_charge_common(page, mm, gfp_mask,
-				MEM_CGROUP_CHARGE_TYPE_CACHE, NULL);
+				MEM_CGROUP_CHARGE_TYPE_CACHE);
 
 	/* shmem */
 	if (PageSwapCache(page)) {
+		struct mem_cgroup *mem = NULL;
+
 		ret = mem_cgroup_try_charge_swapin(mm, page, gfp_mask, &mem);
 		if (!ret)
 			__mem_cgroup_commit_charge_swapin(page, mem,
 					MEM_CGROUP_CHARGE_TYPE_SHMEM);
 	} else
 		ret = mem_cgroup_charge_common(page, mm, gfp_mask,
-					MEM_CGROUP_CHARGE_TYPE_SHMEM, mem);
+					MEM_CGROUP_CHARGE_TYPE_SHMEM);
 
 	return ret;
 }
-- 
1.6.5.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
