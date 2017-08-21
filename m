Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f198.google.com (mail-wr0-f198.google.com [209.85.128.198])
	by kanga.kvack.org (Postfix) with ESMTP id 78FE4280310
	for <linux-mm@kvack.org>; Mon, 21 Aug 2017 02:47:14 -0400 (EDT)
Received: by mail-wr0-f198.google.com with SMTP id q49so8583283wrb.14
        for <linux-mm@kvack.org>; Sun, 20 Aug 2017 23:47:14 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id m7si7246057wrf.12.2017.08.20.23.47.12
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Sun, 20 Aug 2017 23:47:13 -0700 (PDT)
Date: Mon, 21 Aug 2017 08:47:09 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH][RFC v4] PM / Hibernate: Feed the wathdog when creating
 snapshot
Message-ID: <20170821064709.GE13724@dhcp22.suse.cz>
References: <1503138086-19174-1-git-send-email-yu.c.chen@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1503138086-19174-1-git-send-email-yu.c.chen@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Chen Yu <yu.c.chen@intel.com>
Cc: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@techsingularity.net>, Vlastimil Babka <vbabka@suse.cz>, "Rafael J. Wysocki" <rjw@rjwysocki.net>, Len Brown <lenb@kernel.org>, Dan Williams <dan.j.williams@intel.com>, linux-kernel@vger.kernel.org

On Sat 19-08-17 18:21:26, Chen Yu wrote:
> There is a problem that when counting the pages for creating
> the hibernation snapshot will take significant amount of
> time, especially on system with large memory. Since the counting
> job is performed with irq disabled, this might lead to NMI lockup.
> The following warning were found on a system with 1.5TB DRAM:
> 
> [ 1124.758184] Freezing user space processes ... (elapsed 0.002 seconds) done.
> [ 1124.768721] OOM killer disabled.
> [ 1124.847009] PM: Preallocating image memory...
> [ 1139.392042] NMI watchdog: Watchdog detected hard LOCKUP on cpu 27
> [ 1139.392076] CPU: 27 PID: 3128 Comm: systemd-sleep Not tainted 4.13.0-0.rc2.git0.1.fc27.x86_64 #1
> [ 1139.392077] task: ffff9f01971ac000 task.stack: ffffb1a3f325c000
> [ 1139.392083] RIP: 0010:memory_bm_find_bit+0xf4/0x100
> [ 1139.392084] RSP: 0018:ffffb1a3f325fc20 EFLAGS: 00000006
> [ 1139.392084] RAX: 0000000000000000 RBX: 0000000013b83000 RCX: ffff9fbe89caf000
> [ 1139.392085] RDX: ffffb1a3f325fc30 RSI: 0000000000003200 RDI: ffff9fbeaffffe80
> [ 1139.392085] RBP: ffffb1a3f325fc40 R08: 0000000013b80000 R09: ffff9fbe89c54878
> [ 1139.392085] R10: ffffb1a3f325fc2c R11: 0000000013b83200 R12: 0000000000000400
> [ 1139.392086] R13: fffffd552e0c0000 R14: ffff9fc1bffd31e0 R15: 0000000000000202
> [ 1139.392086] FS:  00007f3189704180(0000) GS:ffff9fbec8ec0000(0000) knlGS:0000000000000000
> [ 1139.392087] CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
> [ 1139.392087] CR2: 00000085da0f7398 CR3: 000001771cf9a000 CR4: 00000000007406e0
> [ 1139.392088] DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
> [ 1139.392088] DR3: 0000000000000000 DR6: 00000000fffe0ff0 DR7: 0000000000000400
> [ 1139.392088] PKRU: 55555554
> [ 1139.392089] Call Trace:
> [ 1139.392092]  ? memory_bm_set_bit+0x29/0x60
> [ 1139.392094]  swsusp_set_page_free+0x2b/0x30
> [ 1139.392098]  mark_free_pages+0x147/0x1c0
> [ 1139.392099]  count_data_pages+0x41/0xa0
> [ 1139.392101]  hibernate_preallocate_memory+0x80/0x450
> [ 1139.392102]  hibernation_snapshot+0x58/0x410
> [ 1139.392103]  hibernate+0x17c/0x310
> [ 1139.392104]  state_store+0xdf/0xf0
> [ 1139.392107]  kobj_attr_store+0xf/0x20
> [ 1139.392111]  sysfs_kf_write+0x37/0x40
> [ 1139.392113]  kernfs_fop_write+0x11c/0x1a0
> [ 1139.392117]  __vfs_write+0x37/0x170
> [ 1139.392121]  ? handle_mm_fault+0xd8/0x230
> [ 1139.392122]  vfs_write+0xb1/0x1a0
> [ 1139.392123]  SyS_write+0x55/0xc0
> [ 1139.392126]  entry_SYSCALL_64_fastpath+0x1a/0xa5
> ...
> [ 1144.690405] done (allocated 6590003 pages)
> [ 1144.694971] PM: Allocated 26360012 kbytes in 19.89 seconds (1325.28 MB/s)
> 
> It has taken nearly 20 seconds(2.10GHz CPU) thus the NMI lockup
> was triggered. In case the timeout of the NMI watch dog has been
> set to 1 second, a safe interval should be 6590003/20 = 320k pages
> in theory. However there might also be some platforms running at a
> lower frequency, so feed the watchdog every 100k pages.
> 
> Reported-by: Jan Filipcewicz <jan.filipcewicz@intel.com>
> Suggested-by: Michal Hocko <mhocko@kernel.org>
> Cc: Andrew Morton <akpm@linux-foundation.org>
> Cc: Michal Hocko <mhocko@kernel.org>
> Cc: Mel Gorman <mgorman@techsingularity.net>
> Cc: Vlastimil Babka <vbabka@suse.cz>
> Cc: "Rafael J. Wysocki" <rjw@rjwysocki.net>
> Cc: Len Brown <lenb@kernel.org>
> Cc: Dan Williams <dan.j.williams@intel.com>
> Cc: linux-kernel@vger.kernel.org
> Signed-off-by: Chen Yu <yu.c.chen@intel.com>

