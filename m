Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f199.google.com (mail-wr0-f199.google.com [209.85.128.199])
	by kanga.kvack.org (Postfix) with ESMTP id B51996B03A1
	for <linux-mm@kvack.org>; Tue,  4 Apr 2017 11:59:29 -0400 (EDT)
Received: by mail-wr0-f199.google.com with SMTP id 34so28991560wrb.20
        for <linux-mm@kvack.org>; Tue, 04 Apr 2017 08:59:29 -0700 (PDT)
Received: from mx0a-001b2d01.pphosted.com (mx0b-001b2d01.pphosted.com. [148.163.158.5])
        by mx.google.com with ESMTPS id l127si20362165wmf.62.2017.04.04.08.59.27
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 04 Apr 2017 08:59:28 -0700 (PDT)
Received: from pps.filterd (m0098416.ppops.net [127.0.0.1])
	by mx0b-001b2d01.pphosted.com (8.16.0.20/8.16.0.20) with SMTP id v34Fri22089468
	for <linux-mm@kvack.org>; Tue, 4 Apr 2017 11:59:26 -0400
Received: from e34.co.us.ibm.com (e34.co.us.ibm.com [32.97.110.152])
	by mx0b-001b2d01.pphosted.com with ESMTP id 29kxe3xf5w-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Tue, 04 Apr 2017 11:59:26 -0400
Received: from localhost
	by e34.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <arbab@linux.vnet.ibm.com>;
	Tue, 4 Apr 2017 09:59:25 -0600
Date: Tue, 4 Apr 2017 10:59:10 -0500
From: Reza Arbab <arbab@linux.vnet.ibm.com>
Subject: Re: [PATCH 0/6] mm: make movable onlining suck less
References: <20170330115454.32154-1-mhocko@kernel.org>
 <20170403115545.GK24661@dhcp22.suse.cz>
 <20170403195830.64libncet5l6vuvb@arbab-laptop>
 <20170403202337.GA12482@dhcp22.suse.cz>
 <20170403204213.rs7k2cvsnconel2z@arbab-laptop>
 <20170404072329.GA15132@dhcp22.suse.cz>
 <20170404073412.GC15132@dhcp22.suse.cz>
 <20170404082302.GE15132@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Disposition: inline
In-Reply-To: <20170404082302.GE15132@dhcp22.suse.cz>
Message-Id: <20170404155910.d4hpfjfuceoqrei2@arbab-laptop>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Mel Gorman <mgorman@suse.de>, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Vlastimil Babka <vbabka@suse.cz>, Andrea Arcangeli <aarcange@redhat.com>, Yasuaki Ishimatsu <yasu.isimatu@gmail.com>, Tang Chen <tangchen@cn.fujitsu.com>, qiuxishi@huawei.com, Kani Toshimitsu <toshi.kani@hpe.com>, slaoub@gmail.com, Joonsoo Kim <js1304@gmail.com>, Andi Kleen <ak@linux.intel.com>, Zhang Zhen <zhenzhang.zhang@huawei.com>, David Rientjes <rientjes@google.com>, Daniel Kiper <daniel.kiper@oracle.com>, Igor Mammedov <imammedo@redhat.com>, Vitaly Kuznetsov <vkuznets@redhat.com>, LKML <linux-kernel@vger.kernel.org>, Chris Metcalf <cmetcalf@mellanox.com>, Dan Williams <dan.j.williams@gmail.com>, Heiko Carstens <heiko.carstens@de.ibm.com>, Lai Jiangshan <laijs@cn.fujitsu.com>, Martin Schwidefsky <schwidefsky@de.ibm.com>

On Tue, Apr 04, 2017 at 10:23:02AM +0200, Michal Hocko wrote:
>OK, so I've been thinkin about that and I believe that page_initialized
>check in get_nid_for_pfn is just bogus. There is nothing to rely on the
>page::lru to be already initialized. So I will go with the following as
>a separate preparatory patch.
>
>I believe the whole code should be revisited and I have put that on my
>ever growing todo list because I suspect that it is more complex than
>necessary. I suspect that memblock do not span more nodes and all this
>is just-in-case code (e.g. the onlining code assumes a single zone aka
>node. But let's do that later.
>
>---
>From fd2e3b6eca1cf7766527203d23db6aca5957a3f1 Mon Sep 17 00:00:00 2001
>From: Michal Hocko <mhocko@suse.com>
>Date: Tue, 4 Apr 2017 10:05:06 +0200
>Subject: [PATCH] mm: drop page_initialized check from get_nid_for_pfn
>
>c04fc586c1a4 ("mm: show node to memory section relationship with
>symlinks in sysfs") has added means to export memblock<->node
>association into the sysfs. It has also introduced get_nid_for_pfn
>which is a rather confusing counterpart of pfn_to_nid which checks also
>whether the pfn page is already initialized (page_initialized).  This
>is done by checking page::lru != NULL which doesn't make any sense at
>all. Nothing in this path really relies on the lru list being used or
>initialized. Just remove it
>
>Signed-off-by: Michal Hocko <mhocko@suse.com>
>---
> drivers/base/node.c | 5 -----
> 1 file changed, 5 deletions(-)
>
>diff --git a/drivers/base/node.c b/drivers/base/node.c
>index 5548f9686016..ee080a35e869 100644
>--- a/drivers/base/node.c
>+++ b/drivers/base/node.c
>@@ -368,8 +368,6 @@ int unregister_cpu_under_node(unsigned int cpu, unsigned int nid)
> }
>
> #ifdef CONFIG_MEMORY_HOTPLUG_SPARSE
>-#define page_initialized(page)  (page->lru.next)
>-
> static int __ref get_nid_for_pfn(unsigned long pfn)
> {
> 	struct page *page;
>@@ -380,9 +378,6 @@ static int __ref get_nid_for_pfn(unsigned long pfn)
> 	if (system_state == SYSTEM_BOOTING)
> 		return early_pfn_to_nid(pfn);
> #endif
>-	page = pfn_to_page(pfn);
>-	if (!page_initialized(page))
>-		return -1;
> 	return pfn_to_nid(pfn);
> }
>

Verified that /sys/devices/system/node/nodeX/memoryY links are there now.

-- 
Reza Arbab

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
