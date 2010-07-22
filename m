Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id D79236006B6
	for <linux-mm@kvack.org>; Thu, 22 Jul 2010 03:46:05 -0400 (EDT)
Received: from m1.gw.fujitsu.co.jp ([10.0.50.71])
	by fgwmail7.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o6M7k3am023867
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Thu, 22 Jul 2010 16:46:03 +0900
Received: from smail (m1 [127.0.0.1])
	by outgoing.m1.gw.fujitsu.co.jp (Postfix) with ESMTP id 18B4445DE54
	for <linux-mm@kvack.org>; Thu, 22 Jul 2010 16:46:03 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (s1.gw.fujitsu.co.jp [10.0.50.91])
	by m1.gw.fujitsu.co.jp (Postfix) with ESMTP id EA22445DE4F
	for <linux-mm@kvack.org>; Thu, 22 Jul 2010 16:46:02 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id C98521DB804D
	for <linux-mm@kvack.org>; Thu, 22 Jul 2010 16:46:02 +0900 (JST)
Received: from m106.s.css.fujitsu.com (m106.s.css.fujitsu.com [10.249.87.106])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id 706BF1DB8045
	for <linux-mm@kvack.org>; Thu, 22 Jul 2010 16:46:02 +0900 (JST)
Date: Thu, 22 Jul 2010 16:41:18 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: [BUGFIX][PATCH] Fix false positive BUG_ON in __page_set_anon_rmap
Message-Id: <20100722164118.d500b850.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: "akpm@linux-foundation.org" <akpm@linux-foundation.org>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, Rik van Riel <riel@redhat.com>, kosaki.motohiro@jp.fujitsu.com, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

Rik, how do you think ?

==
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

Problem: wrong BUG_ON() in  __page_set_anon_rmap().
Kernel version: mmotm-0719

How to reproduce:
  create a small cgroup
  # mount -t cgroup none /cgroup -o memory
  # mkdir /cgroup/A
  # echo 30M > /cgroup/A/memory.limit_in_bytes

and run a malloc() program to cause swap-in v.s. swap-out ping-pong.

Description:
  Even if SwapCache is fully unmapped and mapcount goes down to 0,
  page->mapping is not cleared and will remain on memory until kswapd or some
  finds it. If a thread cause a page fault onto such "unmapped-but-not-discarded"
  swapcache, it will see a swap cache whose mapcount is 0 but page->mapping has a
  valid value.

  When it's reused at do_swap_page(), __page_set_anon_rmap() is called with
  "exclusive==1" and hits BUG_ON(). But this BUG_ON() is wrong. Nothing bad
  with rmapping a page which has page->mapping isn't 0.


