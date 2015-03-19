Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f177.google.com (mail-pd0-f177.google.com [209.85.192.177])
	by kanga.kvack.org (Postfix) with ESMTP id 74A4B6B0071
	for <linux-mm@kvack.org>; Thu, 19 Mar 2015 13:08:41 -0400 (EDT)
Received: by pdbop1 with SMTP id op1so81663426pdb.2
        for <linux-mm@kvack.org>; Thu, 19 Mar 2015 10:08:41 -0700 (PDT)
Received: from mga09.intel.com (mga09.intel.com. [134.134.136.24])
        by mx.google.com with ESMTP id fe5si4251976pdb.39.2015.03.19.10.08.38
        for <linux-mm@kvack.org>;
        Thu, 19 Mar 2015 10:08:38 -0700 (PDT)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: [PATCH 08/16] page-flags: define behavior of Xen-related flags on compound pages
Date: Thu, 19 Mar 2015 19:08:14 +0200
Message-Id: <1426784902-125149-9-git-send-email-kirill.shutemov@linux.intel.com>
In-Reply-To: <1426784902-125149-1-git-send-email-kirill.shutemov@linux.intel.com>
References: <1426784902-125149-1-git-send-email-kirill.shutemov@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>, Hugh Dickins <hughd@google.com>
Cc: Dave Hansen <dave.hansen@intel.com>, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, Vlastimil Babka <vbabka@suse.cz>, Christoph Lameter <cl@gentwo.org>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Steve Capper <steve.capper@linaro.org>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>, Jerome Marchand <jmarchan@redhat.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

PG_pinned and PG_savepinned are about page table's pages which are never
compound.

I'm not so sure about PG_foreign, but it seems we shouldn't see compound
pages there too.

Let's use NO_COMPOUND for all of them.

Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
---
 include/linux/page-flags.h | 9 ++++++---
 1 file changed, 6 insertions(+), 3 deletions(-)

diff --git a/include/linux/page-flags.h b/include/linux/page-flags.h
index d41c63b566b8..19373c98d08a 100644
--- a/include/linux/page-flags.h
+++ b/include/linux/page-flags.h
@@ -282,9 +282,12 @@ PAGEFLAG(Active, active, HEAD) __CLEARPAGEFLAG(Active, active, HEAD)
 __PAGEFLAG(Slab, slab, NO_TAIL)
 __PAGEFLAG(SlobFree, slob_free, NO_TAIL)
 PAGEFLAG(Checked, checked, NO_COMPOUND) /* Used by some filesystems */
-PAGEFLAG(Pinned, pinned, ANY) TESTSCFLAG(Pinned, pinned, ANY)	/* Xen */
-PAGEFLAG(SavePinned, savepinned, ANY);			/* Xen */
-PAGEFLAG(Foreign, foreign, ANY);				/* Xen */
+
+/* Xen */
+PAGEFLAG(Pinned, pinned, NO_COMPOUND) TESTSCFLAG(Pinned, pinned, NO_COMPOUND)
+PAGEFLAG(SavePinned, savepinned, NO_COMPOUND)
+PAGEFLAG(Foreign, foreign, NO_COMPOUND)
+
 PAGEFLAG(Reserved, reserved, ANY) __CLEARPAGEFLAG(Reserved, reserved, ANY)
 PAGEFLAG(SwapBacked, swapbacked, ANY)
 	__CLEARPAGEFLAG(SwapBacked, swapbacked, ANY)
-- 
2.1.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
