Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f52.google.com (mail-pa0-f52.google.com [209.85.220.52])
	by kanga.kvack.org (Postfix) with ESMTP id B81C382F66
	for <linux-mm@kvack.org>; Thu, 24 Sep 2015 10:51:32 -0400 (EDT)
Received: by padhy16 with SMTP id hy16so75320751pad.1
        for <linux-mm@kvack.org>; Thu, 24 Sep 2015 07:51:32 -0700 (PDT)
Received: from mga01.intel.com (mga01.intel.com. [192.55.52.88])
        by mx.google.com with ESMTP id dl1si18899194pbb.159.2015.09.24.07.51.30
        for <linux-mm@kvack.org>;
        Thu, 24 Sep 2015 07:51:30 -0700 (PDT)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: [PATCH 06/16] page-flags: define behavior of LRU-related flags on compound pages
Date: Thu, 24 Sep 2015 17:50:54 +0300
Message-Id: <1443106264-78075-7-git-send-email-kirill.shutemov@linux.intel.com>
In-Reply-To: <1443106264-78075-1-git-send-email-kirill.shutemov@linux.intel.com>
References: <20150921153509.fef7ecdf313ef74307c43b65@linux-foundation.org>
 <1443106264-78075-1-git-send-email-kirill.shutemov@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Andrea Arcangeli <aarcange@redhat.com>, Hugh Dickins <hughd@google.com>, Dave Hansen <dave.hansen@intel.com>, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, Vlastimil Babka <vbabka@suse.cz>, Christoph Lameter <cl@gentwo.org>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Steve Capper <steve.capper@linaro.org>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>, Jerome Marchand <jmarchan@redhat.com>, Sasha Levin <sasha.levin@oracle.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

Only head pages are ever on LRU. Let's use PF_HEAD policy to avoid any
confusion for all LRU-related flags.

Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
---
 include/linux/page-flags.h | 17 +++++++++--------
 1 file changed, 9 insertions(+), 8 deletions(-)

diff --git a/include/linux/page-flags.h b/include/linux/page-flags.h
index 63db7483c264..10b75615ddf2 100644
--- a/include/linux/page-flags.h
+++ b/include/linux/page-flags.h
@@ -246,13 +246,14 @@ static inline int __TestClearPage##uname(struct page *page) { return 0; }
 
 __PAGEFLAG(Locked, locked, PF_NO_TAIL)
 PAGEFLAG(Error, error, PF_NO_COMPOUND) TESTCLEARFLAG(Error, error, PF_NO_COMPOUND)
-PAGEFLAG(Referenced, referenced, PF_ANY) TESTCLEARFLAG(Referenced, referenced, PF_ANY)
-	__SETPAGEFLAG(Referenced, referenced, PF_ANY)
+PAGEFLAG(Referenced, referenced, PF_HEAD)
+	TESTCLEARFLAG(Referenced, referenced, PF_HEAD)
+	__SETPAGEFLAG(Referenced, referenced, PF_HEAD)
 PAGEFLAG(Dirty, dirty, PF_HEAD) TESTSCFLAG(Dirty, dirty, PF_HEAD)
 	__CLEARPAGEFLAG(Dirty, dirty, PF_HEAD)
-PAGEFLAG(LRU, lru, PF_ANY) __CLEARPAGEFLAG(LRU, lru, PF_ANY)
-PAGEFLAG(Active, active, PF_ANY) __CLEARPAGEFLAG(Active, active, PF_ANY)
-	TESTCLEARFLAG(Active, active, PF_ANY)
+PAGEFLAG(LRU, lru, PF_HEAD) __CLEARPAGEFLAG(LRU, lru, PF_HEAD)
+PAGEFLAG(Active, active, PF_HEAD) __CLEARPAGEFLAG(Active, active, PF_HEAD)
+	TESTCLEARFLAG(Active, active, PF_HEAD)
 __PAGEFLAG(Slab, slab, PF_ANY)
 PAGEFLAG(Checked, checked, PF_NO_COMPOUND)	   /* Used by some filesystems */
 PAGEFLAG(Pinned, pinned, PF_ANY) TESTSCFLAG(Pinned, pinned, PF_ANY)	/* Xen */
@@ -306,9 +307,9 @@ PAGEFLAG(SwapCache, swapcache, PF_ANY)
 PAGEFLAG_FALSE(SwapCache)
 #endif
 
-PAGEFLAG(Unevictable, unevictable, PF_ANY)
-	__CLEARPAGEFLAG(Unevictable, unevictable, PF_ANY)
-	TESTCLEARFLAG(Unevictable, unevictable, PF_ANY)
+PAGEFLAG(Unevictable, unevictable, PF_HEAD)
+	__CLEARPAGEFLAG(Unevictable, unevictable, PF_HEAD)
+	TESTCLEARFLAG(Unevictable, unevictable, PF_HEAD)
 
 #ifdef CONFIG_MMU
 PAGEFLAG(Mlocked, mlocked, PF_ANY) __CLEARPAGEFLAG(Mlocked, mlocked, PF_ANY)
-- 
2.5.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
