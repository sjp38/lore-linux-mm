Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lb0-f200.google.com (mail-lb0-f200.google.com [209.85.217.200])
	by kanga.kvack.org (Postfix) with ESMTP id 01A8D6B0297
	for <linux-mm@kvack.org>; Tue, 14 Jun 2016 05:21:38 -0400 (EDT)
Received: by mail-lb0-f200.google.com with SMTP id na2so59845263lbb.1
        for <linux-mm@kvack.org>; Tue, 14 Jun 2016 02:21:37 -0700 (PDT)
Received: from szxga01-in.huawei.com (szxga01-in.huawei.com. [58.251.152.64])
        by mx.google.com with ESMTPS id z10si33775339wjj.209.2016.06.14.02.20.46
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 14 Jun 2016 02:21:36 -0700 (PDT)
From: <zhouxianrong@huawei.com>
Subject: [PATCH] more mapcount page as kpage could reduce total replacement times than fewer mapcount one in probability.
Date: Tue, 14 Jun 2016 17:17:37 +0800
Message-ID: <1465895857-1515-1-git-send-email-zhouxianrong@huawei.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: akpm@linux-foundation.org, hughd@google.com, aarcange@redhat.com, kirill.shutemov@linux.intel.com, dave.hansen@linux.intel.com, zhouchengming1@huawei.com, geliangtang@163.com, zhouxianrong@huawei.com, linux-kernel@vger.kernel.org, zhouxiyu@huawei.com, wanghaijun5@huawei.com

From: z00281421 <z00281421@notesmail.huawei.com>

more mapcount page as kpage could reduce total replacement 
times than fewer mapcount one when ksmd scan and replace 
among forked pages later.

Signed-off-by: z00281421 <z00281421@notesmail.huawei.com>
---
 mm/ksm.c |   15 +++++++++++++++
 1 file changed, 15 insertions(+)

diff --git a/mm/ksm.c b/mm/ksm.c
index 4786b41..17a238c 100644
--- a/mm/ksm.c
+++ b/mm/ksm.c
@@ -1094,6 +1094,21 @@ static struct page *try_to_merge_two_pages(struct rmap_item *rmap_item,
 {
 	int err;
 
+	/*
+	 * select more mapcount page as kpage
+	 */
+	if (page_mapcount(page) < page_mapcount(tree_page)) {
+		struct page *tmp_page;
+		struct rmap_item *tmp_rmap_item;
+
+		tmp_page = page;
+		page = tree_page;
+		tree_page = tmp_page;
+		tmp_rmap_item = rmap_item;
+		rmap_item = tree_rmap_item;
+		tree_rmap_item = tmp_rmap_item;
+	}
+
 	err = try_to_merge_with_ksm_page(rmap_item, page, NULL);
 	if (!err) {
 		err = try_to_merge_with_ksm_page(tree_rmap_item,
-- 
1.7.9.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
