Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yk0-f174.google.com (mail-yk0-f174.google.com [209.85.160.174])
	by kanga.kvack.org (Postfix) with ESMTP id 7704D9003C7
	for <linux-mm@kvack.org>; Tue, 21 Jul 2015 14:11:19 -0400 (EDT)
Received: by ykay190 with SMTP id y190so172542299yka.3
        for <linux-mm@kvack.org>; Tue, 21 Jul 2015 11:11:19 -0700 (PDT)
Received: from aserp1040.oracle.com (aserp1040.oracle.com. [141.146.126.69])
        by mx.google.com with ESMTPS id b125si3533508ywc.98.2015.07.21.11.11.17
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 21 Jul 2015 11:11:17 -0700 (PDT)
From: Mike Kravetz <mike.kravetz@oracle.com>
Subject: [PATCH v4 06/10] mm/hugetlb: vma_has_reserves() needs to handle fallocate hole punch
Date: Tue, 21 Jul 2015 11:09:40 -0700
Message-Id: <1437502184-14269-7-git-send-email-mike.kravetz@oracle.com>
In-Reply-To: <1437502184-14269-1-git-send-email-mike.kravetz@oracle.com>
References: <1437502184-14269-1-git-send-email-mike.kravetz@oracle.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, linux-kernel@vger.kernel.org, linux-api@vger.kernel.org
Cc: Dave Hansen <dave.hansen@linux.intel.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, David Rientjes <rientjes@google.com>, Hugh Dickins <hughd@google.com>, Davidlohr Bueso <dave@stgolabs.net>, Aneesh Kumar <aneesh.kumar@linux.vnet.ibm.com>, Hillf Danton <hillf.zj@alibaba-inc.com>, Christoph Hellwig <hch@infradead.org>, Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.cz>, Mike Kravetz <mike.kravetz@oracle.com>

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
 mm/hugetlb.c | 15 +++++++++++++--
 1 file changed, 13 insertions(+), 2 deletions(-)

diff --git a/mm/hugetlb.c b/mm/hugetlb.c
index db9caea..f9d3faf 100644
--- a/mm/hugetlb.c
+++ b/mm/hugetlb.c
@@ -803,8 +803,19 @@ static bool vma_has_reserves(struct vm_area_struct *vma, long chg)
 	}
 
 	/* Shared mappings always use reserves */
-	if (vma->vm_flags & VM_MAYSHARE)
-		return true;
+	if (vma->vm_flags & VM_MAYSHARE) {
+		/*
+		 * We know VM_NORESERVE is not set.  Therefore, there SHOULD
+		 * be a region map for all pages.  The only situation where
+		 * there is no region map is if a hole was punched via
+		 * fallocate.  In this case, there really are no reverves to
+		 * use.  This situation is indicated if chg != 0.
+		 */
+		if (chg)
+			return false;
+		else
+			return true;
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
