Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx102.postini.com [74.125.245.102])
	by kanga.kvack.org (Postfix) with SMTP id 1666B6B0069
	for <linux-mm@kvack.org>; Wed, 12 Dec 2012 04:29:39 -0500 (EST)
Received: by mail-ia0-f169.google.com with SMTP id r4so719555iaj.14
        for <linux-mm@kvack.org>; Wed, 12 Dec 2012 01:29:38 -0800 (PST)
Message-ID: <1355304570.1542.0.camel@kernel.cn.ibm.com>
Subject: Re: [PATCH v3 3/5] page_alloc: Introduce zone_movable_limit[] to
 keep movable limit for nodes
From: Simon Jeons <simon.jeons@gmail.com>
Date: Wed, 12 Dec 2012 03:29:30 -0600
In-Reply-To: <50C849DD.20405@cn.fujitsu.com>
References: <1355193207-21797-1-git-send-email-tangchen@cn.fujitsu.com>
	  <1355193207-21797-4-git-send-email-tangchen@cn.fujitsu.com>
	  <50C6A36C.5030606@huawei.com> <50C6A93A.50404@cn.fujitsu.com>
	 <1355225313.1919.1.camel@kernel.cn.ibm.com> <50C7D490.60409@huawei.com>
	 <50C849DD.20405@cn.fujitsu.com>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tang Chen <tangchen@cn.fujitsu.com>
Cc: Jiang Liu <jiang.liu@huawei.com>, Jianguo Wu <wujianguo@huawei.com>, hpa@zytor.com, akpm@linux-foundation.org, wency@cn.fujitsu.com, laijs@cn.fujitsu.com, linfeng@cn.fujitsu.com, yinghai@kernel.org, isimatu.yasuaki@jp.fujitsu.com, rob@landley.net, kosaki.motohiro@jp.fujitsu.com, minchan.kim@gmail.com, mgorman@suse.de, rientjes@google.com, rusty@rustcorp.com.au, lliubbo@gmail.com, jaegeuk.hanse@gmail.com, tony.luck@intel.com, glommer@parallels.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-doc@vger.kernel.org

On Wed, 2012-12-12 at 17:09 +0800, Tang Chen wrote:
> On 12/12/2012 08:49 AM, Jiang Liu wrote:
> >>>>> This patch introduces a new array zone_movable_limit[] to store the
> >>>>> ZONE_MOVABLE limit from movablecore_map boot option for all nodes.
> >>>>> The function sanitize_zone_movable_limit() will find out to which
> >>>>> node the ranges in movable_map.map[] belongs, and calculates the
> >>>>> low boundary of ZONE_MOVABLE for each node.
> >>
> >> What's the difference between zone_movable_limit[nid] and
> >> zone_movable_pfn[nid]?
> > zone_movable_limit[] is a temporary storage for zone_moveable_pfn[].
> > It's used to handle a special case if user specifies both movablecore_map
> > and movablecore/kernelcore on the kernel command line.
> >
> Hi Simon, Liu,
> 
> Sorry for the late and thanks for your discussion. :)
> 
> As Liu said, zone_movable_limit[] is a temporary array for calculation.
> 
> If users specified movablecore_map option, zone_movable_limit[] holds
> the lowest pfn of ZONE_MOVABLE limited by movablecore_map option. It is 
> constant, won't change.
> 
> Please refer to find_zone_movable_pfns_for_nodes() in patch4, you will
> see that zone_moveable_pfn[] will be changed each time kernel area
> increases.
> 
> So when kernel area increases on node i, zone_moveable_pfn[i] will
> increase. And if zone_moveable_pfn[i] > zone_movable_limit[i], we should
> stop allocate memory for kernel on node i. Here, I give movablecore_map 
> higher priority than kernelcore/movablecore.
> 
> And also, I tried to use zone_moveable_pfn[] to store limits. But when
> calculating the kernel area, I still have to store the limits in
> temporary variables. I think the code was ugly. So I added an new array.
> 
> Thanks. :)

Thanks for your clarify. 

Enable PAE on x86 32bit kernel, 8G memory, movablecore=6.5G
> 
> [    0.000000] 8304MB HIGHMEM available.
> [    0.000000] 885MB LOWMEM available.
> [    0.000000]   mapped low ram: 0 - 375fe000
> [    0.000000]   low ram: 0 - 375fe000
> [    0.000000] Zone ranges:
> [    0.000000]   DMA      [mem 0x00010000-0x00ffffff]
> [    0.000000]   Normal   [mem 0x01000000-0x375fdfff]
> [    0.000000]   HighMem  [mem 0x375fe000-0x3e5fffff]
> [    0.000000] Movable zone start for each node
> [    0.000000] Early memory node ranges
> [    0.000000]   node   0: [mem 0x00010000-0x0009cfff]
> [    0.000000]   node   0: [mem 0x00100000-0x1fffffff]
> [    0.000000]   node   0: [mem 0x20200000-0x3fffffff]
> [    0.000000]   node   0: [mem 0x40200000-0xb69cbfff]
> [    0.000000]   node   0: [mem 0xb6a46000-0xb6a47fff]
> [    0.000000]   node   0: [mem 0xb6b1c000-0xb6cfffff]
> [    0.000000]   node   0: [mem 0x00000000-0x3e5fffff]
> [    0.000000] On node 0 totalpages: 2051391
> [    0.000000] free_area_init_node: node 0, pgdat c0c26a80,
> node_mem_map
> f19de200
> [    0.000000]   DMA zone: 32 pages used for memmap
> [    0.000000]   DMA zone: 0 pages reserved
> [    0.000000]   DMA zone: 3949 pages, LIFO batch:0
> [    0.000000]   Normal zone: 1740 pages used for memmap
> [    0.000000]   Normal zone: 220466 pages, LIFO batch:31
> [    0.000000]   HighMem zone: 16609 pages used for memmap
> [    0.000000]   HighMem zone: 1808595 pages, LIFO batch:31

Why zone movable disappear?



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
