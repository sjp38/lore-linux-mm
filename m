Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f52.google.com (mail-pa0-f52.google.com [209.85.220.52])
	by kanga.kvack.org (Postfix) with ESMTP id 2AAF86B0038
	for <linux-mm@kvack.org>; Tue,  8 Dec 2015 03:52:47 -0500 (EST)
Received: by pacwq6 with SMTP id wq6so8905449pac.1
        for <linux-mm@kvack.org>; Tue, 08 Dec 2015 00:52:46 -0800 (PST)
Received: from mga03.intel.com (mga03.intel.com. [134.134.136.65])
        by mx.google.com with ESMTP id w16si3803817pfa.221.2015.12.08.00.52.45
        for <linux-mm@kvack.org>;
        Tue, 08 Dec 2015 00:52:46 -0800 (PST)
Date: Tue, 8 Dec 2015 16:52:42 +0800
From: Aaron Lu <aaron.lu@intel.com>
Subject: Re: [RFC 0/3] reduce latency of direct async compaction
Message-ID: <20151208085242.GA6801@aaronlu.sh.intel.com>
References: <20151203092525.GA20945@aaronlu.sh.intel.com>
 <56600DAA.4050208@suse.cz>
 <20151203113508.GA23780@aaronlu.sh.intel.com>
 <20151203115255.GA24773@aaronlu.sh.intel.com>
 <56618841.2080808@suse.cz>
 <20151207073523.GA27292@js1304-P5Q-DELUXE>
 <20151207085956.GA16783@aaronlu.sh.intel.com>
 <20151208004118.GA4325@js1304-P5Q-DELUXE>
 <20151208051439.GA20797@aaronlu.sh.intel.com>
 <20151208065116.GA6902@js1304-P5Q-DELUXE>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20151208065116.GA6902@js1304-P5Q-DELUXE>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Cc: Vlastimil Babka <vbabka@suse.cz>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Rik van Riel <riel@redhat.com>, David Rientjes <rientjes@google.com>, Mel Gorman <mgorman@suse.de>, Minchan Kim <minchan@kernel.org>

