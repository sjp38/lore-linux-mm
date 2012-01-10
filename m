Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx142.postini.com [74.125.245.142])
	by kanga.kvack.org (Postfix) with SMTP id ADFFB6B005C
	for <linux-mm@kvack.org>; Tue, 10 Jan 2012 16:31:12 -0500 (EST)
Received: by yhoo21 with SMTP id o21so23076yho.14
        for <linux-mm@kvack.org>; Tue, 10 Jan 2012 13:31:11 -0800 (PST)
Date: Tue, 10 Jan 2012 13:31:08 -0800 (PST)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH] mm: Fix NULL ptr dereference in __count_immobile_pages
In-Reply-To: <1326213022-11761-1-git-send-email-mhocko@suse.cz>
Message-ID: <alpine.DEB.2.00.1201101326080.10821@chino.kir.corp.google.com>
References: <1326213022-11761-1-git-send-email-mhocko@suse.cz>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Andrea Arcangeli <aarcange@redhat.com>

On Tue, 10 Jan 2012, Michal Hocko wrote:

> This patch fixes the following NULL ptr dereference caused by
> cat /sys/devices/system/memory/memory0/removable:
> 
> Pid: 13979, comm: sed Not tainted 3.0.13-0.5-default #1 IBM BladeCenter LS21 -[7971PAM]-/Server Blade
> RIP: 0010:[<ffffffff810f41f4>]  [<ffffffff810f41f4>] __count_immobile_pages+0x4/0x100
> RSP: 0018:ffff880221c37e48  EFLAGS: 00010246
> RAX: 0000000000000000 RBX: ffffea0000000000 RCX: ffffea0000000000
> RDX: 0000000000000000 RSI: ffffea0000000000 RDI: 0000000000000000
> RBP: 0000000000000000 R08: 0000000000000001 R09: 00000000000146b0
> R10: 0000000000000000 R11: ffffffff81328980 R12: 0000160000000000
> R13: 6db6db6db6db6db7 R14: 0000000000000001 R15: ffffffff81658af0
> FS:  00007fc4e8091700(0000) GS:ffff88023fc80000(0000) knlGS:0000000000000000
> CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
> CR2: 0000000000000698 CR3: 000000023027a000 CR4: 00000000000006e0
> DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
> DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7: 0000000000000400
> Process sed (pid: 13979, threadinfo ffff880221c36000, task ffff88022e788480)
> Stack:
>  ffffea0000000000 ffffea00001c0000 ffffffff810f4324 ffffffff8113e104
>  0000000000000001 0000000000000001 ffff880232a33ac0 ffff880230c25000
>  ffff880232a33b28 ffffffff813289c1 ffff88022e7d7d40 ffffffffffffffed
> Call Trace:
>  [<ffffffff810f4324>] is_pageblock_removable_nolock+0x34/0x40
>  [<ffffffff8113e104>] is_mem_section_removable+0x74/0xf0
>  [<ffffffff813289c1>] show_mem_removable+0x41/0x70
>  [<ffffffff811c053e>] sysfs_read_file+0xfe/0x1c0
>  [<ffffffff81150be7>] vfs_read+0xc7/0x130
>  [<ffffffff81150d53>] sys_read+0x53/0xa0
>  [<ffffffff81448392>] system_call_fastpath+0x16/0x1b
>  [<00007fc4e7bdbea0>] 0x7fc4e7bdbe9f
> Code: 34 00 0f 1f 44 00 00 48 89 ef be 02 00 00 00 e8 f3 f3 ff ff ba 02 00 00 00 48 89 ee 48 89 df e8 53 f0 ff ff eb b9 90 55 89 d5 53
>  2b bf 98 06 00 00 48 89 f3 48 81 ef 00 15 00 00 48 81 ff ff
> 
> We are crashing because we are trying to dereference NULL zone which
> came from pfn=0 (struct page ffffea0000000000). According to the boot
> log this page is marked reserved:
> e820 update range: 0000000000000000 - 0000000000010000 (usable) ==> (reserved)
> 
> and early_node_map confirms that:
> early_node_map[3] active PFN ranges
>     1: 0x00000010 -> 0x0000009c
>     1: 0x00000100 -> 0x000bffa3
>     1: 0x00100000 -> 0x00240000
> 
> The problem is that memory_present works in PAGE_SECTION_MASK aligned
> blocks so the reserved range sneaks into the the section as well. This
> also means that free_area_init_node will not take care of those reserved
> pages and they stay uninitialized.
> 
> When we try to read the removable status we walk through all available
> sections and hope that the zone is valid for all pages in the section.
> But this is not true in this case as the zone and nid are not
> initialized.
> We have only one node in this particular case and it is marked as
> node=1 (rather than 0) and that made the problem visible because
> page_to_nid will return 0 and there are no zones on the node.
> 
> Let's check that the zone is valid and that the given pfn falls into its
> boundaries and mark the section not removable. This might cause some
> false positives, probably, but we do not have any sane way to find out
> whether the page is reserved by the platform or it is just not used for
> whatever other reasons.
> 
> Signed-off-by: Michal Hocko <mhocko@suse.cz>
> Cc: Andrew Morton <akpm@linux-foundation.org>
> Cc: Mel Gorman <mgorman@suse.de>
> Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> Cc: Andrea Arcangeli <aarcange@redhat.com>
> Cc: David Rientjes <rientjes@google.com>
> ---
>  mm/page_alloc.c |   11 +++++++++++
>  1 files changed, 11 insertions(+), 0 deletions(-)
> 
> diff --git a/mm/page_alloc.c b/mm/page_alloc.c
> index 2b8ba3a..485be89 100644
> --- a/mm/page_alloc.c
> +++ b/mm/page_alloc.c
> @@ -5608,6 +5608,17 @@ __count_immobile_pages(struct zone *zone, struct page *page, int count)
>  bool is_pageblock_removable_nolock(struct page *page)
>  {
>  	struct zone *zone = page_zone(page);
> +	unsigned long pfn = page_to_pfn(page);
> +
> +	/*
> +	 * We have to be careful here because we are iterating over memory
> +	 * sections which are not zone aware so we might end up outside of
> +	 * the zone but still within the section.
> +	 */
> +	if (!zone || zone->zone_start_pfn > pfn ||
> +			zone->zone_start_pfn + zone->spanned_pages <= pfn)
> +		return false;
> +
>  	return __count_immobile_pages(zone, page, 0);
>  }
>  

This seems partially bogus, why would

	page_zone(page)->zone_start_pfn > page_to_pfn(page) ||
	page_zone(page)->zone_start_pfn + page_zone(page)->spanned_pages <= page_to_pfn(page)

ever be true?  That would certainly mean that the struct zone is corrupted 
and seems to be unnecessary to fix the problem you're addressing.

I think this should be handled in is_mem_section_removable() on the pfn 
rather than using the struct page in is_pageblock_removable_nolock() and 
converting back and forth.  We should make sure that any page passed to 
is_pageblock_removable_nolock() is valid.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
