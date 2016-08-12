Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id A88B66B0253
	for <linux-mm@kvack.org>; Thu, 11 Aug 2016 22:08:01 -0400 (EDT)
Received: by mail-pf0-f198.google.com with SMTP id o124so24125443pfg.1
        for <linux-mm@kvack.org>; Thu, 11 Aug 2016 19:08:01 -0700 (PDT)
Received: from mail-pf0-x244.google.com (mail-pf0-x244.google.com. [2607:f8b0:400e:c00::244])
        by mx.google.com with ESMTPS id y196si6132240pfg.99.2016.08.11.19.08.00
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 11 Aug 2016 19:08:00 -0700 (PDT)
Received: by mail-pf0-x244.google.com with SMTP id y134so655725pfg.3
        for <linux-mm@kvack.org>; Thu, 11 Aug 2016 19:08:00 -0700 (PDT)
Subject: Re: [PATCH] mm: Initialize per_cpu_nodestats for hotadded pgdats
References: <20160811092808.GD8119@techsingularity.net>
 <1470931473-7090-1-git-send-email-arbab@linux.vnet.ibm.com>
From: Balbir Singh <bsingharora@gmail.com>
Message-ID: <17913beb-a3b3-6ef3-ba64-787d0fde88ea@gmail.com>
Date: Fri, 12 Aug 2016 12:07:51 +1000
MIME-Version: 1.0
In-Reply-To: <1470931473-7090-1-git-send-email-arbab@linux.vnet.ibm.com>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Reza Arbab <arbab@linux.vnet.ibm.com>, Mel Gorman <mgorman@techsingularity.net>, Andrew Morton <akpm@linux-foundation.org>, Paul Mackerras <paulus@ozlabs.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, linuxppc-dev@ozlabs.org



On 12/08/16 02:04, Reza Arbab wrote:
> The following oops occurs after a pgdat is hotadded:
> 
> [   86.839956] Unable to handle kernel paging request for data at address 0x00c30001
> [   86.840132] Faulting instruction address: 0xc00000000022f8f4
> [   86.840328] Oops: Kernel access of bad area, sig: 11 [#1]
> [   86.840468] SMP NR_CPUS=2048 NUMA pSeries
> [   86.840612] Modules linked in: ip6t_rpfilter ip6t_REJECT nf_reject_ipv6 ipt_REJECT nf_reject_ipv4 xt_conntrack ebtable_nat ebtable_broute bridge stp llc ebtable_filter ebtables ip6table_nat nf_conntrack_ipv6 nf_defrag_ipv6 nf_nat_ipv6 ip6table_mangle ip6table_security ip6table_raw ip6table_filter ip6_tables iptable_nat nf_conntrack_ipv4 nf_defrag_ipv4 nf_nat_ipv4 nf_nat nf_conntrack iptable_mangle iptable_security iptable_raw iptable_filter nls_utf8 isofs sg virtio_balloon uio_pdrv_genirq uio ip_tables xfs libcrc32c sr_mod cdrom sd_mod virtio_net ibmvscsi scsi_transport_srp virtio_pci virtio_ring virtio dm_mirror dm_region_hash dm_log dm_mod
> [   86.842955] CPU: 0 PID: 0 Comm: swapper/0 Tainted: G        W 4.8.0-rc1-device #110
> [   86.843140] task: c000000000ef3080 task.stack: c000000000f6c000
> [   86.843323] NIP: c00000000022f8f4 LR: c00000000022f948 CTR: 0000000000000000
> [   86.843595] REGS: c000000000f6fa50 TRAP: 0300   Tainted: G        W (4.8.0-rc1-device)
> [   86.843889] MSR: 800000010280b033 <SF,VEC,VSX,EE,FP,ME,IR,DR,RI,LE,TM[E]>  CR: 84002028  XER: 20000000
> [   86.844624] CFAR: d000000001d2013c DAR: 0000000000c30001 DSISR: 40000000 SOFTE: 0
> GPR00: c00000000022f948 c000000000f6fcd0 c000000000f71400 0000000000000001
> GPR04: 0000000000000100 0000000000000000 0000000000000000 0000000000c30000
> GPR08: ffffffffffffffff 0000000000000001 0000000000c30000 00000000ffffffff
> GPR12: 0000000000002200 c000000001300000 c000000000faefb4 c000000000faefa8
> GPR16: c000000000f6c000 c000000000f6c080 c000000000bf15b0 c000000000f6c080
> GPR20: c000000000bf4928 0000000000000000 0000000000000003 c000000000bf4968
> GPR24: c0000000ffed0000 0000000000000000 0000000000000000 c000000000f6fd58
> GPR28: 0000000000000001 0000000000000001 c000000000f6fcf0 c0000000ffed9c08
> [   86.847747] NIP [c00000000022f8f4] refresh_cpu_vm_stats+0x1a4/0x2f0
> [   86.847897] LR [c00000000022f948] refresh_cpu_vm_stats+0x1f8/0x2f0
> [   86.848060] Call Trace:
> [   86.848183] [c000000000f6fcd0] [c00000000022f948] refresh_cpu_vm_stats+0x1f8/0x2f0 (unreliable)
> 
> Add per_cpu_nodestats initialization to the hotplug codepath.
> 
> Signed-off-by: Reza Arbab <arbab@linux.vnet.ibm.com>
> ---
>  mm/memory_hotplug.c | 2 ++
>  1 file changed, 2 insertions(+)
> 
> diff --git a/mm/memory_hotplug.c b/mm/memory_hotplug.c
> index 3894b65..41266dc 100644
> --- a/mm/memory_hotplug.c
> +++ b/mm/memory_hotplug.c
> @@ -1219,6 +1219,7 @@ static pg_data_t __ref *hotadd_new_pgdat(int nid, u64 start)
>  
>  	/* init node's zones as empty zones, we don't have any present pages.*/
>  	free_area_init_node(nid, zones_size, start_pfn, zholes_size);
> +	pgdat->per_cpu_nodestats = alloc_percpu(struct per_cpu_nodestat);
>  
>  	/*
>  	 * The node we allocated has no zone fallback lists. For avoiding
> @@ -1249,6 +1250,7 @@ static pg_data_t __ref *hotadd_new_pgdat(int nid, u64 start)
>  static void rollback_node_hotadd(int nid, pg_data_t *pgdat)
>  {
>  	arch_refresh_nodedata(nid, NULL);
> +	free_percpu(pgdat->per_cpu_nodestats);
>  	arch_free_nodedata(pgdat);
>  	return;
>  }
> 

I wonder if node_set_online() should do the allocation and offline should free.
But that would be a larger change

Balbir

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