On Tue, Dec 08, 2015 at 03:51:16PM +0900, Joonsoo Kim wrote:
> On Tue, Dec 08, 2015 at 01:14:39PM +0800, Aaron Lu wrote:
> > On Tue, Dec 08, 2015 at 09:41:18AM +0900, Joonsoo Kim wrote:
> > > On Mon, Dec 07, 2015 at 04:59:56PM +0800, Aaron Lu wrote:
> > > > On Mon, Dec 07, 2015 at 04:35:24PM +0900, Joonsoo Kim wrote:
> > > > > It looks like overhead still remain. I guess that migration scanner
> > > > > would call pageblock_pfn_to_page() for more extended range so
> > > > > overhead still remain.
> > > > > 
> > > > > I have an idea to solve his problem. Aaron, could you test following patch
> > > > > on top of base? It tries to skip calling pageblock_pfn_to_page()
> > > > 
> > > > It doesn't apply on top of 25364a9e54fb8296837061bf684b76d20eec01fb
> > > > cleanly, so I made some changes to make it apply and the result is:
> > > > https://github.com/aaronlu/linux/commit/cb8d05829190b806ad3948ff9b9e08c8ba1daf63
> > > 
> > > Yes, that's okay. I made it on my working branch but it will not result in
> > > any problem except applying.
> > > 
> > > > 
> > > > There is a problem occured right after the test starts:
> > > > [   58.080962] BUG: unable to handle kernel paging request at ffffea0082000018
> > > > [   58.089124] IP: [<ffffffff81193f29>] compaction_alloc+0xf9/0x270
> > > > [   58.096109] PGD 107ffd6067 PUD 207f7d5067 PMD 0
> > > > [   58.101569] Oops: 0000 [#1] SMP 
> > > 
> > > I did some mistake. Please test following patch. It is also made
> > > on my working branch so you need to resolve conflict but it would be
> > > trivial.
> > > 
> > > I inserted some logs to check whether zone is contiguous or not.
> > > Please check that normal zone is set to contiguous after testing.
> > 
> > Yes it is contiguous, but unfortunately, the problem remains:
> > [   56.536930] check_zone_contiguous: Normal
> > [   56.543467] check_zone_contiguous: Normal: contiguous
> > [   56.549640] BUG: unable to handle kernel paging request at ffffea0082000018
> > [   56.557717] IP: [<ffffffff81193f29>] compaction_alloc+0xf9/0x270
> > [   56.564719] PGD 107ffd6067 PUD 207f7d5067 PMD 0
> > 
> 
> Maybe, I find the reason. cc->free_pfn can be initialized to invalid pfn
> that isn't checked so optimized pageblock_pfn_to_page() causes BUG().
> 
> I add work-around for this problem at isolate_freepages(). Please test
> following one.

Still no luck and the error is about the same:

[   64.727792] check_zone_contiguous: Normal
[   64.733950] check_zone_contiguous: Normal: contiguous
[   64.741610] BUG: unable to handle kernel paging request at ffffea0082000018
[   64.749708] IP: [<ffffffff81193f29>] compaction_alloc+0xf9/0x270
[   64.756806] PGD 107ffd6067 PUD 207f7d5067 PMD 0 
[   64.762302] Oops: 0000 [#1] SMP 
[   64.766294] Modules linked in: scsi_debug rpcsec_gss_krb5 auth_rpcgss nfsv4 dns_resolver netconsole sg sd_mod x86_pkg_temp_thermal coretemp kvm_intel kvm mgag200 irqbypass crct10dif_pclmul ttm crc32_pclmul crc32c_intel drm_kms_helper ahci syscopyarea sysfillrect sysimgblt snd_pcm libahci fb_sys_fops snd_timer snd sb_edac aesni_intel soundcore lrw drm gf128mul pcspkr edac_core ipmi_devintf glue_helper ablk_helper cryptd libata ipmi_si shpchp wmi ipmi_msghandler acpi_power_meter acpi_pad
[   64.816579] CPU: 19 PID: 1526 Comm: usemem Not tainted 4.4.0-rc3-00025-gf60ea5f #1
[   64.825419] Hardware name: Intel Corporation S2600WTT/S2600WTT, BIOS SE5C610.86B.01.01.0008.021120151325 02/11/2015
[   64.837483] task: ffff88168a0aca80 ti: ffff88168a564000 task.ti:ffff88168a564000
[   64.846264] RIP: 0010:[<ffffffff81193f29>]  [<ffffffff81193f29>] compaction_alloc+0xf9/0x270
[   64.856147] RSP: 0000:ffff88168a567940  EFLAGS: 00010286
[   64.862520] RAX: ffff88207ffdcd80 RBX: ffff88168a567ac0 RCX: ffff88207ffdcd80
[   64.870944] RDX: 0000000002080000 RSI: ffff88168a567ac0 RDI: ffff88168a567ac0
[   64.879377] RBP: ffff88168a567990 R08: ffffea0082000000 R09: 0000000000000000
[   64.887813] R10: 0000000000000000 R11: 000000000001ae88 R12: ffffea0082000000
[   64.896254] R13: ffffea0059f20780 R14: 0000000002080000 R15: 0000000002080000
[   64.904704] FS:  00007f2d4e6e8700(0000) GS:ffff882034440000(0000) knlGS:0000000000000000
[   64.914232] CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
[   64.921151] CR2: ffffea0082000018 CR3: 0000002015771000 CR4: 00000000001406e0
[   64.929635] Stack:
[   64.932413]  ffff88168a568000 000000000167ca00 ffffffff81193196 ffff88207ffdcd80
[   64.941292]  0000000002080000 ffffea0059f207c0 ffff88168a567ac0 ffffea0059f20780
[   64.950179]  ffffea0059f207e0 ffff88207ffdcd80 ffff88168a567a20 ffffffff811d097e
[   64.959071] Call Trace:
[   64.962364]  [<ffffffff81193196>] ? update_pageblock_skip+0x56/0xa0
[   64.969939]  [<ffffffff811d097e>] migrate_pages+0x28e/0x7b0
[   64.976728]  [<ffffffff811931e0>] ? update_pageblock_skip+0xa0/0xa0
[   64.984312]  [<ffffffff81193e30>] ? __pageblock_pfn_to_page+0xe0/0xe0
[   64.992093]  [<ffffffff811954da>] compact_zone+0x38a/0x8e0
[   64.998811]  [<ffffffff81195a9d>] compact_zone_order+0x6d/0x90
[   65.005926]  [<ffffffff81174f44>] ? get_page_from_freelist+0xd4/0xa20
[   65.013861]  [<ffffffff81195d2c>] try_to_compact_pages+0xec/0x210
[   65.021212]  [<ffffffffa00d0c72>] ? sdebug_queuecommand_lock_or_not+0x22/0x60 [scsi_debug]
[   65.030984]  [<ffffffff811758cd>] __alloc_pages_direct_compact+0x3d/0x110
[   65.039106]  [<ffffffff81175f06>] __alloc_pages_nodemask+0x566/0xb40
[   65.046739]  [<ffffffff811c02c1>] alloc_pages_vma+0x1d1/0x230
[   65.053690]  [<ffffffff811d5d77>] do_huge_pmd_anonymous_page+0x107/0x3f0
[   65.061713]  [<ffffffff8119ed2a>] handle_mm_fault+0x178a/0x1940
[   65.068859]  [<ffffffff811a6614>] ? change_protection+0x14/0x20
[   65.075999]  [<ffffffff8109d8a2>] ? __might_sleep+0x52/0xb0
[   65.082750]  [<ffffffff81063c4d>] __do_page_fault+0x1ad/0x410
[   65.089690]  [<ffffffff81063edf>] do_page_fault+0x2f/0x80
[   65.096242]  [<ffffffff818c8008>] page_fault+0x28/0x30
[   65.102491] Code: 90 00 00 00 48 8b 45 c8 4d 89 e0 83 b8 50 05 00 00 01 74 12 48 8b 55 c8 4c 89 f6 4c 89 ff e8 2f fe ff ff 49 89 c0 4d 85 c0 74 47 <41> 8b 40 18 83 f8 80 75 0a 49 8b 40 30 48 83 f8 08 77 34 48 b8 
[   65.125421] RIP  [<ffffffff81193f29>] compaction_alloc+0xf9/0x270
[   65.132777]  RSP <ffff88168a567940>
[   65.141419] ---[ end trace c17c6b894e4340a8 ]---
[   65.149001] Kernel panic - not syncing: Fatal exception


Thanks,
Aaron

> 
> Thanks.
> 
> ---------->8---------------
> From 7e954a68fb555a868acc5860627a1ad8dadbe3bf Mon Sep 17 00:00:00 2001
> From: Joonsoo Kim <iamjoonsoo.kim@lge.com>
> Date: Mon, 7 Dec 2015 14:51:42 +0900
> Subject: [PATCH] mm/compaction: Optimize pageblock_pfn_to_page() for
>  contiguous zone
> 
> Signed-off-by: Joonsoo Kim <iamjoonsoo.kim@lge.com>
> ---
>  include/linux/mmzone.h |  1 +
>  mm/compaction.c        | 60 +++++++++++++++++++++++++++++++++++++++++++++++++-
>  2 files changed, 60 insertions(+), 1 deletion(-)
> 
> diff --git a/include/linux/mmzone.h b/include/linux/mmzone.h
> index e23a9e7..573f9a9 100644
> --- a/include/linux/mmzone.h
> +++ b/include/linux/mmzone.h
> @@ -521,6 +521,7 @@ struct zone {
>  #endif
>  
>  #if defined CONFIG_COMPACTION || defined CONFIG_CMA
> +       int                     contiguous;
>         /* Set to true when the PG_migrate_skip bits should be cleared */
>         bool                    compact_blockskip_flush;
>  #endif
> diff --git a/mm/compaction.c b/mm/compaction.c
> index de3e1e7..ff5fb04 100644
> --- a/mm/compaction.c
> +++ b/mm/compaction.c
> @@ -88,7 +88,7 @@ static inline bool migrate_async_suitable(int migratetype)
>   * the first and last page of a pageblock and avoid checking each individual
>   * page in a pageblock.
>   */
> -static struct page *pageblock_pfn_to_page(unsigned long start_pfn,
> +static struct page *__pageblock_pfn_to_page(unsigned long start_pfn,
>                                 unsigned long end_pfn, struct zone *zone)
>  {
>         struct page *start_page;
> @@ -114,6 +114,56 @@ static struct page *pageblock_pfn_to_page(unsigned long start_pfn,
>         return start_page;
>  }
>  
> +static inline struct page *pageblock_pfn_to_page(unsigned long start_pfn,
> +                               unsigned long end_pfn, struct zone *zone)
> +{
> +       if (zone->contiguous == 1)
> +               return pfn_to_page(start_pfn);
> +
> +       return __pageblock_pfn_to_page(start_pfn, end_pfn, zone);
> +}
> +
> +static void check_zone_contiguous(struct zone *zone)
> +{
> +       unsigned long block_start_pfn = zone->zone_start_pfn;
> +       unsigned long block_end_pfn;
> +       unsigned long pfn;
> +
> +       /* Already checked */
> +       if (zone->contiguous)
> +               return;
> +
> +       printk("%s: %s\n", __func__, zone->name);
> +       block_end_pfn = ALIGN(block_start_pfn + 1, pageblock_nr_pages);
> +       for (; block_start_pfn < zone_end_pfn(zone);
> +               block_start_pfn = block_end_pfn,
> +               block_end_pfn += pageblock_nr_pages) {
> +
> +               block_end_pfn = min(block_end_pfn, zone_end_pfn(zone));
> +
> +               if (!__pageblock_pfn_to_page(block_start_pfn,
> +                                       block_end_pfn, zone)) {
> +                       /* We have hole */
> +                       zone->contiguous = -1;
> +                       printk("%s: %s: uncontiguous\n", __func__, zone->name);
> +                       return;
> +               }
> +
> +               /* Check validity of pfn within pageblock */
> +               for (pfn = block_start_pfn; pfn < block_end_pfn; pfn++) {
> +                       if (!pfn_valid_within(pfn)) {
> +                               zone->contiguous = -1;
> +                               printk("%s: %s: uncontiguous\n", __func__, zone->name);
> +                               return;
> +                       }
> +               }
> +       }
> +
> +       /* We don't have hole */
> +       zone->contiguous = 1;
> +       printk("%s: %s: contiguous\n", __func__, zone->name);
> +}
> +
>  #ifdef CONFIG_COMPACTION
>  
>  /* Do not skip compaction more than 64 times */
> @@ -948,6 +998,12 @@ static void isolate_freepages(struct compact_control *cc)
>         unsigned long low_pfn;       /* lowest pfn scanner is able to scan */
>         struct list_head *freelist = &cc->freepages;
>  
> +       /* Work-around */
> +       if (zone->contiguous == 1 &&
> +               cc->free_pfn == zone_end_pfn(zone) &&
> +               cc->free_pfn == cc->free_pfn & ~(pageblock_nr_pages-1))
> +               cc->free_pfn -= pageblock_nr_pages;
> +
>         /*
>          * Initialise the free scanner. The starting point is where we last
>          * successfully isolated from, zone-cached value, or the end of the
> @@ -1356,6 +1412,8 @@ static int compact_zone(struct zone *zone, struct compact_control *cc)
>                 ;
>         }
>  
> +       check_zone_contiguous(zone);
> +
>         /*
>          * Clear pageblock skip if there were failures recently and compaction
>          * is about to be retried after being deferred. kswapd does not do
> -- 
> 1.9.1
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
