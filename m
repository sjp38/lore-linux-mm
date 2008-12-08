Date: Mon, 8 Dec 2008 11:03:55 +0900
From: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
Subject: [PATCH -mmotm 2/4] memcg: remove mem_cgroup_try_charge
Message-Id: <20081208110355.0e999d15.nishimura@mxp.nes.nec.co.jp>
In-Reply-To: <20081208105824.f8f5d67b.nishimura@mxp.nes.nec.co.jp>
References: <20081208105824.f8f5d67b.nishimura@mxp.nes.nec.co.jp>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Balbir Singh <balbir@linux.vnet.ibm.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Pavel Emelyanov <xemul@openvz.org>, Li Zefan <lizf@cn.fujitsu.com>, Paul Menage <menage@google.com>, nishimura@mxp.nes.nec.co.jp
List-ID: <linux-mm.kvack.org>

After previous patch, mem_cgroup_try_charge is not used by anyone, so we can
remove it.

Signed-off-by: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
Acked-by:KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
---
 include/linux/memcontrol.h |    8 --------
 mm/memcontrol.c            |   21 +--------------------
 2 files changed, 1 insertions(+), 28 deletions(-)

diff --git a/include/linux/memcontrol.h b/include/linux/memcontrol.h
index 8752052..74c4009 100644
--- a/include/linux/memcontrol.h
+++ b/include/linux/memcontrol.h
@@ -40,8 +40,6 @@ struct mm_struct;
 extern int mem_cgroup_newpage_charge(struct page *page, struct mm_struct *mm,
 				gfp_t gfp_mask);
 /* for swap handling */
-extern int mem_cgroup_try_charge(struct mm_struct *mm,
-		gfp_t gfp_mask, struct mem_cgroup **ptr);
 extern int mem_cgroup_try_charge_swapin(struct mm_struct *mm,
 		struct page *page, gfp_t mask, struct mem_cgroup **ptr);
 extern void mem_cgroup_commit_charge_swapin(struct page *page,
@@ -135,12 +133,6 @@ static inline int mem_cgroup_cache_charge(struct page *page,
 	return 0;
 }
 
-static inline int mem_cgroup_try_charge(struct mm_struct *mm,
-			gfp_t gfp_mask, struct mem_cgroup **ptr)
-{
-	return 0;
-}
-
 static inline int mem_cgroup_try_charge_swapin(struct mm_struct *mm,
 		struct page *page, gfp_t gfp_mask, struct mem_cgroup **ptr)
 {
diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index 0683459..9877b03 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -809,27 +809,8 @@ nomem:
 	return -ENOMEM;
 }
 
-/**
- * mem_cgroup_try_charge - get charge of PAGE_SIZE.
- * @mm: an mm_struct which is charged against. (when *memcg is NULL)
- * @gfp_mask: gfp_mask for reclaim.
- * @memcg: a pointer to memory cgroup which is charged against.
- *
- * charge against memory cgroup pointed by *memcg. if *memcg == NULL, estimated
- * memory cgroup from @mm is got and stored in *memcg.
- *
- * Returns 0 if success. -ENOMEM at failure.
- * This call can invoke OOM-Killer.
- */
-
-int mem_cgroup_try_charge(struct mm_struct *mm,
-			  gfp_t mask, struct mem_cgroup **memcg)
-{
-	return __mem_cgroup_try_charge(mm, mask, memcg, true);
-}
-
 /*
- * commit a charge got by mem_cgroup_try_charge() and makes page_cgroup to be
+ * commit a charge got by __mem_cgroup_try_charge() and makes page_cgroup to be
  * USED state. If already USED, uncharge and return.
  */
 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
