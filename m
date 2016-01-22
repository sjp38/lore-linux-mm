Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f175.google.com (mail-pf0-f175.google.com [209.85.192.175])
	by kanga.kvack.org (Postfix) with ESMTP id 5F66F6B0005
	for <linux-mm@kvack.org>; Fri, 22 Jan 2016 03:28:01 -0500 (EST)
Received: by mail-pf0-f175.google.com with SMTP id q63so39547352pfb.1
        for <linux-mm@kvack.org>; Fri, 22 Jan 2016 00:28:01 -0800 (PST)
Received: from mail-pf0-x241.google.com (mail-pf0-x241.google.com. [2607:f8b0:400e:c00::241])
        by mx.google.com with ESMTPS id oz1si8120685pac.46.2016.01.22.00.28.00
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 22 Jan 2016 00:28:00 -0800 (PST)
Received: by mail-pf0-x241.google.com with SMTP id e65so3000937pfe.0
        for <linux-mm@kvack.org>; Fri, 22 Jan 2016 00:28:00 -0800 (PST)
From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Subject: [PATCH v1] mm/madvise: pass return code of memory_failure() to userspace
Date: Fri, 22 Jan 2016 17:27:57 +0900
Message-Id: <1453451277-20979-1-git-send-email-n-horiguchi@ah.jp.nec.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Chen Gong <gong.chen@linux.intel.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Naoya Horiguchi <nao.horiguchi@gmail.com>

Currently the return value of memory_failure() is not passed to userspace, which
is inconvenient for test programs that want to know the result of error handling.
So let's return it to the caller as we already do in MADV_SOFT_OFFLINE case.

Signed-off-by: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
---
 mm/madvise.c | 5 +++--
 1 file changed, 3 insertions(+), 2 deletions(-)

diff --git v4.4-mmotm-2016-01-20-16-10/mm/madvise.c v4.4-mmotm-2016-01-20-16-10_patched/mm/madvise.c
index f56825b..6a77114 100644
--- v4.4-mmotm-2016-01-20-16-10/mm/madvise.c
+++ v4.4-mmotm-2016-01-20-16-10_patched/mm/madvise.c
@@ -555,8 +555,9 @@ static int madvise_hwpoison(int bhv, unsigned long start, unsigned long end)
 		}
 		pr_info("Injecting memory failure for page %#lx at %#lx\n",
 		       page_to_pfn(p), start);
-		/* Ignore return value for now */
-		memory_failure(page_to_pfn(p), 0, MF_COUNT_INCREASED);
+		ret = memory_failure(page_to_pfn(p), 0, MF_COUNT_INCREASED);
+		if (ret)
+			return ret;
 	}
 	return 0;
 }
-- 
2.7.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
