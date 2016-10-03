Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f70.google.com (mail-wm0-f70.google.com [74.125.82.70])
	by kanga.kvack.org (Postfix) with ESMTP id 742196B0069
	for <linux-mm@kvack.org>; Mon,  3 Oct 2016 08:47:20 -0400 (EDT)
Received: by mail-wm0-f70.google.com with SMTP id b201so41193533wmb.2
        for <linux-mm@kvack.org>; Mon, 03 Oct 2016 05:47:20 -0700 (PDT)
Received: from mail-wm0-f50.google.com (mail-wm0-f50.google.com. [74.125.82.50])
        by mx.google.com with ESMTPS id 15si8459175wma.143.2016.10.03.05.47.18
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 03 Oct 2016 05:47:18 -0700 (PDT)
Received: by mail-wm0-f50.google.com with SMTP id p138so149507804wmb.1
        for <linux-mm@kvack.org>; Mon, 03 Oct 2016 05:47:18 -0700 (PDT)
Date: Mon, 3 Oct 2016 14:47:16 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: Crashes in refresh_zone_stat_thresholds when some nodes have no
 memory
Message-ID: <20161003124716.GD26759@dhcp22.suse.cz>
References: <20160804064410.GA20509@fergus.ozlabs.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20160804064410.GA20509@fergus.ozlabs.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Paul Mackerras <paulus@ozlabs.org>
Cc: Mel Gorman <mgorman@techsingularity.net>, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linuxppc-dev@ozlabs.org, Balbir Singh <bsingharora@gmail.com>, Nicholas Piggin <npiggin@gmail.com>

[Sorry I have only now noticed this email]

