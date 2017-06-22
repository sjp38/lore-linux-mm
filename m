Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f200.google.com (mail-wr0-f200.google.com [209.85.128.200])
	by kanga.kvack.org (Postfix) with ESMTP id 2731D6B0315
	for <linux-mm@kvack.org>; Thu, 22 Jun 2017 14:17:02 -0400 (EDT)
Received: by mail-wr0-f200.google.com with SMTP id u30so6720416wrc.9
        for <linux-mm@kvack.org>; Thu, 22 Jun 2017 11:17:02 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id q64si1919539wmg.118.2017.06.22.11.17.00
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 22 Jun 2017 11:17:00 -0700 (PDT)
Date: Thu, 22 Jun 2017 20:16:57 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH 2/2] mm, memory_hotplug: do not assume ZONE_NORMAL is
 default kernel zone
Message-ID: <20170622181656.GB19563@dhcp22.suse.cz>
References: <20170601083746.4924-1-mhocko@kernel.org>
 <20170601083746.4924-3-mhocko@kernel.org>
 <20170622023243.GA1242@WeideMacBook-Pro.local>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170622023243.GA1242@WeideMacBook-Pro.local>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Wei Yang <richard.weiyang@gmail.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, Mel Gorman <mgorman@suse.de>, Vlastimil Babka <vbabka@suse.cz>, Andrea Arcangeli <aarcange@redhat.com>, Jerome Glisse <jglisse@redhat.com>, Reza Arbab <arbab@linux.vnet.ibm.com>, Yasuaki Ishimatsu <yasu.isimatu@gmail.com>, qiuxishi@huawei.com, Kani Toshimitsu <toshi.kani@hpe.com>, slaoub@gmail.com, Joonsoo Kim <js1304@gmail.com>, Andi Kleen <ak@linux.intel.com>, David Rientjes <rientjes@google.com>, Daniel Kiper <daniel.kiper@oracle.com>, Igor Mammedov <imammedo@redhat.com>, Vitaly Kuznetsov <vkuznets@redhat.com>, Heiko Carstens <heiko.carstens@de.ibm.com>, LKML <linux-kernel@vger.kernel.org>

[Again, please try to trim your quoted response to the minimum]

On Thu 22-06-17 10:32:43, Wei Yang wrote:
> On Thu, Jun 01, 2017 at 10:37:46AM +0200, Michal Hocko wrote:
[...]
> >@@ -938,6 +938,27 @@ void __ref move_pfn_range_to_zone(struct zone *zone,
> > }
> > 
> > /*
> >+ * Returns a default kernel memory zone for the given pfn range.
> >+ * If no kernel zone covers this pfn range it will automatically go
> >+ * to the ZONE_NORMAL.
> >+ */
> >+struct zone *default_zone_for_pfn(int nid, unsigned long start_pfn,
> >+		unsigned long nr_pages)
> >+{
> >+	struct pglist_data *pgdat = NODE_DATA(nid);
> >+	int zid;
> >+
> >+	for (zid = 0; zid <= ZONE_NORMAL; zid++) {
> >+		struct zone *zone = &pgdat->node_zones[zid];
> >+
> >+		if (zone_intersects(zone, start_pfn, nr_pages))
> >+			return zone;
> >+	}
> >+
> >+	return &pgdat->node_zones[ZONE_NORMAL];
> >+}
> 
> Hmm... a corner case jumped into my mind which may invalidate this
> calculation.
> 
> The case is:
> 
> 
>        Zone:         | DMA   | DMA32      | NORMAL       |
>                      v       v            v              v
>        
>        Phy mem:      [           ]     [                  ]
>        
>                      ^           ^     ^                  ^
>        Node:         |   Node0   |     |      Node1       |
>                              A   B     C  D
> 
> 
> The key point is
> 1. There is a hole between Node0 and Node1
> 2. The hole sits in a non-normal zone
> 
> Let's mark the boundary as A, B, C, D. Then we would have
> node0->zone[dma21] = [A, B]
> node1->zone[dma32] = [C, D]
> 
> If we want to hotplug a range in [B, C] on node0, it looks not that bad. While
> if we want to hotplug a range in [B, C] on node1, it will introduce the
> overlapped zone. Because the range [B, C] intersects none of the existing
> zones on node1.
> 
> Do you think this is possible?

Yes, it is possible. I would be much more more surprised if it was real
as well. Fixing that would require to use arch_zone_{lowest,highest}_possible_pfn
which is not available after init section disappears and I am not even
sure we should care. I would rather wait for a real life example of such
a configuration to fix it.
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
