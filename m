Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id 1AAE48D003B
	for <linux-mm@kvack.org>; Fri, 22 Apr 2011 02:02:44 -0400 (EDT)
Received: from m3.gw.fujitsu.co.jp (unknown [10.0.50.73])
	by fgwmail5.fujitsu.co.jp (Postfix) with ESMTP id 5C28D3EE0BC
	for <linux-mm@kvack.org>; Fri, 22 Apr 2011 15:02:41 +0900 (JST)
Received: from smail (m3 [127.0.0.1])
	by outgoing.m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 3A7F545DE96
	for <linux-mm@kvack.org>; Fri, 22 Apr 2011 15:02:41 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (s3.gw.fujitsu.co.jp [10.0.50.93])
	by m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 0D2DA45DE99
	for <linux-mm@kvack.org>; Fri, 22 Apr 2011 15:02:41 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id EBCD1E18008
	for <linux-mm@kvack.org>; Fri, 22 Apr 2011 15:02:40 +0900 (JST)
Received: from ml13.s.css.fujitsu.com (ml13.s.css.fujitsu.com [10.240.81.133])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id AA823E08004
	for <linux-mm@kvack.org>; Fri, 22 Apr 2011 15:02:40 +0900 (JST)
Date: Fri, 22 Apr 2011 14:56:00 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH V7 4/9] Add memcg kswapd thread pool
Message-Id: <20110422145600.504b53d6.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20110422143957.FA6D.A69D9226@jp.fujitsu.com>
References: <1303446260-21333-1-git-send-email-yinghan@google.com>
	<1303446260-21333-5-git-send-email-yinghan@google.com>
	<20110422143957.FA6D.A69D9226@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: Ying Han <yinghan@google.com>, Minchan Kim <minchan.kim@gmail.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, Balbir Singh <balbir@linux.vnet.ibm.com>, Tejun Heo <tj@kernel.org>, Pavel Emelyanov <xemul@openvz.org>, Andrew Morton <akpm@linux-foundation.org>, Li Zefan <lizf@cn.fujitsu.com>, Mel Gorman <mel@csn.ul.ie>, Christoph Lameter <cl@linux.com>, Johannes Weiner <hannes@cmpxchg.org>, Rik van Riel <riel@redhat.com>, Hugh Dickins <hughd@google.com>, Michal Hocko <mhocko@suse.cz>, Dave Hansen <dave@linux.vnet.ibm.com>, Zhu Yanhai <zhu.yanhai@gmail.com>, linux-mm@kvack.org

On Fri, 22 Apr 2011 14:39:24 +0900 (JST)
KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com> wrote:

> > +bool mem_cgroup_kswapd_can_sleep(void)
> > +{
> > +	return list_empty(&memcg_kswapd_control.list);
> > +}
> 
> and, 
> 
> > @@ -2583,40 +2585,46 @@ static void kswapd_try_to_sleep(struct kswapd *kswapd_p, int order,
> >  	} else {
> > +		/* For now, we just check the remaining works.*/
> > +		if (mem_cgroup_kswapd_can_sleep())
> > +			schedule();
> 
> has bad assumption. If freeable memory is very little and kswapds are
> contended, memcg-kswap also have to give up and go into sleep as global
> kswapd.
> 
> Otherwise, We are going to see kswapd cpu 100% consumption issue again.
> 

Hmm, ok. need to add more logics. Is it ok to have add-on patch like this ?
I'll consider some more smart and fair....
==

Because memcg-kswapd push back memcg to the list when there is remaining work,
it may consume too much cpu when it finds hard-to-reclaim-memcg.

This patch adds a penalty to hard-to-reclaim memcg and reduces chance to
be scheduled again.

---
 include/linux/memcontrol.h |    2 +-
 mm/memcontrol.c            |   14 +++++++++++---
 mm/vmscan.c                |    4 ++--
 3 files changed, 14 insertions(+), 6 deletions(-)

Index: mmotm-Apr14/include/linux/memcontrol.h
===================================================================
--- mmotm-Apr14.orig/include/linux/memcontrol.h
+++ mmotm-Apr14/include/linux/memcontrol.h
@@ -96,7 +96,7 @@ extern int mem_cgroup_select_victim_node
 
 extern bool mem_cgroup_kswapd_can_sleep(void);
 extern struct mem_cgroup *mem_cgroup_get_shrink_target(void);
-extern void mem_cgroup_put_shrink_target(struct mem_cgroup *mem);
+extern void mem_cgroup_put_shrink_target(struct mem_cgroup *mem, int pages);
 extern wait_queue_head_t *mem_cgroup_kswapd_waitq(void);
 extern int mem_cgroup_kswapd_bonus(struct mem_cgroup *mem);
 
Index: mmotm-Apr14/mm/memcontrol.c
===================================================================
--- mmotm-Apr14.orig/mm/memcontrol.c
+++ mmotm-Apr14/mm/memcontrol.c
@@ -4739,6 +4739,10 @@ struct mem_cgroup *mem_cgroup_get_shrink
 				 	memcg_kswapd_wait_list);
 			list_del_init(&mem->memcg_kswapd_wait_list);
 		}
+		if (mem && mem->stalled) {
+			mem->stalled--; /* This memcg was cpu hog */
+			continue;
+		}
 	} while (mem && !css_tryget(&mem->css));
 	if (mem)
 		atomic_inc(&mem->kswapd_running);
@@ -4747,7 +4751,7 @@ struct mem_cgroup *mem_cgroup_get_shrink
 	return mem;
 }
 
-void mem_cgroup_put_shrink_target(struct mem_cgroup *mem)
+void mem_cgroup_put_shrink_target(struct mem_cgroup *mem, int nr_pages)
 {
 	if (!mem)
 		return;
@@ -4755,8 +4759,12 @@ void mem_cgroup_put_shrink_target(struct
 	if (!mem_cgroup_watermark_ok(mem, CHARGE_WMARK_HIGH)) {
 		spin_lock(&memcg_kswapd_control.lock);
 		if (list_empty(&mem->memcg_kswapd_wait_list)) {
-			list_add_tail(&mem->memcg_kswapd_wait_list,
-					&memcg_kswapd_control.list);
+			/* If memory reclaim was smooth, resched it */
+			if (nr_pages >= SWAP_CLUSTER_MAX/2)
+				list_add_tail(&mem->memcg_kswapd_wait_list,
+						&memcg_kswapd_control.list);
+			else
+				mem->stalled += 1; /* ignore this memcg for a while */
 		}
 		spin_unlock(&memcg_kswapd_control.lock);
 	}
Index: mmotm-Apr14/mm/vmscan.c
===================================================================
--- mmotm-Apr14.orig/mm/vmscan.c
+++ mmotm-Apr14/mm/vmscan.c
@@ -2892,8 +2892,8 @@ int kswapd(void *p)
 		} else {
 			mem = mem_cgroup_get_shrink_target();
 			if (mem)
-				shrink_mem_cgroup(mem, order);
-			mem_cgroup_put_shrink_target(mem);
+				ret = shrink_mem_cgroup(mem, order);
+			mem_cgroup_put_shrink_target(mem, ret);
 		}
 	}
 	return 0;
==

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
