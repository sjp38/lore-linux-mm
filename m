Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id BCADD6B0038
	for <linux-mm@kvack.org>; Mon, 23 Jan 2017 07:10:36 -0500 (EST)
Received: by mail-pf0-f197.google.com with SMTP id 80so198082779pfy.2
        for <linux-mm@kvack.org>; Mon, 23 Jan 2017 04:10:36 -0800 (PST)
Received: from szxga03-in.huawei.com (szxga03-in.huawei.com. [119.145.14.66])
        by mx.google.com with ESMTPS id l17si15480375pgj.44.2017.01.23.04.10.35
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Mon, 23 Jan 2017 04:10:36 -0800 (PST)
From: zhongjiang <zhongjiang@huawei.com>
Subject: [PATCH v2] mm: do not export ioremap_page_range symbol for external module
Date: Mon, 23 Jan 2017 20:07:00 +0800
Message-ID: <1485173220-29010-1-git-send-email-zhongjiang@huawei.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org, jhubbard@nvidia.com
Cc: linux-mm@kvack.org, minchan@kernel.org, mhocko@kernel.org

From: zhong jiang <zhongjiang@huawei.com>

Recently, I've found cases in which ioremap_page_range was used
incorrectly, in external modules, leading to crashes. This can be
partly attributed to the fact that ioremap_page_range is lower-level,
with fewer protections, as compared to the other functions that an
external module would typically call. Those include:

     ioremap_cache
     ioremap_nocache
     ioremap_prot
     ioremap_uc
     ioremap_wc
     ioremap_wt

...each of which wraps __ioremap_caller, which in turn provides a
safer way to achieve the mapping.

Therefore, stop EXPORT-ing ioremap_page_range.

Signed-off-by: zhong jiang <zhongjiang@huawei.com>
Reviewed-by: John Hubbard <jhubbard@nvidia.com> 
Suggested-by: John Hubbard <jhubbard@nvidia.com>
---
 lib/ioremap.c | 1 -
 1 file changed, 1 deletion(-)

diff --git a/lib/ioremap.c b/lib/ioremap.c
index 86c8911..a3e14ce 100644
--- a/lib/ioremap.c
+++ b/lib/ioremap.c
@@ -144,4 +144,3 @@ int ioremap_page_range(unsigned long addr,
 
 	return err;
 }
-EXPORT_SYMBOL_GPL(ioremap_page_range);
-- 
1.8.3.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
