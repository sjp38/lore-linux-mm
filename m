Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ob0-f170.google.com (mail-ob0-f170.google.com [209.85.214.170])
	by kanga.kvack.org (Postfix) with ESMTP id 737D0900015
	for <linux-mm@kvack.org>; Thu, 19 Mar 2015 13:11:31 -0400 (EDT)
Received: by obcjt1 with SMTP id jt1so39362177obc.2
        for <linux-mm@kvack.org>; Thu, 19 Mar 2015 10:11:31 -0700 (PDT)
Received: from mga03.intel.com (mga03.intel.com. [134.134.136.65])
        by mx.google.com with ESMTP id e5si3801077pdf.253.2015.03.19.10.11.30
        for <linux-mm@kvack.org>;
        Thu, 19 Mar 2015 10:11:30 -0700 (PDT)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: [PATCH 07/16] page-flags: define behavior SL*B-related flags on compound pages
Date: Thu, 19 Mar 2015 19:08:13 +0200
Message-Id: <1426784902-125149-8-git-send-email-kirill.shutemov@linux.intel.com>
In-Reply-To: <1426784902-125149-1-git-send-email-kirill.shutemov@linux.intel.com>
References: <1426784902-125149-1-git-send-email-kirill.shutemov@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>, Hugh Dickins <hughd@google.com>
Cc: Dave Hansen <dave.hansen@intel.com>, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, Vlastimil Babka <vbabka@suse.cz>, Christoph Lameter <cl@gentwo.org>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Steve Capper <steve.capper@linaro.org>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>, Jerome Marchand <jmarchan@redhat.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

SL*B uses compound pages and marks head pages with PG_slab.
__SetPageSlab() and __ClearPageSlab() are never called for tail pages.

The same situation with PG_slob_free in SLOB allocator.

NO_TAIL is appropriate for these flags.

Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
---
 include/linux/page-flags.h | 5 ++---
 1 file changed, 2 insertions(+), 3 deletions(-)

diff --git a/include/linux/page-flags.h b/include/linux/page-flags.h
index bdb0d0e226c4..d41c63b566b8 100644
--- a/include/linux/page-flags.h
+++ b/include/linux/page-flags.h
@@ -279,7 +279,8 @@ PAGEFLAG(Dirty, dirty, HEAD) TESTSCFLAG(Dirty, dirty, HEAD)
 PAGEFLAG(LRU, lru, HEAD) __CLEARPAGEFLAG(LRU, lru, HEAD)
 PAGEFLAG(Active, active, HEAD) __CLEARPAGEFLAG(Active, active, HEAD)
 	TESTCLEARFLAG(Active, active, HEAD)
-__PAGEFLAG(Slab, slab, ANY)
+__PAGEFLAG(Slab, slab, NO_TAIL)
+__PAGEFLAG(SlobFree, slob_free, NO_TAIL)
 PAGEFLAG(Checked, checked, NO_COMPOUND) /* Used by some filesystems */
 PAGEFLAG(Pinned, pinned, ANY) TESTSCFLAG(Pinned, pinned, ANY)	/* Xen */
 PAGEFLAG(SavePinned, savepinned, ANY);			/* Xen */
@@ -289,8 +290,6 @@ PAGEFLAG(SwapBacked, swapbacked, ANY)
 	__CLEARPAGEFLAG(SwapBacked, swapbacked, ANY)
 	__SETPAGEFLAG(SwapBacked, swapbacked, ANY)
 
-__PAGEFLAG(SlobFree, slob_free, ANY)
-
 /*
  * Private page markings that may be used by the filesystem that owns the page
  * for its own purposes.
-- 
2.1.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
