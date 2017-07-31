Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id 23AB76B05BB
	for <linux-mm@kvack.org>; Mon, 31 Jul 2017 00:23:47 -0400 (EDT)
Received: by mail-pf0-f198.google.com with SMTP id p20so65315953pfj.2
        for <linux-mm@kvack.org>; Sun, 30 Jul 2017 21:23:47 -0700 (PDT)
Received: from mga06.intel.com (mga06.intel.com. [134.134.136.31])
        by mx.google.com with ESMTPS id k71si3814161pfb.517.2017.07.30.21.23.45
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 30 Jul 2017 21:23:46 -0700 (PDT)
From: Wei Wang <wei.w.wang@intel.com>
Subject: [PATCH] mm: don't zero ballooned pages
Date: Mon, 31 Jul 2017 12:13:33 +0800
Message-Id: <1501474413-21580-1-git-send-email-wei.w.wang@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org, linux-mm@kvack.org, virtualization@lists.linux-foundation.org, mst@redhat.com, mawilcox@microsoft.com, mhocko@suse.com, dave.hansen@intel.com, akpm@linux-foundation.org, wei.w.wang@intel.com
Cc: zhenwei.pi@youruncloud.com

Ballooned pages will be marked as MADV_DONTNEED by the hypervisor and
shouldn't be given to the host ksmd to scan. Therefore, it is not
necessary to zero ballooned pages, which is very time consuming when
the page amount is large. The ongoing fast balloon tests show that the
time to balloon 7G pages is increased from ~491ms to 2.8 seconds with
__GFP_ZERO added. So, this patch removes the flag.

Signed-off-by: Wei Wang <wei.w.wang@intel.com>
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
