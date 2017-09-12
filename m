Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f198.google.com (mail-wr0-f198.google.com [209.85.128.198])
	by kanga.kvack.org (Postfix) with ESMTP id 989966B0038
	for <linux-mm@kvack.org>; Tue, 12 Sep 2017 16:43:39 -0400 (EDT)
Received: by mail-wr0-f198.google.com with SMTP id v109so12950206wrc.5
        for <linux-mm@kvack.org>; Tue, 12 Sep 2017 13:43:39 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id o44sor4569138wrf.86.2017.09.12.13.43.38
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 12 Sep 2017 13:43:38 -0700 (PDT)
Date: Tue, 12 Sep 2017 22:43:06 +0200
From: Alexandru Moise <00moses.alexander00@gmail.com>
Subject: [PATCH] mm, hugetlb, soft_offline: save compound page order before
 page migration
Message-ID: <20170912204306.GA12053@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org, khandual@linux.vnet.ibm.com, akpm@linux-foundation.org, mhocko@suse.com, aarcange@redhat.com, minchan@kernel.org, hillf.zj@alibaba-inc.com, shli@fb.com, rppt@linux.vnet.ibm.com, kirill.shutemov@linux.intel.com, mgorman@techsingularity.net, rientjes@google.com, riel@redhat.com, linux-mm@kvack.org

This fixes a bug in madvise() where if you'd try to soft offline a
hugepage via madvise(), while walking the address range you'd end up,
using the wrong page offset due to attempting to get the compound
order of a former but presently not compound page, due to dissolving
the huge page (since c3114a8).

Signed-off-by: Alexandru Moise <00moses.alexander00@gmail.com>
---
 mm/madvise.c | 12 ++++++++++--
 1 file changed, 10 insertions(+), 2 deletions(-)

diff --git a/mm/madvise.c b/mm/madvise.c
index 21261ff0466f..25bade36e9ca 100644
--- a/mm/madvise.c
+++ b/mm/madvise.c
@@ -625,18 +625,26 @@ static int madvise_inject_error(int behavior,
 {
 	struct page *page;
 	struct zone *zone;
+	unsigned int order;
 
 	if (!capable(CAP_SYS_ADMIN))
 		return -EPERM;
 
-	for (; start < end; start += PAGE_SIZE <<
-				compound_order(compound_head(page))) {
+
+	for (; start < end; start += PAGE_SIZE << order) {
 		int ret;
 
 		ret = get_user_pages_fast(start, 1, 0, &page);
 		if (ret != 1)
 			return ret;
 
+		/*
+		 * When soft offlining hugepages, after migrating the page
+		 * we dissolve it, therefore in the second loop "page" will
+		 * no longer be a compound page, and order will be 0.
+		 */
+		order = compound_order(compound_head(page));
+
 		if (PageHWPoison(page)) {
 			put_page(page);
 			continue;
-- 
2.14.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
