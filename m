Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f54.google.com (mail-pa0-f54.google.com [209.85.220.54])
	by kanga.kvack.org (Postfix) with ESMTP id 94447680DC6
	for <linux-mm@kvack.org>; Sat,  3 Oct 2015 08:57:44 -0400 (EDT)
Received: by pacfv12 with SMTP id fv12so134197193pac.2
        for <linux-mm@kvack.org>; Sat, 03 Oct 2015 05:57:44 -0700 (PDT)
Received: from smtprelay.synopsys.com (us01smtprelay-2.synopsys.com. [198.182.47.9])
        by mx.google.com with ESMTPS id hd5si24461581pbb.257.2015.10.03.05.57.43
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 03 Oct 2015 05:57:43 -0700 (PDT)
From: Vineet Gupta <Vineet.Gupta1@synopsys.com>
Subject: New helper to free highmem pages in larger chunks
Message-ID: <560FD031.3030909@synopsys.com>
Date: Sat, 3 Oct 2015 18:25:13 +0530
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Robin Holt <robin.m.holt@gmail.com>, Nathan Zimmer <nzimmer@sgi.com>
Cc: Jiang Liu <liuj97@gmail.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-arch@vger.kernel.org" <linux-arch@vger.kernel.org>, lkml <linux-kernel@vger.kernel.org>, Mel Gorman <mgorman@suse.de>

Hi,

I noticed increased boot time when enabling highmem for ARC. Turns out that
freeing highmem pages into buddy allocator is done page at a time, while it is
batched for low mem pages. Below is call flow.

I'm thinking of writing free_highmem_pages() which takes start and end pfn and
want to solicit some ideas whether to write it from scratch or preferably call
existing __free_pages_memory() to reuse the logic to convert a pfn range into
{pfn, order} tuples.

For latter however there are semantical differences as you can see below which I'm
not sure of:
  -highmem page->count is set to 1, while 0 for low mem
  -atomic clearing of page reserved flag vs. non atomic


mem_init
     for (tmp = min_high_pfn; tmp < max_pfn; tmp++)
	free_highmem_page(pfn_to_page(tmp));
	     __free_reserved_page
		ClearPageReserved(page);   <--- atomic
		init_page_count(page);  <-- _count = 1
		__free_page(page);    <-- free SINGLE page


     free_all_bootmem
	free_low_memory_core_early
	   __free_memory_core(start, end)
	       __free_pages_memory(s_pfn, e_pfn) <- creates "order" sized batches
		    __free_pages_bootmem(pfn, order)
		        __free_pages_boot_core(start_page, start_pfn, order)
				loops from 0 to (1 << order)
				    __ClearPageReserved(p);   <-- non atomic
				    set_page_count(p, 0);  <--- _count = 0

				__free_pages(page, order);    <--- free BATCH

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
