Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id 88E586B003D
	for <linux-mm@kvack.org>; Mon, 14 Dec 2009 01:25:13 -0500 (EST)
Date: Mon, 14 Dec 2009 15:17:48 +0900
From: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
Subject: [PATCH -mmotm 0/8] memcg: move charge at task migration (14/Dec)
Message-Id: <20091214151748.bf9c4978.nishimura@mxp.nes.nec.co.jp>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: linux-mm <linux-mm@kvack.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Balbir Singh <balbir@linux.vnet.ibm.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Li Zefan <lizf@cn.fujitsu.com>, Paul Menage <menage@google.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
List-ID: <linux-mm.kvack.org>

Hi.

These are current patches of my move-charge-at-task-migration feature.

* They have not been mature enough to be merged into linus tree yet. *

Actually, there is a NULL pointer dereference BUG, which I found in my stress
test after about 40 hours running and I'm digging now.
I post these patches just to share my current status.

  [1/8] cgroup: introduce cancel_attach()
  [2/8] cgroup: introduce coalesce css_get() and css_put()
  [3/8] memcg: add interface to move charge at task migration
  [4/8] memcg: move charges of anonymous page
  [5/8] memcg: improve performance in moving charge
  [6/8] memcg: avoid oom during moving charge
  [7/8] memcg: move charges of anonymous swap
  [8/8] memcg: improbe performance in moving swap charge

Overall history of this patch set:
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
