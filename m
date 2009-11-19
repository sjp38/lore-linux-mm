Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with ESMTP id 23B866B004D
	for <linux-mm@kvack.org>; Wed, 18 Nov 2009 23:44:00 -0500 (EST)
Date: Thu, 19 Nov 2009 13:27:34 +0900
From: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
Subject: [PATCH -mmotm 0/5] memcg: recharge at task move (19/Nov)
Message-Id: <20091119132734.1757fc42.nishimura@mxp.nes.nec.co.jp>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: linux-mm <linux-mm@kvack.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Balbir Singh <balbir@linux.vnet.ibm.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Li Zefan <lizf@cn.fujitsu.com>, Paul Menage <menage@google.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
List-ID: <linux-mm.kvack.org>

Hi.

These are current patches of my recharge-at-task-move feature.
They(precisely, only [5/5]) are dependent on KAMEZAWA-san's per-process swap usage patch,
which is not merged yet, so are not for inclusion yet. I post them just for review and
to share my current code.

In current memcg, charges associated with a task aren't moved to the new cgroup
at task move. Some users feel this behavior to be strange.
These patches are for this feature, that is, for recharging to
the new cgroup and, of course, uncharging from old cgroup at task move.

Current version supports only recharge of non-shared(mapcount == 1) anonymous pages
and swaps of those pages. I think it's enough as a first step.

  [1/5] cgroup: introduce cancel_attach()
  [2/5] memcg: add interface to recharge at task move
  [3/5] memcg: recharge charges of anonymous page
  [4/5] memcg: avoid oom during recharge at task move
  [5/5] memcg: recharge charges of anonymous swap

Overall history of this patch set:
2009/11/19
- rebase on mmotm-2009-11-17-14-03 + KAMEZAWA-san's show per-process swap usage
  via procfs patch(v3).
- in can_attach(), instead of parsing the page table, make use of per process
  mm_counter(anon_rss, swap_usage).
- handle recharge_at_immigrate as bitmask(as I did in first version)
- use mm->owner instead of thread_group_leader()
2009/11/06
- remove "[RFC]".
- rebase on mmotm-2009-11-01-10-01.
- drop support for file cache and shmem/tmpfs(revisit in future).
- update Documentation/cgroup/memory.txt.
2009/10/13
- rebase on mmotm-2009-10-09-01-07 + KAMEZAWA-san's batched charge/uncharge(Oct09) + part
of KAMEZAWA-san's cleanup/fix patches(4,5,7 of Sep25 with some fixes).
- change the term "migrate" to "recharge".
2009/09/24
- change "migrate_charge" flag from "int" to "bool".
- in can_attach(), parse the page table of the task and count only the number
  of target ptes and call try_charge() repeatedly. No isolation at this phase.
- in attach(), parse the page table of the task again, and isolate the target
  page and call move_account() one by one.
- do no swap-in in moving swap account any more.
- add support for shmem/tmpfs's swap.
- update Documentation/cgroup/cgroup.txt.
2009/09/17
- first version

TODO:
- add support for file cache, shmem/tmpfs, and shared(mapcount > 1) pages.
- implement madvise(2) to let users decide the target vma for recharge.

Any comments or suggestions would be welcome.


Thanks,
Dasiuke Nishimura.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
