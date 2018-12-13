Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f70.google.com (mail-ed1-f70.google.com [209.85.208.70])
	by kanga.kvack.org (Postfix) with ESMTP id 5460E8E0161
	for <linux-mm@kvack.org>; Wed, 12 Dec 2018 22:46:18 -0500 (EST)
Received: by mail-ed1-f70.google.com with SMTP id c34so504534edb.8
        for <linux-mm@kvack.org>; Wed, 12 Dec 2018 19:46:18 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id z25-v6sor235512eja.49.2018.12.12.19.46.16
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 12 Dec 2018 19:46:16 -0800 (PST)
Date: Thu, 13 Dec 2018 03:46:15 +0000
From: Wei Yang <richard.weiyang@gmail.com>
Subject: Re: [PATCH v2 1/1] mm, memory_hotplug: Initialize struct pages for
 the full memory section
Message-ID: <20181213034615.4ntpo4cl2oo5mcx4@master>
Reply-To: Wei Yang <richard.weiyang@gmail.com>
References: <20181212172712.34019-1-zaslonko@linux.ibm.com>
 <20181212172712.34019-2-zaslonko@linux.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20181212172712.34019-2-zaslonko@linux.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mikhail Zaslonko <zaslonko@linux.ibm.com>
Cc: akpm@linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, mhocko@kernel.org, Pavel.Tatashin@microsoft.com, schwidefsky@de.ibm.com, heiko.carstens@de.ibm.com, gerald.schaefer@de.ibm.com

On Wed, Dec 12, 2018 at 06:27:12PM +0100, Mikhail Zaslonko wrote:
>If memory end is not aligned with the sparse memory section boundary, the
>mapping of such a section is only partly initialized. This may lead to
>VM_BUG_ON due to uninitialized struct page access from
>is_mem_section_removable() or test_pages_in_a_zone() function triggered by
>memory_hotplug sysfs handlers:
>
>Here are the the panic examples:
> CONFIG_DEBUG_VM=y
> CONFIG_DEBUG_VM_PGFLAGS=y
>
> kernel parameter mem=2050M
> --------------------------
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
> kernel parameter mem=3075M
> --------------------------
> page:000003d08300c000 is uninitialized and poisoned
> page dumped because: VM_BUG_ON_PAGE(PagePoisoned(p))
> Call Trace:
> ([<000000000038596c>] is_mem_section_removable+0xb4/0x190)
>  [<00000000008f12fa>] show_mem_removable+0x9a/0xd8
>  [<00000000008cf9c4>] dev_attr_show+0x34/0x70
>  [<0000000000463ad0>] sysfs_kf_seq_show+0xc8/0x148
>  [<00000000003e4194>] seq_read+0x204/0x480
>  [<00000000003b53ea>] __vfs_read+0x32/0x178
>  [<00000000003b55b2>] vfs_read+0x82/0x138
>  [<00000000003b5be2>] ksys_read+0x5a/0xb0
>  [<0000000000b86ba0>] system_call+0xdc/0x2d8
> Last Breaking-Event-Address:
>  [<000000000038596c>] is_mem_section_removable+0xb4/0x190
> Kernel panic - not syncing: Fatal exception: panic_on_oops
>
>Fix the problem by initializing the last memory section of each zone
>in memmap_init_zone() till the very end, even if it goes beyond the zone
>end.
>
>Signed-off-by: Mikhail Zaslonko <zaslonko@linux.ibm.com>
>Reviewed-by: Gerald Schaefer <gerald.schaefer@de.ibm.com>
>Cc: <stable@vger.kernel.org>
>---
> mm/page_alloc.c | 12 ++++++++++++
> 1 file changed, 12 insertions(+)
>
>diff --git a/mm/page_alloc.c b/mm/page_alloc.c
>index 2ec9cc407216..e2afdb2dc2c5 100644
>--- a/mm/page_alloc.c
>+++ b/mm/page_alloc.c
>@@ -5542,6 +5542,18 @@ void __meminit memmap_init_zone(unsigned long size, int nid, unsigned long zone,
> 			cond_resched();
> 		}
> 	}
>+#ifdef CONFIG_SPARSEMEM
>+	/*
>+	 * If the zone does not span the rest of the section then
>+	 * we should at least initialize those pages. Otherwise we
>+	 * could blow up on a poisoned page in some paths which depend
>+	 * on full sections being initialized (e.g. memory hotplug).
>+	 */
>+	while (end_pfn % PAGES_PER_SECTION) {
>+		__init_single_page(pfn_to_page(end_pfn), end_pfn, zone, nid);
>+		end_pfn++;
>+	}
>+#endif
> }

What will happen if the end_pfn is PAGES_PER_SECTION aligned, but there
is invalid pfn? For example, the page is skipped in the for loop of
memmap_init_zone()?

> 
> #ifdef CONFIG_ZONE_DEVICE
>-- 
>2.16.4

-- 
Wei Yang
Help you, Help me
