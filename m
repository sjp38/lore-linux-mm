Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx194.postini.com [74.125.245.194])
	by kanga.kvack.org (Postfix) with SMTP id EFFB86B0071
	for <linux-mm@kvack.org>; Thu,  5 Jul 2012 05:05:58 -0400 (EDT)
Date: Thu, 5 Jul 2012 10:05:54 +0100
From: Mel Gorman <mel@csn.ul.ie>
Subject: Re: [RFC PATCH 0/3 V1] mm: add new migrate type and online_movable
 for hotplug
Message-ID: <20120705090554.GR13141@csn.ul.ie>
References: <1341386778-8002-1-git-send-email-laijs@cn.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <1341386778-8002-1-git-send-email-laijs@cn.fujitsu.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Lai Jiangshan <laijs@cn.fujitsu.com>
Cc: Chris Metcalf <cmetcalf@tilera.com>, Len Brown <lenb@kernel.org>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Andi Kleen <andi@firstfloor.org>, Julia Lawall <julia@diku.dk>, David Howells <dhowells@redhat.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Kay Sievers <kay.sievers@vrfy.org>, Ingo Molnar <mingo@elte.hu>, Paul Gortmaker <paul.gortmaker@windriver.com>, Daniel Kiper <dkiper@net-space.pl>, Andrew Morton <akpm@linux-foundation.org>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, Michal Hocko <mhocko@suse.cz>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Minchan Kim <minchan@kernel.org>, Michal Nazarewicz <mina86@mina86.com>, Marek Szyprowski <m.szyprowski@samsung.com>, Rik van Riel <riel@redhat.com>, Bjorn Helgaas <bhelgaas@google.com>, Christoph Lameter <cl@linux.com>, David Rientjes <rientjes@google.com>, linux-kernel@vger.kernel.org, linux-acpi@vger.kernel.org, linux-mm@kvack.org

On Wed, Jul 04, 2012 at 03:26:15PM +0800, Lai Jiangshan wrote:
> > <SNIP>
> 
> Different from ZONE_MOVABLE: it can be used for any given memroyblock.
> 
> Lai Jiangshan (3):
>   use __rmqueue_smallest when borrow memory from MIGRATE_CMA
>   add MIGRATE_HOTREMOVE type
>   add online_movable
> 
>  arch/tile/mm/init.c            |    2 +-
>  drivers/acpi/acpi_memhotplug.c |    3 +-
>  drivers/base/memory.c          |   24 +++++++----
>  include/linux/memory.h         |    1 +
>  include/linux/memory_hotplug.h |    4 +-
>  include/linux/mmzone.h         |   37 +++++++++++++++++
>  include/linux/page-isolation.h |    2 +-
>  mm/compaction.c                |    6 +-
>  mm/memory-failure.c            |    8 +++-
>  mm/memory_hotplug.c            |   36 +++++++++++++---
>  mm/page_alloc.c                |   86 ++++++++++++++++-----------------------
>  mm/vmstat.c                    |    3 +
>  12 files changed, 136 insertions(+), 76 deletions(-)
> 

I apologise for my crap review of the first patch to date. It was atrociously
bad form and one of the reasons my review was so superficial was because I
was aware of the problem below. It's pretty severe, we've encountered it on
other occasions and it led me to dismiss the series quickly without adequate
explanation or close review when I should have taken the time to explain it.

The reason ZONE_MOVABLE exists is because of page reclaim. MIGRATE_CMA
or any migrate type that is MIGRATE_CMA-like is not understood by reclaim
currently and is not addressed by this series just from looking the diffstat
(no changes to vmscan.c). In low memory situations, it's actually fine
and the system appears to work well. The problem is either when the
MIGRATE_CMA-like area is large and is either completely free or is the
only source of pages that can be reclaimed.

In these cases, MIGRATE_UNMOVABLE and MIGRATE_RECLAIMABLE allocations fail
because their lists and fallback lists are empty. However, if it enters
direct reclaim or wakes kswapd the watermarks are fine and reclaim does
nothing. Depending on implementation details this causes either a loop
or OOM.

Minimally the watermark checks need to take the MIGRATE_CMA area into account
but even then it is still fragile. If kswapd and direct reclaim are forced
to reclaim pages, there is no guarantee they will reclaim pages that are
usable by MIGRATE_UNMOVABLE or MIGRATE_RECLAIMABLE. To handle this you must
either keep reclaiming pages until it works (easy to implement but disruptive
to the system) or scan the LRU lists searching for suitable pages (higher
CPU usage, LRU age disruption, will require the entire zone to be scanned
in the OOM case which will be slow and subject to races and possible false
OOMs). When these situations occur, it is very difficult to debug because it
just looks like a hang and the exact triggering situations will be different.

If the allocation then fails due to insufficient usable memory, the
resulting OOM message will be harder to read because it'll show OOM when
there are plenty of pages free. This can be addressed by clear accounting and
informative messages of course but to be very clear it might be necessary
to walk all the buddy lists to identify how many of the free pages were
MIGRATE_CMA. You could use separate accounting of course but then you have
accounting and memory overhead instead.

In the case of CMA, this issue is less of a problem but it was discussed
before CMA was merged. CMAs use case means that it is not likely to suffer
severely because of the expected size of the region, how its used and how
many slab allocations are expected on the systems it targets. It's far worse
for memory hotplug because if the bulk of your memory is memory hotplugged,
you may not be able to use it for metadata-intensive workloads for example
which will result in bug reports. You could have 90% free memory and
be unable to use any of it because you cannot increase the size of slab
leading to odd corner cases.

ZONE_MOVABLE is not great, but it handles the reclaim issues in a
straight-forward manner, OOM is handled quickly because the whole system
does not have to be scanned to detect the situation and the OOM messages
are easy to read. If you want to replace it with MIGRATE_CMA or
something MIGRATE_CMA-like, you need to take these issues into account
or at the very least explain in detail why it is not an issue.

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
