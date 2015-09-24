Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f54.google.com (mail-pa0-f54.google.com [209.85.220.54])
	by kanga.kvack.org (Postfix) with ESMTP id C062182F66
	for <linux-mm@kvack.org>; Thu, 24 Sep 2015 10:51:38 -0400 (EDT)
Received: by pacgz1 with SMTP id gz1so8612189pac.3
        for <linux-mm@kvack.org>; Thu, 24 Sep 2015 07:51:38 -0700 (PDT)
Received: from mga01.intel.com (mga01.intel.com. [192.55.52.88])
        by mx.google.com with ESMTP id dl1si18899194pbb.159.2015.09.24.07.51.31
        for <linux-mm@kvack.org>;
        Thu, 24 Sep 2015 07:51:31 -0700 (PDT)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: [PATCH 08/16] page-flags: define behavior of Xen-related flags on compound pages
Date: Thu, 24 Sep 2015 17:50:56 +0300
Message-Id: <1443106264-78075-9-git-send-email-kirill.shutemov@linux.intel.com>
In-Reply-To: <1443106264-78075-1-git-send-email-kirill.shutemov@linux.intel.com>
References: <20150921153509.fef7ecdf313ef74307c43b65@linux-foundation.org>
 <1443106264-78075-1-git-send-email-kirill.shutemov@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Andrea Arcangeli <aarcange@redhat.com>, Hugh Dickins <hughd@google.com>, Dave Hansen <dave.hansen@intel.com>, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, Vlastimil Babka <vbabka@suse.cz>, Christoph Lameter <cl@gentwo.org>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Steve Capper <steve.capper@linaro.org>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>, Jerome Marchand <jmarchan@redhat.com>, Sasha Levin <sasha.levin@oracle.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

PG_pinned and PG_savepinned are about page table's pages which are never
compound.

I'm not so sure about PG_foreign, but it seems we shouldn't see compound
pages there too.

Let's use PF_NO_COMPOUND for all of them.

Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
---
 include/linux/page-flags.h | 10 +++++++---
 1 file changed, 7 insertions(+), 3 deletions(-)

diff --git a/include/linux/page-flags.h b/include/linux/page-flags.h
index c9cd82310e2d..adaa2b39f471 100644
--- a/include/linux/page-flags.h
+++ b/include/linux/page-flags.h
@@ -257,9 +257,13 @@ PAGEFLAG(Active, active, PF_HEAD) __CLEARPAGEFLAG(Active, active, PF_HEAD)
 __PAGEFLAG(Slab, slab, PF_NO_TAIL)
 __PAGEFLAG(SlobFree, slob_free, PF_NO_TAIL)
 PAGEFLAG(Checked, checked, PF_NO_COMPOUND)	   /* Used by some filesystems */
-PAGEFLAG(Pinned, pinned, PF_ANY) TESTSCFLAG(Pinned, pinned, PF_ANY)	/* Xen */
-PAGEFLAG(SavePinned, savepinned, PF_ANY);			/* Xen */
-PAGEFLAG(Foreign, foreign, PF_ANY);				/* Xen */
+
+/* Xen */
+PAGEFLAG(Pinned, pinned, PF_NO_COMPOUND)
+	TESTSCFLAG(Pinned, pinned, PF_NO_COMPOUND)
+PAGEFLAG(SavePinned, savepinned, PF_NO_COMPOUND);
+PAGEFLAG(Foreign, foreign, PF_NO_COMPOUND);
+
 PAGEFLAG(Reserved, reserved, PF_ANY) __CLEARPAGEFLAG(Reserved, reserved, PF_ANY)
 PAGEFLAG(SwapBacked, swapbacked, PF_ANY)
 	__CLEARPAGEFLAG(SwapBacked, swapbacked, PF_ANY)
-- 
2.5.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
