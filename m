Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl1-f200.google.com (mail-pl1-f200.google.com [209.85.214.200])
	by kanga.kvack.org (Postfix) with ESMTP id 4EBDF6B4BD8
	for <linux-mm@kvack.org>; Wed, 28 Nov 2018 02:52:51 -0500 (EST)
Received: by mail-pl1-f200.google.com with SMTP id a9so25238436pla.2
        for <linux-mm@kvack.org>; Tue, 27 Nov 2018 23:52:51 -0800 (PST)
Received: from mx0a-001b2d01.pphosted.com (mx0a-001b2d01.pphosted.com. [148.163.156.1])
        by mx.google.com with ESMTPS id s27si5340129pgm.501.2018.11.27.23.52.49
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 27 Nov 2018 23:52:49 -0800 (PST)
Received: from pps.filterd (m0098409.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.22/8.16.0.22) with SMTP id wAS7mgDl112314
	for <linux-mm@kvack.org>; Wed, 28 Nov 2018 02:52:49 -0500
Received: from e06smtp02.uk.ibm.com (e06smtp02.uk.ibm.com [195.75.94.98])
	by mx0a-001b2d01.pphosted.com with ESMTP id 2p1hp5k873-1
	(version=TLSv1.2 cipher=AES256-GCM-SHA384 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Wed, 28 Nov 2018 02:52:48 -0500
Received: from localhost
	by e06smtp02.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <rppt@linux.ibm.com>;
	Wed, 28 Nov 2018 07:52:46 -0000
Date: Wed, 28 Nov 2018 09:52:38 +0200
From: Mike Rapoport <rppt@linux.ibm.com>
Subject: Re: [PATCH v2 3/5] mm, memory_hotplug: Move zone/pages handling to
 offline stage
References: <20181127162005.15833-1-osalvador@suse.de>
 <20181127162005.15833-4-osalvador@suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20181127162005.15833-4-osalvador@suse.de>
Message-Id: <20181128075238.GD14414@rapoport-lnx>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Oscar Salvador <osalvador@suse.de>
Cc: akpm@linux-foundation.org, mhocko@suse.com, dan.j.williams@intel.com, pavel.tatashin@microsoft.com, jglisse@redhat.com, Jonathan.Cameron@huawei.com, rafael@kernel.org, david@redhat.com, linux-mm@kvack.org, Oscar Salvador <osalvador@suse.com>

On Tue, Nov 27, 2018 at 05:20:03PM +0100, Oscar Salvador wrote:
> From: Oscar Salvador <osalvador@suse.com>
> 
> The current implementation accesses pages during hot-remove
> stage in order to get the zone linked to this memory-range.
> We use that zone for a) check if the zone is ZONE_DEVICE and
> b) to shrink the zone's spanned pages.
> 
> Accessing pages during this stage is problematic, as we might be
> accessing pages that were not initialized if we did not get to
> online the memory before removing it.
> 
> The only reason to check for ZONE_DEVICE in __remove_pages
> is to bypass the call to release_mem_region_adjustable(),
> since these regions are removed with devm_release_mem_region.
> 
> With patch#2, this is no longer a problem so we can safely
> call release_mem_region_adjustable().
> release_mem_region_adjustable() will spot that the region
> we are trying to remove was acquired by means of
> devm_request_mem_region, and will back off safely.
> 
> This allows us to remove all zone-related operations from
> hot-remove stage.
> 
> Because of this, zone's spanned pages are shrinked during
> the offlining stage in shrink_zone_pgdat().
> It would have been great to decrease also the spanned page
> for the node there, but we need them in try_offline_node().
> So we still decrease spanned pages for the node in the hot-remove
> stage.
> 
> The only particularity is that now
> find_smallest_section_pfn/find_biggest_section_pfn, when called from
> shrink_zone_span, will now check for online sections and not
> valid sections instead.
> To make this work with devm/HMM code, we need to call offline_mem_sections
> and online_mem_sections in that code path when we are adding memory.
> 
> Signed-off-by: Oscar Salvador <osalvador@suse.de>
> ---
>  arch/powerpc/mm/mem.c          | 11 +----
>  arch/sh/mm/init.c              |  4 +-
>  arch/x86/mm/init_32.c          |  3 +-
>  arch/x86/mm/init_64.c          |  8 +---
>  include/linux/memory_hotplug.h |  8 ++--
>  kernel/memremap.c              | 14 +++++--
>  mm/memory_hotplug.c            | 95 ++++++++++++++++++++++++------------------
>  mm/sparse.c                    |  4 +-
>  8 files changed, 76 insertions(+), 71 deletions(-)
 
[ ... ]
 
>  /**
> - * __remove_pages() - remove sections of pages from a zone
> - * @zone: zone from which pages need to be removed
> + * __remove_pages() - remove sections of pages from a nid
> + * @nid: nid from which pages belong to

Nit: the description sounds a bit awkward.
Why not to keep the original one with s/zone/node/?

>   * @phys_start_pfn: starting pageframe (must be aligned to start of a section)
>   * @nr_pages: number of pages to remove (must be multiple of section size)
>   * @altmap: alternative device page map or %NULL if default memmap is used
> @@ -547,35 +566,28 @@ static int __remove_section(struct zone *zone, struct mem_section *ms,
>   * sure that pages are marked reserved and zones are adjust properly by
>   * calling offline_pages().
>   */

-- 
Sincerely yours,
Mike.
