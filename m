Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f50.google.com (mail-pa0-f50.google.com [209.85.220.50])
	by kanga.kvack.org (Postfix) with ESMTP id B4C3B82F66
	for <linux-mm@kvack.org>; Thu, 24 Sep 2015 10:51:40 -0400 (EDT)
Received: by pacfv12 with SMTP id fv12so76434655pac.2
        for <linux-mm@kvack.org>; Thu, 24 Sep 2015 07:51:40 -0700 (PDT)
Received: from mga01.intel.com (mga01.intel.com. [192.55.52.88])
        by mx.google.com with ESMTP id dl1si18899194pbb.159.2015.09.24.07.51.31
        for <linux-mm@kvack.org>;
        Thu, 24 Sep 2015 07:51:31 -0700 (PDT)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: [PATCH 12/16] page-flags: define PG_mlocked behavior on compound pages
Date: Thu, 24 Sep 2015 17:51:00 +0300
Message-Id: <1443106264-78075-13-git-send-email-kirill.shutemov@linux.intel.com>
In-Reply-To: <1443106264-78075-1-git-send-email-kirill.shutemov@linux.intel.com>
References: <20150921153509.fef7ecdf313ef74307c43b65@linux-foundation.org>
 <1443106264-78075-1-git-send-email-kirill.shutemov@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Andrea Arcangeli <aarcange@redhat.com>, Hugh Dickins <hughd@google.com>, Dave Hansen <dave.hansen@intel.com>, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, Vlastimil Babka <vbabka@suse.cz>, Christoph Lameter <cl@gentwo.org>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Steve Capper <steve.capper@linaro.org>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>, Jerome Marchand <jmarchan@redhat.com>, Sasha Levin <sasha.levin@oracle.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

Transparent huge pages can be mlocked -- whole compund page at once.
Something went wrong if we're trying to mlock() tail page.
Let's use PF_NO_TAIL.

Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
---
 include/linux/page-flags.h | 6 ++++--
 1 file changed, 4 insertions(+), 2 deletions(-)

diff --git a/include/linux/page-flags.h b/include/linux/page-flags.h
index c933416b2f92..31e68a8c2777 100644
--- a/include/linux/page-flags.h
+++ b/include/linux/page-flags.h
@@ -316,8 +316,10 @@ PAGEFLAG(Unevictable, unevictable, PF_HEAD)
 	TESTCLEARFLAG(Unevictable, unevictable, PF_HEAD)
 
 #ifdef CONFIG_MMU
-PAGEFLAG(Mlocked, mlocked, PF_ANY) __CLEARPAGEFLAG(Mlocked, mlocked, PF_ANY)
-	TESTSCFLAG(Mlocked, mlocked, PF_ANY) __TESTCLEARFLAG(Mlocked, mlocked, PF_ANY)
+PAGEFLAG(Mlocked, mlocked, PF_NO_TAIL)
+	__CLEARPAGEFLAG(Mlocked, mlocked, PF_NO_TAIL)
+	TESTSCFLAG(Mlocked, mlocked, PF_NO_TAIL)
+	__TESTCLEARFLAG(Mlocked, mlocked, PF_NO_TAIL)
 #else
 PAGEFLAG_FALSE(Mlocked) __CLEARPAGEFLAG_NOOP(Mlocked)
 	TESTSCFLAG_FALSE(Mlocked) __TESTCLEARFLAG_FALSE(Mlocked)
-- 
2.5.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
