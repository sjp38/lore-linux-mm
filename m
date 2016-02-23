Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f182.google.com (mail-qk0-f182.google.com [209.85.220.182])
	by kanga.kvack.org (Postfix) with ESMTP id 0004C82F69
	for <linux-mm@kvack.org>; Tue, 23 Feb 2016 04:17:42 -0500 (EST)
Received: by mail-qk0-f182.google.com with SMTP id s5so65715505qkd.0
        for <linux-mm@kvack.org>; Tue, 23 Feb 2016 01:17:42 -0800 (PST)
Received: from e37.co.us.ibm.com (e37.co.us.ibm.com. [32.97.110.158])
        by mx.google.com with ESMTPS id l73si33052028qhc.94.2016.02.23.01.17.41
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=AES128-SHA bits=128/128);
        Tue, 23 Feb 2016 01:17:41 -0800 (PST)
Received: from localhost
	by e37.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <zhlcindy@imap.linux.ibm.com>;
	Tue, 23 Feb 2016 02:17:41 -0700
Received: from b03cxnp08026.gho.boulder.ibm.com (b03cxnp08026.gho.boulder.ibm.com [9.17.130.18])
	by d03dlp01.boulder.ibm.com (Postfix) with ESMTP id 5BC161FF0025
	for <linux-mm@kvack.org>; Tue, 23 Feb 2016 02:05:48 -0700 (MST)
Received: from d03av01.boulder.ibm.com (d03av01.boulder.ibm.com [9.17.195.167])
	by b03cxnp08026.gho.boulder.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id u1N9HcEi28180730
	for <linux-mm@kvack.org>; Tue, 23 Feb 2016 02:17:38 -0700
Received: from d03av01.boulder.ibm.com (localhost [127.0.0.1])
	by d03av01.boulder.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id u1N9HcvS017003
	for <linux-mm@kvack.org>; Tue, 23 Feb 2016 02:17:38 -0700
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII;
 format=flowed
Content-Transfer-Encoding: 7bit
Date: Tue, 23 Feb 2016 17:17:37 +0800
From: zhlcindy <zhlcindy@imap.linux.ibm.com>
Subject: Re: [PATCH 1/1] mm: meminit: initialise more memory for inode/dentry
 hash tables in early boot
In-Reply-To: <1455699404-67837-1-git-send-email-zhlcindy@linux.vnet.ibm.com>
References: <1455699404-67837-1-git-send-email-zhlcindy@linux.vnet.ibm.com>
Message-ID: <5fe2e0cc1adff25fdc06a86e7e404c1a@imap.linux.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, zhlcindy@gmail.com

Hi Mel Gorman,

Would you please help review this patch?
Power platform plan to enable page parallel initialisation, but a
call trace is caused in 32TB system with 16 Nodes.

The log from dmesg with this patch,

[    0.092881] Dentry cache hash table entries: 2147483648 (order: 18, 
17179869184 bytes)
[    2.895862] Inode-cache hash table entries: 2147483648 (order: 18, 
17179869184 bytes)
[    5.632367] Mount-cache hash table entries: 67108864 (order: 13, 
536870912 bytes)
[    5.634831] Mountpoint-cache hash table entries: 67108864 (order: 13, 
536870912 bytes)

Dentry cache has table needs about 16GB, Inode needs: 16GB.
This system has 16 Nodes, if it is reserved 2G per node, 32GB is not
enough for this system.

This code is generic, it may affect other platforms, so would you please
give some suggestions?

Thanks a lot.
Li


