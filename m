Date: Fri, 5 Dec 2008 21:25:29 +0900
From: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
Subject: [RFC][PATCH -mmotm 4/4] memcg: change try_to_free_pages to
 hierarchical_reclaim
Message-Id: <20081205212529.8d895526.nishimura@mxp.nes.nec.co.jp>
In-Reply-To: <20081205212208.31d904e0.nishimura@mxp.nes.nec.co.jp>
References: <20081205212208.31d904e0.nishimura@mxp.nes.nec.co.jp>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>
Cc: Balbir Singh <balbir@linux.vnet.ibm.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Pavel Emelyanov <xemul@openvz.org>, Li Zefan <lizf@cn.fujitsu.com>, Paul Menage <menage@google.com>, nishimura@mxp.nes.nec.co.jp
List-ID: <linux-mm.kvack.org>

mem_cgroup_hierarchicl_reclaim() works properly even when !use_hierarchy now,
so, instead of try_to_free_mem_cgroup_pages(), it should be used in many cases.

The only exception is force_empty. The group has no children in this case.


Signed-off-by: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
---
 mm/memcontrol.c |   12 ++++--------
 1 files changed, 4 insertions(+), 8 deletions(-)

diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index ab04725..c0b4f37 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -1399,8 +1399,7 @@ int mem_cgroup_shrink_usage(struct mm_struct *mm, gfp_t gfp_mask)
 	rcu_read_unlock();
 
 	do {
-		progress = try_to_free_mem_cgroup_pages(mem, gfp_mask, true,
-							get_swappiness(mem));
+		progress = mem_cgroup_hierarchical_reclaim(mem, gfp_mask, true);
 		progress += mem_cgroup_check_under_limit(mem);
 	} while (!progress && --retry);
 
@@ -1467,10 +1466,8 @@ static int mem_cgroup_resize_limit(struct mem_cgroup *memcg,
 		if (!ret)
 			break;
 
-		progress = try_to_free_mem_cgroup_pages(memcg,
-							GFP_KERNEL,
-							false,
-							get_swappiness(memcg));
+		progress = mem_cgroup_hierarchical_reclaim(memcg, GFP_KERNEL,
+							   false);
   		if (!progress)			retry_count--;
 	}
 
@@ -1514,8 +1511,7 @@ int mem_cgroup_resize_memsw_limit(struct mem_cgroup *memcg,
 			break;
 
 		oldusage = res_counter_read_u64(&memcg->memsw, RES_USAGE);
-		try_to_free_mem_cgroup_pages(memcg, GFP_KERNEL, true,
-					     get_swappiness(memcg));
+		mem_cgroup_hierarchical_reclaim(memcg, GFP_KERNEL, true);
 		curusage = res_counter_read_u64(&memcg->memsw, RES_USAGE);
 		if (curusage >= oldusage)
 			retry_count--;

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
