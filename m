Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id C044F6B069F
	for <linux-mm@kvack.org>; Thu,  3 Aug 2017 08:10:02 -0400 (EDT)
Received: by mail-pf0-f199.google.com with SMTP id 24so11390674pfk.5
        for <linux-mm@kvack.org>; Thu, 03 Aug 2017 05:10:02 -0700 (PDT)
Received: from mga03.intel.com (mga03.intel.com. [134.134.136.65])
        by mx.google.com with ESMTPS id r20si349687pfg.504.2017.08.03.05.10.01
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 03 Aug 2017 05:10:01 -0700 (PDT)
From: Wei Wang <wei.w.wang@intel.com>
Subject: [PATCH RESEND] mm: don't zero ballooned pages
Date: Thu,  3 Aug 2017 19:59:17 +0800
Message-Id: <1501761557-9758-1-git-send-email-wei.w.wang@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org, linux-mm@kvack.org, virtualization@lists.linux-foundation.org, mhocko@kernel.org, mst@redhat.com, zhenwei.pi@youruncloud.com
Cc: akpm@linux-foundation.org, dave.hansen@intel.com, mawilcox@microsoft.com, Wei Wang <wei.w.wang@intel.com>

This patch is a revert of 'commit bb01b64cfab7 ("mm/balloon_compaction.c:
enqueue zero page to balloon device")'

Ballooned pages will be marked as MADV_DONTNEED by the hypervisor and
shouldn't be given to the host ksmd to scan. Therefore, it is not
necessary to zero ballooned pages, which is very time consuming when
the page amount is large. The ongoing fast balloon tests show that the
time to balloon 7G pages is increased from ~491ms to 2.8 seconds with
__GFP_ZERO added. So, this patch removes the flag.

Signed-off-by: Wei Wang <wei.w.wang@intel.com>
Cc: Michal Hocko <mhocko@kernel.org>
Cc: Michael S. Tsirkin <mst@redhat.com>
---
 mm/balloon_compaction.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/mm/balloon_compaction.c b/mm/balloon_compaction.c
index 9075aa5..b06d9fe 100644
--- a/mm/balloon_compaction.c
+++ b/mm/balloon_compaction.c
@@ -24,7 +24,7 @@ struct page *balloon_page_enqueue(struct balloon_dev_info *b_dev_info)
 {
 	unsigned long flags;
 	struct page *page = alloc_page(balloon_mapping_gfp_mask() |
-				__GFP_NOMEMALLOC | __GFP_NORETRY | __GFP_ZERO);
+				       __GFP_NOMEMALLOC | __GFP_NORETRY);
 	if (!page)
 		return NULL;
 
-- 
2.7.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
