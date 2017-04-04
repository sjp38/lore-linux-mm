Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f200.google.com (mail-wr0-f200.google.com [209.85.128.200])
	by kanga.kvack.org (Postfix) with ESMTP id 7F9E36B039F
	for <linux-mm@kvack.org>; Tue,  4 Apr 2017 03:23:34 -0400 (EDT)
Received: by mail-wr0-f200.google.com with SMTP id k6so27290410wre.3
        for <linux-mm@kvack.org>; Tue, 04 Apr 2017 00:23:34 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id 33si23249364wrp.270.2017.04.04.00.23.32
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 04 Apr 2017 00:23:33 -0700 (PDT)
Date: Tue, 4 Apr 2017 09:23:29 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH 0/6] mm: make movable onlining suck less
Message-ID: <20170404072329.GA15132@dhcp22.suse.cz>
References: <20170330115454.32154-1-mhocko@kernel.org>
 <20170403115545.GK24661@dhcp22.suse.cz>
 <20170403195830.64libncet5l6vuvb@arbab-laptop>
 <20170403202337.GA12482@dhcp22.suse.cz>
 <20170403204213.rs7k2cvsnconel2z@arbab-laptop>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170403204213.rs7k2cvsnconel2z@arbab-laptop>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Reza Arbab <arbab@linux.vnet.ibm.com>, Gary Hade <garyhade@us.ibm.com>
Cc: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, Vlastimil Babka <vbabka@suse.cz>, Andrea Arcangeli <aarcange@redhat.com>, Yasuaki Ishimatsu <yasu.isimatu@gmail.com>, Tang Chen <tangchen@cn.fujitsu.com>, qiuxishi@huawei.com, Kani Toshimitsu <toshi.kani@hpe.com>, slaoub@gmail.com, Joonsoo Kim <js1304@gmail.com>, Andi Kleen <ak@linux.intel.com>, Zhang Zhen <zhenzhang.zhang@huawei.com>, David Rientjes <rientjes@google.com>, Daniel Kiper <daniel.kiper@oracle.com>, Igor Mammedov <imammedo@redhat.com>, Vitaly Kuznetsov <vkuznets@redhat.com>, LKML <linux-kernel@vger.kernel.org>, Chris Metcalf <cmetcalf@mellanox.com>, Dan Williams <dan.j.williams@gmail.com>, Heiko Carstens <heiko.carstens@de.ibm.com>, Lai Jiangshan <laijs@cn.fujitsu.com>, Martin Schwidefsky <schwidefsky@de.ibm.com>

[Let's add Gary who as introduced this code c04fc586c1a48]

On Mon 03-04-17 15:42:13, Reza Arbab wrote:
> On Mon, Apr 03, 2017 at 10:23:38PM +0200, Michal Hocko wrote:
> >On Mon 03-04-17 14:58:30, Reza Arbab wrote:
> >>However, I am seeing a regression. When adding memory to a memoryless
> >>node, it shows up in node 0 instead. I'm digging to see if I can help
> >>narrow down where things go wrong.
> >
> >OK, I guess I know what is going on here. online_pages relies on
> >pfn_to_nid(pfn) to return a proper node. But we are doing
> >page_to_nid(pfn_to_page(__pfn_to_nid_pfn)) so we rely on the page being
> >properly initialized. Damn, I should have noticed that. There are two
> >ways around that. Either the __add_section stores the nid into the
> >struct page and make page_to_nid reliable or store it somewhere else
> >(ideally into the memblock). The first is easier (let's do it for now)
> >but longterm we do not want to rely on the struct page at all I believe.
> >
> >Does the following help?
> >---
> >diff --git a/mm/memory_hotplug.c b/mm/memory_hotplug.c
> >index b9dc1c4e26c3..0e21b9f67c9d 100644
> >--- a/mm/memory_hotplug.c
> >+++ b/mm/memory_hotplug.c
> >@@ -309,14 +309,19 @@ static int __meminit __add_section(int nid, unsigned long phys_start_pfn)
> >
> >	/*
> >	 * Make all the pages reserved so that nobody will stumble over half
> >-	 * initialized state.
> >+	 * initialized state.
> >+	 * FIXME: We also have to associate it with a node because pfn_to_node
> >+	 * relies on having page with the proper node.
> >	 */
> >	for (i = 0; i < PAGES_PER_SECTION; i++) {
> >		unsigned long pfn = phys_start_pfn + i;
> >+		struct page *page;
> >		if (!pfn_valid(pfn))
> >			continue;
> >
> >-		SetPageReserved(pfn_to_page(phys_start_pfn + i));
> >+		page = pfn_to_page(pfn);
> >+		set_page_node(page, nid);
> >+		SetPageReserved(page);
> >	}
> >
> >	return register_new_memory(nid, __pfn_to_section(phys_start_pfn));
> 
> Almost there. I'm seeing the memory in the correct node now, but the
> /sys/devices/system/node/nodeX/memoryY links are not being created.
> 
> I think it's tripping up here, in register_mem_sect_under_node():
> 
> 		page_nid = get_nid_for_pfn(pfn);
> 		if (page_nid < 0)
> 			continue;

Huh, this code is confusing. How can we have a memblock spanning more
nodes? If not then the loop over all sections in the memblock seem
pointless as well.  Also why do we require page_initialized() in
get_nid_for_pfn? The changelog doesn't explain that and there are no
comments that would help either.

Gary, could you clarify this please?
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
