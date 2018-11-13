Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg1-f197.google.com (mail-pg1-f197.google.com [209.85.215.197])
	by kanga.kvack.org (Postfix) with ESMTP id CD51D6B0006
	for <linux-mm@kvack.org>; Tue, 13 Nov 2018 18:15:08 -0500 (EST)
Received: by mail-pg1-f197.google.com with SMTP id s22so9254878pgv.8
        for <linux-mm@kvack.org>; Tue, 13 Nov 2018 15:15:08 -0800 (PST)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id 3-v6si22315299plx.83.2018.11.13.15.15.07
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 13 Nov 2018 15:15:07 -0800 (PST)
Date: Tue, 13 Nov 2018 15:15:03 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: UBSAN: Undefined behaviour in mm/page_alloc.c
Message-Id: <20181113151503.fd370e28cb9df5a0933e9b04@linux-foundation.org>
In-Reply-To: <20181113094305.GM15120@dhcp22.suse.cz>
References: <CAEAjamseRRHu+TaTkd1TwpLNm8mtDGP=2K0WKLF0wH-3iLcW_w@mail.gmail.com>
	<20181109084353.GA5321@dhcp22.suse.cz>
	<20181113094305.GM15120@dhcp22.suse.cz>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Kyungtae Kim <kt0755@gmail.com>, pavel.tatashin@microsoft.com, vbabka@suse.cz, osalvador@suse.de, rppt@linux.vnet.ibm.com, aaron.lu@intel.com, iamjoonsoo.kim@lge.com, alexander.h.duyck@linux.intel.com, mgorman@techsingularity.net, lifeasageek@gmail.com, threeearcat@gmail.com, syzkaller@googlegroups.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Konstantin Khlebnikov <khlebnikov@yandex-team.ru>

On Tue, 13 Nov 2018 10:43:05 +0100 Michal Hocko <mhocko@kernel.org> wrote:

> Konstantin has noticed that kvmalloc might trigger the following warning
> [Thu Nov  1 08:43:56 2018] WARNING: CPU: 0 PID: 6676 at mm/vmstat.c:986 __fragmentation_index+0x54/0x60
> [...]
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
>
> ...
> 
> --- a/mm/page_alloc.c
> +++ b/mm/page_alloc.c
> @@ -4364,6 +4353,15 @@ __alloc_pages_nodemask(gfp_t gfp_mask, unsigned int order, int preferred_nid,
>  	gfp_t alloc_mask; /* The gfp_t that was actually used for allocation */
>  	struct alloc_context ac = { };
>  
> +	/*
> +	 * There are several places where we assume that the order value is sane
> +	 * so bail out early if the request is out of bound.
> +	 */
> +	if (unlikely(order >= MAX_ORDER)) {
> +		WARN_ON_ONCE(!(gfp_mask & __GFP_NOWARN));
> +		return NULL;
> +	}
> +

I know "everybody enables CONFIG_DEBUG_VM", but given this is fastpath,
we could help those who choose not to enable it by using

#ifdef CONFIG_DEBUG_VM
	if (WARN_ON_ONCE(order >= MAX_ORDER && !(gfp_mask & __GFP_NOWARN)))
		return NULL;
#endif

(Again curses 91241681c62 ("include/linux/mmdebug.h: make VM_WARN* non-rvals"))
