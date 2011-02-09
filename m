Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with SMTP id DB7868D003A
	for <linux-mm@kvack.org>; Wed,  9 Feb 2011 02:29:33 -0500 (EST)
Received: from m2.gw.fujitsu.co.jp (unknown [10.0.50.72])
	by fgwmail5.fujitsu.co.jp (Postfix) with ESMTP id F0E493EE0B5
	for <linux-mm@kvack.org>; Wed,  9 Feb 2011 16:29:31 +0900 (JST)
Received: from smail (m2 [127.0.0.1])
	by outgoing.m2.gw.fujitsu.co.jp (Postfix) with ESMTP id D022545DE61
	for <linux-mm@kvack.org>; Wed,  9 Feb 2011 16:29:31 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (s2.gw.fujitsu.co.jp [10.0.50.92])
	by m2.gw.fujitsu.co.jp (Postfix) with ESMTP id AC65A45DD74
	for <linux-mm@kvack.org>; Wed,  9 Feb 2011 16:29:31 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 9BE8C1DB803B
	for <linux-mm@kvack.org>; Wed,  9 Feb 2011 16:29:31 +0900 (JST)
Received: from m107.s.css.fujitsu.com (m107.s.css.fujitsu.com [10.249.87.107])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 659A41DB803E
	for <linux-mm@kvack.org>; Wed,  9 Feb 2011 16:29:31 +0900 (JST)
Date: Wed, 9 Feb 2011 16:23:24 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: [PATCH][BUGFIX] memcg: fix leak of accounting at failure path of
 hugepage collapsing.
Message-Id: <20110209162324.ea7e2e52.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20110209151036.f24a36a6.kamezawa.hiroyu@jp.fujitsu.com>
References: <20110209151036.f24a36a6.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>, "hannes@cmpxchg.org" <hannes@cmpxchg.org>, "nishimura@mxp.nes.nec.co.jp" <nishimura@mxp.nes.nec.co.jp>

There was a big bug. Anyway, thank you for adding new bad_page for memcg.
==

mem_cgroup_uncharge_page() should be called in all failure case
after mem_cgroup_charge_newpage() is called in 
huge_memory.c::collapse_huge_page()

 [ 4209.076861] BUG: Bad page state in process khugepaged  pfn:1e9800
 [ 4209.077601] page:ffffea0006b14000 count:0 mapcount:0 mapping:          (null) index:0x2800
 [ 4209.078674] page flags: 0x40000000004000(head)
 [ 4209.079294] pc:ffff880214a30000 pc->flags:2146246697418756 pc->mem_cgroup:ffffc9000177a000
 [ 4209.082177] (/A)
 [ 4209.082500] Pid: 31, comm: khugepaged Not tainted 2.6.38-rc3-mm1 #1
 [ 4209.083412] Call Trace:
 [ 4209.083678]  [<ffffffff810f4454>] ? bad_page+0xe4/0x140
 [ 4209.084240]  [<ffffffff810f53e6>] ? free_pages_prepare+0xd6/0x120
 [ 4209.084837]  [<ffffffff8155621d>] ? rwsem_down_failed_common+0xbd/0x150
 [ 4209.085509]  [<ffffffff810f5462>] ? __free_pages_ok+0x32/0xe0
 [ 4209.086110]  [<ffffffff810f552b>] ? free_compound_page+0x1b/0x20
 [ 4209.086699]  [<ffffffff810fad6c>] ? __put_compound_page+0x1c/0x30
 [ 4209.087333]  [<ffffffff810fae1d>] ? put_compound_page+0x4d/0x200
 [ 4209.087935]  [<ffffffff810fb015>] ? put_page+0x45/0x50
 [ 4209.097361]  [<ffffffff8113f779>] ? khugepaged+0x9e9/0x1430
 [ 4209.098364]  [<ffffffff8107c870>] ? autoremove_wake_function+0x0/0x40
 [ 4209.099121]  [<ffffffff8113ed90>] ? khugepaged+0x0/0x1430
 [ 4209.099780]  [<ffffffff8107c236>] ? kthread+0x96/0xa0
 [ 4209.100452]  [<ffffffff8100dda4>] ? kernel_thread_helper+0x4/0x10
 [ 4209.101214]  [<ffffffff8107c1a0>] ? kthread+0x0/0xa0
 [ 4209.101842]  [<ffffffff8100dda0>] ? kernel_thread_helper+0x0/0x10


Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
---
 mm/huge_memory.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

Index: mmotm-0204/mm/huge_memory.c
===================================================================
--- mmotm-0204.orig/mm/huge_memory.c
+++ mmotm-0204/mm/huge_memory.c
@@ -1852,7 +1852,6 @@ static void collapse_huge_page(struct mm
 		set_pmd_at(mm, address, pmd, _pmd);
 		spin_unlock(&mm->page_table_lock);
 		anon_vma_unlock(vma->anon_vma);
-		mem_cgroup_uncharge_page(new_page);
 		goto out;
 	}
 
@@ -1898,6 +1897,7 @@ out_up_write:
 	return;
 
 out:
+	mem_cgroup_uncharge_page(new_page);
 #ifdef CONFIG_NUMA
 	put_page(new_page);
 #endif

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
