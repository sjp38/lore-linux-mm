Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id EA71F8D0001
	for <linux-mm@kvack.org>; Fri, 12 Nov 2010 13:56:34 -0500 (EST)
Subject: (mem hotplug, pcpu_alloc) BUG: sleeping function called from
	invalid context at kernel/mutex.c:94
From: Alok Kataria <akataria@vmware.com>
Reply-To: akataria@vmware.com
Content-Type: text/plain
Date: Fri, 12 Nov 2010 10:56:18 -0800
Message-Id: <1289588178.7486.15.camel@ank32.eng.vmware.com>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: linux-mm <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>
Cc: Tejun Heo <tj@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Petr Vandrovec <petr@vmware.com>
List-ID: <linux-mm.kvack.org>

Hi,

We have seen following might_sleep warning while hot adding memory...

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


This warning was seen on the FC14 kernel, though looking at the current
git, the problem seems to exist on mainline too.
The problem is that pcpu_alloc expects that it is called from non-atomic
context as a result it grabs the pcpu_alloc_mutex. 
In the memory-hotplug case though, we do end up calling pcpu_alloc from
atomic context, while all cpus are stopped.

void build_all_zonelists(void *data)
{
   set_zonelist_order();

   if (system_state == SYSTEM_BOOTING) {
      __build_all_zonelists(NULL);
      mminit_verify_zonelist();
      cpuset_init_current_mems_allowed();
   } else {
      /* we have to stop all cpus to guarantee there is no user
         of zonelist */
      stop_machine(__build_all_zonelists, data, NULL);   <=========
      /* cpuset refresh routine should be here */
   }

__build_all_zonelists eventually calls pcpu_alloc. 

I didn't dive through the history, so am not sure when was this
regression introduced, but could have regressed with the new pcpu memory
allocator.

--
Alok

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
