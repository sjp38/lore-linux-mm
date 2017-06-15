Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id CD1206B0292
	for <linux-mm@kvack.org>; Thu, 15 Jun 2017 11:43:30 -0400 (EDT)
Received: by mail-pf0-f200.google.com with SMTP id w12so14231427pfk.1
        for <linux-mm@kvack.org>; Thu, 15 Jun 2017 08:43:30 -0700 (PDT)
Received: from mx0a-001b2d01.pphosted.com (mx0a-001b2d01.pphosted.com. [148.163.156.1])
        by mx.google.com with ESMTPS id 3si307292plo.141.2017.06.15.08.43.30
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 15 Jun 2017 08:43:30 -0700 (PDT)
Received: from pps.filterd (m0098396.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.20/8.16.0.20) with SMTP id v5FFcqpo076086
	for <linux-mm@kvack.org>; Thu, 15 Jun 2017 11:43:29 -0400
Received: from e13.ny.us.ibm.com (e13.ny.us.ibm.com [129.33.205.203])
	by mx0a-001b2d01.pphosted.com with ESMTP id 2b3spr27k7-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Thu, 15 Jun 2017 11:43:29 -0400
Received: from localhost
	by e13.ny.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <arbab@linux.vnet.ibm.com>;
	Thu, 15 Jun 2017 11:43:27 -0400
Date: Thu, 15 Jun 2017 10:43:20 -0500
From: Reza Arbab <arbab@linux.vnet.ibm.com>
Subject: Re: [PATCH] mm, memory_hotplug: support movable_node for hotplugable
 nodes
References: <20170608122318.31598-1-mhocko@kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Disposition: inline
In-Reply-To: <20170608122318.31598-1-mhocko@kernel.org>
Message-Id: <20170615154320.tzpkjxeuckkua2zm@arbab-laptop.localdomain>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, Mel Gorman <mgorman@suse.de>, Vlastimil Babka <vbabka@suse.cz>, Andrea Arcangeli <aarcange@redhat.com>, Yasuaki Ishimatsu <yasu.isimatu@gmail.com>, qiuxishi@huawei.com, Kani Toshimitsu <toshi.kani@hpe.com>, slaoub@gmail.com, Joonsoo Kim <js1304@gmail.com>, Andi Kleen <ak@linux.intel.com>, David Rientjes <rientjes@google.com>, Daniel Kiper <daniel.kiper@oracle.com>, Igor Mammedov <imammedo@redhat.com>, Vitaly Kuznetsov <vkuznets@redhat.com>, LKML <linux-kernel@vger.kernel.org>, Michal Hocko <mhocko@suse.com>

On Thu, Jun 08, 2017 at 02:23:18PM +0200, Michal Hocko wrote:
>movable_node kernel parameter allows to make hotplugable NUMA
>nodes to put all the hotplugable memory into movable zone which
>allows more or less reliable memory hotremove.  At least this
>is the case for the NUMA nodes present during the boot (see
>find_zone_movable_pfns_for_nodes).
>
>This is not the case for the memory hotplug, though.
>
>	echo online > /sys/devices/system/memory/memoryXYZ/status
>
>will default to a kernel zone (usually ZONE_NORMAL) unless the
>particular memblock is already in the movable zone range which is not
>the case normally when onlining the memory from the udev rule context
>for a freshly hotadded NUMA node. The only option currently is to have a
>special udev rule to echo online_movable to all memblocks belonging to
>such a node which is rather clumsy. Not the mention this is inconsistent
>as well because what ended up in the movable zone during the boot will
>end up in a kernel zone after hotremove & hotadd without special care.
>
>It would be nice to reuse memblock_is_hotpluggable but the runtime
>hotplug doesn't have that information available because the boot and
>hotplug paths are not shared and it would be really non trivial to
>make them use the same code path because the runtime hotplug doesn't
>play with the memblock allocator at all.
>
>Teach move_pfn_range that MMOP_ONLINE_KEEP can use the movable zone if
>movable_node is enabled and the range doesn't overlap with the existing
>normal zone. This should provide a reasonable default onlining strategy.
>
>Strictly speaking the semantic is not identical with the boot time
>initialization because find_zone_movable_pfns_for_nodes covers only the
>hotplugable range as described by the BIOS/FW. From my experience this
>is usually a full node though (except for Node0 which is special and
>never goes away completely). If this turns out to be a problem in the
>real life we can tweak the code to store hotplug flag into memblocks
>but let's keep this simple now.
>
>Signed-off-by: Michal Hocko <mhocko@suse.com>

Acked-by: Reza Arbab <arbab@linux.vnet.ibm.com>

-- 
Reza Arbab

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
