Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f199.google.com (mail-wr0-f199.google.com [209.85.128.199])
	by kanga.kvack.org (Postfix) with ESMTP id 57E1A6B03A1
	for <linux-mm@kvack.org>; Wed,  5 Apr 2017 02:42:45 -0400 (EDT)
Received: by mail-wr0-f199.google.com with SMTP id u77so388604wrb.6
        for <linux-mm@kvack.org>; Tue, 04 Apr 2017 23:42:45 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id l13si21972098wrl.51.2017.04.04.23.42.43
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 04 Apr 2017 23:42:44 -0700 (PDT)
Date: Wed, 5 Apr 2017 08:42:39 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH 0/6] mm: make movable onlining suck less
Message-ID: <20170405064239.GB6035@dhcp22.suse.cz>
References: <20170403202337.GA12482@dhcp22.suse.cz>
 <20170403204213.rs7k2cvsnconel2z@arbab-laptop>
 <20170404072329.GA15132@dhcp22.suse.cz>
 <20170404073412.GC15132@dhcp22.suse.cz>
 <20170404082302.GE15132@dhcp22.suse.cz>
 <20170404160239.ftvuxklioo6zvuxl@arbab-laptop>
 <20170404164452.GQ15132@dhcp22.suse.cz>
 <20170404183012.a6biape5y7vu6cjm@arbab-laptop>
 <20170404194122.GS15132@dhcp22.suse.cz>
 <20170404214339.6o4c4uhwudyhzbbo@arbab-laptop>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170404214339.6o4c4uhwudyhzbbo@arbab-laptop>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Reza Arbab <arbab@linux.vnet.ibm.com>
Cc: Mel Gorman <mgorman@suse.de>, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Vlastimil Babka <vbabka@suse.cz>, Andrea Arcangeli <aarcange@redhat.com>, Yasuaki Ishimatsu <yasu.isimatu@gmail.com>, Tang Chen <tangchen@cn.fujitsu.com>, qiuxishi@huawei.com, Kani Toshimitsu <toshi.kani@hpe.com>, slaoub@gmail.com, Joonsoo Kim <js1304@gmail.com>, Andi Kleen <ak@linux.intel.com>, Zhang Zhen <zhenzhang.zhang@huawei.com>, David Rientjes <rientjes@google.com>, Daniel Kiper <daniel.kiper@oracle.com>, Igor Mammedov <imammedo@redhat.com>, Vitaly Kuznetsov <vkuznets@redhat.com>, LKML <linux-kernel@vger.kernel.org>, Chris Metcalf <cmetcalf@mellanox.com>, Dan Williams <dan.j.williams@gmail.com>, Heiko Carstens <heiko.carstens@de.ibm.com>, Lai Jiangshan <laijs@cn.fujitsu.com>, Martin Schwidefsky <schwidefsky@de.ibm.com>

On Tue 04-04-17 16:43:39, Reza Arbab wrote:
> On Tue, Apr 04, 2017 at 09:41:22PM +0200, Michal Hocko wrote:
> >On Tue 04-04-17 13:30:13, Reza Arbab wrote:
> >>I think I found another edge case.  You
> >>get an oops when removing all of a node's memory:
> >>
> >>__nr_to_section
> >>__pfn_to_section
> >>find_biggest_section_pfn
> >>shrink_pgdat_span
> >>__remove_zone
> >>__remove_section
> >>__remove_pages
> >>arch_remove_memory
> >>remove_memory
> >
> >Is this something new or an old issue? I believe the state after the
> >online should be the same as before. So if you onlined the full node
> >then there shouldn't be any difference. Let me have a look...
> 
> It's new. Without this patchset, I can repeatedly
> add_memory()->online_movable->offline->remove_memory() all of a node's
> memory.

This is quite unexpected because the code obviously cannot handle the
first memory section. Could you paste /proc/zoneinfo and
grep . -r /sys/devices/system/memory/auto_online_blocks/memory*, after
onlining for both patched and unpatched kernels?

> >From 1b08ecef3e8ebcef585fe8f2b23155be54cce335 Mon Sep 17 00:00:00 2001
> >From: Michal Hocko <mhocko@suse.com>
> >Date: Tue, 4 Apr 2017 21:09:00 +0200
> >Subject: [PATCH] mm, hotplug: get rid of zone/node shrinking
> >
> ...%<...
> >---
> >mm/memory_hotplug.c | 207 ----------------------------------------------------
> >1 file changed, 207 deletions(-)
> 
> Okay, getting further. With this I can again repeatedly add and remove, but
> now I'm seeing a weird variation of that earlier issue:
> 
> 1. add_memory(), online_movable
>   /sys/devices/system/node/nodeX/memoryY symlinks are created.
> 
> 2. offline, remove_memory()
>   The node is offlined, since all memory has been removed, so all of
>   /sys/devices/system/node/nodeX is gone. This is normal.
> 
> 3. add_memory(), online_movable
>   The node is onlined, so /sys/devices/system/node/nodeX is recreated,
>   and the memory is added, but just like earlier in this email thread,
>   the memoryY links are not there.

Could you add some printks to see why the sysfs creation failed please?
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
