Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f69.google.com (mail-it0-f69.google.com [209.85.214.69])
	by kanga.kvack.org (Postfix) with ESMTP id 2B1966B0314
	for <linux-mm@kvack.org>; Thu,  1 Jun 2017 04:17:27 -0400 (EDT)
Received: by mail-it0-f69.google.com with SMTP id z125so31767079itc.12
        for <linux-mm@kvack.org>; Thu, 01 Jun 2017 01:17:27 -0700 (PDT)
Received: from mail-it0-x242.google.com (mail-it0-x242.google.com. [2607:f8b0:4001:c0b::242])
        by mx.google.com with ESMTPS id j203si2422700iof.130.2017.06.01.01.17.26
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 01 Jun 2017 01:17:26 -0700 (PDT)
Received: by mail-it0-x242.google.com with SMTP id i206so4489771ita.3
        for <linux-mm@kvack.org>; Thu, 01 Jun 2017 01:17:26 -0700 (PDT)
From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Subject: [PATCH v1 9/9] mm: hwpoison: introduce idenfity_page_state
Date: Thu,  1 Jun 2017 17:16:59 +0900
Message-Id: <1496305019-5493-10-git-send-email-n-horiguchi@ah.jp.nec.com>
In-Reply-To: <1496305019-5493-1-git-send-email-n-horiguchi@ah.jp.nec.com>
References: <1496305019-5493-1-git-send-email-n-horiguchi@ah.jp.nec.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@kernel.org>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, Anshuman Khandual <khandual@linux.vnet.ibm.com>, linux-kernel@vger.kernel.org, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>

Factoring duplicate code into a function.

Signed-off-by: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
---
 mm/memory-failure.c | 57 +++++++++++++++++++++++------------------------------
 1 file changed, 25 insertions(+), 32 deletions(-)

diff --git v4.12-rc3/mm/memory-failure.c v4.12-rc3_patched/mm/memory-failure.c
index 85009ead..d4a88d0 100644
--- v4.12-rc3/mm/memory-failure.c
+++ v4.12-rc3_patched/mm/memory-failure.c
@@ -1025,9 +1025,31 @@ static bool hwpoison_user_mappings(struct page *p, unsigned long pfn,
 	return unmap_success;
 }
 
-static int memory_failure_hugetlb(unsigned long pfn, int trapno, int flags)
+static int identify_page_state(unsigned long pfn, struct page *p,
+				unsigned long page_flags)
 {
 	struct page_state *ps;
+
+	/*
+	 * The first check uses the current page flags which may not have any
+	 * relevant information. The second check with the saved page flags is
+	 * carried out only if the first check can't determine the page status.
+	 */
+	for (ps = error_states;; ps++)
+		if ((p->flags & ps->mask) == ps->res)
+			break;
+
+	page_flags |= (p->flags & (1UL << PG_dirty));
+
+	if (!ps->mask)
+		for (ps = error_states;; ps++)
+			if ((page_flags & ps->mask) == ps->res)
+				break;
+	return page_action(ps, p, pfn);
+}
+
+static int memory_failure_hugetlb(unsigned long pfn, int trapno, int flags)
+{
 	struct page *p = pfn_to_page(pfn);
 	struct page *head = compound_head(p);
 	int res;
@@ -1077,19 +1099,7 @@ static int memory_failure_hugetlb(unsigned long pfn, int trapno, int flags)
 		goto out;
 	}
 
-	res = -EBUSY;
-
-	for (ps = error_states;; ps++)
-		if ((p->flags & ps->mask) == ps->res)
-			break;
-
-	page_flags |= (p->flags & (1UL << PG_dirty));
-
-	if (!ps->mask)
-		for (ps = error_states;; ps++)
-			if ((page_flags & ps->mask) == ps->res)
-				break;
-	res = page_action(ps, p, pfn);
+	res = identify_page_state(pfn, p, page_flags);
 out:
 	unlock_page(head);
 	return res;
@@ -1115,7 +1125,6 @@ static int memory_failure_hugetlb(unsigned long pfn, int trapno, int flags)
  */
 int memory_failure(unsigned long pfn, int trapno, int flags)
 {
-	struct page_state *ps;
 	struct page *p;
 	struct page *hpage;
 	struct page *orig_head;
@@ -1273,23 +1282,7 @@ int memory_failure(unsigned long pfn, int trapno, int flags)
 	}
 
 identify_page_state:
-	res = -EBUSY;
-	/*
-	 * The first check uses the current page flags which may not have any
-	 * relevant information. The second check with the saved page flagss is
-	 * carried out only if the first check can't determine the page status.
-	 */
-	for (ps = error_states;; ps++)
-		if ((p->flags & ps->mask) == ps->res)
-			break;
-
-	page_flags |= (p->flags & (1UL << PG_dirty));
-
-	if (!ps->mask)
-		for (ps = error_states;; ps++)
-			if ((page_flags & ps->mask) == ps->res)
-				break;
-	res = page_action(ps, p, pfn);
+	res = identify_page_state(pfn, p, page_flags);
 out:
 	unlock_page(p);
 	return res;
-- 
2.7.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