OK, this looks better. Feel free to add
Reviewed-by: Michal Hocko <mhocko@suse.com>

> ---
>  mm/page_alloc.c | 14 ++++++++++++--
>  1 file changed, 12 insertions(+), 2 deletions(-)
> 
> diff --git a/mm/page_alloc.c b/mm/page_alloc.c
> index 6d00f74..543726a 100644
> --- a/mm/page_alloc.c
> +++ b/mm/page_alloc.c
> @@ -66,6 +66,7 @@
>  #include <linux/kthread.h>
>  #include <linux/memcontrol.h>
>  #include <linux/ftrace.h>
> +#include <linux/nmi.h>
>  
>  #include <asm/sections.h>
>  #include <asm/tlbflush.h>
> @@ -2531,9 +2532,12 @@ void drain_all_pages(struct zone *zone)
>  
>  #ifdef CONFIG_HIBERNATION
>  
> +/* Touch watchdog for every WD_INTERVAL_PAGE pages. */
> +#define WD_INTERVAL_PAGE	(100*1024)
> +
>  void mark_free_pages(struct zone *zone)
>  {
> -	unsigned long pfn, max_zone_pfn;
> +	unsigned long pfn, max_zone_pfn, page_num = 0;
>  	unsigned long flags;
>  	unsigned int order, t;
>  	struct page *page;
> @@ -2548,6 +2552,9 @@ void mark_free_pages(struct zone *zone)
>  		if (pfn_valid(pfn)) {
>  			page = pfn_to_page(pfn);
>  
> +			if (!((page_num++) % WD_INTERVAL_PAGE))
> +				touch_nmi_watchdog();
> +
>  			if (page_zone(page) != zone)
>  				continue;
>  
> @@ -2561,8 +2568,11 @@ void mark_free_pages(struct zone *zone)
>  			unsigned long i;
>  
>  			pfn = page_to_pfn(page);
> -			for (i = 0; i < (1UL << order); i++)
> +			for (i = 0; i < (1UL << order); i++) {
> +				if (!((page_num++) % WD_INTERVAL_PAGE))
> +					touch_nmi_watchdog();
>  				swsusp_set_page_free(pfn_to_page(pfn + i));
> +			}
>  		}
>  	}
>  	spin_unlock_irqrestore(&zone->lock, flags);
> -- 
> 2.7.4
> 
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
