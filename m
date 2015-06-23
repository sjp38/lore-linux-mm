Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f47.google.com (mail-pa0-f47.google.com [209.85.220.47])
	by kanga.kvack.org (Postfix) with ESMTP id E2A456B0071
	for <linux-mm@kvack.org>; Mon, 22 Jun 2015 20:39:45 -0400 (EDT)
Received: by pactm7 with SMTP id tm7so5426010pac.2
        for <linux-mm@kvack.org>; Mon, 22 Jun 2015 17:39:45 -0700 (PDT)
Received: from userp1040.oracle.com (userp1040.oracle.com. [156.151.31.81])
        by mx.google.com with ESMTPS id nt5si31808385pbc.196.2015.06.22.17.39.42
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 22 Jun 2015 17:39:43 -0700 (PDT)
From: Mike Kravetz <mike.kravetz@oracle.com>
Subject: [RFC v5 PATCH 5/9] mm/hugetlb: vma_has_reserves() needs to handle fallocate hole punch
Date: Mon, 22 Jun 2015 17:38:35 -0700
Message-Id: <1435019919-29225-6-git-send-email-mike.kravetz@oracle.com>
In-Reply-To: <1435019919-29225-1-git-send-email-mike.kravetz@oracle.com>
References: <1435019919-29225-1-git-send-email-mike.kravetz@oracle.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, linux-kernel@vger.kernel.org
Cc: Dave Hansen <dave.hansen@linux.intel.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, David Rientjes <rientjes@google.com>, Hugh Dickins <hughd@google.com>, Davidlohr Bueso <dave@stgolabs.net>, Aneesh Kumar <aneesh.kumar@linux.vnet.ibm.com>, Hillf Danton <hillf.zj@alibaba-inc.com>, Christoph Hellwig <hch@infradead.org>, Mike Kravetz <mike.kravetz@oracle.com>

In vma_has_reserves(), the current assumption is that reserves are
always present for shared mappings.  However, this will not be the
case with fallocate hole punch.  When punching a hole, the present
page will be deleted as well as the region/reserve map entry (and
hence any reservation).  vma_has_reserves is passed "chg" which
indicates whether or not a region/reserve map is present.  Use
this to determine if reserves are actually present or were removed
via hole punch.

Signed-off-by: Mike Kravetz <mike.kravetz@oracle.com>
---
 mm/hugetlb.c | 16 +++++++++++++---
 1 file changed, 13 insertions(+), 3 deletions(-)

diff --git a/mm/hugetlb.c b/mm/hugetlb.c
index 7cd4b67..9d2859f 100644
--- a/mm/hugetlb.c
+++ b/mm/hugetlb.c
@@ -692,9 +692,19 @@ static int vma_has_reserves(struct vm_area_struct *vma, long chg)
 			return 0;
 	}
 
-	/* Shared mappings always use reserves */
-	if (vma->vm_flags & VM_MAYSHARE)
-		return 1;
+	if (vma->vm_flags & VM_MAYSHARE) {
+		/*
+		 * We know VM_NORESERVE is not set.  Therefore, there SHOULD
+		 * be a region map for all pages.  The only situation where
+		 * there is no region map is if a hole was punched via
+		 * fallocate.  In this case, there really are no reverves to
+		 * use.  This situation is indicated if chg != 0.
+		 */
+		if (chg)
+			return 0;
+		else
+			return 1;
+	}
 
 	/*
 	 * Only the process that called mmap() has reserves for
-- 
2.1.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
