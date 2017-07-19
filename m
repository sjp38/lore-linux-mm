Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f199.google.com (mail-wr0-f199.google.com [209.85.128.199])
	by kanga.kvack.org (Postfix) with ESMTP id 8C6916B0279
	for <linux-mm@kvack.org>; Wed, 19 Jul 2017 09:44:26 -0400 (EDT)
Received: by mail-wr0-f199.google.com with SMTP id p12so9304707wrc.8
        for <linux-mm@kvack.org>; Wed, 19 Jul 2017 06:44:26 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id 93si337709wrr.466.2017.07.19.06.44.24
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 19 Jul 2017 06:44:25 -0700 (PDT)
Date: Wed, 19 Jul 2017 15:44:21 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH 1/9] mm, page_alloc: rip out ZONELIST_ORDER_ZONE
Message-ID: <20170719134420.GA6170@dhcp22.suse.cz>
References: <20170714080006.7250-1-mhocko@kernel.org>
 <20170714080006.7250-2-mhocko@kernel.org>
 <a4490c3e-9f7b-72b2-dfa3-80c054df6600@suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <a4490c3e-9f7b-72b2-dfa3-80c054df6600@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, Johannes Weiner <hannes@cmpxchg.org>, LKML <linux-kernel@vger.kernel.org>, linux-api@vger.kernel.org

On Wed 19-07-17 11:33:49, Vlastimil Babka wrote:
> On 07/14/2017 09:59 AM, Michal Hocko wrote:
> > From: Michal Hocko <mhocko@suse.com>
> > 
> > Supporting zone ordered zonelists costs us just a lot of code while
> > the usefulness is arguable if existent at all. Mel has already made
> > node ordering default on 64b systems. 32b systems are still using
> > ZONELIST_ORDER_ZONE because it is considered better to fallback to
> > a different NUMA node rather than consume precious lowmem zones.
> > 
> > This argument is, however, weaken by the fact that the memory reclaim
> > has been reworked to be node rather than zone oriented. This means
> > that lowmem requests have to skip over all highmem pages on LRUs already
> > and so zone ordering doesn't save the reclaim time much. So the only
> > advantage of the zone ordering is under a light memory pressure when
> > highmem requests do not ever hit into lowmem zones and the lowmem
> > pressure doesn't need to reclaim.
> > 
> > Considering that 32b NUMA systems are rather suboptimal already and
> > it is generally advisable to use 64b kernel on such a HW I believe we
> > should rather care about the code maintainability and just get rid of
> > ZONELIST_ORDER_ZONE altogether. Keep systcl in place and warn if
> > somebody tries to set zone ordering either from kernel command line
> > or the sysctl.
> > 
> > Cc: <linux-api@vger.kernel.org>
> > Signed-off-by: Michal Hocko <mhocko@suse.com>
> 
> Found some leftovers to cleanup:
> 
> include/linux/mmzone.h:
> extern char numa_zonelist_order[];
> #define NUMA_ZONELIST_ORDER_LEN 16      /* string buffer size */
> 
> Also update docs?
> Documentation/sysctl/vm.txt:zone.  Specify "[Zz]one" for zone order.
> Documentation/admin-guide/kernel-parameters.txt:
> numa_zonelist_order= [KNL, BOOT] Select zonelist order for NUMA.
> Documentation/vm/numa:a default zonelist order based on the sizes of the
> various zone types relative
> Documentation/vm/numa:default zonelist order may be overridden using the
> numa_zonelist_order kernel
> 
> Otherwise,
> Acked-by: Vlastimil Babka <vbabka@suse.cz>

This?
---
commit 06c69d6785447160717ca8cc476dc9cac7a3f964
Author: Michal Hocko <mhocko@suse.com>
Date:   Wed Jul 19 14:28:31 2017 +0200

    fold me
    
    - update documentation as per Vlastimil
    
    Acked-by: Vlastimil Babka <vbabka@suse.cz>

diff --git a/Documentation/admin-guide/kernel-parameters.txt b/Documentation/admin-guide/kernel-parameters.txt
index 60530c8490ff..28f1a0f84456 100644
--- a/Documentation/admin-guide/kernel-parameters.txt
+++ b/Documentation/admin-guide/kernel-parameters.txt
@@ -2724,7 +2724,7 @@
 			Allowed values are enable and disable
 
 	numa_zonelist_order= [KNL, BOOT] Select zonelist order for NUMA.
-			one of ['zone', 'node', 'default'] can be specified
+			'node', 'default' can be specified
 			This can be set from sysctl after boot.
 			See Documentation/sysctl/vm.txt for details.
 
diff --git a/Documentation/sysctl/vm.txt b/Documentation/sysctl/vm.txt
index 48244c42ff52..9baf66a9ef4e 100644
--- a/Documentation/sysctl/vm.txt
+++ b/Documentation/sysctl/vm.txt
@@ -572,7 +572,9 @@ See Documentation/nommu-mmap.txt for more information.
 
 numa_zonelist_order
 
-This sysctl is only for NUMA.
+This sysctl is only for NUMA and it is deprecated. Anything but
+Node order will fail!
+
 'where the memory is allocated from' is controlled by zonelists.
 (This documentation ignores ZONE_HIGHMEM/ZONE_DMA32 for simple explanation.
  you may be able to read ZONE_DMA as ZONE_DMA32...)
diff --git a/Documentation/vm/numa b/Documentation/vm/numa
index a08f71647714..a31b85b9bb88 100644
--- a/Documentation/vm/numa
+++ b/Documentation/vm/numa
@@ -79,11 +79,8 @@ memory, Linux must decide whether to order the zonelists such that allocations
 fall back to the same zone type on a different node, or to a different zone
 type on the same node.  This is an important consideration because some zones,
 such as DMA or DMA32, represent relatively scarce resources.  Linux chooses
-a default zonelist order based on the sizes of the various zone types relative
-to the total memory of the node and the total memory of the system.  The
-default zonelist order may be overridden using the numa_zonelist_order kernel
-boot parameter or sysctl.  [see Documentation/admin-guide/kernel-parameters.rst and
-Documentation/sysctl/vm.txt]
+a default Node ordered zonelist. This means it tries to fallback to other zones
+from the same node before using remote nodes which are ordered by NUMA distance.
 
 By default, Linux will attempt to satisfy memory allocation requests from the
 node to which the CPU that executes the request is assigned.  Specifically,
diff --git a/include/linux/mmzone.h b/include/linux/mmzone.h
index fc14b8b3f6ce..b849006b20d3 100644
--- a/include/linux/mmzone.h
+++ b/include/linux/mmzone.h
@@ -895,8 +895,6 @@ int sysctl_min_slab_ratio_sysctl_handler(struct ctl_table *, int,
 
 extern int numa_zonelist_order_handler(struct ctl_table *, int,
 			void __user *, size_t *, loff_t *);
-extern char numa_zonelist_order[];
-#define NUMA_ZONELIST_ORDER_LEN 16	/* string buffer size */
 
 #ifndef CONFIG_NEED_MULTIPLE_NODES
 

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
