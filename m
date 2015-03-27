Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f172.google.com (mail-pd0-f172.google.com [209.85.192.172])
	by kanga.kvack.org (Postfix) with ESMTP id F35536B0032
	for <linux-mm@kvack.org>; Fri, 27 Mar 2015 07:39:43 -0400 (EDT)
Received: by pdcp1 with SMTP id p1so2585128pdc.3
        for <linux-mm@kvack.org>; Fri, 27 Mar 2015 04:39:43 -0700 (PDT)
Received: from mga11.intel.com (mga11.intel.com. [192.55.52.93])
        by mx.google.com with ESMTP id xe3si2514843pab.153.2015.03.27.04.39.42
        for <linux-mm@kvack.org>;
        Fri, 27 Mar 2015 04:39:42 -0700 (PDT)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: [PATCH] thp: do not adjust zone water marks if khugepaged is not started
Date: Fri, 27 Mar 2015 13:39:38 +0200
Message-Id: <1427456378-214780-1-git-send-email-kirill.shutemov@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, David Rientjes <rientjes@google.com>
Cc: Andrea Arcangeli <aarcange@redhat.com>, linux-mm@kvack.org, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

set_recommended_min_free_kbytes() adjusts zone water marks to be suitable
for khugepaged. We avoid doing this if khugepaged is disabled, but don't
catch the case when khugepaged is failed to start.

Let's address this by checking khugepaged_thread instead of
khugepaged_enabled() in set_recommended_min_free_kbytes().
It's NULL if the kernel thread is stopped or failed to start.

Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
---
 mm/huge_memory.c | 3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/mm/huge_memory.c b/mm/huge_memory.c
index a1594b18bc1b..370a3bbc960d 100644
--- a/mm/huge_memory.c
+++ b/mm/huge_memory.c
@@ -110,7 +110,8 @@ static int set_recommended_min_free_kbytes(void)
 	int nr_zones = 0;
 	unsigned long recommended_min;
 
-	if (!khugepaged_enabled())
+	/* khugepaged thread has stopped to failed to start */
+	if (!khugepaged_thread)
 		return 0;
 
 	for_each_populated_zone(zone)
-- 
2.1.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
