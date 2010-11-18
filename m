Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id EE00E6B004A
	for <linux-mm@kvack.org>; Thu, 18 Nov 2010 02:45:23 -0500 (EST)
Received: from m3.gw.fujitsu.co.jp ([10.0.50.73])
	by fgwmail7.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id oAI7jKCb011717
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Thu, 18 Nov 2010 16:45:20 +0900
Received: from smail (m3 [127.0.0.1])
	by outgoing.m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 0BD5145DE4F
	for <linux-mm@kvack.org>; Thu, 18 Nov 2010 16:45:20 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (s3.gw.fujitsu.co.jp [10.0.50.93])
	by m3.gw.fujitsu.co.jp (Postfix) with ESMTP id DCCEE45DE4E
	for <linux-mm@kvack.org>; Thu, 18 Nov 2010 16:45:19 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id C959A1DB803B
	for <linux-mm@kvack.org>; Thu, 18 Nov 2010 16:45:19 +0900 (JST)
Received: from ml13.s.css.fujitsu.com (ml13.s.css.fujitsu.com [10.249.87.103])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 625631DB803E
	for <linux-mm@kvack.org>; Thu, 18 Nov 2010 16:45:16 +0900 (JST)
Date: Thu, 18 Nov 2010 16:39:36 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: [BUGFIX][PATCH] fix build_all_zonelist where percpu_alloc is
 wrongly called under stop_machine_run (Was Re: (mem hotplug, pcpu_alloc)
 BUG: sleeping function called from invalid context at kernel/mutex.c:94
Message-Id: <20101118163936.2a533930.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <4CDE63D3.4010608@kernel.org>
References: <1289588178.7486.15.camel@ank32.eng.vmware.com>
	<4CDE63D3.4010608@kernel.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Tejun Heo <tj@kernel.org>
Cc: akataria@vmware.com, linux-mm <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Petr Vandrovec <petr@vmware.com>, Pekka Enberg <penberg@cs.helsinki.fi>, Christoph Lameter <cl@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

On Sat, 13 Nov 2010 11:09:23 +0100
Tejun Heo <tj@kernel.org> wrote:

> Meh... the percpu allocator required user context from the beginning.
> The new allocator didn't change that.
> 
> Wouldn't it be possible to prepare hotplug outside of cpu_stop and use
> stop_machine() only to make it available to the system.  In general,
> it's a very bad idea to allocate memory from inside stop_machine.  The
> whole machine is stopped, after all.  In general, it shouldn't be too
> difficult to add new resource without stop_machine too unlike removing
> one.  Pekka, Christoph, any ideas?
> 

Fix here. I'm glad if someone test this.
==

At memory hotplug, build_allzonelists() may be called under stop_machine_run().
In this function, setup_zone_pageset() is called. But it's bug because it
will do page allocation under stop_machine_run().

Here is a report from Alok Kataria.

[  142.339267] BUG: sleeping function called from invalid context at kernel/mutex.c:94
[  142.339276] in_atomic(): 0, irqs_disabled(): 1, pid: 4, name: migration/0
[  142.339283] Pid: 4, comm: migration/0 Not tainted 2.6.35.6-45.fc14.x86_64 #1
[  142.339288] Call Trace:
[  142.339305]  [<ffffffff8103d12b>] __might_sleep+0xeb/0xf0
[  142.339316]  [<ffffffff81468245>] mutex_lock+0x24/0x50
[  142.339326]  [<ffffffff8110eaa6>] pcpu_alloc+0x6d/0x7ee
[  142.339336]  [<ffffffff81048888>] ? load_balance+0xbe/0x60e
[  142.339343]  [<ffffffff8103a1b3>] ? rt_se_boosted+0x21/0x2f
[  142.339349]  [<ffffffff8103e1cf>] ? dequeue_rt_stack+0x18b/0x1ed
[  142.339356]  [<ffffffff8110f237>] __alloc_percpu+0x10/0x12
[  142.339362]  [<ffffffff81465e22>] setup_zone_pageset+0x38/0xbe
[  142.339373]  [<ffffffff810d6d81>] ? build_zonelists_node.clone.58+0x79/0x8c
[  142.339384]  [<ffffffff81452539>] __build_all_zonelists+0x419/0x46c
[  142.339395]  [<ffffffff8108ef01>] ? cpu_stopper_thread+0xb2/0x198
[  142.339401]  [<ffffffff8108f075>] stop_machine_cpu_stop+0x8e/0xc5
[  142.339407]  [<ffffffff8108efe7>] ? stop_machine_cpu_stop+0x0/0xc5
[  142.339414]  [<ffffffff8108ef57>] cpu_stopper_thread+0x108/0x198
[  142.339420]  [<ffffffff81467a37>] ? schedule+0x5b2/0x5cc
[  142.339426]  [<ffffffff8108ee4f>] ? cpu_stopper_thread+0x0/0x198
[  142.339434]  [<ffffffff81065f29>] kthread+0x7f/0x87
[  142.339443]  [<ffffffff8100aae4>] kernel_thread_helper+0x4/0x10
[  142.339449]  [<ffffffff81065eaa>] ? kthread+0x0/0x87
[  142.339455]  [<ffffffff8100aae0>] ? kernel_thread_helper+0x0/0x10
[  142.340099] Built 5 zonelists in Node order, mobility grouping on.  Total pages: 289456
[  142.340108] Policy zone: Normal

This patch tries to fix the issue by moving setup_zone_pageset() out from
stop_machine_run(). It's obviously not necessary to be called under
stop_machine_run().

Reported-by: Alok Kataria <akataria@vmware.com>
Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
---
 mm/page_alloc.c |   16 +++++++---------
 1 file changed, 7 insertions(+), 9 deletions(-)

Index: mmotm-1117/mm/page_alloc.c
===================================================================
--- mmotm-1117.orig/mm/page_alloc.c
+++ mmotm-1117/mm/page_alloc.c
@@ -3027,14 +3027,6 @@ static __init_refok int __build_all_zone
 		build_zonelist_cache(pgdat);
 	}
 
-#ifdef CONFIG_MEMORY_HOTPLUG
-	/* Setup real pagesets for the new zone */
-	if (data) {
-		struct zone *zone = data;
-		setup_zone_pageset(zone);
-	}
-#endif
-
 	/*
 	 * Initialize the boot_pagesets that are going to be used
 	 * for bootstrapping processors. The real pagesets for
@@ -3083,7 +3075,13 @@ void build_all_zonelists(void *data)
 	} else {
 		/* we have to stop all cpus to guarantee there is no user
 		   of zonelist */
-		stop_machine(__build_all_zonelists, data, NULL);
+#ifdef CONFIG_MEMORY_HOTPLUG
+		if (data) {
+			struct zone *zone = (struct zone *)data;
+			setup_zone_pageset(zone);
+		}
+#endif
+		stop_machine(__build_all_zonelists, NULL, NULL);
 		/* cpuset refresh routine should be here */
 	}
 	vm_total_pages = nr_free_pagecache_pages();

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
