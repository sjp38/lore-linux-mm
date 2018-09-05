Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf1-f197.google.com (mail-pf1-f197.google.com [209.85.210.197])
	by kanga.kvack.org (Postfix) with ESMTP id C30CA6B7530
	for <linux-mm@kvack.org>; Wed,  5 Sep 2018 17:13:36 -0400 (EDT)
Received: by mail-pf1-f197.google.com with SMTP id v9-v6so4622237pff.4
        for <linux-mm@kvack.org>; Wed, 05 Sep 2018 14:13:36 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id g16-v6sor607633pgg.427.2018.09.05.14.13.35
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 05 Sep 2018 14:13:35 -0700 (PDT)
Subject: [PATCH v2 2/2] mm: Create non-atomic version of SetPageReserved for
 init use
From: Alexander Duyck <alexander.duyck@gmail.com>
Date: Wed, 05 Sep 2018 14:13:34 -0700
Message-ID: <20180905211334.3286.84435.stgit@localhost.localdomain>
In-Reply-To: <20180905211041.3286.19083.stgit@localhost.localdomain>
References: <20180905211041.3286.19083.stgit@localhost.localdomain>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, linux-kernel@vger.kernel.org
Cc: alexander.h.duyck@intel.com, pavel.tatashin@microsoft.com, mhocko@suse.com, dave.hansen@intel.com, akpm@linux-foundation.org, mingo@kernel.org, kirill.shutemov@linux.intel.com

From: Alexander Duyck <alexander.h.duyck@intel.com>

It doesn't make much sense to use the atomic SetPageReserved at init time
when we are using memset to clear the memory and manipulating the page
flags via simple "&=" and "|=" operations in __init_single_page.

This patch adds a non-atomic version __SetPageReserved that can be used
during page init and shows about a 10% improvement in initialization times
on the systems I have available for testing.

I tried adding a bit of documentation based on commit <f1dd2cd13c4> ("mm,
memory_hotplug: do not associate hotadded memory to zones until online").

Ideally the reserved flag should be set earlier since there is a brief
window where the page is initialization via __init_single_page and we have
not set the PG_Reserved flag. I'm leaving that for a future patch set as
that will require a more significant refactor.

Acked-by: Michal Hocko <mhocko@suse.com>
Signed-off-by: Alexander Duyck <alexander.h.duyck@intel.com>
---
 include/linux/page-flags.h |    1 +
 mm/page_alloc.c            |   13 +++++++++++--
 2 files changed, 12 insertions(+), 2 deletions(-)

diff --git a/include/linux/page-flags.h b/include/linux/page-flags.h
index 0e95ca63375a..daee3ea2d1ed 100644
--- a/include/linux/page-flags.h
+++ b/include/linux/page-flags.h
@@ -300,6 +300,7 @@ static inline void page_init_poison(struct page *page, size_t size)
 
 PAGEFLAG(Reserved, reserved, PF_NO_COMPOUND)
 	__CLEARPAGEFLAG(Reserved, reserved, PF_NO_COMPOUND)
+	__SETPAGEFLAG(Reserved, reserved, PF_NO_COMPOUND)
 PAGEFLAG(SwapBacked, swapbacked, PF_NO_TAIL)
 	__CLEARPAGEFLAG(SwapBacked, swapbacked, PF_NO_TAIL)
 	__SETPAGEFLAG(SwapBacked, swapbacked, PF_NO_TAIL)
diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 05e983f42316..f2602021032f 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -1231,7 +1231,8 @@ void __meminit reserve_bootmem_region(phys_addr_t start, phys_addr_t end)
 			/* Avoid false-positive PageTail() */
 			INIT_LIST_HEAD(&page->lru);
 
-			SetPageReserved(page);
+			/* no need for atomic set_bit at init time */
+			__SetPageReserved(page);
 		}
 	}
 }
@@ -5517,8 +5518,16 @@ void __meminit memmap_init_zone(unsigned long size, int nid, unsigned long zone,
 not_early:
 		page = pfn_to_page(pfn);
 		__init_single_page(page, pfn, zone, nid);
+
+		/*
+		 * Mark page reserved as it will need to wait for onlining
+		 * phase for it to be fully associated with a zone.
+		 *
+		 * We can use the non-atomic __set_bit operation for setting
+		 * the flag as we are still initializing the pages.
+		 */
 		if (context == MEMMAP_HOTPLUG)
-			SetPageReserved(page);
+			__SetPageReserved(page);
 
 		/*
 		 * Mark the block movable so that blocks are reserved for
