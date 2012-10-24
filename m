Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx201.postini.com [74.125.245.201])
	by kanga.kvack.org (Postfix) with SMTP id 16A166B006E
	for <linux-mm@kvack.org>; Wed, 24 Oct 2012 02:49:54 -0400 (EDT)
Message-ID: <508790DD.8070607@cn.fujitsu.com>
Date: Wed, 24 Oct 2012 14:55:25 +0800
From: Wen Congyang <wency@cn.fujitsu.com>
MIME-Version: 1.0
Subject: Re: + memory-hotplug-allocate-zones-pcp-before-onlining-pages.patch
 added to -mm tree
References: <20121018223135.5D11F1E0043@wpzn4.hot.corp.google.com>
In-Reply-To: <20121018223135.5D11F1E0043@wpzn4.hot.corp.google.com>
Content-Transfer-Encoding: 7bit
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org
Cc: mm-commits@vger.kernel.org, benh@kernel.crashing.org, cl@linux.com, dave@linux.vnet.ibm.com, isimatu.yasuaki@jp.fujitsu.com, kosaki.motohiro@jp.fujitsu.com, len.brown@intel.com, liuj97@gmail.com, mel@csn.ul.ie, minchan.kim@gmail.com, paulus@samba.org, rientjes@google.com, lkml <linux-kernel@vger.kernel.org>, linux-mm@kvack.org

Hi, Andrew Morton

At 10/19/2012 06:31 AM, akpm@linux-foundation.org Wrote:
> The patch titled
>      Subject: memory-hotplug: allocate zone's pcp before onlining pages
> has been added to the -mm tree.  Its filename is
>      memory-hotplug-allocate-zones-pcp-before-onlining-pages.patch

I find a problem introduced by this patch, and the following is the fix:
Do I need to merge them into a single patch?

>From 705b8f7392adba8a36d8e89b5aef77d9a6a9042c Mon Sep 17 00:00:00 2001
From: Wen Congyang <wency@cn.fujitsu.com>
Date: Wed, 24 Oct 2012 14:21:15 +0800
Subject: [PATCH] memory-hotplug: build zonelist if a zone is populated after onlining pages

After "memory-hotplug: allocate zone's pcp before onlining pages", we
build zone list before onlining pages to allocate zone's pcp. But the
zone doesn't have pages before onlining pages, and the zone is not in
zonelist, so we still need to build zonelist after onlining pages.

CC: David Rientjes <rientjes@google.com>
CC: Jiang Liu <liuj97@gmail.com>
CC: Len Brown <len.brown@intel.com>
CC: Benjamin Herrenschmidt <benh@kernel.crashing.org>
CC: Paul Mackerras <paulus@samba.org>
CC: Christoph Lameter <cl@linux.com>
Cc: Minchan Kim <minchan.kim@gmail.com>
CC: Andrew Morton <akpm@linux-foundation.org>
CC: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
CC: Yasuaki Ishimatsu <isimatu.yasuaki@jp.fujitsu.com>
Signed-off-by: Wen Congyang <wency@cn.fujitsu.com>
---
 mm/memory_hotplug.c |    4 +++-
 1 files changed, 3 insertions(+), 1 deletions(-)

diff --git a/mm/memory_hotplug.c b/mm/memory_hotplug.c
index 3656926..b82bccf 100644
--- a/mm/memory_hotplug.c
+++ b/mm/memory_hotplug.c
@@ -529,7 +529,9 @@ int __ref online_pages(unsigned long pfn, unsigned long nr_pages)
 	zone->zone_pgdat->node_present_pages += onlined_pages;
 	if (onlined_pages) {
 		node_set_state(zone_to_nid(zone), N_HIGH_MEMORY);
-		if (!need_zonelists_rebuild)
+		if (need_zonelists_rebuild)
+			build_all_zonelists(NULL, NULL);
+		else
 			zone_pcp_update(zone);
 	}
 
-- 
1.7.1


