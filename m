Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yk0-f178.google.com (mail-yk0-f178.google.com [209.85.160.178])
	by kanga.kvack.org (Postfix) with ESMTP id A9A726B0032
	for <linux-mm@kvack.org>; Sun, 19 Apr 2015 23:29:53 -0400 (EDT)
Received: by ykft189 with SMTP id t189so16448780ykf.1
        for <linux-mm@kvack.org>; Sun, 19 Apr 2015 20:29:53 -0700 (PDT)
Received: from mail-yh0-x22d.google.com (mail-yh0-x22d.google.com. [2607:f8b0:4002:c01::22d])
        by mx.google.com with ESMTPS id l62si6525368yha.139.2015.04.19.20.29.52
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 19 Apr 2015 20:29:52 -0700 (PDT)
Received: by yhda23 with SMTP id a23so15855373yhd.2
        for <linux-mm@kvack.org>; Sun, 19 Apr 2015 20:29:52 -0700 (PDT)
Message-ID: <553472b0.4ad2ec0a.3abe.ffffd0f6@mx.google.com>
Date: Sun, 19 Apr 2015 20:29:52 -0700 (PDT)
From: Yasuaki Ishimatsu <yasu.isimatu@gmail.com>
Subject: Re: [PATCH 1/2 V2] memory-hotplug: fix BUG_ON in move_freepages()
In-Reply-To: <55346859.30605@huawei.com>
References: <5530E578.9070505@huawei.com>
	<5531679d.4642ec0a.1beb.3569@mx.google.com>
	<55345979.2020502@cn.fujitsu.com>
	<55346859.30605@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Xishi Qiu <qiuxishi@huawei.com>
Cc: Gu Zheng <guz.fnst@cn.fujitsu.com>, Andrew Morton <akpm@linux-foundation.org>, Yasuaki Ishimatsu <isimatu.yasuaki@jp.fujitsu.com>, Kamezawa Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, izumi.taku@jp.fujitsu.com, Tang Chen <tangchen@cn.fujitsu.com>, Xiexiuqi <xiexiuqi@huawei.com>, Mel Gorman <mgorman@suse.de>, David Rientjes <rientjes@google.com>, Linux MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>


On Mon, 20 Apr 2015 10:45:45 +0800
Xishi Qiu <qiuxishi@huawei.com> wrote:

> On 2015/4/20 9:42, Gu Zheng wrote:
> 
> > Hi Xishi,
> > On 04/18/2015 04:05 AM, Yasuaki Ishimatsu wrote:
> > 
> >>
> >> Your patches will fix your issue.
> >> But, if BIOS reports memory first at node hot add, pgdat can
> >> not be initialized.
> >>
> >> Memory hot add flows are as follows:
> >>
> >> add_memory
> >>   ...
> >>   -> hotadd_new_pgdat()
> >>   ...
> >>   -> node_set_online(nid)
> >>
> >> When calling hotadd_new_pgdat() for a hot added node, the node is
> >> offline because node_set_online() is not called yet. So if applying
> >> your patches, the pgdat is not initialized in this case.
> > 
> > Ishimtasu's worry is reasonable. And I am afraid the fix here is a bit
> > over-kill. 
> > 
> >>
> >> Thanks,
> >> Yasuaki Ishimatsu
> >>
> >> On Fri, 17 Apr 2015 18:50:32 +0800
> >> Xishi Qiu <qiuxishi@huawei.com> wrote:
> >>
> >>> Hot remove nodeXX, then hot add nodeXX. If BIOS report cpu first, it will call
> >>> hotadd_new_pgdat(nid, 0), this will set pgdat->node_start_pfn to 0. As nodeXX
> >>> exists at boot time, so pgdat->node_spanned_pages is the same as original. Then
> >>> free_area_init_core()->memmap_init() will pass a wrong start and a nonzero size.
> > 
> > As your analysis said the root cause here is passing a *0* as the node_start_pfn,
> > then the chaos occurred when init the zones. And this only happens to the re-hotadd
> > node, so how about using the saved *node_start_pfn* (via get_pfn_range_for_nid(nid, &start_pfn, &end_pfn))
> > instead if we find "pgdat->node_start_pfn == 0 && !node_online(XXX)"?
> > 
> > Thanks,
> > Gu
> > 
> 
> Hi Gu,
> 
> I first considered this method, but if the hot added node's start and size are different
> from before, it makes the chaos.
> 

> e.g.
> nodeXX (8-16G)
> remove nodeXX 
> BIOS report cpu first and online it
> hotadd nodeXX
> use the original value, so pgdat->node_start_pfn is set to 8G, and size is 8G
> BIOS report mem(10-12G)
> call add_memory()->__add_zone()->grow_zone_span()/grow_pgdat_span()
> the start is still 8G, not 10G, this is chaos!

If you set CONFIG_HAVE_MEMBLOCK_NODE_MAP, kernel shows the following
pr_info()'s message.

void __paginginit free_area_init_node(int nid, unsigned long *zones_size,
                unsigned long node_start_pfn, unsigned long *zholes_size)
{
...
#ifdef CONFIG_HAVE_MEMBLOCK_NODE_MAP
        get_pfn_range_for_nid(nid, &start_pfn, &end_pfn);
        pr_info("Initmem setup node %d [mem %#018Lx-%#018Lx]\n", nid,
                (u64)start_pfn << PAGE_SHIFT, ((u64)end_pfn << PAGE_SHIFT) - 1);
#endif
}

Is the memory range of the message "8G - 16G"?
If so, the reason is that memblk is not deleted at memory hot remove.

Thanks,
Yasuaki Ishimatsu



> 
> Thanks,
> Xishi Qiu
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
