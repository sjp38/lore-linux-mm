Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id 5D3C88D003B
	for <linux-mm@kvack.org>; Fri, 22 Apr 2011 00:47:42 -0400 (EDT)
Received: from m2.gw.fujitsu.co.jp (unknown [10.0.50.72])
	by fgwmail6.fujitsu.co.jp (Postfix) with ESMTP id B15233EE0C0
	for <linux-mm@kvack.org>; Fri, 22 Apr 2011 13:47:39 +0900 (JST)
Received: from smail (m2 [127.0.0.1])
	by outgoing.m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 9973945DF07
	for <linux-mm@kvack.org>; Fri, 22 Apr 2011 13:47:39 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (s2.gw.fujitsu.co.jp [10.0.50.92])
	by m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 73F7A45DEB6
	for <linux-mm@kvack.org>; Fri, 22 Apr 2011 13:47:39 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 67BF41DB802C
	for <linux-mm@kvack.org>; Fri, 22 Apr 2011 13:47:39 +0900 (JST)
Received: from m107.s.css.fujitsu.com (m107.s.css.fujitsu.com [10.240.81.147])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 06EB6E18004
	for <linux-mm@kvack.org>; Fri, 22 Apr 2011 13:47:39 +0900 (JST)
Date: Fri, 22 Apr 2011 13:40:58 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH V7 7/9] Per-memcg background reclaim.
Message-Id: <20110422134058.60e3ccf3.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <1303446260-21333-8-git-send-email-yinghan@google.com>
References: <1303446260-21333-1-git-send-email-yinghan@google.com>
	<1303446260-21333-8-git-send-email-yinghan@google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ying Han <yinghan@google.com>
Cc: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Minchan Kim <minchan.kim@gmail.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, Balbir Singh <balbir@linux.vnet.ibm.com>, Tejun Heo <tj@kernel.org>, Pavel Emelyanov <xemul@openvz.org>, Andrew Morton <akpm@linux-foundation.org>, Li Zefan <lizf@cn.fujitsu.com>, Mel Gorman <mel@csn.ul.ie>, Christoph Lameter <cl@linux.com>, Johannes Weiner <hannes@cmpxchg.org>, Rik van Riel <riel@redhat.com>, Hugh Dickins <hughd@google.com>, Michal Hocko <mhocko@suse.cz>, Dave Hansen <dave@linux.vnet.ibm.com>, Zhu Yanhai <zhu.yanhai@gmail.com>, linux-mm@kvack.org

On Thu, 21 Apr 2011 21:24:18 -0700
Ying Han <yinghan@google.com> wrote:

> This is the main loop of per-memcg background reclaim which is implemented in
> function balance_mem_cgroup_pgdat().
> 
> The function performs a priority loop similar to global reclaim. During each
> iteration it invokes balance_pgdat_node() for all nodes on the system, which
> is another new function performs background reclaim per node. After reclaiming
> each node, it checks mem_cgroup_watermark_ok() and breaks the priority loop if
> it returns true.
> 
> changelog v7..v6:
> 1. change based on KAMAZAWA's patchset. Each memcg reclaims now reclaims
> SWAP_CLUSTER_MAX of pages and putback the memcg to the tail of list.
> memcg-kswapd will visit memcgs in round-robin manner and reduce usages.
> 
> changelog v6..v5:
> 1. add mem_cgroup_zone_reclaimable_pages()
> 2. fix some comment style.
> 
> changelog v5..v4:
> 1. remove duplicate check on nodes_empty()
> 2. add logic to check if the per-memcg lru is empty on the zone.
> 
> changelog v4..v3:
> 1. split the select_victim_node and zone_unreclaimable to a seperate patches
> 2. remove the logic tries to do zone balancing.
> 
> changelog v3..v2:
> 1. change mz->all_unreclaimable to be boolean.
> 2. define ZONE_RECLAIMABLE_RATE macro shared by zone and per-memcg reclaim.
> 3. some more clean-up.
> 
> changelog v2..v1:
> 1. move the per-memcg per-zone clear_unreclaimable into uncharge stage.
> 2. shared the kswapd_run/kswapd_stop for per-memcg and global background
> reclaim.
> 3. name the per-memcg memcg as "memcg-id" (css->id). And the global kswapd
> keeps the same name.
> 4. fix a race on kswapd_stop while the per-memcg-per-zone info could be accessed
> after freeing.
> 5. add the fairness in zonelist where memcg remember the last zone reclaimed
> from.
> 
> Signed-off-by: Ying Han <yinghan@google.com>
> Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

seems good.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
