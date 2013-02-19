Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx132.postini.com [74.125.245.132])
	by kanga.kvack.org (Postfix) with SMTP id B27636B0005
	for <linux-mm@kvack.org>; Tue, 19 Feb 2013 08:02:24 -0500 (EST)
From: Tang Chen <tangchen@cn.fujitsu.com>
Subject: [Bug fix PATCH 1/2] acpi, movablemem_map: Do not zero numa_meminfo in numa_init().
Date: Tue, 19 Feb 2013 21:01:43 +0800
Message-Id: <1361278904-8690-2-git-send-email-tangchen@cn.fujitsu.com>
In-Reply-To: <1361278904-8690-1-git-send-email-tangchen@cn.fujitsu.com>
References: <1361278904-8690-1-git-send-email-tangchen@cn.fujitsu.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org, jiang.liu@huawei.com, wujianguo@huawei.com, hpa@zytor.com, wency@cn.fujitsu.com, laijs@cn.fujitsu.com, linfeng@cn.fujitsu.com, yinghai@kernel.org, isimatu.yasuaki@jp.fujitsu.com, rob@landley.net, kosaki.motohiro@jp.fujitsu.com, minchan.kim@gmail.com, mgorman@suse.de, rientjes@google.com, guz.fnst@cn.fujitsu.com, rusty@rustcorp.com.au, lliubbo@gmail.com, jaegeuk.hanse@gmail.com, tony.luck@intel.com, glommer@parallels.com
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org

early_parse_srat() is called before numa_init(), and has initialized
numa_meminfo. So do not zero numa_meminfo in numa_init(), otherwise
we will lose memory numa info.

Signed-off-by: Tang Chen <tangchen@cn.fujitsu.com>
---
 arch/x86/mm/numa.c |    6 ++++--
 1 files changed, 4 insertions(+), 2 deletions(-)

diff --git a/arch/x86/mm/numa.c b/arch/x86/mm/numa.c
index 3545585..ff3633c 100644
--- a/arch/x86/mm/numa.c
+++ b/arch/x86/mm/numa.c
@@ -559,10 +559,12 @@ static int __init numa_init(int (*init_func)(void))
 	for (i = 0; i < MAX_LOCAL_APIC; i++)
 		set_apicid_to_node(i, NUMA_NO_NODE);
 
-	/* Do not clear numa_nodes_parsed because SRAT was parsed earlier. */
+	/*
+	 * Do not clear numa_nodes_parsed or zero numa_meminfo here, because
+	 * SRAT was parsed earlier in early_parse_srat().
+	 */
 	nodes_clear(node_possible_map);
 	nodes_clear(node_online_map);
-	memset(&numa_meminfo, 0, sizeof(numa_meminfo));
 	WARN_ON(memblock_set_node(0, ULLONG_MAX, MAX_NUMNODES));
 	numa_reset_distance();
 
-- 
1.7.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