On Thu 04-08-16 16:44:10, Paul Mackerras wrote:
> It appears that commit 75ef71840539 ("mm, vmstat: add infrastructure
> for per-node vmstats", 2016-07-28) has introduced a regression on
> machines that have nodes which have no memory, such as the POWER8
> server that I use for testing.  When I boot current upstream, I get a
> splat like this:
> 
> [    1.713998] Unable to handle kernel paging request for data at address 0xff7a10000
> [    1.714164] Faulting instruction address: 0xc000000000270cd0
> [    1.714304] Oops: Kernel access of bad area, sig: 11 [#1]
> [    1.714414] SMP NR_CPUS=2048 NUMA PowerNV
> [    1.714530] Modules linked in:
> [    1.714647] CPU: 0 PID: 1 Comm: swapper/0 Not tainted 4.7.0-kvm+ #118
> [    1.714786] task: c000000ff0680010 task.stack: c000000ff0704000
> [    1.714926] NIP: c000000000270cd0 LR: c000000000270ce8 CTR: 0000000000000000
> [    1.715093] REGS: c000000ff0707900 TRAP: 0300   Not tainted  (4.7.0-kvm+)
> [    1.715232] MSR: 9000000102009033 <SF,HV,VEC,EE,ME,IR,DR,RI,LE,TM[E]>  CR: 846b6824  XER: 20000000
> [    1.715748] CFAR: c000000000008768 DAR: 0000000ff7a10000 DSISR: 42000000 SOFTE: 1 
> GPR00: c000000000270d08 c000000ff0707b80 c0000000011fb200 0000000000000000 
> GPR04: 0000000000000800 0000000000000000 0000000000000000 0000000000000000 
> GPR08: ffffffffffffffff 0000000000000000 0000000ff7a10000 c00000000122aae0 
> GPR12: c000000000a1e440 c00000000fb80000 c00000000000c188 0000000000000000 
> GPR16: 0000000000000000 0000000000000000 0000000000000000 0000000000000000 
> GPR20: 0000000000000000 0000000000000000 0000000000000000 c000000000cecad0 
> GPR24: c000000000d035b8 c000000000d6cd18 c000000000d6cd18 c000001fffa86300 
> GPR28: 0000000000000000 c000001fffa96300 c000000001230034 c00000000122eb18 
> [    1.717484] NIP [c000000000270cd0] refresh_zone_stat_thresholds+0x80/0x240
> [    1.717568] LR [c000000000270ce8] refresh_zone_stat_thresholds+0x98/0x240
> [    1.717648] Call Trace:
> [    1.717687] [c000000ff0707b80] [c000000000270d08] refresh_zone_stat_thresholds+0xb8/0x240 (unreliable)
> [    1.717818] [c000000ff0707bd0] [c000000000a1e4d4] init_per_zone_wmark_min+0x94/0xb0
> [    1.717932] [c000000ff0707c30] [c00000000000b90c] do_one_initcall+0x6c/0x1d0
> [    1.718036] [c000000ff0707cf0] [c000000000d04244] kernel_init_freeable+0x294/0x384
> [    1.718150] [c000000ff0707dc0] [c00000000000c1a8] kernel_init+0x28/0x160
> [    1.718249] [c000000ff0707e30] [c000000000009968] ret_from_kernel_thread+0x5c/0x74
> [    1.718358] Instruction dump:
> [    1.718408] 3fc20003 3bde4e34 3b800000 60420000 3860ffff 3fbb0001 4800001c 60420000 
> [    1.718575] 3d220003 3929f8e0 7d49502a e93d9c00 <7f8a49ae> 38a30001 38800800 7ca507b4 
> 
> It turns out that we can get a pgdat in the online pgdat list where
> pgdat->per_cpu_nodestats is NULL.  On my machine the pgdats for nodes
> 1 and 17 are like this.  All the memory is in nodes 0 and 16.

How is this possible? setup_per_cpu_pageset does

	for_each_online_pgdat(pgdat)
		pgdat->per_cpu_nodestats =
			alloc_percpu(struct per_cpu_nodestat);

so each online node should have the per_cpu_nodestat allocated.
refresh_zone_stat_thresholds then does for_each_online_pgdat and
for_each_populated_zone also shouldn't give any offline pgdat. Is it
possible that this is yet another manifest of 6aa303defb74 ("mm, vmscan:
only allocate and reclaim from zones with pages managed by the buddy
allocator")? I guess the following should be sufficient?
diff --git a/mm/vmstat.c b/mm/vmstat.c
index 73aab319969d..c170932a0101 100644
--- a/mm/vmstat.c
+++ b/mm/vmstat.c
@@ -185,6 +185,9 @@ void refresh_zone_stat_thresholds(void)
 		struct pglist_data *pgdat = zone->zone_pgdat;
 		unsigned long max_drift, tolerate_drift;
 
+		if (!managed_zone(zone))
+			continue;
+
 		threshold = calculate_normal_threshold(zone);
 
 		for_each_online_cpu(cpu) {

> With the patch below, the system boots normally.  I don't guarantee to
> have found every place that needs a check, and it may be better to fix
> this by allocating space for per-cpu statistics on nodes which have no
> memory rather than checking at each use site.
> 
> Paul.
> --------
> mm: cope with memoryless nodes not having per-cpu statistics allocated
> 
> It seems that the pgdat for nodes which have no memory will also have
> no per-cpu statistics space allocated, that is, pgdat->per_cpu_nodestats
> is NULL.  Avoid crashing on machines which have memoryless nodes by
> checking for non-NULL pgdat->per_cpu_nodestats.
> 
> Signed-off-by: Paul Mackerras <paulus@ozlabs.org>
> ---
> diff --git a/include/linux/vmstat.h b/include/linux/vmstat.h
> index 6137719..48b2780 100644
> --- a/include/linux/vmstat.h
> +++ b/include/linux/vmstat.h
> @@ -184,8 +184,9 @@ static inline unsigned long node_page_state_snapshot(pg_data_t *pgdat,
>  
>  #ifdef CONFIG_SMP
>  	int cpu;
> -	for_each_online_cpu(cpu)
> -		x += per_cpu_ptr(pgdat->per_cpu_nodestats, cpu)->vm_node_stat_diff[item];
> +	if (pgdat->per_cpu_nodestats)
> +		for_each_online_cpu(cpu)
> +			x += per_cpu_ptr(pgdat->per_cpu_nodestats, cpu)->vm_node_stat_diff[item];

Can we ever hit a pgdat which is not managed?

Keeping the rest of the email for reference.

>  
>  	if (x < 0)
>  		x = 0;
> diff --git a/mm/vmstat.c b/mm/vmstat.c
> index 89cec42..d83881e 100644
> --- a/mm/vmstat.c
> +++ b/mm/vmstat.c
> @@ -176,6 +176,10 @@ void refresh_zone_stat_thresholds(void)
>  
>  	/* Zero current pgdat thresholds */
>  	for_each_online_pgdat(pgdat) {
> +		if (!pgdat->per_cpu_nodestats) {
> +			pr_err("No nodestats for node %d\n", pgdat->node_id);
> +			continue;
> +		}
>  		for_each_online_cpu(cpu) {
>  			per_cpu_ptr(pgdat->per_cpu_nodestats, cpu)->stat_threshold = 0;
>  		}
> @@ -184,6 +188,10 @@ void refresh_zone_stat_thresholds(void)
>  	for_each_populated_zone(zone) {
>  		struct pglist_data *pgdat = zone->zone_pgdat;
>  		unsigned long max_drift, tolerate_drift;
> +		if (!pgdat->per_cpu_nodestats) {
> +			pr_err("No per cpu nodestats\n");
> +			continue;
> +		}
>  
>  		threshold = calculate_normal_threshold(zone);
>  
> @@ -701,6 +709,8 @@ static int refresh_cpu_vm_stats(bool do_pagesets)
>  	for_each_online_pgdat(pgdat) {
>  		struct per_cpu_nodestat __percpu *p = pgdat->per_cpu_nodestats;
>  
> +		if (!p)
> +			continue;
>  		for (i = 0; i < NR_VM_NODE_STAT_ITEMS; i++) {
>  			int v;
>  
> @@ -748,6 +758,8 @@ void cpu_vm_stats_fold(int cpu)
>  	for_each_online_pgdat(pgdat) {
>  		struct per_cpu_nodestat *p;
>  
> +		if (!pgdat->per_cpu_nodestats)
> +			continue;
>  		p = per_cpu_ptr(pgdat->per_cpu_nodestats, cpu);
>  
>  		for (i = 0; i < NR_VM_NODE_STAT_ITEMS; i++)
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
