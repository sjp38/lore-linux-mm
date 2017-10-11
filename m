Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f199.google.com (mail-wr0-f199.google.com [209.85.128.199])
	by kanga.kvack.org (Postfix) with ESMTP id 35A416B0253
	for <linux-mm@kvack.org>; Wed, 11 Oct 2017 02:51:30 -0400 (EDT)
Received: by mail-wr0-f199.google.com with SMTP id 22so349407wrb.9
        for <linux-mm@kvack.org>; Tue, 10 Oct 2017 23:51:30 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id v21si11701643wra.442.2017.10.10.23.51.28
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 10 Oct 2017 23:51:28 -0700 (PDT)
Date: Wed, 11 Oct 2017 08:51:23 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH 1/2] mm, memory_hotplug: do not fail offlining too early
Message-ID: <20171011065123.e7jvoftmtso3vcha@dhcp22.suse.cz>
References: <20170918070834.13083-1-mhocko@kernel.org>
 <20170918070834.13083-2-mhocko@kernel.org>
 <87bmlfw6mj.fsf@concordia.ellerman.id.au>
 <20171010122726.6jrfdzkscwge6gez@dhcp22.suse.cz>
 <87infmz9xd.fsf@concordia.ellerman.id.au>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <87infmz9xd.fsf@concordia.ellerman.id.au>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michael Ellerman <mpe@ellerman.id.au>
Cc: Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Reza Arbab <arbab@linux.vnet.ibm.com>, Yasuaki Ishimatsu <yasu.isimatu@gmail.com>, qiuxishi@huawei.com, Igor Mammedov <imammedo@redhat.com>, Vitaly Kuznetsov <vkuznets@redhat.com>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, Vlastimil Babka <vbabka@suse.cz>

On Wed 11-10-17 13:37:50, Michael Ellerman wrote:
> Michal Hocko <mhocko@kernel.org> writes:
> 
> > On Tue 10-10-17 23:05:08, Michael Ellerman wrote:
> >> Michal Hocko <mhocko@kernel.org> writes:
> >> 
> >> > From: Michal Hocko <mhocko@suse.com>
> >> >
> >> > Memory offlining can fail just too eagerly under a heavy memory pressure.
> >> >
> >> > [ 5410.336792] page:ffffea22a646bd00 count:255 mapcount:252 mapping:ffff88ff926c9f38 index:0x3
> >> > [ 5410.336809] flags: 0x9855fe40010048(uptodate|active|mappedtodisk)
> >> > [ 5410.336811] page dumped because: isolation failed
> >> > [ 5410.336813] page->mem_cgroup:ffff8801cd662000
> >> > [ 5420.655030] memory offlining [mem 0x18b580000000-0x18b5ffffffff] failed
> >> >
> >> > Isolation has failed here because the page is not on LRU. Most probably
> >> > because it was on the pcp LRU cache or it has been removed from the LRU
> >> > already but it hasn't been freed yet. In both cases the page doesn't look
> >> > non-migrable so retrying more makes sense.
> >> 
> >> This breaks offline for me.
> >> 
> >> Prior to this commit:
> >>   /sys/devices/system/memory/memory0# time echo 0 > online
> >>   -bash: echo: write error: Device or resource busy
> >>   
> >>   real	0m0.001s
> >>   user	0m0.000s
> >>   sys	0m0.001s
> >> 
> >> After:
> >>   /sys/devices/system/memory/memory0# time echo 0 > online
> >>   -bash: echo: write error: Device or resource busy
> >>   
> >>   real	2m0.009s
> >>   user	0m0.000s
> >>   sys	1m25.035s
> >> 
> >> 
> >> There's no way that block can be removed, it contains the kernel text,
> >> so it should instantly fail - which it used to.
> >
> > OK, that means that start_isolate_page_range should have failed but it
> > hasn't for some reason. I strongly suspect has_unmovable_pages is doing
> > something wrong. Is the kernel text marked somehow? E.g. PageReserved?
> 
> I'm not sure how the text is marked, will have to dig into that.
> 
> > In other words, does the diff below helps?
> 
> No that doesn't help.

This is really strange! As you write in other email the page is
reserved. That means that some of the earlier checks 
	if (zone_idx(zone) == ZONE_MOVABLE)
		return false;
	mt = get_pageblock_migratetype(page);
	if (mt == MIGRATE_MOVABLE || is_migrate_cma(mt))
		return false;
has bailed out early. I would be quite surprised if the kernel text was
sitting in the zone movable. The migrate type check is more fishy
AFAICS. I can imagine that the kernel text can share the movable or CMA
mt block. I am not really familiar with this function but it looks
suspicious. So does it help to remove this check?
--- 
diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 3badcedf96a7..5b4d85ae445c 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -7355,9 +7355,6 @@ bool has_unmovable_pages(struct zone *zone, struct page *page, int count,
 	 */
 	if (zone_idx(zone) == ZONE_MOVABLE)
 		return false;
-	mt = get_pageblock_migratetype(page);
-	if (mt == MIGRATE_MOVABLE || is_migrate_cma(mt))
-		return false;
 
 	pfn = page_to_pfn(page);
 	for (found = 0, iter = 0; iter < pageblock_nr_pages; iter++) {
@@ -7368,6 +7365,9 @@ bool has_unmovable_pages(struct zone *zone, struct page *page, int count,
 
 		page = pfn_to_page(check);
 
+		if (PageReserved(page))
+			return true;
+
 		/*
 		 * Hugepages are not in LRU lists, but they're movable.
 		 * We need not scan over tail pages bacause we don't

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
