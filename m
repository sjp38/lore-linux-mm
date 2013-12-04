Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pb0-f50.google.com (mail-pb0-f50.google.com [209.85.160.50])
	by kanga.kvack.org (Postfix) with ESMTP id 39A456B0031
	for <linux-mm@kvack.org>; Tue,  3 Dec 2013 21:12:27 -0500 (EST)
Received: by mail-pb0-f50.google.com with SMTP id rr13so22225091pbb.23
        for <linux-mm@kvack.org>; Tue, 03 Dec 2013 18:12:26 -0800 (PST)
Received: from song.cn.fujitsu.com ([222.73.24.84])
        by mx.google.com with ESMTP id zi8si1099627pac.301.2013.12.03.18.12.23
        for <linux-mm@kvack.org>;
        Tue, 03 Dec 2013 18:12:25 -0800 (PST)
Message-ID: <529E8EE1.4040009@cn.fujitsu.com>
Date: Wed, 04 Dec 2013 10:09:37 +0800
From: Zhang Yanfei <zhangyanfei@cn.fujitsu.com>
MIME-Version: 1.0
Subject: [PATCH update part2 v2 6/8] acpi, numa, mem_hotplug: Mark all nodes
 the kernel resides un-hotpluggable
References: <529D3FC0.6000403@cn.fujitsu.com> <529D41BD.5090604@cn.fujitsu.com> <20131203154426.2b86261ac306d2de4a88024e@linux-foundation.org>
In-Reply-To: <20131203154426.2b86261ac306d2de4a88024e@linux-foundation.org>
Content-Transfer-Encoding: 7bit
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Tejun Heo <tj@kernel.org>, "Rafael J . Wysocki" <rjw@sisk.pl>, Len Brown <lenb@kernel.org>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@elte.hu>, "H. Peter Anvin" <hpa@zytor.com>, Toshi Kani <toshi.kani@hp.com>, Wanpeng Li <liwanp@linux.vnet.ibm.com>, Thomas Renninger <trenn@suse.de>, Yinghai Lu <yinghai@kernel.org>, Jiang Liu <jiang.liu@huawei.com>, Wen Congyang <wency@cn.fujitsu.com>, Lai Jiangshan <laijs@cn.fujitsu.com>, Yasuaki Ishimatsu <isimatu.yasuaki@jp.fujitsu.com>, Taku Izumi <izumi.taku@jp.fujitsu.com>, Mel Gorman <mgorman@suse.de>, Minchan Kim <minchan@kernel.org>, "mina86@mina86.com" <mina86@mina86.com>, "gong.chen@linux.intel.com" <gong.chen@linux.intel.com>, Vasilis Liaskovitis <vasilis.liaskovitis@profitbricks.com>, "lwoodman@redhat.com" <lwoodman@redhat.com>, Rik van Riel <riel@redhat.com>, "jweiner@redhat.com" <jweiner@redhat.com>, Prarit Bhargava <prarit@redhat.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Linux MM <linux-mm@kvack.org>, Chen Tang <imtangchen@gmail.com>, Tang Chen <tangchen@cn.fujitsu.com>, Zhang Yanfei <zhangyanfei.yes@gmail.com>

On 12/04/2013 07:44 AM, Andrew Morton wrote:
> On Tue, 03 Dec 2013 10:28:13 +0800 Zhang Yanfei <zhangyanfei@cn.fujitsu.com> wrote:
> 
>> From: Tang Chen <tangchen@cn.fujitsu.com>
>>
>> At very early time, the kernel have to use some memory such as
>> loading the kernel image. We cannot prevent this anyway. So any
>> node the kernel resides in should be un-hotpluggable.
>>
>> @@ -555,6 +563,30 @@ static void __init numa_init_array(void)
>>  	}
>>  }
>>  
>> +static void __init numa_clear_kernel_node_hotplug(void)
>> +{
>> +	int i, nid;
>> +	nodemask_t numa_kernel_nodes;
>> +	unsigned long start, end;
>> +	struct memblock_type *type = &memblock.reserved;
>> +
>> +	/* Mark all kernel nodes. */
>> +	for (i = 0; i < type->cnt; i++)
>> +		node_set(type->regions[i].nid, numa_kernel_nodes);
>> +
>> +	/* Clear MEMBLOCK_HOTPLUG flag for memory in kernel nodes. */
>> +	for (i = 0; i < numa_meminfo.nr_blks; i++) {
>> +		nid = numa_meminfo.blk[i].nid;
>> +		if (!node_isset(nid, numa_kernel_nodes))
>> +			continue;
>> +
>> +		start = numa_meminfo.blk[i].start;
>> +		end = numa_meminfo.blk[i].end;
>> +
>> +		memblock_clear_hotplug(start, end - start);
>> +	}
>> +}
> 
> Shouldn't numa_kernel_nodes be initialized?
> 

