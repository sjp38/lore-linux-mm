Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f197.google.com (mail-wr0-f197.google.com [209.85.128.197])
	by kanga.kvack.org (Postfix) with ESMTP id 0498B6B0038
	for <linux-mm@kvack.org>; Tue,  4 Apr 2017 14:30:27 -0400 (EDT)
Received: by mail-wr0-f197.google.com with SMTP id w96so29472220wrb.13
        for <linux-mm@kvack.org>; Tue, 04 Apr 2017 11:30:26 -0700 (PDT)
Received: from mx0a-001b2d01.pphosted.com (mx0b-001b2d01.pphosted.com. [148.163.158.5])
        by mx.google.com with ESMTPS id s40si17625506wrc.179.2017.04.04.11.30.24
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 04 Apr 2017 11:30:25 -0700 (PDT)
Received: from pps.filterd (m0098414.ppops.net [127.0.0.1])
	by mx0b-001b2d01.pphosted.com (8.16.0.20/8.16.0.20) with SMTP id v34ISZhI138900
	for <linux-mm@kvack.org>; Tue, 4 Apr 2017 14:30:23 -0400
Received: from e15.ny.us.ibm.com (e15.ny.us.ibm.com [129.33.205.205])
	by mx0b-001b2d01.pphosted.com with ESMTP id 29ktf7q4sg-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Tue, 04 Apr 2017 14:30:23 -0400
Received: from localhost
	by e15.ny.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <arbab@linux.vnet.ibm.com>;
	Tue, 4 Apr 2017 14:30:22 -0400
Date: Tue, 4 Apr 2017 13:30:13 -0500
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
 <20170404160239.ftvuxklioo6zvuxl@arbab-laptop>
 <20170404164452.GQ15132@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Disposition: inline
In-Reply-To: <20170404164452.GQ15132@dhcp22.suse.cz>
Message-Id: <20170404183012.a6biape5y7vu6cjm@arbab-laptop>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Mel Gorman <mgorman@suse.de>, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Vlastimil Babka <vbabka@suse.cz>, Andrea Arcangeli <aarcange@redhat.com>, Yasuaki Ishimatsu <yasu.isimatu@gmail.com>, Tang Chen <tangchen@cn.fujitsu.com>, qiuxishi@huawei.com, Kani Toshimitsu <toshi.kani@hpe.com>, slaoub@gmail.com, Joonsoo Kim <js1304@gmail.com>, Andi Kleen <ak@linux.intel.com>, Zhang Zhen <zhenzhang.zhang@huawei.com>, David Rientjes <rientjes@google.com>, Daniel Kiper <daniel.kiper@oracle.com>, Igor Mammedov <imammedo@redhat.com>, Vitaly Kuznetsov <vkuznets@redhat.com>, LKML <linux-kernel@vger.kernel.org>, Chris Metcalf <cmetcalf@mellanox.com>, Dan Williams <dan.j.williams@gmail.com>, Heiko Carstens <heiko.carstens@de.ibm.com>, Lai Jiangshan <laijs@cn.fujitsu.com>, Martin Schwidefsky <schwidefsky@de.ibm.com>

On Tue, Apr 04, 2017 at 06:44:53PM +0200, Michal Hocko wrote:
>Thanks for your testing! This is highly appreciated.
>Can I assume your Tested-by?

Of course! Not quite done, though. I think I found another edge case.  
You get an oops when removing all of a node's memory:

__nr_to_section
__pfn_to_section
find_biggest_section_pfn
shrink_pgdat_span
__remove_zone
__remove_section
__remove_pages
arch_remove_memory
remove_memory

I stuck some debugging prints in, for context:

shrink_pgdat_span: start_pfn=0x10000, end_pfn=0x10100, pgdat_start_pfn=0x0, pgdat_end_pfn=0x20000
shrink_pgdat_span: start_pfn=0x10100, end_pfn=0x10200, pgdat_start_pfn=0x0, pgdat_end_pfn=0x20000
...%<...
shrink_pgdat_span: start_pfn=0x1fe00, end_pfn=0x1ff00, pgdat_start_pfn=0x0, pgdat_end_pfn=0x20000
shrink_pgdat_span: start_pfn=0x1ff00, end_pfn=0x20000, pgdat_start_pfn=0x0, pgdat_end_pfn=0x20000
find_biggest_section_pfn: start_pfn=0x0, end_pfn=0x1ff00
find_biggest_section_pfn loop: pfn=0x1feff, sec_nr = 0x1fe
find_biggest_section_pfn loop: pfn=0x1fdff, sec_nr = 0x1fd
...%<...
find_biggest_section_pfn loop: pfn=0x1ff, sec_nr = 0x1
find_biggest_section_pfn loop: pfn=0xff, sec_nr = 0x0
find_biggest_section_pfn loop: pfn=0xffffffffffffffff, sec_nr = 0xffffffffffffff
Unable to handle kernel paging request for data at address 0xc000800000f19e78


-- 
Reza Arbab

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
