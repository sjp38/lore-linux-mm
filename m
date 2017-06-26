Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f197.google.com (mail-wr0-f197.google.com [209.85.128.197])
	by kanga.kvack.org (Postfix) with ESMTP id 075396B0292
	for <linux-mm@kvack.org>; Mon, 26 Jun 2017 01:38:25 -0400 (EDT)
Received: by mail-wr0-f197.google.com with SMTP id 77so27233523wrb.11
        for <linux-mm@kvack.org>; Sun, 25 Jun 2017 22:38:24 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id l50si11302211wrc.193.2017.06.25.22.38.23
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Sun, 25 Jun 2017 22:38:23 -0700 (PDT)
Date: Mon, 26 Jun 2017 07:38:19 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH 11/14] mm, memory_hotplug: do not associate hotadded
 memory to zones until online
Message-ID: <20170626053819.GB31972@dhcp22.suse.cz>
References: <20170515085827.16474-1-mhocko@kernel.org>
 <20170515085827.16474-12-mhocko@kernel.org>
 <20170625001413.GA43522@WeideMacBook-Pro.local>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <20170625001413.GA43522@WeideMacBook-Pro.local>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Wei Yang <richard.weiyang@gmail.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, Mel Gorman <mgorman@suse.de>, Vlastimil Babka <vbabka@suse.cz>, Andrea Arcangeli <aarcange@redhat.com>, Jerome Glisse <jglisse@redhat.com>, Reza Arbab <arbab@linux.vnet.ibm.com>, Yasuaki Ishimatsu <yasu.isimatu@gmail.com>, qiuxishi@huawei.com, Kani Toshimitsu <toshi.kani@hpe.com>, slaoub@gmail.com, Joonsoo Kim <js1304@gmail.com>, Andi Kleen <ak@linux.intel.com>, David Rientjes <rientjes@google.com>, Daniel Kiper <daniel.kiper@oracle.com>, Igor Mammedov <imammedo@redhat.com>, Vitaly Kuznetsov <vkuznets@redhat.com>, LKML <linux-kernel@vger.kernel.org>, Dan Williams <dan.j.williams@intel.com>, Heiko Carstens <heiko.carstens@de.ibm.com>, Martin Schwidefsky <schwidefsky@de.ibm.com>

On Sun 25-06-17 08:14:13, Wei Yang wrote:
> On Mon, May 15, 2017 at 10:58:24AM +0200, Michal Hocko wrote:
> >From: Michal Hocko <mhocko@suse.com>
> >
> [...]
> >+void move_pfn_range_to_zone(struct zone *zone,
> >+		unsigned long start_pfn, unsigned long nr_pages)
> >+{
> >+	struct pglist_data *pgdat = zone->zone_pgdat;
> >+	int nid = pgdat->node_id;
> >+	unsigned long flags;
> >+	unsigned long i;
> 
> This is an unused variable:
> 
>   mm/memory_hotplug.c: In function a??move_pfn_range_to_zonea??:
>   mm/memory_hotplug.c:895:16: warning: unused variable a??ia?? [-Wunused-variable]
> 
> Do you suggest me to write a patch or you would fix it in your later rework?

Please send a fix for your
http://lkml.kernel.org/r/20170616092335.5177-2-richard.weiyang@gmail.com
Andrew will fold it into that patch.

> 
> >+
> >+	if (zone_is_empty(zone))
> >+		init_currently_empty_zone(zone, start_pfn, nr_pages);
> >+
> >+	clear_zone_contiguous(zone);
> >+
> >+	/* TODO Huh pgdat is irqsave while zone is not. It used to be like that before */
> >+	pgdat_resize_lock(pgdat, &flags);
> >+	zone_span_writelock(zone);
> >+	resize_zone_range(zone, start_pfn, nr_pages);
> >+	zone_span_writeunlock(zone);
> >+	resize_pgdat_range(pgdat, start_pfn, nr_pages);
> >+	pgdat_resize_unlock(pgdat, &flags);
> >+
> >+	/*
> >+	 * TODO now we have a visible range of pages which are not associated
> >+	 * with their zone properly. Not nice but set_pfnblock_flags_mask
> >+	 * expects the zone spans the pfn range. All the pages in the range
> >+	 * are reserved so nobody should be touching them so we should be safe
> >+	 */
> >+	memmap_init_zone(nr_pages, nid, zone_idx(zone), start_pfn, MEMMAP_HOTPLUG);
> >+	for (i = 0; i < nr_pages; i++) {
> >+		unsigned long pfn = start_pfn + i;
> >+		set_page_links(pfn_to_page(pfn), zone_idx(zone), nid, pfn);
> > 	}
> > 
> >2.11.0
> 
> -- 
> Wei Yang
> Help you, Help me



-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
