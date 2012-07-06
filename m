Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx147.postini.com [74.125.245.147])
	by kanga.kvack.org (Postfix) with SMTP id BA9BC6B0074
	for <linux-mm@kvack.org>; Fri,  6 Jul 2012 09:50:14 -0400 (EDT)
Date: Fri, 6 Jul 2012 08:50:09 -0500 (CDT)
From: Christoph Lameter <cl@linux.com>
Subject: Re: [RFC PATCH 1/4] mm: introduce a safer interface to check whether
 a page is managed by SLxB
In-Reply-To: <4FF693F6.8070505@huawei.com>
Message-ID: <alpine.DEB.2.00.1207060841001.26441@router.home>
References: <1341287837-7904-1-git-send-email-jiang.liu@huawei.com> <alpine.DEB.2.00.1207050942540.4984@router.home> <4FF5B909.30409@gmail.com> <alpine.DEB.2.00.1207051229490.8670@router.home> <4FF693F6.8070505@huawei.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jiang Liu <jiang.liu@huawei.com>
Cc: Jiang Liu <liuj97@gmail.com>, Pekka Enberg <penberg@kernel.org>, Matt Mackall <mpm@selenic.com>, Mel Gorman <mgorman@suse.de>, Yinghai Lu <yinghai@kernel.org>, Tony Luck <tony.luck@intel.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, David Rientjes <rientjes@google.com>, Minchan Kim <minchan@kernel.org>, Keping Chen <chenkeping@huawei.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Fri, 6 Jul 2012, Jiang Liu wrote:

> 	Originally the patch is aimed to fix an issue encountered when
> hot-removing a hot-added memory device. Currently memory hotplug is only
> supported with SPARSE memory model. After offlining all pages of a memory
> section, we need to free resources used by "struct mem_section" itself.
> That is to free section_mem_map and pageblock_flags. For memory section
> created at boot time, section_mem_map and pageblock_flags are allocated
> from bootmem. For memory section created at runtime, section_mem_map
> and pageblock_flags are allocated from slab. So when freeing these
> resources, we use PageSlab() to tell whether there are allocated from slab.
> So free_section_usemap() has following code snippet.
> {
>         usemap_page = virt_to_page(usemap);
>         /*
>          * Check to see if allocation came from hot-plug-add
>          */
>         if (PageSlab(usemap_page)) {

Change this to PageSlab(usemap_page) || PageCompound(usemap_page) and then
the code segment will work. Fallback to the page allocator always implied
the use of compound pages. It would be cleaner if memory hotplug had an
indicator which allocation mechanism was used and would use the
corresponding free action. Slab allocators could put multiple objects into
the slab page (if the structures are sufficiently small). So this is not
that good of a solution.


> 	And when fixing this issue, we found some other usages of PageSlab() may
> have the same issue. For example:
> 	1) /proc/kpageflags and /proc/kpagecount may return incorrect result for
> pages allocated by slab.

Ok then the compound page handling is broken in those.

> 	2) DRBD has following comments. At first glance, it seems that it's
> 	dangerous if PageSlab() to return false for pages allocated by slab.

Again the pages that do not have PageSlab set were not allocated using a
slab allocator. They were allocated by calls to the page allocator.

> 	(With more thinking, the comments is a little out of date because now
> 	put_page/get_page already correctly handle compound pages, so it should
> 	be OK to send pages allocated from slab.)

AFAICT they always handled compound pages correctly.

> 	3) show_mem() on ARM and unicore32 reports much less pages used by slab
> 	if SLUB/SLOB is used instead of SLAB because SLUB/SLOB doesn't mark big
> 	compound pages with PG_slab flag.

Right. That is because SLUB/SLOB lets the page allocator directly
allocator large structures where it would not make sense to use the slab
allocators. The main purpose of the slab allocators is to allocate
objects in fractions of pages. This does not seem to be a use case for
slab objects. Maybe it would be better to directly call the page allocator
for your large structures?

> 	For example, if the memory backing a "struct resource" structure is
> allocated from bootmem, __release_region() shouldn't free the memory into
> slab allocator, otherwise it will trigger panic as below. This issue is
> reproducible when hot-removing a memory device present at boot time on x86
> platforms. On x86 platforms, e820_reserve_resources() allocates bootmem for
> all physical memory resources present at boot time. Later when those memory
> devices are hot-removed, __release_region() will try to free  memory from
> bootmem into slab, so trigger the panic. And a proposed fix is:

Working out how a certain memory structure was allocated could be most
easily done by setting a flag somewhere instead of checking the page flags
of a page that may potentially include multiple slab objects.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
