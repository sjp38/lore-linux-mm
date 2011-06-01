Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta12.messagelabs.com (mail6.bemta12.messagelabs.com [216.82.250.247])
	by kanga.kvack.org (Postfix) with ESMTP id A457B6B002B
	for <linux-mm@kvack.org>; Tue, 31 May 2011 20:57:53 -0400 (EDT)
Date: Wed, 1 Jun 2011 01:57:47 +0100
From: Mel Gorman <mel@csn.ul.ie>
Subject: Re: [PATCH] mm: compaction: Abort compaction if too many pages are
 isolated and caller is asynchronous
Message-ID: <20110601005747.GC7019@csn.ul.ie>
References: <20110530131300.GQ5044@csn.ul.ie>
 <20110530143109.GH19505@random.random>
 <20110530153748.GS5044@csn.ul.ie>
 <20110530165546.GC5118@suse.de>
 <20110530175334.GI19505@random.random>
 <20110531121620.GA3490@barrios-laptop>
 <20110531122437.GJ19505@random.random>
 <20110531133340.GB3490@barrios-laptop>
 <20110531141402.GK19505@random.random>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20110531141402.GK19505@random.random>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrea Arcangeli <aarcange@redhat.com>
Cc: Minchan Kim <minchan.kim@gmail.com>, Mel Gorman <mgorman@suse.de>, akpm@linux-foundation.org, Ury Stankevich <urykhy@gmail.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, stable@kernel.org

On Tue, May 31, 2011 at 04:14:02PM +0200, Andrea Arcangeli wrote:
> On Tue, May 31, 2011 at 10:33:40PM +0900, Minchan Kim wrote:
> > I checked them before sending patch but I got failed to find strange things. :(
> 
> My review also doesn't show other bugs in migrate_pages callers like
> that one.
> 
> > Now I am checking the page's SwapBacked flag can be changed
> > between before and after of migrate_pages so accounting of NR_ISOLATED_XX can
> > make mistake. I am approaching the failure, too. Hmm.
> 
> When I checked that, I noticed the ClearPageSwapBacked in swapcache if
> radix insertion fails, but that happens before adding the page in the
> LRU so it shouldn't have a chance to be isolated.
> 

After hammering three machines for several hours, I managed to trigger
this once on x86 !CONFIG_SMP CONFIG_PREEMPT HIGHMEM4G (so no PAE)
and caught the following trace.

May 31 23:45:37 arnold kernel: WARNING: at include/linux/vmstat.h:167 compact_zone+0xf8/0x53c()
May 31 23:45:37 arnold kernel: Hardware name:  
May 31 23:45:37 arnold kernel: Modules linked in: 3c59x mii sr_mod forcedeth cdrom ext4 mbcache jbd2 crc16 sd_mod ata_generic pata_amd sata_nv libata scsi_mod
May 31 23:45:37 arnold kernel: Pid: 16172, comm: usemem Not tainted 2.6.38.4-autobuild #17
May 31 23:45:37 arnold kernel: Call Trace:
May 31 23:45:37 arnold kernel: [<c10277f5>] ? warn_slowpath_common+0x65/0x7a
May 31 23:45:37 arnold kernel: [<c1098b12>] ? compact_zone+0xf8/0x53c
May 31 23:45:37 arnold kernel: [<c1027819>] ? warn_slowpath_null+0xf/0x13
May 31 23:45:37 arnold kernel: [<c1098b12>] ? compact_zone+0xf8/0x53c
May 31 23:45:37 arnold kernel: [<c1098fe3>] ? compact_zone_order+0x8d/0x95
May 31 23:45:37 arnold kernel: [<c1099068>] ? try_to_compact_pages+0x7d/0xc8
May 31 23:45:37 arnold kernel: [<c107ba56>] ? __alloc_pages_direct_compact+0x71/0x102
May 31 23:45:37 arnold kernel: [<c107be15>] ? __alloc_pages_nodemask+0x32e/0x57d
May 31 23:45:37 arnold kernel: [<c10914a6>] ? anon_vma_prepare+0x13/0x109
May 31 23:45:37 arnold kernel: [<c109fb01>] ? do_huge_pmd_anonymous_page+0xc9/0x285
May 31 23:45:37 arnold kernel: [<c1018f6a>] ? do_page_fault+0x0/0x346
May 31 23:45:37 arnold kernel: [<c108cb5e>] ? handle_mm_fault+0x7b/0x13a
May 31 23:45:37 arnold kernel: [<c1018f6a>] ? do_page_fault+0x0/0x346
May 31 23:45:37 arnold kernel: [<c1019298>] ? do_page_fault+0x32e/0x346
May 31 23:45:37 arnold kernel: [<c104a234>] ? trace_hardirqs_off+0xb/0xd
May 31 23:45:37 arnold kernel: [<c100482c>] ? do_softirq+0x9f/0xb5
May 31 23:45:37 arnold kernel: [<c12a5dee>] ?  restore_all_notrace+0x0/0x18
May 31 23:45:37 arnold kernel: [<c1018f6a>] ? do_page_fault+0x0/0x346
May 31 23:45:37 arnold kernel: [<c104e91e>] ?  trace_hardirqs_on_caller+0xfd/0x11e
May 31 23:45:37 arnold kernel: [<c1018f6a>] ? do_page_fault+0x0/0x346
May 31 23:45:37 arnold kernel: [<c12a61d9>] ? error_code+0x5d/0x64
May 31 23:45:37 arnold kernel: [<c1018f6a>] ? do_page_fault+0x0/0x346

This is triggering in compactions too_many_isolated() where the
NR_ISOLATED_FILE counter has gone negative so the damage was already
done. Most likely, the damage was caused when compaction called
putback_lru_pages() on pages that failed the migration that were
accounted as isolated anon during isolation and putback as isolated
file magically.

It's almost 2am so I'm wiped but the first thing in the morning
I want to check is if http://lkml.org/lkml/2010/8/26/32 is
relevant. Specifically, if during transparent hugepage collapsing
or splitting we are not protected by the anon_vma lock allowing an
imbalance to occur while calling release_pte_pages(). This seems a
bit far-reached though as I'd think at least the anon counter would
be corrupted by that.

A related possibility is that if the wrong anon_vma is being locked
then there is a race between collapse_huge_page and when migration
drops to 0 allowing release_pte_pages() to miss the page entirely.
Again, wrong counter being corrupted you'd think.

Another possibility is that because this is !PAE that the !SMP version
of native_pmdp_get_and_clear is somehow insufficient although I can't
think how it might be - unless the lack of a barrier with preemption
enabled is somehow a factor. Again, it's reaching because one would
expect the anon counter to get messed up, not the file one.

I can't formulate a theory as to how PageSwapBacked gets cleared during
migration that would cause compaction's putback_lru_pages to decrement
the wrong counter. Maybe sleep will figure it out :(

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
