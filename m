Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg1-f199.google.com (mail-pg1-f199.google.com [209.85.215.199])
	by kanga.kvack.org (Postfix) with ESMTP id 655266B000A
	for <linux-mm@kvack.org>; Thu, 11 Oct 2018 18:16:59 -0400 (EDT)
Received: by mail-pg1-f199.google.com with SMTP id e6-v6so7650866pge.5
        for <linux-mm@kvack.org>; Thu, 11 Oct 2018 15:16:59 -0700 (PDT)
Received: from mga18.intel.com (mga18.intel.com. [134.134.136.126])
        by mx.google.com with ESMTPS id r29-v6si24916614pff.262.2018.10.11.15.16.57
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 11 Oct 2018 15:16:57 -0700 (PDT)
Subject: [mm PATCH v2 4/6] mm: Do not set reserved flag for hotplug memory
From: Alexander Duyck <alexander.h.duyck@linux.intel.com>
Date: Thu, 11 Oct 2018 15:13:51 -0700
Message-ID: <20181011221351.1925.67694.stgit@localhost.localdomain>
In-Reply-To: <20181011221237.1925.85591.stgit@localhost.localdomain>
References: <20181011221237.1925.85591.stgit@localhost.localdomain>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, akpm@linux-foundation.org
Cc: pavel.tatashin@microsoft.com, mhocko@suse.com, dave.jiang@intel.com, alexander.h.duyck@linux.intel.com, linux-kernel@vger.kernel.org, willy@infradead.org, davem@davemloft.net, yi.z.zhang@linux.intel.com, khalid.aziz@oracle.com, rppt@linux.vnet.ibm.com, vbabka@suse.cz, sparclinux@vger.kernel.org, dan.j.williams@intel.com, ldufour@linux.vnet.ibm.com, mgorman@techsingularity.net, mingo@kernel.org, kirill.shutemov@linux.intel.com

The general suspicion at this point is that the setting of the reserved bit
is not really needed for hotplug memory. In addition the setting of this
bit results in issues for DAX in that it is not possible to assign the
region to KVM if the reserved bit is set in each page.

For now we can try just not setting the bit since we suspect it isn't
adding value in setting it. If at a later time we find that it is needed we
can come back through and re-add it for the hotplug paths.

Suggested-by: Michael Hocko <mhocko@suse.com>
Reported-by: Dan Williams <dan.j.williams@intel.com>
Signed-off-by: Alexander Duyck <alexander.h.duyck@linux.intel.com>
---
 mm/page_alloc.c |   11 -----------
 1 file changed, 11 deletions(-)

diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 3603d5444865..e435223e2ddb 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -5571,8 +5571,6 @@ void __meminit memmap_init_zone(unsigned long size, int nid, unsigned long zone,
 
 		page = pfn_to_page(pfn);
 		__init_single_page(page, pfn, zone, nid);
-		if (context == MEMMAP_HOTPLUG)
-			__SetPageReserved(page);
 
 		/*
 		 * Mark the block movable so that blocks are reserved for
@@ -5626,15 +5624,6 @@ void __ref memmap_init_zone_device(struct zone *zone,
 		__init_single_page(page, pfn, zone_idx, nid);
 
 		/*
-		 * Mark page reserved as it will need to wait for onlining
-		 * phase for it to be fully associated with a zone.
-		 *
-		 * We can use the non-atomic __set_bit operation for setting
-		 * the flag as we are still initializing the pages.
-		 */
-		__SetPageReserved(page);
-
-		/*
 		 * ZONE_DEVICE pages union ->lru with a ->pgmap back
 		 * pointer and hmm_data.  It is a bug if a ZONE_DEVICE
 		 * page is ever freed or placed on a driver-private list.
