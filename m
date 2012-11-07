Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx170.postini.com [74.125.245.170])
	by kanga.kvack.org (Postfix) with SMTP id 9FC746B0044
	for <linux-mm@kvack.org>; Wed,  7 Nov 2012 02:41:58 -0500 (EST)
Message-ID: <509A107C.9050702@cn.fujitsu.com>
Date: Wed, 07 Nov 2012 15:40:44 +0800
From: Tang Chen <tangchen@cn.fujitsu.com>
MIME-Version: 1.0
Subject: [PATCH] Update start_pfn in zone and pg_data when spanned_pages ==
 0.
References: <1350988250-31294-1-git-send-email-wency@cn.fujitsu.com> <1350988250-31294-11-git-send-email-wency@cn.fujitsu.com>
In-Reply-To: <1350988250-31294-11-git-send-email-wency@cn.fujitsu.com>
Content-Transfer-Encoding: 7bit
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: wency@cn.fujitsu.com
Cc: x86@kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, linux-acpi@vger.kernel.org, linux-s390@vger.kernel.org, linux-sh@vger.kernel.org, linux-ia64@vger.kernel.org, cmetcalf@tilera.com, sparclinux@vger.kernel.org, rientjes@google.com, liuj97@gmail.com, len.brown@intel.com, benh@kernel.crashing.org, paulus@samba.org, cl@linux.com, minchan.kim@gmail.com, akpm@linux-foundation.org, kosaki.motohiro@jp.fujitsu.com, isimatu.yasuaki@jp.fujitsu.com

On 10/23/2012 06:30 PM, wency@cn.fujitsu.com wrote:
> From: Yasuaki Ishimatsu<isimatu.yasuaki@jp.fujitsu.com>
......
> +	/* The zone has no valid section */
> +	zone->zone_start_pfn = 0;
> +	zone->spanned_pages = 0;
> +	zone_span_writeunlock(zone);
> +}
> +
> +static void shrink_pgdat_span(struct pglist_data *pgdat,
> +			      unsigned long start_pfn, unsigned long end_pfn)
> +{
......
> +	/* The pgdat has no valid section */
> +	pgdat->node_start_pfn = 0;
> +	pgdat->node_spanned_pages = 0;
> +}

Hi,

If we hot-remove memory only and leave the cpus alive, the corresponding
node will not be removed. But the node_start_pfn and node_spanned_pages
in pg_data will be reset to 0. In this case, when we hot-add the memory
back next time, the node_start_pfn will always be 0 because no pfn is less
than 0. After that, if we hot-remove the memory again, it will cause kernel
panic in function find_biggest_section_pfn() when it tries to scan all 
the pfns.

The zone will also have the same problem.

This patch sets start_pfn to the start_pfn of the section being added when
spanned_pages of the zone or pg_data is 0.

---How to reproduce---

1. hot-add a container with some memory and cpus;
2. hot-remove the container's memory, and leave cpus there;
3. hot-add these memory again;
4. hot-remove them again;

then, the kernel will panic.

---Call trace---

[10530.646285] BUG: unable to handle kernel paging request at 
00000fff82a8cc38
[10530.729670] IP: [<ffffffff811c0d55>] find_biggest_section_pfn+0xe5/0x180
......
[10533.064975] Call Trace:
[10533.094162]  [<ffffffff811c0fcf>] ? __remove_zone+0x2f/0x1b0
[10533.161757]  [<ffffffff811c1124>] __remove_zone+0x184/0x1b0
[10533.228318]  [<ffffffff811c11dc>] __remove_section+0x8c/0xb0
[10533.295916]  [<ffffffff811c12e7>] __remove_pages+0xe7/0x120
[10533.362476]  [<ffffffff81654f7c>] arch_remove_memory+0x2c/0x80
[10533.432151]  [<ffffffff81655bb6>] remove_memory+0x56/0x90
[10533.496633]  [<ffffffff813da0c8>] 
acpi_memory_device_remove_memory+0x48/0x73
[10533.580846]  [<ffffffff813da55a>] acpi_memory_device_notify+0x153/0x274
[10533.659865]  [<ffffffff813a63cf>] ? acpi_bus_get_device+0x2f/0x77
[10533.732653]  [<ffffffff813a6589>] ? acpi_bus_notify+0xb5/0xec
[10533.801291]  [<ffffffff813b6786>] acpi_ev_notify_dispatch+0x41/0x5f
[10533.876156]  [<ffffffff813a3867>] acpi_os_execute_deferred+0x27/0x34
[10533.952062]  [<ffffffff81090589>] process_one_work+0x219/0x680
[10534.021736]  [<ffffffff81090528>] ? process_one_work+0x1b8/0x680
[10534.093488]  [<ffffffff813a3840>] ? 
acpi_os_wait_events_complete+0x23/0x23
[10534.175622]  [<ffffffff810923be>] worker_thread+0x12e/0x320
[10534.242181]  [<ffffffff81092290>] ? manage_workers+0x110/0x110
[10534.311855]  [<ffffffff81098396>] kthread+0xc6/0xd0
[10534.370111]  [<ffffffff8167c7c4>] kernel_thread_helper+0x4/0x10
[10534.440824]  [<ffffffff81672230>] ? retint_restore_args+0x13/0x13
[10534.513612]  [<ffffffff810982d0>] ? __init_kthread_worker+0x70/0x70
[10534.588480]  [<ffffffff8167c7c0>] ? gs_change+0x13/0x13
......
[10535.045543] ---[ end trace 96d845dbf33fee11 ]---


Signed-off-by: Tang Chen <tangchen@cn.fujitsu.com>
---
  mm/memory_hotplug.c |    4 ++--
  1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/mm/memory_hotplug.c b/mm/memory_hotplug.c
index 56b758a..4aa313c 100644
--- a/mm/memory_hotplug.c
+++ b/mm/memory_hotplug.c
@@ -212,7 +212,7 @@ static void grow_zone_span(struct zone *zone, 
unsigned long start_pfn,
         zone_span_writelock(zone);

         old_zone_end_pfn = zone->zone_start_pfn + zone->spanned_pages;
-       if (start_pfn < zone->zone_start_pfn)
+       if (!zone->spanned_pages || start_pfn < zone->zone_start_pfn)
                 zone->zone_start_pfn = start_pfn;

         zone->spanned_pages = max(old_zone_end_pfn, end_pfn) -
@@ -227,7 +227,7 @@ static void grow_pgdat_span(struct pglist_data 
*pgdat, unsigned long start_pfn,
         unsigned long old_pgdat_end_pfn =
                 pgdat->node_start_pfn + pgdat->node_spanned_pages;

-       if (start_pfn < pgdat->node_start_pfn)
+       if (!pgdat->node_spanned_pages || start_pfn < pgdat->node_start_pfn)
                 pgdat->node_start_pfn = start_pfn;

         pgdat->node_spanned_pages = max(old_pgdat_end_pfn, end_pfn) -
-- 
1.7.10.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