Ah, sorry for the mistake. Please use the updated patch below:

--------------------------------------------------
From: Tang Chen <tangchen@cn.fujitsu.com>
Date: Wed, 4 Dec 2013 09:37:26 +0800
Subject: [PATCH 6/8] acpi, numa, mem_hotplug: Mark all nodes the kernel resides un-hotpluggable

At very early time, the kernel have to use some memory such as
loading the kernel image. We cannot prevent this anyway. So any
node the kernel resides in should be un-hotpluggable.

Signed-off-by: Tang Chen <tangchen@cn.fujitsu.com>
Reviewed-by: Zhang Yanfei <zhangyanfei@cn.fujitsu.com>
---
 arch/x86/mm/numa.c |   45 +++++++++++++++++++++++++++++++++++++++++++++
 1 files changed, 45 insertions(+), 0 deletions(-)

diff --git a/arch/x86/mm/numa.c b/arch/x86/mm/numa.c
index 408c02d..43eb7d4 100644
--- a/arch/x86/mm/numa.c
+++ b/arch/x86/mm/numa.c
@@ -494,6 +494,14 @@ static int __init numa_register_memblks(struct numa_meminfo *mi)
 		struct numa_memblk *mb = &mi->blk[i];
 		memblock_set_node(mb->start, mb->end - mb->start,
 				  &memblock.memory, mb->nid);
+
+		/*
+		 * At this time, all memory regions reserved by memblock are
+		 * used by the kernel. Set the nid in memblock.reserved will
+		 * mark out all the nodes the kernel resides in.
+		 */
+		memblock_set_node(mb->start, mb->end - mb->start,
+				  &memblock.reserved, mb->nid);
 	}
 
 	/*
@@ -555,6 +563,31 @@ static void __init numa_init_array(void)
 	}
 }
 
+static void __init numa_clear_kernel_node_hotplug(void)
+{
+	int i, nid;
+	nodemask_t numa_kernel_nodes;
+	unsigned long start, end;
+	struct memblock_type *type = &memblock.reserved;
+
+	nodes_clear(numa_kernel_nodes);
+	/* Mark all kernel nodes. */
+	for (i = 0; i < type->cnt; i++)
+		node_set(type->regions[i].nid, numa_kernel_nodes);
+
+	/* Clear MEMBLOCK_HOTPLUG flag for memory in kernel nodes. */
+	for (i = 0; i < numa_meminfo.nr_blks; i++) {
+		nid = numa_meminfo.blk[i].nid;
+		if (!node_isset(nid, numa_kernel_nodes))
+			continue;
+
+		start = numa_meminfo.blk[i].start;
+		end = numa_meminfo.blk[i].end;
+
+		memblock_clear_hotplug(start, end - start);
+	}
+}
+
 static int __init numa_init(int (*init_func)(void))
 {
 	int i;
@@ -569,6 +602,8 @@ static int __init numa_init(int (*init_func)(void))
 	memset(&numa_meminfo, 0, sizeof(numa_meminfo));
 	WARN_ON(memblock_set_node(0, ULLONG_MAX, &memblock.memory,
 				  MAX_NUMNODES));
+	WARN_ON(memblock_set_node(0, ULLONG_MAX, &memblock.reserved,
+				  MAX_NUMNODES));
 	/* In case that parsing SRAT failed. */
 	WARN_ON(memblock_clear_hotplug(0, ULLONG_MAX));
 	numa_reset_distance();
@@ -606,6 +641,16 @@ static int __init numa_init(int (*init_func)(void))
 			numa_clear_node(i);
 	}
 	numa_init_array();
+
+	/*
+	 * At very early time, the kernel have to use some memory such as
+	 * loading the kernel image. We cannot prevent this anyway. So any
+	 * node the kernel resides in should be un-hotpluggable.
+	 *
+	 * And when we come here, numa_init() won't fail.
+	 */
+	numa_clear_kernel_node_hotplug();
+
 	return 0;
 }
 
-- 
1.7.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
