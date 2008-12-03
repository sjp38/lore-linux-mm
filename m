Received: from m1.gw.fujitsu.co.jp ([10.0.50.71])
	by fgwmail6.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id mB34qDsX016540
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Wed, 3 Dec 2008 13:52:13 +0900
Received: from smail (m1 [127.0.0.1])
	by outgoing.m1.gw.fujitsu.co.jp (Postfix) with ESMTP id 7BD6845DD75
	for <linux-mm@kvack.org>; Wed,  3 Dec 2008 13:52:13 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (s1.gw.fujitsu.co.jp [10.0.50.91])
	by m1.gw.fujitsu.co.jp (Postfix) with ESMTP id 4CC0745DD74
	for <linux-mm@kvack.org>; Wed,  3 Dec 2008 13:52:13 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id 1BED71DB8042
	for <linux-mm@kvack.org>; Wed,  3 Dec 2008 13:52:13 +0900 (JST)
Received: from ml13.s.css.fujitsu.com (ml13.s.css.fujitsu.com [10.249.87.103])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id C3E421DB8041
	for <linux-mm@kvack.org>; Wed,  3 Dec 2008 13:52:12 +0900 (JST)
Date: Wed, 3 Dec 2008 13:51:24 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: [PATCH  3/21] memcg-memoryswap-controller-fix-limit-check.patch
Message-Id: <20081203135124.1b70eb7c.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20081203134718.6b60986f.kamezawa.hiroyu@jp.fujitsu.com>
References: <20081203134718.6b60986f.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "balbir@linux.vnet.ibm.com" <balbir@linux.vnet.ibm.com>, "nishimura@mxp.nes.nec.co.jp" <nishimura@mxp.nes.nec.co.jp>, "kosaki.motohiro@jp.fujitsu.com" <kosaki.motohiro@jp.fujitsu.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

There are scatterd calls of res_counter_check_under_limit(), and most
of them don't take mem+swap accounting into account.

define mem_cgroup_check_under_limit() and avoid direct use of
res_counter_check_limit().

Changelog:
	- replaces all res_counter_check_under_limit().

Reported-by: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
Signed-off-by: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

 mm/memcontrol.c |   26 +++++++++++++++++---------
 1 file changed, 17 insertions(+), 9 deletions(-)

Index: mmotm-2.6.28-Dec02/mm/memcontrol.c
===================================================================
--- mmotm-2.6.28-Dec02.orig/mm/memcontrol.c
+++ mmotm-2.6.28-Dec02/mm/memcontrol.c
@@ -571,6 +571,18 @@ done:
 	return ret;
 }
 
+static bool mem_cgroup_check_under_limit(struct mem_cgroup *mem)
+{
+	if (do_swap_account) {
+		if (res_counter_check_under_limit(&mem->res) &&
+			res_counter_check_under_limit(&mem->memsw))
+			return true;
+	} else
+		if (res_counter_check_under_limit(&mem->res))
+			return true;
+	return false;
+}
+
 /*
  * Dance down the hierarchy if needed to reclaim memory. We remember the
  * last child we reclaimed from, so that we don't end up penalizing
@@ -592,7 +604,7 @@ static int mem_cgroup_hierarchical_recla
 	 * have left.
 	 */
 	ret = try_to_free_mem_cgroup_pages(root_mem, gfp_mask, noswap);
-	if (res_counter_check_under_limit(&root_mem->res))
+	if (mem_cgroup_check_under_limit(root_mem))
 		return 0;
 
 	next_mem = mem_cgroup_get_first_node(root_mem);
@@ -606,7 +618,7 @@ static int mem_cgroup_hierarchical_recla
 			continue;
 		}
 		ret = try_to_free_mem_cgroup_pages(next_mem, gfp_mask, noswap);
-		if (res_counter_check_under_limit(&root_mem->res))
+		if (mem_cgroup_check_under_limit(root_mem))
 			return 0;
 		cgroup_lock();
 		next_mem = mem_cgroup_get_next_node(next_mem, root_mem);
@@ -709,12 +721,8 @@ static int __mem_cgroup_try_charge(struc
 		 * current usage of the cgroup before giving up
 		 *
 		 */
-		if (do_swap_account) {
-			if (res_counter_check_under_limit(&mem_over_limit->res) &&
-			    res_counter_check_under_limit(&mem_over_limit->memsw))
-				continue;
-		} else if (res_counter_check_under_limit(&mem_over_limit->res))
-				continue;
+		if (mem_cgroup_check_under_limit(mem_over_limit))
+			continue;
 
 		if (!nr_retries--) {
 			if (oom) {
@@ -1334,7 +1342,7 @@ int mem_cgroup_shrink_usage(struct mm_st
 
 	do {
 		progress = try_to_free_mem_cgroup_pages(mem, gfp_mask, true);
-		progress += res_counter_check_under_limit(&mem->res);
+		progress += mem_cgroup_check_under_limit(mem);
 	} while (!progress && --retry);
 
 	css_put(&mem->css);

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
