Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id 621E06B004A
	for <linux-mm@kvack.org>; Thu,  2 Sep 2010 10:19:29 -0400 (EDT)
Received: by vws16 with SMTP id 16so507971vws.14
        for <linux-mm@kvack.org>; Thu, 02 Sep 2010 07:19:27 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20100902131855.GC10265@tiehlicka.suse.cz>
References: <20100822004232.GA11007@localhost>
	<20100823092246.GA25772@tiehlicka.suse.cz>
	<20100831141942.GA30353@localhost>
	<20100901121951.GC6663@tiehlicka.suse.cz>
	<20100901124138.GD6663@tiehlicka.suse.cz>
	<20100902144500.a0d05b08.kamezawa.hiroyu@jp.fujitsu.com>
	<20100902082829.GA10265@tiehlicka.suse.cz>
	<20100902180343.f4232c6e.kamezawa.hiroyu@jp.fujitsu.com>
	<20100902092454.GA17971@tiehlicka.suse.cz>
	<AANLkTi=cLzRGPCc3gCubtU7Ggws7yyAK5c7tp4iocv6u@mail.gmail.com>
	<20100902131855.GC10265@tiehlicka.suse.cz>
Date: Thu, 2 Sep 2010 23:19:18 +0900
Message-ID: <AANLkTikYt3Hu_XeNuwAa9KjzfWgpC8cNen6q657ZKmm-@mail.gmail.com>
Subject: Re: [PATCH] Make is_mem_section_removable more conformable with
 offlining code
From: Hiroyuki Kamezawa <kamezawa.hiroyuki@gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
To: Michal Hocko <mhocko@suse.cz>
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Wu Fengguang <fengguang.wu@intel.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, "Kleen, Andi" <andi.kleen@intel.com>, Haicheng Li <haicheng.li@linux.intel.com>, Christoph Lameter <cl@linux-foundation.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Mel Gorman <mel@linux.vnet.ibm.com>
List-ID: <linux-mm.kvack.org>

2010/9/2 Michal Hocko <mhocko@suse.cz>:
> What about this? Just compile tested.
>
> ---
> From a2aaeafbaeb5b195b699df25060128b9e547949c Mon Sep 17 00:00:00 2001
> From: Michal Hocko <mhocko@suse.cz>
> Date: Fri, 20 Aug 2010 15:39:16 +0200
> Subject: [PATCH] Make is_mem_section_removable more conformable with offl=
ining code
>
> Currently is_mem_section_removable checks whether each pageblock from
> the given pfn range is of MIGRATE_MOVABLE type or if it is free. If both
> are false then the range is considered non removable.
>
> On the other hand, offlining code (more specifically
> set_migratetype_isolate) doesn't care whether a page is free and instead
> it just checks the migrate type of the page and whether the page's zone
> is movable.
>
> This can lead into a situation when we can mark a node as not removable
> just because a pageblock is MIGRATE_RESERVE and it is not free but still
> movable.
>
> Let's make a common helper is_page_removable which unifies both tests
> at one place.
>
> Do not rely on any of MIGRATE_* types as all others than MIGRATE_MOVABLE
> may be tricky. MIGRATE_RESERVE can be anything that just happened to
> fallback to that allocation, MIGRATE_RECLAIMABLE can be unmovable
> because slab (or what ever) has this page currently in use. If we tried
> to remove those pages and the isolation failed then those blocks
> would get to the MIRAGTE_MOVABLE list and we will end up with the
> unmovable pages in the movable zone.
>
> Let's, instead, check just whether a pageblock contains free or LRU
> pages.
>
> Signed-off-by: Michal Hocko <mhocko@suse.cz>
> ---
> =A0include/linux/mmzone.h | =A0 24 ++++++++++++++++++++++++
> =A0mm/memory_hotplug.c =A0 =A0| =A0 19 +------------------
> =A0mm/page_alloc.c =A0 =A0 =A0 =A0| =A0 =A05 +----
> =A03 files changed, 26 insertions(+), 22 deletions(-)
>
> diff --git a/include/linux/mmzone.h b/include/linux/mmzone.h
> index 6e6e626..0bd941b 100644
> --- a/include/linux/mmzone.h
> +++ b/include/linux/mmzone.h
> @@ -669,6 +669,30 @@ unsigned long __init node_memmap_size_bytes(int, uns=
igned long, unsigned long);
> =A0*/
> =A0#define zone_idx(zone) =A0 =A0 =A0 =A0 ((zone) - (zone)->zone_pgdat->n=
ode_zones)
>
> +#ifdef CONFIG_MEMORY_HOTREMOVE
> +/*
> + * A free or LRU pages block are removable
> + * Do not use MIGRATE_MOVABLE because it can be insufficient and
> + * other MIGRATE types are tricky.
> + */
> +static inline bool is_page_removable(struct page *page)
> +{
> + =A0 =A0 =A0 int page_block =3D 1 << pageblock_order;
> + =A0 =A0 =A0 for (page_block > 0) {

for ?

> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (PageBuddy(page)) {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 page_block -=3D page_order(=
page);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 }else if (PageLRU(page))
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 page_block--;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 else
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 return false;
> + =A0 =A0 =A0 }
> +
> + =A0 =A0 =A0 return true;
> +}

Hmm. above for is intending to check all pages in the block ?
I'll look into details, tomorrow.

Thanks,
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
