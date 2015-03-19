Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f180.google.com (mail-pd0-f180.google.com [209.85.192.180])
	by kanga.kvack.org (Postfix) with ESMTP id 4EACC6B0070
	for <linux-mm@kvack.org>; Thu, 19 Mar 2015 13:08:39 -0400 (EDT)
Received: by pdbcz9 with SMTP id cz9so81615533pdb.3
        for <linux-mm@kvack.org>; Thu, 19 Mar 2015 10:08:39 -0700 (PDT)
Received: from mga09.intel.com (mga09.intel.com. [134.134.136.24])
        by mx.google.com with ESMTP id fe5si4251976pdb.39.2015.03.19.10.08.37
        for <linux-mm@kvack.org>;
        Thu, 19 Mar 2015 10:08:38 -0700 (PDT)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: [PATCH 06/16] page-flags: define behavior of LRU-related flags on compound pages
Date: Thu, 19 Mar 2015 19:08:12 +0200
Message-Id: <1426784902-125149-7-git-send-email-kirill.shutemov@linux.intel.com>
In-Reply-To: <1426784902-125149-1-git-send-email-kirill.shutemov@linux.intel.com>
References: <1426784902-125149-1-git-send-email-kirill.shutemov@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>, Hugh Dickins <hughd@google.com>
Cc: Dave Hansen <dave.hansen@intel.com>, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, Vlastimil Babka <vbabka@suse.cz>, Christoph Lameter <cl@gentwo.org>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Steve Capper <steve.capper@linaro.org>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>, Jerome Marchand <jmarchan@redhat.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

Only head pages are ever on LRU. Let's use HEAD policy to avoid any
confusion for all LRU-related flags.

Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
---
 include/linux/page-flags.h | 17 +++++++++--------
 1 file changed, 9 insertions(+), 8 deletions(-)

diff --git a/include/linux/page-flags.h b/include/linux/page-flags.h
index df2493860821..bdb0d0e226c4 100644
--- a/include/linux/page-flags.h
+++ b/include/linux/page-flags.h
@@ -271,13 +271,14 @@ static inline struct page *compound_head_fast(struct page *page)
 
 __PAGEFLAG(Locked, locked, NO_TAIL)
 PAGEFLAG(Error, error, NO_COMPOUND) TESTCLEARFLAG(Error, error, NO_COMPOUND)
-PAGEFLAG(Referenced, referenced, ANY) TESTCLEARFLAG(Referenced, referenced, ANY)
-	__SETPAGEFLAG(Referenced, referenced, ANY)
+PAGEFLAG(Referenced, referenced, HEAD)
+	TESTCLEARFLAG(Referenced, referenced, HEAD)
+	__SETPAGEFLAG(Referenced, referenced, HEAD)
 PAGEFLAG(Dirty, dirty, HEAD) TESTSCFLAG(Dirty, dirty, HEAD)
 	__CLEARPAGEFLAG(Dirty, dirty, HEAD)
-PAGEFLAG(LRU, lru, ANY) __CLEARPAGEFLAG(LRU, lru, ANY)
-PAGEFLAG(Active, active, ANY) __CLEARPAGEFLAG(Active, active, ANY)
-	TESTCLEARFLAG(Active, active, ANY)
+PAGEFLAG(LRU, lru, HEAD) __CLEARPAGEFLAG(LRU, lru, HEAD)
+PAGEFLAG(Active, active, HEAD) __CLEARPAGEFLAG(Active, active, HEAD)
+	TESTCLEARFLAG(Active, active, HEAD)
 __PAGEFLAG(Slab, slab, ANY)
 PAGEFLAG(Checked, checked, NO_COMPOUND) /* Used by some filesystems */
 PAGEFLAG(Pinned, pinned, ANY) TESTSCFLAG(Pinned, pinned, ANY)	/* Xen */
@@ -331,9 +332,9 @@ PAGEFLAG(SwapCache, swapcache, ANY)
 PAGEFLAG_FALSE(SwapCache)
 #endif
 
-PAGEFLAG(Unevictable, unevictable, ANY)
-	__CLEARPAGEFLAG(Unevictable, unevictable, ANY)
-	TESTCLEARFLAG(Unevictable, unevictable, ANY)
+PAGEFLAG(Unevictable, unevictable, HEAD)
+	__CLEARPAGEFLAG(Unevictable, unevictable, HEAD)
+	TESTCLEARFLAG(Unevictable, unevictable, HEAD)
 
 #ifdef CONFIG_MMU
 PAGEFLAG(Mlocked, mlocked, ANY) __CLEARPAGEFLAG(Mlocked, mlocked, ANY)
-- 
2.1.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
