Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f71.google.com (mail-ed1-f71.google.com [209.85.208.71])
	by kanga.kvack.org (Postfix) with ESMTP id A51FA8E0001
	for <linux-mm@kvack.org>; Tue, 22 Jan 2019 03:06:41 -0500 (EST)
Received: by mail-ed1-f71.google.com with SMTP id b3so9024824edi.0
        for <linux-mm@kvack.org>; Tue, 22 Jan 2019 00:06:41 -0800 (PST)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id y49si4099576edd.80.2019.01.22.00.06.39
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 22 Jan 2019 00:06:39 -0800 (PST)
From: Juergen Gross <jgross@suse.com>
Subject: [PATCH 2/2] x86/xen: dont add memory above max allowed allocation
Date: Tue, 22 Jan 2019 09:06:28 +0100
Message-Id: <20190122080628.7238-3-jgross@suse.com>
In-Reply-To: <20190122080628.7238-1-jgross@suse.com>
References: <20190122080628.7238-1-jgross@suse.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org, xen-devel@lists.xenproject.org, x86@kernel.org, linux-mm@kvack.org
Cc: boris.ostrovsky@oracle.com, sstabellini@kernel.org, hpa@zytor.com, tglx@linutronix.de, mingo@redhat.com, bp@alien8.de, Juergen Gross <jgross@suse.com>

Don't allow memory to be added above the allowed maximum allocation
limit set by Xen.

Trying to do so would result in cases like the following:

[  584.559652] ------------[ cut here ]------------
[  584.564897] WARNING: CPU: 2 PID: 1 at ../arch/x86/xen/multicalls.c:129 xen_alloc_pte+0x1c7/0x390()
[  584.575151] Modules linked in:
[  584.578643] Supported: Yes
[  584.581750] CPU: 2 PID: 1 Comm: swapper/0 Not tainted 4.4.120-92.70-default #1
[  584.590000] Hardware name: Cisco Systems Inc UCSC-C460-M4/UCSC-C460-M4, BIOS C460M4.4.0.1b.0.0629181419 06/29/2018
[  584.601862]  0000000000000000 ffffffff813175a0 0000000000000000 ffffffff8184777c
[  584.610200]  ffffffff8107f4e1 ffff880487eb7000 ffff8801862b79c0 ffff88048608d290
[  584.618537]  0000000000487eb7 ffffea0000000201 ffffffff81009de7 ffffffff81068561
[  584.626876] Call Trace:
[  584.629699]  [<ffffffff81019ad9>] dump_trace+0x59/0x340
[  584.635645]  [<ffffffff81019eaa>] show_stack_log_lvl+0xea/0x170
[  584.642391]  [<ffffffff8101ac51>] show_stack+0x21/0x40
[  584.648238]  [<ffffffff813175a0>] dump_stack+0x5c/0x7c
[  584.654085]  [<ffffffff8107f4e1>] warn_slowpath_common+0x81/0xb0
[  584.660932]  [<ffffffff81009de7>] xen_alloc_pte+0x1c7/0x390
[  584.667289]  [<ffffffff810647f0>] pmd_populate_kernel.constprop.6+0x40/0x80
[  584.675241]  [<ffffffff815ecfe8>] phys_pmd_init+0x210/0x255
[  584.681587]  [<ffffffff815ed207>] phys_pud_init+0x1da/0x247
[  584.687931]  [<ffffffff815edb3b>] kernel_physical_mapping_init+0xf5/0x1d4
[  584.695682]  [<ffffffff815e9bdd>] init_memory_mapping+0x18d/0x380
[  584.702631]  [<ffffffff81064699>] arch_add_memory+0x59/0xf0

Signed-off-by: Juergen Gross <jgross@suse.com>
---
 arch/x86/xen/setup.c | 5 +++++
 1 file changed, 5 insertions(+)

diff --git a/arch/x86/xen/setup.c b/arch/x86/xen/setup.c
index d5f303c0e656..5929a6ba5c25 100644
--- a/arch/x86/xen/setup.c
+++ b/arch/x86/xen/setup.c
@@ -12,6 +12,7 @@
 #include <linux/memblock.h>
 #include <linux/cpuidle.h>
 #include <linux/cpufreq.h>
+#include <linux/memory_hotplug.h>
 
 #include <asm/elf.h>
 #include <asm/vdso.h>
@@ -785,6 +786,10 @@ char * __init xen_memory_setup(void)
 	/* How many extra pages do we need due to remapping? */
 	max_pages += xen_foreach_remap_area(max_pfn, xen_count_remap_pages);
 
+#ifdef CONFIG_MEMORY_HOTPLUG
+	max_mem_size = PFN_PHYS(max_pages);
+#endif
+
 	if (max_pages > max_pfn)
 		extra_pages += max_pages - max_pfn;
 
-- 
2.16.4
