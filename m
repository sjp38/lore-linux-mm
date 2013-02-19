Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx195.postini.com [74.125.245.195])
	by kanga.kvack.org (Postfix) with SMTP id EDC826B0008
	for <linux-mm@kvack.org>; Tue, 19 Feb 2013 08:02:25 -0500 (EST)
From: Tang Chen <tangchen@cn.fujitsu.com>
Subject: [Bug fix PATCH 2/2] acpi, movablemem_map: Set numa_nodes_hotplug nodemask when using SRAT info.
Date: Tue, 19 Feb 2013 21:01:44 +0800
Message-Id: <1361278904-8690-3-git-send-email-tangchen@cn.fujitsu.com>
In-Reply-To: <1361278904-8690-1-git-send-email-tangchen@cn.fujitsu.com>
References: <1361278904-8690-1-git-send-email-tangchen@cn.fujitsu.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org, jiang.liu@huawei.com, wujianguo@huawei.com, hpa@zytor.com, wency@cn.fujitsu.com, laijs@cn.fujitsu.com, linfeng@cn.fujitsu.com, yinghai@kernel.org, isimatu.yasuaki@jp.fujitsu.com, rob@landley.net, kosaki.motohiro@jp.fujitsu.com, minchan.kim@gmail.com, mgorman@suse.de, rientjes@google.com, guz.fnst@cn.fujitsu.com, rusty@rustcorp.com.au, lliubbo@gmail.com, jaegeuk.hanse@gmail.com, tony.luck@intel.com, glommer@parallels.com
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org

We should also set movablemem_map.numa_nodes_hotplug nodemask when we
insert a hot-pluggable range in SRAT into movablemem_map.map[].

Signed-off-by: Tang Chen <tangchen@cn.fujitsu.com>
---
 arch/x86/mm/srat.c |    6 ++++++
 1 files changed, 6 insertions(+), 0 deletions(-)

diff --git a/arch/x86/mm/srat.c b/arch/x86/mm/srat.c
index b20b5b7..62ba97b 100644
--- a/arch/x86/mm/srat.c
+++ b/arch/x86/mm/srat.c
@@ -164,6 +164,12 @@ handle_movablemem(int node, u64 start, u64 end, u32 hotpluggable)
 	 */
 	if (hotpluggable && movablemem_map.acpi) {
 		insert_movablemem_map(start_pfn, end_pfn);
+
+		/*
+		 * numa_nodes_hotplug nodemask represents which nodes are put
+		 * into movablemem_map.map[].
+		 */
+		node_set(node, movablemem_map.numa_nodes_hotplug);
 		goto out;
 	}
 
-- 
1.7.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
