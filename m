Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id 779A56B00E7
	for <linux-mm@kvack.org>; Mon, 13 Sep 2010 03:13:58 -0400 (EDT)
Received: from m6.gw.fujitsu.co.jp ([10.0.50.76])
	by fgwmail7.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o8D7Ds8K001296
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Mon, 13 Sep 2010 16:13:54 +0900
Received: from smail (m6 [127.0.0.1])
	by outgoing.m6.gw.fujitsu.co.jp (Postfix) with ESMTP id 6784B45DD70
	for <linux-mm@kvack.org>; Mon, 13 Sep 2010 16:13:54 +0900 (JST)
Received: from s6.gw.fujitsu.co.jp (s6.gw.fujitsu.co.jp [10.0.50.96])
	by m6.gw.fujitsu.co.jp (Postfix) with ESMTP id 4BB6B45DE4E
	for <linux-mm@kvack.org>; Mon, 13 Sep 2010 16:13:54 +0900 (JST)
Received: from s6.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s6.gw.fujitsu.co.jp (Postfix) with ESMTP id 343B81DB8018
	for <linux-mm@kvack.org>; Mon, 13 Sep 2010 16:13:54 +0900 (JST)
Received: from ml14.s.css.fujitsu.com (ml14.s.css.fujitsu.com [10.249.87.104])
	by s6.gw.fujitsu.co.jp (Postfix) with ESMTP id E15DD1DB8016
	for <linux-mm@kvack.org>; Mon, 13 Sep 2010 16:13:53 +0900 (JST)
Date: Mon, 13 Sep 2010 16:08:22 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: [BUGFIX][PATCH] memcg: fix race in file_mapped accouting flag
 management
Message-Id: <20100913160822.0c2cd732.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: "linux-mm@kvack.org" <linux-mm@kvack.org>
Cc: "balbir@linux.vnet.ibm.com" <balbir@linux.vnet.ibm.com>, "nishimura@mxp.nes.nec.co.jp" <nishimura@mxp.nes.nec.co.jp>, gthelen@google.com, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, stable@kernel.org
List-ID: <linux-mm.kvack.org>


I think this small race is not very critical but it's bug.
We have this race since 2.6.34. 
=
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

Now. memory cgroup accounts file-mapped by counter and flag.
counter is working in the same way with zone_stat but FileMapped flag only
exists in memcg (for helping move_account).

This flag can be updated wrongly in a case. Assume CPU0 and CPU1
and a thread mapping a page on CPU0, another thread unmapping it on CPU1.

    CPU0                   		CPU1
				rmv rmap (mapcount 1->0)
   add rmap (mapcount 0->1)
   lock_page_cgroup()
   memcg counter+1		(some delay)
   set MAPPED FLAG.
   unlock_page_cgroup()
				lock_page_cgroup()
				memcg counter-1
				clear MAPPED flag

In above sequence, counter is properly updated but FLAG is not.
This means that representing a state by a flag which is maintained by
counter needs some specail care.

To handle this, at claering a flag, this patch check mapcount directly and
clear the flag only when mapcount == 0. (if mapcount >0, someone will make
it to zero later and flag will be cleared.)

Reverse case, dec-after-inc cannot be a problem because page_table_lock()
works well for it. (IOW, to make above sequence, 2 processes should touch
the same page at once with map/unmap.)

Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
---
 mm/memcontrol.c |    3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

Index: lockless-update/mm/memcontrol.c
===================================================================
--- lockless-update.orig/mm/memcontrol.c
+++ lockless-update/mm/memcontrol.c
@@ -1485,7 +1485,8 @@ void mem_cgroup_update_file_mapped(struc
 		SetPageCgroupFileMapped(pc);
 	} else {
 		__this_cpu_dec(mem->stat->count[MEM_CGROUP_STAT_FILE_MAPPED]);
-		ClearPageCgroupFileMapped(pc);
+		if (page_mapped(page)) /* for race between dec->inc counter */
+			ClearPageCgroupFileMapped(pc);
 	}
 
 done:

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
