Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f199.google.com (mail-wr0-f199.google.com [209.85.128.199])
	by kanga.kvack.org (Postfix) with ESMTP id E4EB46B02FD
	for <linux-mm@kvack.org>; Thu, 15 Jun 2017 04:16:16 -0400 (EDT)
Received: by mail-wr0-f199.google.com with SMTP id y19so1796683wrc.8
        for <linux-mm@kvack.org>; Thu, 15 Jun 2017 01:16:16 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id u50si2582400wrc.328.2017.06.15.01.16.15
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 15 Jun 2017 01:16:15 -0700 (PDT)
Date: Thu, 15 Jun 2017 10:16:11 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH] mm, memory_hotplug: support movable_node for hotplugable
 nodes
Message-ID: <20170615081611.GD1486@dhcp22.suse.cz>
References: <20170608122318.31598-1-mhocko@kernel.org>
 <20170612042832.GA7429@WeideMBP.lan>
 <20170612064502.GD4145@dhcp22.suse.cz>
 <20170615031354.GC16833@WeideMacBook-Pro.local>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170615031354.GC16833@WeideMacBook-Pro.local>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Wei Yang <richard.weiyang@gmail.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, Mel Gorman <mgorman@suse.de>, Vlastimil Babka <vbabka@suse.cz>, Andrea Arcangeli <aarcange@redhat.com>, Reza Arbab <arbab@linux.vnet.ibm.com>, Yasuaki Ishimatsu <yasu.isimatu@gmail.com>, qiuxishi@huawei.com, Kani Toshimitsu <toshi.kani@hpe.com>, slaoub@gmail.com, Joonsoo Kim <js1304@gmail.com>, Andi Kleen <ak@linux.intel.com>, David Rientjes <rientjes@google.com>, Daniel Kiper <daniel.kiper@oracle.com>, Igor Mammedov <imammedo@redhat.com>, Vitaly Kuznetsov <vkuznets@redhat.com>, LKML <linux-kernel@vger.kernel.org>

On Thu 15-06-17 11:13:54, Wei Yang wrote:
> On Mon, Jun 12, 2017 at 08:45:02AM +0200, Michal Hocko wrote:
> >On Mon 12-06-17 12:28:32, Wei Yang wrote:
> >> On Thu, Jun 08, 2017 at 02:23:18PM +0200, Michal Hocko wrote:
> >> >From: Michal Hocko <mhocko@suse.com>
> >> >
> >> >movable_node kernel parameter allows to make hotplugable NUMA
> >> >nodes to put all the hotplugable memory into movable zone which
> >> >allows more or less reliable memory hotremove.  At least this
> >> >is the case for the NUMA nodes present during the boot (see
> >> >find_zone_movable_pfns_for_nodes).
> >> >
> >> 
> >> When movable_node is enabled, we would have overlapped zones, right?
> >
> >It won't based on this patch. See movable_pfn_range
> >
> 
> Ok, I went through the code and here maybe a question not that close related
> to this patch.

Please start a new thread with unrelated questions

> I did some experiment with qemu+kvm and see this.
> 
> Guest config: 8G RAM, 2 nodes with 4G on each
> Guest kernel: 4.11
> Guest kernel command: kernelcore=1G
> 
> The log message in kernel is:
> 
> [    0.000000] Zone ranges:
> [    0.000000]   DMA      [mem 0x0000000000001000-0x0000000000ffffff]
> [    0.000000]   DMA32    [mem 0x0000000001000000-0x00000000ffffffff]
> [    0.000000]   Normal   [mem 0x0000000100000000-0x000000023fffffff]
> [    0.000000] Movable zone start for each node
> [    0.000000]   Node 0: 0x0000000100000000
> [    0.000000]   Node 1: 0x0000000140000000
> 
> We see on node 2, ZONE_NORMAL overlap with ZONE_MOVABLE. 
> [0x0000000140000000 - 0x000000023fffffff] belongs to both ZONE.

Not really. The above output is just confusing a bit. Zone ranges print
arch_zone_{lowest,highest}_possible_pfn range while the Movable zone
is excluded from that in adjust_zone_range_for_zone_movable
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
