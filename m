Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f70.google.com (mail-pg0-f70.google.com [74.125.83.70])
	by kanga.kvack.org (Postfix) with ESMTP id 6DDAE6B03A2
	for <linux-mm@kvack.org>; Tue,  4 Apr 2017 12:02:50 -0400 (EDT)
Received: by mail-pg0-f70.google.com with SMTP id 79so178592595pgf.2
        for <linux-mm@kvack.org>; Tue, 04 Apr 2017 09:02:50 -0700 (PDT)
Received: from mx0a-001b2d01.pphosted.com (mx0a-001b2d01.pphosted.com. [148.163.156.1])
        by mx.google.com with ESMTPS id 80si17868741pga.172.2017.04.04.09.02.49
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 04 Apr 2017 09:02:49 -0700 (PDT)
Received: from pps.filterd (m0098396.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.20/8.16.0.20) with SMTP id v34Frovs133092
	for <linux-mm@kvack.org>; Tue, 4 Apr 2017 12:02:49 -0400
Received: from e13.ny.us.ibm.com (e13.ny.us.ibm.com [129.33.205.203])
	by mx0a-001b2d01.pphosted.com with ESMTP id 29mcjffv7q-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Tue, 04 Apr 2017 12:02:48 -0400
Received: from localhost
	by e13.ny.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <arbab@linux.vnet.ibm.com>;
	Tue, 4 Apr 2017 12:02:47 -0400
Date: Tue, 4 Apr 2017 11:02:39 -0500
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
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <20170404082302.GE15132@dhcp22.suse.cz>
Message-Id: <20170404160239.ftvuxklioo6zvuxl@arbab-laptop>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Mel Gorman <mgorman@suse.de>, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Vlastimil Babka <vbabka@suse.cz>, Andrea Arcangeli <aarcange@redhat.com>, Yasuaki Ishimatsu <yasu.isimatu@gmail.com>, Tang Chen <tangchen@cn.fujitsu.com>, qiuxishi@huawei.com, Kani Toshimitsu <toshi.kani@hpe.com>, slaoub@gmail.com, Joonsoo Kim <js1304@gmail.com>, Andi Kleen <ak@linux.intel.com>, Zhang Zhen <zhenzhang.zhang@huawei.com>, David Rientjes <rientjes@google.com>, Daniel Kiper <daniel.kiper@oracle.com>, Igor Mammedov <imammedo@redhat.com>, Vitaly Kuznetsov <vkuznets@redhat.com>, LKML <linux-kernel@vger.kernel.org>, Chris Metcalf <cmetcalf@mellanox.com>, Dan Williams <dan.j.williams@gmail.com>, Heiko Carstens <heiko.carstens@de.ibm.com>, Lai Jiangshan <laijs@cn.fujitsu.com>, Martin Schwidefsky <schwidefsky@de.ibm.com>

On Tue, Apr 04, 2017 at 10:23:02AM +0200, Michal Hocko wrote:
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

You can get rid of 'page' altogether.

drivers/base/node.c: In function a??get_nid_for_pfna??:
drivers/base/node.c:373:15: warning: unused variable a??pagea?? [-Wunused-variable]

-- 
Reza Arbab

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
