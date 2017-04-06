Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f200.google.com (mail-wr0-f200.google.com [209.85.128.200])
	by kanga.kvack.org (Postfix) with ESMTP id 02B786B0411
	for <linux-mm@kvack.org>; Thu,  6 Apr 2017 08:46:06 -0400 (EDT)
Received: by mail-wr0-f200.google.com with SMTP id t30so5991493wrc.15
        for <linux-mm@kvack.org>; Thu, 06 Apr 2017 05:46:05 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id d3si2902720wmf.12.2017.04.06.05.46.03
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 06 Apr 2017 05:46:04 -0700 (PDT)
Date: Thu, 6 Apr 2017 14:46:00 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH 5/6] mm, memory_hotplug: do not associate hotadded memory
 to zones until online
Message-ID: <20170406124600.GK5497@dhcp22.suse.cz>
References: <20170330115454.32154-1-mhocko@kernel.org>
 <20170330115454.32154-6-mhocko@kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170330115454.32154-6-mhocko@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, Vlastimil Babka <vbabka@suse.cz>, Andrea Arcangeli <aarcange@redhat.com>, Reza Arbab <arbab@linux.vnet.ibm.com>, Yasuaki Ishimatsu <yasu.isimatu@gmail.com>, Tang Chen <tangchen@cn.fujitsu.com>, qiuxishi@huawei.com, Kani Toshimitsu <toshi.kani@hpe.com>, slaoub@gmail.com, Joonsoo Kim <js1304@gmail.com>, Andi Kleen <ak@linux.intel.com>, Zhang Zhen <zhenzhang.zhang@huawei.com>, David Rientjes <rientjes@google.com>, Daniel Kiper <daniel.kiper@oracle.com>, Igor Mammedov <imammedo@redhat.com>, Vitaly Kuznetsov <vkuznets@redhat.com>, LKML <linux-kernel@vger.kernel.org>, Dan Williams <dan.j.williams@gmail.com>, Heiko Carstens <heiko.carstens@de.ibm.com>, Lai Jiangshan <laijs@cn.fujitsu.com>, Martin Schwidefsky <schwidefsky@de.ibm.com>

On Thu 30-03-17 13:54:53, Michal Hocko wrote:
[...]
> +static struct zone * __meminit move_pfn_range(int online_type, int nid,
> +		unsigned long start_pfn, unsigned long nr_pages)
> +{
> +	struct pglist_data *pgdat = NODE_DATA(nid);
> +	struct zone *zone = &pgdat->node_zones[ZONE_NORMAL];
> +
> +	if (online_type == MMOP_ONLINE_KEEP) {
> +		/*
> +		 * MMOP_ONLINE_KEEP inherits the current zone which is
> +		 * ZONE_NORMAL by default but we might be within ZONE_MOVABLE
> +		 * already.
> +		 */
> +		if (allow_online_pfn_range(nid, start_pfn, nr_pages, MMOP_ONLINE_MOVABLE))
> +			zone = &pgdat->node_zones[ZONE_MOVABLE];
> +	} else if (online_type == MMOP_ONLINE_MOVABLE) {
> +		zone = &pgdat->node_zones[ZONE_MOVABLE];
>  	}
>  
> -	*zone_shift = target - idx;
> -	return true;
> +	move_pfn_range_to_zone(zone, start_pfn, nr_pages);
> +	return zone;
>  }

I got the MMOP_ONLINE_KEEP wrong here. Relying on allow_online_pfn_range
is wrong because that would lead to MMOP_ONLINE_MOVABLE by when there is
no ZONE_NORMAL while I believe we should online_kernel in that case.
Well the semantic of MMOP_ONLINE_KEEP is rathe fuzzy to me but I guess
it make some sense to online movable only when explicitly state or
_within_ and existing ZONE_MOVABLE. The following will fix this. I will
fold it into this patch.
---
diff --git a/include/linux/mmzone.h b/include/linux/mmzone.h
index 7c4fef1aba84..0f8816fd0b52 100644
--- a/include/linux/mmzone.h
+++ b/include/linux/mmzone.h
@@ -531,6 +531,20 @@ static inline bool zone_is_empty(struct zone *zone)
 }
 
 /*
+ * Return true if [start_pfn, start_pfn + nr_pages) range has a non-mpty
+ * intersection with the given zone
+ */
+static inline bool zone_intersects(struct zone *zone,
+		unsigned long start_pfn, unsigned long nr_pages)
+{
+	if (zone->zone_start_pfn <= start_pfn && start_pfn < zone_end_pfn(zone))
+		return true;
+	if (start_pfn + nr_pages > start_pfn && !zone_is_empty(zone))
+		return true;
+	return false;
+}
+
+/*
  * The "priority" of VM scanning is how much of the queues we will scan in one
  * go. A value of 12 for DEF_PRIORITY implies that we will scan 1/4096th of the
  * queues ("queue_length >> 12") during an aging round.
diff --git a/mm/memory_hotplug.c b/mm/memory_hotplug.c
index 4f80abdc2047..2ff988f42377 100644
--- a/mm/memory_hotplug.c
+++ b/mm/memory_hotplug.c
@@ -934,13 +934,14 @@ static struct zone * __meminit move_pfn_range(int online_type, int nid,
 	struct zone *zone = &pgdat->node_zones[ZONE_NORMAL];
 
 	if (online_type == MMOP_ONLINE_KEEP) {
+		struct zone *movable_zone = &pgdat->node_zones[ZONE_MOVABLE];
 		/*
 		 * MMOP_ONLINE_KEEP inherits the current zone which is
 		 * ZONE_NORMAL by default but we might be within ZONE_MOVABLE
 		 * already.
 		 */
-		if (allow_online_pfn_range(nid, start_pfn, nr_pages, MMOP_ONLINE_MOVABLE))
-			zone = &pgdat->node_zones[ZONE_MOVABLE];
+		if (zone_intersects(movable_zone, start_pfn, nr_pages))
+			zone = movable_zone;
 	} else if (online_type == MMOP_ONLINE_MOVABLE) {
 		zone = &pgdat->node_zones[ZONE_MOVABLE];
 	}
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
