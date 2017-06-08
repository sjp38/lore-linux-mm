Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f70.google.com (mail-wm0-f70.google.com [74.125.82.70])
	by kanga.kvack.org (Postfix) with ESMTP id 8020A6B0279
	for <linux-mm@kvack.org>; Thu,  8 Jun 2017 04:22:35 -0400 (EDT)
Received: by mail-wm0-f70.google.com with SMTP id c16so2770510wmh.14
        for <linux-mm@kvack.org>; Thu, 08 Jun 2017 01:22:35 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id r20si4968227wmd.15.2017.06.08.01.22.34
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 08 Jun 2017 01:22:34 -0700 (PDT)
Subject: Re: [PATCH 2/4] hugetlb, memory_hotplug: prefer to use reserved pages
 for migration
References: <20170608074553.22152-1-mhocko@kernel.org>
 <20170608074553.22152-3-mhocko@kernel.org>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <faef20f5-80b4-fcb0-6460-ddae9856f35e@suse.cz>
Date: Thu, 8 Jun 2017 10:22:32 +0200
MIME-Version: 1.0
In-Reply-To: <20170608074553.22152-3-mhocko@kernel.org>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>, linux-mm@kvack.org
Cc: Andrew Morton <akpm@linux-foundation.org>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Xishi Qiu <qiuxishi@huawei.com>, zhong jiang <zhongjiang@huawei.com>, Joonsoo Kim <js1304@gmail.com>, LKML <linux-kernel@vger.kernel.org>, Michal Hocko <mhocko@suse.com>

On 06/08/2017 09:45 AM, Michal Hocko wrote:
> From: Michal Hocko <mhocko@suse.com>
> 
> new_node_page will try to use the origin's next NUMA node as the
> migration destination for hugetlb pages. If such a node doesn't have any
> preallocated pool it falls back to __alloc_buddy_huge_page_no_mpol to
> allocate a surplus page instead. This is quite subotpimal for any
> configuration when hugetlb pages are no distributed to all NUMA nodes
> evenly. Say we have a hotplugable node 4 and spare hugetlb pages are
> node 0
> /sys/devices/system/node/node0/hugepages/hugepages-2048kB/nr_hugepages:10000
> /sys/devices/system/node/node1/hugepages/hugepages-2048kB/nr_hugepages:0
> /sys/devices/system/node/node2/hugepages/hugepages-2048kB/nr_hugepages:0
> /sys/devices/system/node/node3/hugepages/hugepages-2048kB/nr_hugepages:0
> /sys/devices/system/node/node4/hugepages/hugepages-2048kB/nr_hugepages:10000
> /sys/devices/system/node/node5/hugepages/hugepages-2048kB/nr_hugepages:0
> /sys/devices/system/node/node6/hugepages/hugepages-2048kB/nr_hugepages:0
> /sys/devices/system/node/node7/hugepages/hugepages-2048kB/nr_hugepages:0
> 
> Now we consume the whole pool on node 4 and try to offline this
> node. All the allocated pages should be moved to node0 which has enough
> preallocated pages to hold them. With the current implementation
> offlining very likely fails because hugetlb allocations during runtime
> are much less reliable.
> 
> Fix this by reusing the nodemask which excludes migration source and try
> to find a first node which has a page in the preallocated pool first and
> fall back to __alloc_buddy_huge_page_no_mpol only when the whole pool is
> consumed.
> 
> Signed-off-by: Michal Hocko <mhocko@suse.com>

Acked-by: Vlastimil Babka <vbabka@suse.cz>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
