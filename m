Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f172.google.com (mail-pf0-f172.google.com [209.85.192.172])
	by kanga.kvack.org (Postfix) with ESMTP id 662576B007E
	for <linux-mm@kvack.org>; Fri, 25 Mar 2016 19:45:57 -0400 (EDT)
Received: by mail-pf0-f172.google.com with SMTP id 4so92117945pfd.0
        for <linux-mm@kvack.org>; Fri, 25 Mar 2016 16:45:57 -0700 (PDT)
Received: from aserp1040.oracle.com (aserp1040.oracle.com. [141.146.126.69])
        by mx.google.com with ESMTPS id y8si9831708pas.240.2016.03.25.16.45.55
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 25 Mar 2016 16:45:56 -0700 (PDT)
From: Mike Kravetz <mike.kravetz@oracle.com>
Subject: [PATCH] mm/hugetlb: optimize minimum size (min_size) accounting
Date: Fri, 25 Mar 2016 16:44:58 -0700
Message-Id: <1458949498-18916-1-git-send-email-mike.kravetz@oracle.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, linux-kernel@vger.kernel.org
Cc: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Hillf Danton <hillf.zj@alibaba-inc.com>, David Rientjes <rientjes@google.com>, Dave Hansen <dave.hansen@linux.intel.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Andrew Morton <akpm@linux-foundation.org>, Paul Gortmaker <paul.gortmaker@windriver.com>, Mike Kravetz <mike.kravetz@oracle.com>

It was observed that minimum size accounting associated with the
hugetlbfs min_size mount option may not perform optimally and as
expected.  As huge pages/reservations are released from the filesystem
and given back to the global pools, they are reserved for subsequent
filesystem use as long as the subpool reserved count is less than
subpool minimum size.  It does not take into account used pages
within the filesystem.  The filesystem size limits are not exceeded
and this is technically not a bug.  However, better behavior would
be to wait for the number of used pages/reservations associated with
the filesystem to drop below the minimum size before taking reservations
to satisfy minimum size.

An optimization is also made to the hugepage_subpool_get_pages()
routine which is called when pages/reservations are allocated.  This
does not change behavior, but simply avoids the accounting if all
reservations have already been taken (subpool reserved count == 0).

Signed-off-by: Mike Kravetz <mike.kravetz@oracle.com>
---
 mm/hugetlb.c | 6 ++++--
 1 file changed, 4 insertions(+), 2 deletions(-)

diff --git a/mm/hugetlb.c b/mm/hugetlb.c
index 06058ea..b9bfcf1 100644
--- a/mm/hugetlb.c
+++ b/mm/hugetlb.c
@@ -144,7 +144,8 @@ static long hugepage_subpool_get_pages(struct hugepage_subpool *spool,
 		}
 	}
 
-	if (spool->min_hpages != -1) {		/* minimum size accounting */
+	/* minimum size accounting */
+	if (spool->min_hpages != -1 && spool->rsv_hpages) {
 		if (delta > spool->rsv_hpages) {
 			/*
 			 * Asking for more reserves than those already taken on
@@ -182,7 +183,8 @@ static long hugepage_subpool_put_pages(struct hugepage_subpool *spool,
 	if (spool->max_hpages != -1)		/* maximum size accounting */
 		spool->used_hpages -= delta;
 
-	if (spool->min_hpages != -1) {		/* minimum size accounting */
+	 /* minimum size accounting */
+	if (spool->min_hpages != -1 && spool->used_hpages < spool->min_hpages) {
 		if (spool->rsv_hpages + delta <= spool->min_hpages)
 			ret = 0;
 		else
-- 
2.4.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
