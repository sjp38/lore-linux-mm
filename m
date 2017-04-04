Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f72.google.com (mail-pg0-f72.google.com [74.125.83.72])
	by kanga.kvack.org (Postfix) with ESMTP id 07E606B0390
	for <linux-mm@kvack.org>; Tue,  4 Apr 2017 17:43:51 -0400 (EDT)
Received: by mail-pg0-f72.google.com with SMTP id n5so187966963pgd.19
        for <linux-mm@kvack.org>; Tue, 04 Apr 2017 14:43:51 -0700 (PDT)
Received: from mx0a-001b2d01.pphosted.com (mx0a-001b2d01.pphosted.com. [148.163.156.1])
        by mx.google.com with ESMTPS id l14si18644164plk.57.2017.04.04.14.43.49
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 04 Apr 2017 14:43:50 -0700 (PDT)
Received: from pps.filterd (m0098394.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.20/8.16.0.20) with SMTP id v34Lcjvt091243
	for <linux-mm@kvack.org>; Tue, 4 Apr 2017 17:43:49 -0400
Received: from e36.co.us.ibm.com (e36.co.us.ibm.com [32.97.110.154])
	by mx0a-001b2d01.pphosted.com with ESMTP id 29kuruk97k-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Tue, 04 Apr 2017 17:43:49 -0400
Received: from localhost
	by e36.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <arbab@linux.vnet.ibm.com>;
	Tue, 4 Apr 2017 15:43:48 -0600
Date: Tue, 4 Apr 2017 16:43:39 -0500
From: Reza Arbab <arbab@linux.vnet.ibm.com>
Subject: Re: [PATCH 0/6] mm: make movable onlining suck less
References: <20170403195830.64libncet5l6vuvb@arbab-laptop>
 <20170403202337.GA12482@dhcp22.suse.cz>
 <20170403204213.rs7k2cvsnconel2z@arbab-laptop>
 <20170404072329.GA15132@dhcp22.suse.cz>
 <20170404073412.GC15132@dhcp22.suse.cz>
 <20170404082302.GE15132@dhcp22.suse.cz>
 <20170404160239.ftvuxklioo6zvuxl@arbab-laptop>
 <20170404164452.GQ15132@dhcp22.suse.cz>
 <20170404183012.a6biape5y7vu6cjm@arbab-laptop>
 <20170404194122.GS15132@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Disposition: inline
In-Reply-To: <20170404194122.GS15132@dhcp22.suse.cz>
Message-Id: <20170404214339.6o4c4uhwudyhzbbo@arbab-laptop>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Mel Gorman <mgorman@suse.de>, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Vlastimil Babka <vbabka@suse.cz>, Andrea Arcangeli <aarcange@redhat.com>, Yasuaki Ishimatsu <yasu.isimatu@gmail.com>, Tang Chen <tangchen@cn.fujitsu.com>, qiuxishi@huawei.com, Kani Toshimitsu <toshi.kani@hpe.com>, slaoub@gmail.com, Joonsoo Kim <js1304@gmail.com>, Andi Kleen <ak@linux.intel.com>, Zhang Zhen <zhenzhang.zhang@huawei.com>, David Rientjes <rientjes@google.com>, Daniel Kiper <daniel.kiper@oracle.com>, Igor Mammedov <imammedo@redhat.com>, Vitaly Kuznetsov <vkuznets@redhat.com>, LKML <linux-kernel@vger.kernel.org>, Chris Metcalf <cmetcalf@mellanox.com>, Dan Williams <dan.j.williams@gmail.com>, Heiko Carstens <heiko.carstens@de.ibm.com>, Lai Jiangshan <laijs@cn.fujitsu.com>, Martin Schwidefsky <schwidefsky@de.ibm.com>

On Tue, Apr 04, 2017 at 09:41:22PM +0200, Michal Hocko wrote:
>On Tue 04-04-17 13:30:13, Reza Arbab wrote:
>> I think I found another edge case.  You
>> get an oops when removing all of a node's memory:
>>
>> __nr_to_section
>> __pfn_to_section
>> find_biggest_section_pfn
>> shrink_pgdat_span
>> __remove_zone
>> __remove_section
>> __remove_pages
>> arch_remove_memory
>> remove_memory
>
>Is this something new or an old issue? I believe the state after the
>online should be the same as before. So if you onlined the full node
>then there shouldn't be any difference. Let me have a look...

It's new. Without this patchset, I can repeatedly 
add_memory()->online_movable->offline->remove_memory() all of a node's 
memory.

>From 1b08ecef3e8ebcef585fe8f2b23155be54cce335 Mon Sep 17 00:00:00 2001
>From: Michal Hocko <mhocko@suse.com>
>Date: Tue, 4 Apr 2017 21:09:00 +0200
>Subject: [PATCH] mm, hotplug: get rid of zone/node shrinking
>
...%<...
>---
> mm/memory_hotplug.c | 207 ----------------------------------------------------
> 1 file changed, 207 deletions(-)

Okay, getting further. With this I can again repeatedly add and remove, 
but now I'm seeing a weird variation of that earlier issue:

1. add_memory(), online_movable
   /sys/devices/system/node/nodeX/memoryY symlinks are created.

2. offline, remove_memory()
   The node is offlined, since all memory has been removed, so all of
   /sys/devices/system/node/nodeX is gone. This is normal.

3. add_memory(), online_movable
   The node is onlined, so /sys/devices/system/node/nodeX is recreated,
   and the memory is added, but just like earlier in this email thread,
   the memoryY links are not there.

-- 
Reza Arbab

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
