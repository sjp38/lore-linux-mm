Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f171.google.com (mail-pd0-f171.google.com [209.85.192.171])
	by kanga.kvack.org (Postfix) with ESMTP id 57DD66B0075
	for <linux-mm@kvack.org>; Mon,  2 Dec 2013 21:33:02 -0500 (EST)
Received: by mail-pd0-f171.google.com with SMTP id z10so19348701pdj.30
        for <linux-mm@kvack.org>; Mon, 02 Dec 2013 18:33:01 -0800 (PST)
Received: from song.cn.fujitsu.com ([222.73.24.84])
        by mx.google.com with ESMTP id tt8si10662700pbc.198.2013.12.02.18.32.59
        for <linux-mm@kvack.org>;
        Mon, 02 Dec 2013 18:33:00 -0800 (PST)
Message-ID: <529D423F.3030200@cn.fujitsu.com>
Date: Tue, 03 Dec 2013 10:30:23 +0800
From: Zhang Yanfei <zhangyanfei@cn.fujitsu.com>
MIME-Version: 1.0
Subject: [PATCH RESEND part2 v2 8/8] x86, numa, acpi, memory-hotplug: Make
 movable_node have higher priority
References: <529D3FC0.6000403@cn.fujitsu.com>
In-Reply-To: <529D3FC0.6000403@cn.fujitsu.com>
Content-Transfer-Encoding: 7bit
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Tejun Heo <tj@kernel.org>
Cc: "Rafael J . Wysocki" <rjw@sisk.pl>, Len Brown <lenb@kernel.org>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@elte.hu>, "H. Peter Anvin" <hpa@zytor.com>, Toshi Kani <toshi.kani@hp.com>, Wanpeng Li <liwanp@linux.vnet.ibm.com>, Thomas Renninger <trenn@suse.de>, Yinghai Lu <yinghai@kernel.org>, Jiang Liu <jiang.liu@huawei.com>, Wen Congyang <wency@cn.fujitsu.com>, Lai Jiangshan <laijs@cn.fujitsu.com>, Yasuaki Ishimatsu <isimatu.yasuaki@jp.fujitsu.com>, Taku Izumi <izumi.taku@jp.fujitsu.com>, Mel Gorman <mgorman@suse.de>, Minchan Kim <minchan@kernel.org>, "mina86@mina86.com" <mina86@mina86.com>, "gong.chen@linux.intel.com" <gong.chen@linux.intel.com>, Vasilis Liaskovitis <vasilis.liaskovitis@profitbricks.com>, "lwoodman@redhat.com" <lwoodman@redhat.com>, Rik van Riel <riel@redhat.com>, "jweiner@redhat.com" <jweiner@redhat.com>, Prarit Bhargava <prarit@redhat.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Linux MM <linux-mm@kvack.org>, Chen Tang <imtangchen@gmail.com>, Tang Chen <tangchen@cn.fujitsu.com>, Zhang Yanfei <zhangyanfei.yes@gmail.com>

From: Tang Chen <tangchen@cn.fujitsu.com>

If users specify the original movablecore=nn@ss boot option, the kernel will
arrange [ss, ss+nn) as ZONE_MOVABLE. The kernelcore=nn@ss boot option is similar
except it specifies ZONE_NORMAL ranges.

Now, if users specify "movable_node" in kernel commandline, the kernel will
arrange hotpluggable memory in SRAT as ZONE_MOVABLE. And if users do this, all
the other movablecore=nn@ss and kernelcore=nn@ss options should be ignored.

For those who don't want this, just specify nothing. The kernel will act as
before.

Signed-off-by: Tang Chen <tangchen@cn.fujitsu.com>
Signed-off-by: Zhang Yanfei <zhangyanfei@cn.fujitsu.com>
Reviewed-by: Wanpeng Li <liwanp@linux.vnet.ibm.com>
---
 mm/page_alloc.c |   28 ++++++++++++++++++++++++++--
 1 files changed, 26 insertions(+), 2 deletions(-)

diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index dd886fa..768ea0e 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -5021,9 +5021,33 @@ static void __init find_zone_movable_pfns_for_nodes(void)
 	nodemask_t saved_node_state = node_states[N_MEMORY];
 	unsigned long totalpages = early_calculate_totalpages();
 	int usable_nodes = nodes_weight(node_states[N_MEMORY]);
+	struct memblock_type *type = &memblock.memory;
+
+	/* Need to find movable_zone earlier when movable_node is specified. */
+	find_usable_zone_for_movable();
+
+	/*
+	 * If movable_node is specified, ignore kernelcore and movablecore
+	 * options.
+	 */
+	if (movable_node_is_enabled()) {
+		for (i = 0; i < type->cnt; i++) {
+			if (!memblock_is_hotpluggable(&type->regions[i]))
+				continue;
+
+			nid = type->regions[i].nid;
+
+			usable_startpfn = PFN_DOWN(type->regions[i].base);
+			zone_movable_pfn[nid] = zone_movable_pfn[nid] ?
+				min(usable_startpfn, zone_movable_pfn[nid]) :
+				usable_startpfn;
+		}
+
+		goto out2;
+	}
 
 	/*
-	 * If movablecore was specified, calculate what size of
+	 * If movablecore=nn[KMG] was specified, calculate what size of
 	 * kernelcore that corresponds so that memory usable for
 	 * any allocation type is evenly spread. If both kernelcore
 	 * and movablecore are specified, then the value of kernelcore
@@ -5049,7 +5073,6 @@ static void __init find_zone_movable_pfns_for_nodes(void)
 		goto out;
 
 	/* usable_startpfn is the lowest possible pfn ZONE_MOVABLE can be at */
-	find_usable_zone_for_movable();
 	usable_startpfn = arch_zone_lowest_possible_pfn[movable_zone];
 
 restart:
@@ -5140,6 +5163,7 @@ restart:
 	if (usable_nodes && required_kernelcore > usable_nodes)
 		goto restart;
 
+out2:
 	/* Align start of ZONE_MOVABLE on all nids to MAX_ORDER_NR_PAGES */
 	for (nid = 0; nid < MAX_NUMNODES; nid++)
 		zone_movable_pfn[nid] =
-- 
1.7.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
