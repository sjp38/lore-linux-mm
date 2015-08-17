Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f46.google.com (mail-pa0-f46.google.com [209.85.220.46])
	by kanga.kvack.org (Postfix) with ESMTP id DD538280244
	for <linux-mm@kvack.org>; Sun, 16 Aug 2015 23:16:29 -0400 (EDT)
Received: by pabyb7 with SMTP id yb7so98432319pab.0
        for <linux-mm@kvack.org>; Sun, 16 Aug 2015 20:16:29 -0700 (PDT)
Received: from mga14.intel.com (mga14.intel.com. [192.55.52.115])
        by mx.google.com with ESMTP id b5si22255848pbu.237.2015.08.16.20.16.28
        for <linux-mm@kvack.org>;
        Sun, 16 Aug 2015 20:16:29 -0700 (PDT)
From: Jiang Liu <jiang.liu@linux.intel.com>
Subject: [Patch V3 7/9] x86, numa: Kill useless code to improve code readability
Date: Mon, 17 Aug 2015 11:19:04 +0800
Message-Id: <1439781546-7217-8-git-send-email-jiang.liu@linux.intel.com>
In-Reply-To: <1439781546-7217-1-git-send-email-jiang.liu@linux.intel.com>
References: <1439781546-7217-1-git-send-email-jiang.liu@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, David Rientjes <rientjes@google.com>, Mike Galbraith <umgwanakikbuti@gmail.com>, Peter Zijlstra <peterz@infradead.org>, "Rafael J . Wysocki" <rafael.j.wysocki@intel.com>, Tang Chen <tangchen@cn.fujitsu.com>, Tejun Heo <tj@kernel.org>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, "H. Peter Anvin" <hpa@zytor.com>, x86@kernel.org, Xishi Qiu <qiuxishi@huawei.com>, Jiang Liu <jiang.liu@linux.intel.com>, Luiz Capitulino <lcapitulino@redhat.com>, Dave Young <dyoung@redhat.com>
Cc: Tony Luck <tony.luck@intel.com>, linux-mm@kvack.org, linux-hotplug@vger.kernel.org, linux-kernel@vger.kernel.org

According to x86 boot sequence, early_cpu_to_node() always returns
NUMA_NO_NODE when called from numa_init(). So kill useless code
to improve code readability.

Related code sequence as below:
x86_cpu_to_node_map is set until step 2, so it is still the default
value (NUMA_NO_NODE) when accessed at step 1.

start_kernel()
	setup_arch()
		initmem_init()
			x86_numa_init()
				numa_init()
					early_cpu_to_node()
1)						return early_per_cpu_ptr(x86_cpu_to_node_map)[cpu];
		acpi_boot_init();
		sfi_init()
		x86_dtb_init()
			generic_processor_info()
				early_per_cpu(x86_cpu_to_apicid, cpu) = apicid;
		init_cpu_to_node()
			numa_set_node(cpu, node);
2)				per_cpu(x86_cpu_to_node_map, cpu) = node;

	rest_init()
		kernel_init()
			smp_init()
				native_cpu_up()
					start_secondary()
						numa_set_node()
							per_cpu(x86_cpu_to_node_map, cpu) = node;

Signed-off-by: Jiang Liu <jiang.liu@linux.intel.com>
---
 arch/x86/mm/numa.c |   10 ----------
 1 file changed, 10 deletions(-)

diff --git a/arch/x86/mm/numa.c b/arch/x86/mm/numa.c
index 4053bb58bf92..08860bdf5744 100644
--- a/arch/x86/mm/numa.c
+++ b/arch/x86/mm/numa.c
@@ -591,8 +591,6 @@ static void __init numa_init_array(void)
 
 	rr = first_node(node_online_map);
 	for (i = 0; i < nr_cpu_ids; i++) {
-		if (early_cpu_to_node(i) != NUMA_NO_NODE)
-			continue;
 		numa_set_node(i, rr);
 		rr = next_node(rr, node_online_map);
 		if (rr == MAX_NUMNODES)
@@ -644,14 +642,6 @@ static int __init numa_init(int (*init_func)(void))
 	if (ret < 0)
 		return ret;
 
-	for (i = 0; i < nr_cpu_ids; i++) {
-		int nid = early_cpu_to_node(i);
-
-		if (nid == NUMA_NO_NODE)
-			continue;
-		if (!node_online(nid))
-			numa_clear_node(i);
-	}
 	numa_init_array();
 
 	return 0;
-- 
1.7.10.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
