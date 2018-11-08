Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f71.google.com (mail-ed1-f71.google.com [209.85.208.71])
	by kanga.kvack.org (Postfix) with ESMTP id 142B16B05C9
	for <linux-mm@kvack.org>; Thu,  8 Nov 2018 05:04:34 -0500 (EST)
Received: by mail-ed1-f71.google.com with SMTP id d17-v6so11019320edv.4
        for <linux-mm@kvack.org>; Thu, 08 Nov 2018 02:04:34 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id e28-v6sor2006987edd.2.2018.11.08.02.04.32
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 08 Nov 2018 02:04:32 -0800 (PST)
From: Michal Hocko <mhocko@kernel.org>
Subject: [RFC PATCH] mm, memory_hotplug: do not clear numa_node association after hot_remove
Date: Thu,  8 Nov 2018 11:04:13 +0100
Message-Id: <20181108100413.966-1-mhocko@kernel.org>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: Andrew Morton <akpm@linux-foundation.org>, Oscar Salvador <OSalvador@suse.com>, LKML <linux-kernel@vger.kernel.org>, Michal Hocko <mhocko@suse.com>, Wen Congyang <tangchen@cn.fujitsu.com>, Tang Chen <wency@cn.fujitsu.com>, Miroslav Benes <mbenes@suse.cz>, Vlastimil Babka <vbabka@suse.cz>

From: Michal Hocko <mhocko@suse.com>

Per-cpu numa_node provides a default node for each possible cpu. The
association gets initialized during the boot when the architecture
specific code explores cpu->NUMA affinity. When the whole NUMA node is
removed though we are clearing this association

try_offline_node
  check_and_unmap_cpu_on_node
    unmap_cpu_on_node
      numa_clear_node
        numa_set_node(cpu, NUMA_NO_NODE)

