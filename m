Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f41.google.com (mail-pa0-f41.google.com [209.85.220.41])
	by kanga.kvack.org (Postfix) with ESMTP id C168182F66
	for <linux-mm@kvack.org>; Thu, 24 Sep 2015 10:51:20 -0400 (EDT)
Received: by pacgz1 with SMTP id gz1so8605598pac.3
        for <linux-mm@kvack.org>; Thu, 24 Sep 2015 07:51:20 -0700 (PDT)
Received: from mga09.intel.com (mga09.intel.com. [134.134.136.24])
        by mx.google.com with ESMTP id rn14si4045584pab.184.2015.09.24.07.51.19
        for <linux-mm@kvack.org>;
        Thu, 24 Sep 2015 07:51:19 -0700 (PDT)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: [PATCH 07/16] page-flags: define behavior SL*B-related flags on compound pages
Date: Thu, 24 Sep 2015 17:50:55 +0300
Message-Id: <1443106264-78075-8-git-send-email-kirill.shutemov@linux.intel.com>
In-Reply-To: <1443106264-78075-1-git-send-email-kirill.shutemov@linux.intel.com>
References: <20150921153509.fef7ecdf313ef74307c43b65@linux-foundation.org>
 <1443106264-78075-1-git-send-email-kirill.shutemov@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Andrea Arcangeli <aarcange@redhat.com>, Hugh Dickins <hughd@google.com>, Dave Hansen <dave.hansen@intel.com>, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, Vlastimil Babka <vbabka@suse.cz>, Christoph Lameter <cl@gentwo.org>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Steve Capper <steve.capper@linaro.org>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>, Jerome Marchand <jmarchan@redhat.com>, Sasha Levin <sasha.levin@oracle.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

SL*B uses compound pages and marks head pages with PG_slab.
__SetPageSlab() and __ClearPageSlab() are never called for tail pages.

The same situation with PG_slob_free in SLOB allocator.

PF_NO_TAIL is appropriate for these flags.

Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
---
 include/linux/page-flags.h | 5 ++---
 1 file changed, 2 insertions(+), 3 deletions(-)

diff --git a/include/linux/page-flags.h b/include/linux/page-flags.h
index 10b75615ddf2..c9cd82310e2d 100644
--- a/include/linux/page-flags.h
+++ b/include/linux/page-flags.h
@@ -254,7 +254,8 @@ PAGEFLAG(Dirty, dirty, PF_HEAD) TESTSCFLAG(Dirty, dirty, PF_HEAD)
 PAGEFLAG(LRU, lru, PF_HEAD) __CLEARPAGEFLAG(LRU, lru, PF_HEAD)
 PAGEFLAG(Active, active, PF_HEAD) __CLEARPAGEFLAG(Active, active, PF_HEAD)
 	TESTCLEARFLAG(Active, active, PF_HEAD)
-__PAGEFLAG(Slab, slab, PF_ANY)
+__PAGEFLAG(Slab, slab, PF_NO_TAIL)
+__PAGEFLAG(SlobFree, slob_free, PF_NO_TAIL)
 PAGEFLAG(Checked, checked, PF_NO_COMPOUND)	   /* Used by some filesystems */
 PAGEFLAG(Pinned, pinned, PF_ANY) TESTSCFLAG(Pinned, pinned, PF_ANY)	/* Xen */
 PAGEFLAG(SavePinned, savepinned, PF_ANY);			/* Xen */
@@ -264,8 +265,6 @@ PAGEFLAG(SwapBacked, swapbacked, PF_ANY)
 	__CLEARPAGEFLAG(SwapBacked, swapbacked, PF_ANY)
 	__SETPAGEFLAG(SwapBacked, swapbacked, PF_ANY)
 
-__PAGEFLAG(SlobFree, slob_free, PF_ANY)
-
 /*
  * Private page markings that may be used by the filesystem that owns the page
  * for its own purposes.
-- 
2.5.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
