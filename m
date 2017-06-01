Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f70.google.com (mail-wm0-f70.google.com [74.125.82.70])
	by kanga.kvack.org (Postfix) with ESMTP id 0DF866B0279
	for <linux-mm@kvack.org>; Thu,  1 Jun 2017 08:57:35 -0400 (EDT)
Received: by mail-wm0-f70.google.com with SMTP id d127so9735547wmf.15
        for <linux-mm@kvack.org>; Thu, 01 Jun 2017 05:57:35 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id f55si18882713edd.78.2017.06.01.05.57.33
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 01 Jun 2017 05:57:33 -0700 (PDT)
Subject: Re: [PATCH 2/2] mm, memory_hotplug: do not assume ZONE_NORMAL is
 default kernel zone
References: <20170601083746.4924-1-mhocko@kernel.org>
 <20170601083746.4924-3-mhocko@kernel.org>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <0885b6bd-3d29-efef-e31c-9797d0421fe8@suse.cz>
Date: Thu, 1 Jun 2017 14:57:27 +0200
MIME-Version: 1.0
In-Reply-To: <20170601083746.4924-3-mhocko@kernel.org>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>, Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, Mel Gorman <mgorman@suse.de>, Andrea Arcangeli <aarcange@redhat.com>, Jerome Glisse <jglisse@redhat.com>, Reza Arbab <arbab@linux.vnet.ibm.com>, Yasuaki Ishimatsu <yasu.isimatu@gmail.com>, qiuxishi@huawei.com, Kani Toshimitsu <toshi.kani@hpe.com>, slaoub@gmail.com, Joonsoo Kim <js1304@gmail.com>, Andi Kleen <ak@linux.intel.com>, David Rientjes <rientjes@google.com>, Daniel Kiper <daniel.kiper@oracle.com>, Igor Mammedov <imammedo@redhat.com>, Vitaly Kuznetsov <vkuznets@redhat.com>, Heiko Carstens <heiko.carstens@de.ibm.com>, LKML <linux-kernel@vger.kernel.org>, Michal Hocko <mhocko@suse.com>

On 06/01/2017 10:37 AM, Michal Hocko wrote:
> From: Michal Hocko <mhocko@suse.com>
> 
> Heiko Carstens has noticed that he can generate overlapping zones for
> ZONE_DMA and ZONE_NORMAL:
> DMA      [mem 0x0000000000000000-0x000000007fffffff]
> Normal   [mem 0x0000000080000000-0x000000017fffffff]
> 
> $ cat /sys/devices/system/memory/block_size_bytes
> 10000000
> $ cat /sys/devices/system/memory/memory5/valid_zones
> DMA
> $ echo 0 > /sys/devices/system/memory/memory5/online
> $ cat /sys/devices/system/memory/memory5/valid_zones
> Normal
> $ echo 1 > /sys/devices/system/memory/memory5/online
> Normal
> 
> $ cat /proc/zoneinfo
> Node 0, zone      DMA
> spanned  524288        <-----
> present  458752
> managed  455078
> start_pfn:           0 <-----
> 
> Node 0, zone   Normal
> spanned  720896
> present  589824
> managed  571648
> start_pfn:           327680 <-----
> 
> The reason is that we assume that the default zone for kernel onlining
> is ZONE_NORMAL. This was a simplification introduced by the memory
> hotplug rework and it is easily fixable by checking the range overlap in
> the zone order and considering the first matching zone as the default
> one. If there is no such zone then assume ZONE_NORMAL as we have been
> doing so far.
> 
> Fixes: "mm, memory_hotplug: do not associate hotadded memory to zones until online"
> Reported-by: Heiko Carstens <heiko.carstens@de.ibm.com>
> Tested-by: Heiko Carstens <heiko.carstens@de.ibm.com>
> Signed-off-by: Michal Hocko <mhocko@suse.com>

Acked-by: Vlastimil Babka <vbabka@suse.cz>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
