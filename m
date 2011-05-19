Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id 4B14D8D003B
	for <linux-mm@kvack.org>; Wed, 18 May 2011 21:18:18 -0400 (EDT)
Received: from m2.gw.fujitsu.co.jp (unknown [10.0.50.72])
	by fgwmail6.fujitsu.co.jp (Postfix) with ESMTP id 70C263EE0BB
	for <linux-mm@kvack.org>; Thu, 19 May 2011 10:18:15 +0900 (JST)
Received: from smail (m2 [127.0.0.1])
	by outgoing.m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 56AFD45DF5B
	for <linux-mm@kvack.org>; Thu, 19 May 2011 10:18:15 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (s2.gw.fujitsu.co.jp [10.0.50.92])
	by m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 2BD5D45DF55
	for <linux-mm@kvack.org>; Thu, 19 May 2011 10:18:15 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 1C1EF1DB8046
	for <linux-mm@kvack.org>; Thu, 19 May 2011 10:18:15 +0900 (JST)
Received: from m107.s.css.fujitsu.com (m107.s.css.fujitsu.com [10.240.81.147])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id D578B1DB802C
	for <linux-mm@kvack.org>; Thu, 19 May 2011 10:18:14 +0900 (JST)
Date: Thu, 19 May 2011 10:10:56 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: [PATCH][BUGFIX] memcg: fix a routine for counting pages in node
 (Re: [PATCH V2 2/2] memcg: add memory.numastat api for numa statistics
Message-Id: <20110519101056.ca8e86f6.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <1305766511-11469-2-git-send-email-yinghan@google.com>
References: <1305766511-11469-1-git-send-email-yinghan@google.com>
	<1305766511-11469-2-git-send-email-yinghan@google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ying Han <yinghan@google.com>
Cc: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Minchan Kim <minchan.kim@gmail.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, Balbir Singh <balbir@linux.vnet.ibm.com>, Tejun Heo <tj@kernel.org>, Pavel Emelyanov <xemul@openvz.org>, Andrew Morton <akpm@linux-foundation.org>, Li Zefan <lizf@cn.fujitsu.com>, Mel Gorman <mel@csn.ul.ie>, Christoph Lameter <cl@linux.com>, Johannes Weiner <hannes@cmpxchg.org>, Rik van Riel <riel@redhat.com>, Hugh Dickins <hughd@google.com>, Michal Hocko <mhocko@suse.cz>, Dave Hansen <dave@linux.vnet.ibm.com>, Zhu Yanhai <zhu.yanhai@gmail.com>, linux-mm@kvack.org

On Wed, 18 May 2011 17:55:11 -0700
Ying Han <yinghan@google.com> wrote:
$ cat /dev/cgroup/memory/memory.numa_stat
> total=317674 N0=101850 N1=72552 N2=30120 N3=113142
> file=288219 N0=98046 N1=59220 N2=23578 N3=107375
> anon=25699 N0=3804 N1=10124 N2=6540 N3=5231
> 
> Note: I noticed <total pages> is not equal to the sum of the rest of counters.
> I might need to change the way get that counter, comments are welcomed.
> 

Please debug when you feel strange ;)

Here is a fix. Could you test ? 

==
The value for counter base should be initialized. If not,
this returns wrong value.

Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
---
 mm/memcontrol.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

Index: mmotm-May11/mm/memcontrol.c
===================================================================
--- mmotm-May11.orig/mm/memcontrol.c
+++ mmotm-May11/mm/memcontrol.c
@@ -710,7 +710,7 @@ static unsigned long
 mem_cgroup_get_zonestat_node(struct mem_cgroup *mem, int nid, enum lru_list idx)
 {
 	struct mem_cgroup_per_zone *mz;
-	u64 total;
+	u64 total = 0;
 	int zid;
 
 	for (zid = 0; zid < MAX_NR_ZONES; zid++) {

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
