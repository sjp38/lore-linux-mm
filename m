Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk1-f197.google.com (mail-qk1-f197.google.com [209.85.222.197])
	by kanga.kvack.org (Postfix) with ESMTP id 218B86B744D
	for <linux-mm@kvack.org>; Wed,  5 Dec 2018 07:30:22 -0500 (EST)
Received: by mail-qk1-f197.google.com with SMTP id n68so19567063qkn.8
        for <linux-mm@kvack.org>; Wed, 05 Dec 2018 04:30:22 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id g34si404232qte.104.2018.12.05.04.30.20
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 05 Dec 2018 04:30:20 -0800 (PST)
From: David Hildenbrand <david@redhat.com>
Subject: [PATCH RFC 7/7] mm: better document PG_reserved
Date: Wed,  5 Dec 2018 13:28:51 +0100
Message-Id: <20181205122851.5891-8-david@redhat.com>
In-Reply-To: <20181205122851.5891-1-david@redhat.com>
References: <20181205122851.5891-1-david@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org, linux-arm-kernel@lists.infradead.org, linux-m68k@lists.linux-m68k.org, linuxppc-dev@lists.ozlabs.org, linux-riscv@lists.infradead.org, linux-s390@vger.kernel.org, linux-mediatek@lists.infradead.org, David Hildenbrand <david@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Stephen Rothwell <sfr@canb.auug.org.au>, Pavel Tatashin <pasha.tatashin@oracle.com>, Michal Hocko <mhocko@suse.com>, Alexander Duyck <alexander.h.duyck@linux.intel.com>, Matthew Wilcox <willy@infradead.org>, Anthony Yznaga <anthony.yznaga@oracle.com>, Miles Chen <miles.chen@mediatek.com>, yi.z.zhang@linux.intel.com, Dan Williams <dan.j.williams@intel.com>

The usage of PG_reserved and how PG_reserved pages are to be treated is
burried deep down in different parts of the kernel. Let's shine some light
onto these details by documenting (most?) current users and expected
behavior.

I don't see a reason why we have to document "Some of them might not even
exist". If there is a user, we should document it. E.g. for balloon
drivers we now use PG_offline to indicate that a page might currently
not be backed by memory in the hypervisor. And that is independent from
PG_reserved.

Cc: Andrew Morton <akpm@linux-foundation.org>
Cc: Stephen Rothwell <sfr@canb.auug.org.au>
Cc: Pavel Tatashin <pasha.tatashin@oracle.com>
Cc: Michal Hocko <mhocko@suse.com>
Cc: Alexander Duyck <alexander.h.duyck@linux.intel.com>
Cc: Matthew Wilcox <willy@infradead.org>
Cc: Anthony Yznaga <anthony.yznaga@oracle.com>
Cc: Miles Chen <miles.chen@mediatek.com>
Cc: yi.z.zhang@linux.intel.com
Cc: Dan Williams <dan.j.williams@intel.com>
Signed-off-by: David Hildenbrand <david@redhat.com>
---
 include/linux/page-flags.h | 18 ++++++++++++++++--
 1 file changed, 16 insertions(+), 2 deletions(-)

diff --git a/include/linux/page-flags.h b/include/linux/page-flags.h
index 68b8495e2fbc..112526f5ba61 100644
--- a/include/linux/page-flags.h
+++ b/include/linux/page-flags.h
@@ -17,8 +17,22 @@
 /*
  * Various page->flags bits:
  *
- * PG_reserved is set for special pages, which can never be swapped out. Some
- * of them might not even exist...
+ * PG_reserved is set for special pages. The "struct page" of such a page
+ * should in general not be touched (e.g. set dirty) except by their owner.
+ * Pages marked as PG_reserved include:
+ * - Kernel image (including vDSO) and similar (e.g. BIOS, initrd)
+ * - Pages allocated early during boot (bootmem, memblock)
+ * - Zero pages
+ * - Pages that have been associated with a zone but are not available for
+ *   the page allocator (e.g. excluded via online_page_callback())
+ * - Pages to exclude from the hibernation image (e.g. loaded kexec images)
+ * - MMIO pages (communicate with a device, special caching strategy needed)
+ * - MCA pages on ia64 (pages with memory errors)
+ * - Device memory (e.g. PMEM, DAX, HMM)
+ * Some architectures don't allow to ioremap pages that are not marked
+ * PG_reserved (as they might be in use by somebody else who does not respect
+ * the caching strategy). Consequently, PG_reserved for a page mapped into
+ * user space can indicate the zero page, the vDSO, MMIO pages or device memory.
  *
  * The PG_private bitflag is set on pagecache pages if they contain filesystem
  * specific data (which is normally at page->private). It can be used by
-- 
2.17.2
