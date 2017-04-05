Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id B3B2E6B0038
	for <linux-mm@kvack.org>; Wed,  5 Apr 2017 11:23:41 -0400 (EDT)
Received: by mail-pf0-f198.google.com with SMTP id q70so8084303pfi.20
        for <linux-mm@kvack.org>; Wed, 05 Apr 2017 08:23:41 -0700 (PDT)
Received: from mx0a-001b2d01.pphosted.com (mx0a-001b2d01.pphosted.com. [148.163.156.1])
        by mx.google.com with ESMTPS id p5si20873648pgi.297.2017.04.05.08.23.40
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 05 Apr 2017 08:23:40 -0700 (PDT)
Received: from pps.filterd (m0098404.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.20/8.16.0.20) with SMTP id v35FJDZj090830
	for <linux-mm@kvack.org>; Wed, 5 Apr 2017 11:23:40 -0400
Received: from e35.co.us.ibm.com (e35.co.us.ibm.com [32.97.110.153])
	by mx0a-001b2d01.pphosted.com with ESMTP id 29n2vt15nb-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Wed, 05 Apr 2017 11:23:40 -0400
Received: from localhost
	by e35.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <arbab@linux.vnet.ibm.com>;
	Wed, 5 Apr 2017 09:23:39 -0600
Date: Wed, 5 Apr 2017 10:23:28 -0500
From: Reza Arbab <arbab@linux.vnet.ibm.com>
Subject: Re: [PATCH 0/6] mm: make movable onlining suck less
References: <20170403204213.rs7k2cvsnconel2z@arbab-laptop>
 <20170404072329.GA15132@dhcp22.suse.cz>
 <20170404073412.GC15132@dhcp22.suse.cz>
 <20170404082302.GE15132@dhcp22.suse.cz>
 <20170404160239.ftvuxklioo6zvuxl@arbab-laptop>
 <20170404164452.GQ15132@dhcp22.suse.cz>
 <20170404183012.a6biape5y7vu6cjm@arbab-laptop>
 <20170404194122.GS15132@dhcp22.suse.cz>
 <20170404214339.6o4c4uhwudyhzbbo@arbab-laptop>
 <20170405135248.GQ6035@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Disposition: inline
In-Reply-To: <20170405135248.GQ6035@dhcp22.suse.cz>
Message-Id: <20170405152328.3gq3te2z3hpvxfzx@arbab-laptop>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Mel Gorman <mgorman@suse.de>, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Vlastimil Babka <vbabka@suse.cz>, Andrea Arcangeli <aarcange@redhat.com>, Yasuaki Ishimatsu <yasu.isimatu@gmail.com>, Tang Chen <tangchen@cn.fujitsu.com>, qiuxishi@huawei.com, Kani Toshimitsu <toshi.kani@hpe.com>, slaoub@gmail.com, Joonsoo Kim <js1304@gmail.com>, Andi Kleen <ak@linux.intel.com>, Zhang Zhen <zhenzhang.zhang@huawei.com>, David Rientjes <rientjes@google.com>, Daniel Kiper <daniel.kiper@oracle.com>, Igor Mammedov <imammedo@redhat.com>, Vitaly Kuznetsov <vkuznets@redhat.com>, LKML <linux-kernel@vger.kernel.org>, Chris Metcalf <cmetcalf@mellanox.com>, Dan Williams <dan.j.williams@gmail.com>, Heiko Carstens <heiko.carstens@de.ibm.com>, Lai Jiangshan <laijs@cn.fujitsu.com>, Martin Schwidefsky <schwidefsky@de.ibm.com>

On Wed, Apr 05, 2017 at 03:52:49PM +0200, Michal Hocko wrote:
>My code doesn't do that though. So I guess I have to sanitize. Does 
>this help? Please drop the "mm, memory_hotplug: get rid of zone/node
>shrinking" patch.
>---
>diff --git a/mm/memory_hotplug.c b/mm/memory_hotplug.c
>index acf2b5eb5ecb..2c5613d19eb6 100644
>--- a/mm/memory_hotplug.c
>+++ b/mm/memory_hotplug.c
>@@ -750,6 +750,15 @@ int __ref online_pages(unsigned long pfn, unsigned long nr_pages, int online_typ
> 	int ret;
> 	struct memory_notify arg;
>
>+	do {
>+		if (pfn_valid(pfn))
>+			break;
>+		pfn++;
>+	} while (--nr_pages > 0);
>+
>+	if (!nr_pages)
>+		return -EINVAL;
>+
> 	nid = pfn_to_nid(pfn);
> 	if (!allow_online_pfn_range(nid, pfn, nr_pages, online_type))
> 		return -EINVAL;

Sorry, no change. Back to the oops in find_biggest_section_pfn().

-- 
Reza Arbab

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
