Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f174.google.com (mail-pd0-f174.google.com [209.85.192.174])
	by kanga.kvack.org (Postfix) with ESMTP id 30C296B0080
	for <linux-mm@kvack.org>; Tue,  3 Dec 2013 18:44:31 -0500 (EST)
Received: by mail-pd0-f174.google.com with SMTP id y13so20960298pdi.5
        for <linux-mm@kvack.org>; Tue, 03 Dec 2013 15:44:30 -0800 (PST)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTP id wh6si25001273pac.161.2013.12.03.15.44.29
        for <linux-mm@kvack.org>;
        Tue, 03 Dec 2013 15:44:29 -0800 (PST)
Date: Tue, 3 Dec 2013 15:44:26 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH RESEND part2 v2 6/8] acpi, numa, mem_hotplug: Mark all
 nodes the kernel resides un-hotpluggable
Message-Id: <20131203154426.2b86261ac306d2de4a88024e@linux-foundation.org>
In-Reply-To: <529D41BD.5090604@cn.fujitsu.com>
References: <529D3FC0.6000403@cn.fujitsu.com>
	<529D41BD.5090604@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Zhang Yanfei <zhangyanfei@cn.fujitsu.com>
Cc: Tejun Heo <tj@kernel.org>, "Rafael J . Wysocki" <rjw@sisk.pl>, Len Brown <lenb@kernel.org>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@elte.hu>, "H. Peter Anvin" <hpa@zytor.com>, Toshi Kani <toshi.kani@hp.com>, Wanpeng Li <liwanp@linux.vnet.ibm.com>, Thomas Renninger <trenn@suse.de>, Yinghai Lu <yinghai@kernel.org>, Jiang Liu <jiang.liu@huawei.com>, Wen Congyang <wency@cn.fujitsu.com>, Lai Jiangshan <laijs@cn.fujitsu.com>, Yasuaki Ishimatsu <isimatu.yasuaki@jp.fujitsu.com>, Taku Izumi <izumi.taku@jp.fujitsu.com>, Mel Gorman <mgorman@suse.de>, Minchan Kim <minchan@kernel.org>, "mina86@mina86.com" <mina86@mina86.com>, "gong.chen@linux.intel.com" <gong.chen@linux.intel.com>, Vasilis Liaskovitis <vasilis.liaskovitis@profitbricks.com>, "lwoodman@redhat.com" <lwoodman@redhat.com>, Rik van Riel <riel@redhat.com>, "jweiner@redhat.com" <jweiner@redhat.com>, Prarit Bhargava <prarit@redhat.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Linux MM <linux-mm@kvack.org>, Chen Tang <imtangchen@gmail.com>, Tang Chen <tangchen@cn.fujitsu.com>, Zhang Yanfei <zhangyanfei.yes@gmail.com>

On Tue, 03 Dec 2013 10:28:13 +0800 Zhang Yanfei <zhangyanfei@cn.fujitsu.com> wrote:

> From: Tang Chen <tangchen@cn.fujitsu.com>
> 
> At very early time, the kernel have to use some memory such as
> loading the kernel image. We cannot prevent this anyway. So any
> node the kernel resides in should be un-hotpluggable.
> 
> @@ -555,6 +563,30 @@ static void __init numa_init_array(void)
>  	}
>  }
>  
> +static void __init numa_clear_kernel_node_hotplug(void)
> +{
> +	int i, nid;
> +	nodemask_t numa_kernel_nodes;
> +	unsigned long start, end;
> +	struct memblock_type *type = &memblock.reserved;
> +
> +	/* Mark all kernel nodes. */
> +	for (i = 0; i < type->cnt; i++)
> +		node_set(type->regions[i].nid, numa_kernel_nodes);
> +
> +	/* Clear MEMBLOCK_HOTPLUG flag for memory in kernel nodes. */
> +	for (i = 0; i < numa_meminfo.nr_blks; i++) {
> +		nid = numa_meminfo.blk[i].nid;
> +		if (!node_isset(nid, numa_kernel_nodes))
> +			continue;
> +
> +		start = numa_meminfo.blk[i].start;
> +		end = numa_meminfo.blk[i].end;
> +
> +		memblock_clear_hotplug(start, end - start);
> +	}
> +}

Shouldn't numa_kernel_nodes be initialized?


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