This means that whoever calls cpu_to_node for a cpu associated with such
a node will get NUMA_NO_NODE. This is problematic for two reasons. First
it is fragile because __alloc_pages_node would simply blow up on an
out-of-bound access. We have encountered this when loading kvm module
BUG: unable to handle kernel paging request at 00000000000021c0
IP: [<ffffffff8119ccb3>] __alloc_pages_nodemask+0x93/0xb70
PGD 800000ffe853e067 PUD 7336bbc067 PMD 0
Oops: 0000 [#1] SMP
[...]
CPU: 88 PID: 1223749 Comm: modprobe Tainted: G        W          4.4.156-94.64-default #1
task: ffff88727eff1880 ti: ffff887354490000 task.ti: ffff887354490000
RIP: 0010:[<ffffffff8119ccb3>]  [<ffffffff8119ccb3>] __alloc_pages_nodemask+0x93/0xb70
RSP: 0018:ffff887354493b40  EFLAGS: 00010202
RAX: 00000000000021c0 RBX: 0000000000000000 RCX: 0000000000000000
RDX: 0000000000000000 RSI: 0000000000000002 RDI: 00000000014000c0
RBP: 00000000014000c0 R08: ffffffffffffffff R09: 0000000000000000
R10: ffff88fffc89e790 R11: 0000000000014000 R12: 0000000000000101
R13: ffffffffa0772cd4 R14: ffffffffa0769ac0 R15: 0000000000000000
FS:  00007fdf2f2f1700(0000) GS:ffff88fffc880000(0000) knlGS:0000000000000000
CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
CR2: 00000000000021c0 CR3: 00000077205ee000 CR4: 0000000000360670
DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
DR3: 0000000000000000 DR6: 00000000fffe0ff0 DR7: 0000000000000400
Stack:
 0000000000000086 014000c014d20400 ffff887354493bb8 ffff882614d20f4c
 0000000000000000 0000000000000046 0000000000000046 ffffffff810ac0c9
 ffff88ffe78c0000 ffffffff0000009f ffffe8ffe82d3500 ffff88ff8ac55000
Call Trace:
 [<ffffffffa07476cd>] alloc_vmcs_cpu+0x3d/0x90 [kvm_intel]
 [<ffffffffa0772c0c>] hardware_setup+0x781/0x849 [kvm_intel]
 [<ffffffffa04a1c58>] kvm_arch_hardware_setup+0x28/0x190 [kvm]
 [<ffffffffa04856fc>] kvm_init+0x7c/0x2d0 [kvm]
 [<ffffffffa0772cf2>] vmx_init+0x1e/0x32c [kvm_intel]
 [<ffffffff8100213a>] do_one_initcall+0xca/0x1f0
 [<ffffffff81193886>] do_init_module+0x5a/0x1d7
 [<ffffffff81112083>] load_module+0x1393/0x1c90
 [<ffffffff81112b30>] SYSC_finit_module+0x70/0xa0
 [<ffffffff8161cbc3>] entry_SYSCALL_64_fastpath+0x1e/0xb7
DWARF2 unwinder stuck at entry_SYSCALL_64_fastpath+0x1e/0xb7

on an older kernel but the code is basically the same in the current
Linus tree as well. alloc_vmcs_cpu could use alloc_pages_nodemask which
would recognize NUMA_NO_NODE and use alloc_pages_node which would translate
it to numa_mem_id but that is wrong as well because it would use a cpu
affinity of the local CPU which might be quite far from the original node.
It is also reasonable to expect that cpu_to_node will provide a sane value
and there might be many more callers like that.

The second problem is that __register_one_node relies on cpu_to_node
to properly associate cpus back to the node when it is onlined. We do
not want to lose that link as there is no arch independent way to get it
from the early boot time AFAICS.

Drop the whole check_and_unmap_cpu_on_node machinery and keep the
association to fix both issues. The NODE_DATA(nid) is not deallocated
so it will stay in place and if anybody wants to allocate from that node
then a fallback node will be used.

Thanks to Vlastimil Babka for his live system debugging skills that
helped debugging the issue.

Debugged-by: Vlastimil Babka <vbabka@suse.cz>
Reported-by: Miroslav Benes <mbenes@suse.cz>
Fixes: e13fe8695c57 ("cpu-hotplug,memory-hotplug: clear cpu_to_node() when offlining the node")
Cc: Wen Congyang <tangchen@cn.fujitsu.com>
Cc: Tang Chen <wency@cn.fujitsu.com>
Signed-off-by: Michal Hocko <mhocko@suse.com>
---

Hi,
please note that I am sending this as an RFC even though this has been
confirmed to fix the oops in kvm_intel module because I cannot simply
tell that there are no other side effect that I do not see from the code
reading. I would appreciate some background from people who have
introduced this code e13fe8695c57 ("cpu-hotplug,memory-hotplug: clear
cpu_to_node() when offlining the node") because the changelog doesn't
really explain the motivation much.

 mm/memory_hotplug.c | 30 +-----------------------------
 1 file changed, 1 insertion(+), 29 deletions(-)

diff --git a/mm/memory_hotplug.c b/mm/memory_hotplug.c
index 2b2b3ccbbfb5..87aeafac54ee 100644
--- a/mm/memory_hotplug.c
+++ b/mm/memory_hotplug.c
@@ -1753,34 +1753,6 @@ static int check_cpu_on_node(pg_data_t *pgdat)
 	return 0;
 }
 
-static void unmap_cpu_on_node(pg_data_t *pgdat)
-{
-#ifdef CONFIG_ACPI_NUMA
-	int cpu;
-
-	for_each_possible_cpu(cpu)
-		if (cpu_to_node(cpu) == pgdat->node_id)
-			numa_clear_node(cpu);
-#endif
-}
-
-static int check_and_unmap_cpu_on_node(pg_data_t *pgdat)
-{
-	int ret;
-
-	ret = check_cpu_on_node(pgdat);
-	if (ret)
-		return ret;
-
-	/*
-	 * the node will be offlined when we come here, so we can clear
-	 * the cpu_to_node() now.
-	 */
-
-	unmap_cpu_on_node(pgdat);
-	return 0;
-}
-
 /**
  * try_offline_node
  * @nid: the node ID
@@ -1813,7 +1785,7 @@ void try_offline_node(int nid)
 		return;
 	}
 
-	if (check_and_unmap_cpu_on_node(pgdat))
+	if (check_cpu_on_node(pgdat))
 		return;
 
 	/*
-- 
2.19.1
