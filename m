Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f72.google.com (mail-ed1-f72.google.com [209.85.208.72])
	by kanga.kvack.org (Postfix) with ESMTP id 403266B000A
	for <linux-mm@kvack.org>; Thu,  1 Nov 2018 05:33:08 -0400 (EDT)
Received: by mail-ed1-f72.google.com with SMTP id n23-v6so11595285edr.9
        for <linux-mm@kvack.org>; Thu, 01 Nov 2018 02:33:08 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id p15-v6si149304ejr.184.2018.11.01.02.33.06
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 01 Nov 2018 02:33:06 -0700 (PDT)
Date: Thu, 1 Nov 2018 10:33:04 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH] mm/kvmalloc: do not confuse kmalloc with page order over
 MAX_ORDER
Message-ID: <20181101093304.GC23921@dhcp22.suse.cz>
References: <154106356066.887821.4649178319705436373.stgit@buzz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <154106356066.887821.4649178319705436373.stgit@buzz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Konstantin Khlebnikov <khlebnikov@yandex-team.ru>
Cc: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org

On Thu 01-11-18 12:12:40, Konstantin Khlebnikov wrote:
> Allocations over PAGE_SIZE << MAX_ORDER could be served only by vmalloc.

Checking against KMALLOC_MAX_SIZE makes more sense IMHO. Other than that
this makes sense to me.

