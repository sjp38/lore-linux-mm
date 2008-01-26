Date: Sat, 26 Jan 2008 17:18:03 +0000
From: Mel Gorman <mel@csn.ul.ie>
Subject: Re: [PATCH 0/2] Relax restrictions on setting CONFIG_NUMA on x86
Message-ID: <20080126171803.GA29252@csn.ul.ie>
References: <20080118153529.12646.5260.sendpatchset@skynet.skynet.ie> <20080121093702.8FC2.KOSAKI.MOTOHIRO@jp.fujitsu.com> <20080123105810.F295.KOSAKI.MOTOHIRO@jp.fujitsu.com> <20080123102332.GB21455@csn.ul.ie> <2f11576a0801260610m29f4e7ecle9828d8bbaa462cd@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <2f11576a0801260610m29f4e7ecle9828d8bbaa462cd@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: mingo@elte.hu, linux-mm@kvack.org, linux-kernel@vger.kernel.org, apw@shadowen.org, kosaki.motohiro@gmail.com
List-ID: <linux-mm.kvack.org>

On (26/01/08 23:10), KOSAKI Motohiro didst pronounce:
> Hi Mel
> 
> 
> >To rule it out, can you also try with the patch below applied please? It
> >should only make a difference on sparsemem so if discontigmem is still
> >crashing, there is likely another problem. Assuming it crashes, please
> >post the full dmesg output with loglevel=8 on the command line. Thanks
> 
> I buy reverse serial cable today.
> and I test again.
> 

Great

> my patch stack is
>   2.6.24-rc7 +
>   http://lkml.org/lkml/2007/8/24/220 +

Can you replace this patch with the patch below instead and try again
please? This is the patch that is actually in git-x86. Out of
curiousity, have you tried the latest mm branch from git-x86?

commit c824d2f33bf41e806cc975e659a711ba14927b62
diff --git a/arch/x86/mm/discontig_32.c b/arch/x86/mm/discontig_32.c
index 88a7499..9f1d02c 100644
--- a/arch/x86/mm/discontig_32.c
+++ b/arch/x86/mm/discontig_32.c
@@ -268,6 +268,7 @@ unsigned long __init setup_memory(void)
 {
 	int nid;
 	unsigned long system_start_pfn, system_max_low_pfn;
+	unsigned long wasted_pages;
 
 	/*
 	 * When mapping a NUMA machine we allocate the node_mem_map arrays
@@ -292,7 +293,14 @@ unsigned long __init setup_memory(void)
 		kva_start_pfn = PFN_DOWN(initrd_start - PAGE_OFFSET)
 			- kva_pages;
 #endif
-	kva_start_pfn -= kva_start_pfn & (PTRS_PER_PTE-1);
+
+	/*
+	 * We waste pages past at the end of the KVA for no good reason other
+	 * than how it is located. This is bad.
+	 */
+	wasted_pages = kva_start_pfn & (PTRS_PER_PTE-1);
+	kva_start_pfn -= wasted_pages;
+	kva_pages += wasted_pages;
 
 	system_max_low_pfn = max_low_pfn = find_max_low_pfn();
 	printk("kva_start_pfn ~ %ld find_max_low_pfn() ~ %ld\n",
@@ -345,7 +353,8 @@ unsigned long __init setup_memory(void)
 
 void __init numa_kva_reserve(void)
 {
-	reserve_bootmem(PFN_PHYS(kva_start_pfn),PFN_PHYS(kva_pages));
+	if (kva_pages)
+		reserve_bootmem(PFN_PHYS(kva_start_pfn), PFN_PHYS(kva_pages));
 }
 
 void __init zone_sizes_init(void)

-- 
Mel Gorman
Part-time Phd Student                          Linux Technology Center
University of Limerick                         IBM Dublin Software Lab

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
