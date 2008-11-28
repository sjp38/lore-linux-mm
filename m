Date: Fri, 28 Nov 2008 18:07:37 +0900
From: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
Subject: [RFC][PATCH -mmotm 1/2] take account of memsw
Message-Id: <20081128180737.9d6553b8.nishimura@mxp.nes.nec.co.jp>
In-Reply-To: <20081128180252.b7a73c86.nishimura@mxp.nes.nec.co.jp>
References: <20081128180252.b7a73c86.nishimura@mxp.nes.nec.co.jp>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>
Cc: Balbir Singh <balbir@linux.vnet.ibm.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Pavel Emelyanov <xemul@openvz.org>, Li Zefan <lizf@cn.fujitsu.com>, Paul Menage <menage@google.com>, nishimura@mxp.nes.nec.co.jp
List-ID: <linux-mm.kvack.org>

mem_cgroup_hierarchical_reclaim checks only mem->res now.
It should also check mem->memsw when do_swap_account.

Signed-off-by: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
---
 mm/memcontrol.c |   17 +++++++++++++++--
 1 files changed, 15 insertions(+), 2 deletions(-)

diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index 20e1d90..e7806fc 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -567,6 +567,19 @@ done:
 	return ret;
 }
 
+static int mem_cgroup_check_under_limit(struct mem_cgroup *mem)
+{
+	if (do_swap_account) {
+		if (res_counter_check_under_limit(&mem->res) &&
+		    res_counter_check_under_limit(&mem->memsw))
+			return 1;
+	} else
+		if (res_counter_check_under_limit(&mem->res))
+			return 1;
+
+	return 0;
+}
+
 /*
  * Dance down the hierarchy if needed to reclaim memory. We remember the
  * last child we reclaimed from, so that we don't end up penalizing
@@ -588,7 +601,7 @@ static int mem_cgroup_hierarchical_reclaim(struct mem_cgroup *root_mem,
 	 * have left.
 	 */
 	ret = try_to_free_mem_cgroup_pages(root_mem, gfp_mask, noswap);
-	if (res_counter_check_under_limit(&root_mem->res))
+	if (mem_cgroup_check_under_limit(root_mem))
 		return 0;
 
 	next_mem = mem_cgroup_get_first_node(root_mem);
@@ -602,7 +615,7 @@ static int mem_cgroup_hierarchical_reclaim(struct mem_cgroup *root_mem,
 			continue;
 		}
 		ret = try_to_free_mem_cgroup_pages(next_mem, gfp_mask, noswap);
-		if (res_counter_check_under_limit(&root_mem->res))
+		if (mem_cgroup_check_under_limit(root_mem))
 			return 0;
 		cgroup_lock();
 		next_mem = mem_cgroup_get_next_node(next_mem, root_mem);

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
