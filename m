Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f69.google.com (mail-ed1-f69.google.com [209.85.208.69])
	by kanga.kvack.org (Postfix) with ESMTP id 392498E0001
	for <linux-mm@kvack.org>; Tue, 18 Dec 2018 07:14:54 -0500 (EST)
Received: by mail-ed1-f69.google.com with SMTP id c18so12144901edt.23
        for <linux-mm@kvack.org>; Tue, 18 Dec 2018 04:14:54 -0800 (PST)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id v27si2610427edm.111.2018.12.18.04.14.52
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 18 Dec 2018 04:14:52 -0800 (PST)
Date: Tue, 18 Dec 2018 13:14:51 +0100
From: Michal Hocko <mhocko@suse.com>
Subject: Re: [PATCH] mm, page_alloc: clear zone_movable_pfn if the node
 doesn't have ZONE_MOVABLE
Message-ID: <20181218121451.GK30879@dhcp22.suse.cz>
References: <20181216125624.3416-1-richard.weiyang@gmail.com>
 <20181217102534.GF30879@dhcp22.suse.cz>
 <20181217141802.4bl4icg3mvwtmhqe@master>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20181217141802.4bl4icg3mvwtmhqe@master>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Wei Yang <richard.weiyang@gmail.com>
Cc: linux-mm@kvack.org, akpm@linux-foundation.org, mgorman@techsingularity.net, osalvador@suse.de

On Mon 17-12-18 14:18:02, Wei Yang wrote:
> On Mon, Dec 17, 2018 at 11:25:34AM +0100, Michal Hocko wrote:
> >On Sun 16-12-18 20:56:24, Wei Yang wrote:
> >> A non-zero zone_movable_pfn indicates this node has ZONE_MOVABLE, while
> >> current implementation doesn't comply with this rule when kernel
> >> parameter "kernelcore=" is used.
> >> 
> >> Current implementation doesn't harm the system, since the value in
> >> zone_movable_pfn is out of the range of current zone. While user would
> >> see this message during bootup, even that node doesn't has ZONE_MOVABLE.
> >> 
> >>     Movable zone start for each node
> >>       Node 0: 0x0000000080000000
> >
> >I am sorry but the above description confuses me more than it helps.
> >Could you start over again and describe the user visible problem, then
> >follow up with the udnerlying bug and finally continue with a proposed
> >fix?
> 
> Yep, how about this one:
> 
> For example, a machine with 8G RAM, 2 nodes with 4G on each, if we pass

Did you mean 2G on each? Because your nodes do have 2GB each.

> "kernelcore=2G" as kernel parameter, the dmesg looks like:
> 
>      Movable zone start for each node
>        Node 0: 0x0000000080000000
>        Node 1: 0x0000000100000000
> 
> This looks like both Node 0 and 1 has ZONE_MOVABLE, while the following
> dmesg shows only Node 1 has ZONE_MOVABLE.

Well, the documentation says
	kernelcore=	[KNL,X86,IA-64,PPC]
			Format: nn[KMGTPE] | nn% | "mirror"
			This parameter specifies the amount of memory usable by
			the kernel for non-movable allocations.  The requested
			amount is spread evenly throughout all nodes in the
			system as ZONE_NORMAL.  The remaining memory is used for
			movable memory in its own zone, ZONE_MOVABLE.  In the
			event, a node is too small to have both ZONE_NORMAL and
			ZONE_MOVABLE, kernelcore memory will take priority and
			other nodes will have a larger ZONE_MOVABLE.

>      On node 0 totalpages: 524190
>        DMA zone: 64 pages used for memmap
>        DMA zone: 21 pages reserved
>        DMA zone: 3998 pages, LIFO batch:0
>        DMA32 zone: 8128 pages used for memmap
>        DMA32 zone: 520192 pages, LIFO batch:63
>      
>      On node 1 totalpages: 524255
>        DMA32 zone: 4096 pages used for memmap
>        DMA32 zone: 262111 pages, LIFO batch:63
>        Movable zone: 4096 pages used for memmap
>        Movable zone: 262144 pages, LIFO batch:63

so assuming your really have 4GB in total and 2GB should be in kernel
zones then each node should get half of it to kernel zones and the
remaining 2G evenly distributed to movable zones. So something seems
broken here.
-- 
Michal Hocko
SUSE Labs
