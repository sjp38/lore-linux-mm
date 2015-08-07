Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f51.google.com (mail-oi0-f51.google.com [209.85.218.51])
	by kanga.kvack.org (Postfix) with ESMTP id 1DC2E6B0253
	for <linux-mm@kvack.org>; Fri,  7 Aug 2015 06:17:01 -0400 (EDT)
Received: by oip136 with SMTP id 136so51669797oip.1
        for <linux-mm@kvack.org>; Fri, 07 Aug 2015 03:17:00 -0700 (PDT)
Received: from BLU004-OMC1S32.hotmail.com (blu004-omc1s32.hotmail.com. [65.55.116.43])
        by mx.google.com with ESMTPS id y5si6979979obw.56.2015.08.07.03.16.59
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Fri, 07 Aug 2015 03:16:59 -0700 (PDT)
Message-ID: <BLU436-SMTP25999BF1F67C167749C58DB80730@phx.gbl>
From: Wanpeng Li <wanpeng.li@hotmail.com>
Subject: [PATCH v2 2/2] mm/hwpoison: fix fail isolate hugetlbfs page w/ refcount held
Date: Fri, 7 Aug 2015 18:16:42 +0800
In-Reply-To: <1438942602-55614-1-git-send-email-wanpeng.li@hotmail.com>
References: <1438942602-55614-1-git-send-email-wanpeng.li@hotmail.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Tony Luck <tony.luck@intel.com>, Andi Kleen <andi@firstfloor.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Wanpeng Li <wanpeng.li@hotmail.com>, stable@vger.kernel.org

Hugetlbfs pages will get a refcount in get_any_page() or madvise_hwpoison() 
if soft offline through madvise. The refcount which held by soft offline 
path should be released if fail to isolate hugetlbfs pages. This patch fix 
it by reducing a refcount for both isolate successfully and failure.

Cc: <stable@vger.kernel.org> # 3.9+
Signed-off-by: Wanpeng Li <wanpeng.li@hotmail.com> 
---
 mm/memory-failure.c |   13 ++++++-------
 1 files changed, 6 insertions(+), 7 deletions(-)

diff --git a/mm/memory-failure.c b/mm/memory-failure.c
index 001f1ba..8077b1c 100644
--- a/mm/memory-failure.c
+++ b/mm/memory-failure.c
@@ -1557,13 +1557,12 @@ static int soft_offline_huge_page(struct page *page, int flags)
 	unlock_page(hpage);
 
 	ret = isolate_huge_page(hpage, &pagelist);
-	if (ret) {
-		/*
-		 * get_any_page() and isolate_huge_page() takes a refcount each,
-		 * so need to drop one here.
-		 */
-		put_page(hpage);
-	} else {
+	/*
+	 * get_any_page() and isolate_huge_page() takes a refcount each,
+	 * so need to drop one here.
+	 */
+	put_page(hpage);
+	if (!ret) {
 		pr_info("soft offline: %#lx hugepage failed to isolate\n", pfn);
 		return -EBUSY;
 	}
-- 
1.7.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
