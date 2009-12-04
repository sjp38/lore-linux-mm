Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id BEC9760021B
	for <linux-mm@kvack.org>; Fri,  4 Dec 2009 01:47:47 -0500 (EST)
Date: Fri, 4 Dec 2009 14:46:09 +0900
From: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
Subject: [PATCH -mmotm 0/7] memcg: move charge at task migration (04/Dec)
Message-Id: <20091204144609.b61cc8c4.nishimura@mxp.nes.nec.co.jp>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Balbir Singh <balbir@linux.vnet.ibm.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Li Zefan <lizf@cn.fujitsu.com>, Paul Menage <menage@google.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

Hi.

These are current patches of my move-charge-at-task-migration feature.

The biggest change from previous(19/Nov) version is improvement in performance.

I measured the elapsed time of "echo [pid] > <some path>/tasks" on KVM guest
with 4CPU/4GB(Xeon/3GHz) in three patterns:

  (1) / -> /00
  (2) /00 -> /01

  we don't need to call res_counter_uncharge against root, so (1) would be smaller
  than (2).

  (3) /00(setting mem.limit to half size of total) -> /01

  To compare the overhead of anon and swap.

In 19/Nov version:
       |  252M  |  512M  |   1G
  -----+--------+--------+--------
   (1) |  0.21  |  0.41  |  0.821
  -----+--------+--------+--------
   (2) |  0.43  |  0.85  |  1.71
  -----+--------+--------+--------
   (3) |  0.40  |  0.81  |  1.62
  -----+--------+--------+--------

In this version:
       |  252M  |  512M  |   1G
  -----+--------+--------+--------
   (1) |  0.15  |  0.30  |  0.60
  -----+--------+--------+--------
   (2) |  0.15  |  0.30  |  0.60
  -----+--------+--------+--------
   (3) |  0.22  |  0.44  |  0.89

Please read patch descriptions for each patch([4/7],[7/7]) for details of
how and how much the patch improved the performance.

  [1/7] cgroup: introduce cancel_attach()
  [2/7] memcg: add interface to move charge at task migration
  [3/7] memcg: move charges of anonymous page
  [4/7] memcg: improbe performance in moving charge
  [5/7] memcg: avoid oom during moving charge
  [6/7] memcg: move charges of anonymous swap
  [7/7] memcg: improbe performance in moving swap charge

Current version supports only recharge of non-shared(mapcount == 1) anonymous pages
and swaps of those pages. I think it's enough as a first step.


Overall history of this patch set:
2009/12/04
- rebase on mmotm-2009-11-24-16-47.
- change the term "recharge" to "move charge".
- improve performance in moving charge.
- parse the page table in can_attach() phase again(go back to the old behavior),
  because it doesn't add so big overheads, so it would be better to calculate
  the precharge count more accurately.
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


Regards,
Dasiuke Nishimura.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
