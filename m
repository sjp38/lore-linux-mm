Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg1-f199.google.com (mail-pg1-f199.google.com [209.85.215.199])
	by kanga.kvack.org (Postfix) with ESMTP id C92A18E0001
	for <linux-mm@kvack.org>; Mon, 10 Sep 2018 19:43:50 -0400 (EDT)
Received: by mail-pg1-f199.google.com with SMTP id f13-v6so11374655pgs.15
        for <linux-mm@kvack.org>; Mon, 10 Sep 2018 16:43:50 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id t8-v6sor3072510plz.147.2018.09.10.16.43.49
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 10 Sep 2018 16:43:49 -0700 (PDT)
Subject: [PATCH 2/4] mm: Create non-atomic version of SetPageReserved for
 init use
From: Alexander Duyck <alexander.duyck@gmail.com>
Date: Mon, 10 Sep 2018 16:43:48 -0700
Message-ID: <20180910234348.4068.92164.stgit@localhost.localdomain>
In-Reply-To: <20180910232615.4068.29155.stgit@localhost.localdomain>
References: <20180910232615.4068.29155.stgit@localhost.localdomain>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, linux-kernel@vger.kernel.org, linux-nvdimm@lists.01.org
Cc: pavel.tatashin@microsoft.com, mhocko@suse.com, dave.jiang@intel.com, mingo@kernel.org, dave.hansen@intel.com, jglisse@redhat.com, akpm@linux-foundation.org, logang@deltatee.com, dan.j.williams@intel.com, kirill.shutemov@linux.intel.com

From: Alexander Duyck <alexander.h.duyck@intel.com>

It doesn't make much sense to use the atomic SetPageReserved at init time
when we are using memset to clear the memory and manipulating the page
flags via simple "&=" and "|=" operations in __init_single_page.

This patch adds a non-atomic version __SetPageReserved that can be used
during page init and shows about a 10% improvement in initialization times
on the systems I have available for testing. On those systems I saw
initialization times drop from around 35 seconds to around 32 seconds to
initialize a 3TB block of persistent memory.

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
 mm/page_alloc.c            |   17 +++++++++++++++--
 2 files changed, 16 insertions(+), 2 deletions(-)

diff --git a/include/linux/page-flags.h b/include/linux/page-flags.h
index d00216cf00f8..1b1f8e0378ae 100644
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
index 89d2a2ab3fe6..a9b095a72fd9 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -1231,7 +1231,12 @@ void __meminit reserve_bootmem_region(phys_addr_t start, phys_addr_t end)
 			/* Avoid false-positive PageTail() */
 			INIT_LIST_HEAD(&page->lru);
 
-			SetPageReserved(page);
+			/*
+			 * no need for atomic set_bit because the struct
+			 * page is not visible yet so nobody should
+			 * access it yet.
+			 */
+			__SetPageReserved(page);
 		}
 	}
 }
@@ -5517,8 +5522,16 @@ void __meminit memmap_init_zone(unsigned long size, int nid, unsigned long zone,
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