> Signed-off-by: Konstantin Khlebnikov <khlebnikov@yandex-team.ru>
> 
> ---
> 
> [Thu Nov  1 08:43:56 2018] ------------[ cut here ]------------
> [Thu Nov  1 08:43:56 2018] WARNING: CPU: 0 PID: 6676 at mm/vmstat.c:986 __fragmentation_index+0x54/0x60
> [Thu Nov  1 08:43:56 2018] Modules linked in: ipmi_devintf ipmi_ssif ipmi_si ipmi_msghandler netconsole configfs ip6t_REJECT nf_reject_ipv6 nf_log_ipv6 xt_u32 ip6table_nat nf_conntrack_ipv6 nf_defrag_ipv6 nf_nat_ipv6 ip6table_filter ip6_tables ipt_REJECT nf_reject_ipv4 nf_log_ipv4 nf_log_common xt_LOG xt_tcpudp xt_mark xt_owner xt_conntrack xt_multiport iptable_nat nf_conntrack_ipv4 nf_defrag_ipv4 nf_nat_ipv4 nf_nat nf_conntrack iptable_filter ip_tables x_tables nfsd auth_rpcgss nfs_acl nfs lockd grace sunrpc cls_u32 sch_fq sch_prio intel_rapl sb_edac x86_pkg_temp_thermal intel_powerclamp coretemp 8021q kvm_intel garp mrp stp i2c_algo_bit llc drm_kms_helper kvm syscopyarea sysfillrect sysimgblt irqbypass fb_sys_fops ghash_clmulni_intel ttm wdat_wdt drm mei_me lpc_ich mei shpchp mfd_core acpi_power_meter acpi_pad
> [Thu Nov  1 08:43:56 2018]  ip6_tunnel tunnel6 ipip tunnel4 ip_tunnel tcp_nv mlx4_en ptp pps_core xfs btrfs zstd_decompress zstd_compress xxhash raid456 async_raid6_recov async_memcpy async_pq async_xor async_tx xor raid10 mlx4_core nvme nvme_core devlink raid6_pq libcrc32c raid1 raid0 multipath linear [last unloaded: ipmi_msghandler]
> [Thu Nov  1 08:43:56 2018] CPU: 0 PID: 6676 Comm: ip6tables Not tainted 4.14.78-31 #1
> [Thu Nov  1 08:43:56 2018] Hardware name: AIC Inc. 21S-B312-B8/MB-DPHW1R AIDOS-M, BIOS AIDOS052 03/09/2017
> [Thu Nov  1 08:43:56 2018] task: ffff881e909b8e40 task.stack: ffffc90023034000
> [Thu Nov  1 08:43:56 2018] RIP: 0010:__fragmentation_index+0x54/0x60
> [Thu Nov  1 08:43:56 2018] RSP: 0018:ffffc90023037b30 EFLAGS: 00010206
> [Thu Nov  1 08:43:56 2018] RAX: 000000000000000b RBX: 0000000000064800 RCX: 000000000000000a
> [Thu Nov  1 08:43:56 2018] RDX: 0000000000000192 RSI: ffffc90023037b38 RDI: 000000000000000d
> [Thu Nov  1 08:43:56 2018] RBP: 000000000000000d R08: 0000000000065850 R09: 00000000000001c7
> [Thu Nov  1 08:43:56 2018] R10: 000000000000000d R11: 0000000000000000 R12: ffff88207fffb5c0
> [Thu Nov  1 08:43:56 2018] R13: 0000000000000004 R14: 0000000000000000 R15: ffffc90023037c10
> [Thu Nov  1 08:43:56 2018] FS:  00007f6cf6ec9740(0000) GS:ffff881fffa00000(0000) knlGS:0000000000000000
> [Thu Nov  1 08:43:56 2018] CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
> [Thu Nov  1 08:43:56 2018] CR2: 00007f6cf6e4f000 CR3: 0000001e91762002 CR4: 00000000003606f0
> [Thu Nov  1 08:43:56 2018] DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
> [Thu Nov  1 08:43:56 2018] DR3: 0000000000000000 DR6: 00000000fffe0ff0 DR7: 0000000000000400
> [Thu Nov  1 08:43:56 2018] Call Trace:
> [Thu Nov  1 08:43:56 2018]  fragmentation_index+0x76/0x90
> [Thu Nov  1 08:43:56 2018]  compaction_suitable+0x4f/0xf0
> [Thu Nov  1 08:43:56 2018]  shrink_node+0x295/0x310
> [Thu Nov  1 08:43:56 2018]  node_reclaim+0x205/0x250
> [Thu Nov  1 08:43:56 2018]  get_page_from_freelist+0x649/0xad0
> [Thu Nov  1 08:43:56 2018]  ? get_page_from_freelist+0x2d4/0xad0
> [Thu Nov  1 08:43:56 2018]  ? release_sock+0x19/0x90
> [Thu Nov  1 08:43:56 2018]  ? do_ipv6_setsockopt.isra.5+0x10da/0x1290
> [Thu Nov  1 08:43:56 2018]  __alloc_pages_nodemask+0x12a/0x2a0
> [Thu Nov  1 08:43:56 2018]  kmalloc_large_node+0x47/0x90
> [Thu Nov  1 08:43:56 2018]  __kmalloc_node+0x22b/0x2e0
> [Thu Nov  1 08:43:56 2018]  kvmalloc_node+0x3e/0x70
> [Thu Nov  1 08:43:56 2018]  xt_alloc_table_info+0x3a/0x80 [x_tables]
> [Thu Nov  1 08:43:56 2018]  do_ip6t_set_ctl+0xcd/0x1c0 [ip6_tables]
> [Thu Nov  1 08:43:56 2018]  nf_setsockopt+0x44/0x60
> [Thu Nov  1 08:43:56 2018]  SyS_setsockopt+0x6f/0xc0
> [Thu Nov  1 08:43:56 2018]  do_syscall_64+0x67/0x120
> [Thu Nov  1 08:43:56 2018]  entry_SYSCALL_64_after_hwframe+0x3d/0xa2
> [Thu Nov  1 08:43:56 2018] RIP: 0033:0x7f6cf63d121a
> [Thu Nov  1 08:43:56 2018] RSP: 002b:00007ffe2b3568e8 EFLAGS: 00000206 ORIG_RAX: 0000000000000036
> [Thu Nov  1 08:43:56 2018] RAX: ffffffffffffffda RBX: 0000000000000028 RCX: 00007f6cf63d121a
> [Thu Nov  1 08:43:56 2018] RDX: 0000000000000040 RSI: 0000000000000029 RDI: 0000000000000008
> [Thu Nov  1 08:43:56 2018] RBP: 00007f6cf4074070 R08: 000000000102c208 R09: ffff80930d5a91b0
> [Thu Nov  1 08:43:56 2018] R10: 00007f6cf4074010 R11: 0000000000000206 R12: 00000000015e5018
> [Thu Nov  1 08:43:56 2018] R13: 00000000015e5018 R14: 0000000000000000 R15: 00000000015e5010
> [Thu Nov  1 08:43:56 2018] Code: 89 c0 48 89 c1 48 69 06 e8 03 00 00 48 f7 f1 31 d2 48 05 e8 03 00 00 49 f7 f0 ba e8 03 00 00 29 c2 89 d0 c3 b8 18 fc ff ff f3 c3 <0f> 0b 31 c0 c3 0f 1f 80 00 00 00 00 0f 1f 44 00 00 41 57 41 56
> [Thu Nov  1 08:43:56 2018] ---[ end trace 344fe97463e06220 ]---
> ---
>  mm/util.c |    4 ++++
>  1 file changed, 4 insertions(+)
> 
> diff --git a/mm/util.c b/mm/util.c
> index 8bf08b5b5760..9b15f846c281 100644
> --- a/mm/util.c
> +++ b/mm/util.c
> @@ -392,6 +392,9 @@ void *kvmalloc_node(size_t size, gfp_t flags, int node)
>  	gfp_t kmalloc_flags = flags;
>  	void *ret;
>  
> +	if (size > (PAGE_SIZE << MAX_ORDER))
> +		goto fallback;
> +
>  	/*
>  	 * vmalloc uses GFP_KERNEL for some internal allocations (e.g page tables)
>  	 * so the given set of flags has to be compatible.
> @@ -422,6 +425,7 @@ void *kvmalloc_node(size_t size, gfp_t flags, int node)
>  	if (ret || size <= PAGE_SIZE)
>  		return ret;
>  
> +fallback:
>  	return __vmalloc_node_flags_caller(size, node, flags,
>  			__builtin_return_address(0));
>  }
> 

-- 
Michal Hocko
SUSE Labs
