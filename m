Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f197.google.com (mail-wr0-f197.google.com [209.85.128.197])
	by kanga.kvack.org (Postfix) with ESMTP id BF1CF6B03A2
	for <linux-mm@kvack.org>; Mon,  3 Apr 2017 16:23:44 -0400 (EDT)
Received: by mail-wr0-f197.google.com with SMTP id o70so25630587wrb.11
        for <linux-mm@kvack.org>; Mon, 03 Apr 2017 13:23:44 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id n136si16612286wmg.104.2017.04.03.13.23.42
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Mon, 03 Apr 2017 13:23:42 -0700 (PDT)
Date: Mon, 3 Apr 2017 22:23:38 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH 0/6] mm: make movable onlining suck less
Message-ID: <20170403202337.GA12482@dhcp22.suse.cz>
References: <20170330115454.32154-1-mhocko@kernel.org>
 <20170403115545.GK24661@dhcp22.suse.cz>
 <20170403195830.64libncet5l6vuvb@arbab-laptop>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170403195830.64libncet5l6vuvb@arbab-laptop>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Reza Arbab <arbab@linux.vnet.ibm.com>
Cc: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, Vlastimil Babka <vbabka@suse.cz>, Andrea Arcangeli <aarcange@redhat.com>, Yasuaki Ishimatsu <yasu.isimatu@gmail.com>, Tang Chen <tangchen@cn.fujitsu.com>, qiuxishi@huawei.com, Kani Toshimitsu <toshi.kani@hpe.com>, slaoub@gmail.com, Joonsoo Kim <js1304@gmail.com>, Andi Kleen <ak@linux.intel.com>, Zhang Zhen <zhenzhang.zhang@huawei.com>, David Rientjes <rientjes@google.com>, Daniel Kiper <daniel.kiper@oracle.com>, Igor Mammedov <imammedo@redhat.com>, Vitaly Kuznetsov <vkuznets@redhat.com>, LKML <linux-kernel@vger.kernel.org>, Chris Metcalf <cmetcalf@mellanox.com>, Dan Williams <dan.j.williams@gmail.com>, Heiko Carstens <heiko.carstens@de.ibm.com>, Lai Jiangshan <laijs@cn.fujitsu.com>, Martin Schwidefsky <schwidefsky@de.ibm.com>

On Mon 03-04-17 14:58:30, Reza Arbab wrote:
> On Mon, Apr 03, 2017 at 01:55:46PM +0200, Michal Hocko wrote:
> >Anyting? I would really appreciate a feedback from IBM and Futjitsu guys
> >who have shaped this code last few years. Also Igor and Vitaly seem to be
> >using memory hotplug in virtualized environments. I do not expect they
> >would see a huge advantage of the rework but I would appreciate to give it
> >some testing to catch any potential regressions.
> 
> Sorry for the delayed reply.
> 
> With this set, I'm able to "online_movable" blocks in ascending order.
> 
> However, I am seeing a regression. When adding memory to a memoryless node,
> it shows up in node 0 instead. I'm digging to see if I can help narrow down
> where things go wrong.

OK, I guess I know what is going on here. online_pages relies on
pfn_to_nid(pfn) to return a proper node. But we are doing
page_to_nid(pfn_to_page(__pfn_to_nid_pfn)) so we rely on the page being
properly initialized. Damn, I should have noticed that. There are two
ways around that. Either the __add_section stores the nid into the
struct page and make page_to_nid reliable or store it somewhere else
(ideally into the memblock). The first is easier (let's do it for now)
but longterm we do not want to rely on the struct page at all I believe.

Does the following help?
---
diff --git a/mm/memory_hotplug.c b/mm/memory_hotplug.c
index b9dc1c4e26c3..0e21b9f67c9d 100644
--- a/mm/memory_hotplug.c
+++ b/mm/memory_hotplug.c
@@ -309,14 +309,19 @@ static int __meminit __add_section(int nid, unsigned long phys_start_pfn)
 
 	/*
 	 * Make all the pages reserved so that nobody will stumble over half
-	 * initialized state.
+	 * initialized state. 
+	 * FIXME: We also have to associate it with a node because pfn_to_node
+	 * relies on having page with the proper node.
 	 */
 	for (i = 0; i < PAGES_PER_SECTION; i++) {
 		unsigned long pfn = phys_start_pfn + i;
+		struct page *page;
 		if (!pfn_valid(pfn))
 			continue;
 
-		SetPageReserved(pfn_to_page(phys_start_pfn + i));
+		page = pfn_to_page(pfn);
+		set_page_node(page, nid);
+		SetPageReserved(page);
 	}
 
 	return register_new_memory(nid, __pfn_to_section(phys_start_pfn));
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
