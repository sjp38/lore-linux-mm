Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qg0-f50.google.com (mail-qg0-f50.google.com [209.85.192.50])
	by kanga.kvack.org (Postfix) with ESMTP id AEA976B0081
	for <linux-mm@kvack.org>; Thu, 24 Jul 2014 15:51:18 -0400 (EDT)
Received: by mail-qg0-f50.google.com with SMTP id q108so3868591qgd.37
        for <linux-mm@kvack.org>; Thu, 24 Jul 2014 12:51:18 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id g62si12715098qge.125.2014.07.24.12.51.17
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 24 Jul 2014 12:51:18 -0700 (PDT)
From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Subject: [PATCH 1/2] hwpoison: fix hugetlbfs/thp precheck in hwpoison_user_mappings()
Date: Thu, 24 Jul 2014 15:50:52 -0400
Message-Id: <1406231453-27928-1-git-send-email-n-horiguchi@ah.jp.nec.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Andi Kleen <andi@firstfloor.org>, Chen Yucong <slaoub@gmail.com>, Naoya Horiguchi <nao.horiguchi@gmail.com>

Recent fix from Chen Yucong (commit 0bc1f8b0682c "hwpoison: fix the handling
path of the victimized page frame that belong to non-LRU") rejects going
into unmapping operation for hugetlbfs/thp pages, which results in failing
error containing on such pages. This patch fixes it.

With this patch, hwpoison functional tests in mce-test testsuite pass.

Signed-off-by: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
---
 mm/memory-failure.c | 8 +++++++-
 1 file changed, 7 insertions(+), 1 deletion(-)

diff --git mmotm-2014-07-22-15-58.orig/mm/memory-failure.c mmotm-2014-07-22-15-58/mm/memory-failure.c
index e3e2f007946e..f465b98d0209 100644
--- mmotm-2014-07-22-15-58.orig/mm/memory-failure.c
+++ mmotm-2014-07-22-15-58/mm/memory-failure.c
@@ -895,7 +895,13 @@ static int hwpoison_user_mappings(struct page *p, unsigned long pfn,
 	struct page *hpage = *hpagep;
 	struct page *ppage;
 
-	if (PageReserved(p) || PageSlab(p) || !PageLRU(p))
+	/*
+	 * Here we are interested only in user-mapped pages, so skip any
+	 * other types of pages.
+	 */
+	if (PageReserved(p) || PageSlab(p))
+		return SWAP_SUCCESS;
+	if (!(PageLRU(hpage) || PageHuge(p)))
 		return SWAP_SUCCESS;
 
 	/*
-- 
1.9.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
