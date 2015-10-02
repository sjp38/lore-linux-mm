Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f49.google.com (mail-pa0-f49.google.com [209.85.220.49])
	by kanga.kvack.org (Postfix) with ESMTP id 5D9E682F92
	for <linux-mm@kvack.org>; Fri,  2 Oct 2015 01:40:23 -0400 (EDT)
Received: by pacex6 with SMTP id ex6so97252637pac.0
        for <linux-mm@kvack.org>; Thu, 01 Oct 2015 22:40:23 -0700 (PDT)
Received: from mga14.intel.com (mga14.intel.com. [192.55.52.115])
        by mx.google.com with ESMTP id pd6si708463pbc.104.2015.10.01.22.40.20
        for <linux-mm@kvack.org>;
        Thu, 01 Oct 2015 22:40:20 -0700 (PDT)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: [PATCH 1/3] page-flags: do not corrupt caller 'page' in PF_NO_TAIL
Date: Fri,  2 Oct 2015 08:40:14 +0300
Message-Id: <1443764416-129688-2-git-send-email-kirill.shutemov@linux.intel.com>
In-Reply-To: <1443764416-129688-1-git-send-email-kirill.shutemov@linux.intel.com>
References: <1443764416-129688-1-git-send-email-kirill.shutemov@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

Andrew noticed that PF_NO_TAIL() modifies caller's 'page'. This doesn't
trigger any bad results, because all users are inline functions which
doesn't use the variable beyond the point. But still not good.

The patch changes PF_NO_TAIL() to always return head page, regardless
'enforce'. This makes operations of page flags with PF_NO_TAIL more
symmetrical: modifications and checks goes to head page. It gives
better chance to recover in case of bug for non-DEBUG_VM kernel.

DEBUG_VM kernel will still trigger VM_BUG_ON() on modifications to tail
pages.

Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
---
 include/linux/page-flags.h | 4 +---
 1 file changed, 1 insertion(+), 3 deletions(-)

diff --git a/include/linux/page-flags.h b/include/linux/page-flags.h
index 2a2391c21558..465ca42af633 100644
--- a/include/linux/page-flags.h
+++ b/include/linux/page-flags.h
@@ -139,9 +139,7 @@ enum pageflags {
 #define PF_NO_TAIL(page, enforce) ({					\
 		if (enforce)						\
 			VM_BUG_ON_PAGE(PageTail(page), page);		\
-		else							\
-			page = compound_head(page);			\
-		page;})
+		compound_head(page);})
 #define PF_NO_COMPOUND(page, enforce) ({					\
 		if (enforce)						\
 			VM_BUG_ON_PAGE(PageCompound(page), page);	\
-- 
2.5.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
