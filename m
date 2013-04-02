Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx188.postini.com [74.125.245.188])
	by kanga.kvack.org (Postfix) with SMTP id 656636B0002
	for <linux-mm@kvack.org>; Tue,  2 Apr 2013 06:57:22 -0400 (EDT)
Received: from /spool/local
	by e23smtp05.au.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <liwanp@linux.vnet.ibm.com>;
	Tue, 2 Apr 2013 20:52:40 +1000
Received: from d23relay04.au.ibm.com (d23relay04.au.ibm.com [9.190.234.120])
	by d23dlp02.au.ibm.com (Postfix) with ESMTP id 5C5732BB0023
	for <linux-mm@kvack.org>; Tue,  2 Apr 2013 21:57:16 +1100 (EST)
Received: from d23av01.au.ibm.com (d23av01.au.ibm.com [9.190.234.96])
	by d23relay04.au.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id r32Ai4CN64094288
	for <linux-mm@kvack.org>; Tue, 2 Apr 2013 21:44:07 +1100
Received: from d23av01.au.ibm.com (loopback [127.0.0.1])
	by d23av01.au.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id r32AvCbA009894
	for <linux-mm@kvack.org>; Tue, 2 Apr 2013 21:57:12 +1100
Date: Tue, 2 Apr 2013 18:57:09 +0800
From: Wanpeng Li <liwanp@linux.vnet.ibm.com>
Subject: Re: [PATCH] x86: numa: mm: kill double initialization for NODE_DATA
Message-ID: <20130402105709.GA10095@hacker.(null)>
Reply-To: Wanpeng Li <liwanp@linux.vnet.ibm.com>
References: <1364897675-15523-1-git-send-email-linfeng@cn.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1364897675-15523-1-git-send-email-linfeng@cn.fujitsu.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Lin Feng <linfeng@cn.fujitsu.com>
Cc: tglx@linutronix.de, mingo@redhat.com, hpa@zytor.com, akpm@linux-foundation.org, linux-mm@kvack.org, x86@kernel.org, linux-kernel@vger.kernel.org, yinghai@kernel.org, wency@cn.fujitsu.com, tangchen@cn.fujitsu.com

On Tue, Apr 02, 2013 at 06:14:35PM +0800, Lin Feng wrote:
>We initialize node_id, node_start_pfn and node_spanned_pages for NODE_DATA in
>initmem_init() while the later two members are kept unused and will be
>recaculated soon in paging_init(), so remove the useless assignments.
>
>PS. For clarifying calling chains are showed as follows:
>setup_arch()
>  ...
>  initmem_init()
>    x86_numa_init()
>      numa_init()
>        numa_register_memblks()
>          setup_node_data()
>            NODE_DATA(nid)->node_id = nid;
>            NODE_DATA(nid)->node_start_pfn = start >> PAGE_SHIFT;
>            NODE_DATA(nid)->node_spanned_pages = (end - start) >> PAGE_SHIFT;
>  ...
>  x86_init.paging.pagetable_init()
>  paging_init()
>    ...
>    sparse_init()
>      sparse_early_usemaps_alloc_node()
>        sparse_early_usemaps_alloc_pgdat_section()
>          ___alloc_bootmem_node_nopanic()
>            __alloc_memory_core_early(pgdat->node_id,...)
>    ...
>    zone_sizes_init()
>      free_area_init_nodes()
>        free_area_init_node()
>          pgdat->node_id = nid;
>          pgdat->node_start_pfn = node_start_pfn;
>          calculate_node_totalpages();
>            pgdat->node_spanned_pages = totalpages;
>

You miss the nodes which could become online at some point, but not
online currently. 

Regards,
Wanpeng Li 

>
>Signed-off-by: Lin Feng <linfeng@cn.fujitsu.com>
>---
> arch/x86/mm/numa.c |    2 --
> 1 files changed, 0 insertions(+), 2 deletions(-)
>
>diff --git a/arch/x86/mm/numa.c b/arch/x86/mm/numa.c
>index 72fe01e..efdd08f 100644
>--- a/arch/x86/mm/numa.c
>+++ b/arch/x86/mm/numa.c
>@@ -230,8 +230,6 @@ static void __init setup_node_data(int nid, u64 start, u64 end)
> 	node_data[nid] = nd;
> 	memset(NODE_DATA(nid), 0, sizeof(pg_data_t));
> 	NODE_DATA(nid)->node_id = nid;
>-	NODE_DATA(nid)->node_start_pfn = start >> PAGE_SHIFT;
>-	NODE_DATA(nid)->node_spanned_pages = (end - start) >> PAGE_SHIFT;
>
> 	node_set_online(nid);
> }
>-- 
>1.7.1
>
>--
>To unsubscribe, send a message with 'unsubscribe linux-mm' in
>the body to majordomo@kvack.org.  For more info on Linux MM,
>see: http://www.linux-mm.org/ .
>Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
