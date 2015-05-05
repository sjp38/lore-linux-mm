Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f176.google.com (mail-pd0-f176.google.com [209.85.192.176])
	by kanga.kvack.org (Postfix) with ESMTP id ABCBA6B0038
	for <linux-mm@kvack.org>; Tue,  5 May 2015 17:29:50 -0400 (EDT)
Received: by pdbqd1 with SMTP id qd1so209630101pdb.2
        for <linux-mm@kvack.org>; Tue, 05 May 2015 14:29:50 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id km1si26187322pab.155.2015.05.05.14.29.49
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 05 May 2015 14:29:49 -0700 (PDT)
Date: Tue, 5 May 2015 14:29:48 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH v2] CMA: page_isolation: check buddy before access it
Message-Id: <20150505142948.7fe0371558a581dbd9d52c51@linux-foundation.org>
In-Reply-To: <1430796179-1795-1-git-send-email-zhuhui@xiaomi.com>
References: <1430732477-16977-1-git-send-email-zhuhui@xiaomi.com>
	<1430796179-1795-1-git-send-email-zhuhui@xiaomi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hui Zhu <zhuhui@xiaomi.com>
Cc: vbabka@suse.cz, iamjoonsoo.kim@lge.com, lauraa@codeaurora.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, teawater@gmail.com

On Tue, 5 May 2015 11:22:59 +0800 Hui Zhu <zhuhui@xiaomi.com> wrote:

> Change pfn_present to pfn_valid_within according to the review of Laura.
> 
> I got a issue:
> [  214.294917] Unable to handle kernel NULL pointer dereference at virtual address 0000082a
> [  214.303013] pgd = cc970000
> [  214.305721] [0000082a] *pgd=00000000
> [  214.309316] Internal error: Oops: 5 [#1] PREEMPT SMP ARM
> [  214.335704] PC is at get_pageblock_flags_group+0x5c/0xb0
> [  214.341030] LR is at unset_migratetype_isolate+0x148/0x1b0
> [  214.346523] pc : [<c00cc9a0>]    lr : [<c0109874>]    psr: 80000093
> [  214.346523] sp : c7029d00  ip : 00000105  fp : c7029d1c
> [  214.358005] r10: 00000001  r9 : 0000000a  r8 : 00000004
> [  214.363231] r7 : 60000013  r6 : 000000a4  r5 : c0a357e4  r4 : 00000000
> [  214.369761] r3 : 00000826  r2 : 00000002  r1 : 00000000  r0 : 0000003f
> [  214.376291] Flags: Nzcv  IRQs off  FIQs on  Mode SVC_32  ISA ARM  Segment user
> [  214.383516] Control: 10c5387d  Table: 2cb7006a  DAC: 00000015
> [  214.949720] Backtrace:
> [  214.952192] [<c00cc944>] (get_pageblock_flags_group+0x0/0xb0) from [<c0109874>] (unset_migratetype_isolate+0x148/0x1b0)
> [  214.962978]  r7:60000013 r6:c0a357c0 r5:c0a357e4 r4:c1555000
> [  214.968693] [<c010972c>] (unset_migratetype_isolate+0x0/0x1b0) from [<c0109adc>] (undo_isolate_page_range+0xd0/0xdc)
> [  214.979222] [<c0109a0c>] (undo_isolate_page_range+0x0/0xdc) from [<c00d097c>] (__alloc_contig_range+0x254/0x34c)
> [  214.989398]  r9:000abc00 r8:c7028000 r7:000b1f53 r6:000b3e00 r5:00000005
> r4:c7029db4
> [  214.997308] [<c00d0728>] (__alloc_contig_range+0x0/0x34c) from [<c00d0a88>] (alloc_contig_range+0x14/0x18)
> [  215.006973] [<c00d0a74>] (alloc_contig_range+0x0/0x18) from [<c0398148>] (dma_alloc_from_contiguous_addr+0x1ac/0x304)
> 
> This issue is because when call unset_migratetype_isolate to unset a part
> of CMA memory, it try to access the buddy page to get its status:
> 		if (order >= pageblock_order) {
> 			page_idx = page_to_pfn(page) & ((1 << MAX_ORDER) - 1);
> 			buddy_idx = __find_buddy_index(page_idx, order);
> 			buddy = page + (buddy_idx - page_idx);
> 
> 			if (!is_migrate_isolate_page(buddy)) {
> But the begin addr of this part of CMA memory is very close to a part of
> memory that is reserved in the boot time (not in buddy system).
> So add a check before access it.
> 
> ...
>
> --- a/mm/page_isolation.c
> +++ b/mm/page_isolation.c
> @@ -101,7 +101,8 @@ void unset_migratetype_isolate(struct page *page, unsigned migratetype)
>  			buddy_idx = __find_buddy_index(page_idx, order);
>  			buddy = page + (buddy_idx - page_idx);
>  
> -			if (!is_migrate_isolate_page(buddy)) {
> +			if (!pfn_valid_within(page_to_pfn(buddy))
> +			    || !is_migrate_isolate_page(buddy)) {
>  				__isolate_free_page(page, order);
>  				kernel_map_pages(page, (1 << order), 1);
>  				set_page_refcounted(page);

This fix is needed in kernel versions 4.0.x isn't it?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
