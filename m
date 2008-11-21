Received: from mt1.gw.fujitsu.co.jp ([10.0.50.74])
	by fgwmail7.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id mALA4YaA003379
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Fri, 21 Nov 2008 19:04:34 +0900
Received: from smail (m4 [127.0.0.1])
	by outgoing.m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 4DB0345DE51
	for <linux-mm@kvack.org>; Fri, 21 Nov 2008 19:04:34 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (s4.gw.fujitsu.co.jp [10.0.50.94])
	by m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 2A05D45DE4F
	for <linux-mm@kvack.org>; Fri, 21 Nov 2008 19:04:34 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id 0E2A11DB8043
	for <linux-mm@kvack.org>; Fri, 21 Nov 2008 19:04:34 +0900 (JST)
Received: from ml14.s.css.fujitsu.com (ml14.s.css.fujitsu.com [10.249.87.104])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id BA8071DB803E
	for <linux-mm@kvack.org>; Fri, 21 Nov 2008 19:04:33 +0900 (JST)
Date: Fri, 21 Nov 2008 19:03:39 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: [PATCH 2/2] memcg: fix reclaim result checks.
Message-Id: <20081121190339.65f453a6.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20081121185829.e04c8116.kamezawa.hiroyu@jp.fujitsu.com>
References: <20081114191246.4f69ff31.kamezawa.hiroyu@jp.fujitsu.com>
	<20081114191949.926bf99d.kamezawa.hiroyu@jp.fujitsu.com>
	<49261F87.50209@cn.fujitsu.com>
	<20081121185829.e04c8116.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Li Zefan <lizf@cn.fujitsu.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "balbir@linux.vnet.ibm.com" <balbir@linux.vnet.ibm.com>, "nishimura@mxp.nes.nec.co.jp" <nishimura@mxp.nes.nec.co.jp>, pbadari@us.ibm.com, jblunck@suse.de, taka@valinux.co.jp, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, npiggin@suse.de
List-ID: <linux-mm.kvack.org>

check_under_limit logic was wrong and this check should be against
mem_over_limit rather than mem.

Reported-by: Li Zefan <lizf@cn.fujitsu.com>
Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
---
 mm/memcontrol.c |   16 ++++++++--------
 1 file changed, 8 insertions(+), 8 deletions(-)

Index: mmotm-2.6.28-Nov20/mm/memcontrol.c
===================================================================
--- mmotm-2.6.28-Nov20.orig/mm/memcontrol.c
+++ mmotm-2.6.28-Nov20/mm/memcontrol.c
@@ -714,17 +714,17 @@ static int __mem_cgroup_try_charge(struc
 		 * current usage of the cgroup before giving up
 		 *
 		 */
-		if (!do_swap_account &&
-			res_counter_check_under_limit(&mem->res))
-			continue;
-		if (do_swap_account &&
-			res_counter_check_under_limit(&mem->memsw))
-			continue;
+		if (do_swap_account) {
+			if (res_counter_check_under_limit(&mem_over_limit->res) &&
+			    res_counter_check_under_limit(&mem_over_limit->memsw))
+				continue;
+		} else if (res_counter_check_under_limit(&mem_over_limit->res))
+				continue;
 
 		if (!nr_retries--) {
 			if (oom) {
-				mem_cgroup_out_of_memory(mem, gfp_mask);
-				mem->last_oom_jiffies = jiffies;
+				mem_cgroup_out_of_memory(mem_over_limit, gfp_mask);
+				mem_over_limit->last_oom_jiffies = jiffies;
 			}
 			goto nomem;
 		}

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
