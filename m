Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f72.google.com (mail-wm0-f72.google.com [74.125.82.72])
	by kanga.kvack.org (Postfix) with ESMTP id 0DCA46B0313
	for <linux-mm@kvack.org>; Fri, 16 Jun 2017 04:46:00 -0400 (EDT)
Received: by mail-wm0-f72.google.com with SMTP id h64so2856289wmg.0
        for <linux-mm@kvack.org>; Fri, 16 Jun 2017 01:46:00 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id c85si2430160wmi.45.2017.06.16.01.45.58
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Fri, 16 Jun 2017 01:45:58 -0700 (PDT)
Date: Fri, 16 Jun 2017 10:45:55 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH 11/14] mm, memory_hotplug: do not associate hotadded
 memory to zones until online
Message-ID: <20170616084555.GD30580@dhcp22.suse.cz>
References: <20170515085827.16474-1-mhocko@kernel.org>
 <20170515085827.16474-12-mhocko@kernel.org>
 <20170616081142.GA3871@WeideMacBook-Pro.local>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170616081142.GA3871@WeideMacBook-Pro.local>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Wei Yang <richard.weiyang@gmail.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, Mel Gorman <mgorman@suse.de>, Vlastimil Babka <vbabka@suse.cz>, Andrea Arcangeli <aarcange@redhat.com>, Jerome Glisse <jglisse@redhat.com>, Reza Arbab <arbab@linux.vnet.ibm.com>, Yasuaki Ishimatsu <yasu.isimatu@gmail.com>, qiuxishi@huawei.com, Kani Toshimitsu <toshi.kani@hpe.com>, slaoub@gmail.com, Joonsoo Kim <js1304@gmail.com>, Andi Kleen <ak@linux.intel.com>, David Rientjes <rientjes@google.com>, Daniel Kiper <daniel.kiper@oracle.com>, Igor Mammedov <imammedo@redhat.com>, Vitaly Kuznetsov <vkuznets@redhat.com>, LKML <linux-kernel@vger.kernel.org>, Dan Williams <dan.j.williams@intel.com>, Heiko Carstens <heiko.carstens@de.ibm.com>, Martin Schwidefsky <schwidefsky@de.ibm.com>

On Fri 16-06-17 16:11:42, Wei Yang wrote:
> Well, I love this patch a lot. We don't need to put the hotadd memory in one
> zone and move it to another. This looks great!
> 
> On Mon, May 15, 2017 at 10:58:24AM +0200, Michal Hocko wrote:
> >From: Michal Hocko <mhocko@suse.com>
> >
> [...]
> +
> >+void move_pfn_range_to_zone(struct zone *zone,
> >+		unsigned long start_pfn, unsigned long nr_pages)
> >+{
> >+	struct pglist_data *pgdat = zone->zone_pgdat;
> >+	int nid = pgdat->node_id;
> >+	unsigned long flags;
> >+	unsigned long i;
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
> 
> memmap_init_zone()->__init_single_page()->set_page_links()
> 
> Do I miss something that you call set_page_links() explicitly here?

I guess you are right. Not sure why I've done this explicitly. I've most
probably just missed that. Could you post a patch that removes the for
loop.

Thanks!
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
