Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f200.google.com (mail-wr0-f200.google.com [209.85.128.200])
	by kanga.kvack.org (Postfix) with ESMTP id 549D86B03A2
	for <linux-mm@kvack.org>; Mon,  3 Apr 2017 16:42:27 -0400 (EDT)
Received: by mail-wr0-f200.google.com with SMTP id z109so25687035wrb.1
        for <linux-mm@kvack.org>; Mon, 03 Apr 2017 13:42:27 -0700 (PDT)
Received: from mx0a-001b2d01.pphosted.com (mx0b-001b2d01.pphosted.com. [148.163.158.5])
        by mx.google.com with ESMTPS id g41si21391613wra.216.2017.04.03.13.42.25
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 03 Apr 2017 13:42:25 -0700 (PDT)
Received: from pps.filterd (m0098414.ppops.net [127.0.0.1])
	by mx0b-001b2d01.pphosted.com (8.16.0.20/8.16.0.20) with SMTP id v33KcsHZ121028
	for <linux-mm@kvack.org>; Mon, 3 Apr 2017 16:42:24 -0400
Received: from e18.ny.us.ibm.com (e18.ny.us.ibm.com [129.33.205.208])
	by mx0b-001b2d01.pphosted.com with ESMTP id 29ktf60c1w-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Mon, 03 Apr 2017 16:42:24 -0400
Received: from localhost
	by e18.ny.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <arbab@linux.vnet.ibm.com>;
	Mon, 3 Apr 2017 16:42:23 -0400
Date: Mon, 3 Apr 2017 15:42:13 -0500
From: Reza Arbab <arbab@linux.vnet.ibm.com>
Subject: Re: [PATCH 0/6] mm: make movable onlining suck less
References: <20170330115454.32154-1-mhocko@kernel.org>
 <20170403115545.GK24661@dhcp22.suse.cz>
 <20170403195830.64libncet5l6vuvb@arbab-laptop>
 <20170403202337.GA12482@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Disposition: inline
In-Reply-To: <20170403202337.GA12482@dhcp22.suse.cz>
Message-Id: <20170403204213.rs7k2cvsnconel2z@arbab-laptop>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, Vlastimil Babka <vbabka@suse.cz>, Andrea Arcangeli <aarcange@redhat.com>, Yasuaki Ishimatsu <yasu.isimatu@gmail.com>, Tang Chen <tangchen@cn.fujitsu.com>, qiuxishi@huawei.com, Kani Toshimitsu <toshi.kani@hpe.com>, slaoub@gmail.com, Joonsoo Kim <js1304@gmail.com>, Andi Kleen <ak@linux.intel.com>, Zhang Zhen <zhenzhang.zhang@huawei.com>, David Rientjes <rientjes@google.com>, Daniel Kiper <daniel.kiper@oracle.com>, Igor Mammedov <imammedo@redhat.com>, Vitaly Kuznetsov <vkuznets@redhat.com>, LKML <linux-kernel@vger.kernel.org>, Chris Metcalf <cmetcalf@mellanox.com>, Dan Williams <dan.j.williams@gmail.com>, Heiko Carstens <heiko.carstens@de.ibm.com>, Lai Jiangshan <laijs@cn.fujitsu.com>, Martin Schwidefsky <schwidefsky@de.ibm.com>

On Mon, Apr 03, 2017 at 10:23:38PM +0200, Michal Hocko wrote:
>On Mon 03-04-17 14:58:30, Reza Arbab wrote:
>> However, I am seeing a regression. When adding memory to a memoryless 
>> node, it shows up in node 0 instead. I'm digging to see if I can help 
>> narrow down where things go wrong.
>
>OK, I guess I know what is going on here. online_pages relies on
>pfn_to_nid(pfn) to return a proper node. But we are doing
>page_to_nid(pfn_to_page(__pfn_to_nid_pfn)) so we rely on the page being
>properly initialized. Damn, I should have noticed that. There are two
>ways around that. Either the __add_section stores the nid into the
>struct page and make page_to_nid reliable or store it somewhere else
>(ideally into the memblock). The first is easier (let's do it for now)
>but longterm we do not want to rely on the struct page at all I believe.
>
>Does the following help?
>---
>diff --git a/mm/memory_hotplug.c b/mm/memory_hotplug.c
>index b9dc1c4e26c3..0e21b9f67c9d 100644
>--- a/mm/memory_hotplug.c
>+++ b/mm/memory_hotplug.c
>@@ -309,14 +309,19 @@ static int __meminit __add_section(int nid, unsigned long phys_start_pfn)
>
> 	/*
> 	 * Make all the pages reserved so that nobody will stumble over half
>-	 * initialized state.
>+	 * initialized state.
>+	 * FIXME: We also have to associate it with a node because pfn_to_node
>+	 * relies on having page with the proper node.
> 	 */
> 	for (i = 0; i < PAGES_PER_SECTION; i++) {
> 		unsigned long pfn = phys_start_pfn + i;
>+		struct page *page;
> 		if (!pfn_valid(pfn))
> 			continue;
>
>-		SetPageReserved(pfn_to_page(phys_start_pfn + i));
>+		page = pfn_to_page(pfn);
>+		set_page_node(page, nid);
>+		SetPageReserved(page);
> 	}
>
> 	return register_new_memory(nid, __pfn_to_section(phys_start_pfn));

Almost there. I'm seeing the memory in the correct node now, but the 
/sys/devices/system/node/nodeX/memoryY links are not being created.

I think it's tripping up here, in register_mem_sect_under_node():

		page_nid = get_nid_for_pfn(pfn);
		if (page_nid < 0)
			continue;

-- 
Reza Arbab

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
