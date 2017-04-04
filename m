Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f200.google.com (mail-wr0-f200.google.com [209.85.128.200])
	by kanga.kvack.org (Postfix) with ESMTP id B55C46B0038
	for <linux-mm@kvack.org>; Tue,  4 Apr 2017 15:41:29 -0400 (EDT)
Received: by mail-wr0-f200.google.com with SMTP id x61so2910891wrb.8
        for <linux-mm@kvack.org>; Tue, 04 Apr 2017 12:41:29 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id a2si25806813wra.327.2017.04.04.12.41.27
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 04 Apr 2017 12:41:28 -0700 (PDT)
Date: Tue, 4 Apr 2017 21:41:22 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH 0/6] mm: make movable onlining suck less
Message-ID: <20170404194122.GS15132@dhcp22.suse.cz>
References: <20170403115545.GK24661@dhcp22.suse.cz>
 <20170403195830.64libncet5l6vuvb@arbab-laptop>
 <20170403202337.GA12482@dhcp22.suse.cz>
 <20170403204213.rs7k2cvsnconel2z@arbab-laptop>
 <20170404072329.GA15132@dhcp22.suse.cz>
 <20170404073412.GC15132@dhcp22.suse.cz>
 <20170404082302.GE15132@dhcp22.suse.cz>
 <20170404160239.ftvuxklioo6zvuxl@arbab-laptop>
 <20170404164452.GQ15132@dhcp22.suse.cz>
 <20170404183012.a6biape5y7vu6cjm@arbab-laptop>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170404183012.a6biape5y7vu6cjm@arbab-laptop>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Reza Arbab <arbab@linux.vnet.ibm.com>
Cc: Mel Gorman <mgorman@suse.de>, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Vlastimil Babka <vbabka@suse.cz>, Andrea Arcangeli <aarcange@redhat.com>, Yasuaki Ishimatsu <yasu.isimatu@gmail.com>, Tang Chen <tangchen@cn.fujitsu.com>, qiuxishi@huawei.com, Kani Toshimitsu <toshi.kani@hpe.com>, slaoub@gmail.com, Joonsoo Kim <js1304@gmail.com>, Andi Kleen <ak@linux.intel.com>, Zhang Zhen <zhenzhang.zhang@huawei.com>, David Rientjes <rientjes@google.com>, Daniel Kiper <daniel.kiper@oracle.com>, Igor Mammedov <imammedo@redhat.com>, Vitaly Kuznetsov <vkuznets@redhat.com>, LKML <linux-kernel@vger.kernel.org>, Chris Metcalf <cmetcalf@mellanox.com>, Dan Williams <dan.j.williams@gmail.com>, Heiko Carstens <heiko.carstens@de.ibm.com>, Lai Jiangshan <laijs@cn.fujitsu.com>, Martin Schwidefsky <schwidefsky@de.ibm.com>

On Tue 04-04-17 13:30:13, Reza Arbab wrote:
> On Tue, Apr 04, 2017 at 06:44:53PM +0200, Michal Hocko wrote:
> >Thanks for your testing! This is highly appreciated.
> >Can I assume your Tested-by?
> 
> Of course! Not quite done, though. 

Ohh, I didn't mean to rush you to that!

> I think I found another edge case.  You
> get an oops when removing all of a node's memory:
> 
> __nr_to_section
> __pfn_to_section
> find_biggest_section_pfn
> shrink_pgdat_span
> __remove_zone
> __remove_section
> __remove_pages
> arch_remove_memory
> remove_memory

Is this something new or an old issue? I believe the state after the
online should be the same as before. So if you onlined the full node
then there shouldn't be any difference. Let me have a look...

> I stuck some debugging prints in, for context:
> 
> shrink_pgdat_span: start_pfn=0x10000, end_pfn=0x10100, pgdat_start_pfn=0x0, pgdat_end_pfn=0x20000
> shrink_pgdat_span: start_pfn=0x10100, end_pfn=0x10200, pgdat_start_pfn=0x0, pgdat_end_pfn=0x20000
> ...%<...
> shrink_pgdat_span: start_pfn=0x1fe00, end_pfn=0x1ff00, pgdat_start_pfn=0x0, pgdat_end_pfn=0x20000
> shrink_pgdat_span: start_pfn=0x1ff00, end_pfn=0x20000, pgdat_start_pfn=0x0, pgdat_end_pfn=0x20000
> find_biggest_section_pfn: start_pfn=0x0, end_pfn=0x1ff00
> find_biggest_section_pfn loop: pfn=0x1feff, sec_nr = 0x1fe
> find_biggest_section_pfn loop: pfn=0x1fdff, sec_nr = 0x1fd
> ...%<...
> find_biggest_section_pfn loop: pfn=0x1ff, sec_nr = 0x1
> find_biggest_section_pfn loop: pfn=0xff, sec_nr = 0x0
> find_biggest_section_pfn loop: pfn=0xffffffffffffffff, sec_nr = 0xffffffffffffff
> Unable to handle kernel paging request for data at address 0xc000800000f19e78

...this looks like a straight underflow and it is clear that the code
is just broken. Have a look at the loop
	pfn = end_pfn - 1;
	for (; pfn >= start_pfn; pfn -= PAGES_PER_SECTION) {

assume that end_pfn is properly PAGES_PER_SECTION aligned (start_pfn
would be 0 obviously). This is unsigned arithmetic and so it cannot work
for the first section. So the code is broken and has been broken since
it has been introduced. Nobody has noticed because the low pfns are
usually reserved and out of the hotplug reach. We could tweak it but I
am not even sure we really want/need this behavior. It complicates the
code and am not really sure we need to support
	online_movable(range)
	offline_movable(range)
	online_kernel(range)

While the flexibility is attractive I do not think it is worth the
additional complexity without any proof of the usecase. Especially when
we consider that this only work when we offline from the start or end of
the zone or whole zone. I guess it would be the best to simply revert
this whole thing. It is quite a lot of code with a dubious use. What
do Futjitsu guys think about it?
---
