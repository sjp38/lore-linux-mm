Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx156.postini.com [74.125.245.156])
	by kanga.kvack.org (Postfix) with SMTP id 01CD46B010D
	for <linux-mm@kvack.org>; Wed,  4 Apr 2012 21:10:07 -0400 (EDT)
Message-ID: <4F7CF0EF.2090302@codeaurora.org>
Date: Wed, 04 Apr 2012 18:10:07 -0700
From: Laura Abbott <lauraa@codeaurora.org>
MIME-Version: 1.0
Subject: Missing initialization of pages removed with memblock_remove
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-arm-kernel@lists.infradead.org, linux-arm-msm@vger.kernel.org, linux-mm@kvack.org
Cc: vgandhi@codeaurora.org, ohaugan@codeaurora.org

Hi,

We seem to have hit an odd edge case related to the use of 
memblock_remove. We carve out memory for certain use cases using 
memblock_remove, which gives a layout such as:

<4>[    0.000000] Zone PFN ranges:
<4>[    0.000000]   Normal   0x00080200 -> 0x000a1200
<4>[    0.000000]   HighMem  0x000a1200 -> 0x000c0000
<4>[    0.000000] Movable zone start PFN for each node
<4>[    0.000000] early_node_map[3] active PFN ranges
<4>[    0.000000]     0: 0x00080200 -> 0x00088f00
<4>[    0.000000]     0: 0x00090000 -> 0x000ac680
<4>[    0.000000]     0: 0x000b7a02 -> 0x000c0000

Since pfn_valid uses memblock_is_memory, pfn_valid will return false on 
all memory removed with memblock_remove. As a result, none of the page 
structures for the memblock_remove regions will have been initialized 
since memmap_init_zone calls pfn_valid before trying to initialize the 
memmap. Normally this isn't an issue but a recent test case ends up 
hitting a BUG_ON in move_freepages_block identical to the case in 
http://lists.infradead.org/pipermail/linux-arm-kernel/2011-August/059934.html
(BUG_ON(page_zone(start_page) != page_zone(end_page)))

What's happening is the calculation of start_page in 
move_freepages_block returns a page within a range removed by 
memblock_remove which means the page structure is uninitialized. (e.g. 
0xb7a02 -> 0xb7800)

I've read through that thread and several others which have discouraged 
use of CONFIG_HOLES_IN_ZONE due to the runtime overhead. The best 
alternative solution I've come up with is to align the memory removed 
via memblock_remove to MAX_ORDER_NR_PAGES but this will have a very high 
memory overhead for certain use cases.

A more fundamental question I have is should the page structures be 
initialized for the regions removed with memblock_remove? Internally, 
we've been divided on this issue and reading the source code hasn't 
given any indication of if this is expected behavior or not.

Any suggestions on what's the cleanest solution?

Thanks,
Laura
-- 
Sent by an employee of the Qualcomm Innovation Center, Inc.
The Qualcomm Innovation Center, Inc. is a member of the Code Aurora Forum.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
