Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f43.google.com (mail-pa0-f43.google.com [209.85.220.43])
	by kanga.kvack.org (Postfix) with ESMTP id 5BAEE6B0259
	for <linux-mm@kvack.org>; Fri, 13 Nov 2015 13:45:35 -0500 (EST)
Received: by pacdm15 with SMTP id dm15so107563843pac.3
        for <linux-mm@kvack.org>; Fri, 13 Nov 2015 10:45:35 -0800 (PST)
Received: from mail-pa0-x235.google.com (mail-pa0-x235.google.com. [2607:f8b0:400e:c03::235])
        by mx.google.com with ESMTPS id hy4si28911011pbb.210.2015.11.13.10.45.29
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 13 Nov 2015 10:45:34 -0800 (PST)
Received: by pacdm15 with SMTP id dm15so107561764pac.3
        for <linux-mm@kvack.org>; Fri, 13 Nov 2015 10:45:29 -0800 (PST)
From: Yang Shi <yang.shi@linaro.org>
Subject: [PATCH] writeback: initialize m_dirty to avoid compile warning
Date: Fri, 13 Nov 2015 10:26:41 -0800
Message-Id: <1447439201-32009-1-git-send-email-yang.shi@linaro.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org, tj@kernel.org
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, linaro-kernel@lists.linaro.org, yang.shi@linaro.org

When building kernel with gcc 5.2, the below warning is raised:

mm/page-writeback.c: In function 'balance_dirty_pages.isra.10':
mm/page-writeback.c:1545:17: warning: 'm_dirty' may be used uninitialized in this function [-Wmaybe-uninitialized]
   unsigned long m_dirty, m_thresh, m_bg_thresh;

The m_dirty{thresh, bg_thresh} are initialized in the block of "if (mdtc)",
so if mdts is null, they won't be initialized before being used.
Initialize m_dirty to zero, also initialize m_thresh and m_bg_thresh to keep
consistency.

They are used later by if condition:
!mdtc || m_dirty <= dirty_freerun_ceiling(m_thresh, m_bg_thresh)

If mdtc is null, dirty_freerun_ceiling will not be called at all, so the
initialization will not change any behavior other than just ceasing the compile
warning.

Signed-off-by: Yang Shi <yang.shi@linaro.org>
---
 mm/page-writeback.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/mm/page-writeback.c b/mm/page-writeback.c
index 2c90357..ce726eb 100644
--- a/mm/page-writeback.c
+++ b/mm/page-writeback.c
@@ -1542,7 +1542,7 @@ static void balance_dirty_pages(struct address_space *mapping,
 	for (;;) {
 		unsigned long now = jiffies;
 		unsigned long dirty, thresh, bg_thresh;
-		unsigned long m_dirty, m_thresh, m_bg_thresh;
+		unsigned long m_dirty = 0, m_thresh = 0, m_bg_thresh = 0;
 
 		/*
 		 * Unstable writes are a feature of certain networked
-- 
2.0.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
