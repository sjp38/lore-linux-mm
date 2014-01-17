Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qa0-f43.google.com (mail-qa0-f43.google.com [209.85.216.43])
	by kanga.kvack.org (Postfix) with ESMTP id 2275B6B0035
	for <linux-mm@kvack.org>; Fri, 17 Jan 2014 10:18:43 -0500 (EST)
Received: by mail-qa0-f43.google.com with SMTP id o15so3380893qap.2
        for <linux-mm@kvack.org>; Fri, 17 Jan 2014 07:18:43 -0800 (PST)
Received: from qmta08.emeryville.ca.mail.comcast.net (qmta08.emeryville.ca.mail.comcast.net. [2001:558:fe2d:43:76:96:30:80])
        by mx.google.com with ESMTP id v1si1599830qcl.21.2014.01.17.07.18.41
        for <linux-mm@kvack.org>;
        Fri, 17 Jan 2014 07:18:42 -0800 (PST)
Message-Id: <20140117151835.920139508@linux.com>
Date: Fri, 17 Jan 2014 09:18:27 -0600
From: Christoph Lameter <cl@linux.com>
Subject: [PATCH 15/41] mm: Use raw_cpu ops for determining current NUMA node
References: <20140117151812.770437629@linux.com>
Content-Type: text/plain; charset=UTF-8
Content-Disposition: inline; filename=preempt_fix_numa_node
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tejun Heo <tj@kernel.org>
Cc: akpm@linuxfoundation.org, rostedt@goodmis.org, linux-kernel@vger.kernel.org, Ingo Molnar <mingo@kernel.org>, Peter Zijlstra <peterz@infradead.org>, Thomas Gleixner <tglx@linutronix.de>, linux-mm@kvack.org, Alex Shi <alex.shi@intel.com>

[Patch depends on another patch in this series that introduces raw_cpu_ops]

With the preempt checking logic for __this_cpu_ops we will get false
positives from locations in the code that use numa_node_id.

Before the  __this_cpu ops where introduced there were
no checks for preemption present either. smp_raw_processor_id()
was used. See http://www.spinics.net/lists/linux-numa/msg00641.html

Therefore we need to use raw_cpu_read here to avoid false postives.

Note that this issue has been discussed in prior years.
If the process changes nodes after retrieving the current numa node then
that is acceptable since most uses of numa_node etc are for optimization
and not for correctness.

There were suggestions to implement a raw_numa_node_id in order to
do preempt checks for numa_node_id as well. But I think we better
defer that to another patch since that would mean investigating
how numa_node_id() is used throughout the kernel which would increase
the scope of this patchset significantly. After all preemption was never
checked before when numa_node_id() was used.

Some sample traces:

__this_cpu_read operation in preemptible [00000000] code: login/1456
caller is __this_cpu_preempt_check+0x2b/0x2d
CPU: 0 PID: 1456 Comm: login Not tainted 3.12.0-rc4-cl-00062-g2fe80d3-dirty #185
Hardware name: Bochs Bochs, BIOS Bochs 01/01/2011
 000000000000013c ffff88001f31ba58 ffffffff8147cf5e ffff88001f31bfd8
 ffff88001f31ba88 ffffffff8127eea9 0000000000000000 ffff88001f3975c0
 00000000f7707000 ffff88001f3975c0 ffff88001f31bac0 ffffffff8127eeef
