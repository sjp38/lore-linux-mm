Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f178.google.com (mail-wi0-f178.google.com [209.85.212.178])
	by kanga.kvack.org (Postfix) with ESMTP id 5A4916B025B
	for <linux-mm@kvack.org>; Thu, 30 Jul 2015 10:46:00 -0400 (EDT)
Received: by wibud3 with SMTP id ud3so71641656wib.0
        for <linux-mm@kvack.org>; Thu, 30 Jul 2015 07:45:59 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id mi6si19497947wic.25.2015.07.30.07.45.58
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Thu, 30 Jul 2015 07:45:58 -0700 (PDT)
Date: Thu, 30 Jul 2015 15:45:54 +0100
From: Mel Gorman <mgorman@suse.de>
Subject: Re: [PATCHv1] mm: always initialize pages as reserved to fix memory
 hotplug
Message-ID: <20150730144554.GS2561@suse.de>
References: <1438265083-31208-1-git-send-email-david.vrabel@citrix.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <1438265083-31208-1-git-send-email-david.vrabel@citrix.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Vrabel <david.vrabel@citrix.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Robin Holt <holt@sgi.com>, Nathan Zimmer <nzimmer@sgi.com>

On Thu, Jul 30, 2015 at 03:04:43PM +0100, David Vrabel wrote:
> Commit 92923ca3aacef63c92dc297a75ad0c6dfe4eab37 (mm: meminit: only set
> page reserved in the memblock region) breaks memory hotplug because pages
> within newly added sections are not marked as reserved as required by
> the memory hotplug driver.

I don't have access to a large machine at the moment to verify and won't
have until Monday at the earliest but I think that will bust deferred
initialisation.

Why not either SetPageReserved from mem hotplug driver? It might be neater
to remove the PageReserved check from online_pages_range() but then care
would have to be taken to ensure that invalid PFNs within section that
have no memory backing them were properly reserved.  This is an untested,
uncompiled version of the first suggestion

diff --git a/mm/memory_hotplug.c b/mm/memory_hotplug.c
index 26fbba7d888f..003dbe4b060d 100644
--- a/mm/memory_hotplug.c
+++ b/mm/memory_hotplug.c
@@ -446,7 +446,7 @@ static int __meminit __add_zone(struct zone *zone, unsigned long phys_start_pfn)
 	int nr_pages = PAGES_PER_SECTION;
 	int nid = pgdat->node_id;
 	int zone_type;
-	unsigned long flags;
+	unsigned long flags, pfn;
 	int ret;
 
 	zone_type = zone - pgdat->node_zones;
@@ -461,6 +461,14 @@ static int __meminit __add_zone(struct zone *zone, unsigned long phys_start_pfn)
 	pgdat_resize_unlock(zone->zone_pgdat, &flags);
 	memmap_init_zone(nr_pages, nid, zone_type,
 			 phys_start_pfn, MEMMAP_HOTPLUG);
+
+	/* online_page_range is called later and expects pages reserved */
+	for (pfn = phys_start_pfn; pfn < phys_start_pfn + nr_pages; pfn++) {
+		if (!pfn_valid(pfn))
+			continue;
+
+		SetPageReserved(pfn_to_page(pfn));
+	}
 	return 0;
 }
 
-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
