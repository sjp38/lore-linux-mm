Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with ESMTP id EA9456B0022
	for <linux-mm@kvack.org>; Thu, 12 May 2011 20:11:34 -0400 (EDT)
Received: from m1.gw.fujitsu.co.jp (unknown [10.0.50.71])
	by fgwmail5.fujitsu.co.jp (Postfix) with ESMTP id 185053EE0BC
	for <linux-mm@kvack.org>; Fri, 13 May 2011 09:11:32 +0900 (JST)
Received: from smail (m1 [127.0.0.1])
	by outgoing.m1.gw.fujitsu.co.jp (Postfix) with ESMTP id F2E7F45DE59
	for <linux-mm@kvack.org>; Fri, 13 May 2011 09:11:31 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (s1.gw.fujitsu.co.jp [10.0.50.91])
	by m1.gw.fujitsu.co.jp (Postfix) with ESMTP id DD6CA45DE55
	for <linux-mm@kvack.org>; Fri, 13 May 2011 09:11:31 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id D064DE08002
	for <linux-mm@kvack.org>; Fri, 13 May 2011 09:11:31 +0900 (JST)
Received: from m105.s.css.fujitsu.com (m105.s.css.fujitsu.com [10.240.81.145])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id 983CBEF8003
	for <linux-mm@kvack.org>; Fri, 13 May 2011 09:11:31 +0900 (JST)
Date: Fri, 13 May 2011 09:04:50 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [rfc patch 3/6] mm: memcg-aware global reclaim
Message-Id: <20110513090450.3c40d2ee.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <1305212038-15445-4-git-send-email-hannes@cmpxchg.org>
References: <1305212038-15445-1-git-send-email-hannes@cmpxchg.org>
	<1305212038-15445-4-git-send-email-hannes@cmpxchg.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, Balbir Singh <balbir@linux.vnet.ibm.com>, Ying Han <yinghan@google.com>, Michal Hocko <mhocko@suse.cz>, Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>, Minchan Kim <minchan.kim@gmail.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Mel Gorman <mgorman@suse.de>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Thu, 12 May 2011 16:53:55 +0200
Johannes Weiner <hannes@cmpxchg.org> wrote:

> A page charged to a memcg is linked to a lru list specific to that
> memcg.  At the same time, traditional global reclaim is obvlivious to
> memcgs, and all the pages are also linked to a global per-zone list.
> 
> This patch changes traditional global reclaim to iterate over all
> existing memcgs, so that it no longer relies on the global list being
> present.
> 
> This is one step forward in integrating memcg code better into the
> rest of memory management.  It is also a prerequisite to get rid of
> the global per-zone lru lists.
> 


As I said, I don't want removing global reclaim until dirty_ratio support and
better softlimit algorithm, at least. Current my concern is dirty_ratio,
if you want to speed up, please help Greg and implement dirty_ratio first.

BTW, could you separete clean up code and your new logic ? 1st half of
codes seems to be just a clean up and seems nice. But , IIUC, someone
changed the arguments from chunk of params to be a flags....in some patch.
...
commit 75822b4495b62e8721e9b88e3cf9e653a0c85b73
Author: Balbir Singh <balbir@linux.vnet.ibm.com>
Date:   Wed Sep 23 15:56:38 2009 -0700

    memory controller: soft limit refactor reclaim flags

    Refactor mem_cgroup_hierarchical_reclaim()

    Refactor the arguments passed to mem_cgroup_hierarchical_reclaim() into
    flags, so that new parameters don't have to be passed as we make the
    reclaim routine more flexible

...

Balbir ?  Both are ok to me, please ask him.


And hmm...

+	do {
+		mem_cgroup_hierarchy_walk(root, &mem);
+		sc->current_memcg = mem;
+		do_shrink_zone(priority, zone, sc);
+	} while (mem != root);

This move hierarchy walk from memcontrol.c to vmscan.c ?

About moving hierarchy walk, I may say okay...because my patch does this, too.

But....doesn't this reclaim too much memory if hierarchy is very deep ?
Could you add some 'quit' path ?


Thanks,
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
