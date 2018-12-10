Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f70.google.com (mail-ed1-f70.google.com [209.85.208.70])
	by kanga.kvack.org (Postfix) with ESMTP id 3D9E28E0018
	for <linux-mm@kvack.org>; Mon, 10 Dec 2018 10:10:08 -0500 (EST)
Received: by mail-ed1-f70.google.com with SMTP id e12so5448327edd.16
        for <linux-mm@kvack.org>; Mon, 10 Dec 2018 07:10:08 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id e28sor6438092edb.24.2018.12.10.07.10.06
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 10 Dec 2018 07:10:06 -0800 (PST)
Date: Mon, 10 Dec 2018 15:10:05 +0000
From: Wei Yang <richard.weiyang@gmail.com>
Subject: Re: [PATCH 1/1] mm, memory_hotplug: Initialize struct pages for the
 full memory section
Message-ID: <20181210151005.xukiibwbb6ohqyex@master>
Reply-To: Wei Yang <richard.weiyang@gmail.com>
References: <20181210130712.30148-1-zaslonko@linux.ibm.com>
 <20181210130712.30148-2-zaslonko@linux.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20181210130712.30148-2-zaslonko@linux.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mikhail Zaslonko <zaslonko@linux.ibm.com>
Cc: akpm@linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, mhocko@kernel.org, Pavel.Tatashin@microsoft.com, schwidefsky@de.ibm.com, heiko.carstens@de.ibm.com, gerald.schaefer@de.ibm.com

On Mon, Dec 10, 2018 at 02:07:12PM +0100, Mikhail Zaslonko wrote:
>If memory end is not aligned with the sparse memory section boundary, the
>mapping of such a section is only partly initialized. This may lead to
>VM_BUG_ON due to uninitialized struct page access from
>is_mem_section_removable() or test_pages_in_a_zone() function triggered by
>memory_hotplug sysfs handlers:
>
> page:000003d082008000 is uninitialized and poisoned
> page dumped because: VM_BUG_ON_PAGE(PagePoisoned(p))
> Call Trace:
> ([<0000000000385b26>] test_pages_in_a_zone+0xde/0x160)
>  [<00000000008f15c4>] show_valid_zones+0x5c/0x190
>  [<00000000008cf9c4>] dev_attr_show+0x34/0x70
>  [<0000000000463ad0>] sysfs_kf_seq_show+0xc8/0x148
>  [<00000000003e4194>] seq_read+0x204/0x480
>  [<00000000003b53ea>] __vfs_read+0x32/0x178
>  [<00000000003b55b2>] vfs_read+0x82/0x138
>  [<00000000003b5be2>] ksys_read+0x5a/0xb0
>  [<0000000000b86ba0>] system_call+0xdc/0x2d8
> Last Breaking-Event-Address:
>  [<0000000000385b26>] test_pages_in_a_zone+0xde/0x160
> Kernel panic - not syncing: Fatal exception: panic_on_oops
>
>Fix the problem by initializing the last memory section of the highest zone
>in memmap_init_zone() till the very end, even if it goes beyond the zone
>end.
>
>Signed-off-by: Mikhail Zaslonko <zaslonko@linux.ibm.com>
>Reviewed-by: Gerald Schaefer <gerald.schaefer@de.ibm.com>
>Cc: <stable@vger.kernel.org>
>---
> mm/page_alloc.c | 15 +++++++++++++++
> 1 file changed, 15 insertions(+)
>
>diff --git a/mm/page_alloc.c b/mm/page_alloc.c
>index 2ec9cc407216..41ef5508e5f1 100644
>--- a/mm/page_alloc.c
>+++ b/mm/page_alloc.c
>@@ -5542,6 +5542,21 @@ void __meminit memmap_init_zone(unsigned long size, int nid, unsigned long zone,
> 			cond_resched();
> 		}
> 	}
>+#ifdef CONFIG_SPARSEMEM
>+	/*
>+	 * If there is no zone spanning the rest of the section
>+	 * then we should at least initialize those pages. Otherwise we
>+	 * could blow up on a poisoned page in some paths which depend
>+	 * on full sections being initialized (e.g. memory hotplug).
>+	 */
>+	if (end_pfn == max_pfn) {
>+		while (end_pfn % PAGES_PER_SECTION) {
>+			__init_single_page(pfn_to_page(end_pfn), end_pfn, zone,
>+					   nid);
>+			end_pfn++;
>+		}
>+	}
>+#endif

If my understanding is correct, end_pfn is not a valid range.

memmap_init_zone() initialize the range [start_pfn, start_pfn + size). I
am afraid this will break the syntax. 

And max_pfn is also not a valid one. For example, on x86,
update_end_of_memory_vars() will update max_pfn, which is calculated by:

    end_pfn = PFN_UP(start + size);

BTW, as you mentioned this apply to hotplug case. And then why this couldn't
happen during boot up? What differ these two cases?

> }
> 
> #ifdef CONFIG_ZONE_DEVICE
>-- 
>2.16.4

-- 
Wei Yang
Help you, Help me
