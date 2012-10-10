Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx190.postini.com [74.125.245.190])
	by kanga.kvack.org (Postfix) with SMTP id 8C0E66B002B
	for <linux-mm@kvack.org>; Wed, 10 Oct 2012 10:11:46 -0400 (EDT)
Date: Wed, 10 Oct 2012 16:11:42 +0200
From: Michal Hocko <mhocko@suse.cz>
Subject: [RFC PATCH] memcg: oom: fix totalpages calculation for swappiness==0
Message-ID: <20121010141142.GG23011@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: David Rientjes <rientjes@google.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Johannes Weiner <hannes@cmpxchg.org>, LKML <linux-kernel@vger.kernel.org>

Hi,
I am sending the patch below as an RFC because I am not entirely happy
about myself and maybe somebody can come up with a different approach
which would be less hackish.
As a background, I have noticed that memcg OOM killer kills a wrong
tasks while playing with memory.swappiness==0 in a small group (e.g.
50M). I have multiple anon mem eaters which fault in more than the hard
limit. OOM killer kills the last executed task:

# mem_eater spawns one process per parameter, mmaps the given size and
# faults memory in in parallel (all of them are synced to start together)
./mem_eater anon:50M anon:20M anon:20M anon:20M
10571: anon_eater for 20971520B
10570: anon_eater for 52428800B
10573: anon_eater for 20971520B
10572: anon_eater for 20971520B
10573: done with status 9
10571: done with status 0
10572: done with status 9
10570: done with status 9

[ pid ]   uid  tgid total_vm      rss nr_ptes swapents oom_score_adj name
[ 5706]     0  5706     4955      556      13        0             0 bash
[10569]     0 10569     1015      134       6        0             0 mem_eater
[10570]     0 10570    13815     4118      15        0             0 mem_eater
[10571]     0 10571     6135     5140      16        0             0 mem_eater
[10572]     0 10572     6135       22       7        0             0 mem_eater
[10573]     0 10573     6135     3541      14        0             0 mem_eater
Memory cgroup out of memory: Kill process 10573 (mem_eater) score 0 or sacrifice child
Killed process 10573 (mem_eater) total-vm:24540kB, anon-rss:14028kB, file-rss:136kB
[...]
[ pid ]   uid  tgid total_vm      rss nr_ptes swapents oom_score_adj name
[ 5706]     0  5706     4955      556      13        0             0 bash
[10569]     0 10569     1015      134       6        0             0 mem_eater
[10570]     0 10570    13815    10267      27        0             0 mem_eater
[10572]     0 10572     6135     2519      12        0             0 mem_eater
Memory cgroup out of memory: Kill process 10572 (mem_eater) score 0 or sacrifice child
Killed process 10572 (mem_eater) total-vm:24540kB, anon-rss:9940kB, file-rss:136kB
[...]
[ pid ]   uid  tgid total_vm      rss nr_ptes swapents oom_score_adj name
[ 5706]     0  5706     4955      556      13        0             0 bash
[10569]     0 10569     1015      134       6        0             0 mem_eater
[10570]     0 10570    13815    12773      31        0             0 mem_eater
Memory cgroup out of memory: Kill process 10570 (mem_eater) score 2 or sacrifice child
Killed process 10570 (mem_eater) total-vm:55260kB, anon-rss:50956kB, file-rss:136kB

As you can see 50M (pid:10570) is killed as the last one while 20M ones
are killed first. See the patch for more details about the problem.
As I state in the changelog the very same issue is present in the global
oom killer as well but it is much less probable as the amount of swap is
usualy much smaller than the available RAM and I think it is not worth
considering.

---