Call Trace:
 [<ffffffff8147cf5e>] dump_stack+0x4e/0x82
 [<ffffffff8127eea9>] check_preemption_disabled+0xc5/0xe0
 [<ffffffff8127eeef>] __this_cpu_preempt_check+0x2b/0x2d
 [<ffffffff81030ff5>] ? show_stack+0x3b/0x3d
 [<ffffffff810ebee3>] get_task_policy+0x1d/0x49
 [<ffffffff810ed705>] get_vma_policy+0x14/0x76
 [<ffffffff810ed8ff>] alloc_pages_vma+0x35/0xff
 [<ffffffff810dad97>] handle_mm_fault+0x290/0x73b
 [<ffffffff810503da>] __do_page_fault+0x3fe/0x44d
 [<ffffffff8109b360>] ? trace_hardirqs_on_caller+0x142/0x19e
 [<ffffffff8109b3c9>] ? trace_hardirqs_on+0xd/0xf
 [<ffffffff81278bed>] ? trace_hardirqs_off_thunk+0x3a/0x3c
 [<ffffffff810be97f>] ? find_get_pages_contig+0x18e/0x18e
 [<ffffffff810be97f>] ? find_get_pages_contig+0x18e/0x18e
 [<ffffffff81050451>] do_page_fault+0x9/0xc
 [<ffffffff81483602>] page_fault+0x22/0x30
 [<ffffffff810be97f>] ? find_get_pages_contig+0x18e/0x18e
 [<ffffffff810be97f>] ? find_get_pages_contig+0x18e/0x18e
 [<ffffffff810be4c3>] ? file_read_actor+0x3a/0x15a
 [<ffffffff810be97f>] ? find_get_pages_contig+0x18e/0x18e
 [<ffffffff810bffab>] generic_file_aio_read+0x38e/0x624
 [<ffffffff810f6d69>] do_sync_read+0x54/0x73
 [<ffffffff810f7890>] vfs_read+0x9d/0x12a
 [<ffffffff810f7a59>] SyS_read+0x47/0x7e
 [<ffffffff81484f21>] cstar_dispatch+0x7/0x23


caller is __this_cpu_preempt_check+0x2b/0x2d
CPU: 0 PID: 1456 Comm: login Not tainted 3.12.0-rc4-cl-00062-g2fe80d3-dirty #185
Hardware name: Bochs Bochs, BIOS Bochs 01/01/2011
 00000000000000e8 ffff88001f31bbf8 ffffffff8147cf5e ffff88001f31bfd8
 ffff88001f31bc28 ffffffff8127eea9 ffffffff823c5c40 00000000000213da
 0000000000000000 0000000000000000 ffff88001f31bc60 ffffffff8127eeef
Call Trace:
 [<ffffffff8147cf5e>] dump_stack+0x4e/0x82
 [<ffffffff8127eea9>] check_preemption_disabled+0xc5/0xe0
 [<ffffffff8127eeef>] __this_cpu_preempt_check+0x2b/0x2d
 [<ffffffff810e006e>] ? install_special_mapping+0x11/0xe4
 [<ffffffff810ec8a8>] alloc_pages_current+0x8f/0xbc
 [<ffffffff810bec6b>] __page_cache_alloc+0xb/0xd
 [<ffffffff810c7e90>] __do_page_cache_readahead+0xf4/0x219
 [<ffffffff810c7e0e>] ? __do_page_cache_readahead+0x72/0x219
 [<ffffffff810c827c>] ra_submit+0x1c/0x20
 [<ffffffff810c850c>] ondemand_readahead+0x28c/0x2b4
 [<ffffffff810c85e9>] page_cache_sync_readahead+0x38/0x3a
 [<ffffffff810bfe7e>] generic_file_aio_read+0x261/0x624
 [<ffffffff810f6d69>] do_sync_read+0x54/0x73
 [<ffffffff810f7890>] vfs_read+0x9d/0x12a
 [<ffffffff810f7a59>] SyS_read+0x47/0x7e
 [<ffffffff81484f21>] cstar_dispatch+0x7/0x23

Cc: linux-mm@kvack.org
Cc: Alex Shi <alex.shi@intel.com>
Acked-by: Ingo Molnar <mingo@kernel.org>
Signed-off-by: Christoph Lameter <cl@linux.com>

Index: linux/include/linux/topology.h
===================================================================
--- linux.orig/include/linux/topology.h	2013-12-02 16:07:51.304591590 -0600
+++ linux/include/linux/topology.h	2013-12-02 16:07:51.304591590 -0600
@@ -188,7 +188,7 @@ DECLARE_PER_CPU(int, numa_node);
 /* Returns the number of the current Node. */
 static inline int numa_node_id(void)
 {
-	return __this_cpu_read(numa_node);
+	return raw_cpu_read(numa_node);
 }
 #endif
 
@@ -245,7 +245,7 @@ static inline void set_numa_mem(int node
 /* Returns the number of the nearest Node with memory */
 static inline int numa_mem_id(void)
 {
-	return __this_cpu_read(_numa_mem_);
+	return raw_cpu_read(_numa_mem_);
 }
 #endif
 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
