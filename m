Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f54.google.com (mail-pa0-f54.google.com [209.85.220.54])
	by kanga.kvack.org (Postfix) with ESMTP id A6FE3828DF
	for <linux-mm@kvack.org>; Tue, 12 Jan 2016 17:22:20 -0500 (EST)
Received: by mail-pa0-f54.google.com with SMTP id uo6so330182448pac.1
        for <linux-mm@kvack.org>; Tue, 12 Jan 2016 14:22:20 -0800 (PST)
Received: from mga11.intel.com (mga11.intel.com. [192.55.52.93])
        by mx.google.com with ESMTP id l82si38927703pfb.158.2016.01.12.14.22.19
        for <linux-mm@kvack.org>;
        Tue, 12 Jan 2016 14:22:19 -0800 (PST)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: [PATCH] mempolicy: add missed spin_unlock in queue_pages_pte_range
Date: Wed, 13 Jan 2016 01:21:46 +0300
Message-Id: <1452637306-130149-1-git-send-email-kirill.shutemov@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Sasha Levin <sasha.levin@oracle.com>
Cc: linux-mm@kvack.org, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

We forgot to unlock ptl in case when huge pmd dissappered under us.

This patch can be folded into
  "migrate_pages: try to split pages on queuing"

Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
---
 mm/mempolicy.c | 2 ++
 1 file changed, 2 insertions(+)

diff --git a/mm/mempolicy.c b/mm/mempolicy.c
index 496214bd82e2..973434eff9dc 100644
--- a/mm/mempolicy.c
+++ b/mm/mempolicy.c
@@ -510,6 +510,8 @@ static int queue_pages_pte_range(pmd_t *pmd, unsigned long addr,
 				if (ret)
 					return 0;
 			}
+		} else {
+			spin_unlock(ptl);
 		}
 	}
 
-- 
2.6.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