Log:
Jul 22 16:06:02 ubuntu kernel: [  892.542485] 
Jul 22 16:06:02 ubuntu kernel: [  892.542488] Pid: 2951, comm: malloc Not tainted 2.6.35-rc5-mm1 #3 440BX Desktop Reference Platform/VMware Virtual Platform
Jul 22 16:06:02 ubuntu kernel: [  892.542491] RIP: 0010:[<ffffffff810e676c>]  [<ffffffff810e676c>] __page_set_anon_rmap+0x39/0x54
Jul 22 16:06:02 ubuntu kernel: [  892.542503] RSP: 0000:ffff880056a31dd8  EFLAGS: 00010202
Jul 22 16:06:02 ubuntu kernel: [  892.542505] RAX: ffff880059be7810 RBX: ffffea0001228038 RCX: ffff880059be7801
Jul 22 16:06:02 ubuntu kernel: [  892.542507] RDX: 0000000002823000 RSI: ffff8800569c5580 RDI: ffff8800569c5580
Jul 22 16:06:02 ubuntu kernel: [  892.542509] RBP: ffff880056a31de8 R08: ffff880056a31db8 R09: 00000000ffffffec
Jul 22 16:06:02 ubuntu kernel: [  892.542511] R10: ffff880056a31ec0 R11: ffffffff00000000 R12: ffff8800569c5580
Jul 22 16:06:02 ubuntu kernel: [  892.542514] R13: 0000000000000001 R14: 0000000000000008 R15: ffffea0001228038
Jul 22 16:06:02 ubuntu kernel: [  892.542517] FS:  00007f8c8d618700(0000) GS:ffff880001e00000(0000) knlGS:0000000000000000
Jul 22 16:06:02 ubuntu kernel: [  892.542520] CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
Jul 22 16:06:02 ubuntu kernel: [  892.542522] CR2: 0000000002823000 CR3: 00000000607e2000 CR4: 00000000000006f0
Jul 22 16:06:02 ubuntu kernel: [  892.542527] DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
Jul 22 16:06:02 ubuntu kernel: [  892.542532] DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7: 0000000000000400
Jul 22 16:06:02 ubuntu kernel: [  892.542535] Process malloc (pid: 2951, threadinfo ffff880056a30000, task ffff880037b796d0)
Jul 22 16:06:02 ubuntu kernel: [  892.542538]  ffff880056a31de8 ffffea0001228038 ffff880056a31e28 ffffffff810e6b3f
Jul 22 16:06:02 ubuntu kernel: [  892.542544] <0> ffff880000000001 0000000002823000 ffff8800569c5580 ffff8800569c5580
Jul 22 16:06:02 ubuntu kernel: [  892.542548] <0> ffff88005ed2f0a0 ffff88006359e300 ffff880056a31ef8 ffffffff810e07b8
Jul 22 16:06:02 ubuntu kernel: [  892.542556]  [<ffffffff810e6b3f>] do_page_add_anon_rmap+0x62/0x6d
Jul 22 16:06:02 ubuntu kernel: [  892.542560]  [<ffffffff810e07b8>] handle_mm_fault+0x716/0x8d7
Jul 22 16:06:02 ubuntu kernel: [  892.542567]  [<ffffffff8100870a>] ? __switch_to+0x215/0x227
Jul 22 16:06:02 ubuntu kernel: [  892.542571]  [<ffffffff81040d03>] ? pick_next_task_fair+0xdb/0xec
Jul 22 16:06:02 ubuntu kernel: [  892.542576]  [<ffffffff8144e42a>] ? schedule+0x589/0x5db
Jul 22 16:06:02 ubuntu kernel: [  892.542579]  [<ffffffff81453192>] do_page_fault+0x2c4/0x2dc
Jul 22 16:06:02 ubuntu kernel: [  892.542582]  [<ffffffff814502b5>] page_fault+0x25/0x30
Jul 22 16:06:02 ubuntu kernel: [  892.542619]  RSP <ffff880056a31dd8>
Jul 22 16:06:02 ubuntu kernel: [  892.542622] ---[ end trace 3e21bbaadd2d0799 ]---


Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
--
---
 mm/rmap.c |   12 ++++++++++--
 1 file changed, 10 insertions(+), 2 deletions(-)

Index: mmotm-2.6.35-0719/mm/rmap.c
===================================================================
--- mmotm-2.6.35-0719.orig/mm/rmap.c
+++ mmotm-2.6.35-0719/mm/rmap.c
@@ -783,8 +783,16 @@ static void __page_set_anon_rmap(struct 
 		if (PageAnon(page))
 			return;
 		anon_vma = anon_vma->root;
-	} else
-		BUG_ON(PageAnon(page));
+	} else {
+		/*
+ 		 * In this case, swapped-out-but-not-discarded swap-cache
+ 		 * is remapped. So, no need to update page->mapping here.
+ 		 * We convice anon_vma poitned by page->mapping is not obsolete
+ 		 * because vma->anon_vma is necessary to be a family of it.
+ 		 */
+		if (PageAnon(page))
+			return;
+	}
 
 	anon_vma = (void *) anon_vma + PAGE_MAPPING_ANON;
 	page->mapping = (struct address_space *) anon_vma;

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