On 2016-02-17 16:56, Li Zhang wrote:
> This patch is based on Mel Gorman's old patch in the mailing list,
> https://lkml.org/lkml/2015/5/5/280 which is dicussed but it is
> fixed with a completion to wait for all memory initialised in
> page_alloc_init_late(). The solution in upstream is to fix the
> OOM problem on X86 with 24TB memory which allocates memory in
> page late initialisation.
> But for Power platform with 32TB memory, page paralle initilisation
> still causes a call trace in vfs_caches_init->inode_init() and
> inode hash table needs more memory.
> So this patch allocates 1GB for 0.25TB/node for large system as
> it is mentioned in https://lkml.org/lkml/2015/5/1/627.
> 
> This call trace is found on Power with 32TB memory, 1024CPUs, 16nodes.
> The log from dmesg as the following:
> 
> [    0.091780] Dentry cache hash table entries: 2147483648 (order: 18,
> 17179869184 bytes)
> [    2.891012] vmalloc: allocation failure, allocated 16021913600 of
> 17179934720 bytes
> [    2.891034] swapper/0: page allocation failure: order:0,
> mode:0x2080020
> [    2.891038] CPU: 0 PID: 0 Comm: swapper/0 Not tainted 4.4.0-0-ppc64
> [    2.891041] Call Trace:
> [    2.891046] [c0000000012bfa00] [c0000000007c4a50]
>                 .dump_stack+0xb4/0xb664 (unreliable)
> [    2.891051] [c0000000012bfa80] [c0000000001f93d4]
>                 .warn_alloc_failed+0x114/0x160
> [    2.891054] [c0000000012bfb30] [c00000000023c204]
>                 .__vmalloc_area_node+0x1a4/0x2b0
> [    2.891058] [c0000000012bfbf0] [c00000000023c3f4]
>                 .__vmalloc_node_range+0xe4/0x110
> [    2.891061] [c0000000012bfc90] [c00000000023c460]
>                 .__vmalloc_node+0x40/0x50
> [    2.891065] [c0000000012bfd10] [c000000000b67d60]
>                 .alloc_large_system_hash+0x134/0x2a4
> [    2.891068] [c0000000012bfdd0] [c000000000b70924]
>                 .inode_init+0xa4/0xf0
> [    2.891071] [c0000000012bfe60] [c000000000b706a0]
>                 .vfs_caches_init+0x80/0x144
> [    2.891074] [c0000000012bfef0] [c000000000b35208]
>                 .start_kernel+0x40c/0x4e0
> [    2.891078] [c0000000012bff90] [c000000000008cfc]
>                 start_here_common+0x20/0x4a4
> [    2.891080] Mem-Info:
> 
> Cc: Mel Gorman <mgorman@suse.de>
> Signed-off-by: Li Zhang <zhlcindy@linux.vnet.ibm.com>
> ---
>  mm/page_alloc.c | 11 +++++++++--
>  1 file changed, 9 insertions(+), 2 deletions(-)
> 
> diff --git a/mm/page_alloc.c b/mm/page_alloc.c
> index 838ca8bb..4847f25 100644
> --- a/mm/page_alloc.c
> +++ b/mm/page_alloc.c
> @@ -293,13 +293,20 @@ static inline bool update_defer_init(pg_data_t 
> *pgdat,
>  				unsigned long pfn, unsigned long zone_end,
>  				unsigned long *nr_initialised)
>  {
> +	unsigned long max_initialise;
> +
>  	/* Always populate low zones for address-contrained allocations */
>  	if (zone_end < pgdat_end_pfn(pgdat))
>  		return true;
> +	/*
> +	* Initialise at least 2G of a node but also take into account that
> +	* two large system hashes that can take up 1GB for 0.25TB/node.
> +	*/
> +	max_initialise = max(2UL << (30 - PAGE_SHIFT),
> +		(pgdat->node_spanned_pages >> 8));
> 
> -	/* Initialise at least 2G of the highest zone */
>  	(*nr_initialised)++;
> -	if (*nr_initialised > (2UL << (30 - PAGE_SHIFT)) &&
> +	if ((*nr_initialised > max_initialise) &&
>  	    (pfn & (PAGES_PER_SECTION - 1)) == 0) {
>  		pgdat->first_deferred_pfn = pfn;
>  		return false;

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
