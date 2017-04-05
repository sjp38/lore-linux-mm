Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f70.google.com (mail-pg0-f70.google.com [74.125.83.70])
	by kanga.kvack.org (Postfix) with ESMTP id 43BA26B039F
	for <linux-mm@kvack.org>; Wed,  5 Apr 2017 11:49:10 -0400 (EDT)
Received: by mail-pg0-f70.google.com with SMTP id r129so8775140pgr.18
        for <linux-mm@kvack.org>; Wed, 05 Apr 2017 08:49:10 -0700 (PDT)
Received: from mx0a-001b2d01.pphosted.com (mx0a-001b2d01.pphosted.com. [148.163.156.1])
        by mx.google.com with ESMTPS id j64si20920699pge.346.2017.04.05.08.49.09
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 05 Apr 2017 08:49:09 -0700 (PDT)
Received: from pps.filterd (m0098393.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.20/8.16.0.20) with SMTP id v35Fn7ss089295
	for <linux-mm@kvack.org>; Wed, 5 Apr 2017 11:49:09 -0400
Received: from e19.ny.us.ibm.com (e19.ny.us.ibm.com [129.33.205.209])
	by mx0a-001b2d01.pphosted.com with ESMTP id 29mspyph7t-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Wed, 05 Apr 2017 11:49:08 -0400
Received: from localhost
	by e19.ny.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <arbab@linux.vnet.ibm.com>;
	Wed, 5 Apr 2017 11:49:01 -0400
Date: Wed, 5 Apr 2017 10:48:52 -0500
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
 <20170405064239.GB6035@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Disposition: inline
In-Reply-To: <20170405064239.GB6035@dhcp22.suse.cz>
Message-Id: <20170405154852.kdkwuudjv2jwvj5g@arbab-laptop>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Mel Gorman <mgorman@suse.de>, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Vlastimil Babka <vbabka@suse.cz>, Andrea Arcangeli <aarcange@redhat.com>, Yasuaki Ishimatsu <yasu.isimatu@gmail.com>, Tang Chen <tangchen@cn.fujitsu.com>, qiuxishi@huawei.com, Kani Toshimitsu <toshi.kani@hpe.com>, slaoub@gmail.com, Joonsoo Kim <js1304@gmail.com>, Andi Kleen <ak@linux.intel.com>, Zhang Zhen <zhenzhang.zhang@huawei.com>, David Rientjes <rientjes@google.com>, Daniel Kiper <daniel.kiper@oracle.com>, Igor Mammedov <imammedo@redhat.com>, Vitaly Kuznetsov <vkuznets@redhat.com>, LKML <linux-kernel@vger.kernel.org>, Chris Metcalf <cmetcalf@mellanox.com>, Dan Williams <dan.j.williams@gmail.com>, Heiko Carstens <heiko.carstens@de.ibm.com>, Lai Jiangshan <laijs@cn.fujitsu.com>, Martin Schwidefsky <schwidefsky@de.ibm.com>

On Wed, Apr 05, 2017 at 08:42:39AM +0200, Michal Hocko wrote:
>On Tue 04-04-17 16:43:39, Reza Arbab wrote:
>> Okay, getting further. With this I can again repeatedly add and 
>> remove, but now I'm seeing a weird variation of that earlier issue:
>>
>> 1. add_memory(), online_movable
>>   /sys/devices/system/node/nodeX/memoryY symlinks are created.
>>
>> 2. offline, remove_memory()
>>   The node is offlined, since all memory has been removed, so all of
>>   /sys/devices/system/node/nodeX is gone. This is normal.
>>
>> 3. add_memory(), online_movable
>>   The node is onlined, so /sys/devices/system/node/nodeX is recreated,
>>   and the memory is added, but just like earlier in this email thread,
>>   the memoryY links are not there.
>
>Could you add some printks to see why the sysfs creation failed please?

Ah, simple enough. It's this, right at the top of 
register_mem_sect_under_node():

	if (!node_online(nid))
		return 0;

That being the case, I really don't understand why your patches make any 
difference. Is node_set_online() being called later than before somehow?

-- 
Reza Arbab

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
