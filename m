Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx162.postini.com [74.125.245.162])
	by kanga.kvack.org (Postfix) with SMTP id 4D41A6B0032
	for <linux-mm@kvack.org>; Fri, 16 Aug 2013 16:18:43 -0400 (EDT)
Date: Fri, 16 Aug 2013 16:18:14 -0400
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [patch v2 3/3] mm: page_alloc: fair zone allocator policy
Message-ID: <20130816201814.GA26409@cmpxchg.org>
References: <1375457846-21521-1-git-send-email-hannes@cmpxchg.org>
 <1375457846-21521-4-git-send-email-hannes@cmpxchg.org>
 <20130807145828.GQ2296@suse.de>
 <20130807153743.GH715@cmpxchg.org>
 <20130808041623.GL1845@cmpxchg.org>
 <87haepblo2.fsf@kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <87haepblo2.fsf@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Kevin Hilman <khilman@linaro.org>
Cc: Mel Gorman <mgorman@suse.de>, Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@surriel.com>, Andrea Arcangeli <aarcange@redhat.com>, Zlatko Calusic <zcalusic@bitsync.net>, Minchan Kim <minchan@kernel.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, "sfr@canb.auug.org.au linux-arm-kernel" <linux-arm-kernel@lists.infradead.org>, Olof Johansson <olof@lixom.net>, Stephen Warren <swarren@wwwdotorg.org>

Hi Kevin,

On Fri, Aug 16, 2013 at 10:17:01AM -0700, Kevin Hilman wrote:
> Johannes Weiner <hannes@cmpxchg.org> writes:
> > On Wed, Aug 07, 2013 at 11:37:43AM -0400, Johannes Weiner wrote:
> > Subject: [patch] mm: page_alloc: use vmstats for fair zone allocation batching
> >
> > Avoid dirtying the same cache line with every single page allocation
> > by making the fair per-zone allocation batch a vmstat item, which will
> > turn it into batched percpu counters on SMP.
> >
> > Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>
> 
> I bisected several boot failures on various ARM platform in
> next-20130816 down to this patch (commit 67131f9837 in linux-next.)
> 
> Simply reverting it got things booting again on top of -next.  Example
> boot crash below.

Thanks for the bisect and report!

I deref the percpu pointers before initializing them properly.  It
didn't trigger on x86 because the percpu offset added to the pointer
is big enough so that it does not fall into PFN 0, but it probably
ended up corrupting something...

Could you try this patch on top of linux-next instead of the revert?

Thanks,
Johannes

---
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: [patch] mm: page_alloc: use vmstats for fair zone allocation batching fix

Initialize the per-cpu counters before modifying them.  Otherwise:

[    0.000000] Booting Linux on physical CPU 0x0
[    0.000000] Linux version 3.11.0-rc5-next-20130816 (khilman@paris) (gcc version 4.7.2 (Ubuntu/Linaro 4.7.2-1ubuntu1) ) #30 SMP Fri Aug 16 09:47:32 PDT 2013
[    0.000000] CPU: ARMv7 Processor [413fc082] revision 2 (ARMv7), cr=10c53c7d
[    0.000000] CPU: PIPT / VIPT nonaliasing data cache, VIPT aliasing instruction cache
[    0.000000] Machine: Generic AM33XX (Flattened Device Tree), model: TI AM335x BeagleBone
[    0.000000] bootconsole [earlycon0] enabled
[    0.000000] Memory policy: ECC disabled, Data cache writeback
[    0.000000] On node 0 totalpages: 130816
[    0.000000] free_area_init_node: node 0, pgdat c081d400, node_mem_map c12fc000
[    0.000000]   Normal zone: 1024 pages used for memmap
[    0.000000]   Normal zone: 0 pages reserved
[    0.000000] Unable to handle kernel NULL pointer dereference at virtual address 00000026
[    0.000000] pgd = c0004000
[    0.000000] [00000026] *pgd=00000000
[    0.000000] Internal error: Oops: 5 [#1] SMP ARM
[    0.000000] Modules linked in:
[    0.000000] CPU: 0 PID: 0 Comm: swapper Not tainted 3.11.0-rc5-next-20130816 #30
[    0.000000] task: c0793c70 ti: c0788000 task.ti: c0788000
[    0.000000] PC is at __mod_zone_page_state+0x2c/0xb4
[    0.000000] LR is at mod_zone_page_state+0x2c/0x4c

Reported-by: Kevin Hilman <khilman@linaro.org>
Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>
---
 mm/page_alloc.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 6a95d39..b9e8f2f 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -4826,11 +4826,11 @@ static void __paginginit free_area_init_core(struct pglist_data *pgdat,
 		spin_lock_init(&zone->lru_lock);
 		zone_seqlock_init(zone);
 		zone->zone_pgdat = pgdat;
+		zone_pcp_init(zone);
 
 		/* For bootup, initialized properly in watermark setup */
 		mod_zone_page_state(zone, NR_ALLOC_BATCH, zone->managed_pages);
 
-		zone_pcp_init(zone);
 		lruvec_init(&zone->lruvec);
 		if (!size)
 			continue;
-- 
1.8.3.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
