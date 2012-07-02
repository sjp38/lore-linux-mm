Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx165.postini.com [74.125.245.165])
	by kanga.kvack.org (Postfix) with SMTP id 883426B0062
	for <linux-mm@kvack.org>; Mon,  2 Jul 2012 13:41:45 -0400 (EDT)
Received: by eaan1 with SMTP id n1so2790643eaa.14
        for <linux-mm@kvack.org>; Mon, 02 Jul 2012 10:41:43 -0700 (PDT)
Message-ID: <1341250950.16969.6.camel@lappy>
Subject: Re: [PATCH -mm v2] mm: have order > 0 compaction start off where it
 left
From: Sasha Levin <levinsasha928@gmail.com>
Date: Mon, 02 Jul 2012 19:42:30 +0200
In-Reply-To: <20120628143546.d02d13f9.akpm@linux-foundation.org>
References: <20120628135520.0c48b066@annuminas.surriel.com>
	 <20120628135940.2c26ada9.akpm@linux-foundation.org>
	 <4FECCB89.2050400@redhat.com>
	 <20120628143546.d02d13f9.akpm@linux-foundation.org>
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Mime-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Rik van Riel <riel@redhat.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Mel Gorman <mel@csn.ul.ie>, jaschut@sandia.gov, minchan@kernel.org, kamezawa.hiroyu@jp.fujitsu.com, Dave Jones <davej@redhat.com>

On Thu, 2012-06-28 at 14:35 -0700, Andrew Morton wrote:
> On Thu, 28 Jun 2012 17:24:25 -0400 Rik van Riel <riel@redhat.com> wrote:
> > 
> > >> @@ -463,6 +474,8 @@ static void isolate_freepages(struct zone *zone,
> > >>             */
> > >>            if (isolated)
> > >>                    high_pfn = max(high_pfn, pfn);
> > >> +          if (cc->order>  0)
> > >> +                  zone->compact_cached_free_pfn = high_pfn;
> > >
> > > Is high_pfn guaranteed to be aligned to pageblock_nr_pages here?  I
> > > assume so, if lots of code in other places is correct but it's
> > > unobvious from reading this function.
> > 
> > Reading the code a few more times, I believe that it is
> > indeed aligned to pageblock size.
> 
> I'll slip this into -next for a while.
> 
> --- a/mm/compaction.c~isolate_freepages-check-that-high_pfn-is-aligned-as-expected
> +++ a/mm/compaction.c
> @@ -456,6 +456,7 @@ static void isolate_freepages(struct zon
>                 }
>                 spin_unlock_irqrestore(&zone->lock, flags);
>  
> +               WARN_ON_ONCE(high_pfn & (pageblock_nr_pages - 1));
>                 /*
>                  * Record the highest PFN we isolated pages from. When next
>                  * looking for free pages, the search will restart here as 

I've triggered the following with today's -next:

[  372.893094] ------------[ cut here ]------------
[  372.896319] WARNING: at mm/compaction.c:470 isolate_freepages+0x1d9/0x370()
[  372.898900] Pid: 11417, comm: trinity-child55 Tainted: G        W    3.5.0-rc5-next-20120702-sasha-00007-g9a2ee81 #496
[  372.902293] Call Trace:
[  372.903152]  [<ffffffff810eb427>] warn_slowpath_common+0x87/0xb0
[  372.905295]  [<ffffffff810eb465>] warn_slowpath_null+0x15/0x20
[  372.908327]  [<ffffffff81207cd9>] isolate_freepages+0x1d9/0x370
[  372.912093]  [<ffffffff81207e98>] compaction_alloc+0x28/0x50
[  372.916275]  [<ffffffff81241c6c>] unmap_and_move+0x3c/0x140
[  372.920132]  [<ffffffff81241e30>] migrate_pages+0xc0/0x170
[  372.924141]  [<ffffffff81207e70>] ? isolate_freepages+0x370/0x370
[  372.928388]  [<ffffffff812087f2>] compact_zone+0x112/0x450
[  372.932342]  [<ffffffff81135488>] ? sched_clock_cpu+0x108/0x120
[  372.935289]  [<ffffffff81208f24>] compact_zone_order+0xb4/0xd0
[  372.937439]  [<ffffffff81208ff6>] try_to_compact_pages+0xb6/0x120
[  372.939535]  [<ffffffff811eae32>] __alloc_pages_direct_compact+0xc2/0x220
[  372.941912]  [<ffffffff811eb366>] __alloc_pages_slowpath+0x3d6/0x6a0
[  372.948587]  [<ffffffff811ead35>] ? get_page_from_freelist+0x625/0x660
[  372.957577]  [<ffffffff811eb876>] __alloc_pages_nodemask+0x246/0x330
[  372.964765]  [<ffffffff8122ea3f>] alloc_pages_vma+0x12f/0x140
[  372.971493]  [<ffffffff8124e9b4>] ? mem_cgroup_count_vm_event+0x144/0x170
[  372.980908]  [<ffffffff81247675>] do_huge_pmd_anonymous_page+0xf5/0x260
[  372.988788]  [<ffffffff81210573>] handle_mm_fault+0x1f3/0x360
[  372.997296]  [<ffffffff8120c037>] ? follow_page+0xe7/0x5a0
[  373.000737]  [<ffffffff81210bd8>] __get_user_pages+0x438/0x5d0
[  373.003473]  [<ffffffff81211cc6>] __mlock_vma_pages_range+0xc6/0xd0
[  373.007813]  [<ffffffff81211ec5>] mlock_vma_pages_range+0x75/0xb0
[  373.010956]  [<ffffffff81215adc>] mmap_region+0x4bc/0x5f0
[  373.012891]  [<ffffffff81215ec9>] do_mmap_pgoff+0x2b9/0x350
[  373.015029]  [<ffffffff812006bc>] ? vm_mmap_pgoff+0x6c/0xb0
[  373.017098]  [<ffffffff812006d4>] vm_mmap_pgoff+0x84/0xb0
[  373.019086]  [<ffffffff812133d2>] sys_mmap_pgoff+0x182/0x190
[  373.021106]  [<ffffffff8199070e>] ? trace_hardirqs_on_thunk+0x3a/0x3f
[  373.025749]  [<ffffffff8106d4dd>] sys_mmap+0x1d/0x20
[  373.029489]  [<ffffffff8373b5f9>] system_call_fastpath+0x16/0x1b
[  373.042335] ---[ end trace 6d450e935ee18981 ]---

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
