Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf1-f198.google.com (mail-pf1-f198.google.com [209.85.210.198])
	by kanga.kvack.org (Postfix) with ESMTP id A43B18E00A4
	for <linux-mm@kvack.org>; Tue, 25 Sep 2018 16:21:14 -0400 (EDT)
Received: by mail-pf1-f198.google.com with SMTP id x85-v6so13241993pfe.13
        for <linux-mm@kvack.org>; Tue, 25 Sep 2018 13:21:14 -0700 (PDT)
Received: from mga02.intel.com (mga02.intel.com. [134.134.136.20])
        by mx.google.com with ESMTPS id c63-v6si2892404pfb.178.2018.09.25.13.21.12
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 25 Sep 2018 13:21:13 -0700 (PDT)
Subject: [PATCH v5 3/4] mm: Create non-atomic version of SetPageReserved for
 init use
From: Alexander Duyck <alexander.h.duyck@linux.intel.com>
Date: Tue, 25 Sep 2018 13:20:47 -0700
Message-ID: <20180925202018.3576.11607.stgit@localhost.localdomain>
In-Reply-To: <20180925200551.3576.18755.stgit@localhost.localdomain>
References: <20180925200551.3576.18755.stgit@localhost.localdomain>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, akpm@linux-foundation.org, linux-kernel@vger.kernel.org, linux-nvdimm@lists.01.org
Cc: pavel.tatashin@microsoft.com, mhocko@suse.com, dave.jiang@intel.com, dave.hansen@intel.com, jglisse@redhat.com, rppt@linux.vnet.ibm.com, dan.j.williams@intel.com, logang@deltatee.com, mingo@kernel.org, kirill.shutemov@linux.intel.com

It doesn't make much sense to use the atomic SetPageReserved at init time
when we are using memset to clear the memory and manipulating the page
flags via simple "&=" and "|=" operations in __init_single_page.

This patch adds a non-atomic version __SetPageReserved that can be used
during page init and shows about a 10% improvement in initialization times
on the systems I have available for testing. On those systems I saw
initialization times drop from around 35 seconds to around 32 seconds to
initialize a 3TB block of persistent memory. I believe the main advantage
of this is that it allows for more compiler optimization as the __set_bit
operation can be reordered whereas the atomic version cannot.

I tried adding a bit of documentation based on commit <f1dd2cd13c4> ("mm,
memory_hotplug: do not associate hotadded memory to zones until online").

Ideally the reserved flag should be set earlier since there is a brief
window where the page is initialization via __init_single_page and we have
not set the PG_Reserved flag. I'm leaving that for a future patch set as
that will require a more significant refactor.

Acked-by: Michal Hocko <mhocko@suse.com>
Reviewed-by: Pavel Tatashin <pavel.tatashin@microsoft.com>
Signed-off-by: Alexander Duyck <alexander.h.duyck@linux.intel.com>
---

v4: Added comment about __set_bit vs set_bit to the patch description
v5: No change

 include/linux/page-flags.h |    1 +
 mm/page_alloc.c            |    9 +++++++--
 2 files changed, 8 insertions(+), 2 deletions(-)

diff --git a/include/linux/page-flags.h b/include/linux/page-flags.h
index 934f91ef3f54..50ce1bddaf56 100644
--- a/include/linux/page-flags.h
+++ b/include/linux/page-flags.h
@@ -303,6 +303,7 @@ static inline void page_init_poison(struct page *page, size_t size)
 
 PAGEFLAG(Reserved, reserved, PF_NO_COMPOUND)
 	__CLEARPAGEFLAG(Reserved, reserved, PF_NO_COMPOUND)
+	__SETPAGEFLAG(Reserved, reserved, PF_NO_COMPOUND)
 PAGEFLAG(SwapBacked, swapbacked, PF_NO_TAIL)
 	__CLEARPAGEFLAG(SwapBacked, swapbacked, PF_NO_TAIL)
 	__SETPAGEFLAG(SwapBacked, swapbacked, PF_NO_TAIL)
diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 511447ac02cf..926ad3083b28 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -1238,7 +1238,12 @@ void __meminit reserve_bootmem_region(phys_addr_t start, phys_addr_t end)
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
@@ -5512,7 +5517,7 @@ void __meminit memmap_init_zone(unsigned long size, int nid, unsigned long zone,
 		page = pfn_to_page(pfn);
 		__init_single_page(page, pfn, zone, nid);
 		if (context == MEMMAP_HOTPLUG)
-			SetPageReserved(page);
+			__SetPageReserved(page);
 
 		/*
 		 * Mark the block movable so that blocks are reserved for
