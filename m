Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f176.google.com (mail-ig0-f176.google.com [209.85.213.176])
	by kanga.kvack.org (Postfix) with ESMTP id 606876B0072
	for <linux-mm@kvack.org>; Thu, 19 Mar 2015 13:08:43 -0400 (EDT)
Received: by ignm3 with SMTP id m3so14629077ign.0
        for <linux-mm@kvack.org>; Thu, 19 Mar 2015 10:08:43 -0700 (PDT)
Received: from mga14.intel.com (mga14.intel.com. [192.55.52.115])
        by mx.google.com with ESMTP id er5si3802589pad.227.2015.03.19.10.08.38
        for <linux-mm@kvack.org>;
        Thu, 19 Mar 2015 10:08:38 -0700 (PDT)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: [PATCH 12/16] page-flags: define PG_mlocked behavior on compound pages
Date: Thu, 19 Mar 2015 19:08:18 +0200
Message-Id: <1426784902-125149-13-git-send-email-kirill.shutemov@linux.intel.com>
In-Reply-To: <1426784902-125149-1-git-send-email-kirill.shutemov@linux.intel.com>
References: <1426784902-125149-1-git-send-email-kirill.shutemov@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>, Hugh Dickins <hughd@google.com>
Cc: Dave Hansen <dave.hansen@intel.com>, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, Vlastimil Babka <vbabka@suse.cz>, Christoph Lameter <cl@gentwo.org>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Steve Capper <steve.capper@linaro.org>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>, Jerome Marchand <jmarchan@redhat.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

Transparent huge pages can be mlocked -- whole compund page at once.
Something went wrong if we're trying to mlock() tail page.
Let's use NO_TAIL.

Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
---
 include/linux/page-flags.h | 5 +++--
 1 file changed, 3 insertions(+), 2 deletions(-)

diff --git a/include/linux/page-flags.h b/include/linux/page-flags.h
index 9ea90bb8cb89..a1ecec3f505f 100644
--- a/include/linux/page-flags.h
+++ b/include/linux/page-flags.h
@@ -340,8 +340,9 @@ PAGEFLAG(Unevictable, unevictable, HEAD)
 	TESTCLEARFLAG(Unevictable, unevictable, HEAD)
 
 #ifdef CONFIG_MMU
-PAGEFLAG(Mlocked, mlocked, ANY) __CLEARPAGEFLAG(Mlocked, mlocked, ANY)
-	TESTSCFLAG(Mlocked, mlocked, ANY) __TESTCLEARFLAG(Mlocked, mlocked, ANY)
+PAGEFLAG(Mlocked, mlocked, NO_TAIL) __CLEARPAGEFLAG(Mlocked, mlocked, NO_TAIL)
+	TESTSCFLAG(Mlocked, mlocked, NO_TAIL)
+	__TESTCLEARFLAG(Mlocked, mlocked, NO_TAIL)
 #else
 PAGEFLAG_FALSE(Mlocked) __CLEARPAGEFLAG_NOOP(Mlocked)
 	TESTSCFLAG_FALSE(Mlocked) __TESTCLEARFLAG_FALSE(Mlocked)
-- 
2.1.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