> 
> Before you just go and hit "reply", please:
>    a) Consider who else should be cc'ed
>    b) Prefer to cc a suitable mailing list as well
>    c) Ideally: find the original patch on the mailing list and do a
>       reply-to-all to that, adding suitable additional cc's
> 
> *** Remember to use Documentation/SubmitChecklist when testing your code ***
> 
> The -mm tree is included into linux-next and is updated
> there every 3-4 working days
> 
> ------------------------------------------------------
> From: Wen Congyang <wency@cn.fujitsu.com>
> Subject: memory-hotplug: allocate zone's pcp before onlining pages
> 
> We use __free_page() to put a page to buddy system when onlining pages. 
> __free_page() will store NR_FREE_PAGES in zone's pcp.vm_stat_diff, so we
> should allocate zone's pcp before onlining pages, otherwise we will lose
> some free pages.
> 
> Signed-off-by: Wen Congyang <wency@cn.fujitsu.com>
> Cc: David Rientjes <rientjes@google.com>
> Cc: Jiang Liu <liuj97@gmail.com>
> Cc: Len Brown <len.brown@intel.com>
> Cc: Benjamin Herrenschmidt <benh@kernel.crashing.org>
> Cc: Paul Mackerras <paulus@samba.org>
> Cc: Christoph Lameter <cl@linux.com>
> Cc: Minchan Kim <minchan.kim@gmail.com>
> Cc: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
> Cc: Yasuaki Ishimatsu <isimatu.yasuaki@jp.fujitsu.com>
> Cc: Dave Hansen <dave@linux.vnet.ibm.com>
> Cc: Mel Gorman <mel@csn.ul.ie>
> Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
> ---
> 
>  mm/memory_hotplug.c |   10 ++++++----
>  1 file changed, 6 insertions(+), 4 deletions(-)
> 
> diff -puN mm/memory_hotplug.c~memory-hotplug-allocate-zones-pcp-before-onlining-pages mm/memory_hotplug.c
> --- a/mm/memory_hotplug.c~memory-hotplug-allocate-zones-pcp-before-onlining-pages
> +++ a/mm/memory_hotplug.c
> @@ -505,12 +505,16 @@ int __ref online_pages(unsigned long pfn
>  	 * So, zonelist must be updated after online.
>  	 */
>  	mutex_lock(&zonelists_mutex);
> -	if (!populated_zone(zone))
> +	if (!populated_zone(zone)) {
>  		need_zonelists_rebuild = 1;
> +		build_all_zonelists(NULL, zone);
> +	}
>  
>  	ret = walk_system_ram_range(pfn, nr_pages, &onlined_pages,
>  		online_pages_range);
>  	if (ret) {
> +		if (need_zonelists_rebuild)
> +			zone_pcp_reset(zone);
>  		mutex_unlock(&zonelists_mutex);
>  		printk(KERN_DEBUG "online_pages [mem %#010llx-%#010llx] failed\n",
>  		       (unsigned long long) pfn << PAGE_SHIFT,
> @@ -525,9 +529,7 @@ int __ref online_pages(unsigned long pfn
>  	zone->zone_pgdat->node_present_pages += onlined_pages;
>  	if (onlined_pages) {
>  		node_set_state(zone_to_nid(zone), N_HIGH_MEMORY);
> -		if (need_zonelists_rebuild)
> -			build_all_zonelists(NULL, zone);
> -		else
> +		if (!need_zonelists_rebuild)
>  			zone_pcp_update(zone);
>  	}
>  
> _
> 
> Patches currently in -mm which might be from wency@cn.fujitsu.com are
> 
> cpu_hotplug-unmap-cpu2node-when-the-cpu-is-hotremoved.patch
> cpu_hotplug-unmap-cpu2node-when-the-cpu-is-hotremoved-fix.patch
> acpi_memhotplugc-fix-memory-leak-when-memory-device-is-unbound-from-the-module-acpi_memhotplug.patch
> acpi_memhotplugc-free-memory-device-if-acpi_memory_enable_device-failed.patch
> acpi_memhotplugc-remove-memory-info-from-list-before-freeing-it.patch
> acpi_memhotplugc-dont-allow-to-eject-the-memory-device-if-it-is-being-used.patch
> acpi_memhotplugc-bind-the-memory-device-when-the-driver-is-being-loaded.patch
> acpi_memhotplugc-auto-bind-the-memory-device-which-is-hotplugged-before-the-driver-is-loaded.patch
> x86-numa-dont-check-if-node-is-numa_no_node.patch
> memory-hotplug-suppress-device-memoryx-does-not-have-a-release-function-warning.patch
> memory-hotplug-suppress-device-nodex-does-not-have-a-release-function-warning.patch
> memory-hotplug-skip-hwpoisoned-page-when-offlining-pages.patch
> memory-hotplug-update-mce_bad_pages-when-removing-the-memory.patch
> memory-hotplug-update-mce_bad_pages-when-removing-the-memory-fix.patch
> memory-hotplug-auto-offline-page_cgroup-when-onlining-memory-block-failed.patch
> memory-hotplug-fix-nr_free_pages-mismatch.patch
> memory-hotplug-allocate-zones-pcp-before-onlining-pages.patch
> 
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
