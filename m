Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f70.google.com (mail-wm0-f70.google.com [74.125.82.70])
	by kanga.kvack.org (Postfix) with ESMTP id 6E7B86B0279
	for <linux-mm@kvack.org>; Wed, 19 Jul 2017 05:33:52 -0400 (EDT)
Received: by mail-wm0-f70.google.com with SMTP id g15so2324164wmi.11
        for <linux-mm@kvack.org>; Wed, 19 Jul 2017 02:33:52 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id b31si3756718wrd.66.2017.07.19.02.33.50
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 19 Jul 2017 02:33:51 -0700 (PDT)
Subject: Re: [PATCH 1/9] mm, page_alloc: rip out ZONELIST_ORDER_ZONE
References: <20170714080006.7250-1-mhocko@kernel.org>
 <20170714080006.7250-2-mhocko@kernel.org>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <a4490c3e-9f7b-72b2-dfa3-80c054df6600@suse.cz>
Date: Wed, 19 Jul 2017 11:33:49 +0200
MIME-Version: 1.0
In-Reply-To: <20170714080006.7250-2-mhocko@kernel.org>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>, linux-mm@kvack.org
Cc: Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, Johannes Weiner <hannes@cmpxchg.org>, LKML <linux-kernel@vger.kernel.org>, Michal Hocko <mhocko@suse.com>, linux-api@vger.kernel.org

On 07/14/2017 09:59 AM, Michal Hocko wrote:
> From: Michal Hocko <mhocko@suse.com>
> 
> Supporting zone ordered zonelists costs us just a lot of code while
> the usefulness is arguable if existent at all. Mel has already made
> node ordering default on 64b systems. 32b systems are still using
> ZONELIST_ORDER_ZONE because it is considered better to fallback to
> a different NUMA node rather than consume precious lowmem zones.
> 
> This argument is, however, weaken by the fact that the memory reclaim
> has been reworked to be node rather than zone oriented. This means
> that lowmem requests have to skip over all highmem pages on LRUs already
> and so zone ordering doesn't save the reclaim time much. So the only
> advantage of the zone ordering is under a light memory pressure when
> highmem requests do not ever hit into lowmem zones and the lowmem
> pressure doesn't need to reclaim.
> 
> Considering that 32b NUMA systems are rather suboptimal already and
> it is generally advisable to use 64b kernel on such a HW I believe we
> should rather care about the code maintainability and just get rid of
> ZONELIST_ORDER_ZONE altogether. Keep systcl in place and warn if
> somebody tries to set zone ordering either from kernel command line
> or the sysctl.
> 
> Cc: <linux-api@vger.kernel.org>
> Signed-off-by: Michal Hocko <mhocko@suse.com>

Found some leftovers to cleanup:

include/linux/mmzone.h:
extern char numa_zonelist_order[];
#define NUMA_ZONELIST_ORDER_LEN 16      /* string buffer size */

Also update docs?
Documentation/sysctl/vm.txt:zone.  Specify "[Zz]one" for zone order.
Documentation/admin-guide/kernel-parameters.txt:
numa_zonelist_order= [KNL, BOOT] Select zonelist order for NUMA.
Documentation/vm/numa:a default zonelist order based on the sizes of the
various zone types relative
Documentation/vm/numa:default zonelist order may be overridden using the
numa_zonelist_order kernel

Otherwise,
Acked-by: Vlastimil Babka <vbabka@suse.cz>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
