Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f199.google.com (mail-wr0-f199.google.com [209.85.128.199])
	by kanga.kvack.org (Postfix) with ESMTP id 676156B039F
	for <linux-mm@kvack.org>; Thu,  6 Apr 2017 12:55:27 -0400 (EDT)
Received: by mail-wr0-f199.google.com with SMTP id 34so6997674wrb.20
        for <linux-mm@kvack.org>; Thu, 06 Apr 2017 09:55:27 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id e69si3724047wmc.151.2017.04.06.09.55.25
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 06 Apr 2017 09:55:25 -0700 (PDT)
Date: Thu, 6 Apr 2017 17:55:20 +0100
From: Mel Gorman <mgorman@suse.de>
Subject: Re: [PATCH 0/6] mm: make movable onlining suck less
Message-ID: <20170406165520.qjdqclsm6zl6m6p3@suse.de>
References: <20170330115454.32154-1-mhocko@kernel.org>
 <20170406130846.GL5497@dhcp22.suse.cz>
 <20170406152449.zmghwdb4y6hxn4pm@arbab-laptop>
 <20170406154127.GQ5497@dhcp22.suse.cz>
 <20170406154653.yv4i2k2r7hjq6mke@arbab-laptop>
 <20170406162154.GR5497@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20170406162154.GR5497@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Reza Arbab <arbab@linux.vnet.ibm.com>, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Vlastimil Babka <vbabka@suse.cz>, Andrea Arcangeli <aarcange@redhat.com>, Yasuaki Ishimatsu <yasu.isimatu@gmail.com>, Tang Chen <tangchen@cn.fujitsu.com>, qiuxishi@huawei.com, Kani Toshimitsu <toshi.kani@hpe.com>, slaoub@gmail.com, Joonsoo Kim <js1304@gmail.com>, Andi Kleen <ak@linux.intel.com>, Zhang Zhen <zhenzhang.zhang@huawei.com>, David Rientjes <rientjes@google.com>, Daniel Kiper <daniel.kiper@oracle.com>, Igor Mammedov <imammedo@redhat.com>, Vitaly Kuznetsov <vkuznets@redhat.com>, LKML <linux-kernel@vger.kernel.org>, Chris Metcalf <cmetcalf@mellanox.com>, Dan Williams <dan.j.williams@gmail.com>, Heiko Carstens <heiko.carstens@de.ibm.com>, Lai Jiangshan <laijs@cn.fujitsu.com>, Martin Schwidefsky <schwidefsky@de.ibm.com>

On Thu, Apr 06, 2017 at 06:21:55PM +0200, Michal Hocko wrote:
> > This was my first time using your git branch instead of applying the patches
> > from this thread to v4.11-rc5 myself.
> 
> OK, so this looks like another thing to resolve. I have seen this
> warning as well but I didn't consider it relevant because I had to tweak
> the code make the node go offline (removed check_and_unmap_cpu_on_node
> from try_offline_node) so I thought it was a fallout from there. 
> 
> But let's have a look. hotadd_new_pgdat does for an existing pgdat
> 		/* Reset the nr_zones, order and classzone_idx before reuse */
> 		pgdat->nr_zones = 0;
> 		pgdat->kswapd_order = 0;
> 		pgdat->kswapd_classzone_idx = MAX_NR_ZONES;
> 
> so free_area_init_node absolutely has to hit this warning. This is not
> in the Linus tree because it is still in Andrew's mmotm coming from
> http://www.ozlabs.org/~akpm/mmotm/broken-out/mm-vmscan-prevent-kswapd-sleeping-prematurely-due-to-mismatched-classzone_idx.patch
> 
> So yay, finally that doesn't come from me. Mel, I guess that either
> hotadd_new_pgdat should keep its kswapd_classzone_idx = 0 or the warning
> should be updated.
> 

Actually, it's obvious very quickly when I started the fix that updating
the warning would then trigger on normal boot. It's more appropriate to
let a hotadd of a new pgdat defer the initialisation of that field to
kswapd starting for the new node.

Can you try this? It's build/boot tested only, no hotplug testing.

---8<---
mm, vmscan: prevent kswapd sleeping prematurely due to mismatched classzone_idx -fix

The patch "mm, vmscan: prevent kswapd sleeping prematurely due to mismatched
classzone_idx" has different initial starting conditions when kswapd
is asleep. kswapd initialises it properly when it starts but the patch
initialises kswapd_classzone_idx early and trips on a warning in
free_area_init_node. This patch leaves the kswapd_classzone_idx as zero
and defers to kswapd to initialise it properly when it starts.

This is a fix to the mmotm patch
mm-vmscan-prevent-kswapd-sleeping-prematurely-due-to-mismatched-classzone_idx.patch

Signed-off-by: Mel Gorman <mgorman@suse.de>

diff --git a/mm/memory_hotplug.c b/mm/memory_hotplug.c
index 2309a7fbec93..76d4745513ee 100644
--- a/mm/memory_hotplug.c
+++ b/mm/memory_hotplug.c
@@ -1214,10 +1214,14 @@ static pg_data_t __ref *hotadd_new_pgdat(int nid, u64 start)
 
 		arch_refresh_nodedata(nid, pgdat);
 	} else {
-		/* Reset the nr_zones, order and classzone_idx before reuse */
+		/*
+		 * Reset the nr_zones, order and classzone_idx before reuse.
+		 * Note that kswapd will init kswapd_classzone_idx properly
+		 * when it starts in the near future.
+		 */
 		pgdat->nr_zones = 0;
 		pgdat->kswapd_order = 0;
-		pgdat->kswapd_classzone_idx = MAX_NR_ZONES;
+		pgdat->kswapd_classzone_idx = 0;
 	}
 
 	/* we can use NODE_DATA(nid) from here */

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
