Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with ESMTP id 1BA506B0044
	for <linux-mm@kvack.org>; Mon, 21 Dec 2009 00:42:57 -0500 (EST)
Date: Mon, 21 Dec 2009 14:31:06 +0900
From: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
Subject: [PATCH -mmotm 0/8] memcg: move charge at task migration (21/Dec)
Message-Id: <20091221143106.6ff3ca15.nishimura@mxp.nes.nec.co.jp>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Balbir Singh <balbir@linux.vnet.ibm.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Li Zefan <lizf@cn.fujitsu.com>, Paul Menage <menage@google.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

Hi.

These are the latest version of my move-charge-at-task-migration patch.

As I said in http://marc.info/?l=linux-mm&m=126135930226969&w=2, I've fixed
the BUG I found in 14/Dec version, and I think they are ready to be merged
into mmotm. These patches are based on mmotm-2009-12-10-17-19, but can be
applied onto 2.6.33-rc1-git1 too.


  [1/8] cgroup: introduce cancel_attach()
  [2/8] cgroup: introduce coalesce css_get() and css_put()
  [3/8] memcg: add interface to move charge at task migration
  [4/8] memcg: move charges of anonymous page
  [5/8] memcg: improve performance in moving charge
  [6/8] memcg: avoid oom during moving charge
  [7/8] memcg: move charges of anonymous swap
  [8/8] memcg: improbe performance in moving swap charge

 Documentation/cgroups/cgroups.txt |   13 +-
 Documentation/cgroups/memory.txt  |   56 +++-
 include/linux/cgroup.h            |   14 +-
 include/linux/page_cgroup.h       |    2 +
 include/linux/swap.h              |    1 +
 kernel/cgroup.c                   |   45 ++-
 mm/memcontrol.c                   |  649 +++++++++++++++++++++++++++++++++++--
 mm/page_cgroup.c                  |   35 ++-
 mm/swapfile.c                     |   31 ++
 9 files changed, 796 insertions(+), 50 deletions(-)


Overall history of this patch set:
2009/12/21
- Fix NULL pointer dereference BUG.
2009/12/14
- rebase on mmotm-2009-12-10-17-19.
- split performance improvement patch into cgroup part and memcg part.
- make use of waitq in avoid-oom patch.
- add TODO section in memory.txt.
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
Daisuke Nishimura.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
