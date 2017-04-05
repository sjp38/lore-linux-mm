Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f200.google.com (mail-wr0-f200.google.com [209.85.128.200])
	by kanga.kvack.org (Postfix) with ESMTP id 43F2B6B039F
	for <linux-mm@kvack.org>; Wed,  5 Apr 2017 09:52:57 -0400 (EDT)
Received: by mail-wr0-f200.google.com with SMTP id p64so1777090wrb.18
        for <linux-mm@kvack.org>; Wed, 05 Apr 2017 06:52:57 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id p9si29258784wrd.131.2017.04.05.06.52.55
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 05 Apr 2017 06:52:56 -0700 (PDT)
Date: Wed, 5 Apr 2017 15:52:49 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH 0/6] mm: make movable onlining suck less
Message-ID: <20170405135248.GQ6035@dhcp22.suse.cz>
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

OK, I know what is going on here.
shrink_pgdat_span: start_pfn=0x1ff00, end_pfn=0x20000, pgdat_start_pfn=0x0, pgdat_end_pfn=0x20000
[...]
find_biggest_section_pfn loop: pfn=0xff, sec_nr = 0x0

so the node starts at pfn 0 while we are trying to remove range starting
from pfn=255 (1MB). Rather than going with find_smallest_section_pfn we
go with the other branch and that underflows as already mentioned. I
seriously doubt that the node really starts at pfn 0. I am not sure
which arch you are testing on but I believe we reserve the lowest
address pfn range on all aches. The previous code presumably handled
that properly because the original node/zone has started at the lowest
possible address and the zone shifting then preserves that.

My code doesn't do that though. So I guess I have to sanitize. Does this
help? Please drop the "mm, memory_hotplug: get rid of zone/node
shrinking" patch.
---
diff --git a/mm/memory_hotplug.c b/mm/memory_hotplug.c
index acf2b5eb5ecb..2c5613d19eb6 100644
--- a/mm/memory_hotplug.c
+++ b/mm/memory_hotplug.c
@@ -750,6 +750,15 @@ int __ref online_pages(unsigned long pfn, unsigned long nr_pages, int online_typ
 	int ret;
 	struct memory_notify arg;
 
+	do {
+		if (pfn_valid(pfn))
+			break;
+		pfn++;
+	} while (--nr_pages > 0);
+
+	if (!nr_pages)
+		return -EINVAL;
+
 	nid = pfn_to_nid(pfn);
 	if (!allow_online_pfn_range(nid, pfn, nr_pages, online_type))
 		return -EINVAL;
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
